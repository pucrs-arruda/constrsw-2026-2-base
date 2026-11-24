# Stack — BFF

Prescrição de implementação. O que a BFF faz está em `SPEC.md`.

| Peça | Pin |
| --- | --- |
| Node.js | `>=24.15` (engines do `package.json`) |
| NestJS (`@nestjs/core`) | 12.1.3 |
| Express | 5.x (via `@nestjs/platform-express`) |
| Contrato | OpenAPI 3.1 `docs/open-api/bff.yaml` (repo base) |
| Persistência | Nenhuma de agregado Closed CRAS |
| Métricas | scrapáveis (`HttpMetrics` / porta `BFF_INTERNAL_METRICS_PORT`) |
| Logs | Estruturados em stdout; sem tokens/cookies/corpos |

## Compose (raiz)

Serviço `bff` no `docker-compose.yml`. Não subir o BFF fora do Compose da base para demos oficiais.

Variáveis relevantes (nomes no container; valores vêm do `.env` da base — **não imprimir segredos**):

| Variável | Uso |
| --- | --- |
| `PORT` | Porta HTTP interna |
| `BFF_ORIGIN` | Origem CORS com credentials |
| `SESSION_COOKIE_NAME` | Cookie HttpOnly alinhado ao oauth |
| `*_BASE_URL` | Origem de cada contexto (classes, courses, employees, lessons, professors, reservations, resources, rooms, students) |
| `OAUTH_*` / `JWT_*` | Validação/encaminhamento conforme módulo (ex. reservations valida JWKS) |
| `BFF_HTTP_TIMEOUT_MS` | Timeout por tentativa |
| `BFF_HTTP_RETRIES` | Retries em métodos idempotentes |
| `BFF_CIRCUIT_BREAKER_*` | Threshold, reset, volume, janela |
| `BFF_INTERNAL_METRICS_PORT` | Listener opcional de métricas |

Porta publicada típica: `BFF_EXTERNAL_API_PORT` → 8180.

## Resiliência (AD-10)

- Timeout por tentativa; limite total inclui tentativas + backoff (teto documentado no código/README, tipicamente ≤ 1000 ms entre tentativas).
- Retry: GET/HEAD (e política explícita do módulo); **writes de courses: uma tentativa**.
- HTTP 5xx do downstream conta como falha no circuito; respostas 4xx do domínio sobem intactas (não são “rede”).
- Redirects: não seguir.
- Circuitos independentes por dependência (ex. courses vs classes no mesmo módulo).

## Testes no submódulo

```sh
npm ci
npm test -- --runInBand
npm run test:contract
npm run build
# E2E do domínio com stack Compose no ar:
npm run test:e2e:<contexto>
```
