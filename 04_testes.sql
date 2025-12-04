SET SERVEROUTPUT ON;
DECLARE
    v_contrato_id   NUMBER;
    v_status_imovel VARCHAR2(20);
    v_qtd_parcelas  NUMBER;
    v_multa         NUMBER;
    v_total_func    NUMBER;
    v_total_manual  NUMBER;
    v_erro          VARCHAR2(4000);
BEGIN

    DBMS_OUTPUT.PUT_LINE('1: CRIAR CONTRATO');
    
    BEGIN
        pkg_contratos.criar_contrato(
            p_imovel_id    => 1,
            p_inquilino_id => 1,
            p_data_inicio  => DATE '2025-01-01',
            p_data_fim     => DATE '2025-06-01',
            p_valor        => 1500,
            p_garantia     => 'FIADOR',
            p_usuario      => 'TESTE'
        );
    EXCEPTION WHEN OTHERS THEN
        v_erro := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('FAIL: erro ao criar contrato: ' || v_erro);
        RETURN;
    END;

    -- validação se o contrato foi criado
    SELECT MAX(id_contrato)
    INTO v_contrato_id
    FROM contrato
    WHERE id_imovel = 1;

    -- validar o status do imovel 
    SELECT status INTO v_status_imovel
    FROM imovel
    WHERE id_imovel = 1;

    -- validar o numero de parcelas
    SELECT COUNT(*)
    INTO v_qtd_parcelas
    FROM pagamento
    WHERE id_contrato = v_contrato_id;

    IF v_status_imovel = 'ALUGADO' AND v_qtd_parcelas = 6 THEN
        DBMS_OUTPUT.PUT_LINE('PASS: Contrato criado corretamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: Contrato criado, mas dados inconsistentes.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('2: REGISTRAR PAGAMENTO EM ATRASO');

    -- cria um pagamento atrasado 
    UPDATE pagamento
    SET data_vencimento = SYSDATE - 5   -- 5 dias atrasado
    WHERE id_contrato = v_contrato_id
      AND ROWNUM = 1
    RETURNING id_pagto INTO v_multa;

    COMMIT;

    -- registra um pagamento de hoje
    BEGIN
        pkg_financeiro.registrar_pagamento(
            p_pagto_id => v_multa,
            p_data_pag => SYSDATE,
            p_valor    => 1500,
            p_usuario  => 'TESTE'
        );
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FAIL: Erro ao registrar pagamento: ' || SQLERRM);
        RETURN;
    END;

    -- verificar multa 
    SELECT multa
    INTO v_multa
    FROM pagamento
    WHERE id_pagto = v_multa;

    IF v_multa = (1500 * 0.01 * 5) THEN
        DBMS_OUTPUT.PUT_LINE('PASS: Multa correta aplicada (' || v_multa || ').');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: Multa incorreta (' || v_multa || ').');
    END IF;

    DBMS_OUTPUT.PUT_LINE('3: ENCERRAR CONTRATO');

    BEGIN
        pkg_contratos.encerrar_contrato(
            p_contrato_id      => v_contrato_id,
            p_data_encerramento => SYSDATE,
            p_usuario           => 'TESTE'
        );
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FAIL: Erro ao encerrar contrato: ' || SQLERRM);
        RETURN;
    END;

    -- verificar se o contrato está encerrado
    SELECT situacao INTO v_status_imovel
    FROM contrato
    WHERE id_contrato = v_contrato_id;

    IF v_status_imovel = 'ENCERRADO' THEN
        DBMS_OUTPUT.PUT_LINE('PASS: Contrato encerrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: Contrato não foi encerrado.');
    END IF;

    -- Validar imóvel disponível
    SELECT status INTO v_status_imovel
    FROM imovel
    WHERE id_imovel = 1;

    IF v_status_imovel = 'DISPONIVEL' THEN
        DBMS_OUTPUT.PUT_LINE('PASS: Imóvel liberado corretamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: Imóvel não foi liberado.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('4: FUNÇÃO TOTAL DEVEDOR');
    
    -- as parcelas tem que ser pagas para nao interferir no calculo

    UPDATE pagamento
    SET status = 'PAGO',
        data_pagamento = SYSDATE,
        multa = 0
    WHERE id_contrato = v_contrato_id
      AND status IN ('PENDENTE', 'ATRASADO');
    
    COMMIT;

    -- Inserir duas parcelas pendentes para teste
    INSERT INTO pagamento (id_pagto, id_contrato, data_vencimento, valor, status)
    VALUES (seq_pagamento.NEXTVAL, v_contrato_id, SYSDATE + 10, 1000, 'PENDENTE');

    INSERT INTO pagamento (id_pagto, id_contrato, data_vencimento, valor, status)
    VALUES (seq_pagamento.NEXTVAL, v_contrato_id, SYSDATE + 20, 500, 'PENDENTE');

    COMMIT;

    v_total_manual := 1000 + 500;

    -- chamar função
    v_total_func := fn_calcula_total_devedor(v_contrato_id);

    IF v_total_func = v_total_manual THEN
        DBMS_OUTPUT.PUT_LINE('PASS: Função total devedor correta (' || v_total_func || ').');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: Função retornou ' || v_total_func || ', esperado ' || v_total_manual);
        -- DEBUG: Mostre quais parcelas estão sendo consideradas
        DBMS_OUTPUT.PUT_LINE('DEBUG - Parcelas do contrato ' || v_contrato_id || ':');
        FOR rec IN (
            SELECT id_pagto, valor, status, data_pagamento, multa
            FROM pagamento 
            WHERE id_contrato = v_contrato_id
            ORDER BY data_vencimento
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.id_pagto || 
                               ', Valor: ' || rec.valor || 
                               ', Status: ' || rec.status || 
                               ', Multa: ' || NVL(rec.multa, 0) ||
                               ', Pago: ' || CASE WHEN rec.data_pagamento IS NULL THEN 'NÃO' ELSE 'SIM' END);
        END LOOP;
    END IF;

    DBMS_OUTPUT.PUT_LINE('TESTE 5: CONCORRÊNCIA');

    -- Tentar alugar um imóvel que esta alugado
    -- Verifica se imóvel 2 está realmente ALUGADO
    SELECT status INTO v_status_imovel
    FROM imovel
    WHERE id_imovel = 2;
    
    DBMS_OUTPUT.PUT_LINE('Status do imóvel 2: ' || v_status_imovel);
    
    -- Tenta criar outro contrato para o MESMO imóvel 2 (que já está alugado)
    BEGIN
        pkg_contratos.criar_contrato(
            p_imovel_id    => 2,
            p_inquilino_id => 2,
            p_data_inicio  => SYSDATE + 30,  -- Data FUTURA
            p_data_fim     => SYSDATE + 60,
            p_valor        => 1000,
            p_garantia     => 'TESTE',
            p_usuario      => 'TESTE'
        );

        DBMS_OUTPUT.PUT_LINE('FAIL: Concorrência falhou. Contrato criado quando não deveria.');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PASS: Concorrência funcionando. Erro esperado: ' || SQLERRM);
    END;

END;
/