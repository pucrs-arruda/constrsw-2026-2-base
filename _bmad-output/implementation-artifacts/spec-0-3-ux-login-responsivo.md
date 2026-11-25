---
title: '0.3 UX-LOGIN responsivo'
type: 'feature'
created: '2026-11-24'
status: 'done'
baseline_commit: '29f457fcc2e0be6b48b6aa18fa3303c8f9875ba5'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-2-sessao-oauth-bearer-para-o-bff.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md'
  - '{project-root}/_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** After Story 0.2 the SPA has oauth session APIs but no login UI, routes, or gate — operators cannot authenticate from the browser or recover from a cold load / empty in-memory token.

**Approach:** Ship UX-LOGIN (responsive login-panel + institutional banners) on `AuthSession`, with route guards, one boot refresh when memory is empty, and a minimal HOME stub so `201` has a landing place.

## Boundaries & Constraints

**Always:**
- Auth only via existing `AuthSession` / `OauthApi`; Bearer in memory only; no `keycloak-js` / IdP in the browser
- pt-BR microcopy locked: 401 → “Não foi possível entrar. Verifique usuário e senha.”; 503/rede → “Identidade indisponível.”; CTA **Entrar**; banners `role="alert"`
- login-panel: expanded = marca|card split; medium = faixa + card ≤440px; compact = faixa + full-width sem elevação; verify 360 / 768 / 1280
- Code in `frontend/src/app/shell/`; Material + DESIGN tokens; no `.mdc-*`; touch ≥48px compact/medium
- `201` → HOME stub; unauthenticated / failed restore → UX-LOGIN

**Ask First:**
- Persisting Bearer outside memory
- Full UX-HOME (hambúrguer, `identidade/me`, menu, Sair) — Story 0.4
- Enabling oauth CORS instead of same-origin proxy

**Never:**
- Full shell nav, employees, or shared kit (0.4–0.5+)
- Account enumeration, stack traces, naming Keycloak/services in banners
- FAB, dark mode, desktop-only login

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Login success | Valid creds → oauth `201` | Bearer in memory; navigate HOME stub | N/A |
| Credentials rejected | `401` or empty fields | Stay on LOGIN; refusal-banner (locked copy) | Form retained; Entrar re-enabled |
| Identity down | `503` / network / 502 / 504 | Stay on LOGIN; identity-banner | Form retained |
| Boot restore | Memory empty + refresh cookie → `201` | Session restored; HOME stub (skip form) | Refresh fail → clear + LOGIN |
| Authed hits login | `isAuthenticated` | Redirect HOME stub | N/A |
| Guard blocks home | No token after boot attempt | Redirect LOGIN | N/A |

</frozen-after-approval>

## Code Map

- `frontend/src/app/shell/auth-session.ts` / `oauth-api.ts` -- consume 0.2 session + `OauthRequestError`
- `frontend/src/app/shell/login-page.*` -- UX-LOGIN panel + banners (new)
- `frontend/src/app/shell/home-stub-page.*` -- minimal authenticated landing until 0.4 (new)
- `frontend/src/app/shell/auth.guard.ts` / `guest.guard.ts` -- gates + one boot refresh (new)
- `frontend/src/app/app.routes.ts` -- `/login`, HOME stub, redirects
- `frontend/src/app/app.ts|html|scss` -- keep brand chrome; outlet hosts surfaces

## Tasks & Acceptance

**Execution:**
- [x] `frontend/src/app/shell/login-page.*` -- responsive login-panel (usuário/senha, Entrar, banners) via `AuthSession.login` -- FE-CAP-1 UX-LOGIN
- [x] `frontend/src/app/shell/home-stub-page.*` -- guarded placeholder without menu/Sair/identidade -- `201` landing until 0.4
- [x] `frontend/src/app/shell/auth.guard.ts` + `guest.guard.ts` -- boot refresh once if memory empty; gate routes -- cold/expired session
- [x] `frontend/src/app/app.routes.ts` -- `/login`, HOME stub, default redirects -- navigable SPA
- [x] `frontend/src/app/shell/*login*.spec.ts` (+ guard specs) -- unit-test I/O matrix -- READY testable
- [x] Verify -- `ng test --watch=false` + `ng build`; spot-check 360/768/1280 -- gate
- [x] Parent repo -- update `frontend` submodule pointer after commit -- AD-8

**Acceptance Criteria:**
- Given cold URL or empty session, when UX-LOGIN opens, then layouts match EXPERIENCE at 360 / 768 / 1280 without horizontal overflow
- Given `401`, when submit finishes, then refusal-banner shows locked copy; form retained
- Given `503`/network, when submit finishes, then banner shows “Identidade indisponível.”
- Given oauth `201`, when login succeeds, then Bearer is set and app navigates to HOME stub
- And full UX-HOME shell remains out of scope

## Spec Change Log

## Design Notes

HOME stub is intentional: 0.3 owns auth UX and navigation *to* home; 0.4 owns shell chrome. One boot `refresh()` when `accessToken` is null covers deferred cookie restore; no proactive `expires_in` timers. Reuse `OauthRequestError` messages — do not invent alternate copy.

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false` -- I/O matrix covered
- `cd frontend && npm run build` -- production build succeeds
- `rg "keycloak-js|localStorage" frontend/src/app/shell` -- no Keycloak; no Bearer in localStorage

**Manual checks:**
- ~360 / 768 / 1280: login-panel geometry (split / faixa+card / full-width)
- oauth up: bad password → 401 banner; oauth down → identity banner; good login → HOME stub

## Suggested Review Order

**Login panel**

- Submit path: trim, locked banners, re-enable form, navigate HOME stub
  [`login-page.ts:40`](../../../frontend/src/app/shell/login-page.ts#L40)

- Entrar CTA, `role="alert"` banners, brand strip without `aria-hidden` on text
  [`login-page.html:1`](../../../frontend/src/app/shell/login-page.html#L1)

- Compact / medium ≤440 / expanded split breakpoints
  [`login-page.scss:1`](../../../frontend/src/app/shell/login-page.scss#L1)

**Session gate**

- One shared boot refresh when memory is empty
  [`session-bootstrap.ts:18`](../../../frontend/src/app/shell/session-bootstrap.ts#L18)

- Authenticated routes → LOGIN when restore fails
  [`auth.guard.ts:7`](../../../frontend/src/app/shell/auth.guard.ts#L7)

- Guest LOGIN → HOME stub when session present/restored
  [`guest.guard.ts:7`](../../../frontend/src/app/shell/guest.guard.ts#L7)

**Routes + stub**

- `/login`, `/` + `/home` stub, catch-all
  [`app.routes.ts:7`](../../../frontend/src/app/app.routes.ts#L7)

- Minimal authenticated landing until Story 0.4
  [`home-stub-page.ts:7`](../../../frontend/src/app/shell/home-stub-page.ts#L7)

**Tests**

- Login I/O matrix including 502/500 microcopy lock
  [`login-page.spec.ts:14`](../../../frontend/src/app/shell/login-page.spec.ts#L14)

- Guards + single boot refresh / no retry after fail
  [`auth.guards.spec.ts:22`](../../../frontend/src/app/shell/auth.guards.spec.ts#L22)
