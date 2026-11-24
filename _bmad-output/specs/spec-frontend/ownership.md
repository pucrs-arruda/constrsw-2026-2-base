# Ownership — Frontend (OQ-1 fechada)

**Decisão 2026-11-24:** reverte frontend cruzado. Prof. Arruda entrega shell + employees; cada grupo entrega a UX do **próprio** serviço.

**Travado no Correct Course (2026-11-24):** a matriz abaixo é a partição oficial para épicos/stories e quick-dev — CE não pode alterar donos/superfícies.

## Mapa

| Superfície | Dono | Contexto / serviço |
|---|---|---|
| UX-LOGIN | Prof. Arruda | shell |
| UX-HOME | Prof. Arruda | shell |
| UX-EMPLOYEES | Prof. Arruda | `employees` |
| UX-CLASSES | Grupo 01 | `classes` |
| UX-CLASS-ENROLLMENTS | Grupo 01 | `classes` |
| UX-CLASS-LESSONS | Grupo 02 | `lessons` |
| UX-LESSON-RESERVATIONS | Grupo 03 | `reservations` |
| UX-OCCUPANCY | Grupo 03 | `reservations` (FR-29) |
| UX-STUDENTS | Grupo 04 | `students` |
| UX-STUDENT-READ | Grupo 04 | `students` (FR-19) |
| UX-COURSES | Grupo 05 | `courses` |
| UX-RESOURCES | Grupo 06 | `resources` |
| UX-PROFESSORS | Grupo 07 | `professors` |
| UX-PROFESSOR-VIEW | Grupo 07 | `professors` (FR-31) |
| UX-ROOMS | Grupo 08 | `rooms` |

## Regras

- Um dono por superfície. Grupo **não** implementa UX de outro serviço.
- Shell (LOGIN/HOME) e UX-EMPLOYEES não são rateados entre os nove grupos.
- Sucesso de grupo (SM-4 / FR-28) = par 1–N + BFF do domínio + gateway + **UX do próprio serviço**.
- Coordenação de pastas no repo Angular: `contribution.md`.
- Rastreio: `traceability.md` (`FE-CAP-N` + bloco Refs).
