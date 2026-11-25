---
title: 'BFF pass-through proxy for /api/v1/employees*'
type: 'feature'
created: '2026-11-25'
status: 'done'
baseline_commit: 'a7f5ede631d7c47d462ddfe07e085cba47b357a3'
review_loop_iteration: 0
context:
  - '{project-root}/docs/open-api/arruda-employees-api.yaml'
  - '{project-root}/docs/open-api/bff.yaml'
  - '{project-root}/backend/bff/src/modules/rooms/'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** UX-EMPLOYEES calls the BFF at `/api/v1/employees*`, but `AppModule` has no Employees module, so Nest returns 404. The list page masks that 404 as an empty catalog; create/edit fails with the refusal banner. The domain service and OpenAPI already work; only the BFF surface is missing.

**Approach:** Add a pass-through Nest module under `backend/bff/src/modules/employees/` mirroring the rooms/reservations proxy pattern (no T3 composition), register it in `AppModule`, align `EMPLOYEES_BASE_URL` with other domains, and drop the frontend e2e bridge that bypasses the BFF.

## Boundaries & Constraints

**Always:**
- Browser path = domain path: `/api/v1/employees` (+ `/{id}`, `/{id}/dependents`, `/{id}/dependents/{dependentId}`) — matches `docs/open-api/bff.yaml` and frontend `bffBaseUrl: '/api'` + `/v1/employees`
- Pure proxy: forward method, query, JSON body, Bearer (`bearerTokenOf`), status, Content-Type, Location, and problem+json untouched; no FR/auth pre-validation in the BFF
- Resilience: `DownstreamService` + circuit breaker; domain down → 503 `application/problem+json` with `code: BFF-DOWNSTREAM-UNAVAILABLE` (same shape as rooms)
- `@All` per route template so unsupported verbs come from the domain (405/404), not a BFF allow-list
- `EMPLOYEES_BASE_URL` = origin only (host:port, no `/api/v1`); service concatenates `DOMAIN_PREFIX = '/api/v1/employees'`
- Alphabetical `EmployeesModule` import in `AppModule`
- Contract tests at the BFF↔employees boundary (rooms-style double)

**Ask First:**
- Changing `BFF_EMPLOYEES_BASE_URL` in root `.env` (today includes trailing `/api/v1`) — required for path consistency with rooms/students; confirm if another consumer depends on the suffix
- Adding a live e2e against the compose stack beyond contract tests

**Never:**
- T3 composition / joining classes or professors inside this module
- Validating EmployeeWrite, email uniqueness, or roles in the BFF
- Calling employees from the browser/e2e bypass once the proxy ships (remove `bff-employees-bridge`)
- Global Nest prefix hacks; JWT verification middleware exclusive to reservations
- Touching the employees domain service or frontend UX surfaces except the e2e bridge removal

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| List empty | GET `/api/v1/employees` + Bearer | 200 + domain body (e.g. `[]`); downstream path `/api/v1/employees` | N/A |
| Create | POST collection + EmployeeWrite JSON + Bearer | Domain status (201) + body; `Location` forwarded if present | Domain 400/409 problem+json intact |
| Nested dependent | Any verb on `…/employees/{id}/dependents/{dependentId}` | Forwarded path with encoded segments + query | Domain errors intact |
| Auth missing | No Bearer/cookie | Domain 401 (or whatever employees returns); BFF still forwards when token absent | Do not invent BFF-local 401 like reservations |
| Downstream down | Circuit/timeout/`DownstreamUnavailableError` | 503 problem+json `BFF-DOWNSTREAM-UNAVAILABLE` | No partial body |
| Double prefix | Misconfigured base URL ending in `/api/v1` | Must not call `…/api/v1/api/v1/employees` | Prevent via env align + tests asserting path |

</frozen-after-approval>

## Code Map

- `backend/bff/src/app.module.ts` -- register `EmployeesModule` alphabetically
- `backend/bff/src/modules/rooms/` -- copy pattern (module/service/controller/contract.spec)
- `backend/bff/src/common/http/downstream.service.ts` -- send + header whitelist (Location)
- `backend/bff/src/common/auth/bearer-token.ts` -- Bearer/cookie extraction
- `docs/open-api/bff.yaml` -- employees paths already `$ref` domain OpenAPI (no BFF OpenAPI rewrite required unless submodule local openapi needs update)
- `.env` -- `BFF_EMPLOYEES_BASE_URL` currently appends `/api/v1` (must align)
- `docker-compose.yml` -- already maps `EMPLOYEES_BASE_URL=${BFF_EMPLOYEES_BASE_URL}` and depends_on employees
- `frontend/e2e/helpers/bff-employees-bridge.ts` + `frontend/e2e/helpers/ui.ts` -- remove bridge after proxy exists
- `frontend/src/app/surfaces/ux-employees/employees-api.ts` -- already targets BFF `/v1/employees` (no API change)

## Tasks & Acceptance

**Execution:**
- [x] `.env` -- strip trailing `/api/v1` from `BFF_EMPLOYEES_BASE_URL` so it matches rooms/students origin style -- avoid double prefix
- [x] `backend/bff/src/modules/employees/employees.module.ts` -- DownstreamService factory on `EMPLOYEES_BASE_URL` + breaker env -- wire resilience
- [x] `backend/bff/src/modules/employees/employees.service.ts` -- `forward` with `DOMAIN_PREFIX='/api/v1/employees'` + 503 UNAVAILABLE_BODY -- pass-through
- [x] `backend/bff/src/modules/employees/employees.controller.ts` -- `@Controller('api/v1/employees')` with four `@All` routes (collection, `:id`, `:id/dependents`, `:id/dependents/:dependentId`); propagate headers/Location/204 -- public surface
- [x] `backend/bff/src/app.module.ts` -- import `EmployeesModule` alphabetically -- activate routes
- [x] `backend/bff/src/modules/employees/employees.contract.spec.ts` -- assert path mapping, nested routes, Bearer, Location on 201, 204 empty, domain error pass-through, 503 mapping -- cover I/O matrix
- [x] `backend/bff/README.md` -- document employees proxy + `EMPLOYEES_BASE_URL` (origin only) -- ops clarity
- [x] `frontend/e2e/helpers/bff-employees-bridge.ts` + `ui.ts` -- remove bridge install -- traffic hits real BFF
- [x] Rebuild/restart `api` container and smoke POST/GET via BFF with lab token -- prove UI path unblocked

**Acceptance Criteria:**
- Given BFF is up with employees healthy, when GET `/api/v1/employees` with a valid user token, then response is the domain list (not Nest `Cannot GET`)
- Given the same stack, when POST `/api/v1/employees` with valid `EmployeeWrite`, then 201 from domain is returned through BFF with `Location` when the domain sends it
- Given employees is unreachable, when any proxied call runs, then 503 problem+json with `BFF-DOWNSTREAM-UNAVAILABLE`
- Given frontend e2e helpers, when tests run, then they no longer route-intercept employees away from the BFF
- Given Closed CRAS UI, when saving the first employee, then create succeeds (or shows a real domain refusal), not a BFF 404 masked as empty list

## Spec Change Log

## Design Notes

Mirror **rooms** proxy mechanics, but publish under **`api/v1/employees`** (like students/reservations) because the SPA uses `bffBaseUrl: '/api'` + `/v1/employees`.

Golden path shape (controller → service):

```ts
@Controller('api/v1/employees')
// @All(), @All(':id'), @All(':id/dependents'), @All(':id/dependents/:dependentId')
// forward suffix built with encodeURIComponent; query from originalUrl
// DOMAIN_PREFIX + suffix → DownstreamService.send
```

Do **not** copy reservations' KeycloakJwtVerifier gate — employees domain already authenticates.

## Verification

**Commands:**
- `cd backend/bff && npm test -- --runInBand employees.contract.spec.ts` -- expected: all green
- `docker compose up -d --build api` (from repo root) -- expected: healthy `api`
- `curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" http://localhost:8180/api/v1/employees` -- expected: `200` (not `404`)

**Manual checks:**
- UI: Funcionários → Novo → save Donald Knuth-like payload → lands on detail or list with the new row; Network tab shows POST `/api/v1/employees` → 201 via BFF

## Suggested Review Order

**Public surface**

- Entry: `@Controller('api/v1/employees')` mirrors SPA `/api` + `/v1/employees`
  [`employees.controller.ts:17`](../../backend/bff/src/modules/employees/employees.controller.ts#L17)

- Four `@All` templates — domain owns verbs; dependents nested before generic `:id` collision risk handled by Nest specificity
  [`employees.controller.ts:21`](../../backend/bff/src/modules/employees/employees.controller.ts#L21)

**Pass-through + resilience**

- `DOMAIN_PREFIX` + `forward` maps to employees without reinterpretation
  [`employees.service.ts:17`](../../backend/bff/src/modules/employees/employees.service.ts#L17)

- Stale `…/api/v1` base URLs stripped so path never doubles
  [`employees.module.ts:47`](../../backend/bff/src/modules/employees/employees.module.ts#L47)

- Alphabetical registration activates the module
  [`app.module.ts:24`](../../backend/bff/src/app.module.ts#L24)

**Lab wiring**

- Compose env origin-only (no trailing `/api/v1`)
  [`.env:260`](../../.env#L260)

- E2E no longer bypasses BFF; global-setup asserts BFF health
  [`global-setup.ts:28`](../../frontend/e2e/global-setup.ts#L28)

**Verification**

- Contract suite covers path, Bearer, Location, 409, 204, 503
  [`employees.contract.spec.ts:12`](../../backend/bff/src/modules/employees/employees.contract.spec.ts#L12)
