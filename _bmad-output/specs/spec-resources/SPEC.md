---
id: SPEC-resources
companions:
  - schema.sql
  - data-dictionary.md
  - openapi.yaml
  - bff-openapi.yaml
  - bff-read-model.md
  - change-impact.md
  - ../../planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-08-24/DESIGN.md
  - ../../planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-08-24/EXPERIENCE.md
  - ../../planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
sources: []
---

> **Revision v1.3 — 2026-10-28.** Removes `assignedTo`, `startedAt`, and the `IN_PROGRESS` state: an Occurrence goes `OPEN → RESOLVED` once. Audit actors are `reportedBy` and `resolvedBy`. Occurrence PATCH is resolve-only again.

> **Revision v1.1 — 2026-10-27.** Expands `resource_type` and adds the audit actors `reportedBy`, `assignedTo`, and `resolvedBy`.

> **Canonical contract.** This SPEC and every file in `companions:` form the complete resources-context contract. The PRD, UX, and architecture spines remain authoritative for their own domains; this SPEC restates and, where Model A changes the pair, supersedes the resources-specific rules. `change-impact.md` lists the upstream edits; no upstream artifact was edited in this run.

# Resources — Reservable Assets and Occurrences

## Why

Closed CRAS needs a master record for every physical reservable asset, separate from rooms, so the reservations context can decide eligibility from a stable resource ID and staff can record what is wrong with a unit without inventing a parallel inventory system. The resources service is currently an empty Git submodule. The original PRD pair Resource/InventoryItem treated InventoryItem as a nested item list; Model A makes each Resource one physical unit and replaces InventoryItem with Occurrence, the only entity that carries fault and damage history. Without this contract, the resources context is undefined and reservations would be forced to invent its own eligibility rule.

## Scope

**In scope:** Resource master data (create, list/filter, read aggregate, update); Occurrence recording and resolution; the active reservation-gate contract; the `cras_resources` PostgreSQL schema; the resources REST contract and JWT resource-server behavior; the resources BFF module and its read model; the UX-S3 Resource zone contract; the upstream change-impact list.

**Out of scope:** reservations, availability, occupancy, conflict detection, and the FR-23 write path; Room data; inventory quantities, stock, bundles, component tracking, serial numbers, cost, or location; Resource or Occurrence deletion; reopening a resolved occurrence; notifications, email, webhooks, event bus, or maintenance scheduling; per-occurrence actor audit; Student or roster data; ownership of UX-S3 (OQ-1); editing the PRD, UX, or architecture sources.

## Glossary

- **Resource** — one physical reservable unit of equipment (projector, kit, computer, audio-visual unit, other). Not a Room and not a quantity.
- **Occurrence** — a fault, damage, missing, or other event attached to exactly one Resource, carrying its own lifecycle, timestamps, and audit actors. Replaces InventoryItem. The 1–N secondary class of the resources pair.
- **Model A** — the decision that one Resource row is one physical reservable unit; no quantity, stock, bundle, or component model.
- **code** — the canonical business identifier of a Resource. Required, unique, uppercase, immutable, 3–32 characters, pattern `^[A-Z0-9]+(-[A-Z0-9]+)*$`.
- **active** — the master-data flag and the sole reservation gate. An inactive Resource is not eligible for a new Reservation (FR-23).
- **open occurrence** — an Occurrence whose status is `OPEN` (not started, not resolved). A non-`RESOLVED` occurrence never blocks reservations by itself.
- **resolve** — the one-way transition `OPEN → RESOLVED` that stores a resolution, a server-set `resolvedBy`, and a server-set `resolvedAt`.
- **audit actor** — `reportedBy` or `resolvedBy`: an employee UUID taken from the identity fragment. Both are server-set from the JWT and never accepted in a body.
- **Resource summary** — a Resource without its occurrences. **Resource aggregate** — a Resource plus its occurrence collection.
- **funcionário** — the realm role allowed to write the resources context. `coordenador`, `professor`, and `student` are read-only here.
- **resource-server** — the service validates a Keycloak JWT via JWKS and enforces roles; the browser never calls it directly.
- **BFF** — the browser-facing NestJS composition layer. It owns the session cookie and may add read-model fields such as `openOccurrenceCount`.
- **bare collection** — every JSON collection is a top-level array (`[...]`); there is no `items` envelope and no pagination envelope in v1.
- **FR-22 / FR-23** — the source PRD requirements for Resource registration and Resource reservation. FR-22 is rewritten by Model A; FR-23 semantics are preserved.

## Invariants

- **INV-1 — Model A.** Each `resources` row is exactly one physical reservable unit. No quantity, stock, bundle, component, or location columns exist. `HEALTH_KIT` means one reservable kit, not a kit plus component rows.
- **INV-2 — Pair.** Resource 1–N Occurrence. Every `occurrences.resource_id` references an existing Resource; there is no orphan and no `inventory_items` entity or table.
- **INV-3 — Code.** `code` is required, unique, uppercase, immutable after create, 3–32 characters, and matches `^[A-Z0-9]+(-[A-Z0-9]+)*$`. The API trims and uppercases input; invalid values are a 422. A retired code remains reserved.
- **INV-4 — Master data.** `name` is trimmed, 1–120 characters, non-blank. `type` is one of `PROJECTOR`, `HEALTH_KIT`, `COMPUTER`, `NOTEBOOK`, `CAMERA`, `MICROPHONE`, `DISPLAY`, `CABLE`, `ADAPTER`. There is no `ROOM` type (Room is another context) and no `OTHER` fallback: an unlisted kind of equipment requires an enum migration.
- **INV-5 — Active is the gate.** `active` defaults to `true` and is the only Resource flag that gates reservations. No occurrence count, priority, or status gates a reservation.
- **INV-6 — Lifecycle.** An Occurrence is created `OPEN` with `reportedBy` taken from the token and may transition once to `RESOLVED`. There is no intermediate state. `RESOLVED` is terminal: no reopen, delete, cancel, or edit path. Multiple `OPEN` occurrences per Resource are allowed.
- **INV-7 — State consistency.** `RESOLVED` requires a non-blank `resolution`, a non-null `resolvedBy`, and a non-null `resolvedAt`; `OPEN` requires all three to be null. `resolvedAt` is never earlier than `createdAt`.
- **INV-8 — Occurrences do not gate.** A non-`RESOLVED` occurrence does not change `active`, does not block reservations, and does not auto-deactivate a Resource. Resolving an occurrence does not reactivate a Resource. Deactivating a Resource does not resolve its occurrences.
- **INV-9 — Tags.** `tags` is a set of 0–10 lowercase tags, each 1–30 characters matching `^[a-z0-9]+(-[a-z0-9]+)*$`, unique and sorted in JSON. It is stored 1NF in `resource_tags(resource_id, tag)` and exchanged as an array. A PATCH replaces the whole set, in the same transaction. The list filter is an exact match on the normalized tag. At most 10 per resource, enforced by API validation and by `trg_resource_tags_max`.
- **INV-10 — Identity.** Resource and Occurrence IDs are server-generated UUID v4 values, emitted lowercase. Clients never supply IDs.
- **INV-11 — Time.** `createdAt` is server-set and is report time, not event time. `updatedAt` is server-set on every update. `resolvedAt` is server-set on resolve. All timestamps are RFC 3339 UTC in JSON and `TIMESTAMPTZ` in PostgreSQL. No client-supplied timestamps are accepted.
- **INV-12 — Wire shape.** JSON properties are camelCase; enum values are uppercase; the removed `dataHora` and InventoryItem fields (`identifier`, `estado`) never appear. `status` is never client-supplied: the PATCH body carries only the `resolution` and the server derives the state, the actor, and the timestamps.
- **INV-13 — Collections.** Every collection, including the nested occurrence collection, is a top-level array (`[...]`). No pagination in v1. Ordering is deterministic: resources by `code` ascending; occurrences by `createdAt` descending, then `id` descending.
- **INV-14 — Access.** Writes require `funcionario`. Reads require any authenticated realm role (`funcionario`, `coordenador`, `professor`, `student`). An occurrence write token must also carry `employeeId`; a `funcionario` without it receives 403 `EMPLOYEE_IDENTITY_REQUIRED`, because every occurrence write records an audit actor. Resource writes do not require the claim. `/health` is the only anonymous route. The browser talks only to the BFF.
- **INV-15 — Refusals.** Invariant refusals use RFC 9457 `application/problem+json`, HTTP 409, `code` equal to `FR-22`, and `type` equal to `urn:closed-cras:recusa:FR-22`. A `reason` extension discriminates the condition. Shape and format errors use 422 with `code: VALIDATION` and an `errors[]` array. No ad hoc `{ "message": ... }` envelope exists.
- **INV-16 — Retention.** There is no Resource or Occurrence DELETE route and no soft-delete column. The occurrence FK is `ON DELETE RESTRICT`. `active=false` is retirement; occurrence history is retained. Deletion is an operational database decision outside this contract.
- **INV-17 — Context boundary.** Reservations reads only `Resource.id` and `Resource.active`; it does not read occurrences, and resources exposes no availability or occupancy route. The BFF may expose `openOccurrenceCount` as a warning, but it never changes eligibility.
- **INV-18 — Schema authority.** `schema.sql` applied to an empty `cras_resources` database is the authoritative shape. Tags are stored in `resource_tags` (1NF); there is no array column and no alternative model.
- **INV-19 — Audit.** `reportedBy` is server-set from the JWT `employeeId` at create and is immutable. `resolvedBy` is server-set from the token on resolve. Clients never supply either. Employee UUIDs are stored without a cross-context foreign key; the resources context never calls the employees context.
- **INV-20 — Type is descriptive.** Every `resource_type` value is a classification label; none affects eligibility, filtering semantics, reservation gating, or the occurrence lifecycle. `active` remains the only gate (INV-5).

## Capabilities

- **CAP-1 — Create Resource**
  - **intent:** Staff can register one physical reservable unit so reservations and other contexts can reference a stable resource ID.
  - **success:** `POST /v1/resources` with `code`, `name`, and `type` returns 201 with a `Location` header; the resource has `active=true`, `tags=[]`, server-set timestamps, and a subsequent `GET` by that ID returns the same resource.

- **CAP-2 — List and filter Resources**
  - **intent:** Authenticated callers can find resources by code, type, active state, and tag without paginating or joining other contexts.
  - **success:** `GET /v1/resources` returns a JSON array; `code`, `type`, `active`, and `tag` filters combine with AND; the order is `code` ascending; no pagination fields exist.

- **CAP-3 — Read Resource aggregate**
  - **intent:** Authenticated callers can inspect one resource together with its full occurrence history.
  - **success:** `GET /v1/resources/{resourceId}` returns the resource and `occurrences` ordered newest first; an unknown ID returns 404 with `reason=RESOURCE_NOT_FOUND`.

- **CAP-4 — Update Resource master data**
  - **intent:** Staff can correct a resource's name, type, active state, and tags without changing its stable code.
  - **success:** A partial PATCH persists only the supplied fields; `code` remains byte-identical; a body containing `code`, an unknown field, or no fields returns 422.

- **CAP-5 — Record Occurrence**
  - **intent:** Staff can record a malfunction, damage, missing, or other event against a resource so the unit's history is not lost.
  - **success:** `POST /v1/resources/{resourceId}/occurrences` returns 201 with `Location`, `status=OPEN`, default priority `MEDIUM`, null `resolution` and `resolvedAt`, `reportedBy` equal to the caller's employee, and a server-set `createdAt`.

- **CAP-6 — Resolve Occurrence**
  - **intent:** Staff can close an open occurrence with an explanation, once, so the history shows who reported, who resolved, and what was done.
  - **success:** PATCH with `{resolution}` returns 200 with `status=RESOLVED`, the non-blank resolution, `resolvedBy`, and `resolvedAt` not earlier than `createdAt`. A second resolve returns 409 `OCCURRENCE_ALREADY_RESOLVED`.

- **CAP-7 — Enforce the reservation-gate contract**
  - **intent:** The resources context exposes one unambiguous eligibility signal so reservations never has to interpret occurrence data.
  - **success:** `active=false` makes the reservations contract refuse the resource under FR-23; an `OPEN` occurrence on an `active=true` resource does not block; resolving it does not reactivate; deactivating does not resolve.

- **CAP-8 — Authenticated access and identity gateway**
  - **intent:** The service behaves as a resource-server so the mesh has one JWT and role model.
  - **success:** A request without a valid JWT returns 401; a write without `funcionario` returns 403; an authenticated read returns 200; `GET /v1/identidade/me` returns the fragment schema; `GET /health` is anonymous.

- **CAP-9 — BFF read model**
  - **intent:** The browser can use the resources domain through the BFF without joining the domain API directly or seeing an orphaned aggregate.
  - **success:** The BFF module exposes the same routes with cookie auth and adds `openOccurrenceCount` to list and detail; the count equals the number of `OPEN` occurrences; problem+json passes through unchanged.

- **CAP-10 — UX-S3 Resource zone**
  - **intent:** Staff can operate the Resource zone of UX-S3 as a master-detail surface and understand the occurrence history at a glance.
  - **success:** Selecting a resource shows its occurrences; create and resolve actions work; no occurrence can be created without a selected resource; status and priority are visible; 409 conditions render a refusal banner; no roster appears.

## Constraints

- **C-1 — Database.** PostgreSQL 18.6, database `cras_resources`, one database for this context. `schema.sql` is the DDL of record.
- **C-2 — Conventions.** Snake_case tables and columns; `UUID` IDs; `TIMESTAMPTZ`; JSON camelCase; uppercase enum wire values; UTF-8.
- **C-3 — Routes.** Only the routes listed in this SPEC exist. No DELETE Resource, no DELETE Occurrence, no `/inventory-items`, no `/availability`, no `/occupancy`.
- **C-4 — Stack.** The service may use Spring Boot 4.1.x or NestJS 11.2.x with Express 5.2.x per AD-3. OpenAPI 3.1 is the contract; the implementation stack does not change the wire shape.
- **C-5 — Identity.** Keycloak realm `closed-cras`; JWT Bearer validated via JWKS; four realm roles; the BFF is the browser's identity gateway and propagates the user token.
- **C-6 — Errors.** RFC 9457 problem+json; invariant refusals are 409 with `code=FR-22`; shape validation is 422 with `code=VALIDATION`; `type` follows the mapping in this SPEC.
- **C-7 — No pagination.** List and aggregate responses return every matching item. There is no `page`, `pageSize`, `limit`, `offset`, `total`, or `next` field.
- **C-8 — Tags.** Tags live in `resource_tags(resource_id, tag)` with `PRIMARY KEY (resource_id, tag)`, `ON DELETE CASCADE`, lowercase/format checks, a 10-tag trigger, and a B-tree index on `tag`. No array column exists. The API still exchanges `tags` as a sorted array.
- **C-9 — No deletion.** There is no delete or restore operation. `active=false` is the retirement mechanism; history remains.
- **C-10 — BFF boundary.** The resources context enables no CORS. Only the BFF enables CORS for the frontend origin. The resources BFF module lives at `backend/bff/src/modules/resources/`.
- **C-11 — UX ownership.** UX-S3 ownership remains OQ-1. This SPEC fixes the Resource zone's data and behavior, not which group implements the surface.
- **C-12 — Source discipline.** The PRD, UX, and architecture sources are not edited here. `change-impact.md` is the handoff; this SPEC wins for resources-specific conflicts until those sources are updated.

## Non-goals

- No `inventory_items` entity, table, endpoint, or field. InventoryItem is replaced by Occurrence.
- No quantity, stock, bundle, component, serial-number, cost, acquisition, or location model. One Resource is one unit.
- No Resource or Occurrence DELETE, soft delete, archive, restore, reopen, cancel, or edit-after-resolve.
- No automatic reservation blocking, automatic deactivation, or automatic reactivation from occurrence state.
- No reservations, availability, occupancy, conflict detection, or calendar endpoints in this context. FR-23 and FR-29 stay in reservations/lessons/BFF.
- No notifications, email, webhooks, event bus, SLA timers, escalation, or maintenance scheduling.
- No per-occurrence actor audit (`reportedBy`, `resolvedBy`) in v1; see open questions.
- No pagination, free-text search, arbitrary sorting, multiple-tag AND/OR filters, or `occurredAt` in v1.
- No Room fields, Student data, roster, or LGPD-nominative data in this context.
- No direct browser access, CORS, or `keycloak-js` in the resources context.
- No ownership decision for UX-S3; OQ-1 remains with the class/instructor.

## Success signal

The DDL model and the contract tests demonstrate the full loop: a `funcionario` creates a `PROJECTOR`, records an `OPEN` `MALFUNCTION` with `reportedBy` from the token, the BFF list reports `openOccurrenceCount=1`, the same staff member resolves it so the count becomes `0` with `resolvedBy` and `resolvedAt` set, and a second resolve returns 409. In parallel, an `active=true` resource with an `OPEN` occurrence remains eligible for a Reservation under FR-23, while setting `active=false` makes the reservation contract refuse it.

## Acceptance criteria

| ID | Given / When / Then |
|---|---|
| AC-01 | Given an authenticated `funcionario`, when `POST /v1/resources` sends `{code:"proj-01", name:"Projector 1", type:"PROJECTOR"}`, then the response is 201, `Location` is `/v1/resources/{id}`, `code` is `PROJ-01`, `active` is `true`, `tags` is `[]`, timestamps are present, and `GET` by the returned ID returns the same resource. |
| AC-02 | Given an existing code `PROJ-01`, when a create uses `proj-01` or `PROJ-01`, then the response is 409 problem+json with `code="FR-22"`, `type="urn:closed-cras:recusa:FR-22"`, and `reason="RESOURCE_CODE_TAKEN"`. |
| AC-03 | Given an invalid code (2 or 33 characters, `PROJ_01`, `-PROJ`, blank, or non-string), when a create is attempted, then the response is 422 with `code="VALIDATION"` and an `errors[]` entry for `code`. |
| AC-04 | Given tags `["AV", "av", " Audio-Visual "]`, when a resource is created, then the stored and returned tags are `["audio-visual", "av"]`; more than 10 tags, a blank tag, a tag over 30 characters, a duplicate after normalization that cannot be deduplicated, or a tag outside the pattern returns 422. |
| AC-05 | Given resources with different types, active states, and tags, when `GET /v1/resources?code=proj-01&type=PROJECTOR&active=true&tag=av` is called, then only resources satisfying all four filters are returned, the `code` filter is case-normalized, and the order is `code` ascending. |
| AC-06 | Given a list request, when the response is inspected, then it is a top-level array `[...]` and contains no `page`, `pageSize`, `limit`, `offset`, `total`, or `next` field. |
| AC-07 | Given a resource with occurrences, when `GET /v1/resources/{resourceId}` is called, then the body is the Resource aggregate and `occurrences` is ordered `createdAt` descending, then `id` descending; an unknown ID returns 404 with `reason="RESOURCE_NOT_FOUND"`. |
| AC-08 | Given an existing resource, when PATCH sends only `{name, active}`, then only those fields change, `code` and `tags` are unchanged, and `updatedAt` advances; when PATCH sends `{tags:[...]}`, the array is replaced in full. |
| AC-09 | Given an existing resource, when PATCH includes `code`, includes an unknown property, or is `{}`, then the response is 422 with `code="VALIDATION"` and the database row is unchanged. |
| AC-10 | Given an existing resource, when `POST /v1/resources/{resourceId}/occurrences` sends `{description:"Lamp does not turn on", type:"MALFUNCTION"}`, then the response is 201 with `Location`, `status="OPEN"`, `priority="MEDIUM"`, `resolution=null`, `resolvedAt=null`, `reportedBy` equal to the caller's `employeeId`, and a server-set `createdAt`. |
| AC-11 | Given an existing resource, when an occurrence is created with `priority:"HIGH"`, then it is stored as HIGH; an invalid type or priority returns 422; an unknown resource returns 404 with `reason="RESOURCE_NOT_FOUND"`. |
| AC-12 | Given an OPEN occurrence, when PATCH sends `{resolution:"Lamp replaced"}`, then the response is 200 with `status="RESOLVED"`, the resolution, `resolvedBy` equal to the caller's `employeeId`, `resolvedAt >= createdAt`, and a changed `updatedAt`. |
| AC-13 | Given a RESOLVED occurrence, when PATCH is called again, then the response is 409 with `code="FR-22"`, `reason="OCCURRENCE_ALREADY_RESOLVED"`, and the stored occurrence does not change. |
| AC-14 | Given a resource or occurrence, when DELETE is attempted, then the existing path returns 405 problem+json; no delete or reopen route exists, and the row remains. |
| AC-15 | Given a resource with an OPEN occurrence, when PATCH sets `active=false`, then the resource becomes inactive, the occurrence remains OPEN, and a later resolve does not change `active` back to true. |
| AC-16 | Given an `active=true` resource with an OPEN occurrence, when the reservations contract evaluates FR-23, then the resource remains eligible; after `active=false`, the same contract refuses it. Occurrence data is not consulted. |
| AC-17 | Given an inactive resource, when an occurrence is created or resolved, then the write succeeds and `active` remains false. |
| AC-18 | Given no JWT, when any protected route is called, then 401; given a `professor`, `student`, or `coordenador` JWT, when a write is attempted, then 403; given any authenticated realm role, when a read is attempted, then 200. |
| AC-19 | Given a browser `Origin` header sent directly to the resources context, when any route is called, then 403 with `reason="BROWSER_ORIGIN_FORBIDDEN"` and no CORS allow headers are returned. |
| AC-20 | Given a valid JWT, when `GET /v1/identidade/me` is called, then it returns `sub`, `email`, `papeis`, and nullable `employeeId`, `professorId`, `studentId`; `GET /health` is anonymous and returns 200 when the database is reachable, 503 otherwise. |
| AC-21 | Given a BFF session cookie, when the BFF lists or reads resources, then `openOccurrenceCount` equals the number of `OPEN` occurrences; after a resolve the count decreases; a domain 409/422 passes through as the same problem+json. |
| AC-22 | Given any resources response, when the body is inspected, then it contains no roster, Student data, availability, occupancy, or InventoryItem field; neither the context nor the BFF has an `/inventory-items` route. |
| AC-23 | Given an empty `cras_resources` database on PostgreSQL 18.6, when `schema.sql` is applied, then it completes without error, creates the four enums, `resources`, `occurrences`, the indexes and triggers, and creates no `inventory_items` table. |
| AC-24 | Given the schema, when invalid rows are attempted, then the database rejects lowercase or malformed codes, duplicate codes, blank names, an 11th tag, uppercase or duplicate tags, a code update, a reopen or edit of a RESOLVED occurrence, any status other than `OPEN`/`RESOLVED`, a `reported_by` rewrite, an orphan occurrence, RESOLVED without resolution, RESOLVED without `resolvedBy`, RESOLVED without `resolvedAt`, OPEN with `resolvedAt`/`resolvedBy`/`resolution`, `resolvedAt < createdAt`, and deletion of a resource with occurrences; `updated_at` advances on update. |
| AC-25 | Given the schema, when tags are written, then `resource_tags` holds one row per tag, the primary key refuses duplicates, lowercase/pattern/length checks refuse malformed tags, an 11th tag raises P0001, and deleting the resource cascades its tags; `GET /v1/resources` still returns `tags` as a sorted array. |
| AC-26 | Given any resource aggregate or occurrence response, then the occurrence object has no `assignedTo` and no `startedAt` key, and `status` is only `OPEN` or `RESOLVED`. |
| AC-27 | Given an OPEN occurrence, when PATCH sends `{action:"START"}` or a body containing `action`, `assignedTo`, `startedAt`, or `status`, then the response is 422 with `code="VALIDATION"` and the stored occurrence is unchanged. |
| AC-28 | Given the database, when a row is written with `status='IN_PROGRESS'`, then PostgreSQL rejects it (invalid enum value); the transition trigger accepts only `OPEN → RESOLVED`. |
| AC-29 | Given an OPEN occurrence, when PATCH sends `{resolution:"Board replaced"}`, then the response is 200 with `status="RESOLVED"`, `resolvedBy` equal to the caller's `employeeId`, `resolvedAt >= createdAt`, null `resolution` is rejected, and the row keeps its original `reportedBy`. |
| AC-30 | Given a BFF resource payload, then it carries `openOccurrenceCount` and no `inProgressOccurrenceCount`; after a resolve the count decreases by one. |
| AC-31 | Given any write body, when it contains `status`, `reportedBy`, `resolvedBy`, or `resolvedAt`, then the response is 422 with `code="VALIDATION"`; the stored row is unchanged. A token without `employeeId` on an occurrence write returns 403 with `reason="EMPLOYEE_IDENTITY_REQUIRED"`. |
| AC-32 | Given a create with `type:"ROOM"`, `type:"OTHER"`, `type:"KIT"`, `type:"AUDIO_VISUAL"`, or an unknown type, then the response is 422; given `type` one of `PROJECTOR`, `HEALTH_KIT`, `COMPUTER`, `NOTEBOOK`, `CAMERA`, `MICROPHONE`, `DISPLAY`, `CABLE`, `ADAPTER`, the create succeeds and the value is returned unchanged. |
| AC-33 | Given a PATCH without `resolution`, with a blank resolution, or with an unknown field, then the response is 422 with `code="VALIDATION"` and the occurrence is unchanged. |

## Authentication and authorization

- **Token.** `Authorization: Bearer <JWT>`. The service validates signature via Keycloak JWKS, issuer, expiry, and the realm `closed-cras`. Required configuration: `DATABASE_URL`, `KEYCLOAK_JWKS_URL`, `KEYCLOAK_ISSUER`, `BFF_ORIGIN`.
- **Claims.** `sub`, `email`, realm roles, and optional `employeeId`, `professorId`, `studentId`. `GET /v1/identidade/me` returns those fields and nulls for non-applicable IDs, matching the shared identity fragment.
- **Roles.** `funcionario` may write. Any authenticated realm role may read. A recognized authenticated caller without `funcionario` who attempts a write gets 403. A caller with no recognized realm role gets 403 on any protected route.
- **Browser.** The browser authenticates only at the BFF. The BFF holds the session in an httpOnly `cras_session` cookie (placeholder name; see assumptions), forwards the user Bearer token to the context, and never forwards `Origin`. The context enables no CORS.
- **Failures.** Missing, expired, or invalid token: 401. Insufficient role or browser `Origin`: 403. JWKS/identity unavailable: 503 `reason="IDENTITY_UNAVAILABLE"`. Database unavailable: 503 `reason="DATABASE_UNAVAILABLE"`.
- **No identity leakage.** 401 responses do not enumerate accounts or echo token contents. No CPF, roster, or Student data exists in this context.

## Error mapping

All errors except `/health` use `application/problem+json` with at least `type`, `title`, `status`, `detail`, and `code`. `instance` is the request path. `reason` is the machine-readable discriminator. `errors[]` is present only for 422.

| Status | `code` | `type` | `reason` values | When |
|---|---|---|---|---|
| 400 | `MALFORMED_REQUEST` | `urn:closed-cras:malformed-request` | — | Body is not parseable JSON. |
| 401 | `AUTH_UNAUTHENTICATED` | `urn:closed-cras:auth:unauthenticated` | `MISSING_TOKEN`, `INVALID_TOKEN`, `EXPIRED_TOKEN` | No valid JWT on a protected route. |
| 403 | `AUTH_FORBIDDEN` | `urn:closed-cras:auth:forbidden` | `ROLE_NOT_ALLOWED`, `BROWSER_ORIGIN_FORBIDDEN`, `EMPLOYEE_IDENTITY_REQUIRED` | Authenticated but not allowed, a browser `Origin` reached the context, or an occurrence write token has no `employeeId` claim. |
| 404 | `NOT_FOUND` | `urn:closed-cras:not-found` | `RESOURCE_NOT_FOUND`, `OCCURRENCE_NOT_FOUND` | Resource or occurrence does not exist under the supplied path. |
| 405 | `METHOD_NOT_ALLOWED` | `urn:closed-cras:method-not-allowed` | — | Method is not defined for an existing path. |
| 409 | `FR-22` | `urn:closed-cras:recusa:FR-22` | `RESOURCE_CODE_TAKEN`, `OCCURRENCE_ALREADY_RESOLVED` | Resource registration or occurrence lifecycle invariant refused. |
| 415 | `UNSUPPORTED_MEDIA_TYPE` | `urn:closed-cras:unsupported-media-type` | — | POST/PATCH body is not `application/json`. |
| 422 | `VALIDATION` | `urn:closed-cras:validation` | — | Shape, type, enum, format, unknown field, empty PATCH, or malformed UUID/query value. `errors[]` names the fields. |
| 500 | `INTERNAL_ERROR` | `urn:closed-cras:internal` | — | Unexpected server failure; no stack trace in the body. |
| 503 | `DEPENDENCY_UNAVAILABLE` | `urn:closed-cras:dependency:unavailable` | `IDENTITY_UNAVAILABLE`, `DATABASE_UNAVAILABLE` | JWKS/IdP or database unavailable. The BFF adds `RESOURCES_UPSTREAM_UNAVAILABLE`. |

`/health` is the exception: it returns `{status, service, database}` with 200 or 503 and does not use problem+json.

## Data model

`schema.sql` and `data-dictionary.md` are authoritative. Summary:

- **`resources`** — `id UUID PK`, `code VARCHAR(32) UNIQUE NOT NULL`, `name VARCHAR(120) NOT NULL`, `type resource_type NOT NULL`, `active BOOLEAN NOT NULL DEFAULT TRUE`, `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`.
- **`resource_tags`** — `resource_id UUID NOT NULL REFERENCES resources(id) ON DELETE CASCADE`, `tag VARCHAR(30) NOT NULL`, `PRIMARY KEY (resource_id, tag)`, checks for non-blank/lowercase/pattern/length; 0–10 rows per resource enforced by `trg_resource_tags_max`.
- **`occurrences`** — `id UUID PK`, `resource_id UUID NOT NULL FK → resources(id) ON DELETE RESTRICT`, `description TEXT NOT NULL`, `type occurrence_type NOT NULL`, `priority occurrence_priority NOT NULL DEFAULT 'MEDIUM'`, `status occurrence_status NOT NULL DEFAULT 'OPEN'`, `resolution TEXT`, `reported_by UUID NOT NULL`, `resolved_by UUID`, `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`, `resolved_at TIMESTAMPTZ`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`.
- **Enums** — `resource_type = PROJECTOR, HEALTH_KIT, COMPUTER, NOTEBOOK, CAMERA, MICROPHONE, DISPLAY, CABLE, ADAPTER`; `occurrence_type = MALFUNCTION, DAMAGE, MISSING, OTHER`; `occurrence_status = OPEN, RESOLVED`; `occurrence_priority = LOW, MEDIUM, HIGH`.
- **Audit actors** — `reported_by` and `resolved_by` are employee UUIDs from the identity fragment. There is no cross-context FK; the resources context never calls the employees context.
- **Indexes** — unique `resources.code`; `(active, type)`; `resource_tags(tag)`; `(resource_id, status)`; `(resource_id, created_at DESC)`; `(status, priority)`.
- **Triggers** — `updated_at` on both tables; `resources.code` immutability; `occurrences` terminal-state guard (`trg_occurrences_terminal_state` refuses any direct UPDATE of a RESOLVED row); `trg_occurrences_transitions` refuses any illegal status change; `trg_occurrences_identity_immutable` refuses changes to `resource_id` and `reported_by`. `created_at` is server-set by the API and defaulted by the database; the API rejects client-supplied timestamps.
- **Tag guards** — the primary key prevents duplicates; `resource_tags_tag_not_blank`, `_tag_lower`, `_tag_format`, and `_tag_length` carry the value rules; `enforce_resource_tags_max()` + `trg_resource_tags_max` carry the 10-tag limit.
- **Deletion policy** — no API delete; `occurrences → resources` is RESTRICT; `resource_tags → resources` is CASCADE (dependent data). `active=false` retires without deleting history.

## API contract

Base URL: `http://localhost:8106` in the local compose, paths under `/v1`. The full contract is `openapi.yaml`.

| Method | Path | Authorization | Success | Errors |
|---|---|---|---|---|
| GET | `/v1/resources` | any authenticated role | 200 `ResourceSummary[]` | 401, 403, 422, 503 |
| POST | `/v1/resources` | `funcionario` | 201 `Resource` + `Location` | 400, 401, 403, 409, 415, 422, 503 |
| GET | `/v1/resources/{resourceId}` | any authenticated role | 200 `Resource` | 401, 403, 404, 422, 503 |
| PATCH | `/v1/resources/{resourceId}` | `funcionario` | 200 `Resource` | 400, 401, 403, 404, 415, 422, 503 |
| POST | `/v1/resources/{resourceId}/occurrences` | `funcionario` | 201 `Occurrence` + `Location` | 400, 401, 403, 404, 415, 422, 503 |
| PATCH | `/v1/resources/{resourceId}/occurrences/{occurrenceId}` | `funcionario` | 200 `Occurrence` | 400, 401, 403, 404, 409, 415, 422, 503 |
| GET | `/v1/identidade/me` | any authenticated role | 200 `Identity` | 401, 503 |
| GET | `/health` | anonymous | 200 `Health` | 503 |

**Field rules.**

- `code`: trim and uppercase; 3–32; `^[A-Z0-9]+(-[A-Z0-9]+)*$`; unique; immutable on PATCH.
- `name`: trim; 1–120; non-blank.
- `type`: one of the `resource_type` values; no `ROOM`.
- `active`: boolean; create default `true`; PATCH omitted leaves unchanged.
- `tags`: trim, lowercase, deduplicate, sort; 0–10; each 1–30; `^[a-z0-9]+(-[a-z0-9]+)*$`; PATCH replaces the full array.
- `description`: trim; non-blank; TEXT.
- Occurrence `type`: one of the `occurrence_type` values.
- `priority`: one of the `occurrence_priority` values; create default `MEDIUM`.
- `status`: server-set; create always `OPEN`; resolve sets `RESOLVED`. The request never carries it.
- `resolution`: required and non-blank on resolve; null while `OPEN`; server rejects it on create.
- `reportedBy`, `resolvedBy`: server-set from the JWT `employeeId`; a body containing either is rejected with 422.
- `createdAt`, `resolvedAt`, `updatedAt`: server-set; clients cannot send them.
- `resourceId`/`occurrenceId`: UUID; output lowercase; malformed path UUID is 422.

**Collection and ordering.** `ResourceList` and the nested `occurrences` are top-level arrays. Resources are ordered by `code` ascending. Occurrences are ordered by `createdAt` descending, then `id` descending. There is no pagination.

**Location.** 201 responses carry a path-only `Location`: `/v1/resources/{resourceId}` or `/v1/resources/{resourceId}/occurrences/{occurrenceId}`.

## BFF read model

`bff-openapi.yaml` and `bff-read-model.md` are authoritative.

- The module lives at `backend/bff/src/modules/resources/`; it composes the resources context and owns no aggregate and no table.
- Browser auth is the BFF session cookie `cras_session` (httpOnly, SameSite=Lax). The BFF forwards the user's Bearer token; it does not forward browser cookies or `Origin` to the context.
- Browser-facing routes mirror the resources routes. `ResourceSummary` and `Resource` add `openOccurrenceCount` (integer, minimum 0), computed from the aggregate's `OPEN` occurrences. The domain contract does not contain this field.
- The BFF forwards the resolve body unchanged and never sets `status`, `resolvedBy`, or `resolvedAt`.
- The list composition reads the domain list and each resource aggregate to count occurrences per state. This is an N+1 read at lab scale; a domain count projection is out of scope.
- Domain problem+json passes through unchanged. If the resources context is unavailable, the BFF returns 503 `DEPENDENCY_UNAVAILABLE` with `reason="RESOURCES_UPSTREAM_UNAVAILABLE"`.
- The BFF exposes no roster, Student data, availability, occupancy, or inventory-item route. It does not recalculate `active`; it displays the domain value.
- The BFF enables CORS only for the frontend origin with credentials. The resources context enables no CORS.

## UX-S3 contract

UX-S3 is one surface with two zones: Room and Resource. This SPEC fixes the Resource zone's data and behavior; ownership of UX-S3 remains OQ-1.

- **Layout.** Resource list on the left; selected Resource detail on the right, using the `master-detail-panel` and `data-table` patterns. The secondary 1–N list is Occurrences; it is never an orphan page.
- **Resource list.** Shows `code`, `name`, `type`, `active`, tags, and `openOccurrenceCount` from the BFF. Selecting a row loads the aggregate.
- **Resource detail.** Shows code (read-only after create), name, type, active, tags, timestamps, and the occurrence collection. Edit is allowed for name, type, active, and tags; code is never editable.
- **Occurrence list.** Newest first; shows `createdAt`, type, priority, status, description, `reportedBy`, and resolution/`resolvedBy`/`resolvedAt` when present. Status uses the `status-pill` pattern with two states; priority is text, not the warning color reserved for `flag-avaliacao-mark`.
- **Actions.** Create Resource; edit Resource; record Occurrence (description, type, priority default MEDIUM); resolve Occurrence (resolution required). No delete, reopen, or edit-after-resolve control exists.
- **Refusals.** 409 duplicate code, 409 already resolved, and 422 validation surface in the `refusal-banner` with the API `detail`/`reason`; the form is retained. No success toast replaces a refusal.
- **Empty states.** No resources: empty state with a create action for `funcionario`. No occurrences: empty state; a `funcionario` can record one. No Student or roster content.
- **Accessibility and language.** Labels use the locked tokens Resource, Occurrence, code, type, active, tags, description, priority, status, resolution, createdAt, resolvedAt. Status is not conveyed by color alone. The refusal banner is `role="alert"`. Design tokens, typography, and component visuals come from `DESIGN.md`; behavior comes from `EXPERIENCE.md`.

## Assumptions

- **A-1.** Code input is trimmed and uppercased before validation; the canonical stored form is uppercase.
- **A-2.** Tags are normalized to lowercase, trimmed, deduplicated, and sorted; the filter is a single exact tag, not a multi-tag expression.
- **A-3.** Multiple OPEN occurrences per resource are allowed.
- **A-4.** Occurrence writes are allowed regardless of `active`; resolving does not reactivate; deactivating does not resolve.
- **A-5.** A resolution is required and non-blank on resolve and must be null otherwise. Actors are recorded: `reportedBy` on create, `resolvedBy` on resolve.
- **A-6.** PATCH occurrence is resolve-only (`resolution`); PATCH resource is partial; `tags` full-replaces; there is no optimistic concurrency or ETag.
- **A-7.** There are no delete endpoints; `active=false` is retirement; the code remains reserved.
- **A-8.** Reads are open to any authenticated realm role; writes are `funcionario` only.
- **A-9.** Every collection, including nested occurrences, is a top-level array; `Location` is path-only; timestamps are UTC; UUIDs are lowercase.
- **A-10.** The BFF computes `openOccurrenceCount` without a domain count field; the N+1 read is acceptable at lab scale.
- **A-11.** The schema enforces tag value checks and the 10-tag limit on `resource_tags`, plus the resolution/status checks on `occurrences`. `created_at` immutability is enforced by the API, with the database default as a backstop.
- **A-12.** `cras_session` is the BFF cookie name placeholder; the shared auth module must either implement it or update the BFF contract.
- **A-13.** The `reason` extension is the machine discriminator inside the FR-22 refusal; `code` remains the FR id.
- **A-14.** `HEALTH_KIT` is one reservable kit; internal components, quantities, and serial numbers are not modeled.
- **A-15.** `createdAt` is report time; there is no separate `occurredAt` in v1.
- **A-16.** `name`, `description`, and `resolution` are trimmed; descriptions and resolutions have no app-level maximum beyond the TEXT column.
- **A-17.** List order is `code` ascending; occurrence order is `createdAt` descending then `id` descending.
- **A-18.** A mistaken occurrence is resolved with explanatory text; a mistyped immutable code is retired and a new Resource is created.
- **A-19.** A `funcionario` token is expected to carry `employeeId` for occurrence writes. The context does not fall back to `sub`, because the audit actor must be the employee id used by the other contexts. Resource writes are unaffected by this claim.
- **A-20.** `reportedBy` and `resolvedBy` are opaque employee UUIDs: the resources context does not validate that the employee exists, so a stale or unknown id surfaces as a display gap rather than a 404.
- **A-21.** `resource_type` is a descriptive classification with no `OTHER` fallback (decision 2026-10-28). Every resource must fit one of the nine values; an unlisted kind of stock requires an enum migration.

## Open questions

- **OQ-R1 — RESOLVED.** Occurrences record the acting employees: `reportedBy` (create) and `resolvedBy` (resolve). An assignee was tried in v1.1 and removed in v1.3 with the `IN_PROGRESS` state. No per-field audit trail exists beyond these two actors.
- **OQ-R2.** Should a resolved occurrence support correction or reopen? v1 does not; a new occurrence is the workaround.
- **OQ-R3.** Should a `HEALTH_KIT` expose component or quantity tracking? v1 treats it as one unit.
- **OQ-R4.** Should open occurrences warn or block reservations in a future version? v1 keeps `active` as the only gate and preserves FR-23.
- **OQ-R5.** Should deactivating a resource cancel existing reservations? The resources context does not cascade; the reservations context must decide.
- **OQ-R6.** Should tags be a controlled vocabulary, or support multiple-tag AND/OR search? v1 has a single exact tag.
- **OQ-R7.** Should a code be reusable after retirement? v1 has no delete, so the code remains reserved.
- **OQ-R8.** Should occurrences support `occurredAt` separate from `createdAt`? v1 uses report time.
- **OQ-R9.** Is `Occurrence` the final visible UI token, or should the Portuguese label “Ocorrência” be used? The domain token stays `Occurrence`.
- **OQ-R10.** Who owns UX-S3 under OQ-1? The resources group may not implement its own surface.

## Provenance and validation

- **Inputs read:** PRD `_bmad-output/planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/prd.md` (FR-22, FR-23, glossary) and `addendum.md`; architecture `_bmad-output/planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md`; UX `_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-08-24/DESIGN.md` and `EXPERIENCE.md` (UX-S3); `backend/resources/README.md` (empty service).
- **Source status:** no upstream artifact was edited. `change-impact.md` lists the exact sections to update; until they are updated, this SPEC wins for resources-specific conflicts.
- **Adopted companions:** `DESIGN.md`, `EXPERIENCE.md`, and `ARCHITECTURE-SPINE.md` remain owned by their originating skills. They are authoritative for design tokens, UX behavior, and cross-context architecture; this SPEC restates only the resources-specific rules.
- **Wrapper-only / out-of-scope material:** the PRD's other FRs, the UX's other surfaces, and the architecture's other contexts were not copied. They are not load-bearing for the resources contract. The memlog records the scoping decision.
- **Pass 1 — coherence:** PASS. Every capability has an intent and a testable success; invariants and non-goals constrain the design; capability IDs are stable `CAP-1`–`CAP-10`; prose is contract-only.
- **Pass 2 — preservation:** PASS for resources-scoped claims. FR-22, FR-23, the glossary pair, addendum pair/attributes, UX-S3 behavior, AD-2/AD-4/AD-5/AD-6/AD-7 resources implications, and the Model A decisions all land in this SPEC or a companion. The source edits are listed in `change-impact.md`.
- **v1.2 mechanical validation:** `schema.sql` was applied to a disposable PostgreSQL instance; the tag model was exercised (normalized rows, duplicate/uppercase/format/length refusal, 11th tag refused, cascade on resource delete) and the enum refuses `OTHER`, `AUDIO_VISUAL`, and `KIT`.
- **v1.3 mechanical validation:** `schema.sql` was applied to a disposable PostgreSQL instance; `IN_PROGRESS` is rejected by the enum, `OPEN → RESOLVED` works, opening a resolved row is refused, and `reported_by` stays immutable. Both contracts validate against the OAS 3.1 meta-schema.
- **v1.1 mechanical validation:** the v1.1 guards were exercised before the state was removed. `openapi.yaml`, `bff-openapi.yaml`, and the generated `openapi.json` were parsed and their internal `$ref`s resolved.
- **Mechanical validation (v1.0):** the `schema.sql` model was checked against PostgreSQL 18.6 in a disposable local validation (constraints, triggers, and the normalized tag model); no database is provisioned by this spec. `openapi.yaml` and `bff-openapi.yaml` parse as YAML and pass structural checks. The detailed verdicts are appended to `.memlog.md`.
