-- =====================================================================
-- MediAgenda - Clínica NovaSalud
-- Script de creación de la base de datos (HU-02)
-- ADVERTENCIA: borra las tablas existentes y sus datos. Úsalo solo en desarrollo.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS clinica_nova_salud
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE clinica_nova_salud;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS bitacora_expedientes;
DROP TABLE IF EXISTS receta_detalle;
DROP TABLE IF EXISTS recetas;
DROP TABLE IF EXISTS consultas;
DROP TABLE IF EXISTS citas;
DROP TABLE IF EXISTS pacientes;
DROP TABLE IF EXISTS horarios_medico;
DROP TABLE IF EXISTS medicos;
DROP TABLE IF EXISTS especialidades;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS roles;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- Seguridad: roles y usuarios (RF-01, RF-02, RNF-03)
-- ---------------------------------------------------------------------
CREATE TABLE roles (
  id      TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre  VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  rol_id             TINYINT UNSIGNED NOT NULL,
  nombre             VARCHAR(80)  NOT NULL,
  apellido           VARCHAR(80)  NOT NULL,
  correo             VARCHAR(120) NOT NULL UNIQUE,
  password_hash      VARCHAR(255) NOT NULL,
  activo             BOOLEAN NOT NULL DEFAULT TRUE,
  intentos_fallidos  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  bloqueado_hasta    DATETIME NULL,
  creado_en          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id) REFERENCES roles(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Médicos, especialidades y horarios (RF-05)
-- ---------------------------------------------------------------------
CREATE TABLE especialidades (
  id           SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(80) NOT NULL UNIQUE,
  descripcion  VARCHAR(255) NULL,
  activo       BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE medicos (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id       INT UNSIGNED NOT NULL UNIQUE,
  especialidad_id  SMALLINT UNSIGNED NOT NULL,
  colegiado        VARCHAR(20) NOT NULL UNIQUE,
  telefono         VARCHAR(15) NULL,
  CONSTRAINT fk_medicos_usuario      FOREIGN KEY (usuario_id)      REFERENCES usuarios(id),
  CONSTRAINT fk_medicos_especialidad FOREIGN KEY (especialidad_id) REFERENCES especialidades(id)
) ENGINE=InnoDB;

-- dia_semana: 1 = lunes ... 7 = domingo
CREATE TABLE horarios_medico (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  medico_id    INT UNSIGNED NOT NULL,
  dia_semana   TINYINT UNSIGNED NOT NULL,
  hora_inicio  TIME NOT NULL,
  hora_fin     TIME NOT NULL,
  CONSTRAINT fk_horarios_medico FOREIGN KEY (medico_id) REFERENCES medicos(id) ON DELETE CASCADE,
  CONSTRAINT chk_horario_dia   CHECK (dia_semana BETWEEN 1 AND 7),
  CONSTRAINT chk_horario_horas CHECK (hora_fin > hora_inicio),
  CONSTRAINT uq_horario UNIQUE (medico_id, dia_semana, hora_inicio)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Pacientes (RF-03, RF-04, RF-13)
-- usuario_id solo existe si el paciente se registró en el portal.
-- dpi es opcional porque los pacientes de pediatría no tienen DPI.
-- ---------------------------------------------------------------------
CREATE TABLE pacientes (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id        INT UNSIGNED NULL UNIQUE,
  dpi               CHAR(13) NULL UNIQUE,
  nombre            VARCHAR(80) NOT NULL,
  apellido          VARCHAR(80) NOT NULL,
  fecha_nacimiento  DATE NOT NULL,
  sexo              ENUM('F','M') NOT NULL,
  telefono          VARCHAR(15) NOT NULL,
  correo            VARCHAR(120) NULL,
  direccion         VARCHAR(255) NULL,
  nombre_encargado  VARCHAR(160) NULL,
  alergias          TEXT NULL,
  antecedentes      TEXT NULL,
  creado_en         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pacientes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  INDEX idx_pacientes_nombre (apellido, nombre),
  INDEX idx_pacientes_telefono (telefono)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Citas (RF-06 a RF-09, RF-14)
-- La columna "ocupa_horario" vale NULL si la cita está cancelada, así el
-- índice único impide dos citas activas del mismo médico a la misma hora,
-- pero permite volver a usar el horario de una cita cancelada.
-- ---------------------------------------------------------------------
CREATE TABLE citas (
  id                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  paciente_id           INT UNSIGNED NOT NULL,
  medico_id             INT UNSIGNED NOT NULL,
  fecha                 DATE NOT NULL,
  hora_inicio           TIME NOT NULL,
  hora_fin              TIME NOT NULL,
  estado                ENUM('programada','confirmada','en_atencion','atendida','cancelada','no_asistio')
                          NOT NULL DEFAULT 'programada',
  motivo                VARCHAR(255) NULL,
  motivo_cancelacion    VARCHAR(255) NULL,
  recordatorio_enviado  BOOLEAN NOT NULL DEFAULT FALSE,
  creada_por            INT UNSIGNED NOT NULL,
  creado_en             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ocupa_horario         TINYINT AS (IF(estado = 'cancelada', NULL, 1)) STORED,
  CONSTRAINT fk_citas_paciente   FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
  CONSTRAINT fk_citas_medico     FOREIGN KEY (medico_id)   REFERENCES medicos(id),
  CONSTRAINT fk_citas_creada_por FOREIGN KEY (creada_por)  REFERENCES usuarios(id),
  CONSTRAINT chk_citas_horas CHECK (hora_fin > hora_inicio),
  CONSTRAINT uq_cita_horario UNIQUE (medico_id, fecha, hora_inicio, ocupa_horario),
  INDEX idx_citas_fecha_estado (fecha, estado),
  INDEX idx_citas_paciente (paciente_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Expediente clínico: consultas y recetas (RF-10, RF-11, RF-12)
-- Cada cita atendida genera una consulta; cada consulta puede tener una receta.
-- ---------------------------------------------------------------------
CREATE TABLE consultas (
  id                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cita_id              INT UNSIGNED NOT NULL UNIQUE,
  motivo_consulta      VARCHAR(255) NOT NULL,
  presion_arterial     VARCHAR(10) NULL,
  frecuencia_cardiaca  SMALLINT UNSIGNED NULL,
  temperatura          DECIMAL(4,1) NULL,
  peso_kg              DECIMAL(5,2) NULL,
  talla_cm             DECIMAL(5,1) NULL,
  diagnostico          TEXT NOT NULL,
  tratamiento          TEXT NULL,
  notas                TEXT NULL,
  creado_en            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_consultas_cita FOREIGN KEY (cita_id) REFERENCES citas(id)
) ENGINE=InnoDB;

CREATE TABLE recetas (
  id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  consulta_id             INT UNSIGNED NOT NULL UNIQUE,
  indicaciones_generales  TEXT NULL,
  creado_en               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_recetas_consulta FOREIGN KEY (consulta_id) REFERENCES consultas(id)
) ENGINE=InnoDB;

CREATE TABLE receta_detalle (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  receta_id    INT UNSIGNED NOT NULL,
  medicamento  VARCHAR(120) NOT NULL,
  dosis        VARCHAR(60)  NOT NULL,
  frecuencia   VARCHAR(60)  NOT NULL,
  duracion     VARCHAR(60)  NOT NULL,
  CONSTRAINT fk_detalle_receta FOREIGN KEY (receta_id) REFERENCES recetas(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Auditoría de expedientes (RF-17, opcional)
-- ---------------------------------------------------------------------
CREATE TABLE bitacora_expedientes (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id   INT UNSIGNED NOT NULL,
  paciente_id  INT UNSIGNED NOT NULL,
  accion       ENUM('consultar','crear','modificar') NOT NULL,
  detalle      VARCHAR(255) NULL,
  fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bitacora_usuario  FOREIGN KEY (usuario_id)  REFERENCES usuarios(id),
  CONSTRAINT fk_bitacora_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
  INDEX idx_bitacora_paciente_fecha (paciente_id, fecha)
) ENGINE=InnoDB;
