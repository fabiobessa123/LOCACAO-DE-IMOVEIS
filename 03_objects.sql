SET SERVEROUTPUT ON;

-- função para calcular o total do saldo devedor de quem está com o status pendente

CREATE OR REPLACE FUNCTION fn_calcula_total_devedor (p_contrato_id NUMBER)
RETURN NUMBER
AS
    v_total NUMBER := 0;
BEGIN
    -- Soma apenas parcelas PENDENTES ou ATRASADAS que NÃO foram pagas
    SELECT SUM(valor + NVL(multa, 0))
    INTO v_total
    FROM pagamento
    WHERE id_contrato = p_contrato_id
      AND status IN ('PENDENTE', 'ATRASADO')
      AND (data_pagamento IS NULL OR data_pagamento > data_vencimento);
    
    RETURN NVL(v_total, 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        RETURN 0;
END;
/

CREATE OR REPLACE VIEW view_relatorio_saldo_contrato AS
SELECT 
    c.id_contrato,
    i.nome AS nome_inquilino,
    im.endereco,
    fn_calcula_total_devedor(c.id_contrato) AS total_devido,
    (SELECT COUNT(*) 
        FROM pagamento p 
        WHERE p.id_contrato = c.id_contrato 
          AND p.status = 'PENDENTE') AS parcelas_pendentes -- subselect para contar quantas parcelas pendentes tem no contrato
FROM contrato c
JOIN inquilino i ON i.id_inq = c.id_inq
JOIN imovel im ON im.id_imovel = c.id_imovel;
/

-- pkg contrato para visualização dos dados

CREATE OR REPLACE PACKAGE pkg_contratos AS 
    PROCEDURE criar_contrato(      -- procedure para criação de contrato
        p_imovel_id     NUMBER,
        p_inquilino_id  NUMBER,
        p_data_inicio   DATE,
        p_data_fim      DATE,
        p_valor         NUMBER,
        p_garantia      VARCHAR2,
        p_usuario       VARCHAR2
    );

    PROCEDURE encerrar_contrato( -- procedure para encerramento de contrato
        p_contrato_id   NUMBER,
        p_data_encerramento DATE,
        p_usuario       VARCHAR2
    );
END pkg_contratos;
/

-- pkg para inserção dos dados

CREATE OR REPLACE PACKAGE BODY pkg_contratos AS -- package body para logica

    PROCEDURE criar_contrato( 
        p_imovel_id     NUMBER, -- parametros do contrato
        p_inquilino_id  NUMBER,
        p_data_inicio   DATE,
        p_data_fim      DATE,
        p_valor         NUMBER,
        p_garantia      VARCHAR2,
        p_usuario       VARCHAR2
    ) IS
        v_status_imovel VARCHAR2(20);
        v_contrato_id   NUMBER; -- declaraçao de variavel
        v_mes DATE;
    BEGIN
        -- Valida se imóvel está disponível
        SELECT status INTO v_status_imovel 
        FROM imovel
        WHERE id_imovel = p_imovel_id
        FOR UPDATE; -- for update para nao ter mais de uma pessoa criando contrato

        IF v_status_imovel <> 'DISPONIVEL' THEN -- SE imovel for diferente de DISPONIVEL dá uma mensagem de erro e encerra, caso passe vai para criação de contrato
            RAISE_APPLICATION_ERROR(-20001, 'Imóvel não está disponível.');
        END IF;

        -- Cria contrato
        v_contrato_id := seq_contrato.NEXTVAL; -- cria o contrato com o id da sequence feita.

        INSERT INTO contrato (
            id_contrato, id_imovel, id_inq,
            data_inicio, data_fim, valor_aluguel,
            garantia, situacao
        ) VALUES ( -- inserção de dados caso o imovel esteja disponivel
            v_contrato_id, p_imovel_id, p_inquilino_id,
            p_data_inicio, p_data_fim, p_valor,
            p_garantia, 'ATIVO'
        );

        UPDATE imovel
        SET status = 'ALUGADO'
        WHERE id_imovel = p_imovel_id; -- muda o status de disponivel para alugado


        v_mes := p_data_inicio; --gerar parcela mensal

        WHILE v_mes <= p_data_fim LOOP -- caso a data inicial seja menor ou igual a data final, insere as proximas parcelas 
            INSERT INTO pagamento (
                id_pagto, id_contrato, data_vencimento, valor, status
            ) VALUES (
                seq_pagamento.NEXTVAL,
                v_contrato_id,
                v_mes,--ADD_MONTHS(p_data_inicio, TRUNC(MONTHS_BETWEEN(v_mes, p_data_inicio))), -- months_between, retorna quantos meses tem entre duas datas. o trunc serve para nao vir numeros quebrados.
                p_valor,
                'PENDENTE'
            );

            v_mes := ADD_MONTHS(v_mes, 1); -- função ADD_MONTHS adiciona sempre +1 mes
        END LOOP;

        COMMIT;
    END criar_contrato;

 -- pkg para encerrar contratos

    PROCEDURE encerrar_contrato(
        p_contrato_id NUMBER,
        p_data_encerramento DATE,
        p_usuario VARCHAR2
    ) IS
        v_imovel NUMBER;
    BEGIN
        SELECT id_imovel 
        INTO v_imovel
        FROM contrato
        WHERE id_contrato = p_contrato_id;

        UPDATE contrato
        SET situacao = 'ENCERRADO',
            data_fim = p_data_encerramento
        WHERE id_contrato = p_contrato_id;

        UPDATE imovel
        SET status = 'DISPONIVEL'
        WHERE id_imovel = v_imovel;

        COMMIT;
    END encerrar_contrato;

END pkg_contratos;
/


CREATE OR REPLACE PACKAGE pkg_financeiro AS
    PROCEDURE registrar_pagamento(
        p_pagto_id NUMBER,
        p_data_pag DATE,
        p_valor    NUMBER,
        p_usuario  VARCHAR2
    );

    PROCEDURE atualizar_atrasados;
END pkg_financeiro;
/


CREATE OR REPLACE PACKAGE BODY pkg_financeiro AS


    PROCEDURE registrar_pagamento(
        p_pagto_id NUMBER,
        p_data_pag DATE,
        p_valor    NUMBER,
        p_usuario  VARCHAR2
    ) IS
        v_venc DATE;
        v_dias NUMBER;
        v_multa NUMBER := 0;
    BEGIN
        SELECT data_vencimento INTO v_venc
        FROM pagamento
        WHERE id_pagto = p_pagto_id
        FOR UPDATE;

       
        IF p_data_pag > v_venc THEN
            v_dias := p_data_pag - v_venc;
            v_multa := v_dias * (p_valor * 0.01);
        END IF;

        UPDATE pagamento
        SET status = 'PAGO',
            data_pagamento = p_data_pag,
            multa = v_multa,
            juros = 0
        WHERE id_pagto = p_pagto_id;

        COMMIT;
    END registrar_pagamento;


    PROCEDURE atualizar_atrasados IS
    BEGIN
        UPDATE pagamento
        SET status = 'ATRASADO'
        WHERE status = 'PENDENTE'
          AND data_vencimento < TRUNC(SYSDATE);

        COMMIT;
    END atualizar_atrasados;

END pkg_financeiro;
/


CREATE OR REPLACE TRIGGER trg_auditoria
AFTER INSERT OR UPDATE OR DELETE ON pagamento
FOR EACH ROW
DECLARE
    v_operacao VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_operacao := 'INSERT';
    ELSIF UPDATING THEN
        v_operacao := 'UPDATE';
    ELSE
        v_operacao := 'DELETE';
    END IF;

    INSERT INTO log_auditoria (
        id_log, tabela, operacao, chave_registro, usuario, data_hora
    ) VALUES (
        seq_log_auditoria.NEXTVAL,
        'PAGAMENTO',
        v_operacao,
        NVL(:NEW.id_pagto, :OLD.id_pagto),
        USER,
        SYSDATE
    );
END;
/


CREATE OR REPLACE TRIGGER trg_auditoria_contrato
AFTER INSERT OR UPDATE OR DELETE ON contrato
FOR EACH ROW
DECLARE
    v_operacao VARCHAR2(10);
    v_chave VARCHAR2(100);
BEGIN
    IF INSERTING THEN 
        v_operacao := 'INSERT';
        v_chave := TO_CHAR(:NEW.id_contrato);
    ELSIF UPDATING THEN 
        v_operacao := 'UPDATE';
        v_chave := TO_CHAR(:NEW.id_contrato);
    ELSE 
        v_operacao := 'DELETE';
        v_chave := TO_CHAR(:OLD.id_contrato);
    END IF;

    INSERT INTO log_auditoria (
        id_log, 
        tabela, 
        operacao, 
        chave_registro, 
        usuario, 
        data_hora
    ) VALUES (
        seq_log_auditoria.NEXTVAL,
        'CONTRATO',
        v_operacao,
        v_chave,
        USER,
        SYSDATE
    );
END;
/