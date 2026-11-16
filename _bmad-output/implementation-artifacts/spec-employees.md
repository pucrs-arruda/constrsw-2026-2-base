---
title: 'Serviço employees'
type: 'feature'
created: '2026-11-16'
status: 'done'
baseline_commit: '4b0d8dd9aaa176691c4e5d19de4a5002bb039f50'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/specs/spec-employees/SPEC.md'
  - '{project-root}/_bmad-output/specs/spec-employees/routes.md'
  - '{project-root}/_bmad-output/specs/spec-employees/aggregate.md'
  - '{project-root}/_bmad-output/specs/spec-employees/stack.md'
  - '{project-root}/docs/data-model/services/Arruda - Employees.json'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** `backend/employees` não existe. O bloco `employees` do Compose ainda aponta para PostgreSQL e Java, embora já dependa do MongoDB. Sem este serviço, consumidores não leem um `id` estável nem o sinal `ativo`.

**Approach:** Um processo NestJS no Node 24 publica o CRUD de Employee e Dependent em `/api/v1`, persiste um documento por Employee no Mongo já previsto e ajusta só esse bloco do Compose.

## Boundaries & Constraints

**Always:**
- O contrato é `_bmad-output/specs/spec-employees/` mais as assumptions já aceitas. Lista é array JSON. POST 201 traz `Location`. PUT/PATCH de Employee não alteram `dependents`. DELETE lógico usa `enabled`, responde 204 e some das leituras seguintes (404). `status` `Active|Inactive` é outro eixo. GET de coleção e GET por id incluem `ativo` derivado; escrita não o aceita nem o devolve.
- Escrita só com `funcionario`. GET também para `coordenador`, `professor` e `student`. JWT Bearer via JWKS já configurado no Compose. 401 não enumera conta. 403 se o papel não pode escrever. Health anônimo: 200 `{status: ok}` ou 503 `{status: down}`.
- Erros 400, 401, 403, 404 e 409 são `application/problem+json` com `type`, `title`, `status`, `detail`, `code` e `instance`. 400 pode trazer `errors`. E-mail informado é único, inclusive em inativo e excluído; em branco não entra no índice. `registrationNumber` não é único. `null` e campo fora do schema respondem 400.
- Database `cras_employees` no serviço `mongodb` existente. Um documento por Employee, `dependents` embutido. Seed idempotente, sem CPF. `GET /metrics` anônimo. Logs estruturados em stdout.

**Ask First:** Nenhum. Se a implementação exigir arquivo fora de `backend/employees` e do bloco `employees` do Compose, pare.

**Never:** Outro MongoDB, os outros oito contextos, BFF, UX-S1, provisionar Keycloak, `GET /api/v1/identidade/me`, delete físico, undelete, filtro, `sort`, `page`, `size`, CORS de SPA, renumerar portas.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Criar Employee | POST sem `id`, com os seis obrigatórios e e-mail novo | 201, `Location`, corpo sem `ativo` e sem `dependents` | 409 se o e-mail já existe |
| Ler inativo | Employee `Inactive` e `enabled=true` | GET 200 com `ativo` false e dependents visíveis | Excluído (`enabled=false`) responde 404 |
| Substituir | PUT de Employee com dependents já gravados | 200; a coleção permanece | `ativo` ou `dependents` no corpo → 400 |
| Excluir pai | DELETE do Employee | 204; documento fica; dependents ficam `enabled=false` | Novo DELETE ou GET → 404 |
| Dependente órfão | POST em Employee ausente ou excluído | 404 | 400 se faltar `name`, `birthDate`, `dependencyType` ou `status` |
| Health | Mongo no ar ou fora | 200 `{status: ok}` ou 503 `{status: down}` | Sem `problem+json` |

</frozen-after-approval>

## Code Map

- `_bmad-output/specs/spec-employees/` -- contrato vigente; não reabrir.
- `docs/data-model/services/Arruda - Employees.json` -- propriedades e `required`. Defaults de exemplo não são persistidos.
- `docker-compose.yml` serviço `employees` -- hoje `DB_*` e `JAVA_TOOL_OPTIONS`; porta externa 8184, interna 8080. Manter OAuth, JWT, OTEL e portas.
- `backend/employees/` -- ainda não existe. Destino do Nest, OpenAPI, testes e Dockerfile.
- `backend/resources/openapi.yaml` schema `Problem` -- forma do erro, não o domínio.

## Tasks & Acceptance

**Execution:**
- [x] `backend/employees/package.json` -- NestJS 12.1.3, driver `mongodb` 7.7.0, Node `>=24.15` -- pin de `stack.md`.
- [x] `backend/employees/Dockerfile` -- imagem do serviço no Compose, health em `/api/v1/health`.
- [x] `backend/employees/src/` -- agregado, persistência, rotas de `routes.md`, JWKS, métricas e seed -- um documento Employee.
- [x] `backend/employees/openapi/openapi.yaml` -- OpenAPI 3.1 das treze rotas e do `Problem`.
- [x] `backend/employees/src/**/*.spec.ts` -- unidade do agregado e contrato do OpenAPI -- cobre a matriz de I/O.
- [x] `docker-compose.yml` -- só o serviço `employees`: tirar `DB_*` e `JAVA_TOOL_OPTIONS`; `MONGODB_URI` para `cras_employees`; healthcheck em `/api/v1/health`.

**Acceptance Criteria:**
- Given a coleção vazia, when GET `/api/v1/employees`, then 200 e `[]`.
- Given papel autenticado que não é `funcionario`, when POST, then 403 `problem+json`.
- Given DELETE já aplicado, when PUT, PATCH ou DELETE de novo, then 404 e o documento continua no Mongo.
- Given GET de Dependent excluído só naquele item, when GET do Employee, then o pai volta sem esse Dependent.

## Spec Change Log

## Design Notes

`enabled` fica no Mongo e fora do corpo de sucesso. `ativo` é calculado na leitura (`Active` → true, `Inactive` → false) e não é coluna. O índice único de e-mail ignora ausência e string em branco. A URI do Mongo usa as variáveis já existentes do Compose, com database `cras_employees`, sem copiar senha para o repositório.

## Verification

**Commands:**
- `npm test` em `backend/employees` -- expected: unidade do agregado e contrato do OpenAPI passam.
- `npm run build` em `backend/employees` -- expected: compilação sem erro.

## Suggested Review Order

**Rotas**

- O controller publica o CRUD em /api/v1 e devolve Location no 201.
  [`employees.controller.ts:19`](../../backend/employees/src/employees/employees.controller.ts#L19)

**Agregado**

- Data de calendário inválida vira 400 antes de gravar.
  [`employee.rules.ts:113`](../../backend/employees/src/employees/employee.rules.ts#L113)

- GET calcula ativo e omite dependent com enabled false.
  [`employee.rules.ts:342`](../../backend/employees/src/employees/employee.rules.ts#L342)

- DELETE lógico marca o pai e os filhos sem apagar o documento.
  [`employee.rules.ts:302`](../../backend/employees/src/employees/employee.rules.ts#L302)

**Persistência**

- Se o Mongo não conecta, o processo sobe e o health fica down.
  [`mongo-employees.repository.ts:13`](../../backend/employees/src/employees/mongo-employees.repository.ts#L13)

- Índice único de id torna o seed idempotente; o de e-mail ignora branco.
  [`mongo-employees.repository.ts:28`](../../backend/employees/src/employees/mongo-employees.repository.ts#L28)

**Erros**

- JSON inválido responde 400 problem+json em vez de 500.
  [`problem.ts:42`](../../backend/employees/src/problem.ts#L42)

- Chave duplicada de e-mail na corrida vira 409.
  [`employees.service.ts:163`](../../backend/employees/src/employees/employees.service.ts#L163)

**Contrato e processo**

- Pedido de escrita não exige id; a resposta de PUT inclui dependents.
  [`openapi.yaml:385`](../../backend/employees/openapi/openapi.yaml#L385)

- Logs do Nest saem como JSON em stdout.
  [`main.ts:6`](../../backend/employees/src/main.ts#L6)

- O Compose aponta o Mongo existente, database cras_employees, sem Postgres.
  [`docker-compose.yml:266`](../../docker-compose.yml#L266)

- O ignore da imagem deixa de fora o node_modules do host.
  [`.dockerignore:1`](../../backend/employees/.dockerignore#L1)

**Testes**

- O contrato cobre 400, 401, 403, 404, 409 e o OpenAPI.
  [`employees.contract.spec.ts:26`](../../backend/employees/src/employees/employees.contract.spec.ts#L26)

