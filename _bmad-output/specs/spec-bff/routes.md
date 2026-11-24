# Rotas — BFF

Base: `http://localhost:8180` (`BFF_EXTERNAL_API_PORT`). Prefixo de domínio: `/api/v1`.

Autenticação: rotas de negócio exigem identidade (Bearer ou cookie de sessão OAuth). `GET /health` é anônimo. Detalhe do transporte: CAP-4 / `stack.md`.

Tipos:

| Tipo | Significado |
| --- | --- |
| **proxy** | Pass-through do OpenAPI do contexto. Status/corpo/erros = domínio. |
| **T3** | GET de coleção ou item com composição de leitura (`composition.md`). |
| **bff** | Operação do próprio processo BFF. |

Recusas e 503 de composição: ver `composition.md` e o companion adotado `bff.yaml`.

## Saúde

| Rota | Método | Tipo | Sucesso | Notas |
| --- | --- | --- | --- | --- |
| `/health` | GET | bff | 200 `{status: UP}` | Não consulta contextos |

## Students (Grupo 04) — OpenAPI `grupo04-students-api.yaml`

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/students` | GET | T3 (`classes`) |
| `/api/v1/students` | POST | proxy |
| `/api/v1/students/{id}` | GET | T3 (`classes`) |
| `/api/v1/students/{id}` | PUT, PATCH, DELETE | proxy |
| `/api/v1/students/{id}/enrollments` | * | proxy |
| `/api/v1/students/{id}/enrollments/{enrollmentId}` | * | proxy |

## Courses (Grupo 05) — OpenAPI `grupo05-courses-api.yaml`

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/courses` | GET | T3 (`classes`) |
| `/api/v1/courses` | POST | proxy |
| `/api/v1/courses/{courseId}` | GET | T3 (`classes`) |
| `/api/v1/courses/{courseId}` | PUT, PATCH, DELETE | proxy |
| `/api/v1/courses/{courseId}/bibliographic-references` | * | proxy |
| `/api/v1/courses/{courseId}/bibliographic-references/{referenceId}` | * | proxy |
| `/api/v1/courses/{courseId}/syllabus-items` | * | proxy |
| `/api/v1/courses/{courseId}/syllabus-items/{syllabusItemId}` | * | proxy |
| `/api/v1/courses/syllabus-items/{syllabusItemId}` | * | proxy |

## Resources (Grupo 06) — OpenAPI do contexto resources

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/resources` | GET | T3 (`reservations`) |
| `/api/v1/resources` | POST | proxy |
| `/api/v1/resources/{resourceId}` | GET | T3 (`reservations`) |
| `/api/v1/resources/{resourceId}` | PUT, PATCH, DELETE | proxy |
| `/api/v1/resources/{resourceId}/occurrences` | * | proxy |
| `/api/v1/resources/{resourceId}/occurrences/{occurrenceId}` | * | proxy |

## Professors (Grupo 07) — OpenAPI `grupo07-professors-api.yaml`

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/professors` | GET | T3 (`classes`) |
| `/api/v1/professors` | POST | proxy |
| `/api/v1/professors/{id}` | GET | T3 (`classes`) |
| `/api/v1/professors/{id}` | PUT, PATCH, DELETE | proxy |
| `/api/v1/professors/{id}/academic-degrees` | * | proxy |
| `/api/v1/professors/{id}/academic-degrees/{academicDegreeId}` | * | proxy |

## Rooms (Grupo 08) — OpenAPI `grupo08-rooms-api.yaml`

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/rooms` | GET | T3 (`classes`) |
| `/api/v1/rooms` | POST | proxy |
| `/api/v1/rooms/{id}` | GET | T3 (`classes`) |
| `/api/v1/rooms/{id}` | PUT, PATCH, DELETE | proxy |
| `/api/v1/rooms/{id}/accessibility-features` | * | proxy |
| `/api/v1/rooms/{id}/accessibility-features/{featureId}` | * | proxy |

## Classes (Grupo 01) — OpenAPI `grupo01-classes-api.yaml`

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/classes` | * | proxy |
| `/api/v1/classes/import` | * | proxy |
| `/api/v1/classes/{classId}` | * | proxy |
| `/api/v1/classes/{classId}/reviews` | * | proxy |
| `/api/v1/classes/{classId}/reviews/{reviewId}` | * | proxy |

## Lessons (Grupo 02) — OpenAPI `grupo02-lessons-api.yaml`

Paths do domínio podem omitir o prefixo no OpenAPI do writer; o BFF publica com `/api/v1`.

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/lessons` | * | proxy |
| `/api/v1/lessons/generate` | * | proxy |
| `/api/v1/lessons/{lessonId}` | * | proxy |
| `/api/v1/lessons/{lessonId}/topics` | * | proxy |
| `/api/v1/lessons/{lessonId}/topics/{topicId}` | * | proxy |

## Reservations (Grupo 03) — OpenAPI `grupo03-reservations-api.yaml`

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/reservations` | * | proxy |
| `/api/v1/reservations/ocupacao` | GET | proxy (FR-29) |
| `/api/v1/reservations/{id}` | * | proxy |
| `/api/v1/reservations/{id}/details` | * | proxy |
| `/api/v1/reservations/{id}/details/{detailId}` | * | proxy |
| `/api/v1/identidade/me` | GET | proxy |

## Employees — OpenAPI `arruda-employees-api.yaml`

| Rota | Métodos | Tipo |
| --- | --- | --- |
| `/api/v1/employees` | * | proxy |
| `/api/v1/employees/{id}` | * | proxy |
| `/api/v1/employees/{id}/dependents` | * | proxy |
| `/api/v1/employees/{id}/dependents/{dependentId}` | * | proxy |

## Fora desta API

- `GET /health` e `GET /metrics` de cada contexto.
- Endpoints de login/refresh/logout (`oauth`).
- Composição FR-19 / FR-31 no servidor (cliente).
