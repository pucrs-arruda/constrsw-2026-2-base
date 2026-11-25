---
title: '0.2 Sessão oauth Bearer para o BFF'
type: 'feature'
created: '2026-11-24'
status: 'done'
baseline_commit: '81ae0774a91557462c4e341bd6360f437574a143'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/implementation-artifacts/epic-0-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-0-1-scaffold-angular-22-material-tema-design.md'
  - '{project-root}/_bmad-output/specs/spec-frontend/SPEC.md'
  - '{project-root}/_bmad-output/specs/spec-frontend/stack.md'
  - '{project-root}/backend/oauth/README.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** After Story 0.1 the SPA has no oauth session: nothing stores an access token or attaches `Authorization: Bearer` to BFF calls, so Stories 0.3–0.4 cannot authenticate.

**Approach:** Add a `frontend/src/app/shell/` session layer that talks to `backend/oauth` (`POST /login` multipart, `/refresh`, `/logout`), keeps the access token in SPA memory only, and attaches Bearer on BFF HTTP requests — without building the login UI or home shell yet.

## Boundaries & Constraints

**Always:**
- Auth only via `backend/oauth`; data calls only to BFF; never Keycloak / `keycloak-js` / nine domain OpenAPIs
- `POST /login` as `multipart/form-data` (`username`, `password`); `201` body supplies `access_token` (and related token fields) used as `Authorization: Bearer` on BFF
- Refresh via `POST /refresh`; logout via `POST /logout`; refresh cookie may coexist (`withCredentials` on oauth calls)
- Bearer lives in **in-memory session** only — no long-lived `localStorage` for the access token (SPEC / EXPERIENCE)
- Code under `frontend/src/app/shell/`; commit in the `frontend` submodule; update parent pointer when submodule commit exists
- Prefer **same-origin proxy** (nginx + `ng serve` proxy) for oauth so browser cookies and CORS stay simple; expose oauth as `/oauth/*` from the SPA origin
- UI locale pt-BR for any user-visible session error strings introduced here

**Ask First:**
- Changing live `.env` secret values (never print them)
- Enabling CORS on the oauth Nest service instead of (or in addition to) the frontend reverse-proxy
- Persisting refresh/access tokens outside in-memory session (e.g. `sessionStorage`)

**Never:**
- UX-LOGIN screen, UX-HOME nav/hamburger, Employees surfaces, or shared kit primitives (Stories 0.3–0.5+)
- Calling IdP URLs from the browser; embedding Keycloak adapters
- Fragile `.mdc-*` CSS; dark mode; FAB
- Printing `.env` secrets in logs, commits, or chat

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Login success | Valid username/password → oauth `201` with `access_token` | Session holds token in memory; subsequent BFF requests send `Authorization: Bearer <access_token>` | N/A |
| Login refusal | oauth `401` | Session remains empty; no Bearer attached | Surfaceable error signal for Story 0.3 (no account enumeration) |
| Identity down | oauth `503` / network failure on login | Session empty | Surfaceable “Identidade indisponível.” signal for Story 0.3 |
| Refresh | Valid session cookie + `POST /refresh` → `201` | In-memory access token replaced | On refresh failure, clear session (caller → login later) |
| Logout | `POST /logout` | Session cleared; no Bearer on later BFF calls | Treat network error as local clear + best-effort server logout |
| BFF call authenticated | In-memory token present | Interceptor adds Bearer only to BFF base requests | Never attach Bearer to oauth login/refresh/logout |

</frozen-after-approval>

## Code Map

- `frontend/src/app/shell/auth-session.ts` -- in-memory Bearer session (login/refresh/logout/clear)
- `frontend/src/app/shell/oauth-api.ts` -- multipart login + refresh/logout with credentials
- `frontend/src/app/shell/bearer.interceptor.ts` -- Bearer only on `bffBaseUrl` requests
- `frontend/src/app/shell/auth-session.spec.ts` -- I/O matrix unit tests
- `frontend/src/environments/environment*.ts` -- relative `/oauth` + `/api` bases
- `frontend/nginx.conf` -- reverse-proxy `/oauth/` → `oauth:8088`, `/api/` → `api:3001`
- `frontend/proxy.conf.json` -- `ng serve` proxy to lab host ports 8181/8180
- `frontend/src/app/app.config.ts` -- `provideHttpClient(withInterceptors([bearerInterceptor]))`
- Continuity from 0.1: Material theme + blank brand chrome unchanged

## Tasks & Acceptance

**Execution:**
- [x] `frontend/src/environments/environment.ts` (+ `.development.ts` if needed) -- define `oauthBaseUrl` / `bffBaseUrl` (relative `/oauth` + `/api` preferred) -- FE can target lab hosts without secrets in source
- [x] `frontend/nginx.conf` + `proxy.conf.json` -- proxy `/oauth/` to oauth service; wire `ng serve --proxy-config` -- same-origin auth + cookies
- [x] `frontend/src/app/shell/auth-session.ts` (or equivalent) -- in-memory access token; login/refresh/logout methods; clear on failure -- FE-CAP-1 session
- [x] `frontend/src/app/shell/oauth-api.ts` -- `HttpClient` multipart login + refresh/logout with `withCredentials` -- oauth contract
- [x] `frontend/src/app/shell/bearer.interceptor.ts` -- attach Bearer to BFF requests only -- BFF Authorization
- [x] `frontend/src/app/app.config.ts` -- `provideHttpClient(withInterceptors(...))` -- enable HTTP stack
- [x] `frontend/src/app/shell/*.spec.ts` -- unit-test I/O matrix (success, 401, 503/network, refresh replace, logout clear, interceptor skip oauth) -- READY testable
- [x] Verify -- `ng test --watch=false` + `ng build`; optional compose rebuild frontend -- gate
- [x] Parent repo -- update `frontend` submodule pointer after submodule commit -- AD-8 envelope

**Acceptance Criteria:**
- Given oauth returns `201` with `access_token`, when session login completes, then the token is held in memory and BFF HTTP calls include `Authorization: Bearer …`
- And refresh updates the in-memory token; logout clears it; no long-lived `localStorage` Bearer
- And `keycloak-js` is absent; browser never calls the IdP
- And login UI / home nav / employees kit are still out of scope (no regressions to blank shell chrome)

## Spec Change Log

## Design Notes

SPEC-frontend wins over Architecture spine wording that routes browser login only through BFF: Story 0.2 calls **oauth** for login/refresh/logout and uses the access token as Bearer on **BFF**.

Same-origin proxy avoids enabling CORS on oauth and keeps the refresh cookie first-party relative to the SPA origin (`localhost:4200`).

Minimal public API for later stories (do not build UI here):

```ts
login(username: string, password: string): Observable<void>;
refresh(): Observable<void>;
logout(): Observable<void>;
readonly accessToken: string | null; // or signal/getter
```

## Verification

**Commands:**
- `cd frontend && npx ng test --watch=false` -- session/interceptor specs pass for I/O matrix
- `cd frontend && npm run build` -- production build succeeds
- `rg "keycloak-js|localStorage" frontend/src/app/shell` -- no keycloak; no Bearer persistence via localStorage
- `rg "\\.mdc-" frontend/src` -- still no fragile MDC selectors

**Manual checks:**
- With oauth up, call session `login` from a temporary harness or unit/integration path; confirm Bearer on a BFF request (DevTools) without implementing UX-LOGIN

## Suggested Review Order

**Session API**

- In-memory access token; login/refresh/logout clear on failure
  [`auth-session.ts:10`](../../../frontend/src/app/shell/auth-session.ts#L10)

- Multipart login + mapped 401/502/503/504 errors for Story 0.3
  [`oauth-api.ts:33`](../../../frontend/src/app/shell/oauth-api.ts#L33)

**Bearer on BFF only**

- Path-bounded interceptor; never attaches to `/oauth/*`
  [`bearer.interceptor.ts:7`](../../../frontend/src/app/shell/bearer.interceptor.ts#L7)

- Wire HttpClient + interceptor at app bootstrap
  [`app.config.ts:12`](../../../frontend/src/app/app.config.ts#L12)

**Same-origin proxy**

- Compose nginx `/oauth/` → oauth, `/api/` → BFF
  [`nginx.conf:14`](../../../frontend/nginx.conf#L14)

- Local `ng serve` proxy to lab host ports
  [`proxy.conf.json:1`](../../../frontend/proxy.conf.json#L1)

**Tests**

- I/O matrix: success, 401/503/network, refresh, logout, no Bearer on oauth
  [`auth-session.spec.ts:18`](../../../frontend/src/app/shell/auth-session.spec.ts#L18)
