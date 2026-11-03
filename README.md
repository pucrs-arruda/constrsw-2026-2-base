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

## Prometheus and Grafana

To start the Group 02 services with monitoring, use the Prometheus Compose overlay and name only the required services:

```bash
docker compose -f docker-compose.yml -f backend/oauth/docker-compose.prometheus.yml up --build -d keycloak oauth prometheus grafana
```

- Prometheus targets: <http://localhost:9090/targets>
- Grafana: <http://localhost:3000>
- OAuth metrics: <http://localhost:8381/actuator/prometheus>

See the [OAuth API README](https://github.com/pucrs-constrsw-2026-2/oauth/blob/grupo02/README.md) for metric details, endpoint examples, and configuration options.

## Lessons (grupo 02)

O Compose raiz inclui `backend/lessons/compose.lessons.yml`. Com os submódulos OAuth e
Lessons inicializados, execute na raiz:

```bash
git submodule update --init backend/oauth backend/lessons
docker volume create constrsw-keycloak-data
docker compose up --build -d --wait lessons
```

Isso sobe Keycloak, OAuth, PostgreSQL e Lessons. Swagger:
[Lessons](http://localhost:8108/swagger-ui/index.html).

Para executar os testes ponta a ponta pela mesma stack:

```bash
python3 backend/lessons/scripts/base_e2e.py --base .
```

Os clientes HTTP de classes, itens do plano de ensino e reservas de sala dependem dos
contratos dos outros grupos. Os testes ponta a ponta usam fixtures apenas nessas três
APIs; Keycloak, OAuth, PostgreSQL e Lessons são reais. Configuração e limitações estão em
[integrações Lessons](backend/lessons/docs/integrations.md).
