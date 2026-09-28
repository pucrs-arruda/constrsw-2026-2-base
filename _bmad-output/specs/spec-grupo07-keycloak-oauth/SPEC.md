---
id: SPEC-grupo07-keycloak-oauth
companions:
  - oauth-api.md
  - keycloak-authz.md
sources:
  - ../planning-artifacts/requirements-grupo07-t1-oauth-professors.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability only — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Grupo 07 — Keycloak OAuth API (T1 + authz)

## Why

**Mandate:** ConstrSW 2026/2 T1 requires Grupo 07 to ship an `oauth` identity gateway that consumes Keycloak’s REST/OIDC APIs for users, roles, tokens, and resource authorization in realm `constrsw` / client `oauth`. Professor-supplied compose and `.env` are the runtime substrate; this work exists so the group can plug a Dockerized API into that stack and demonstrate login, user/role administration, and role→resource validation without expanding into domain services or the full course mesh.

## Capabilities

- **CAP-1**
  - **intent:** A caller can exchange username/password for Keycloak tokens through the oauth API without sending client credentials.
  - **success:** `POST /login` with form-data `username`+`password` returns `200` and JSON `token_type`, `access_token`, `expires_in`, `refresh_token`, `referesh_expires_in`; invalid structure → `400`; bad credentials → `401`.

- **CAP-2**
  - **intent:** An authenticated caller can create, list (optionally by `enabled`), get, update, change password, and soft-delete Keycloak users via the oauth API.
  - **success:** Routes under `/users` match codes and payloads in `oauth-api.md`; create returns Keycloak `id` from `Location`; delete disables the user (`204`); email usernames fail RFC 5322 validation with `400`; duplicate username → `409`.

- **CAP-3**
  - **intent:** An authenticated caller can manage roles and assign/unassign roles to users.
  - **success:** Full roles CRUD plus assign/unassign endpoints behave per `oauth-api.md`; `DELETE` is logical delete; unauthorized/missing token cases return `401`/`403`.

- **CAP-4**
  - **intent:** Every oauth API error surfaces a uniform diagnostic body for clients and graders.
  - **success:** Error responses use `{ error_code, error_description, error_source, error_stack }` with `error_source` such as `OAuthAPI`; `error_code` relays Keycloak’s code unless a brief-specific code applies; `error_stack` chains to the root cause.

- **CAP-5**
  - **intent:** Realm `constrsw` client `oauth` exposes the B.2 authorization model (roles, resources, role policies, resource permissions).
  - **success:** Client roles `administrator`, `coordinator`, `professor`, `student`; eight resources with URLs; policies/permissions present — **verified on the professor-imported realm** (`constrsw.json`) with gap-fill only; not a group-owned compose/realm-JSON deliverable. The realm's **multi-policy** permission bindings are authoritative over the brief's single-policy table (group decision 2026-09-09, see `keycloak-authz.md`); they are **not** gaps to "correct".

- **CAP-6**
  - **intent:** A caller can ask whether an access token grants access to a named authorization resource.
  - **success:** Validate endpoint calls **Keycloak Authorization Services** (not a local role matrix) and returns `200` when permitted and `403` when forbidden (`401` if token missing/invalid); outcomes must match the **realm-derived** matrix in `keycloak-authz.md` (hierarchical: `administrator` ⊇ `coordinator` ⊇ `professor`; `student` → none), not the brief's disjoint table.

- **CAP-7**
  - **intent:** A caller can obtain new tokens from a valid `refresh_token` without re-entering password.
  - **success:** Refresh route posts Keycloak `grant_type=refresh_token` with server-side client credentials and returns a token payload usable like login; rejected refresh yields `401` (or mapped Keycloak failure via CAP-4).

- **CAP-8**
  - **intent:** The oauth service runs as a container built from `backend/oauth` and attaches to the professor-provided compose/`.env`.
  - **success:** Dockerfile builds the API image (with `GET /health`); professor compose already defines/enables `oauth` — group **verifies** build/run; runtime reads `KEYCLOAK_SERVER_URL`, `KEYCLOAK_REALM`, `KEYCLOAK_CLIENT_ID`, `KEYCLOAK_CLIENT_SECRET` (and related vars) from the provided `.env` — no invented compose file as a group deliverable.

## Constraints

- Implement on the **group branch** inside submodule `backend/oauth`; add the **Dockerfile** there.
- Realm **`constrsw`**, client **`oauth`**; email is username.
- Login body: clients send **username + password**; the API **also accepts and ignores** `client_id` / `grant_type` (which the T1 brief lists in the form) so a brief-shaped request still succeeds. `client_id`, `client_secret` and `grant_type` sent to Keycloak **always** come from env — a client-supplied value is never trusted, used, or logged.
- Login success status is **`200`** — nothing is created, and the T1 brief leaves `Response codes` as `???` for this route (group decision 2026-09-09; see `oauth-api.md`).
- Preserve response field spelling **`referesh_expires_in`** as in the brief.
- Prefer Keycloak **26 URL style without `/auth`** (`…/realms/{realm}/…`); if professor base URL includes `/auth`, use that base instead.
- Soft-delete users (and logical delete roles) — disable / mark inactive in Keycloak, do not hard-delete unless brief requires otherwise.
- Authz roles are **client roles** on `oauth` (filter by client when binding policies).
- Canonical role names for the permission matrix: **`administrator`**, **`coordinator`**, **`professor`**, **`student`**. Confirmed to match the imported realm; if a future import diverges on **role names**, stop and realign before coding policies.
- CAP-6 **must** evaluate via **Keycloak Authorization Services**; the **realm-derived** matrix in `keycloak-authz.md` is the expected-outcome oracle, not a local decision engine and not the brief's table.
- Where the professor's `constrsw.json` and the Moodle brief disagree, **the realm wins** (group decision 2026-09-09, rationale in `keycloak-authz.md`). Never edit the professor's realm to make it match the brief.
- `.env` and `docker-compose.yml` are **professor-provided**; plug in — do not treat inventing compose as a deliverable.
- Authorization resources/policies/permissions and the validate endpoint are **in MVP** for this SPEC.

## Non-goals

- Professors domain API, PostgreSQL, Astah schemas/examples (requirements section C).
- Architecture spine / system architecture artifacts.
- Full course mesh services (classes, courses, lessons, rooms, etc. as implemented APIs).
- MongoDB, and observability stacks other than the oauth Prometheus and OpenTelemetry work owned by sibling spec `spec-grupo07-oauth-observability`. This kernel does not define that work.
- Custom BMAD agents.
- Inventing or owning the root `docker-compose.yml` / `.env` contents.

## Success signal

Against the professor-provided Keycloak stack: login returns `200` with access and refresh tokens; user and role routes enforce Bearer auth and the OA error shape; CAP-5 authz objects are verified on imported `constrsw`/`oauth`; validate returns `200`/`403` correctly for at least one permitted and one forbidden role→resource pair; refresh yields a usable new access token; the oauth image builds and runs healthy on the provided compose.

## Assumptions

- Professor compose is on `main`: Keycloak **26.0.1** via `infrastructure/dev.local/services/keycloak`, realm import `constrsw.json`, external volume `constrsw-keycloak-data`, console `:8081`, oauth API `:8181`.
- Keycloak public/internal API base omits `/auth` (`KEYCLOAK_SERVER_URL=http://keycloak:8080`) — **verified against professor `.env`**.
- Client secret and Admin API credentials needed for user/role CRUD are supplied via the provided `.env`.
- CAP-5 objects ship complete in `constrsw.json` (verified 2026-09-09: 4 client roles, 8 resources + URLs, 4 role policies, 3 resource permissions, authz enabled); implementation **verifies** and gap-fills only what is genuinely absent; CAP-6 still evaluates via Authorization Services.
- CAP-6 path/body default: `POST /authz/validate` with Bearer token and JSON `{ "resource": "<name>" }` (one of the eight resource names).
- CAP-7 path default: `POST /refresh` with form-data `refresh_token`; success status **`200`**, same as login.
- Exact URL strings on the eight Keycloak resources may follow the import; otherwise use stable path-like URLs documented in `keycloak-authz.md`.
- T1/SPEC login contract (form-data, `referesh_expires_in` spelling) wins over illustrative JSON curls in the Keycloak README.