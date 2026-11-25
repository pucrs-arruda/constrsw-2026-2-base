---
title: '0.4 UX-HOME app-shell e navegação'
type: 'feature'
created: '2026-11-24'
status: 'done'
baseline_commit: '829dff688a2d45d6155ba559d2e07d4a21bd2b46'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-3-ux-login-responsivo.md'
  - '{project-root}/_bmad-output/specs/spec-frontend/surfaces.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** After Story 0.3 authenticated users land on a HOME stub with toolbar only — no hamburger, identity, or Sair — so domain surfaces cannot be reached through the EXPERIENCE shell.

**Approach:** Ship UX-HOME app-shell on authenticated routes: toolbar + drawer/sheet + outlet, `GET /api/v1/identidade/me`, fixed 10-item menu with active marking, Sair → logout → LOGIN, and no shell chrome on `/login`.

## Boundaries & Constraints

**Always:**
- Authenticated routes only for shell; `/login` has no hamburger/identity/Sair (clear deferred toolbar-on-login)
- Header from BFF `GET {bff}/v1/identidade/me` — display `email` else `sub`; avatar = initials (`Identity` has no `nome`)
- Menu order (surfaces.md): Funcionários, Professores, Alunos, Salas de Aula, Recursos, Disciplinas, Turmas, Ocupação, Plano + roster, Minhas aulas — no Lessons/Reservations; no `/health` screen
- Nav: &lt;1024 modal sheet (Esc/scrim/item close; focus → hamburger); ≥1024 fixed drawer ~280px; active item marked; compact ≤599 may hide caption + name; Sair always visible
- `AuthSession.logout` → `/login`; pt-BR; Material + DESIGN; `frontend/src/app/shell/`; touch ≥48px compact/medium; verify 360 / 768 / 1280
- Placeholder routes for the 10 items; real domain UIs stay later

**Ask First:**
- Changing menu order/labels vs `surfaces.md`
- Persisting Bearer outside memory
- Building Story 0.5 shared HTTP kit beyond a thin identity fetch

**Never:**
- Employees UI, shared table/dialogs kit, domain OpenAPIs, `keycloak-js`
- FAB, dark mode, `.mdc-*`, Lessons/Reservations in top nav

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Shell loads | Bearer + `me` 200 | Identity in header; 10 menu items; HOME in outlet | N/A |
| `me` 401 | BFF rejects | Clear session → LOGIN | No crash |
| `me` 503/network | Fetch fails | Shell usable; institutional fallback in identity area | No stack trace |
| Sair | Click Sair | Logout + LOGIN; no shell chrome | Local clear if logout network fails |
| Nav &lt;1024 | Open hamburger | Modal sheet + scrim; Esc/scrim/item close; focus → hamburger | N/A |
| Nav ≥1024 | Authenticated layout | Fixed drawer; active by route | N/A |
| Guest login | `/login` | Login panel only | N/A |
| Menu click | e.g. Funcionários | Placeholder route; active marked; sheet closes if modal | N/A |

</frozen-after-approval>

## Code Map

- `frontend/src/app/app.routes.ts` + shell layout -- `/login` outside shell; auth children = HOME + 10 placeholders
- `frontend/src/app/shell/app-shell.*` -- toolbar, hamburger, sidenav/sheet, Sair, outlet (new)
- `frontend/src/app/shell/nav-items.ts` -- ordered labels + paths (new)
- `frontend/src/app/shell/identity-api.ts` -- `identidade/me` client (new)
- `frontend/src/app/shell/home-stub-page.*` -- retire/replace with HOME landing under shell
- Continuity: `auth-session`, guards, `session-bootstrap`, `login-page`, bearer interceptor

## Tasks & Acceptance

**Execution:**
- [x] `frontend/src/app/app.routes.ts` (+ shell layout) -- auth shell wraps HOME + 10 placeholders; `/login` outside -- FE-CAP-2
- [x] `frontend/src/app/shell/app-shell.*` -- hamburger, marca, caption, identity, Sair; sheet &lt;1024 / drawer ≥1024; compact hides caption/name -- EXPERIENCE
- [x] `frontend/src/app/shell/nav-items.ts` -- fixed 10-item order; active marking; no health/lessons/reservations -- surfaces.md
- [x] `frontend/src/app/shell/identity-api.ts` (+ shell wire) -- Bearer `me` → email/sub + initials -- header
- [x] Replace `home-stub-page` with HOME landing under shell; strip chrome from `/login` -- landing + deferred polish
- [x] `frontend/src/app/shell/*shell*.spec.ts` (+ identity/nav) -- unit-test I/O matrix -- READY
- [x] Verify -- `ng test --watch=false` + `ng build`; spot-check 360/768/1280 -- gate
- [x] Parent repo -- update `frontend` submodule pointer after commit -- AD-8

**Acceptance Criteria:**
- Given a valid session, when UX-HOME loads, then `identidade/me` fills the header and the menu lists the 10 items with the active route marked
- And Sair logs out to UX-LOGIN without shell chrome
- And below 1024px nav is a modal sheet (Esc/scrim/item; focus → hamburger); ≥1024px fixed drawer
- And layouts work at 360 / 768 / 1280; `/health` is not a screen
- And domain UIs / shared kit remain out of scope (placeholders only)

## Spec Change Log

## Design Notes

Use Material sidenav/CDK focus for sheet vs drawer. Thin `IdentityApi` is enough (do not wait for 0.5 kit). One `SurfacePlaceholder` component can back the 10 routes until later epics.

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false` -- shell/identity I/O covered
- `cd frontend && npm run build` -- production build succeeds

**Manual checks:**
- 360 / 768 / 1280: sheet vs drawer; compact hides caption/name; Sair remains
- `/login` without shell chrome; after login identity + menu appear

## Suggested Review Order

**App shell**

- Toolbar, identity, Sair, Esc sheet, sidenav mode
  [`app-shell.ts:47`](../../../frontend/src/app/shell/app-shell.ts#L47)

- Hamburger a11y + 10-item nav + outlet
  [`app-shell.html:1`](../../../frontend/src/app/shell/app-shell.html#L1)

- Compact hide + nav touch 48px + active bar
  [`app-shell.scss:1`](../../../frontend/src/app/shell/app-shell.scss#L1)

**Identity + nav data**

- `GET /v1/identidade/me` + display/initials helpers
  [`identity-api.ts:17`](../../../frontend/src/app/shell/identity-api.ts#L17)

- Locked surfaces.md order
  [`nav-items.ts:7`](../../../frontend/src/app/shell/nav-items.ts#L7)

**Routing**

- `/login` outside shell; auth children HOME + placeholders
  [`app.routes.ts:9`](../../../frontend/src/app/app.routes.ts#L9)

- Root is outlet-only (no chrome on login)
  [`app.html:1`](../../../frontend/src/app/app.html#L1)

**Tests**

- me/Sair/active/Esc/resize + login without shell
  [`app-shell.spec.ts:29`](../../../frontend/src/app/shell/app-shell.spec.ts#L29)
