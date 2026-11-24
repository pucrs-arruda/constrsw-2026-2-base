---
id: SPEC-bff
companions:
  - routes.md
  - composition.md
  - contribution.md
  - stack.md
  - brownfield.md
  - divergences.md
  - ../../../docs/open-api/bff.yaml
sources:
  - ../../planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
  - ../spec-closed-cras/SPEC.md
  - ../spec-closed-cras/domain-pairs.md
  - ../spec-closed-cras/capability-map.md
  - ../../../backend/bff/README.md
  - ../../../backend/bff/docs/superpowers/specs/2026-11-23-courses-bff-design.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability only — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# BFF

## Why

**Mandato + dor.** O browser da ConstrSW 2026/2 não pode falar com nove OpenAPIs nem com o IdP direto: sem uma superfície única, cada grupo inventa join de tela, CORS e sessão. A BFF é a única origem HTTP do frontend — proxy dos contextos, composição de leitura T3 e resiliência nos hops — sem persistir agregado nem aplicar regra negocial. Sem este contrato, a implementação diverge entre o OpenAPI (`docs/open-api/bff.yaml`), a spine AD-6 e o código parcial em `backend/bff`.

## Capabilities

- **CAP-1**
  - **intent:** O frontend cria, lê, atualiza e exclui recursos de domínio só pela BFF, com o mesmo contrato do contexto escritor.
  - **success:** Toda rota de `routes.md` marcada **proxy** repassa método, query, corpo, status, `Content-Type`, `Location` e `X-Total-Count` do domínio; recusas FR sobem intactas; o BFF não pré-valida invariante negocial. Inclui `GET /api/v1/reservations/ocupacao` (FR-29: recursos ocupados por data+faixa, sem nomes de Student).

- **CAP-2**
  - **intent:** Quem lista ou lê student, course, professor ou room vê as turmas do semestre em curso sem enviar `year`/`semester`; na vista Professor, nome/e-mail de exibição vêm do Employee.
  - **success:** GET de coleção e de item desses quatro recursos devolvem o schema *View* de `composition.md` com `classes` obrigatório; vínculo e semestre conforme ali; sem match → `classes: []`; GETs de professors incluem `employeeName` e, se houver, `employeeEmail` resolvidos via `employees` por `employeeId` (OpenAPI de professors não copia esses campos); falha de `classes` ou de `employees` (só em professors) → 503 sem recurso pela metade (`BFF-DEPENDENCY` em students/professors/rooms; envelope 503 do contexto em courses).

- **CAP-3**
  - **intent:** Quem lista ou lê resource vê as reservas futuras daquele recurso.
  - **success:** GET de coleção e de item de resources devolvem `reservations` futuras conforme `composition.md`; sem match → `[]`; falha do `reservations` → 503 sem recurso pela metade (envelope 503 do contexto resources).

- **CAP-4**
  - **intent:** O browser autentica via OAuth e a BFF encaminha a identidade aos contextos, com CORS só nela.
  - **success:** Cookie HttpOnly (`SESSION_COOKIE_NAME`) ou `Authorization: Bearer` explícito; Bearer malformado não cai no cookie; só o `access_token` segue aos domínios; CORS com `credentials` para `BFF_ORIGIN`; escrita autenticada por cookie com `Origin` diferente de `BFF_ORIGIN` → 403; contextos sem CORS de SPA.

- **CAP-5**
  - **intent:** Falha de dependência não derruba a BFF nem cascateia sem limite.
  - **success:** Cada hop BFF→domínio aplica timeout + circuit breaker; retry só em métodos/política explícitos de `stack.md`; circuito aberto/timeout/rede → 503 estável; writes de courses: uma tentativa; circuitos independentes por dependência (ex. courses vs classes).

- **CAP-6**
  - **intent:** O operador verifica se o processo da BFF responde e observa métricas sem token de usuário.
  - **success:** `GET /health` anônimo → 200 `{status: UP}` sem consultar contextos; métricas scrapáveis; logs estruturados sem tokens, cookies, query sensível nem corpos.

- **CAP-7**
  - **intent:** Cada grupo entrega o módulo do próprio contexto na BFF compartilhada sem ser dono exclusivo dela.
  - **success:** Pasta `src/modules/<contexto>/` + registro em `app.module.ts` (ordem alfabética); checklist de `contribution.md`; mudanças em `common/` não quebram módulos já integrados; testes unit/contrato/E2E do domínio via BFF passam.

## Constraints

- Contrato público: companion adotado `docs/open-api/bff.yaml` (OpenAPI 3.1). Prefixo `/api/v1`. Detalhe de rotas: `routes.md`.
- **OV-10 / AD-6:** escrita, recusa FR e is-a ficam no contexto escritor; BFF não persiste agregado, não recalcula `salaEfetivaId`, não valida `employees.ativo` no proxy.
- Composição T3 só nos GETs de coleção/item listados em `composition.md`. GET de coleção secundária (matrículas, titulações, ocorrências, etc.) permanece proxy.
- Envelopes 503 de composição **por contexto**, como o `bff.yaml`: `BFF-DEPENDENCY` em students/professors/rooms; 503 do contrato do contexto em courses/resources. Sem unificar.
- Prefixo público `/api/v1` em todos os módulos, inclusive rooms (Grupo 08 alinha o legado `/v1/rooms` + acrescenta T3 `classes`).
- FR-19 e FR-31: composição **no cliente** sobre proxies; sem endpoint BFF dedicado de plano/roster/aulas do aluno.
- Roster só via `classes`/`studentIds`; módulo `reservations` do BFF não inclui `Class.studentIds`.
- Sobe só pelo Compose da raiz. Runtime e pins: `stack.md`. Sem Kubernetes/Helm na v1.
- Sem dono exclusivo de BFF/OAuth. Equidade: sucesso de grupo = par 1–N + rotas BFF do domínio + gateway + telas alheias.

## Non-goals

- Persistência de agregado de domínio ou store próprio de entidades Closed CRAS.
- Login/refresh/logout como endpoints novos da BFF (ficam no `oauth`).
- Módulo `ocupacao/` separado: FR-29 é o proxy `GET /api/v1/reservations/ocupacao`.
- Join de nove OpenAPIs no browser; CORS de SPA nos contextos.
- UI, implementação dos nove writers e administração do Keycloak.
- Read-models dedicados FR-19 / FR-31 no BFF.

## Success signal

No Compose, o frontend completa jornadas só contra `localhost:8180`: proxies devolvem o contrato do domínio; GETs T3 trazem `classes`/`reservations` sem o cliente mandar semestre; ocupação responde em `/api/v1/reservations/ocupacao`; falha T3 → 503 sem payload pela metade; `GET /health` → `UP` com dependência down; nove grupos conseguem apontar este SPEC + companions para implementar/alinhar o próprio `src/modules/<contexto>/`.

## Assumptions

- UI laboratório: Bearer após `POST {oauth}/login` (+ refresh/logout); cookie HttpOnly permanece transporte suportado.
- Redirects HTTP do downstream não são seguidos.
- `GET /health` e `GET /metrics` de cada contexto não fazem parte desta API pública.
- Employee sem e-mail: `employeeEmail` é omitido na `ProfessorView`; `employeeName` é obrigatório quando o Employee existe.
