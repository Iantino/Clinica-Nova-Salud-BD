-- Migración para bases existentes: tokens temporales para restablecer contraseñas.
-- Los tokens se guardan como SHA-256, tienen un solo uso y vencen a los 30 minutos.
USE clinica_nova_salud;

CREATE TABLE IF NOT EXISTS tokens_restablecimiento (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id  INT UNSIGNED NOT NULL,
  token_hash  CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
  vence_en    DATETIME NOT NULL,
  usado_en    DATETIME NULL,
  creado_en   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tokens_restablecimiento_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  INDEX idx_tokens_restablecimiento_usuario (usuario_id),
  INDEX idx_tokens_restablecimiento_vence (vence_en)
) ENGINE=InnoDB;
