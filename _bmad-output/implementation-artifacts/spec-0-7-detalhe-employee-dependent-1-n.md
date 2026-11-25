---
title: '0.7 Detalhe Employee + Dependent 1–N'
type: 'feature'
created: '2026-11-25'
status: 'done'
baseline_commit: '7a44486c59d4da055688bfa42489254355d134b3'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-6-lista-de-funcionarios-responsiva.md'
  - '{project-root}/docs/open-api/arruda-employees-api.yaml'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Abrir on the employees list lands on a stub — operators cannot view Employee fields or maintain Dependent 1–N for that employee.

**Approach:** Replace the detail stub with a master-detail UX-EMPLOYEES page: `GET /api/v1/employees/{id}` for the aggregate, Dependent list + create/edit/delete via BFF secondary routes, using shared kit dialogs/table/banners; stack panels below 1280 with “← Voltar para Funcionários” in compact.

## Boundaries & Constraints

**Always:**
- BFF only: `GET/PUT/PATCH/DELETE` employee secondary paths under `/api/v1/employees/{id}/dependents[/{dependentId}]`; Bearer via interceptor
- Reuse kit: `ResponsiveDataTable`, `EmptyState`, `SkeletonBlock`, `AlertBanner`, `openConfirmDialog`, `openEditDialog` / `EditDialogLayout`, `BffClient`
- Master shows Employee read fields (name, registration, status Ativo/Inativo, position, hireDate, email/phone, salary); Dependent 1–N for that employee only
- Compact: back link “← Voltar para Funcionários”; below 1280 stack master then dependents; edit dialogs fullscreen + sticky footer; destructive delete uses confirm naming the dependent
- Dependent CRUD gated to role `funcionario` (same as list Nova); others read-only
- Logical delete only (OpenAPI DELETE → enabled=false); no physical wipe; pt-BR; code under `frontend/src/app/surfaces/ux-employees/`
- ACs at 360 / 768 / 1280

**Ask First:**
- Changing Dependent field set vs OpenAPI
- Editing Employee fields here (that is Story 0.8)

**Never:**
- Employee create/edit forms or write refusal polish beyond dependents (0.8–0.9)
- Keycloak; domain OpenAPIs; FAB; `.mdc-*`; client join on 503

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Detail load | `GET employees/{id}` 200 | Master fields + dependents table/list | Skeleton while loading |
| 404 | Unknown id | Institutional empty/error; Voltar | No crash |
| 503 | Outage | Composition banner | No partial invent |
| 401 | Unauthorized | Clear session → login | N/A |
| Add dependent | funcionario + valid form | POST secondary; refresh list | Refusal banner; form retained in dialog |
| Edit dependent | PUT/PATCH | Updates row | Same refusal pattern |
| Delete dependent | Confirm → DELETE | Row gone (logical) | Confirm names object |
| Compact | &lt;600 | Voltar + stacked layout; fullscreen edit | N/A |

</frozen-after-approval>

## Code Map

- `frontend/src/app/surfaces/ux-employees/employees-detail-stub.*` -- replace with real detail page
- `frontend/src/app/surfaces/ux-employees/employees-api.ts` -- extend get/create/update/delete dependent (+ getById)
- `frontend/src/app/surfaces/ux-employees/employees-list-page.*` -- Abrir already navigates `:id`
- Kit dialogs/table/banners -- consume

## Tasks & Acceptance

**Execution:**
- [x] `employees-api.ts` -- `getById`, dependent list CRUD methods on BFF paths -- API
- [x] `employees-detail-page.*` -- master-detail, Voltar, dependents table, dialogs -- UX detail
- [x] Wire route `:id` to detail page; remove stub -- routing
- [x] Unit specs for load/404/503/401/dependent CRUD happy+confirm -- READY
- [x] Verify -- `ng test --watch=false` + `ng build` -- gate
- [x] Parent repo -- update frontend pointer after commit -- AD-8

**Acceptance Criteria:**
- Given I open an Employee row, when `GET /employees/{id}` returns, then master-detail shows fields and Dependent 1–N for that employee
- And create/edit/delete Dependent uses BFF secondary routes; confirm names the object on delete
- And below 1280 panels stack; compact shows Voltar; edit dialogs fullscreen in compact
- And layouts work at 360 / 768 / 1280
- And Employee create/edit lifecycle remains Story 0.8

## Spec Change Log

## Design Notes

Dependent fields: name, birthDate, dependencyType, status. Employee edit CTA can be a stub button linking to future 0.8 or hidden until 0.8 — prefer hidden/disabled “Editar funcionário” to avoid scope creep.

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false`
- `cd frontend && npm run build`

**Manual checks:**
- Open from list → detail; add/edit/delete dependent; resize 360/768/1280

## Suggested Review Order

**Detalhe + carga**

- Master-detail com `switchMap` em `:id`, Voltar compact, CRUD gated
  [`employees-detail-page.ts:153`](../../../frontend/src/app/surfaces/ux-employees/employees-detail-page.ts#L153)

- Campos do employee + tabela/empty de dependents + Novo
  [`employees-detail-page.html:1`](../../../frontend/src/app/surfaces/ux-employees/employees-detail-page.html#L1)

- Stack &lt;1280 / grid ≥1280
  [`employees-detail-page.scss:110`](../../../frontend/src/app/surfaces/ux-employees/employees-detail-page.scss#L110)

**Dependent write**

- Dialog create/edit com trim validators, `disableClose` ao salvar
  [`dependent-form-dialog.ts:56`](../../../frontend/src/app/surfaces/ux-employees/dependent-form-dialog.ts#L56)

- Form pt-BR + mat-error
  [`dependent-form-dialog.html:1`](../../../frontend/src/app/surfaces/ux-employees/dependent-form-dialog.html#L1)

**API + rota**

- `getById` + secondary Dependent CRUD
  [`employees-api.ts:47`](../../../frontend/src/app/surfaces/ux-employees/employees-api.ts#L47)

- `:id` → detail page (stub removido)
  [`app.routes.ts:47`](../../../frontend/src/app/app.routes.ts#L47)

**Kit**

- Close desabilitável durante save
  [`edit-dialog.ts:30`](../../../frontend/src/app/shared/ui/edit-dialog.ts#L30)

**Tests**

- I/O matrix detail + confirm delete
  [`employees-detail-page.spec.ts:148`](../../../frontend/src/app/surfaces/ux-employees/employees-detail-page.spec.ts#L148)
