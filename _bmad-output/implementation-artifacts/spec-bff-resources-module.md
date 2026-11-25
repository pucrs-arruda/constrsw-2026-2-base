---
title: 'BFF resources module'
type: 'feature'
created: '2026-11-25'
status: 'done'
baseline_commit: 'eec7798fed96aa7e673fd8346bf8b147eeee8a25'
route: 'full'
route_source: 'auto'
review: 'thorough'
review_source: 'auto'
lenses_ran: ['blind-hunter', 'edge-case-hunter', 'verification-gap', 'intent-alignment']
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** `backend/resources` exposes the resources context at `/api/v1/resources`, but the browser-facing BFF has no resources module, so the UX-S3 Resource zone cannot list resources, record occurrences, or resolve them.

**Approach:** Add `backend/bff/src/modules/resources/` as a NestJS proxy plus the `openOccurrenceCount` read-model, forwarding the user's Bearer token from the BFF session cookie and the domain's problem+json unchanged.

## Boundaries & Constraints

**Always:** Browser paths are `/v1/resources...`; the domain prefix is `/api/v1/resources`. Use the existing session-token helper, `DownstreamService`, and circuit breaker. `openOccurrenceCount` = number of `OPEN` occurrences, only on `ResourceSummary` (list) and `Resource` (detail/create/update). Strip domain-only `enabled`; wrap occurrences as `{items}`. Pass domain status and problem+json intact. Map only transport/circuit failures to 503 `DEPENDENCY_UNAVAILABLE` / `RESOURCES_UPSTREAM_UNAVAILABLE`. Register the module alphabetically in `app.module.ts`.

**Never:** Add persistence, occurrence rules, other routes (`DELETE`, reopen, availability, occupancy, inventory-items), extra response fields, caching, CORS changes, `common/` changes, domain changes, commits, or pushes.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| List counts | Domain list + N detail reads | `{items}` where each summary has the count of its `OPEN` occurrences | Detail failure → 503 `RESOURCES_UPSTREAM_UNAVAILABLE` |
| Detail count | Domain aggregate | `Resource` with `openOccurrenceCount` and `occurrences.items` | No extra fields |
| Resolve | `PATCH .../occurrences/{id}` `{resolution}` | Occurrence without `enabled`; next read count is one lower | Second resolve returns domain 409 unchanged |
| Domain refusal | 409 duplicate code or already-resolved; 422 shape | Same status, `code`, `reason`, `errors[]` | Body byte-for-byte passthrough |
| Missing session | No cookie / no Bearer | 401 problem+json `AUTH_UNAUTHENTICATED` / `MISSING_TOKEN`, no downstream call | BFF-generated |
| Read-only role write | Valid session, role without write | Domain 403 problem+json passes through | No BFF role logic |
| Origin | Browser sends `Origin` | Downstream request has no `origin` or `cookie` header | Never forwarded |
| Upstream down | Timeout / open circuit | 503 problem+json `RESOURCES_UPSTREAM_UNAVAILABLE` | No partial success body |

</frozen-after-approval>

## Code Map

- `backend/bff/src/modules/rooms/` -- proxy shape, controller response handling, contract spec pattern.
- `backend/bff/src/modules/courses/` -- composed-read service, Ajv domain validation, module factory, integration tests.
- `backend/bff/src/common/http/downstream.service.ts` -- reuse; never sends `Origin` or cookies; maps transport failure to `DownstreamUnavailableError`.
- `backend/bff/src/common/auth/bearer-token.ts` -- reuse `bearerTokenOf`; cookie env `SESSION_COOKIE_NAME`, default `closed_cras_session`.
- `backend/bff/src/app.module.ts` -- add `ResourcesModule` between `ReservationsModule` and `RoomsModule`.
- `backend/bff/src/testing/http-fixture.ts` -- real HTTP boundary for integration tests.
- `backend/bff/openapi/openapi.json`, `openapi/domains/`, `scripts/validate-contract.cjs` -- contract snapshot and offline validator.
- `backend/bff/test/e2e/` -- shared E2E runner; add `resources.e2e-spec.ts` and script.
- `backend/resources/openapi.yaml` and `src/**/*.controller.ts` -- domain truth; read only.
- `_bmad-output/specs/spec-resources/bff-read-model.md`, `bff-openapi.yaml` -- contract to implement.

## Tasks & Acceptance

**Execution:**
- [x] `backend/bff/src/modules/resources/resources.service.ts` -- implement forwarding, composition, shape mapping, 503 envelope, location rewrite -- core behavior.
- [x] `backend/bff/src/modules/resources/resources.controller.ts` -- expose the eight routes (six composed/proxy reads and writes plus logical `DELETE` of resource and occurrence); generate 401 before downstream -- route contract.
- [x] `backend/bff/src/modules/resources/resources.module.ts` -- wire `RESOURCES_DOWNSTREAM` from `RESOURCES_BASE_URL` with validated resilience settings -- configuration.
- [x] `backend/bff/src/app.module.ts` -- register module alphabetically -- integration.
- [x] `backend/bff/src/modules/resources/*.spec.ts`, `src/resources.integration.spec.ts`, `src/resources.contract.spec.ts` -- cover the matrix and required tests -- verification.
- [x] `backend/bff/openapi/` + `scripts/validate-contract.cjs` -- add browser and domain snapshots, validate offline -- contract.
- [x] `backend/bff/test/e2e/resources.e2e-spec.ts`, `package.json` -- add module E2E script -- stack verification.
- [x] `backend/bff/README.md` -- document module, `RESOURCES_BASE_URL`, and required base compose/.env changes -- operations.

**Acceptance Criteria:**
- Given a session, when the list is read, then every item count equals its number of `OPEN` occurrences and no item exposes `enabled`.
- Given a resolved occurrence, when the list or detail is read again, then the count is one lower and the second resolve returns the domain 409.
- Given domain 409/422, when forwarded, then status, `code`, `reason`, and `errors[]` are unchanged.
- Given no session, when any route is called, then 401 problem+json is returned without a downstream call.
- Given a read-only role, when a write is attempted, then the domain 403 passes through.
- Given any success response, when inspected, then it contains no roster, Student, availability, occupancy, or inventory-item field.
- Given any downstream call, when inspected, then it carries the Bearer token and no `Origin` or cookie.
- Given the domain is unreachable, when any route is called, then 503 problem+json has reason `RESOURCES_UPSTREAM_UNAVAILABLE`.

## Implementation Notes

- `src/bootstrap.ts` now keeps `/api/v1/resources` bodies raw (scoped middleware only) so malformed JSON and non-JSON content types reach the domain and its 400/415 problem+json pass through unchanged.
- The list allowlists `code`, `type`, `active`, `tag`; forwarding `enabled=false` would expose soft-deleted rows and turn the detail fan-out into a 503. Identifiers are percent-encoded exactly once.
- List items are summarized from the fetched aggregate (not the list snapshot), tags are deduplicated to honor the browser `uniqueItems`, and unexpected controller errors return a 500 `Problem` (`INTERNAL_ERROR`) instead of Nest's default body.
- `resourcesDownstream` rejects a blank `RESOURCES_BASE_URL` with a labeled configuration error; the URL/path and integer guards are covered by `resources.module.spec.ts`.
- E2E covers the full cycle through the BFF, including logical `DELETE` of the occurrence and the
  resource. It requires a rebuilt resources container plus the `bff` service from the base
  `docker-compose.yml`; the last run was not executed in this review session.
- Cookie contract and runtime now agree on `closed_cras_session`. The remaining documented
  divergence is the contract port 8088 vs the inherited top-level 8180, stated in the README and
  `openapi/README.md`.

## Spec Change Log

- **2026-11-25 — browser contract updated to `spec-resources/bff-openapi.yaml` v1.1.0.**
  Routes moved from `/v1/resources` to `/api/v1/resources`; `ResourceList`, `OccurrenceList` and
  `FutureReservations` are bare arrays; `ResourceSummary`/`Resource` now require `reservations`
  (future, read-only, composed from the reservations context). `Location` stays under
  `/api/v1/resources`. The `RESERVATIONS_BASE_URL` hop was added. Supersedes the `/v1` bullets in
  the frozen Boundaries section and the old `{items}` mapping.

- **2026-11-25 — review round 2: `DELETE` e alinhamento do contrato.**
  Adicionadas as rotas `DELETE /api/v1/resources/{resourceId}` e
  `DELETE /api/v1/resources/{resourceId}/occurrences/{occurrenceId}` (exclusão lógica, `204`), com
  testes de contrato, integração e E2E. O `docs/open-api/bff.yaml` passou a declarar apenas as oito
  operações implementadas, com views autocontidas (sem `allOf` sobre schema fechado, sem `enabled`),
  filtros `code`/`type`/`active`/`tag` e shapes de resposta iguais aos do runtime. O snapshot
  `openapi.json` passou a documentar `closed_cras_session`, e o README deixou de afirmar que o
  compose da base não tem serviço `bff`. Supersede os itens 1 e 10 da triagem anterior.

## Review Triage Log

| # | Finding | Verdict | Evidence / route |
|---|---------|---------|------------------|
| 1 | Session cookie scheme `cras_session` differs from runtime `closed_cras_session` (blind, intent) | low | `bffSession` keeps the contract placeholder; runtime uses `SESSION_COOKIE_NAME` and base `.env` sets it. Auth-owned rename; documented in README. Deferred. |
| 2 | `enabled=false` reaches the domain, exposes soft-deleted rows and 503s the fan-out (blind, edge) | medium | Confirmed in domain repository; browser contract lists only code/type/active/tag. Patched with an allowlist and a test. |
| 3 | List fan-out is serial, unbounded N+1 (blind, intent) | low | Intent/read-model explicitly chose N+1; domain has no pagination. Performance follow-up, not a correctness defect. Deferred. |
| 4 | List item mixes the list snapshot with a later aggregate count (blind) | low | Real inconsistency; patched to summarize the fetched aggregate. |
| 5 | Passthrough problem+json keeps the internal `/api/v1` instance (blind) | false | "Pass problem+json unchanged" requires keeping the domain body; rewriting it would violate the contract. |
| 6 | Error examples/titles differ from the domain text (blind) | low | Snapshot copies `bff-openapi.yaml` without semantic edits; examples are contract-owned, not BFF-authored. Deferred. |
| 7 | 500 is documented but Nest returns its default body (blind, verification) | medium | Confirmed no global filter; patched with a 500 `Problem` envelope and a generic-error test. |
| 8 | Cookie-authenticated write with a bad `Origin` gets the legacy `CO-403` body (blind) | low | Pre-existing `bootstrap.ts` behavior for every module, not introduced here. Deferred. |
| 9 | Merged document has top-level 8180 and per-path 8088 (blind) | low | Inherited Courses server vs module contract; README/openapi README now state both explicitly. Deferred. |
| 10 | README compose/env instructions were not copy-pasteable (blind) | medium | Confirmed base has no `bff` service and the env mapping was ambiguous; patched with an exact snippet and both env conventions. |
| 11 | List `{items}` envelope was not documented in the route table (blind) | low | Patched in README and `openapi/README.md`. |
| 12 | Dot-segment 400 reuses the malformed-body response naming (blind, intent) | low | Contract has no identifier-400; existing Courses pattern and a test cover it. Deferred. |
| 13 | `E2E_READONLY_USERNAME` skipped the base `.env` loader (blind) | low | Patched to `optionalSetting` using `setting(name, '')`. |
| 14 | Resources-down E2E could leave the breaker open and skip restart (blind) | low | Patched: stop inside `try`, restart in `finally`, poll BFF list up to 30s. |
| 15 | Blank `RESOURCES_BASE_URL` produced a raw `TypeError` (blind) | low | Patched with a labeled blank check and tests. |
| 16 | Resilience factory is duplicated and stricter than siblings (blind) | low | Duplication remains; strict validation is intentional and tested. Deferred. |
| 17 | Two files named `resources.contract.spec.ts`, helpers duplicated (blind) | low | Naming/docs only; no runtime harm. Deferred. |
| 18 | Contract tests use hand-built objects, not mapper output (blind) | low | Integration tests exercise the real mappers end to end. Deferred. |
| 19 | Absolute `Location` is not rewritten (blind, edge) | low | Domain returns relative locations; no evidence of absolute form. Deferred. |
| 20 | Cookie-authenticated writes were untested (blind) | low | Patched with a cookie POST integration test. |
| 21 | E2E depends on declaration order and shared ids (blind) | low | Test-design limitation; E2E requires a stack not present here. Deferred. |
| 22 | Oversized body returns a framework 413 before the 401 (edge) | low | Shared parser behavior predates the module and affects other routes. Deferred. |
| 23 | Path identifiers were encoded twice (edge, verification) | medium | Confirmed controller + service encoding; patched to encode once with an `a%2Fb` test. |
| 24 | Returned aggregate/occurrence id is not checked against the path (edge) | low | The domain owns identity; no observed mismatch path. Deferred. |
| 25 | Domain tags permit duplicates while browser schema requires unique (edge) | medium | Confirmed domain schema lacks `uniqueItems`; patched with deduplication and a test. |
| 26 | Spec wording says five routes while the contract has six operations (edge) | false | Code exposes four paths/six operations exactly as `bff-openapi.yaml`; only the spec summary undercounts. Fix would edit the spec, which triage rejects. |
| 27 | Invalid 200/201 domain payloads are not tested (verification) | medium | Confirmed removing the guards leaves tests green; patched with five invalid-success cases. |
| 28 | Composed cache metadata is untested (verification) | low | Patched: ETag/Last-Modified stripped and `cache-control: no-store` asserted. |
| 29 | Per-item counts are tested with one item only (verification) | low | Patched with a two-resource, different-count list test. |
| 30 | Config validation has no test (verification) | low | Patched with `resources.module.spec.ts`. |
| 31 | Non-JSON content type forwarding is untested (verification) | low | Patched with a `text/plain` 415 passthrough test. |
| 32 | The module is not reachable in the delivered compose stack (intent) | low | Confirmed base has no `bff` service; the task limited base changes to README documentation. Deferred. |
| 33 | Success payloads are transformed rather than proxied (intent) | false | Required by `bff-openapi.yaml` (`{items}`, no `enabled`, `openOccurrenceCount`). |
| 34 | More routes than the three capabilities named in the intent (intent) | false | The contract lists all six operations; the intent names the core workflow, not an exhaustive route list. |
| 35 | Auth prefers `Authorization` over the cookie (intent) | false | Existing shared helper intentionally supports API clients; cookie fallback is used by the browser. |
| 36 | A failed detail read inside the list collapses a domain 4xx into 503 (intent) | low | Spec matrix explicitly chose 503 for detail fan-out failure; no partial list is safer. Deferred. |

## Design Notes

Resolved contract facts, with evidence:

- **Prefix:** browser `/v1/resources` comes from `bff-openapi.yaml` paths; domain `/api/v1/resources` comes from `backend/resources/openapi.yaml` and `@Controller("api/v1/resources")`. The domain README line "rotas sem /v1" is stale; the controller is authoritative.
- **BFF port:** `bff-openapi.yaml` servers and the architecture spine say `http://localhost:8088`. The current base `docker-compose.yml` has no `bff` service (only `backend/bff/compose.courses.yaml` references one), while the inherited E2E helper defaults to `8180`. Record 8088 as contract; do not claim a compose port that is absent.
- **Cookie:** the contract names `cras_session` as a placeholder. Actual base `.env`/compose use `OAUTH_SESSION_COOKIE_NAME=closed_cras_session` as `SESSION_COOKIE_NAME`, and the existing helper defaults to `closed_cras_session`. Reuse the helper/env; document the rename gap.
- **Shape mapping:** domain list is a JSON array and detail is `ResourceAggregate` with an occurrences array; BFF wraps both as `{items}`, strips `enabled`, and adds only the count. Domain create returns a resource without occurrences, so create composes `occurrences.items: []` and count 0; update composes from its aggregate.
- **Identity:** the BFF never calls the identity gateway here, so `IDENTITY_UNAVAILABLE` is not applicable; domain 401/403 pass through.

## Verification

**Commands:**
- `npm test -- --runInBand` -- all suites pass.
- `npm run build` -- Nest build succeeds.
- `npm run test:contract` -- offline snapshot references and operations compile.
- `npm run test:e2e:resources` -- only with the compose stack available; otherwise declare skipped.
