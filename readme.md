Sistema de Locação de Imóveis – Implementação PL/SQL (Oracle)
Sobre o Projeto
Implementação completa da camada de banco de dados de um sistema de locação de imóveis, desenvolvida em PL/SQL Oracle. O sistema contempla modelagem relacional, regras de negócio encapsuladas em packages, auditoria automatizada e testes funcionais com validação PASS/FAIL.

Objetivo do Projeto
Atender integralmente ao teste técnico proposto, demonstrando domínio dos seguintes conceitos:

Modelagem relacional com constraints adequadas

Programação PL/SQL (packages, procedures, functions)

Gatilhos (triggers) para auditoria e integridade

Views para abstração de dados

Testes automatizados com validação de cenários

Documentação técnica clara e completa

Estrutura dos Arquivos
Ordem de Execução:

projeto/
 01_schema.sql          -- Criação do schema completo
 02_dados.sql           -- Dados iniciais para testes
 03_objects.sql         -- Packages, functions, triggers, view
 04_tests.sql           -- Testes automatizados (PASS/FAIL)
README.md              -- Esta documentação
Execute os arquivos exatamente nesta sequência.

Pré-requisitos Técnicos
Banco de Dados: Oracle Database 11g/12c ou superior

Ferramenta Recomendada: SQL Developer ou SQL*Plus

Configuração Necessária:

Modelagem de Dados
Tabelas Implementadas:

proprietario - Cadastro de proprietários

inquilino - Cadastro de inquilinos

imovel - Catálogo de imóveis (status: DISPONIVEL/ALUGADO)

contrato - Contratos de locação (status: ATIVO/ENCERRADO)

pagamento - Parcelas mensais (status: PENDENTE/PAGO/ATRASADO)

log_auditoria - Log de operações DML (INSERT/UPDATE/DELETE)

Implementação PL/SQL
Package: PKG_CONTRATOS
Gerencia o ciclo dos contratos de locação.

Procedimento	Descrição	Regras de Negócio
criar_contrato	Cria novo contrato	• Valida disponibilidade do imóvel
• Gera parcelas mensais automaticamente
• Atualiza status do imóvel para ALUGADO
• Transação atômica (commit/rollback)
encerrar_contrato	Finaliza contrato	• Altera status para ENCERRADO
• Libera imóvel (status: DISPONIVEL)
Package: PKG_FINANCEIRO
Gerencia o financeiro do sistema.

Procedimento	Descrição	Regras de Negócio
registrar_pagamento	Registra pagamento de parcela	• Calcula multa por atraso (1% ao dia)
• Atualiza status para PAGO
• Registra data/hora do pagamento
atualizar_atrasados	Atualiza status de parcelas vencidas	• Marca automaticamente como ATRASADO
• Executável via job agendado
Função: FN_CALCULA_TOTAL_DEVEDOR

-- Interface:
FUNCTION fn_calcula_total_devedor(
    p_contrato_id IN NUMBER
) RETURN NUMBER;

-- Funcionalidade:
-- Calcula: Σ(valor_parcela + multa) para parcelas PENDENTES/ATRASADAS
View: VIEW_RELATORIO_SALDO_CONTRATO

-- Apresenta:
• Dados do contrato
• Informações do imóvel e inquilino
• Saldo devedor atual (usa a função acima)
• Status financeiro
Triggers de Auditoria
Implementados nas tabelas contrato e pagamento:

Trigger	Tabela	Operações	Propósito
trg_audit_contrato	contrato	INSERT, UPDATE, DELETE	Auditabilidade completa
trg_audit_pagamento	pagamento	INSERT, UPDATE, DELETE	Rastreabilidade financeira
Registra na tabela log_auditoria:

Tabela afetada

Tipo de operação (I/U/D)

Chave primária do registro

Usuário que executou

Timestamp exato

Valores antigos/novos (JSON)

Sistema de Testes Automatizados
Arquivo: 04_tests.sql
Executa 5 cenários críticos com validação automática:

Teste:	Cenário	Validação Esperada	Resultado
1	Criação de contrato válido	• Contrato criado
• Imóvel → ALUGADO
• Parcelas geradas	 PASS
2	Pagamento com atraso	• Multa calculada (1% ao dia)
• Status → PAGO	 PASS
3	Encerramento de contrato	• Contrato → ENCERRADO
• Imóvel → DISPONIVEL PASS
4	Cálculo de saldo devedor	• Função retorna valor correto PASS
5	Concorrência (imóvel alugado 2x)	• Segunda tentativa FALHA PASS
Saída do teste:


INICIANDO TESTES

TESTE 1: Criar contrato válido...
✓ Contrato criado: ID = ID gerado automaticamente
✓ Imóvel atualizado para ALUGADO
✓ Parcelas geradas: 6 parcelas
RESULTADO: PASS

TESTE 2: Pagamento em atraso...
✓ Multa calculada: R$ 75,00 (5 dias atraso)
RESULTADO: PASS


Suposições e Decisões de Projeto
Item	Decisão	Justificativa
Multa por atraso	1% ao dia	Conforme especificado no enunciado
Geração de parcelas	Mensal, via ADD_MONTHS	Simples e alinhado com mercado
Usuário de auditoria	USER do Oracle	Rastreabilidade nativa
Idempotência	Scripts reinicializáveis	Facilita testes e demonstração
Status do imóvel	DISPONIVEL/ALUGADO	Estados mínimos necessários
Cronograma de Desenvolvimento
Fase	Tempo Estimado	Atividades
Análise e Modelagem	2 horas	
• Levantamento de requisitos
• Definição de constraints
Implementação do Schema	1 hora	
• Criação de tabelas
• Sequences e índices
• Constraints
População de Dados	30 min	
• Dados de teste realistas
Desenvolvimento PL/SQL	3 horas	
• Packages (contratos + financeiro)
• Função e view
• Tratamento de erros
Implementação de Triggers	1 hora	
• Auditoria
• Log estruturado
Testes Automatizados	1 hora	
• 5 cenários críticos
• Validação PASS/FAIL
Documentação	40 min	
• README técnico
• Comentários no código

Total: 9 horas de desenvolvimento

Competências Demonstradas
Técnicas:
Modelagem de Banco de Dados - Schema normalizado com constraints

PL/SQL - Packages, procedures, functions

Gatilhos (Triggers) - Para auditoria e integridade

Otimização - Índices e boas práticas

Testes Automatizados - Validação sistemática

Documentação - Código comentado e README técnico

Execute na ordem:

@01_schema.sql
@02_dados.sql
@03_objects.sql
@04_tests.sql

Confira a saída: Todos os 5 testes devem mostrar PASS

Explore os objetos criados:

-- Verificar dados de auditoria
SELECT * FROM log_auditoria ORDER BY data_hora DESC;

-- Consultar a view
SELECT * FROM view_relatorio_saldo_contrato;