---
title: '0.6 Lista de Funcionários responsiva'
type: 'feature'
created: '2026-11-24'
status: 'done'
baseline_commit: '0c74a1bb7147d2c0cbd681db1a490fceb80a4d13'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-5-kit-compartilhado-tabela-lista-dialogs-banners-http-bff.md'
  - '{project-root}/docs/open-api/arruda-employees-api.yaml'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Menu “Funcionários” still opens a placeholder — operators cannot browse Employees from the BFF despite shell + shared kit being ready.

**Approach:** Replace `/funcionarios` with UX-EMPLOYEES list surface: `GET /api/v1/employees` via `BffClient`, page-header + toolbar (client-side search), `ResponsiveDataTable` / empty / skeleton / composition banner, using kit primitives under `frontend/src/app/surfaces/ux-employees/`.

## Boundaries & Constraints

**Always:**
- Data only via BFF `GET /api/v1/employees` (no domain OpenAPI); Bearer via existing interceptor
- Reuse shared kit: `ResponsiveDataTable`, `EmptyState`, `SkeletonBlock`, `AlertBanner`, `BffClient` / `mapBffHttpError`
- EXPERIENCE list chrome: page-header (título Funcionários) + toolbar (busca + CTA Nova); compact stacks CTA; no FAB; no table h-scroll; ACs 360 / 768 / 1280
- OpenAPI has no server filter — search filters the loaded list client-side
- Empty pt-BR + CTA when create allowed; cold load → skeleton; composition/outage 503 → “Serviço de composição indisponível.” (no local join)
- CTA “Nova” visible only for role `funcionario` (from existing `identidade/me` / session identity if available); clicking may navigate/open stub — **no create dialog/API in this story**
- Abrir navigates to `/funcionarios/:id` stub route (detail UI = Story 0.7); hide/disable Editar/Excluir or no-op until 0.8 (no physical delete in v1)
- Code under `frontend/src/app/surfaces/ux-employees/`; pt-BR; Material + DESIGN tokens

**Ask First:**
- Inventing server-side query params not in OpenAPI
- Showing create dialog / POST employee in this story
- Changing Employee field labels vs OpenAPI glossary

**Never:**
- Dependent CRUD, Employee create/edit forms, problem+json write handling (0.7–0.9)
- Keycloak provisioning; calling nine domain services; FAB; `.mdc-*`

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| List success | `GET employees` → array | Table/list via kit; page-header + toolbar | N/A |
| Empty | `[]` | EmptyState pt-BR; CTA Nova if `funcionario` | N/A |
| Cold load | Request in flight | SkeletonBlock; no flash of empty | N/A |
| Search | User types in toolbar | Client-side filter on loaded rows | N/A |
| Composition 503 | BFF outage | AlertBanner composition copy | No partial list invent |
| 401 | Unauthorized | Map via BffClient; clear/redirect as existing session patterns allow | No stack trace |
| Abrir | Row open | Navigate `/funcionarios/:id` stub | N/A |
| Nova (funcionario) | Click CTA | Stub/navigate create intent without POST | Non-funcionario: CTA hidden |

</frozen-after-approval>

## Code Map

- `frontend/src/app/surfaces/ux-employees/` -- new surface (list page, optional employees-api)
- `frontend/src/app/app.routes.ts` -- replace placeholder; add `:id` stub for Abrir
- `frontend/src/app/shared/ui/*` + `shared/http/*` -- consume kit
- `frontend/src/app/shell/identity-api.ts` / shell identity -- role gate for Nova if already loaded; else fetch `me` once in surface
- Continuity: nav item `/funcionarios` already exists

## Tasks & Acceptance

**Execution:**
- [x] `frontend/src/app/surfaces/ux-employees/employees-list-page.*` -- header, toolbar search, kit table/empty/skeleton/banner -- UX-EMPLOYEES list
- [x] `frontend/src/app/surfaces/ux-employees/employees-api.ts` (or inline BffClient) -- `GET /v1/employees` map to table rows -- BFF list
- [x] `frontend/src/app/app.routes.ts` -- wire list + `:id` stub; remove SurfacePlaceholder for funcionarios -- routing
- [x] Role-gate Nova via `identidade/me` papeis; Abrir → stub detail route -- EXPERIENCE CTA + continuity to 0.7
- [x] Unit specs: success/empty/search/503/skeleton/role CTA -- READY
- [x] Verify -- `ng test --watch=false` + `ng build`; spot-check 360/768/1280 -- gate
- [x] Parent repo -- update `frontend` submodule pointer after commit -- AD-8

**Acceptance Criteria:**
- Given authenticated user opens Funcionários, when `GET /api/v1/employees` succeeds, then list shows data-table or compact 2-line list + “Mais ações” without horizontal scroll
- And page-header + toolbar (search + primary CTA) follow EXPERIENCE; empty is pt-BR with CTA when create allowed
- And composition 503 shows composition banner without partial local joins
- And layouts work at 360 / 768 / 1280
- And detail CRUD / write refusal flows remain out of scope (stubs only)

## Spec Change Log

## Design Notes

Map OpenAPI Employee fields to columns (e.g. name, email/registration, status/enabled as “Ativo/Inativo” labels). Prefer high priority: name + one identifier; low: position/hireDate. Detail stub can be a one-liner page until 0.7. Do not POST on Nova in 0.6.

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false` -- employees list specs pass with suite
- `cd frontend && npm run build` -- production build succeeds

**Manual checks:**
- `/funcionarios` at ~360 / 768 / 1280: list vs table; search filters; empty + 503 banners

## Suggested Review Order

**Lista**

- Load, search, banners, 401→login, Nova/Abrir
  [`employees-list-page.ts:76`](../../../frontend/src/app/surfaces/ux-employees/employees-list-page.ts#L76)

- Header, toolbar, empty/search-empty, table
  [`employees-list-page.html:1`](../../../frontend/src/app/surfaces/ux-employees/employees-list-page.html#L1)

- BFF `GET /v1/employees`
  [`employees-api.ts:20`](../../../frontend/src/app/surfaces/ux-employees/employees-api.ts#L20)

**Rotas + stubs**

- `funcionarios` / `novo` / `:id`
  [`app.routes.ts:33`](../../../frontend/src/app/app.routes.ts#L33)

**Tests**

- I/O matrix lista
  [`employees-list-page.spec.ts:40`](../../../frontend/src/app/surfaces/ux-employees/employees-list-page.spec.ts#L40)
