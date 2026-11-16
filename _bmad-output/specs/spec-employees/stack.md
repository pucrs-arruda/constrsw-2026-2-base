# Stack — employees

Prescrição de implementação. O que o serviço faz está em `SPEC.md`.

| Peça | Pin |
| --- | --- |
| Node.js | 24.x (>=24.15), LTS |
| NestJS (`@nestjs/core`) | 12.1.3 |
| Driver `mongodb` | 7.7.0 |
| MongoDB | Instância já definida no `docker-compose.yml` (imagem da spine: `mongo:8.3.13`). Não criar outro serviço de banco. |
| Database | `cras_employees` |
| Documento | Um documento por Employee; `dependents` é array embutido |
| Contrato | OpenAPI 3.1 em `backend/employees/openapi/openapi.yaml` |
| Métricas | `GET /metrics` scrapável |
| Logs | Estruturados em stdout |

No `docker-compose.yml`, alterar só o serviço `employees`:

- Remover `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` e `JAVA_TOOL_OPTIONS`.
- Publicar `MONGODB_URI` apontando ao serviço `mongodb` já existente, no database `cras_employees`.
- Manter porta publicada, OAuth/JWT e OTEL como estão.
- Healthcheck em `/api/v1/health`.

Não renumerar portas e não alterar os outros serviços.
