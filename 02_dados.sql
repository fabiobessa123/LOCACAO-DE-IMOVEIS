SET SERVEROUTPUT ON;

------------------------------------------------------------------------
-- INSERIR PROPRIETÁRIOS (5 registros)
------------------------------------------------------------------------

INSERT INTO proprietario (id_prop, nome, cpf_cnpj, email, telefone)
VALUES (seq_proprietario.NEXTVAL, 'Carlos Almeida', '12345678000191', 'carlos@imoveis.com', '31988880001');

INSERT INTO proprietario (id_prop, nome, cpf_cnpj, email, telefone)
VALUES (seq_proprietario.NEXTVAL, 'Fernanda Souza', '98765432000155', 'fernanda@imoveis.com', '31988880002');

INSERT INTO proprietario (id_prop, nome, cpf_cnpj, email, telefone)
VALUES (seq_proprietario.NEXTVAL, 'Marcos Pereira', '55566677000144', 'marcos@imoveis.com', '31988880003');

INSERT INTO proprietario (id_prop, nome, cpf_cnpj, email, telefone)
VALUES (seq_proprietario.NEXTVAL, 'Ana Ribeiro', '22233344000122', 'ana@imoveis.com', '31988880004');

INSERT INTO proprietario (id_prop, nome, cpf_cnpj, email, telefone)
VALUES (seq_proprietario.NEXTVAL, 'João Batista', '11122233000155', 'joao@imoveis.com', '31988880005');

------------------------------------------------------------------------
-- INSERIR INQUILINOS (8 registros)
------------------------------------------------------------------------

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Paulo Costa', '12345678901', 'paulo@mail.com', '31991110001');

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Juliana Silva', '98765432100', 'juliana@mail.com', '31991110002');

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Roberto Dias', '11122233344', 'roberto@mail.com', '31991110003');

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Maria Clara', '55566677788', 'maria@mail.com', '31991110004');

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Lucas Ferreira', '22233344455', 'lucas@mail.com', '31991110005');

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Aline Rocha', '99988877766', 'aline@mail.com', '31991110006');

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Carla Mendes', '44455566677', 'carla@mail.com', '31991110007');

INSERT INTO inquilino (id_inq, nome, cpf, email, telefone)
VALUES (seq_inquilino.NEXTVAL, 'Diego Souza', '33344455566', 'diego@mail.com', '31991110008');

------------------------------------------------------------------------
-- INSERIR IMÓVEIS (10 registros)
------------------------------------------------------------------------

-- Observação: ID_PROP vai de 1 a 5 (inseridos acima)

INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 1, 'Rua A, 100', '30100000', 'Belo Horizonte', 'MG', 'Apartamento', 1500, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 1, 'Rua B, 200', '30110000', 'Belo Horizonte', 'MG', 'Casa', 2500, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 2, 'Rua C, 300', '30120000', 'Contagem', 'MG', 'Apartamento', 1800, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 2, 'Rua D, 400', '30130000', 'Betim', 'MG', 'Casa', 2000, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 3, 'Rua E, 500', '30140000', 'Belo Horizonte', 'MG', 'Cobertura', 3500, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 4, 'Rua F, 600', '30150000', 'Contagem', 'MG', 'Kitnet', 900, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 4, 'Rua G, 700', '30160000', 'Contagem', 'MG', 'Casa', 1700, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 5, 'Rua H, 800', '30170000', 'Betim', 'MG', 'Apartamento', 1600, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 5, 'Rua I, 900', '30180000', 'Belo Horizonte', 'MG', 'Casa', 2200, 'DISPONIVEL');
INSERT INTO imovel VALUES (seq_imovel.NEXTVAL, 3, 'Rua J, 1000', '30190000', 'Betim', 'MG', 'Apartamento', 1400, 'DISPONIVEL');

------------------------------------------------------------------------
-- INSERIR 6 CONTRATOS (3 ATIVOS E 3 ENCERRADOS)
------------------------------------------------------------------------

-- ATIVOS
INSERT INTO contrato (id_contrato, id_imovel, id_inq, data_inicio, data_fim, valor_aluguel, garantia, situacao)
VALUES (seq_contrato.NEXTVAL, 1, 1, DATE '2025-01-01', DATE '2025-12-31', 1500, 'Fiador', 'ATIVO');

INSERT INTO contrato (id_contrato, id_imovel, id_inq, data_inicio, data_fim, valor_aluguel, garantia, situacao)
VALUES (seq_contrato.NEXTVAL, 2, 2, DATE '2025-02-01', DATE '2025-12-31', 2500, 'Caução', 'ATIVO');

INSERT INTO contrato (id_contrato, id_imovel, id_inq, data_inicio, data_fim, valor_aluguel, garantia, situacao)
VALUES (seq_contrato.NEXTVAL, 3, 3, DATE '2025-03-01', DATE '2025-12-31', 1800, 'Seguro Fiança', 'ATIVO');

-- ENCERRADOS
INSERT INTO contrato (id_contrato, id_imovel, id_inq, data_inicio, data_fim, valor_aluguel, garantia, situacao)
VALUES (seq_contrato.NEXTVAL, 4, 4, DATE '2024-01-01', DATE '2024-12-31', 2000, 'Caução', 'ENCERRADO');

INSERT INTO contrato (id_contrato, id_imovel, id_inq, data_inicio, data_fim, valor_aluguel, garantia, situacao)
VALUES (seq_contrato.NEXTVAL, 5, 5, DATE '2024-02-01', DATE '2024-12-31', 3500, 'Fiador', 'ENCERRADO');

INSERT INTO contrato (id_contrato, id_imovel, id_inq, data_inicio, data_fim, valor_aluguel, garantia, situacao)
VALUES (seq_contrato.NEXTVAL, 6, 6, DATE '2024-03-01', DATE '2024-12-31', 900, 'Caução', 'ENCERRADO');


-- INSERIR PAGAMENTOS 15 REGISTROS

-- Pagamentos do contrato 1 (ATIVO)
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 1, DATE '2025-01-10', NULL, 1500, NULL, NULL, 'PENDENTE');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 1, DATE '2025-02-10', DATE '2025-02-12', 1500, 30, 0, 'PAGO');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 1, DATE '2025-03-10', NULL, 1500, NULL, NULL, 'ATRASADO');

-- Pagamentos do contrato 2 (ATIVO)
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 2, DATE '2025-02-15', NULL, 2500, NULL, NULL, 'PENDENTE');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 2, DATE '2025-03-15', NULL, 2500, NULL, NULL, 'PENDENTE');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 2, DATE '2025-04-15', NULL, 2500, NULL, NULL, 'ATRASADO');

-- Pagamentos do contrato 3 (ATIVO)
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 3, DATE '2025-03-20', DATE '2025-03-20', 1800, 0, 0, 'PAGO');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 3, DATE '2025-04-20', NULL, 1800, NULL, NULL, 'PENDENTE');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 3, DATE '2025-05-20', NULL, 1800, NULL, NULL, 'PENDENTE');

-- Pagamentos de contratos ENCERRADOS
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 4, DATE '2024-10-10', DATE '2024-10-12', 2000, 40, 0, 'PAGO');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 4, DATE '2024-11-10', NULL, 2000, NULL, NULL, 'ATRASADO');

INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 5, DATE '2024-12-05', NULL, 3500, NULL, NULL, 'PENDENTE');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 6, DATE '2024-11-15', DATE '2024-11-16', 900, 0, 0, 'PAGO');
INSERT INTO pagamento VALUES (seq_pagamento.NEXTVAL, 6, DATE '2024-12-15', NULL, 900, NULL, NULL, 'ATRASADO');

COMMIT;
