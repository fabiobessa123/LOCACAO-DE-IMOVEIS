-- tabela propietario
CREATE TABLE proprietario (
    id_prop      NUMBER          NOT NULL,
    nome         VARCHAR2(100)   NOT NULL,
    cpf_cnpj     VARCHAR2(18)    NOT NULL,
    email        VARCHAR2(150),
    telefone     VARCHAR2(20),
    CONSTRAINT pk_proprietario PRIMARY KEY (id_prop), -- primary key identificador do propietario
    CONSTRAINT uq_proprietario_cpf_cnpj UNIQUE (cpf_cnpj) -- UNIQUE para nao ter duplicidade de CPF
);
-- tabela inquilino
CREATE TABLE inquilino (
    id_inq       NUMBER          NOT NULL,
    nome         VARCHAR2(100)   NOT NULL,
    cpf          VARCHAR2(14)    NOT NULL,
    email        VARCHAR2(150),
    telefone     VARCHAR2(20),
    CONSTRAINT pk_inquilino PRIMARY KEY (id_inq), -- primary key identificador do inquilino
    CONSTRAINT uq_inquilino_cpf UNIQUE (cpf) -- UNIQUE para nao ter duplicidade de CPF
);
-- tabela imovel
CREATE TABLE imovel (
    id_imovel     NUMBER          NOT NULL,
    id_prop       NUMBER          NOT NULL,
    endereco      VARCHAR2(200)   NOT NULL,
    cep           VARCHAR2(10),
    cidade        VARCHAR2(60)    NOT NULL,
    uf            CHAR(2)         NOT NULL,
    tipo          VARCHAR2(30)    NOT NULL,
    valor_aluguel NUMBER(10,2)    NOT NULL,
    status        VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_imovel PRIMARY KEY (id_imovel), -- primary key identificador do imovel
    CONSTRAINT fk_imovel_proprietario -- foreign key id prop da tabela propietario
        FOREIGN KEY (id_prop)
        REFERENCES proprietario (id_prop), 
    CONSTRAINT ck_imovel_status
        CHECK (status IN ('DISPONIVEL', 'ALUGADO'))--check para coluna STATUS receber apenas DISPONIVEL e ALUGADO
);
-- tabela contrato
CREATE TABLE contrato (
    id_contrato    NUMBER          NOT NULL,
    id_imovel      NUMBER          NOT NULL,
    id_inq         NUMBER          NOT NULL,
    data_inicio    DATE            NOT NULL,
    data_fim       DATE            NOT NULL,
    valor_aluguel  NUMBER(10,2)    NOT NULL,
    garantia       VARCHAR2(200),
    situacao       VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_contrato PRIMARY KEY (id_contrato),
    CONSTRAINT fk_contrato_imovel -- foreign key id imovel da tabela imovel
        FOREIGN KEY (id_imovel)
        REFERENCES imovel (id_imovel), 
    CONSTRAINT fk_contrato_inquilino -- foreign key id inq da tabela inquilino
        FOREIGN KEY (id_inq)
        REFERENCES inquilino (id_inq),
    CONSTRAINT ck_contrato_situacao
        CHECK (situacao IN ('ATIVO', 'ENCERRADO')) --check para coluna SITUACAO receber apenas ATIVO e ENCERRADO
);
-- tabela pagamento
CREATE TABLE pagamento (
    id_pagto         NUMBER         NOT NULL,
    id_contrato      NUMBER         NOT NULL,
    data_vencimento  DATE           NOT NULL,
    data_pagamento   DATE,
    valor            NUMBER(10,2)   NOT NULL,
    multa            NUMBER(10,2),
    juros            NUMBER(10,2),
    status           VARCHAR2(20)   NOT NULL,
    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagto),
    CONSTRAINT fk_pagamento_contrato -- foreign key id contrato da tabela contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contrato (id_contrato),
    CONSTRAINT ck_pagamento_status
        CHECK (status IN ('PENDENTE', 'PAGO', 'ATRASADO')) -- check para coluna status receber apenas DISPONIVEL e alugado
);
-- tabela auditoria
CREATE TABLE log_auditoria (
    id_log          NUMBER          NOT NULL,
    tabela          VARCHAR2(30)    NOT NULL,
    operacao        VARCHAR2(10)    NOT NULL,
    chave_registro  VARCHAR2(100)   NOT NULL,
    usuario         VARCHAR2(100),
    data_hora       DATE            DEFAULT SYSDATE NOT NULL,
    detalhes        VARCHAR2(4000),
    CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log) -- primary key identificador da auditoria
);

-- sequencias para referenciar o proximo numero sequencial do id principal das tabelas
-- exemplo (insert into tabela ( id_tabela , nome, idade) values (seq_tabela.nextval, 'fabio',25))
CREATE SEQUENCE seq_proprietario
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE seq_inquilino
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE seq_imovel
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE seq_contrato
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE seq_pagamento
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE seq_log_auditoria
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- indices paras KEYS, feitos para otimizar os selects para consultas mais rapidas.

CREATE INDEX idx_imovel_id_prop
    ON imovel (id_prop);

CREATE INDEX idx_contrato_id_imovel
    ON contrato (id_imovel);

CREATE INDEX idx_contrato_id_inq
    ON contrato (id_inq);

CREATE INDEX idx_pagamento_id_contrato
    ON pagamento (id_contrato);

CREATE INDEX idx_log_aud_tabela_chave
    ON log_auditoria (tabela, chave_registro);