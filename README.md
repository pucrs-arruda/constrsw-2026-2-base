# base

Umbrella repository for ConstrSW 2026-2. It holds the local infrastructure
(Docker Compose, Keycloak, Prometheus, Grafana, OpenTelemetry) and pulls every backend
service and the frontend in as git submodules.

## Layout

| Path | Contents |
|---|---|
| `backend/*` | One submodule per service (`oauth`, `bff`, `classes`, `courses`, …) |
| `frontend` | Frontend submodule |
| `infrastructure/dev.local/services` | Keycloak, Prometheus, Grafana and OTel Collector images and config |
| `docker-compose.yml` / `.env` | Single entry point for the local environment |
| `_bmad-output/planning-artifacts` | Brief, PRD, architecture and UX artifacts |

## Prerequisites

- Docker with Docker Compose v2
- Git

## Getting started

```bash
git clone --recurse-submodules https://github.com/pucrs-constrsw-2026-2/base.git
cd base
# already cloned without submodules? run: git submodule update --init --recursive

cp .env.example .env

# first run only: create the external volumes
docker volume create constrsw-keycloak-data
docker volume create constrsw-prometheus-data

docker compose up -d --build --wait
```

`--wait` returns once every service is healthy. `oauth` only starts after
Keycloak is healthy.

Every service with a `build:` entry is compiled inside its Dockerfile. Don't
rely on build artifacts from your machine (`dist/`, `node_modules/`).

## Demo

```bash
./scripts/demo.sh
```

A guided walkthrough for presentations. It runs the steps above, then pauses on
each part of the stack: Keycloak health and test users, a login through `oauth`
with the decoded token (also copied to the clipboard for Swagger), Swagger
with a numbered example request for every endpoint, `/metrics`, Prometheus and
Grafana, opening each page in the browser. From the
login step on it sends traffic to `oauth` in the background so the graphs move,
and stops it when the script ends. The stack keeps running afterwards. Needs
`docker`, `curl` and `jq`.

## Services

| Service | URL | Notes |
|---|---|---|
| oauth API | http://localhost:8181 | Login, users and roles gateway over Keycloak |
| oauth Swagger | http://localhost:8181/docs | |
| oauth health | http://localhost:8181/health | |
| oauth metrics | http://localhost:8181/metrics | Scraped by Prometheus |
| Keycloak console | http://localhost:8081 | `admin` / `a12345678`, realm `constrsw` |
| Keycloak health/metrics | http://localhost:9001 | |
| Prometheus | http://localhost:9090 | |
| Grafana | http://localhost:3030 | Dashboards open without login. `admin` / `a12345678` to edit |
| OTel Collector | `localhost:4317` (gRPC), `localhost:4318` (HTTP) | Metrics on 8888 / 8889 |
| Blackbox Exporter | http://localhost:9115 | |

Quick check:

```bash
curl localhost:8181/health
curl -F username=admin@pucrs.br -F password=a12345678 localhost:8181/login
```

A `201` on the login means `oauth` reaches Keycloak. A `503` means it can't,
and a `401` means the realm doesn't have that user or password. See
[Keycloak realm](#keycloak-realm).

## Metrics

Prometheus scrapes `oauth` (`/metrics` on its API port) and Keycloak (port
9001). Grafana, at http://localhost:3030, reads from Prometheus and comes with
two dashboards:

| Dashboard | Shows |
|---|---|
| [ConstrSW — Visão geral](http://localhost:3030/d/constrsw-overview) | Up/down and health check per service, requests and 5xx per service, firing alerts. Grafana's home page |
| [ConstrSW — oauth](http://localhost:3030/d/constrsw-oauth) | oauth traffic, latency and errors, calls to Keycloak by result, memory, CPU and event loop |

Both are files in
[infrastructure/dev.local/services/grafana/dashboards](infrastructure/dev.local/services/grafana/dashboards),
loaded when Grafana starts. Grafana has no data volume and won't save changes
to them from the UI. To change a dashboard, log in as `admin`, edit it, click
**Save** and copy the JSON the dialog offers over the file. Grafana reloads the
folder every 10 seconds, so there's no need to restart it.

Without Grafana, the same data is in Prometheus.
**[Open the oauth dashboard in Prometheus](http://localhost:9090/query?g0.expr=up%7Bjob%3D~%22oauth%7Ckeycloak%22%7D&g0.tab=table&g0.range_input=1h&g1.expr=sum%20by%20%28uri%2C%20status%29%20%28rate%28http_server_requests_seconds_count%7Bjob%3D%22oauth%22%7D%5B5m%5D%29%29&g1.tab=graph&g1.range_input=1h&g2.expr=histogram_quantile%280.95%2C%20sum%20by%20%28le%2C%20uri%29%20%28rate%28http_server_requests_seconds_bucket%7Bjob%3D%22oauth%22%7D%5B5m%5D%29%29%29&g2.tab=graph&g2.range_input=1h&g3.expr=sum%20by%20%28operation%2C%20result%29%20%28rate%28oauth_keycloak_request_duration_seconds_count%5B5m%5D%29%29&g3.tab=graph&g3.range_input=1h)**
opens it with four panels already filled in: targets up, oauth requests/s,
oauth p95 latency, and oauth → Keycloak calls by result. Bookmark it.
Counters restart at zero whenever `oauth` restarts, so the graphs stay flat
until it gets some traffic.

### Generating load for the dashboards

`npm run test:e2e` (in `backend/oauth`) does **not** feed Grafana. It is a
hermetic test: it boots the Nest app in memory with a mocked Keycloak and a
throwaway `prom-client` registry, none of which reaches Prometheus. To actually
move the panels, drive the running `oauth` — the instance Prometheus scrapes:

```bash
./scripts/load.sh                 # 120s, 16 concurrent workers, max speed (~100 req/s)
./scripts/load.sh --rps 60        # exact global cap of 60 req/s
./scripts/load.sh --workers 24    # more concurrency (capped at 24)
./scripts/load.sh --duration 0    # until Ctrl-C, for a live demo
./scripts/load.sh --open          # same, and opens the Grafana dashboards
```

It replays the same operations as the e2e specs, so every series
(`http_server_requests_seconds_*`, `oauth_keycloak_request_*`) gets data and the
4xx/Keycloak-`rejected` panels move too. Throughput is bounded by Keycloak, not
the script: `POST /login` takes ~90ms, so the mixed scenario tops out near
~100 req/s; more workers don't help past ~16. Prometheus scrapes every 10s and
the panels use `rate(...[5m])`, so let it run for a minute or two. `demo.sh`
already sends background traffic; `load.sh` is the fine-grained control for
sending real volume.

Other queries to paste at http://localhost:9090:

| Question | Query |
|---|---|
| oauth requests/s by route | `sum by (uri) (rate(http_server_requests_seconds_count{job="oauth"}[5m]))` |
| oauth 5xx ratio | `sum(rate(http_server_requests_seconds_count{job="oauth",status=~"5.."}[5m])) / sum(rate(http_server_requests_seconds_count{job="oauth"}[5m]))` |
| oauth p95 latency by route | `histogram_quantile(0.95, sum by (le, uri) (rate(http_server_requests_seconds_bucket{job="oauth"}[5m])))` |
| Failed logins/s | `rate(http_server_requests_seconds_count{job="oauth",uri="/login",status="401"}[5m])` |
| oauth → Keycloak calls by result | `sum by (operation, result) (rate(oauth_keycloak_request_duration_seconds_count[5m]))` |
| oauth → Keycloak p95 by operation | `histogram_quantile(0.95, sum by (le, operation) (rate(oauth_keycloak_request_duration_seconds_bucket[5m])))` |
| oauth memory | `process_resident_memory_bytes{job="oauth"}` |
| Keycloak heap used | `base_memory_usedHeap_bytes{job="keycloak"} / base_memory_maxHeap_bytes{job="keycloak"}` |
| Keycloak requests (excluding health and metrics) | `sum by (uri, status) (rate(http_server_requests_seconds_count{job="keycloak",uri!~"/health.*\|/metrics"}[5m]))` |

`result` on the Keycloak calls is `ok`, `rejected` (Keycloak answered with a
non-2xx status, such as a wrong password) or `unavailable` (network error or
timeout, which makes `oauth` return `503` and fires the
`OAuthKeycloakUnavailable` alert). Details are in
[backend/oauth/README.md](backend/oauth/README.md).

`prometheus.yml` only scrapes services that are in the compose file. The other
services' jobs and health check targets are commented out at the end of it,
with their ports and metrics paths. When you add a service to the compose file,
uncomment its job and its line under `health-checks`. Its alerts are already in
`alerts.yml`.

## Configuration

All values live in the root `.env`, which is git-ignored. Copy it from
`.env.example`, whose defaults are only meant for local development. When you
add a variable, add it to `.env.example` too. After changing `.env` or the compose file, recreate the affected service:

```bash
docker compose up -d --build --force-recreate oauth
```

## Keycloak realm

The `constrsw` realm is imported from
`infrastructure/dev.local/services/keycloak/constrsw.json`. It defines two
clients used by `oauth`:

| Client | Used for | Variables |
|---|---|---|
| `oauth` | User login (password grant) | `KEYCLOAK_CLIENT_ID` / `KEYCLOAK_CLIENT_SECRET` |
| `oauth-admin` | Admin API for users and roles (service account) | `KEYCLOAK_ADMIN_CLIENT_ID` / `KEYCLOAK_ADMIN_CLIENT_SECRET` |

The realm also ships the users `admin@pucrs.br`, `coordinator@pucrs.br`,
`professor@pucrs.br` and `student@pucrs.br`. Manage their passwords in the
Keycloak console.

**The import only runs once.** Keycloak keeps its database in the
`constrsw-keycloak-data` volume and skips the import if the realm already
exists, so later changes to `constrsw.json` don't reach an existing volume. To
reload the realm from the file (this deletes any local users and roles):

```bash
docker compose down
docker volume rm constrsw-keycloak-data
docker volume create constrsw-keycloak-data
docker compose up -d --build --wait
```

To keep your data, apply the change in the Keycloak console instead.

## Common commands

```bash
docker compose ps                  # service status
docker compose logs -f oauth       # follow a service's logs
docker compose down                # stop everything (volumes are kept)
git submodule update --remote      # move submodules to their remote branch heads
```

## More docs

- [backend/oauth/README.md](backend/oauth/README.md): oauth routes, decisions and tests
- [infrastructure/dev.local/services/keycloak/README.md](infrastructure/dev.local/services/keycloak/README.md): Keycloak setup
- [infrastructure/dev.local/services/prometheus/README.md](infrastructure/dev.local/services/prometheus/README.md): monitoring
