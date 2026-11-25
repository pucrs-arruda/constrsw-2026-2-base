---
title: '0.8 Criar e editar Employee (ciclo de vida)'
type: 'feature'
created: '2026-11-25'
status: 'done'
baseline_commit: '15853bf5cfbbfd185b05fa35ab43e8f19c6ec1a2'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-7-detalhe-employee-dependent-1-n.md'
  - '{project-root}/docs/open-api/arruda-employees-api.yaml'
  - '{project-root}/docs/open-api/schemas/employee-write.schema.json'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Nova and Editar still dead-end on stubs — operators cannot create or update Employee identity (including Active/Inactive) via the BFF.

**Approach:** Replace the create stub and wire detail “Editar funcionário” with Employee write UX: `POST`/`PUT` `/api/v1/employees[/{id}]` using `EmployeeWrite` (status as ativo signal), shared kit edit dialogs, list/detail refresh with stable `id`; no Keycloak provisioning, no physical delete.

## Boundaries & Constraints

**Always:**
- BFF only: `POST /api/v1/employees`, `PUT /api/v1/employees/{id}` (full replace); Bearer via interceptor; body = OpenAPI `EmployeeWrite` (registrationNumber, name, salary, hireDate, position, status Active|Inactive, optional phone/email)
- Reuse kit: `openEditDialog` / `EditDialogLayout`, `AlertBanner`, `BffClient`; role `funcionario` for write CTAs (same as list Nova / dependent write)
- Create: route `/funcionarios/novo` (replace stub) and/or dialog from Nova; on 201 navigate to detail with returned `id` or refresh list
- Edit: CTA on detail master; PUT then refresh detail; dependents untouched by PUT
- Email uniqueness → refusal-banner + form retained; compact/medium/expanded dialog rules (fullscreen + sticky footer in compact); pt-BR; code under `frontend/src/app/surfaces/ux-employees/`
- ACs at 360 / 768 / 1280

**Ask First:**
- Using PATCH instead of/in addition to PUT for edit
- Changing EmployeeWrite field set vs OpenAPI

**Never:**
- Keycloak / IdP user provisioning on create
- Physical DELETE employee; Dependent CRUD changes (0.7); deep FR refusal microcopy / inactive labeling polish beyond write feedback needed here (Story 0.9)
- Domain OpenAPIs; FAB; `.mdc-*`; client invent on 503

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Create happy | funcionario + valid form | POST 201; land on detail (or list refresh) with stable id | N/A |
| Edit happy | PUT valid body | Detail refreshes; status Active/Inactive applied | N/A |
| Email conflict | Duplicate email | Refusal banner; form retained in dialog/page | problem+json |
| 401 | Unauthorized write | Clear session → login | N/A |
| 503 | Outage | Composition/identity banner as mapped | No invent |
| Compact | &lt;600 | Fullscreen edit dialog + sticky footer | N/A |
| Non-funcionario | Other roles | No Nova / Editar write CTAs | Read-only |

</frozen-after-approval>

## Code Map

- `frontend/src/app/surfaces/ux-employees/employees-create-stub.*` -- replace with create page or remove if dialog-only + route host
- `frontend/src/app/surfaces/ux-employees/employees-api.ts` -- add `create` + `replace` (PUT) for EmployeeWrite
- `frontend/src/app/surfaces/ux-employees/employees-list-page.*` -- Nova already routes to `novo`; keep gated
- `frontend/src/app/surfaces/ux-employees/employees-detail-page.*` -- add Editar funcionário CTA → edit dialog
- `frontend/src/app/surfaces/ux-employees/employee-form-dialog.*` (new) -- shared create/edit form
- Kit dialogs/banners -- consume

## Tasks & Acceptance

**Execution:**
- [x] `employees-api.ts` -- `create` POST + `replace` PUT EmployeeWrite -- API
- [x] `employee-form-dialog.*` -- create/edit form, refusal retained, compact dialog -- UX write
- [x] Replace create stub / wire `/funcionarios/novo` + detail Editar -- routing/UX
- [x] Unit specs for create/edit happy, email refusal, 401/503 -- READY
- [x] Verify -- `ng test --watch=false` + `ng build` -- gate
- [x] Parent repo -- update frontend pointer after commit -- AD-8

**Acceptance Criteria:**
- Given I choose Nova / Editar, when I submit a valid Employee via BFF POST/PUT, then list/detail refresh with stable `id`
- And email uniqueness shows refusal-banner with form retained; Active→Inactive allowed; no Keycloak call
- And no physical delete is offered; dialogs follow compact fullscreen + sticky footer
- And layouts work at 360 / 768 / 1280
- And broad inactive/FR refusal polish remains Story 0.9

## Spec Change Log

## Design Notes

Map epic “ativo” to OpenAPI `status: Active | Inactive` (not `enabled` — that is logical delete). Prefer one `EmployeeFormDialog` for create and edit (mode + optional seed), mirroring DependentFormDialog. Create deep-link `/funcionarios/novo` should host or open the same form so Nova keeps working.

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false`
- `cd frontend && npm run build`

**Manual checks:**
- Nova → create → detail; Editar → Inactive; duplicate email refusal; resize 360/768/1280

## Suggested Review Order

**Create host**

- Gate `funcionario` + dialog create; 401 não compete com lista
  [`employees-create-page.ts:29`](../../../frontend/src/app/surfaces/ux-employees/employees-create-page.ts#L29)

- Rota `/funcionarios/novo`
  [`app.routes.ts:42`](../../../frontend/src/app/app.routes.ts#L42)

**Form write**

- EmployeeWrite POST/PUT, refusal com detail, id obrigatório
  [`employee-form-dialog.ts:130`](../../../frontend/src/app/surfaces/ux-employees/employee-form-dialog.ts#L130)

- Campos + mat-error pt-BR
  [`employee-form-dialog.html:1`](../../../frontend/src/app/surfaces/ux-employees/employee-form-dialog.html#L1)

**Edit no detalhe**

- CTA Editar funcionário → dialog → refresh
  [`employees-detail-page.ts:201`](../../../frontend/src/app/surfaces/ux-employees/employees-detail-page.ts#L201)

**API**

- `create` / `replace`
  [`employees-api.ts:64`](../../../frontend/src/app/surfaces/ux-employees/employees-api.ts#L64)

**Tests**

- Dialog create/edit/email/401/503
  [`employee-form-dialog.spec.ts:111`](../../../frontend/src/app/surfaces/ux-employees/employee-form-dialog.spec.ts#L111)
