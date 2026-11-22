CREATE TABLE IF NOT EXISTS sessao (
    id_sessao    INT NOT NULL AUTO_INCREMENT,
    id_usuario   BIGINT NOT NULL,
    token_hash   VARCHAR(64) NOT NULL UNIQUE,
    criado_em    DATETIME(6) NOT NULL,
    expira_em    DATETIME(6) NOT NULL,
    revogada_em  DATETIME(6),
    PRIMARY KEY (id_sessao),
    INDEX idx_sessao_usuario (id_usuario),
    CONSTRAINT fk_sessao_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
