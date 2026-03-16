-- UNIVERSIDADE FEDERAL DO CARIRI - UFCA
-- PRÓ-REITORIA DE GRADUAÇÃO - PROGRAD
-- CENTRO DE EDUCAÇÃO À DISTÂNCIA - CEAD
-- Disciplina: ADS0011 | PROJETO DE BANCO DE DADOS

-- TEMA 4 – CATÁLOGO DE JOGOS DIGITAIS
-- Projeto Final — Etapa 4: Constraints e Integridade

-- Aluno: Júlio Cesar Batista da Silva
-- Matrícula: 2025014645
-- Professor: Dr. Jayr Alencar Pereira


-- ==========================================================
-- LIMPEZA (evita erro caso execute mais de uma vez)
-- ==========================================================

DROP TABLE IF EXISTS jogo_colecao CASCADE;
DROP TABLE IF EXISTS jogos CASCADE;
DROP TABLE IF EXISTS colecoes CASCADE;
DROP TYPE IF EXISTS status_jogo CASCADE;


-- ==========================================================
-- CRIAÇÃO DE TYPE ENUM
-- ==========================================================

CREATE TYPE status_jogo AS ENUM (
    'NÃO INICIADO',
    'JOGANDO',
    'FINALIZADO'
);


-- ==========================================================
-- CRIAÇÃO DA TABELA JOGOS
-- ==========================================================

CREATE TABLE jogos (
    id INT PRIMARY KEY,

    titulo VARCHAR(100) NOT NULL,
    genero VARCHAR(50) NOT NULL,
    plataforma VARCHAR(100) NOT NULL,

    horas_jogadas NUMERIC(6,2) NOT NULL DEFAULT 0,
    status status_jogo NOT NULL,

    avaliacao INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,

    ano_lancamento INT NOT NULL,

    time_stamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- CHECK: impede horas negativas
    CONSTRAINT ck_horas_jogadas
    CHECK (horas_jogadas >= 0),

    -- CHECK: avaliação deve estar entre 0 e 10
    CONSTRAINT ck_avaliacao
    CHECK (avaliacao BETWEEN 0 AND 10),

    -- CHECK: data_fim não pode ser menor que data_inicio
    CONSTRAINT ck_datas_validas
    CHECK (data_fim >= data_inicio),

    -- UNIQUE: impede duplicidade de jogo na mesma plataforma
    CONSTRAINT uk_titulo_plataforma
    UNIQUE (titulo, plataforma)
);


-- ==========================================================
-- CRIAÇÃO DA TABELA COLECOES
-- ==========================================================

CREATE TABLE colecoes (
    id INT PRIMARY KEY,

    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(200) NOT NULL,

    time_stamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ==========================================================
-- CRIAÇÃO DA TABELA RELACIONAMENTO (N:N)
-- ==========================================================

CREATE TABLE jogo_colecao (
    id INT PRIMARY KEY,

    jogo_id INT NOT NULL,
    colecao_id INT NOT NULL,

    time_stamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- UNIQUE: impede mesmo jogo na mesma coleção duas vezes
    CONSTRAINT uk_jogo_colecao
    UNIQUE (jogo_id, colecao_id),

    -- FK com regras explícitas
    CONSTRAINT fk_jogo_colecao_jogo
    FOREIGN KEY (jogo_id)
    REFERENCES jogos (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_jogo_colecao_colecao
    FOREIGN KEY (colecao_id)
    REFERENCES colecoes (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


-- ==========================================================
-- INSERÇÃO DE DADOS
-- ==========================================================

INSERT INTO jogos (
    id, titulo, genero, plataforma, horas_jogadas,
    status, avaliacao, data_inicio, data_fim,
    ano_lancamento
) VALUES
(1, 'The Witcher 3', 'RPG', 'PC', 120.5, 'FINALIZADO', 10, '2024-01-10', '2024-03-20', 2015),
(2, 'Cyberpunk 2077', 'RPG', 'PC', 45.0, 'JOGANDO', 8, '2025-01-05', '2025-12-31', 2020),
(3, 'Hades', 'Roguelike', 'Nintendo Switch', 0, 'NÃO INICIADO', 9, '2026-01-01', '2026-12-31', 2020);


INSERT INTO colecoes (
    id, nome, descricao
) VALUES
(1, 'RPG Favoritos', 'Jogos de RPG mais jogados'),
(2, 'Indies', 'Jogos independentes'),
(3, 'Backlog', 'Jogos ainda não iniciados');


INSERT INTO jogo_colecao (
    id, jogo_id, colecao_id
) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 2);


-- ==========================================================
-- CONSULTAS (SELECT)
-- ==========================================================

-- 1) Jogos e suas coleções
SELECT
    j.titulo AS jogo,
    c.nome AS colecao
FROM jogos j
INNER JOIN jogo_colecao jc ON j.id = jc.jogo_id
INNER JOIN colecoes c ON c.id = jc.colecao_id;


-- 2) Jogos mesmo que não pertençam a coleção
SELECT
    j.titulo AS jogo,
    c.nome AS colecao
FROM jogos j
LEFT JOIN jogo_colecao jc ON j.id = jc.jogo_id
LEFT JOIN colecoes c ON c.id = jc.colecao_id;


-- 3) Jogos RPG com avaliação >= 9
SELECT
    titulo,
    genero,
    avaliacao
FROM jogos
WHERE genero = 'RPG'
  AND avaliacao >= 9;


-- 4) Jogos finalizados
SELECT
    titulo,
    plataforma,
    horas_jogadas
FROM jogos
WHERE status = 'FINALIZADO';


-- 5) Quantidade de jogos por coleção
SELECT
    c.nome AS colecao,
    COUNT(jc.jogo_id) AS total_jogos
FROM colecoes c
LEFT JOIN jogo_colecao jc ON c.id = jc.colecao_id
GROUP BY c.nome;


-- ==========================================================
-- VIEW
-- ==========================================================

-- View que facilita a consulta de jogos com suas respectivas coleções.
-- Evita repetição frequente de JOINs no sistema.

CREATE VIEW vw_jogos_colecoes AS
SELECT
    j.id AS jogo_id,
    j.titulo,
    j.genero,
    j.plataforma,
    c.id AS colecao_id,
    c.nome AS nome_colecao
FROM jogos j
INNER JOIN jogo_colecao jc ON j.id = jc.jogo_id
INNER JOIN colecoes c ON c.id = jc.colecao_id;


-- ==========================================================
-- VIEW MATERIALIZADA
-- ==========================================================

-- View materializada para relatório de quantidade de jogos
-- e média de avaliação por coleção (melhora desempenho em consultas frequentes).

CREATE MATERIALIZED VIEW mv_relatorio_colecoes AS
SELECT
    c.id AS colecao_id,
    c.nome AS nome_colecao,
    COUNT(jc.jogo_id) AS total_jogos,
    AVG(j.avaliacao) AS media_avaliacao
FROM colecoes c
LEFT JOIN jogo_colecao jc ON c.id = jc.colecao_id
LEFT JOIN jogos j ON j.id = jc.jogo_id
GROUP BY c.id, c.nome;


-- ==========================================================
-- TRIGGERS
-- ==========================================================

-- Tabela de log para registrar inserções na tabela jogos

CREATE TABLE log_jogos (
    id SERIAL PRIMARY KEY,
    jogo_id INT,
    acao VARCHAR(50),
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- Trigger BEFORE
-- =====================================

-- Função que ajusta automaticamente horas_jogadas para 0
-- caso seja inserido valor negativo.

CREATE OR REPLACE FUNCTION fn_ajustar_horas()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.horas_jogadas < 0 THEN
        NEW.horas_jogadas := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_jogos
BEFORE INSERT OR UPDATE ON jogos
FOR EACH ROW
EXECUTE FUNCTION fn_ajustar_horas();


-- =====================================
-- Trigger AFTER
-- =====================================

-- Função que registra log após inserção de um novo jogo.

CREATE OR REPLACE FUNCTION fn_log_insercao_jogo()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_jogos (jogo_id, acao)
    VALUES (NEW.id, 'INSERÇÃO');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_insert_jogos
AFTER INSERT ON jogos
FOR EACH ROW
EXECUTE FUNCTION fn_log_insercao_jogo();


-- ==========================================================
-- PROCEDURE
-- ==========================================================

-- Procedure que atualiza o status de um jogo com base no total de horas jogadas.
-- Se horas_jogadas > 0 e status estiver como 'NÃO INICIADO',
-- o status será alterado para 'JOGANDO'.

CREATE OR REPLACE PROCEDURE sp_atualizar_status_jogo(p_jogo_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE jogos
    SET status = 'JOGANDO'
    WHERE id = p_jogo_id
      AND horas_jogadas > 0
      AND status = 'NÃO INICIADO';
END;
$$;


-- ==========================================================
-- ETAPA 6 – ANÁLISE E OTIMIZAÇÃO DE CONSULTAS (EXPLAIN)
-- ==========================================================

-- O objetivo desta seção é analisar o plano de execução de consultas
-- utilizando EXPLAIN ANALYZE e aplicar melhorias de desempenho.


-- ==========================================================
-- CONSULTA 1
-- Jogos RPG com avaliação >= 9
-- ==========================================================

-- Consulta original

SELECT
    titulo,
    genero,
    avaliacao
FROM jogos
WHERE genero = 'RPG'
AND avaliacao >= 9;


-- EXPLAIN ANALYZE (ANTES DA OTIMIZAÇÃO)

EXPLAIN ANALYZE
SELECT
    titulo,
    genero,
    avaliacao
FROM jogos
WHERE genero = 'RPG'
AND avaliacao >= 9;


-- PROBLEMA IDENTIFICADO
-- O PostgreSQL tende a realizar um Seq Scan (varredura completa da tabela),
-- pois não existe índice para a coluna genero ou avaliacao.


-- OTIMIZAÇÃO APLICADA
-- Criação de índice para melhorar filtragem por gênero e avaliação.

CREATE INDEX idx_jogos_genero_avaliacao
ON jogos (genero, avaliacao);


-- EXPLAIN ANALYZE (APÓS OTIMIZAÇÃO)

EXPLAIN ANALYZE
SELECT
    titulo,
    genero,
    avaliacao
FROM jogos
WHERE genero = 'RPG'
AND avaliacao >= 9;


-- MELHORIA OBSERVADA
-- Após a criação do índice, o PostgreSQL pode utilizar Index Scan
-- em vez de Seq Scan, reduzindo o número de linhas analisadas
-- e melhorando o desempenho da consulta.



-- ==========================================================
-- CONSULTA 2
-- Jogos e suas coleções (JOIN)
-- ==========================================================

SELECT
    j.titulo AS jogo,
    c.nome AS colecao
FROM jogos j
INNER JOIN jogo_colecao jc ON j.id = jc.jogo_id
INNER JOIN colecoes c ON c.id = jc.colecao_id;


-- EXPLAIN ANALYZE (ANTES DA OTIMIZAÇÃO)

EXPLAIN ANALYZE
SELECT
    j.titulo AS jogo,
    c.nome AS colecao
FROM jogos j
INNER JOIN jogo_colecao jc ON j.id = jc.jogo_id
INNER JOIN colecoes c ON c.id = jc.colecao_id;


-- PROBLEMA IDENTIFICADO
-- Sem índices adequados, o banco pode realizar Seq Scan
-- na tabela intermediária jogo_colecao durante o JOIN.


-- OTIMIZAÇÃO APLICADA
-- Criação de índice nas colunas utilizadas nos JOINs.

CREATE INDEX idx_jogo_colecao_jogo
ON jogo_colecao (jogo_id);

CREATE INDEX idx_jogo_colecao_colecao
ON jogo_colecao (colecao_id);


-- EXPLAIN ANALYZE (APÓS OTIMIZAÇÃO)

EXPLAIN ANALYZE
SELECT
    j.titulo AS jogo,
    c.nome AS colecao
FROM jogos j
INNER JOIN jogo_colecao jc ON j.id = jc.jogo_id
INNER JOIN colecoes c ON c.id = jc.colecao_id;


-- MELHORIA OBSERVADA
-- Com os índices, o PostgreSQL pode utilizar Index Scan ou Bitmap Index Scan
-- nas tabelas de relacionamento, tornando os JOINs mais eficientes.



-- ==========================================================
-- CONSULTA 3
-- Quantidade de jogos por coleção
-- ==========================================================

SELECT
    c.nome AS colecao,
    COUNT(jc.jogo_id) AS total_jogos
FROM colecoes c
LEFT JOIN jogo_colecao jc ON c.id = jc.colecao_id
GROUP BY c.nome;


-- EXPLAIN ANALYZE (ANTES DA OTIMIZAÇÃO)

EXPLAIN ANALYZE
SELECT
    c.nome AS colecao,
    COUNT(jc.jogo_id) AS total_jogos
FROM colecoes c
LEFT JOIN jogo_colecao jc ON c.id = jc.colecao_id
GROUP BY c.nome;


-- PROBLEMA IDENTIFICADO
-- O agrupamento pode exigir varredura completa da tabela
-- jogo_colecao caso não exista índice na coluna colecao_id.


-- OTIMIZAÇÃO APLICADA
-- Criação de índice para melhorar operações de agrupamento.

CREATE INDEX idx_jogo_colecao_colecao_group
ON jogo_colecao (colecao_id);


-- EXPLAIN ANALYZE (APÓS OTIMIZAÇÃO)

EXPLAIN ANALYZE
SELECT
    c.nome AS colecao,
    COUNT(jc.jogo_id) AS total_jogos
FROM colecoes c
LEFT JOIN jogo_colecao jc ON c.id = jc.colecao_id
GROUP BY c.nome;


-- MELHORIA OBSERVADA
-- O índice reduz o custo de acesso aos dados durante o JOIN
-- e pode melhorar a eficiência da operação de agregação.