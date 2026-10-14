# Brownfield — constrsw-2026-1

Referência operacional da edição anterior (Close Cras / ConstrSW 2026/1). Informa **padrões**; não é autoridade de produto nem de stack para Closed CRAS 2026/2. Autoridade: PRD + Architecture Spine + este SPEC.

## O que reusar

| Padrão | Evidência em 2026-1 | Como aplicar em 2026-2 |
| --- | --- | --- |
| Browser → BFF → contextos | `backend/bff`, frontend só fala com BFF | AD-6; CAP-10; OV-10 |
| JWT via JWKS (validação local) | `auth` emite; resource-servers validam JWKS | CAP-11; `backend/oauth` + BFF login + `GET /v1/identidade/me` |
| Keycloak como IdP | realm + clients + users de lab | Realm `closed-cras`; papéis do PRD; REST API oauth sobre Keycloak |
| Contract-first OpenAPI | `data-model/*.yml` + BFF gerado | `openapi/openapi.yaml` por contexto (AD-2); CAP-9 |
| BFF = proxy + composição de leitura | Views/agregações; sem regra de domínio | Proxy pass-through vs read-model (OV-10); sem persistir agregado; sem pré-validar FR |
| Compose local reprodutível | `docker-compose.yml` raiz | AD-7; PG + Mongo; Prometheus + Grafana |
| Submódulos por serviço | `.gitmodules` | Mesma malha; seed estrutural do Spine |
| Checagem de refs cross-service | GET autoritativo por `id`; reconciliação pontual | Consumidores guardam IDs; escritores validam via GET (negocial) |
| Health + observabilidade baseline | `/health`, OTEL/Prometheus | `GET /health` + readiness; `/metrics` scrapável; Prometheus+Grafana no compose |
| Hexagonal/layered por serviço | Vários backends | Livre sob checklist de conformidade AD-3 (poliglota) |

## O que não carregar

| 2026-1 | Por que rejeitar | Autoridade 2026-2 |
| --- | --- | --- |
| Student CRUD + academicHistory / notas / frequências | Non-goal; Student é recebido | CAP-3; PRD §7 |
| Professor com mesmo UUID que Employee (identidade de store) | Is-a é só `employeeId` 1–1; store não define identidade | CAP-2; AD-3; non-goal identidade Mongo=Employee |
| Materials aninhados em Course/Lesson | Modelo de plano é SyllabusItem + LessonTopic | CAP-4, CAP-6 |
| Dependents em Employee | Par 1–N é EmploymentBond | CAP-1; `domain-pairs.md` |
| Reservation policies; room events | Par é ReservationLine; Room tem AccessibilityFeature | CAP-7, CAP-8 |
| Stack de domínio sem checklist AD-3 (envelope/JWT/paths divergentes) | Conformidade poliglota, não banimento de linguagem | AD-3; CAP-9 |
| Realm `constrsw`; roles `administrator` / read-only grosso | Papéis e mapa de escrita do PRD | CAP-11; NFR-CTR-2 |
| EKS / Terraform / ECR cloud | Envelope lab = Compose only | AD-7 |
| Sem derivação de sala efetiva | Sala efetiva é invariante central | CAP-6; AD-5 |
| Audience JWT divergente por serviço | Audience/`oauth` unificado no Spine | AD-4 |
| Frontend com mocks default / tema Material sem tokens DESIGN.md | Tokens DESIGN.md prevalecem; dados via BFF; Angular+Material | CAP-12; AD-8 |
| BFF sem wiring completo de students | Students é contexto de primeira classe | CAP-3, CAP-10 |
| BFF validando invariante negocial (ex. Employee ativo) | OV-10 / AD-6: regra fica no escritor | CAP-10; AD-1 |

## Lições operacionais (anti-padrões a evitar)

1. **Monolito distribuído por tela** — UI não orquestra nove OpenAPIs; BFF compõe.
2. **BFF dono de invariante** — sala efetiva, conflitos e geração de Lesson ficam nos escritores de domínio.
3. **Ciclo de dependência de escrita** — só GET em profundidade 1 entre `lessons` e `reservations`.
4. **Checar existência via listagem paginada** — usar GET por `id` autoritativo.
5. **Copiar cadastro (`pessoa`)** — consumidores guardam IDs; resolução de nome/e-mail no BFF ou via Employee.
6. **Heterogeneidade de path/erro/JWT** — AD-2 e AD-4 pinam envelope, paths e validação.
7. **Domínio embute join de tela** — payload completo de outro contexto no agregado “para facilitar UI” (OV-10).

## Fontes consultadas (audit)

- `constrsw-2026-1/architecture-insights.md`
- `constrsw-2026-1/data-model/README.md` e OpenAPIs por domínio
- `constrsw-2026-1/backend/bff/README.md`, `backend/auth/README.md`
- `constrsw-2026-1/docker-compose.yml`, `infrastructure/dev-cloud/README.md`
- Navegação/API do frontend (`navigation.ts`, `api.ts`)
