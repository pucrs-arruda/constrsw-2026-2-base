# Grupo 07 — Change logs (human + AI handoff)

Shared board for **what changed**, **who did it**, and **what the next person should know**.  
Every group member **and** every AI session that modifies the repo should append an entry here **before or with** the commit.

Related docs:

| Doc | Role |
| --- | --- |
| `_bmad-output/specs/spec-grupo07-keycloak-oauth/` | WHAT (API / Keycloak contract) |
| `_bmad-output/planning-artifacts/epics.md` | Story backlog |
| `_bmad-output/planning-artifacts/architecture-grupo07-keycloak-oauth.md` | HOW (Keycloak + oauth only) |
| `_bmad-output/implementation-artifacts/sprint-status.yaml` | Story status |
| `RESPONSIBILITIES.md` | Who implements which epics/stories (3 tracks) |
| `AI-CONTEXT-PROMPT.md` | Paste prompt for teammate AIs |
| This file (`CHANGELOGS.md`) | WHO did WHAT, when |

---

## How to use (required pattern)

### Rules

1. **Append only** — newest entry at the **top** of the “Log entries” section (below the template). Do not rewrite older entries except to fix your own typo.
2. **One entry per work session** (or per logical PR). If an AI continues someone else’s work, start a **new** entry and mention the previous one.
3. **Never paste secrets** (client secrets, passwords, tokens). Env **names** are OK.
4. Update **`sprint-status.yaml`** when story status changes; mention that in the entry.
5. Scope note: for now we track **Keycloak / oauth** work. Professors/Postgres can get its own section later.

### Template (copy this block)

```markdown
### YYYY-MM-DD — <short title>

| Field | Value |
| --- | --- |
| Author | <Name or "AI (Cursor) for <Name>"> |
| Branch | <base branch / oauth submodule branch> |
| Stories | <e.g. 1.1, 1.2 or "planning only"> |
| Status | <done / in progress / blocked> |

**Summary**
- <1–3 bullets: what landed>

**Paths touched**
- `path/to/file` — <why>

**Decisions / notes for the next person**
- <anything they must not redo or must verify>

**Next suggested step**
- <e.g. code-review 1.1; implement 1.2>
```

### Good vs bad

| Good | Bad |
| --- | --- |
| “Bound `KEYCLOAK_SERVER_URL` in Nest ConfigModule” | “Fixed stuff” |
| “Do not invent compose; professor file already enables oauth” | Pasting `.env` secret values |
| “Story 1.1 → review in sprint-status” | Editing someone else’s log entry silently |

---

## Log entries

### 2026-09-22 — Oauth Prometheus metrics (OpenTelemetry pull)

| Field | Value |
| --- | --- |
| Author | AI (Cursor) for EduardoArruda |
| Branch | `base` `grupo07-feat/telemetry` / `backend/oauth` `grupo07-fix/bearer-userinfo` |
| Stories | 7.1 → review (`sprint-status.yaml`: `epic-7` in-progress) |
| Status | in progress — code is in the working tree, not committed |

**Summary**
- Oauth exposes Prometheus text on `OAUTH_INTERNAL_METRICS_PORT` (default 9464, path `/metrics`) with an in-process OpenTelemetry SDK. `service.name` is `oauth`. HTTP duration only; login, refresh, users, roles, authz, and the OA envelope were not changed.
- Professor scrape job renamed from `auth` to `oauth`, target `oauth:9464`. Blackbox probe is `http://oauth:3001/health`. Compose and `.env` were not edited.
- Live check: `http://localhost:8381/metrics` returns `http_server_request_duration`. `GET /health` is still `{ status: "ok" }`. Jest in `backend/oauth`: 24 suites, 269 tests passed.

**Paths touched**
- `backend/oauth/src/telemetry/instrument.ts` — patch Node `http`/`https` before the SDK loads
- `backend/oauth/src/telemetry/register.ts` — start the SDK and Prometheus exporter; `register.spec.ts`
- `backend/oauth/src/main.ts` — import telemetry before Nest
- `backend/oauth/src/config/keycloak.config.ts` — `OAUTH_INTERNAL_METRICS_PORT` (default 9464)
- `backend/oauth/package.json`, `package-lock.json` — `@opentelemetry/api` 1.9.1, `sdk-node` / `exporter-prometheus` / `instrumentation-http` 0.221.0
- `backend/oauth/Dockerfile` — `EXPOSE 9464`
- `infrastructure/dev.local/services/prometheus/prometheus.yml` — job `oauth`
- `_bmad-output/specs/spec-grupo07-oauth-observability/` — sibling spec (CAP-1..4)
- `_bmad-output/implementation-artifacts/7-1-expose-oauth-prometheus-metrics.md`, `sprint-status.yaml`

**Decisions / notes for the next person**
- Pull only. `spanProcessors` and `logRecordProcessors` are empty so the SDK does not push OTLP traces or logs. Do not add `prom-client`, auto-instrumentations, or a second listener on 9464.
- `instrument.ts` must patch `http` before `@opentelemetry/sdk-node` is imported. A later patch never sees the Nest server.
- The series has method and status (`http_request_method`, `http_response_status_code`) and no URL path. `GET` 200 climbs on its own: compose health check every 15s, Prometheus scrape of `/metrics` every 10s, and the blackbox probe. One `POST /login` adds 1 to the POST row only.
- The Prometheus UI at `:9090` does not auto-refresh the graph. Re-run the query, or poll `http_server_request_duration_count{job="oauth"}`.
- Pins stay at 0.221.0. Exporter versions below 0.217.0 crash on a malformed scrape (CVE-2026-44902).
- Grafana, alert edits, and business counters are out of scope. T1 capability IDs stay as they are; Prometheus for oauth is owned by the sibling spec.
- ⚠️ After committing inside `backend/oauth`, move the parent submodule pointer. The telemetry files are still uncommitted on `grupo07-fix/bearer-userinfo`.

**Next suggested step**
- Code-review story 7.1, then commit the oauth submodule and the parent (`prometheus.yml`, story, sprint status) and update the submodule pointer.

### 2026-09-14 — Read oauth client roles from the JWT so admin@pucrs.br can call /users

| Field | Value |
| --- | --- |
| Author | AI (Cursor) for EduardoArruda |
| Branch | `backend/oauth` working tree |
| Stories | 4.x / 5.x follow-up (AdministratorRoleGuard) |
| Status | in progress — rebuild oauth image to pick up |

**Summary**
- Live Postman: after `scope=openid`, `POST /authz/validate` `{ "resource": "rooms" }` returned 200 for `admin@pucrs.br`, but `GET /users` returned 403 (administrator role required).
- Cause: `AdministratorRoleGuard` read `resource_access.oauth.roles` from **UserInfo**. That body does not include client roles; they are on the access token. Authz already sent the JWT to Keycloak, so rooms succeeded.
- Overlay JWT `resource_access` / `realm_access` onto `request.user.raw` after UserInfo succeeds. Still require the **client** role `administrator` (realm-only admin remains 403).

**Paths touched**
- `backend/oauth/src/common/jwt-payload.ts` — decode payload, no signature check
- `backend/oauth/src/common/bearer-auth.guard.ts` — merge role claims
- specs + `backend/oauth/README.md`

**Next suggested step**
- `docker compose up -d --build oauth`, login as `admin@pucrs.br`, `GET /users` should be 200.

### 2026-09-14 — Login/refresh request `scope=openid` so UserInfo (Bearer guard) accepts tokens

| Field | Value |
| --- | --- |
| Author | AI (Cursor) for EduardoArruda |
| Branch | `base` `grupo07` / `backend/oauth` working tree |
| Stories | 2.1 / 2.2 follow-up (Bearer on 4.x, 5.x, 6.5) |
| Status | in progress — rebuild oauth image to pick up |

**Summary**
- Live Postman: `POST /login` returned 200, but `GET /users` and `POST /authz/validate` returned `OA-401` “Access token is invalid or expired” with a fresh token.
- Cause: password/refresh grants did not send `scope=openid`. Keycloak still issues tokens; UserInfo (used by `BearerAuthGuard`) rejects them. Authz was never reached.

**Paths touched**
- `backend/oauth/src/auth/keycloak-token.client.ts` — always send `scope=openid`
- `backend/oauth/src/auth/keycloak-token.client.spec.ts`
- `backend/oauth/README.md`

**Decisions / notes for the next person**
- Rebuild the oauth image after this change. Old tokens without `openid` stay unusable; login again.

**Next suggested step**
- `docker compose up -d --build oauth`, then Postman login → `GET /users` / `/authz/validate`.

### 2026-09-11 — Final audit of the T1 scope + submodule pointer

| Field | Value |
| --- | --- |
| Author | William Klein |
| Branch | `oauth` `grupo07-fix/audit-findings` (PR #13, merged); `base` `grupo07-fix/submodule-pointer` |
| Stories | audit across all six epics — no story status changed |
| Status | done |

**Summary**
- Reviewed every source file against the T1 brief. Coverage is complete and there is no dead code, no `TODO`, no `any`, no `@ts-ignore`.
- Fixed three findings (oauth PR #13): a vacuous test assertion, an inconsistent status, and credentials reaching an error body.
- **Pointed the `backend/oauth` submodule at the current `grupo07`** — it still referenced `98b634e`, from before the users API.

**Paths touched**
- `backend/oauth/src/authz/authz-matrix.spec.ts`, `src/auth/keycloak-token.client.ts`, `src/errors/oa-error.mapper.ts`, `README.md`
- `backend/oauth` (submodule reference), `CHANGELOGS.md`

**Decisions / notes for the next person**

- ⚠️ **Update the submodule pointer whenever the oauth branch advances.** Merging inside the submodule does **not** move the reference the parent stores. It was three merges behind, so `git clone --recurse-submodules` + `docker compose up` would have built an image without the `/users` routes at all. Check `git ls-tree grupo07 backend/oauth` against the submodule's own HEAD before anyone tests.
- **`rejects.toMatchObject({})` matches any object.** The story 6.5 deny cases used it, so replacing the controller's `forbidden()` with `badRequest()` left all 34 tests green. Assert the status, not merely that something was thrown.
- **An unreachable Keycloak is `503` everywhere now** — guard, `/login`, `/refresh`, `/authz/validate`. `/login` and `/refresh` previously answered `401`, telling a caller with valid credentials that they were wrong because of an outage on our side.
- **`error_stack` redacts `access_token`, `refresh_token`, `id_token`, `client_secret` and `password`.** The incomplete-token-response path relayed the upstream payload verbatim, and that payload still holds real tokens. The redaction lives in `OaErrorMapper.fromKeycloak`, so it covers code written later too.
- 📌 **Still not verified against a running Keycloak.** All 254 tests face a faked upstream: they prove the logic and the contracts, not the wiring. Story 1.3 is that proof.

**Next suggested step**
- Run the stack for real and walk every route. Worth watching: whether this Keycloak honours `?enabled=` on `GET /users` (the service refilters locally because some setups ignore it), the `Location` header shape on create, and the hierarchical matrix on `POST /authz/validate` with one permitted and one forbidden pair.
- Update `RESPONSIBILITIES.md`, still describing the original track split.


### 2026-09-10 — Epic 4 (`/users`) + shared Admin client; all six epics now have code

| Field | Value |
| --- | --- |
| Author | William Klein |
| Branch | `oauth` `grupo07-feat/keycloak-admin-client` (PR #11) and `grupo07-feat/users-api` (PR #12), both merged |
| Stories | 4.1–4.6 → review |
| Status | merged |

**Summary**
- **Extracted `KeycloakAdminClient`** from the roles module so users and roles share one Admin API implementation (agreed with the roles track first). The roles service dropped from 258 to 188 lines with no behaviour change.
- **The admin token is now cached** until shortly before the expiry Keycloak reports, and concurrent callers collapse onto a single authentication. Previously a token was fetched on *every* Admin API call — one `GET /roles` opened four upstream requests where two suffice.
- **Implemented the six `/users` routes** (stories 4.1–4.6) on top of that client.

**Paths touched**
- `backend/oauth/src/common/keycloak-admin.client.ts` — shared Admin API client (new)
- `backend/oauth/src/roles/keycloak-admin.service.ts` — now client-role logic only
- `backend/oauth/src/users/` — controller, service, types, exceptions (new)
- `backend/oauth/src/app.integration.spec.ts` — users coverage + route-shadowing guard
- `backend/oauth/README.md` — users section
- `_bmad-output/implementation-artifacts/sprint-status.yaml`, `CHANGELOGS.md`

**Decisions / notes for the next person**

- ⚠️ **Nothing has been exercised against a running Keycloak.** Docker never came up during this work, so all 253 tests are against a faked upstream. They prove the logic and the contracts, not the wiring. **Story 1.3 is the end-to-end proof and still needs a real `docker compose up` before delivery** — someone must actually walk the routes.
- **Do not add a second Admin API client.** Inject `KeycloakAdminClient` — it owns the admin token, the timeout and the failure mapping. Adding another would let the two drift.
- The client caches its token, so **integration tests must call `invalidateToken()` between cases**, otherwise a token cached by an earlier test leaks into the next one and changes which failure path runs.
- **`username` is the account identity.** The realm uses e-mail as username, so `PUT /users/:id` rejects it along with any other unsupported field. Password changes go through `PATCH`.
- Keycloak's user update **replaces the whole representation**, so the service reads the stored user and merges onto it. Writing only the changed fields would clear the others.
- `DELETE /users/:id` disables and never removes, and answers `204` even when the user was already disabled.
- `GET /users` with no query string returns **enabled users only**, per the brief. The filter is reapplied locally because some Keycloak setups ignore the query parameter.
- Users routes require the `administrator` client role, same as roles. Since the service authenticates as `KEYCLOAK_ADMIN`, Keycloak would never answer `403` by itself — that check is what makes the "known caller, not permitted" case reachable.
- Two roles tests fed `fetch` positionally; one of them was passing for the wrong reason (it failed on the admin token, not on the response it claimed to test). Both now route by URL.

**Next suggested step**
- **Run the stack for real** (`docker volume create constrsw-keycloak-data`, then `docker compose up`) and walk every route against the professor's Keycloak. That is story 1.3 and it is the last gap before delivery.
- Update `RESPONSIBILITIES.md`, still describing the original track split.


### 2026-09-09 — Story 1.1 + Bearer guard (Trilha Usuários) and a collision warning for `src/errors/`

| Field | Value |
| --- | --- |
| Author | William Klein |
| Branch | `oauth` `grupo07-feat/keycloak-config` (PR #6) and `grupo07-feat/bearer-guard` (PR #7), both merged |
| Stories | 1.1 → review; 4.1 task 1 (Bearer guard) → 4.1 in-progress |
| Status | merged |

**Summary**
- Story **1.1**: NestJS 11 scaffold, typed config bound to the professor env names, and the Keycloak URL builder (`tokenUrl`, `userInfoUrl`, `adminRealmUrl`, `realmPath()`, `adminPath()`). 29 tests.
- **Bearer guard**: task 1 of story 4.1, delivered ahead of the rest of Epic 4 so the roles and authz tracks would not wait on it. 28 tests.
- `sprint-status.yaml`: `1-1` → `review`; `epic-4` and `4-1` → `in-progress`.

**Paths touched**
- `backend/oauth/src/config/` — env binding with fail-fast, URL builder
- `backend/oauth/src/common/` — `bearer-auth.guard.ts`, `keycloak-token-verifier.service.ts`
- `backend/oauth/README.md` — environment contract, URL rule, authentication section
- `_bmad-output/implementation-artifacts/sprint-status.yaml`, `CHANGELOGS.md`

**Decisions / notes for the next person**

- ⚠️ **`src/errors/` has two implementations and will conflict.** `grupo07` already carries the roles track's `oa-exception.filter.ts` and `errors/index.ts`, while branch `grupo07-feat/tokens-authz` carries the story 3.1 version — a fuller one with `oa-error.mapper.ts` and `oa-error.ts`. Reconcile **before** merging the tokens branch, keeping the story 3.1 implementation as the contract one and making the roles routes work against it. Nobody's fault: the merge block meant all three tracks ran in parallel without integrating.
- **Do not read `process.env` in feature modules.** Inject `KeycloakSettingsService`; the `/auth` rule lives there and must not be duplicated. `adminUser` / `adminPassword` getters were added by the roles track and are the right place for them.
- **`BearerAuthGuard` never decides permissions.** A caller with a valid token and no roles passes it — a test pins this. It answers *who is calling*; `403` is the route's business. The roles track added a separate `AdministratorRoleGuard` for its own routes, which story 4.1 permits ("missing required client role"); note that holding the `administrator` client role is not the same as holding Keycloak Admin API rights, so the two can disagree.
- Guard verification uses **UserInfo**, not local JWT signature checking, so logout and disabled accounts take effect immediately. Bounded by a 5s timeout — Node's `fetch` has none by default and a hung Keycloak would otherwise hold every request open.
- An unreachable Keycloak answers **503**, not 401: a valid token must not be blamed for our outage.
- The guard throws standard Nest exceptions, so whichever OA exception filter wins the reconciliation above formats them with **no change to the guard**.
- **No live Keycloak call has been made from this track yet.** Story 1.1 forbids it, and Docker was not running here; the roles track's story 1.3 covers that proof.
- 📌 **`RESPONSIBILITIES.md` is out of date** — it still lists the original track split with no owners. The tracks are now: Usuários (William), Roles (Gabriel), Tokens & Autorização (Leonardo), with Juliano's part being the planning already delivered.

**Next suggested step**
- Reconcile `src/errors/` before the tokens branch merges.
- Continue Epic 4 (`POST /users` and the rest), reusing the Admin API client the roles track already wrote instead of adding a second one.


### 2026-09-09 — Restrict Roles operations to administrator

| Field | Value |
| --- | --- |
| Author | Gabriel Hoppe with AI |
| Branch | `grupo07-feat/roles-attributions` |
| Stories | Review follow-up for 5.1–5.8 |
| Status | in progress; commit/story separation still deferred |

**Summary**
- Added an authorization guard requiring the `administrator` role for every Roles and user-role assignment route.
- Users without that role now receive `403` through the global OA exception filter.
- Added unit coverage for administrator access and denied non-administrator access.

**Paths touched**
- `backend/oauth/src/common/administrator-role.guard.ts` — administrator authorization rule.
- `backend/oauth/src/roles/roles.controller.ts` — apply authentication and administrator authorization guards.
- `backend/oauth/README.md` — document the administrator-only rule.

**Decisions / notes for the next person**
- The caller authorization decision is now resolved: only `administrator` may manage roles and assignments.
- The service still uses the configured admin credentials for Keycloak Admin API calls after the caller passes both guards.
- `npm test -- --runInBand` passes with 70 tests and `npm run build` passes.

**Next suggested step**
- Re-run code review, then decide whether to address the deferred branch/commit separation.

### 2026-09-09 — Review fixes for Roles & Atribuições

| Field | Value |
| --- | --- |
| Author | Gabriel Hoppe with AI |
| Branch | `grupo07-feat/roles-attributions` |
| Stories | Review follow-up for 1.2, 1.3, 5.1–5.8 |
| Status | in progress; authorization decision intentionally open |

**Summary**
- Added the global OA exception filter and expanded tests for validation, upstream failures, malformed Keycloak responses, and role mappings.
- Separated PUT replacement semantics from PATCH merge semantics and added timeout/network handling for the Keycloak Admin API.
- Kept caller authorization unchanged for now, as explicitly decided in the session; story/commit separation is also deferred.

**Paths touched**
- `backend/oauth/src/errors/` — global OA error filter and tests.
- `backend/oauth/src/roles/` — Admin API resilience, PUT/PATCH semantics, and tests.
- `backend/oauth/src/app.module.ts` — register the global filter.
- `backend/oauth/README.md` — document PUT/PATCH and OA envelope behavior.

**Decisions / notes for the next person**
- Point 1 from the review, caller authorization before admin-backed role operations, remains intentionally unresolved and must not be treated as fixed.
- Point 7, separate branch/commit per story, remains deferred for now.
- `npm test -- --runInBand` passes with 68 tests and `npm run build` passes.

**Next suggested step**
- Re-run code review focusing on the remaining authorization decision and live Keycloak role-operation behavior.

### 2026-09-09 — Story 1.3 compose verification

| Field | Value |
| --- | --- |
| Author | Gabriel Hoppe with AI |
| Branch | `grupo07-feat/roles-attributions` |
| Stories | 1.3 |
| Status | review |

**Summary**
- Built the oauth image through the professor compose and started `keycloak` plus `oauth` without changing compose or environment files.
- Confirmed the oauth container is healthy and `GET http://localhost:8181/health` returns `{"status":"ok"}`.
- Confirmed `keycloak` resolves inside the oauth container and `KEYCLOAK_SERVER_URL` is injected as `http://keycloak:8080`.

**Paths touched**
- `backend/oauth/README.md` — compose volume, console/API URLs, and import/login contract notes.
- `_bmad-output/implementation-artifacts/1-3-verify-oauth-runs-on-professor-provided-compose.md` — verification checklist and status.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — Story 1.3 moved to `review`.

**Decisions / notes for the next person**
- Docker Desktop is running; image build and compose verification passed.
- The external volume `constrsw-keycloak-data` is present. Keycloak import behavior depends on whether the realm already exists in that volume.

**Next suggested step**
- Run code review for Stories 1.2, 1.3, and 5.1–5.8.

### 2026-09-09 — Roles & Atribuições implementation

| Field | Value |
| --- | --- |
| Author | Gabriel Hoppe with AI |
| Branch | `grupo07-feat/roles-attributions` |
| Stories | 1.2, 5.1–5.8 |
| Status | review; 1.3 pending Docker verification |

**Summary**
- Implemented the Roles & Atribuições module against the Keycloak Admin API: client-role CRUD, logical delete, and user assignment/removal.
- Added the documented health endpoint and Dockerfile required by the PDF track.
- Reused the published shared Bearer guard; the professor compose, `.env`, and realm were not changed.

**Paths touched**
- `backend/oauth/src/roles/` — role routes, validation, Keycloak Admin API integration, and tests.
- `backend/oauth/src/health/` — `GET /health` and HTTP test.
- `backend/oauth/Dockerfile`, `backend/oauth/.dockerignore` — image build inputs.
- `backend/oauth/README.md` — role representation, route pinning, canonical names, and inactive flag.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — stories moved to `review`; Epic 5 moved to `in-progress`.

**Decisions / notes for the next person**
- Roles are always client roles for the configured `oauth` client; realm roles are rejected.
- Logical delete sets `attributes.inactive=true` and never calls Keycloak DELETE.
- Assign is pinned to `POST /users/:id/roles`; unassign is `DELETE /users/:id/roles/:roleId`.
- `npm test -- --runInBand` passes with 62 tests and `npm run build` passes. Docker build could not run because the local Docker daemon is unavailable.

**Next suggested step**
- Start Docker and execute Story 1.3 against the professor compose, then run code review for the Roles stories.
### 2026-09-09 — Trilha Tokens & Autorização: login, refresh, OA errors, authz validate (stories 3.1, 2.1, 2.2, 3.2, 6.1-6.5)

| Field | Value |
| --- | --- |
| Author | AI (Claude Code) for Leonardo Gemin |
| Branch | oauth submodule `grupo07-feat/tokens-authz` (from `grupo07-feat/bearer-guard`, which carries stories 1.1 + Bearer guard not yet merged to `grupo07`) |
| Stories | 3.1, 2.1, 2.2, 3.2, 6.1, 6.2, 6.3, 6.4, 6.5 (all of Trilha B / "Tokens & Autorização" per `backend/oauth/Trilhas-Grupo07.pdf`) |
| Status | in progress → review (all 9 stories; code + tests done, live Keycloak verification still pending) |

**Summary**
- `src/errors/`: shared `{ error_code, error_description, error_source, error_stack }` envelope, `OaErrorMapper`/`OaException`, global exception filter registered in `main.ts`. `OA-xxx` local code family documented in the oauth README for Epics 4-6 to reuse.
- `src/auth/`: `POST /login` (form-data/urlencoded, ignores brief-shaped `client_id`/`grant_type`, password grant, `200`, `referesh_expires_in` spelling preserved) and `POST /refresh` (reuses the same `KeycloakTokenClient`, `grant_type=refresh_token`). Both throw via the OA mapper directly, so 3.2's wiring was already satisfied by construction — added dedicated envelope-shape tests to prove it rather than leaving it assumed.
- `src/authz/`: `POST /authz/validate` — Bearer-guarded, JSON `{ resource }` restricted to the eight Story 6.2 resource names, decided purely by Keycloak's UMA-ticket grant on the token endpoint (`audience=oauth`, `permission=<resource>`, caller's own access token). `200` on permit, `403` OA envelope on deny; no local role-to-resource table.
- Stories 6.1-6.4 verified by **direct inspection of `constrsw.json`** (not a live Admin Console session — Docker is not installed in this environment): 4 client roles, 8 resources with URLs, 4 role policies (incl. `student-policy`, applied to nothing), 3 resource permissions with the exact hierarchical `applyPolicies` `keycloak-authz.md` describes. No gaps found; nothing added or edited in the professor's realm file.

**Paths touched**
- `backend/oauth/src/errors/*`, `backend/oauth/src/auth/*`, `backend/oauth/src/authz/*` — new modules
- `backend/oauth/src/app.module.ts`, `backend/oauth/src/main.ts` — wire `AuthModule`, `AuthzModule`, global `OaExceptionFilter`
- `backend/oauth/README.md` — login/refresh/validate contracts, OA envelope + code table, 6.1-6.4 verification record
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — epics 2/3/6 → `in-progress`; their stories → `review`

**Decisions / notes for the next person**
- Branched off `grupo07-feat/bearer-guard`, not `grupo07` directly — `grupo07`'s tip (`48b1723`) predates story 1.1 and the Bearer guard, which this track's code depends on (`KeycloakSettingsService`, `BearerAuthGuard`). Once 1.1/bearer-guard merges to `grupo07`, this branch should rebase before its own PR.
- Used one branch for the whole track with **one commit per story** (9 commits) rather than 9 separate branches — a deliberate deviation from the PDF's "uma branch por story" for review overhead, agreed with the repo owner this session.
- 6.1-6.4 are documented as verified against the **file** that will be imported, not a running realm — the README flags each one as still needing a live Admin Console check once someone actually runs `docker compose up` with a fresh `constrsw-keycloak-data` volume.
- `npm test` (153 tests) and `npx tsc --noEmit` both pass on the final state of the branch.

**Next suggested step**
- Code-review this branch (fresh context), then rebase onto `grupo07` once 1.1/bearer-guard lands and open the PR.
- Someone with Docker running should re-confirm 6.1-6.4 in the Admin Console and run at least one live `/authz/validate` call per Story 6.5 AC #6 before marking Epic 6 `done`.

### 2026-09-09 — Contract review against the T1 brief (authz matrix, login contract, user listing)

| Field | Value |
| --- | --- |
| Author | AI (Claude Code) for William Klein / Grupo 07 |
| Branch | `base` `grupo07` |
| Stories | 6.4, 6.5 (contract/AC correction — no implementation) |
| Status | done |

**Summary**
- Resolved the divergence flagged in Story 6.4 Dev Notes **in favour of the professor's `constrsw.json`**, not the Moodle brief. Test oracle for 6.5 is now the hierarchical matrix.
- Recorded the brief's original disjoint table as a historical note so the group can defend the decision if questioned.
- Marked the multi-policy `applyPolicies` as **intentional configuration** — previously an implementer could have read them as "gaps" and deleted them from the professor's realm.

**Paths touched**
- `_bmad-output/specs/spec-grupo07-keycloak-oauth/keycloak-authz.md` — real permission bindings, new § "Divergence from the T1 brief", corrected matrix quick check
- `_bmad-output/specs/spec-grupo07-keycloak-oauth/SPEC.md` — CAP-5, CAP-6, constraints, assumptions
- `_bmad-output/planning-artifacts/epics.md` — FR15, FR16, NFR9, Epic 6 preamble, Story 6.4/6.5 ACs
- `_bmad-output/implementation-artifacts/6-4-resource-based-permissions.md` — AC #1, Dev Notes, Task 4
- `_bmad-output/implementation-artifacts/6-5-validate-...-services.md` — AC #1, AC #6, Task 3
- `CHANGELOGS.md` — this entry

**Decisions / notes for the next person**
- **The realm is the oracle, not the brief.** Evidence: `constrsw.json` committed by the professor 2026-09-02 (`51423d2`) for this semester, alongside `10e6838` "Ajusta nome do serviço oauth" and `1791eab` the same day; the brief's screenshots still show realm `constr-sw-2022-2` / client `grupo1` (2022 re-upload).
- Verified directly in `constrsw.json`: all three permissions are `decisionStrategy: AFFIRMATIVE`; `coordinator-permissions` applies `coordinator-policy` + `administrator-policy`; `professor-permissions` applies professor + coordinator + administrator. Effective grants: administrator → all 8; coordinator → courses, classes, lessons, reservations; professor → lessons, reservations; student → none.
- **Do not remove those extra policies.** `SPEC.md` forbids editing the professor's realm, and doing so would be "fixing" his current config to match 2022 material.
- Story 6.5 code is unaffected — it delegates to Keycloak Authorization Services, so it is correct under either matrix. Only test expectations changed.
- ⚠️ **No implementation code exists yet.** Branch `grupo07` of submodule `backend/oauth` contains only `README.md` (1 file; other groups have 11–105). The 2026-09-08 entry below reports Story 1.1 as implemented and `sprint-status.yaml` still lists `1-1` as `ready-for-dev` — confirm with the author whether that Nest scaffold was ever committed before anyone redoes it.
- Question to the professor about this divergence was drafted but **not sent** — group chose to follow the realm without waiting.

**Login contract decisions (same review)**
- **Body:** the brief's form lists `client_id` and `grant_type`; the SPEC required username+password only. Now the API **accepts and ignores** those extra fields instead of rejecting them, so a brief-shaped request still succeeds. Credentials sent to Keycloak always come from env — a client-supplied value is never trusted, used, or logged. Story 2.1 explicitly forbids `forbidNonWhitelisted` on the login DTO.
- **Status code:** login now returns **`200`**, not `201`. The brief leaves this route's `Response codes` as literal `???`, nothing is created, and Keycloak itself answers 200. ⚠️ The earlier `201` came from group-supplied material — if Juliano has a professor source that specifies 201, this is a one-line revert in `SPEC.md` / `oauth-api.md` / story 2.1.
- **`GET /users` default:** with no query string the list now returns **enabled users only**, matching the brief's "todos os usuários cadastrados e habilitados". `?enabled=false` shows disabled ones.
- **Roles routes (Epic 5) kept as-is.** They are not in the T1 brief page we hold, but the brief says "no mínimo, as seguintes rotas", and they do not conflict with the professor's realm (the four client roles they manage are the ones `constrsw.json` ships). Flagged for Juliano to confirm the source.

**Next suggested step**
- Confirm the Story 1.1 code situation; fill owner names in `RESPONSIBILITIES.md`; then start Track A (1.1 → 1.2).

### 2026-09-08 — Responsibilities split (3 tracks) + AI context prompt

| Field | Value |
| --- | --- |
| Author | AI (Cursor) for EduardoArruda / Grupo 07 |
| Branch | `base` `grupo07` |
| Stories | Planning / process only (no new story implementation) |
| Status | done |

**Summary**
- Added `RESPONSIBILITIES.md`: Tracks A (Epics 1–3), B (Epic 4), C (Epics 5–6) for assigning 3 members.
- Added `AI-CONTEXT-PROMPT.md`: copy-paste prompt for other AIs (project, architecture, BMAD, changelogs, responsibilities).

**Paths touched**
- `RESPONSIBILITIES.md` — 3-way implementation ownership
- `AI-CONTEXT-PROMPT.md` — handoff prompt for teammate AIs
- `CHANGELOGS.md` — this entry

**Decisions / notes for the next person**
- Fill owner names in `RESPONSIBILITIES.md` before coding in parallel.
- Track A should stay ahead of B/C (OA mapper + Nest foundation).

**Next suggested step**
- Assign Track A/B/C owners; each opens a chat with `AI-CONTEXT-PROMPT.md` filled in.

### 2026-09-08 — BMAD planning + Story 1.1 scaffold + story batch + Keycloak architecture

| Field | Value |
| --- | --- |
| Author | AI (Cursor) for EduardoArruda / Grupo 07 |
| Branch | `base`: `grupo07` (+ professor `main` merge); `backend/oauth`: `grupo07` |
| Stories | Planning (SPEC/epics/sprint); Story **1.1** implemented (status **review**); Stories **1.2–6.5** story files only (**ready-for-dev**) |
| Status | Planning done; 1.1 awaiting code-review; implementation of 1.2+ not started in this session’s final state |

**Summary**
- Locked Keycloak/oauth-only SPEC (`spec-grupo07-keycloak-oauth`) — professors/Postgres deferred.
- Created epics (6) + 26 stories; sprint-status; merged professor `docker-compose.yml` / `.env` / `constrsw.json` from `main`.
- Aligned plan to professor stack: Story **1.3 = verify** (oauth already enabled); Epic **6.1–6.4 = verify-first** on import.
- Fixed `.env` usability: literal `KEYCLOAK_SERVER_URL=http://keycloak:8080`, `OAUTH_INTERNAL_HOST=oauth`.
- Implemented NestJS Story **1.1** (config + URL builder + tests + README env docs) in `backend/oauth`.
- Batch-created **25** remaining BMAD story markdown files under `_bmad-output/implementation-artifacts/` (no extra app code for 1.2–6.5).
- Added this `CHANGELOGS.md` and Keycloak-only architecture doc.

**Paths touched**
- `_bmad-output/specs/spec-grupo07-keycloak-oauth/` — SPEC + companions + memlog
- `_bmad-output/planning-artifacts/requirements-grupo07-t1-oauth-professors.md` — requirements pack
- `_bmad-output/planning-artifacts/epics.md` — epics/stories
- `_bmad-output/planning-artifacts/architecture-grupo07-keycloak-oauth.md` — Keycloak architecture (new)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — tracker
- `_bmad-output/implementation-artifacts/1-1-*.md` … `6-5-*.md` — story files
- `backend/oauth/` — Nest scaffold + Keycloak settings (Story 1.1)
- `.env` — `KEYCLOAK_SERVER_URL` / `OAUTH_INTERNAL_HOST` fixes (no secret rotation)
- `CHANGELOGS.md` — this file

**Decisions / notes for the next person**
- Contract: SPEC + `oauth-api.md` + `keycloak-authz.md` win over Keycloak README JSON login curls (T1 = form-data, login **201**, field `referesh_expires_in`).
- Do **not** invent root compose/`.env`; do **not** use divergent `backend/oauth/keycloak/realm-export.json`.
- Canonical realm import: `infrastructure/dev.local/services/keycloak/constrsw.json`.
- Faster implementation: epic-sized chats OK; story files already exist — no more create-story required for 1.2–6.5.
- Next BMAD step for 1.1: `bmad-code-review` → mark **done**, then implement **1.2** (Dockerfile + `GET /health`).

**Next suggested step**
- Code-review Story 1.1; then implement Epic 1 remaining (1.2 → 1.3) from existing story files.

---
