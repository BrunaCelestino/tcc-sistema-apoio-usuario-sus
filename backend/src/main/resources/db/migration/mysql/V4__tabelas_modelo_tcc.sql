-- V4: tabelas previstas no modelo de dados do TCC.
-- id_usuario BIGINT para compatibilidade com a tabela usuario existente.
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
