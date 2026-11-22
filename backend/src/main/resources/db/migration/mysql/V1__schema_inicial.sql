-- Esquema principal utilizado pela API Apoio SUS em MySQL 8.
-- Os campos id_usuario usam BIGINT para manter compatibilidade com o schema apoio_usuario_sus.
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario      BIGINT NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(150) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    senha           VARCHAR(255) NOT NULL COMMENT 'Armazenar somente hash seguro da senha',
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
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE
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
    CONSTRAINT fk_vacina_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE
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
    CONSTRAINT fk_medicamento_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS unidade_saude (
    id_unidade        INT NOT NULL AUTO_INCREMENT,
    nome              VARCHAR(160) NOT NULL,
    endereco          VARCHAR(255),
    municipio         VARCHAR(100),
    telefone          VARCHAR(30),
    tipo_atendimento  VARCHAR(100),
    latitude          DECIMAL(9,6),
    longitude         DECIMAL(9,6),
    fonte             VARCHAR(255),
    atualizado_em     DATE,
    PRIMARY KEY (id_unidade),
    INDEX idx_unidade_municipio (municipio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS campanha_vacinacao (
    id_campanha    INT NOT NULL AUTO_INCREMENT,
    titulo         VARCHAR(160) NOT NULL,
    descricao      TEXT,
    data_inicio    DATE,
    data_fim       DATE,
    publico_alvo   VARCHAR(255),
    fonte          VARCHAR(255),
    atualizado_em  DATE,
    PRIMARY KEY (id_campanha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS orientacao_saude (
    id_orientacao             INT NOT NULL AUTO_INCREMENT,
    tema                      VARCHAR(160) NOT NULL,
    conteudo_preventivo       TEXT,
    procedimentos_recomendados TEXT,
    fonte                     VARCHAR(255),
    atualizado_em             DATE,
    PRIMARY KEY (id_orientacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS analise_sintoma (
    id_analise           INT NOT NULL AUTO_INCREMENT,
    id_usuario           BIGINT NOT NULL,
    id_orientacao        INT,
    sintomas_informados  TEXT NOT NULL,
    data_analise         DATETIME(6) NOT NULL,
    PRIMARY KEY (id_analise),
    INDEX idx_analise_usuario (id_usuario),
    CONSTRAINT fk_analise_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_analise_orientacao
        FOREIGN KEY (id_orientacao) REFERENCES orientacao_saude (id_orientacao) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
