CREATE TABLE IF NOT EXISTS recuperacao_senha (
    id_recuperacao  INT NOT NULL AUTO_INCREMENT,
    id_usuario      BIGINT NOT NULL,
    token_hash      VARCHAR(64) NOT NULL UNIQUE,
    criado_em       DATETIME(6) NOT NULL,
    expira_em       DATETIME(6) NOT NULL,
    usado_em        DATETIME(6),
    PRIMARY KEY (id_recuperacao),
    INDEX idx_recuperacao_usuario (id_usuario),
    CONSTRAINT fk_recuperacao_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
