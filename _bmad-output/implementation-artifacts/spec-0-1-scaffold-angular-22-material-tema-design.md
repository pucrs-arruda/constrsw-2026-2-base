---
title: '0.1 Scaffold Angular 22 + Material + tema DESIGN'
type: 'feature'
created: '2026-11-24'
status: 'done'
baseline_commit: '9143ca24fcbe270d315e7764cf26175f0f7ad587'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md'
  - '{project-root}/_bmad-output/specs/spec-frontend/stack.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** `frontend/` is a docs/mockups stub with no Angular app; Compose still assumes a Vite build and cannot run the Closed CRAS SPA on lab port 4200.

**Approach:** Scaffold Angular 22.x + Material M3 + CDK + SCSS in `frontend/`, theme via DESIGN tokens (primary `#0066B3`), add Dockerfile + Compose wiring for port 4200, and ship a blank responsive shell with no overflow at 360/768/1280.

## Boundaries & Constraints

**Always:**
- Angular **22.x** SPA + Angular Material (M3) + CDK + SCSS under `frontend/`
- Map DESIGN tokens (primary `#0066B3`, surfaces, typography Source Sans 3) through the official Material theme/token API — no fragile `.mdc-*` CSS
- Wire Compose so the SPA is reachable on lab port **4200**; container health matches compose (`/health`)
- Blank shell must not scroll horizontally at 360 / 768 / 1280
- Preserve existing `frontend/mockups/` and ownership README contract; UI locale pt-BR for any visible chrome text
- Commit work in the `frontend` submodule; update the parent pointer when the submodule commit exists

**Ask First:**
- Changing live `.env` secret values (never print them). Port key renames / `FRONTEND_*_PORT` → 4200 may be proposed; wait for approval before editing `.env`
- Deleting or relocating `frontend/mockups/`
- Introducing a different HTTP server stack than what Compose health expects (e.g. dropping `/health`)

**Never:**
- Login, oauth/Bearer session, UX-HOME nav, shared HTTP kit, Employees or group surfaces
- React / Vite / TanStack; `keycloak-js`; browser calls to the nine domain OpenAPIs
- Default Material theme without DESIGN tokens; dark mode; FAB
- Printing `.env` secrets in logs, commits, or chat

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Local build | `npm`/`ng` build in `frontend/` | Production build succeeds; Angular 22.x + Material + CDK present | Fail build if deps/theme broken |
| Theme tokens | App boot with Material themed | Primary brand `#0066B3` visible on themed chrome; no `.mdc-*` overrides in project styles | N/A |
| Responsive blank shell | Viewports 360 / 768 / 1280 | Layout fits; no horizontal overflow | N/A |
| Compose wire | `docker compose` build/run `frontend` with ports mapped to 4200 | Container healthy on `/health`; SPA served | Healthcheck fails if `/health` missing |

</frozen-after-approval>

## Code Map

- `frontend/` -- stub today (`README.md`, `mockups/`); scaffold target
- `frontend/package.json`, `angular.json`, `tsconfig*` -- Angular 22 scaffold
- `frontend/src/styles.scss` (+ theme partials) -- DESIGN → Material M3
- `frontend/src/app/app.*`, `index.html` -- blank responsive shell
- `frontend/Dockerfile` -- missing; Compose build + `/health`
- `docker-compose.yml` (`frontend`) -- drop `VITE_*` args; keep port/health
- `.env` -- `FRONTEND_*_PORT` / leftover `VITE_*` (ask before editing)

## Tasks & Acceptance

**Execution:**
- [x] `frontend/` -- scaffold Angular 22.x (SCSS); keep `mockups/` + README ownership -- SPA baseline
- [x] `frontend/` -- add Material M3 + CDK; theme DESIGN tokens (primary `#0066B3`, surfaces, Source Sans 3) without `.mdc-*` -- FE-CAP-6
- [x] `frontend/src/app/*` + global styles -- blank shell, no overflow at 360/768/1280 -- NFR-RESP
- [x] `frontend/Dockerfile` -- multi-stage serve SPA + `/health` -- compose envelope
- [x] `docker-compose.yml` -- Angular build args (no Vite); lab external port **4200** path -- Compose AC
- [x] `.env` (only if approved) -- align `FRONTEND_*_PORT` / build-arg keys; never print secrets -- lab port
- [x] Verify -- `npm run build` + theme/responsive check; optional `docker compose build frontend` -- gate

**Acceptance Criteria:**
- Given stub `frontend/`, when scaffold is generated and built, then app runs with Angular 22.x + Material + CDK + SCSS
- And DESIGN tokens (primary `#0066B3`, surfaces, typography) override default Material without `.mdc-*` selectors
- And project is wired for Docker Compose / local port 4200
- And blank shell at 360 / 768 / 1280 has no horizontal overflow

## Spec Change Log

## Design Notes

Use Material’s official M3 theme API (22.x `mat.define-theme` / mixins) + SCSS/CSS variables from DESIGN — never `.mdc-*`.

Blank shell = full-viewport surface host (optional minimal brand mark); no login, sidenav, or domain routes.

```scss
$brand-primary: #0066B3;
$surface: #F5F8FC;
```

Compose healthcheck probes `http://127.0.0.1/health` — Dockerfile must provide it. Ports: `${FRONTEND_EXTERNAL_PORT}:${FRONTEND_INTERNAL_PORT}`; lab external **4200**.

## Verification

**Commands:**
- `cd frontend && npm ci && npm run build` -- success; Angular 22.x + `@angular/material` + CDK in package.json
- `rg "\\.mdc-" frontend/src` -- no matches
- `docker compose build frontend` (if Docker up) -- image builds with `/health`

**Manual checks:**
- Serve on 4200; blank shell at 360/768/1280 without horizontal scroll; primary `#0066B3` on themed chrome

## Suggested Review Order

**Theme (DESIGN tokens)**

- Official M3 `mat.theme` from generated palettes, then exact DESIGN system vars.
  [`styles.scss:7`](../../frontend/src/styles.scss#L7)

- Pin primary `#0066B3` / surfaces so Material utilities cannot drift.
  [`styles.scss:23`](../../frontend/src/styles.scss#L23)

- Seed palettes from DESIGN primary/secondary/tertiary/error.
  [`_theme-colors.scss:7`](../../frontend/src/styles/_theme-colors.scss#L7)

**Blank shell**

- Material `mat-toolbar` brand chrome (no login/nav yet).
  [`app.html:2`](../../frontend/src/app/app.html#L2)

- Fluid shell styles — wrap text, no nested overflow hacks.
  [`app.scss:1`](../../frontend/src/app/app.scss#L1)

**Compose / lab port 4200**

- Host `:4200` → container nginx `:80`.
  [`docker-compose.yml:676`](../../docker-compose.yml#L676)

- Multi-stage Angular build + `/health` for Compose.
  [`Dockerfile:2`](../../frontend/Dockerfile#L2)

- Static SPA routes + asset 404 + health endpoint.
  [`nginx.conf:8`](../../frontend/nginx.conf#L8)

**Stack pins**

- Angular 22.x + Material + CDK; `npm start` on 4200.
  [`package.json:6`](../../frontend/package.json#L6)
