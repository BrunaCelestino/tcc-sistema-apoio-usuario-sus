-- Esquema consolidado do Apoio SUS (MySQL 8).
-- Documento de referência equivalente às migrations V1, V2 e V3.
-- A aplicacao executa as migrations automaticamente ao iniciar.
-- Nao executar este arquivo sobre um banco em uso sem backup.

CREATE DATABASE IF NOT EXISTS apoio_usuario_sus
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE apoio_usuario_sus;

-- Tabela tecnica criada pelo inicializador Banco.criarTabelas().
CREATE TABLE IF NOT EXISTS schema_migracao (
    versao      INT NOT NULL,
    aplicada_em DATETIME(6) NOT NULL,
    PRIMARY KEY (versao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- V1: dados persistentes do usuario e do seu perfil.
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario      BIGINT NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(150) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    senha           VARCHAR(255) NOT NULL COMMENT 'Hash PBKDF2; nunca armazenar senha em texto puro',
    data_nascimento DATE DEFAULT NULL,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY uq_usuario_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS perfil_saude (
    id_perfil           INT NOT NULL AUTO_INCREMENT,
    id_usuario          BIGINT NOT NULL,
    peso                DECIMAL(7,2),
    altura              DECIMAL(5,2),
    tipo_sanguineo      VARCHAR(5),
    alergias            TEXT,
    observacoes_medicas TEXT,
    PRIMARY KEY (id_perfil),
    UNIQUE KEY uq_perfil_usuario (id_usuario),
    CONSTRAINT fk_perfil_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS vacina (
    id_vacina        INT NOT NULL AUTO_INCREMENT,
    id_usuario       BIGINT NOT NULL,
    nome_vacina      VARCHAR(150) NOT NULL,
    data_aplicacao   DATE NOT NULL,
    lote             VARCHAR(100),
    local_aplicacao  VARCHAR(255),
    PRIMARY KEY (id_vacina),
    INDEX idx_vacina_usuario (id_usuario),
    CONSTRAINT fk_vacina_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS medicamento (
    id_medicamento    INT NOT NULL AUTO_INCREMENT,
    id_usuario        BIGINT NOT NULL,
    nome_medicamento  VARCHAR(150) NOT NULL,
    dosagem           VARCHAR(100),
    frequencia        VARCHAR(150),
    data_inicio       DATE,
    data_fim          DATE,
    PRIMARY KEY (id_medicamento),
    INDEX idx_medicamento_usuario (id_usuario),
    CONSTRAINT fk_medicamento_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- V1: tabelas previstas no modelo de dados do TCC.
CREATE TABLE IF NOT EXISTS unidade_saude (
    id_unidade INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(160) NOT NULL,
    endereco VARCHAR(255),
    municipio VARCHAR(100),
    telefone VARCHAR(30),
    tipo_atendimento VARCHAR(100),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    fonte VARCHAR(255),
    atualizado_em DATE,
    PRIMARY KEY (id_unidade),
    INDEX idx_unidade_municipio (municipio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS campanha_vacinacao (
    id_campanha INT NOT NULL AUTO_INCREMENT,
    titulo VARCHAR(160) NOT NULL,
    descricao TEXT,
    data_inicio DATE,
    data_fim DATE,
    publico_alvo VARCHAR(255),
    fonte VARCHAR(255),
    atualizado_em DATE,
    PRIMARY KEY (id_campanha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS orientacao_saude (
    id_orientacao INT NOT NULL AUTO_INCREMENT,
    tema VARCHAR(160) NOT NULL,
    conteudo_preventivo TEXT,
    procedimentos_recomendados TEXT,
    fonte VARCHAR(255),
    atualizado_em DATE,
    PRIMARY KEY (id_orientacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS analise_sintoma (
    id_analise INT NOT NULL AUTO_INCREMENT,
    id_usuario BIGINT NOT NULL,
    id_orientacao INT,
    sintomas_informados TEXT NOT NULL,
    data_analise DATETIME(6) NOT NULL,
    PRIMARY KEY (id_analise),
    INDEX idx_analise_usuario (id_usuario),
    CONSTRAINT fk_analise_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_analise_orientacao FOREIGN KEY (id_orientacao)
        REFERENCES orientacao_saude (id_orientacao) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- V2: sessoes de autenticacao. O token em si nao e armazenado; somente seu SHA-256.
CREATE TABLE IF NOT EXISTS sessao (
    id_sessao    INT NOT NULL AUTO_INCREMENT,
    id_usuario   BIGINT NOT NULL,
    token_hash   VARCHAR(64) NOT NULL,
    criado_em    DATETIME(6) NOT NULL,
    expira_em    DATETIME(6) NOT NULL,
    revogada_em  DATETIME(6),
    PRIMARY KEY (id_sessao),
    UNIQUE KEY uq_sessao_token_hash (token_hash),
    INDEX idx_sessao_usuario (id_usuario),
    CONSTRAINT fk_sessao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- V3: codigos de recuperacao de senha. O codigo original tambem nao e armazenado.
CREATE TABLE IF NOT EXISTS recuperacao_senha (
    id_recuperacao  INT NOT NULL AUTO_INCREMENT,
    id_usuario      BIGINT NOT NULL,
    token_hash      VARCHAR(64) NOT NULL,
    criado_em       DATETIME(6) NOT NULL,
    expira_em       DATETIME(6) NOT NULL,
    usado_em        DATETIME(6),
    PRIMARY KEY (id_recuperacao),
    UNIQUE KEY uq_recuperacao_token_hash (token_hash),
    INDEX idx_recuperacao_usuario (id_usuario),
    CONSTRAINT fk_recuperacao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Unidades consultadas sao obtidas diretamente do CNES e nao sao persistidas localmente.
-- Orientacoes e regras de sintomas sao carregadas de orientacoes.json e sintomas.json.
-- Campanhas de vacinacao e historico de analises de sintomas nao estao implementados.
