# Contribuição por grupo — BFF

A BFF é compartilhada: **sem dono exclusivo**. Cada grupo entrega o módulo do próprio contexto.

## Checklist do módulo

1. Criar `backend/bff/src/modules/<contexto>/` (controller + service + module + testes).
2. Registrar o módulo em `src/app.module.ts` em **ordem alfabética**.
3. Publicar paths sob `/api/v1/...` conforme `routes.md` e `docs/open-api/bff.yaml`.
4. Usar `DownstreamService` + `CircuitBreaker` de `common/http/` (AD-10). Circuitos **independentes** por base URL/dependência.
5. Extrair token com o helper compartilhado (`bearerTokenOf` / cookie `SESSION_COOKIE_NAME`); não inventar login.
6. Se a rota for **T3**, implementar merge conforme `composition.md` (reutilizar `common/academic/current-semester.ts` quando for `classes`).
7. Se a rota for **proxy**, repassar status/corpo/headers relevantes sem reinterpretar FR.
8. Testes: unit/HTTP do módulo; contrato alinhado ao OpenAPI; E2E do domínio via BFF quando a stack Compose do domínio estiver no ar.
9. Documentar variáveis `*_BASE_URL` no README do submódulo se novas.
10. Mudanças em `common/` exigem regressão dos módulos já integrados (rooms, students, courses, reservations, …).

## Mapa grupo → pasta

| Contexto | Pasta | Estado alvo |
| --- | --- | --- |
| classes | `src/modules/classes/` | proxy |
| lessons | `src/modules/lessons/` | proxy |
| reservations | `src/modules/reservations/` | proxy (+ ocupacao) |
| students | `src/modules/students/` | T3 `classes` |
| courses | `src/modules/courses/` | T3 `classes` |
| resources | `src/modules/resources/` | T3 `reservations` |
| professors | `src/modules/professors/` | T3 `classes` + `employeeName`/`employeeEmail` |
| rooms | `src/modules/rooms/` | T3 `classes` sob `/api/v1` (Grupo 08 corrige legado `/v1`) |
| employees | `src/modules/employees/` | proxy |

Estado real do código: `brownfield.md`.

## O que não fazer

- Criar `src/modules/ocupacao/` para FR-29 (usar proxy de reservations).
- Alterar portas Compose de outros serviços.
- Commitar só o ponteiro da base sem o commit no submódulo `backend/bff` (e vice-versa).
- Validar regra FR no proxy “para ajudar” o domínio.
- Publicar `/v1/...` no lugar de `/api/v1/...` (decisão desta SPEC).

## Como apontar no bmad-quick-dev / build

Contexto mínimo para o agente de implementação:

```text
_bmad-output/specs/spec-bff/SPEC.md
_bmad-output/specs/spec-bff/routes.md
_bmad-output/specs/spec-bff/composition.md
_bmad-output/specs/spec-bff/contribution.md
_bmad-output/specs/spec-bff/stack.md
_bmad-output/specs/spec-bff/brownfield.md
docs/open-api/bff.yaml
docs/open-api/<openapi-do-contexto>.yaml
```

Escopo típico de um grupo: **somente** `src/modules/<contexto>/` + linha em `app.module.ts` + testes do módulo. Parar se a tarefa exigir alterar outro módulo de domínio alheio sem coordenação.
