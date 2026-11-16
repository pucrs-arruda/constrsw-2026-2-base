---
id: SPEC-employees
companions:
  - routes.md
  - aggregate.md
  - divergences.md
  - stack.md
  - ../../../docs/data-model/services/Arruda - Employees.json
sources:
  - ../../../docs/open-api/grupo08-rooms-api.yaml
  - ../../../docs/open-api/grupo07-professors-api.yaml
  - ../../../docs/open-api/grupo04-students-api.yaml
  - ../../../backend/resources/openapi.yaml
  - ../../planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
  - ../../planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/prd.md
  - ../spec-closed-cras/SPEC.md
  - ../spec-closed-cras/domain-pairs.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability only — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Employees

## Why

**Mandato.** `employees` é o cadastro-mestre de quem trabalha na IES. `professors`, `classes` e `reservations` consomem um `id` estável e o sinal `ativo`. O JSON Schema desta entrega modela `Employee` com composição `Dependent`, e os outros serviços já publicam CRUD completo em `/api/v1`. Sem este contrato, a implementação segue a grade `/v1` da spine.

## Capabilities

- **CAP-1**
  - **intent:** O funcionário cria, lista, lê, substitui, atualiza parcialmente e exclui logicamente Employee no formato do JSON Schema.
  - **success:** As seis rotas de Employee em `routes.md` cumprem os status ali descritos; o `id` é UUID v4 imutável; e-mail informado é único entre todos os registros; `phone` e `email` podem faltar; o documento excluído permanece no store e deixa de ser lido.

- **CAP-2**
  - **intent:** O funcionário cria, lista, lê, substitui, atualiza parcialmente e exclui logicamente Dependent de um Employee ainda endereçável, sem órfãos.
  - **success:** As seis rotas aninhadas em `routes.md`; PUT e PATCH de Employee não alteram `dependents`; DELETE de Employee marca os dependents; Dependent sob Employee inexistente ou já excluído responde 404.

- **CAP-3**
  - **intent:** Quem lê um Employee ou Dependent endereçável distingue `Active` de `Inactive` pelo campo `ativo`.
  - **success:** GET de coleção e GET por id incluem `ativo` boolean (`Active` true, `Inactive` false). `Inactive` continua no GET. Exclusão lógica não é `Inactive` e responde 404. POST, PUT e PATCH não levam `ativo` no pedido nem na resposta; enviá-lo responde 400.

- **CAP-4**
  - **intent:** O operador verifica, sem token, se o serviço alcança o store.
  - **success:** `GET /api/v1/health` sem `Authorization` responde 200 `{status: ok}` quando o Mongo responde e 503 `{status: down}` quando não.

## Constraints

- Grade e prefixo desta entrega: `/api/v1`. Lista é array JSON, sem filtro, `sort`, `page` nem `size`. Não usar `/v1` nem envelope `items`. Detalhe em `routes.md`.
- Recusas 400, 401, 403, 404 e 409 usam `application/problem+json` (RFC 9457), com `type`, `title`, `status`, `detail`, `code` e `instance`. O `status` do corpo repete o HTTP de `routes.md`; 400 não vira 422. Health fica fora desse envelope.
- `status` (`Active` | `Inactive`) e a exclusão lógica (`enabled`) são eixos distintos. Sem undelete e sem delete físico. Ver `aggregate.md`.
- Escrita (POST, PUT, PATCH, DELETE) só com o papel `funcionario`. Cadastro exige JWT Bearer: token ausente ou inválido responde 401 sem enumerar conta; papel sem escrita responde 403. Health é anônimo. Sem CORS de SPA.
- Store: MongoDB já previsto no Compose, database `cras_employees`. Não PostgreSQL e não um segundo banco. Runtime e o ajuste do bloco `employees`: `stack.md`.
- Este serviço não chama os outros contextos, não é dono de Professor, Room nem Resource, e não aplica FR-1a.
- Criar Employee não provisiona usuário no Keycloak. Seed idempotente, sem CPF. Métricas scrapáveis e logs estruturados em stdout.
- Este serviço entrega teste de unidade do agregado e teste de contrato alinhado ao próprio OpenAPI. E2E de jornada na UI fica fora.

## Non-goals

- `GET /api/v1/identidade/me`.
- Reverter exclusão lógica.
- BFF, tela UX-S1, administração do Keycloak e implementação dos outros oito contextos.
- Folha, ponto e cópia de cadastro pessoal em `professors`.
- Fazer `classes` ficar somente leitura ou recusar Reservation dentro deste serviço.

## Success signal

No Compose, os doze endpoints de `routes.md` e o health respondem como o contrato; um GET de Employee `Inactive` traz `ativo` false; uma recusa de cadastro é `application/problem+json` com o HTTP já fechado; depois do DELETE o mesmo `id` responde 404 e o documento continua no Mongo; PUT de Employee preserva os dependents; não existe `GET /api/v1/identidade/me`.

## Assumptions

- GET de cadastro é permitido a `funcionario`, `coordenador`, `professor` e `student`.
- E-mail omitido ou em branco é ausência e fica fora do índice único.
- Cada elemento de `GET /api/v1/employees` é um Employee com os dependents ainda visíveis.
- `registrationNumber` não é único.
- Corpo de health usa os literais `ok` e `down`.
- POST 201 inclui o header `Location` com a URL do recurso criado.
