# Clínica NovaSalud — Base de datos

Base de datos MySQL de **MediAgenda**, el sistema de citas y expedientes clínicos de la Clínica NovaSalud.
Proyecto final del curso Desarrollo Web, Universidad Mariano Gálvez de Guatemala.

## Contenido

| Archivo | Descripción |
| --- | --- |
| `01_schema.sql` | Crea la base `clinica_nova_salud` y sus 12 tablas |
| `02_seed.sql` | Carga datos de prueba ficticios (usuarios, médicos, horarios y pacientes) |
| `03_password_reset.sql` | Agrega almacenamiento seguro para tokens de restablecimiento en bases existentes |
| `diagrama-er.png` | Diagrama entidad-relación |
| `diagrama-er.md` | El mismo diagrama en Mermaid, visible directamente en GitHub |

## Cómo crear la base de datos

1. Abre MySQL Workbench y conéctate a tu servidor local.
2. Ejecuta `01_schema.sql` y después `02_seed.sql`.

Si la base ya existía antes de agregar la recuperación de contraseña, ejecuta también `03_password_reset.sql`.

> `01_schema.sql` borra las tablas existentes. Úsalo solo en desarrollo.

## Usuarios de prueba

Todos usan la contraseña `NovaSalud2026!`.

| Rol | Correo |
| --- | --- |
| Administrador | admin@novasalud.com |
| Recepcionista | recepcion1@novasalud.com |
| Médico | cmendez@novasalud.com |

## Repositorios relacionados

- Frontend: [Clinica-Nova-Salud](https://github.com/Iantino/Clinica-Nova-Salud)
- Backend: [Clinica-Nova-Salud-Back](https://github.com/Iantino/Clinica-Nova-Salud-Back)
