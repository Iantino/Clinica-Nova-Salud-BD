-- =====================================================================
-- MediAgenda - Clínica NovaSalud
-- Datos iniciales para desarrollo (ficticios)
-- Contraseña de todos los usuarios de prueba: NovaSalud2026!
-- Cámbiala antes de usar el sistema en producción.
-- =====================================================================

USE clinica_nova_salud;

INSERT INTO roles (id, nombre) VALUES
  (1, 'administrador'),
  (2, 'recepcionista'),
  (3, 'medico'),
  (4, 'paciente');

INSERT INTO especialidades (id, nombre, descripcion) VALUES
  (1, 'Medicina general', 'Consulta general para todas las edades'),
  (2, 'Pediatría',        'Atención de niños y adolescentes'),
  (3, 'Dermatología',     'Enfermedades de la piel, cabello y uñas');

INSERT INTO usuarios (id, rol_id, nombre, apellido, correo, password_hash) VALUES
  (1, 1, 'Admin',  'NovaSalud', 'admin@novasalud.com',      '$2b$10$dPPDmTcbJtVsc.jgJXDlMulaH1lKxGKWgu45e9yW0nySmhyoZPBmq'),
  (2, 2, 'Lucía',  'Pérez',     'recepcion1@novasalud.com', '$2b$10$dPPDmTcbJtVsc.jgJXDlMulaH1lKxGKWgu45e9yW0nySmhyoZPBmq'),
  (3, 2, 'Andrés', 'López',     'recepcion2@novasalud.com', '$2b$10$dPPDmTcbJtVsc.jgJXDlMulaH1lKxGKWgu45e9yW0nySmhyoZPBmq'),
  (4, 3, 'Carlos', 'Méndez',    'cmendez@novasalud.com',    '$2b$10$dPPDmTcbJtVsc.jgJXDlMulaH1lKxGKWgu45e9yW0nySmhyoZPBmq'),
  (5, 3, 'Ana',    'García',    'agarcia@novasalud.com',    '$2b$10$dPPDmTcbJtVsc.jgJXDlMulaH1lKxGKWgu45e9yW0nySmhyoZPBmq'),
  (6, 3, 'Sofía',  'Ramírez',   'sramirez@novasalud.com',   '$2b$10$dPPDmTcbJtVsc.jgJXDlMulaH1lKxGKWgu45e9yW0nySmhyoZPBmq'),
  (7, 3, 'Jorge',  'Castillo',  'jcastillo@novasalud.com',  '$2b$10$dPPDmTcbJtVsc.jgJXDlMulaH1lKxGKWgu45e9yW0nySmhyoZPBmq');

-- 2 médicos de medicina general, 1 de pediatría y 1 de dermatología
INSERT INTO medicos (id, usuario_id, especialidad_id, colegiado, telefono) VALUES
  (1, 4, 1, 'COL-10234', '55551001'),
  (2, 5, 1, 'COL-10567', '55551002'),
  (3, 6, 2, 'COL-11890', '55551003'),
  (4, 7, 3, 'COL-12456', '55551004');

-- Todos atienden de lunes (1) a viernes (5), de 8:00 a 13:00
INSERT INTO horarios_medico (medico_id, dia_semana, hora_inicio, hora_fin)
SELECT m.id, d.dia, '08:00:00', '13:00:00'
FROM medicos m
CROSS JOIN (SELECT 1 AS dia UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d;

INSERT INTO pacientes (id, dpi, nombre, apellido, fecha_nacimiento, sexo, telefono, correo, direccion, nombre_encargado, alergias) VALUES
  (1, '2456789010101', 'María',  'Gómez',   '1985-04-12', 'F', '44441001', 'maria.gomez@correo.com', 'Zona 1, Mazatenango', NULL, 'Penicilina'),
  (2, '3012456780901', 'José',   'Hernández','1972-11-03', 'M', '44441002', NULL,                     'Zona 2, Mazatenango', NULL, NULL),
  (3, NULL,            'Mateo',  'Gómez',   '2019-08-20', 'M', '44441001', NULL,                     'Zona 1, Mazatenango', 'María Gómez', NULL);
