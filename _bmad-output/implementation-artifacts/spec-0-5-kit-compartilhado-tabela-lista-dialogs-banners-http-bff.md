---
title: '0.5 Kit compartilhado (tabela/lista, dialogs, banners, HTTP BFF)'
type: 'feature'
created: '2026-11-24'
status: 'done'
baseline_commit: '9a9a08c0f28d390a2e0a633bf13471923205202c'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-4-ux-home-app-shell-e-navegacao.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md'
  - '{project-root}/_bmad-output/specs/spec-frontend/SPEC.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** After Story 0.4 the SPA has shell/auth but no reusable UI/HTTP primitives — Story 0.6+ employees (and later epics) would each re-invent tables, dialogs, banners, and BFF error mapping.

**Approach:** Add `frontend/src/app/shared/` kit: responsive data-table→compact list, edit/confirm dialogs, refusal/identity/composition banners, skeleton + empty, and a thin BFF HTTP helper that maps 401/503 to the correct institutional banners (incl. T3 composition copy).

## Boundaries & Constraints

**Always:**
- Code under `frontend/src/app/shared/`; Angular Material + DESIGN tokens; pt-BR microcopy; `role="alert"` on banners; no fragile `.mdc-*`
- HTTP only to BFF base (`environment.bffBaseUrl`); never nine domain OpenAPIs; Bearer via existing interceptor
- Locked copies: identity “Identidade indisponível.”; composition T3 “Serviço de composição indisponível.”; refusal uses institutional prose (no account enumeration / no microservice names)
- Compact (&lt;600): data-table → 2-line list + “Mais ações”; edit dialog fullscreen + sticky footer; confirm stacks actions if needed; no table horizontal scroll
- Medium/expanded: table with prioritized columns; dialogs non-fullscreen (~560px edit); verify 360 / 768 / 1280
- Export APIs that Story 0.6 can import without forking markup

**Ask First:**
- Changing locked institutional microcopy
- Adding a public kit demo route into the top nav (demo may stay out of nav)
- Replacing `IdentityApi` / oauth session with the new BFF helper

**Never:**
- UX-EMPLOYEES list/CRUD (0.6+), full master-detail layout (0.7), changing shell menu order
- Client-side join/fallback when T3 composition returns 503
- `keycloak-js`, FAB, dark mode, Bearer in `localStorage`

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Compact table | Viewport &lt;600 + rows | 2-line list + “Mais ações”; no h-scroll | N/A |
| Expanded table | Viewport ≥1024/1280 | Columnar table; row actions available | N/A |
| Edit dialog compact | Open edit | Fullscreen; sticky footer actions | N/A |
| Confirm cramped | Narrow width | Primary/cancel stack if needed | N/A |
| Refusal banner | Show refusal | `role="alert"` + locked prose | N/A |
| Composition 503 | BFF/T3 503 via helper | Banner “Serviço de composição indisponível.” | No local join |
| Identity/network 503 | Mapped identity failure | Banner “Identidade indisponível.” | N/A |
| BFF 401 via helper | Unauthorized | Signal/session-clear path usable by callers (no silent swallow) | Map to refusal/session handling |

</frozen-after-approval>

## Code Map

- `frontend/src/app/shared/` -- new kit root (components + bff http)
- `frontend/src/app/shared/ui/` -- data-table/list, dialogs, banners, skeleton, empty (new)
- `frontend/src/app/shared/http/` -- BFF client/error mapper (new)
- `frontend/src/app/shell/login-page.*` -- optional rewire to shared banners (nice-to-have, not blocking)
- Continuity: shell 0.4, `environment.bffBaseUrl`, bearer interceptor

## Tasks & Acceptance

**Execution:**
- [x] `frontend/src/app/shared/ui/refusal-banner.*` + `identity-banner.*` (or one banner with kind) -- `role="alert"` + locked copies -- State Patterns
- [x] `frontend/src/app/shared/ui/skeleton-block.*` + `empty-state.*` -- cold-load + empty+CTA slots -- EXPERIENCE
- [x] `frontend/src/app/shared/ui/responsive-data-table.*` -- table→compact 2-line list + “Mais ações”; no h-scroll -- FE-CAP-3 list
- [x] `frontend/src/app/shared/ui/edit-dialog.*` + `confirm-dialog.*` -- fullscreen+sticky footer compact; stack confirm actions -- EXPERIENCE dialogs
- [x] `frontend/src/app/shared/http/bff-client.ts` (or equiv.) -- BFF-only base; map 401/503/composition to banner kinds + T3 copy -- FE-CAP-4 HTTP
- [x] Unit specs for table breakpoint behavior, banners, dialogs, error mapper -- READY testable
- [x] Verify -- `ng test --watch=false` + `ng build`; spot-check 360/768/1280 on kit components -- gate
- [x] Parent repo -- update `frontend` submodule pointer after commit -- AD-8

**Acceptance Criteria:**
- Given shell from 0.4, when shared components are available, then compact data-table becomes 2-line list + “Mais ações” without horizontal scroll
- And edit dialogs are fullscreen with sticky footer in compact; confirm stacks buttons when needed
- And refusal/identity banners (`role="alert"`), skeleton, and empty follow EXPERIENCE State Patterns
- And HTTP helper targets only BFF; 401/503 map to correct banners; T3 503 shows “Serviço de composição indisponível.” without client join
- And employees/domain surfaces remain out of scope

## Spec Change Log

## Design Notes

Prefer content projection / inputs over hard-coding employee columns — kit stays domain-agnostic. A single `AlertBanner` with `kind: 'refusal' | 'identity' | 'composition'` is fine if copies stay locked. Rewiring login-page to shared banners is desirable but optional if tests stay green. No mandatory kit demo route.

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false` -- shared kit specs pass
- `cd frontend && npm run build` -- production build succeeds

**Manual checks:**
- Resize kit table host ~360 / 768 / 1280: list vs table; dialog fullscreen vs modal
- Trigger mapped 503 composition → institutional banner text only

## Suggested Review Order

**HTTP + banners**

- Locked copies + 401/503/composition mapping
  [`bff-error.ts:51`](../../../frontend/src/app/shared/http/bff-error.ts#L51)

- Thin BFF HttpClient wrapper (no oauth replace)
  [`bff-client.ts:33`](../../../frontend/src/app/shared/http/bff-client.ts#L33)

- AlertBanner kinds + refusal fallback
  [`alert-banner.ts:15`](../../../frontend/src/app/shared/ui/alert-banner.ts#L15)

**Table + dialogs**

- Compact list / hide low &lt;1280 / touch=Abrir
  [`responsive-data-table.ts:38`](../../../frontend/src/app/shared/ui/responsive-data-table.ts#L38)

- Confirm + edit dialog helpers
  [`confirm-dialog.ts:1`](../../../frontend/src/app/shared/ui/confirm-dialog.ts#L1)
  [`edit-dialog.ts:1`](../../../frontend/src/app/shared/ui/edit-dialog.ts#L1)

**Skeleton / empty / exports**

- Cold-load + empty+CTA
  [`skeleton-block.ts:1`](../../../frontend/src/app/shared/ui/skeleton-block.ts#L1)
  [`empty-state.ts:1`](../../../frontend/src/app/shared/ui/empty-state.ts#L1)

- Public kit barrel
  [`ui/index.ts:1`](../../../frontend/src/app/shared/ui/index.ts#L1)

**Tests**

- Table breakpoints + banner/mapper coverage
  [`responsive-data-table.spec.ts:39`](../../../frontend/src/app/shared/ui/responsive-data-table.spec.ts#L39)
