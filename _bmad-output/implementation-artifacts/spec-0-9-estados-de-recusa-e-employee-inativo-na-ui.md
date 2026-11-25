---
title: '0.9 Estados de recusa e Employee inativo na UI'
type: 'feature'
created: '2026-11-25'
status: 'draft'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-8-criar-e-editar-employee-ciclo-de-vida.md'
  - '{project-root}/docs/open-api/arruda-employees-api.yaml'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Write failures and inactive Employees still lack institutional FR-aware copy and clear inactive labeling — operators see generic refusals and consumers cannot reliably spot FR-1a inactive state.

**Approach:** Harden UX-EMPLOYEES refusal handling from BFF problem+json (`code` when present) with institutional pt-BR banners, and surface Inactive employees as visible but explicitly labeled in list/detail (status already Active/Inactive) so later epics can enforce FR-1a.

## Boundaries & Constraints

**Always:**
- Map write problem+json to `AlertBanner` refusal (`role="alert"`); prefer `detail`/`title`/`code` when present; keep form retained on dialog writes
- Inactive (`status: Inactive`) remains listable/openable; label clearly (e.g. Situação Inativo / chip or column already present) — no hide-from-list
- Identity-style 503 uses identity-banner where the failing call is identity-scoped; composition outages keep composition banner
- BFF only; Bearer; pt-BR; code under `frontend/src/app/surfaces/ux-employees/` (+ shared banner helpers only if needed)
- ACs at 360 / 768 / 1280

**Ask First:**
- Changing institutional refusal copy locked in kit/`BFF_BANNER_MESSAGES`
- Hiding Inactive from list (would break FR-1a visibility for consumers)

**Never:**
- New create/edit field sets (0.8); Dependent schema changes; Keycloak; physical delete; FAB; `.mdc-*`; client invent on 503

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Write refusal + code | problem+json with FR code/detail | Refusal banner institutional pt-BR; form retained | No stack traces |
| Inactive in list | Employee status Inactive | Visible row; Situação/label Inativo | N/A |
| Inactive detail | Open Inactive id | Master shows Inativo clearly | N/A |
| Identity 503 | me/oauth-scoped outage path | Identity banner where applicable | No invent |
| Composition 503 | employees write/list down | Composition banner | No invent |

</frozen-after-approval>

## Code Map

- `frontend/src/app/surfaces/ux-employees/employee-form-dialog.*` -- deepen refusal copy from problem+json
- `frontend/src/app/surfaces/ux-employees/dependent-form-dialog.*` -- same refusal pattern on dependent writes
- `frontend/src/app/surfaces/ux-employees/employees-list-page.*` -- ensure Inactive labeled (status column)
- `frontend/src/app/surfaces/ux-employees/employees-detail-page.*` -- Inativo visible on master
- `frontend/src/app/shared/http/bff-error.ts` -- only if shared mapping of `code`/detail needs extension

## Tasks & Acceptance

**Execution:**
- [ ] Refusal mapping from problem+json (`detail`/`title`/`code`) on employee (+ dependent) writes -- UX refusal
- [ ] List + detail: Inactive clearly labeled, still visible/navigable -- FR-1a signal
- [ ] Identity vs composition 503 paths verified in UI specs -- READY
- [ ] Unit specs for refusal+code and Inactive labeling -- READY
- [ ] Verify -- `ng test --watch=false` + `ng build` -- gate
- [ ] Parent repo -- update frontend pointer after commit -- AD-8

**Acceptance Criteria:**
- Given a BFF write returns problem+json with FR `code` when present, when UI handles it, then refusal-banner shows institutional pt-BR (`role="alert"`)
- And inactive employees stay visible but labeled for later FR-1a consumers
- And identity-style 503 uses identity-banner where appropriate; composition stays composition
- And layouts work at 360 / 768 / 1280

## Spec Change Log

## Design Notes

Story 0.8 already maps `detail`/`title` on employee create/edit. 0.9 extends consistency (dependents + list messaging), optional `code` surfacing in copy, and explicit Inactive affordances if the current “Ativo/Inativo” text is too easy to miss (e.g. subtle emphasis — not a new card pattern).

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false`
- `cd frontend && npm run build`

**Manual checks:**
- Force email conflict / FR refusal; open Inactive employee; resize 360/768/1280
