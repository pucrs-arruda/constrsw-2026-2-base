# Brownfield — `backend/bff`

Estado do código observado na criação desta SPEC (submódulo `backend/bff`). O **alvo** é `SPEC.md` + `docs/open-api/bff.yaml`; esta página não autoriza divergência permanente.

## Já integrado em `AppModule`

| Módulo | Comportamento atual | Gap vs alvo |
| --- | --- | --- |
| `courses` | Proxy + T3 `classes`; semestre SP; CO-503 em falha de composição | Alinhado ao contrato courses |
| `students` | Proxy + T3 `classes`; 503 `BFF-DEPENDENCY` | Alinhado |
| `reservations` | Proxy puro incl. `/ocupacao` e `/identidade/me`; JWT JWKS no BFF | Alinhado (proxy); validação JWT extra no módulo |
| `rooms` | Proxy sob **`/v1/rooms`**; **sem** T3 `classes` | **Débito do Grupo 08:** publicar `/api/v1/rooms` + T3 `classes` (OQ-ROOMS-PATH fechada) |

## Ainda ausentes

| Pasta alvo | Tipo alvo |
| --- | --- |
| `src/modules/classes/` | proxy |
| `src/modules/lessons/` | proxy |
| `src/modules/resources/` | T3 `reservations` |
| `src/modules/professors/` | T3 `classes` + display Employee |
| `src/modules/employees/` | proxy |

## Compartilhado já existente

- `common/http/downstream.service.ts` + `circuit-breaker.ts` (AD-10)
- `common/academic/current-semester.ts`
- `common/auth/bearer-token.ts` (Bearer + cookie)
- `common/health/` (`GET /health` → `UP`; métricas)
- `bootstrap.ts`: CORS `BFF_ORIGIN` + credentials; rejeição de Origin em escrita cookie-auth

## Legado a não seguir

- Comentários/código que publicam `/v1/<contexto>` como path público (supersedido por `/api/v1`).
- README citando `src/modules/ocupacao/` como dono FR-29 (supersedido por proxy `reservations/ocupacao`).
- Spine AD-6 pedindo read-models BFF dedicados para FR-19/FR-31 (supersedido por composição no cliente — `divergences.md`).
