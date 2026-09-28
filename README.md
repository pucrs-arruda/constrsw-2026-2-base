# Construction Software — Group 02

This repository contains the Group 02 project configuration. The OAuth API is maintained in the `backend/oauth` Git submodule and integrates with Keycloak.

## Get the source

Clone the Group 02 branch and initialize only the OAuth submodule:

```bash
git clone --branch grupo02 https://github.com/pucrs-constrsw-2026-2/base.git
cd base
git submodule update --init backend/oauth
```

## Configure and run

Docker Compose reads the required configuration from the `.env` file at the repository root. Use the Group 02 local configuration and keep credentials private.

Create the external Keycloak data volume once, then start the Group 02 authentication services:

```bash
docker volume create constrsw-keycloak-data
docker compose up --build -d keycloak oauth
```

## API

- Swagger UI: <http://localhost:8181/swagger-ui/index.html>
- Health check: <http://localhost:8181/health>
- API details and configuration: [OAuth API README](https://github.com/pucrs-constrsw-2026-2/oauth/blob/grupo02/README.md)

## Tests and CI

Run the OAuth API tests from its submodule:

```bash
cd backend/oauth
mvn test
```

The [Group 02 CI workflow](https://github.com/pucrs-constrsw-2026-2/oauth/blob/grupo02/.github/workflows/ci.yml) runs service, adapter, endpoint, and end-to-end test stages before packaging.

## Live end-to-end check

This smoke test calls the running OAuth API and the real local Keycloak. It checks health, login, token refresh, and access to the Group 02 resource /lessons. It does not create or change users or roles, and it does not print tokens.

From the base repository root, start Keycloak and OAuth, then run the script. It prompts for the test user's password if E2E_PASSWORD is not set:

    docker compose up --build -d keycloak oauth
    E2E_USERNAME=admin@pucrs.br python3 scripts/oauth_live_e2e.py

The Group 02 base workflow runs the OAuth test suite first, starts this local stack, and then runs the live smoke test on pushes and pull requests targeting grupo02. The workflow stops its containers afterward; a local run leaves the services running.

The live E2E workflow reads the test user's password from the GitHub Actions repository secret GROUP02_E2E_PASSWORD.

## Prometheus and Grafana

To start the Group 02 services with monitoring, use the Prometheus Compose overlay and name only the required services:

```bash
docker compose -f docker-compose.yml -f backend/oauth/docker-compose.prometheus.yml up --build -d keycloak oauth prometheus grafana
```

- Prometheus targets: <http://localhost:9090/targets>
- Grafana: <http://localhost:3000>
- OAuth metrics: <http://localhost:8381/actuator/prometheus>

See the [OAuth API README](https://github.com/pucrs-constrsw-2026-2/oauth/blob/grupo02/README.md) for metric details, endpoint examples, and configuration options.
