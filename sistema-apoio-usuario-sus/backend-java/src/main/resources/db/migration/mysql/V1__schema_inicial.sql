-- Esquema principal utilizado pela API Apoio SUS em MySQL 8.
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario      INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(120) NOT NULL,
    email           VARCHAR(160) NOT NULL UNIQUE,
    senha           VARCHAR(255) NOT NULL,
    data_nascimento DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS perfil_saude (
    id_perfil           INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario          INT NOT NULL UNIQUE,
    peso                DECIMAL(7,2),
    altura              DECIMAL(5,2),
    tipo_sanguineo      VARCHAR(5),
    alergias            TEXT,
    observacoes_medicas TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS vacina (
    id_vacina        INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario       INT NOT NULL,
    nome_vacina      VARCHAR(150) NOT NULL,
    data_aplicacao   DATE NOT NULL,
    lote             VARCHAR(100),
    local_aplicacao  VARCHAR(255),
    INDEX idx_vacina_usuario (id_usuario),
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS medicamento (
    id_medicamento    INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario        INT NOT NULL,
    nome_medicamento  VARCHAR(150) NOT NULL,
    dosagem           VARCHAR(100),
    frequencia        VARCHAR(150),
    data_inicio       DATE,
    data_fim          DATE,
    INDEX idx_medicamento_usuario (id_usuario),
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
