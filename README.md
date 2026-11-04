# ConstrSW 2026/2 — Closed CRAS

Monorepo da disciplina de Construção de Software. Cada contexto de domínio é um
submódulo em `backend/`, e o ambiente local sobe por Docker Compose.

## Subir o ambiente

Pré-requisitos: Docker + Docker Compose v2. Os volumes externos do Keycloak e do
Prometheus precisam existir uma vez:

```bash
docker volume create constrsw-keycloak-data
docker volume create constrsw-prometheus-data

docker compose up --build
```

| Serviço | URL local |
|---|---|
| Keycloak | http://localhost:8081 |
| OAuth (login) | http://localhost:8181 |
| Resources API — Swagger (OpenAPI 3.1) | **http://localhost:8106/docs** |
| Resources API — OpenAPI 3.1 JSON | http://localhost:8106/docs/json |
| Resources API — readiness | http://localhost:8106/health/ready |
| Resources API — métricas | http://localhost:8106/metrics |

Usuários de teste (senha `a12345678`): `admin@pucrs.br`,
`coordinator@pucrs.br`, `professor@pucrs.br`, `student@pucrs.br`.

## Módulo Resources

Documentação completa e única do módulo (arquitetura, execução, Swagger,
diagramas, rotas, filtros, observabilidade, testes e divergências):
**[`backend/resources/README.md`](backend/resources/README.md)**.

Resumo da entrega:

- CRUD completo de `Resource` (`/resources`).
- Coleção secundária 1–N `Occurrence`
  (`/resources/{id}/occurrences`), com PUT/PATCH/DELETE.
- Query string simples (`?type=PROJECTOR&active=true`) e complexa
  (`?status=%7Bneq%7DRESOLVED&createdAt=%7Bgteq%7D2026-11-01T00:00:00Z`).
- Autenticação JWT do Keycloak (JWKS, `iss`, `aud`, papéis de leitura/escrita).
- Erros RFC 9457 `application/problem+json`.
- PostgreSQL com schema versionado e seed idempotente.
- Contrato **OpenAPI 3.1.0** versionado em `backend/resources/openapi/openapi.yaml`
  e servido em `/docs`, `/docs/json` e `/docs/yaml`.
- `415 Unsupported Media Type` para corpo não-JSON.
- Probes `/health`, `/health/live`, `/health/ready` e métricas Prometheus em
  `/metrics`.
- Testes unitários (`npm test`) e de integração com PostgreSQL real
  (`npm run test:e2e`).
