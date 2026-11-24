# Rooms (Grupo 08): plano de orquestração T3 (BFF) + T4 (frontend)

| Campo | Valor |
| --- | --- |
| Grupo | 08, rooms: Anthony, Lucas Simão, Arthur Maciel, João Biasoli |
| Data | 24/11/2026 |
| Executores | Gemini Argon (agentes de desenvolvimento AG-01 a AG-09) |
| Revisor | Claude (agente REV) |
| Repositório base | `constrsw-2026-2-base`; principal do grupo `grupo08-base` (criada pelo AG-09 a partir de `claude/rooms-frontend-bff-dfae7e`, onde este plano está). Regra de branches: seção 3.1 |
| Fonte de verdade | Este documento + `docs/open-api/bff.yaml` + `docs/open-api/grupo08-rooms-api.yaml` |

---

## Índice

1. Como usar este documento
2. Decisões fechadas
3. Regras globais (valem para todos os agentes)
4. Fatos verificados do sistema
5. Arquitetura alvo
6. Interfaces combinadas entre agentes (contratos internos)
7. Roster de agentes, ondas e dependências
8. Fichas dos agentes (prompt pronto para colar)
9. Revisor (REV): prompt e checklists
10. Integração, commits e ponteiros de submódulo
11. Riscos e armadilhas conhecidas
12. Fora do escopo
13. Glossário

---

## 1. Como usar este documento

- Cada agente recebe como prompt **a seção 3 (regras globais) + a seção 4 (fatos) + a seção 6 (interfaces) + a sua própria ficha da seção 8**. As fichas já dizem isso no início; basta colar a ficha e anexar este arquivo inteiro.
- Os agentes rodam em **ondas** (seção 7). Uma onda só começa quando as entregas de que ela depende foram **aprovadas pelo REV**.
- Todo agente termina com um **relatório de entrega** no formato da seção 8.0. O REV revisa usando a seção 9.
- Nenhum agente decide sozinho coisa que contradiga este documento. Se encontrar contradição entre este documento e o código ou o contrato, **para, descreve a contradição no relatório e espera**. O contrato (`docs/open-api/*.yaml`) vence este documento; o código vence documentação antiga (README, `_bmad-output` antigos).

---

## 2. Decisões fechadas

| # | Decisão | Origem |
| --- | --- | --- |
| D1 | O grupo 08 faz as telas de Rooms no frontend. Ignorar FR-28 / CAP-12 / AD-8 para este caso. | Grupo |
| D2 | Frontend em **Angular 22**, standalone components, **Angular Material M3**, CDK, SCSS. Idioma pt-BR. Só tema claro. Sem keycloak-js. | Grupo + EXPERIENCE.md |
| D3 | Os campos das telas seguem a **API** (contrato), não o mock. "Andar" e "Observações" do mock **não existem** e não devem ser criados. | Grupo |
| D4 | BFF e frontend respondem **exatamente** ao contrato `docs/open-api/bff.yaml` (rooms), que referencia `docs/open-api/grupo08-rooms-api.yaml`. Nada de endpoint, campo ou status fora do contrato. | Grupo |
| D5 | O BFF repassa o **token do próprio usuário** ao rooms e ao classes (mesmo padrão de students e courses). Consequência aceita: o classes filtra por papel; coordinator e administrator veem todas as turmas da sala; professor vê só as que conduz; student vê só as que cursa. Documentar no README do BFF e mostrar um aviso discreto na tela quando o usuário não for coordinator/administrator ("Você vê apenas as turmas vinculadas a você."). | Claude (delegado pelo grupo) |
| D6 | Backend rooms **não muda endpoints**: o contrato do professor (`docs/open-api/grupo08-rooms-api.yaml`) é byte a byte igual a `backend/rooms/openapi.yaml`, e os schemas de room e accessibility feature também. Só corrigimos bugs de build, health e testes. | Verificado com `diff` em 24/11/2026 |
| D7 | Rotas do frontend por path (não hash): `/login`, `/salas`, `/salas/:id`. O nginx faz fallback da SPA. | Claude |
| D8 | O frontend nunca chama rooms, classes ou oauth diretamente pelo host deles. Tudo passa pela mesma origem: `/api/auth/*` (oauth) e `/api/bff/*` (BFF), via proxy do nginx em produção e `proxy.conf.json` no `ng serve`. | Compose + oauth sem CORS |
| D9 | Token nunca vai para `localStorage`/`sessionStorage`. Sessão = cookie httpOnly `closed_cras_session` emitido pelo oauth e lido pelo BFF. | oauth + BFF |
| D10 | A rota legada do BFF `/v1/rooms` é **removida**. Só `/api/v1/rooms`. | bff.yaml |

---

## 3. Regras globais (todos os agentes)

1. **Idioma**: código e identificadores em inglês; textos de UI, mensagens de commit, README e relatórios em **português do Brasil** com acentuação correta.
2. **Segredos**: nunca imprimir, copiar ou commitar valores do `.env` da raiz, senhas, client secrets ou tokens. Pode citar **nomes** de variáveis. Não colar tokens em logs de teste.
3. **Escopo de arquivos**: cada agente só altera os arquivos listados como **"Possui"** na sua ficha. Precisa mexer em outro? Para e registra no relatório como "pedido de alteração fora do escopo".
4. **Submódulos**: `backend/rooms`, `backend/bff` e `frontend` são repositórios git próprios. Commit é feito **dentro** do submódulo, seguindo a **regra de branches da seção 3.1**. **Ninguém atualiza ponteiro no repo base, exceto AG-09.** Nunca `git push --force`. Nunca `git stash` sem nome.
5. **Commits**: Conventional Commits em pt-BR. Ex.: `fix(rooms): corrige COPY do contrato no Dockerfile`, `feat(bff-rooms): compõe classes do semestre em curso`, `feat(frontend): tela de lista de salas`. Um commit por passo lógico.
6. **Exclusão lógica**: nunca exibir, compor ou contar registro com `enabled=false`.
7. **Não quebrar outros grupos**: no BFF, `src/common/**`, `src/app.module.ts`, `src/bootstrap.ts`, `package.json` e os módulos courses/students/reservations só podem ser alterados onde a ficha permitir, e a suíte inteira (`npm test -- --runInBand`) tem de continuar verde.
8. **Sem dependências novas sem necessidade**. No BFF, não adicionar pacotes (já há Ajv, Jest, supertest). No frontend, só Angular, Angular Material/CDK e o que o Angular CLI instala por padrão.
9. **Verificação antes de declarar pronto**: rodar os comandos da seção "Verificação" da ficha e colar a saída resumida (últimas linhas) no relatório. Se algo não puder ser rodado (ex.: sem Docker), dizer explicitamente.
10. **Dúvida = parar e perguntar** no relatório, nunca inventar campo, rota, status ou mensagem.

### 3.1 Regra de branches (obrigatória, vale para todo agente e todo repositório)

**Nunca trabalhar, commitar, mergear ou dar push na `main`** (nem em `master`, `develop` ou branch de outro grupo). Somos o **Grupo 08**; toda branch nossa começa com `grupo08`.

Em cada repositório existem dois níveis de branch:

| Repositório | Branch **principal do grupo** (integração; recebe os merges; é a que sobe para o GitHub) | Branches **de desenvolvimento** (onde se coda; saem da principal) |
| --- | --- | --- |
| `frontend` | `grupo08-frontend` | `grupo08-frontend-feat/<slug>` |
| `backend/bff` | `grupo08-bff` | `grupo08-bff-feat/<slug>` |
| `backend/rooms` | `grupo08` (já é a convenção do repositório rooms) | `grupo08-feat/<slug>` |
| repo base `constrsw-2026-2-base` | `grupo08-base` | `grupo08-base-feat/<slug>` (só se precisar) |

> Não usar `grupo08-frontend/<slug>`: o git não deixa existir a branch `grupo08-frontend` e uma `grupo08-frontend/<algo>` ao mesmo tempo. Por isso o sufixo `-feat/`.

**Fluxo de cada agente (copiar literalmente):**

```bash
# 0) entrar no submódulo do seu escopo
cd <submódulo>                         # frontend | backend/bff | backend/rooms
git fetch origin

# 1) garantir a branch principal do grupo (PRINCIPAL = grupo08-frontend | grupo08-bff | grupo08)
#    se já existe no origin:
git checkout PRINCIPAL && git pull --ff-only origin PRINCIPAL
#    se ainda NÃO existe (só o primeiro agente do repositório cria): a partir do origin/main
#    git checkout -b PRINCIPAL origin/main && git push -u origin PRINCIPAL

# 2) criar a sua branch de desenvolvimento A PARTIR da principal
git checkout -b PRINCIPAL-feat/<slug>  # rooms: grupo08-feat/<slug>

# 3) codar e commitar só na branch de desenvolvimento
# 4) entregar o relatório ao REV (seção 8.0)

# 5) só depois do REV responder APROVADO (ou APROVADO COM RESSALVAS já corrigidas):
git checkout PRINCIPAL
git pull --ff-only origin PRINCIPAL
git merge --no-ff PRINCIPAL-feat/<slug> -m "merge: <slug> na PRINCIPAL"
#    rodar de novo a Verificação da sua ficha NA PRINCIPAL; se falhar, desfazer com
#    git reset --hard ORIG_HEAD e avisar o REV
git push origin PRINCIPAL
git push origin PRINCIPAL-feat/<slug>  # opcional, para histórico
```

Regras do fluxo:
- Quem cria a principal de cada repositório (se ela não existir no `origin`): **AG-01** cria `grupo08` no rooms (se não existir), **AG-02** cria `grupo08-bff`, **AG-04** cria `grupo08-frontend`, **AG-09** cria `grupo08-base`. Os demais só fazem `checkout` + `pull`.
- Agentes que rodam em paralelo no mesmo repositório (ex.: AG-05 e AG-06) mergeiam um de cada vez: sempre `pull --ff-only` antes do merge. Conflito no merge → resolver só se for em arquivo de configuração compartilhado (`app.config.ts`, `package.json`, `package-lock.json`); senão `git merge --abort` e avisar o REV.
- Agente de onda posterior **sempre** cria a sua branch de desenvolvimento a partir da principal **atualizada** (que já contém o trabalho aprovado das ondas anteriores). Nunca a partir da branch de desenvolvimento de outro agente.
- O push é **somente** da principal do grupo (e, opcionalmente, da própria branch de desenvolvimento). Nunca push para `main`. PR para a `main` de cada repositório só é aberto pelo grupo, manualmente, quando decidir entregar.
- Correção pedida pelo REV depois do merge: nova branch de desenvolvimento `PRINCIPAL-feat/<slug>-fix` a partir da principal, mesmo fluxo.

---

## 4. Fatos verificados do sistema

### 4.1 Portas e hosts

| Serviço | Host interno (rede docker `constrsw`) | Porta no host | Observação |
| --- | --- | --- | --- |
| frontend (nginx) | `frontend:80` | 8080 | healthcheck `curl http://127.0.0.1/health` |
| BFF (container `api`, serviço `bff`) | `http://api:3001` (ou `bff:3001`) | 8180 | Nest, `PORT`=3001 |
| oauth | `http://oauth:8088` | 8181 | sem CORS |
| rooms | `http://rooms:8105` | 8189 (API), 8389 (métricas 9091) | sem context-path; base `/api/v1` |
| classes | `http://classes:8107` | 8182 | base `/api/v1` |
| keycloak | `http://keycloak:8080` | 8081 | realm `constrsw` |

Variáveis por nome (sem valores): BFF recebe `ROOMS_BASE_URL` (de `BFF_ROOMS_BASE_URL`) e `CLASSES_BASE_URL` (de `BFF_CLASSES_BASE_URL`), `BFF_ORIGIN`, `SESSION_COOKIE_NAME`, `BFF_HTTP_TIMEOUT_MS`, `BFF_HTTP_RETRIES`, `BFF_CIRCUIT_BREAKER_*`. Frontend recebe build args `VITE_OAUTH_BASE_URL=/api/auth` e `VITE_BFF_BASE_URL=/api/bff`.

### 4.2 Backend rooms (`backend/rooms`, Java 21, Spring Boot 4.1.1, PostgreSQL, Flyway V1–V4)

Segurança: JWT do Keycloak (`KEYCLOAK_JWKS_URL`, `iss` em `KEYCLOAK_ALLOWED_ISSUERS`), papéis em `realm_access.roles`.
- Todo GET: `administrator`, `coordinator`, `professor`, `student`.
- POST, PUT, PATCH, DELETE: só `administrator`.
- Anônimos: `GET /api/v1/health`, Swagger, `/v3/api-docs*`, `/openapi/**`.

Endpoints (todos com prefixo `/api/v1`):

| Método | Path | Corpo | Sucesso | Erros |
| --- | --- | --- | --- | --- |
| GET | `/rooms` | — | 200 `Room[]` + `X-Total-Count` | 400, 401, 403, 404 (só com filtro e zero resultados) |
| POST | `/rooms` | RoomCreate | 201 + `Location` + Room | 400, 401, 403, 409, 503 |
| GET | `/rooms/{id}` | — | 200 Room | 400 (não UUID), 401, 403, 404 |
| PUT | `/rooms/{id}` | RoomUpdate | 200 Room | 400, 401, 403, 404, 409, 503 |
| PATCH | `/rooms/{id}` | RoomPatch (≥1 campo) | 200 Room | 400, 401, 403, 404, 409, 503 |
| DELETE | `/rooms/{id}` | — | 204 | 400, 401, 403, 404 |
| GET | `/rooms/{id}/accessibility-features` | — | 200 `AccessibilityFeature[]` + `X-Total-Count` | 400, 401, 403, 404 (sala inexistente **ou** filtro sem resultado) |
| POST | `/rooms/{id}/accessibility-features` | AccessibilityFeatureCreate | 201 + `Location` | 400, 401, 403, 404 |
| GET | `/rooms/{id}/accessibility-features/{featureId}` | — | 200 | 400, 401, 403, 404 |
| PUT | idem | AccessibilityFeatureUpdate | 200 | 400, 401, 403, 404 |
| PATCH | idem | AccessibilityFeaturePatch (≥1 campo) | 200 | 400, 401, 403, 404 |
| DELETE | idem | — | 204 | 400, 401, 403, 404 |
| GET | `/health` | — | 200 `{status:"UP"}` / 503 | — |

Query de `GET /rooms`:
- Filtros: `code`, `name`, `building` (texto), `capacity` (inteiro, sem `like`), `active` (booleano, só igualdade e `{neq}`), `resourceIds` (um UUID, só igualdade).
- Formato do valor: `valor` ou `{op}valor`, `op` ∈ `neq | gt | gteq | lt | lteq | like`. `like` usa `%` como curinga e ignora caixa. Ex.: `capacity={gteq}40`, `name={like}%lab%`. No fio, `{`→`%7B`, `}`→`%7D`, `%`→`%25`.
- `sort=<attr>[,asc|desc]`, `attr` ∈ `code|name|building|capacity|active`.
- `page` ≥ 0 (começa em 0), `size` 1–100. Só um informado: o outro vira 0 ou 20. Nenhum: lista inteira.
- Sala sem capacidade não casa com nenhum filtro de `capacity`.

Query de `GET /rooms/{id}/accessibility-features`: `code`, `description` (texto), `present` (booleano), `sort` (`code|description|present`), `page`, `size`.

Schemas:

**Room** (resposta, `additionalProperties:false`, todos obrigatórios)

| Campo | Tipo | Regra |
| --- | --- | --- |
| `id` | uuid | readOnly |
| `code` | string | 1–20, sem só espaços, único entre salas habilitadas |
| `name` | string | 1–100 |
| `building` | string | 1–50 |
| `capacity` | integer \| null | ≥ 1 |
| `active` | boolean | default true |
| `enabled` | boolean | readOnly; sempre `true` nas respostas |
| `resourceIds` | uuid[] | únicos, default `[]`; um recurso fica em no máximo uma sala |

- **RoomCreate**: obrigatórios `code`, `name`, `building`. Omitidos viram `capacity=null`, `active=true`, `resourceIds=[]`. Enviar `enabled` dá 400.
- **RoomUpdate (PUT)**: obrigatórios `code`, `name`, `building`, `capacity` (a chave precisa existir; aceita null), `active`, `resourceIds`.
- **RoomPatch**: ≥ 1 campo. `capacity: null` limpa. **Os schemas de patch têm `default`; nunca enviar defaults num PATCH, só os campos alterados.**

**AccessibilityFeature** (resposta)

| Campo | Tipo | Regra |
| --- | --- | --- |
| `id` | uuid | readOnly |
| `roomId` | uuid | readOnly |
| `code` | string | 1–30, `^[A-Z][A-Z0-9_]*$` (ex.: RAMP, ELEVATOR, TACTILE_FLOOR, BRAILLE_SIGN, ADAPTED_DESK) |
| `description` | string \| null | ≤ 255 |
| `present` | boolean | default true |
| `enabled` | boolean | readOnly |

- **Create**: obrigatório só `code`. **Update (PUT)**: `code`, `description` (aceita null), `present`. **Patch**: ≥ 1 campo. Não há unicidade de `code` por sala (sem 409).

**Envelope de erro do rooms** (`application/json`):
```json
{ "error_code": "RM-409", "error_description": "…", "error_source": "RoomsAPI", "error_stack": [] }
```

Exclusão lógica: DELETE de sala grava `enabled=false` na sala e nas features e solta os recursos; depois GET/PUT/PATCH/DELETE dão 404 e o `code` pode ser reusado.

### 4.3 Classes (`backend/classes`, Kotlin/Spring)

- `GET http://classes:8107/api/v1/classes?year=Y&semester=S[&roomId=<uuid>]` (filtro implementado em `ClassController.kt` e `JdbcClassRepositoryAdapter.kt`; coluna `room_id`).
- Resposta: **array JSON puro**, sem paginação, sem `X-Total-Count`, ordenado por `start_date DESC, id ASC`, já sem `enabled=false`.
- `roomId` inválido (não UUID) → 400. Sem token → 401 `application/problem+json`.
- **Escopo por papel** dentro do `findAll`: coordinator/administrator veem todas; professor só `professor_id` = ele; student só as que cursa; outros papéis → `200 []`.
- **Class** (campos): `id`, `enabled`, `courseId`, `startDate`, `endDate`, `year`, `semester`, `seats`, `roomId`, `professorId`, `studentIds`, `code`, `label`, `status`, `modality`, `averageRating`. Conferir tipos exatos em `docs/open-api/grupo01-classes-api.yaml` / `docs/open-api/grupo01-classes-schemas.json`.
- README do classes (`/v1/classes`, envelope `items`) está **desatualizado**; valem código e contrato.

### 4.4 Semestre em curso

- Fuso `America/Sao_Paulo`. `year` = ano civil; `semester` = 1 se mês < 8 (jan–jul), 2 se mês ≥ 8 (ago–dez). Em 24/11/2026: 2026/2.
- Implementação pronta: `backend/bff/src/common/academic/current-semester.ts` → `currentSemester(now = new Date()): { year: number; semester: 1 | 2 }`. (Existe uma cópia em `src/modules/courses/current-semester.ts`; **não** usar a cópia.)
- O cliente **nunca** envia `year`/`semester` ao BFF.

### 4.5 BFF (`backend/bff`, NestJS 12, TypeScript 6, Node ≥ 24.15, Express 5, Jest 30 ESM)

Estrutura relevante:
- `src/app.module.ts`: registra Courses, Reservations, Rooms, Students (ordem alfabética). `RoomsModule` já está registrado.
- `src/bootstrap.ts` (`configureApp`): métricas, CORS com credentials (expõe `Location`, `X-Total-Count`, `Retry-After`), bloqueio de escrita via cookie com `Origin` ≠ `BFF_ORIGIN` (403 `CO-403`), parsers de corpo (há `raw` dedicado a `/api/v1/courses`).
- `src/common/http/downstream.service.ts`: `DownstreamService.send({ method, path, body?, contentType?, bearerToken?, signal? })` → `{ status, body: string, contentType, headers?, location? }`. Timeout, retry com backoff, circuit breaker (`circuit-breaker.ts`), `redirect: 'manual'`. Repassa só os headers `location`, `x-total-count`, `retry-after`, `www-authenticate`, `etag`, `last-modified`, `cache-control`. Lança `DownstreamUnavailableError` quando cai ou o circuito abre; 4xx/5xx **não** lançam (5xx conta como falha no circuito). Aceita opção `retryMethods` (o courses usa `['GET','HEAD']`).
- `src/common/auth/bearer-token.ts`: `bearerTokenOf(request)` → header `Authorization: Bearer` ou, sem header, `request.bearerToken`, ou cookie `SESSION_COOKIE_NAME` (default `closed_cras_session`, JSON com `access_token`, pode ter prefixo `j:`).
- Sem ValidationPipe nem DTOs: o BFF repassa o corpo; o domínio valida.
- **Módulo modelo de composição: `src/modules/courses/`** (`courses.module.ts`, `courses.controller.ts`, `courses.service.ts`, `composition-contract.ts`), testes `src/courses.contract.spec.ts`, `src/courses.integration.spec.ts`, `test/e2e/courses.e2e-spec.ts`. Design e histórico: `docs/superpowers/specs/2026-11-23-courses-bff-design.md`, `docs/superpowers/plans/2026-11-23-courses-bff-progress.md`.
- **Módulo modelo do erro 503: `src/modules/students/`** (`dependencyProblem()` com `type: 'urn:closed-cras:bff:dependency'`, `code: 'BFF-DEPENDENCY'`). **Atenção:** o `send()` do students perde `location` e `x-total-count`; não copiar esse trecho.
- **Rooms hoje (`src/modules/rooms/`)**: `rooms.module.ts` (só `ROOMS_DOWNSTREAM`, sem `retryMethods` → PUT/DELETE são repetidos: bug), `rooms.service.ts` (`DOMAIN_PREFIX='/api/v1/rooms'`, 503 problem+json `BFF-DOWNSTREAM-UNAVAILABLE`), `rooms.controller.ts` (`@Controller('v1/rooms')`, `@All` em `''`, `:id`, `:id/accessibility-features`, `:id/accessibility-features/:featureId`; sem proteção de `.`/`..`; sem `AbortSignal`; reserializa corpo com `JSON.stringify`), `rooms.contract.spec.ts` (12 testes, ids `'abc'`).
- Testes: `npm test -- --runInBand`, `npm run test:contract` (`scripts/validate-contract.cjs`, hoje só courses, `assert.equal(count, 19)`), `npm run build`, `npm run test:e2e:courses|students|reservations` (não há `rooms`). Helpers: `src/testing/http-fixture.ts`, `src/testing/domain-fixtures.ts`, `test/e2e/support/e2e-env.ts` (`urls`, `setting`, `http`, `accessToken`, `waitForBff`, `currentSemester`), `test/jest-e2e.json`.
- Override de compose de referência: `compose.courses.yaml` (usa `depends_on: !override`).
- Dockerfile: multi-stage `node:24-alpine`, copia `openapi/` para runtime, porta 3001.

### 4.6 Contrato do BFF para rooms (`docs/open-api/bff.yaml`)

- Origem `http://localhost:8180`, prefixo `/api/v1`, tag `rooms`, segurança global `bearerAuth` (só `/health` anônimo).
- `GET /api/v1/rooms` (`listRooms`): mesmos 9 parâmetros do backend (code, name, building, capacity, active, resourceIds, sort, page, size), mesmo `X-Total-Count`, mesmo 404. 200 → `RoomViewList` (array de `RoomView`). 400/401/403/404 vêm do backend. 503 `CompositionUnavailable`.
- `GET /api/v1/rooms/{id}` (`getRoom`): 200 → `RoomView`; 400/401/403/404 do backend; 503 de composição.
- `POST /api/v1/rooms`, `PUT|PATCH|DELETE /api/v1/rooms/{id}`, todo `/api/v1/rooms/{id}/accessibility-features[/{featureId}]`: **proxy puro** (status, corpo, headers do rooms; sem `classes`).
- `RoomView` = `allOf[Room, { required: [classes], classes: Class[] }]`. Sem turmas → `classes: []`.
- Composição: "sediada" = `roomId` igual ao id da sala **e** year/semester do semestre em curso. Não filtrar por `status`.
- 503 de composição: `application/problem+json`, schema `Problem` com `type`, `title`, `status` (400–599), `detail`, `code` (= `"BFF-DEPENDENCY"`) obrigatórios e `instance` opcional. A sala **nunca** volta pela metade.
- `GET /api/v1/identidade/me` (módulo reservations do BFF): `{ sub, email, papeis[], employeeId, professorId, studentId }`.
- O health do rooms não é exposto pelo BFF; o BFF tem `/health` próprio.

### 4.7 OAuth (`backend/oauth`) e Keycloak

| Método | Path (no oauth) | Entrada | Sucesso | Erros |
| --- | --- | --- | --- | --- |
| POST | `/login` | `multipart/form-data`: `username` (e-mail), `password` | **201** `{token_type, access_token, expires_in, refresh_token, refresh_expires_in}` + cookie | 400, 401, 503 |
| POST | `/refresh` | sem corpo (lê cookie) | 201, mesmo corpo, regrava cookie | 400/401 (refresh vencido) |
| POST | `/logout` | sem corpo | 201 `{status:"signed_out"}` (só limpa cookie) | — |
| GET | `/health` | — | 200 `{status:"ok",service:"oauth"}` | — |

- Cookie: `closed_cras_session`, httpOnly, SameSite=lax, Secure=false, path `/`, valor JSON `{access_token, refresh_token}`.
- Erro do oauth: `{ error_code: "OA-<status>", error_description (pt-BR), error_source: "OAuthAPI", error_stack: [] }`.
- Access token dura 10 min; sessão ociosa 30 min. Logout não revoga o token no Keycloak.
- Usuários de teste: `admin@pucrs.br` (administrator), `coordinator@pucrs.br`, `professor@pucrs.br`, `student@pucrs.br`. Senha no README do keycloak (não copiar para o código).
- E2E do BFF deve pegar token via `POST {oauth}/login` (token direto do Keycloak tem `iss` diferente).

### 4.8 UX (fonte: `_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/`)

Hierarquia: SPEC (`_bmad-output/specs/spec-closed-cras/SPEC.md`) > `EXPERIENCE.md` (fluxos, microcopy) > `DESIGN.md` (tokens) > Figma > mock HTML (`mockups/closed-cras-responsivo.html`). Prints de referência: `.working/qa/responsive/salas-*.png`, `sala-detalhe-*.png`, `login*`, `home*`. Mapa Figma: `.working/figma-frame-map.md`.

- Tokens: primary `#0066B3`, navy `#0A2540`, tertiary `#6DCDF6`, gold `#C4A035` (só aviso, nunca CTA), error `#B1101A`, fundo `#F5F8FC`, outline `#C5D0DE`. Fontes Source Sans 3 (texto) e Source Code Pro (códigos). Grade 8dp.
- Medidas: botão 40dp (alvo de toque 48), app bar 64dp com faixa tertiary 4dp, campo 56dp, linha de tabela 52dp, linha de lista compact 72dp, dialog 560px (tela cheia em compact), confirm-dialog 400px, busca 320px, drawer 280px.
- Breakpoints: compact 360–599, medium 600–1023, expanded ≥ 1024 (drawer fixo; 2 colunas no detalhe a partir de 1280).
- Menu (ordem fixa, 10 itens): Funcionários, Professores, Alunos, **Salas de Aula**, Recursos, Disciplinas, Turmas, Ocupação, Plano + roster, Minhas aulas. Abaixo de 1024px vira folha modal; Esc fecha.
- Microcopy obrigatória: login 401 "Não foi possível entrar. Verifique usuário e senha."; identidade 503/rede "Identidade indisponível."; composição 503 "Serviço de composição indisponível." + botão "Tentar novamente"; lista vazia "Nenhuma sala cadastrada ainda." + CTA "Nova sala". **Os demais textos devem ser copiados do EXPERIENCE.md**; se não existirem lá, usar os desta ficha.

---

## 5. Arquitetura alvo

```
Navegador (Angular SPA, http://localhost:8080)
   │  mesma origem, cookie closed_cras_session (httpOnly)
   ▼
nginx (container frontend :80)
   ├── /                 → arquivos estáticos (fallback index.html)
   ├── /health           → 200 "ok"
   ├── /api/auth/*       → http://oauth:8088/*      (remove /api/auth)
   └── /api/bff/*        → http://api:3001/*        (remove /api/bff)
                              │
                              ▼
                     BFF NestJS (:3001)  módulo rooms
                       ├── GET /api/v1/rooms, /api/v1/rooms/{id}
                       │     ├── rooms:8105  GET /api/v1/rooms[...]
                       │     └── classes:8107 GET /api/v1/classes?year&semester[&roomId]
                       │     → compõe RoomView (classes[])
                       └── demais verbos e accessibility-features → proxy puro para rooms:8105
```

Token: o navegador nunca vê o token. O oauth grava o cookie; o nginx repassa o cookie; o BFF extrai `access_token` (`bearerTokenOf`) e envia `Authorization: Bearer` ao rooms e ao classes.

---

## 6. Interfaces combinadas entre agentes

Estas interfaces existem para que agentes em paralelo não se choquem. **Nenhum agente muda uma interface desta seção sem aprovação do REV.**

### 6.1 BFF: assinatura interna do módulo rooms (AG-02 implementa, AG-03 testa)

```ts
// src/modules/rooms/rooms.module.ts — tokens de injeção
export const ROOMS_DOWNSTREAM = 'ROOMS_DOWNSTREAM';
export const ROOMS_CLASSES_DOWNSTREAM = 'ROOMS_CLASSES_DOWNSTREAM';
export const ROOMS_CLOCK = 'ROOMS_CLOCK';            // useValue: () => new Date()

// src/modules/rooms/rooms.service.ts
export type RoomsCompose = 'collection' | 'item';
export interface RoomsForwardRequest {
  method: string;                 // GET, POST, PUT, PATCH, DELETE, HEAD
  suffix: string;                 // '' | '/{id}' | '/{id}/accessibility-features' | '/{id}/accessibility-features/{featureId}'
  query: string;                  // query string crua, com '?' ou ''
  body?: Buffer | string;
  contentType?: string;
  bearerToken?: string;
  signal?: AbortSignal;
  roomId?: string;                // presente quando compose === 'item'
}
export interface RoomsForwardResponse {
  status: number;
  body: string;
  contentType?: string;
  headers: Record<string, string>; // inclui x-total-count, location quando houver
}
// RoomsService.forward(req: RoomsForwardRequest, compose?: RoomsCompose): Promise<RoomsForwardResponse>
```

Se o código existente do courses usar nomes diferentes, AG-02 pode alinhar ao estilo do courses **desde que** mantenha os três tokens de injeção acima com esses nomes exatos (AG-03 depende deles para `overrideProvider`).

### 6.2 BFF: corpo do 503 de composição

```json
{
  "type": "urn:closed-cras:bff:dependency",
  "title": "Serviço de composição indisponível",
  "status": 503,
  "detail": "Não foi possível obter as turmas do semestre em curso.",
  "code": "BFF-DEPENDENCY"
}
```
`Content-Type: application/problem+json`. Pode haver `instance` (path da requisição).

### 6.3 Frontend: estrutura de pastas (AG-04 cria, os outros preenchem)

```
frontend/
├── Dockerfile
├── nginx.conf
├── proxy.conf.json
├── .dockerignore
├── README.md
├── angular.json, package.json, tsconfig*.json
└── src/
    ├── main.ts
    ├── index.html
    ├── styles.scss                       (AG-04)
    ├── styles/                           (AG-04: _tokens.scss, _theme.scss, _typography.scss)
    ├── environments/ ou public/config.json  (AG-04)
    └── app/
        ├── app.config.ts                 (AG-04; AG-05 só adiciona o interceptor na linha marcada)
        ├── app.routes.ts                 (AG-04; rotas já declaradas com lazy loading)
        ├── app.component.ts              (AG-04)
        ├── core/
        │   ├── config/app-config.ts      (AG-04)
        │   ├── layout/                   (AG-04: shell, app-bar, nav-drawer, nav-items.ts)
        │   ├── auth/                     (AG-05: auth.service.ts, auth.interceptor.ts, auth.guard.ts, identity.model.ts)
        │   ├── http/                     (AG-06: api-error.ts, error-parser.ts, filter-query.ts)
        │   └── ui/                       (AG-04: confirm-dialog, refusal-banner, error-banner, skeleton, empty-state)
        ├── features/
        │   ├── login/                    (AG-05: login.page.ts|html|scss)
        │   ├── home/                     (AG-04: home.page.ts — boas-vindas simples)
        │   ├── placeholder/              (AG-04: placeholder.page.ts para itens do menu de outros grupos)
        │   └── rooms/
        │       ├── data/                 (AG-06: rooms.models.ts, rooms-api.service.ts, *.spec.ts)
        │       ├── list/                 (AG-07: rooms-list.page.ts|html|scss, room-form.dialog.ts)
        │       └── detail/               (AG-08: room-detail.page.ts|html|scss, feature-form.dialog.ts, room-classes.component.ts)
        └── shared/                       (AG-04: pipes/format utilitários, se precisar)
```

**Regra de conflito**: `room-form.dialog.ts` pertence ao AG-07 (lista) e é **reusado** pelo AG-08 (detalhe) para "Editar sala". AG-08 não altera esse arquivo; se precisar de algo, pede no relatório.

### 6.4 Frontend: rotas (AG-04 declara)

```ts
export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./features/login/login.page').then(m => m.LoginPage) },
  {
    path: '',
    canActivate: [authGuard],                 // AG-04 cria um stub que retorna true; AG-05 implementa de verdade
    loadComponent: () => import('./core/layout/shell.component').then(m => m.ShellComponent),
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'salas' },
      { path: 'salas', loadComponent: () => import('./features/rooms/list/rooms-list.page').then(m => m.RoomsListPage), title: 'Salas de Aula' },
      { path: 'salas/:id', loadComponent: () => import('./features/rooms/detail/room-detail.page').then(m => m.RoomDetailPage), title: 'Sala' },
      { path: 'em-breve/:slug', loadComponent: () => import('./features/placeholder/placeholder.page').then(m => m.PlaceholderPage) },
    ],
  },
  { path: '**', redirectTo: '' },
];
```
AG-04 cria **arquivos stub** para `LoginPage`, `RoomsListPage` e `RoomDetailPage` (componente vazio com título), para o app compilar desde a Onda 1. AG-05, AG-07 e AG-08 substituem o conteúdo desses stubs.

### 6.5 Frontend: configuração

```ts
// src/app/core/config/app-config.ts
export interface AppConfig { oauthBaseUrl: string; bffBaseUrl: string; }   // ex.: '/api/auth', '/api/bff'
export const APP_CONFIG = new InjectionToken<AppConfig>('APP_CONFIG');
```
Valores vêm de `public/config.json` gerado no Dockerfile a partir de `VITE_OAUTH_BASE_URL` e `VITE_BFF_BASE_URL` (defaults `/api/auth` e `/api/bff`). Carregado no bootstrap (`provideAppInitializer`) ou com valores default em `environment.ts`. **Os nomes dos build args do compose não mudam.**

### 6.6 Frontend: AuthService (AG-05 implementa; AG-04 cria stub com a mesma assinatura)

```ts
export interface Identity { sub: string; email: string; papeis: string[]; employeeId?: string | null; professorId?: string | null; studentId?: string | null; }
@Injectable({ providedIn: 'root' })
export class AuthService {
  readonly identity: Signal<Identity | null>;
  readonly isAuthenticated: Signal<boolean>;
  readonly isAdmin: Signal<boolean>;           // papeis inclui 'administrator'
  readonly seesAllClasses: Signal<boolean>;    // papeis inclui 'administrator' ou 'coordinator'
  login(username: string, password: string): Promise<void>;   // lança LoginError {kind: 'invalid' | 'unavailable' | 'validation', message}
  logout(): Promise<void>;
  loadIdentity(): Promise<Identity | null>;    // GET {bff}/api/v1/identidade/me
  refresh(): Promise<boolean>;                 // single-flight
}
```

### 6.7 Frontend: modelos e serviço de rooms (AG-06 implementa; AG-07 e AG-08 consomem)

```ts
// src/app/features/rooms/data/rooms.models.ts
export interface Room { id: string; code: string; name: string; building: string; capacity: number | null; active: boolean; enabled: boolean; resourceIds: string[]; }
export interface ClassSummary { id: string; code: string; label: string; status: string; modality: string; startDate: string; endDate: string; year: number; semester: number; seats: number; courseId: string; professorId: string | null; roomId: string; enabled: boolean; averageRating?: number | null; }
export interface RoomView extends Room { classes: ClassSummary[]; }
export interface AccessibilityFeature { id: string; roomId: string; code: string; description: string | null; present: boolean; enabled: boolean; }
export type RoomCreate = { code: string; name: string; building: string; capacity?: number | null; active?: boolean; resourceIds?: string[] };
export type RoomUpdate = { code: string; name: string; building: string; capacity: number | null; active: boolean; resourceIds: string[] };
export type RoomPatch = Partial<RoomUpdate>;
export type FeatureCreate = { code: string; description?: string | null; present?: boolean };
export type FeatureUpdate = { code: string; description: string | null; present: boolean };
export type FeaturePatch = Partial<FeatureUpdate>;

export type FilterOp = 'eq' | 'neq' | 'gt' | 'gteq' | 'lt' | 'lteq' | 'like';
export interface RoomFilter { field: 'code' | 'name' | 'building' | 'capacity' | 'active' | 'resourceIds'; op: FilterOp; value: string | number | boolean; }
export interface RoomQuery { filters?: RoomFilter[]; sort?: { field: 'code' | 'name' | 'building' | 'capacity' | 'active'; dir: 'asc' | 'desc' }; page?: number; size?: number; }
export interface Page<T> { items: T[]; total: number; }

// src/app/core/http/api-error.ts
export type ApiErrorKind = 'composition-unavailable' | 'domain' | 'unauthorized' | 'forbidden' | 'not-found' | 'conflict' | 'validation' | 'network' | 'unknown';
export interface ApiError { kind: ApiErrorKind; status: number; code?: string; message: string; raw?: unknown; }
```

```ts
// src/app/features/rooms/data/rooms-api.service.ts
@Injectable({ providedIn: 'root' })
export class RoomsApiService {
  list(query: RoomQuery): Observable<Page<RoomView>>;     // 404 → { items: [], total: 0 }
  get(id: string): Observable<RoomView>;
  create(body: RoomCreate): Observable<Room>;
  update(id: string, body: RoomUpdate): Observable<Room>;
  patch(id: string, body: RoomPatch): Observable<Room>;    // envia só o que veio em body
  remove(id: string): Observable<void>;
  listFeatures(roomId: string, query?: { filters?: {field:'code'|'description'|'present'; op: FilterOp; value: string|boolean}[]; sort?: {field:'code'|'description'|'present'; dir:'asc'|'desc'}; page?: number; size?: number }): Observable<Page<AccessibilityFeature>>; // 404 → vazio SE a sala existir (ver AG-06)
  getFeature(roomId: string, featureId: string): Observable<AccessibilityFeature>;
  createFeature(roomId: string, body: FeatureCreate): Observable<AccessibilityFeature>;
  updateFeature(roomId: string, featureId: string, body: FeatureUpdate): Observable<AccessibilityFeature>;
  patchFeature(roomId: string, featureId: string, body: FeaturePatch): Observable<AccessibilityFeature>;
  removeFeature(roomId: string, featureId: string): Observable<void>;
}
```
Todos os erros chegam ao componente como `ApiError` (seção 6.7, `api-error.ts`), nunca como `HttpErrorResponse` cru.

### 6.8 Frontend: componentes de UI compartilhados (AG-04 cria)

| Componente | Seletor | Entradas / saídas |
| --- | --- | --- |
| `ConfirmDialogComponent` | (dialog) | data `{ title, message, confirmLabel, destructive: boolean }` → fecha com `true/false` |
| `RefusalBannerComponent` | `app-refusal-banner` | `@Input() message`, `role="alert"` |
| `ErrorBannerComponent` | `app-error-banner` | `@Input() message`, `@Input() retryLabel = 'Tentar novamente'`, `@Output() retry` |
| `EmptyStateComponent` | `app-empty-state` | `@Input() message`, `@Input() actionLabel?`, `@Output() action` |
| `SkeletonComponent` | `app-skeleton` | `@Input() rows = 5`, `@Input() variant: 'table' \| 'card'` |

---

## 7. Roster de agentes, ondas e dependências

### 7.1 Quantos agentes e por quê

**9 agentes de desenvolvimento (Gemini Argon) + 1 revisor (Claude) = 10.**

Motivo: três repositórios independentes (rooms, bff, frontend) e, dentro do frontend, quatro fatias que podem andar em paralelo depois do esqueleto (auth, dados, lista, detalhe). Mais agentes que isso gera conflito de arquivo no frontend; menos que isso serializa trabalho que pode ser paralelo.

| ID | Nome | Repositório | Branch | Onda | Depende de |
| --- | --- | --- | --- | --- | --- |
| ID | Nome | Repositório | Principal do grupo (merge + push) | Branch de desenvolvimento (sai da principal) | Onda | Depende de |
| --- | --- | --- | --- | --- | --- | --- |
| AG-01 | Rooms Backend Fixer | `backend/rooms` | `grupo08` | `grupo08-feat/t3-fix-build-health` | 1 | — |
| AG-02 | BFF Rooms Core | `backend/bff` | `grupo08-bff` (AG-02 cria) | `grupo08-bff-feat/rooms-core` | 1 | — |
| AG-03 | BFF Rooms Testes e Contrato | `backend/bff` | `grupo08-bff` | `grupo08-bff-feat/rooms-tests` | 2 | AG-02 aprovado e mergeado |
| AG-04 | Frontend Fundação | `frontend` | `grupo08-frontend` (AG-04 cria) | `grupo08-frontend-feat/base` | 1 | — |
| AG-05 | Frontend Auth e Shell | `frontend` | `grupo08-frontend` | `grupo08-frontend-feat/auth` | 2 | AG-04 aprovado e mergeado |
| AG-06 | Frontend Dados de Rooms | `frontend` | `grupo08-frontend` | `grupo08-frontend-feat/rooms-data` | 2 | AG-04 aprovado e mergeado |
| AG-07 | Frontend Lista de Salas | `frontend` | `grupo08-frontend` | `grupo08-frontend-feat/rooms-list` | 3 | AG-05 e AG-06 aprovados e mergeados |
| AG-08 | Frontend Detalhe de Sala | `frontend` | `grupo08-frontend` | `grupo08-frontend-feat/rooms-detail` | 3 | AG-05 e AG-06 aprovados e mergeados |
| AG-09 | Integrador e Entrega | base + 3 submódulos | `grupo08-base` (AG-09 cria) | — | 4 | todos aprovados e mergeados |
| REV | Revisor | todos | — | — | após cada agente | — |

> AG-08 usa `room-form.dialog.ts` do AG-07. Para não bloquear, AG-08 **importa** o dialog pelo caminho combinado (6.3) e, até o AG-07 mergear em `grupo08-frontend`, usa um stub local **não commitado**; antes de pedir revisão, AG-08 faz `git merge grupo08-frontend` na sua branch para pegar o dialog real. Alternativa mais simples se o Orca não lidar bem com isso: rodar AG-08 **depois** do AG-07 (Onda 3b), criando a branch já com o dialog na principal.

### 7.2 Linha do tempo

```
Onda 1 (paralelo):  AG-01  |  AG-02  |  AG-04
                       ↓ REV     ↓ REV     ↓ REV
Onda 2 (paralelo):          AG-03  |  AG-05  |  AG-06
                              ↓ REV    ↓ REV    ↓ REV
Onda 3 (paralelo):                    AG-07  |  AG-08   (ou 3a: AG-07, 3b: AG-08)
                                        ↓ REV    ↓ REV
Onda 4:                                    AG-09
                                             ↓ REV final
```

### 7.3 Portões do REV

Cada entrega passa por: (1) relatório do agente, (2) REV roda checklist da seção 9, (3) REV responde **APROVADO**, **APROVADO COM RESSALVAS** (lista curta, o mesmo agente corrige sem nova onda) ou **REPROVADO** (o mesmo agente refaz). Só **APROVADO** libera dependentes.

---

## 8. Fichas dos agentes

### 8.0 Formato obrigatório do relatório de entrega (todos)

```markdown
## Relatório de entrega — <ID> <Nome>
**Branch / commits:** <branch> — <hash curto + mensagem de cada commit>
**Arquivos alterados:** <lista>
**O que foi feito:** <bullets, 1 por tarefa da ficha, com status ✅/⚠️/❌>
**Verificação:** <comandos rodados + últimas linhas da saída>
**Critérios de aceite:** <cada critério da ficha com ✅/❌ e evidência>
**Pedidos fora do escopo:** <arquivo + motivo, ou "nenhum">
**Dúvidas / contradições encontradas:** <ou "nenhuma">
**Riscos conhecidos que ficaram:** <ou "nenhum">
```

---

### 8.1 AG-01 — Rooms Backend Fixer

**Prompt (colar no agente):**

> Você é o AG-01 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.2 e esta ficha inteira antes de começar). Trabalhe só no submódulo `backend/rooms` (Java 21, Spring Boot 4.1.1, Maven). Objetivo: corrigir build, health e testes **sem alterar nenhum endpoint, campo, status ou schema** do contrato `backend/rooms/openapi.yaml` (que é idêntico a `docs/open-api/grupo08-rooms-api.yaml`). Siga a regra de branches da seção 3.1: principal `grupo08` (se não existir no `origin`, crie a partir de `origin/main` e dê push), desenvolvimento `grupo08-feat/t3-fix-build-health` criada a partir de `grupo08`; após o APROVADO do REV, merge `--no-ff` em `grupo08` e push de `grupo08`. Ao terminar, entregue o relatório no formato da seção 8.0.

**Leia antes:** `backend/rooms/Dockerfile`, `backend/rooms/pom.xml` (procure onde `openapi.yaml` e `schemas/` são copiados para o jar), `backend/rooms/README.md`, `backend/rooms/e2e/run.sh`, `backend/rooms/scripts/trafego.sh`, `backend/rooms/scripts/testar.sh`, `backend/rooms/e2e/bruno/05-permissoes/` (arquivo 09), `src/main/java/**/HealthCompatibilityController*`, `src/test/java/**/ContractCoverageIntegrationTests*`, `src/main/resources/application.yml`, `src/main/resources/db/migration/V4*`.

**Possui:** `backend/rooms/Dockerfile`, `backend/rooms/README.md`, `backend/rooms/e2e/run.sh`, `backend/rooms/scripts/*.sh`, `backend/rooms/e2e/bruno/**`, `backend/rooms/src/test/**`, `backend/rooms/_bmad-output/**`. **Não toque** em `src/main/**`, `openapi.yaml`, `schemas/**` (salvo pedido aprovado pelo REV).

**Tarefas:**
1. **Dockerfile** — `backend/rooms/Dockerfile:12` faz `COPY openapi ./openapi`, mas a pasta não existe. Veja no `pom.xml` como o build Maven inclui o contrato no jar (provável `<resources>` apontando para `openapi.yaml` e `schemas/`). Substitua a linha por `COPY openapi.yaml ./openapi.yaml` e `COPY schemas ./schemas` (ou o que o `pom.xml` exigir) **antes** do passo de build Maven, para que o jar final sirva `/openapi/openapi.yaml`. Não mude a imagem base nem o usuário.
2. **Health** — o código expõe `GET /api/v1/health` (anônimo, 200 `{"status":"UP"}`). Troque toda chamada a `/actuator/health` na porta da API (8105) por `/api/v1/health` em: `README.md`, `e2e/run.sh`, `scripts/trafego.sh`, Bruno `05-permissoes/09*` e qualquer outro script encontrado por `grep -rn "actuator/health" backend/rooms`. Na porta de gestão (9091) o caminho é `/health`; não confundir.
3. **Teste de cobertura de contrato** — `ContractCoverageIntegrationTests` deve falhar porque o contrato declara `GET /api/v1/health` 200 e 503 sem cenário. Adicione cenário para 200 (chamada anônima) e inclua 503 em `COVERED_ELSEWHERE` com comentário explicando que exige derrubar o banco, **ou** crie cenário 503 se houver um jeito limpo já usado no projeto (ex.: mock do `HealthIndicator`). Não desligar o teste.
4. **README** — corrigir: caminho do contrato (`openapi.yaml` e `schemas/` na raiz do submódulo, não `openapi/`); lista de migrações com V4 (`enabled` em `rooms` e `accessibility_features`; `ak_rooms_code` virou índice único parcial `WHERE enabled`); DELETE é lógico (sala e features ficam `enabled=false`, recursos são soltos; nada de cascata física); health em `/api/v1/health`; nota de que o diagrama lógico PNG não mostra `enabled`.
5. **Planejamento** — em `backend/rooms/_bmad-output/implementation-artifacts/sprint-status.yaml`, marque a story 4-4 conforme o estado real (pergunte no relatório se a tag `release-1.0-grupo08` já foi enviada; se `git tag -l` mostrar a tag, marque `done`). Em `backend/rooms/_bmad-output/planning-artifacts/epics.md`, acrescente ao final: "Épico 6 — BFF rooms (T3)" e "Épico 7 — Frontend rooms (T4)", cada um com 1 parágrafo apontando para este plano. Não reescrever o resto.

**Verificação:**
```bash
cd backend/rooms
./mvnw -q verify                       # exige Docker (Testcontainers)
docker build -t rooms-check .          # imagem compila
docker run --rm -d --name rooms-check -p 18105:8105 rooms-check   # pode falhar ao conectar no banco: tudo bem, o objetivo é o build
grep -rn "actuator/health" .           # só deve sobrar o que for porta 9091 ou nenhum
```
Se não houver Docker na máquina do agente, rodar ao menos `./mvnw -q -DskipTests package` e dizer no relatório que `verify` e `docker build` não foram executados.

**Critérios de aceite:**
- [ ] `docker build` do submódulo passa.
- [ ] `./mvnw verify` verde (ou justificativa clara).
- [ ] Nenhuma alteração em `src/main/**`, `openapi.yaml`, `schemas/**`.
- [ ] `grep actuator/health` sem ocorrências indevidas.
- [ ] README coerente com V4 e exclusão lógica.

**Commits sugeridos:** `fix(rooms): corrige cópia do contrato no Dockerfile`, `fix(rooms): usa /api/v1/health em scripts, e2e e README`, `test(rooms): cobre GET /api/v1/health na auditoria de contrato`, `docs(rooms): atualiza README com V4 e exclusão lógica`, `docs(rooms): registra épicos 6 e 7`.

---

### 8.2 AG-02 — BFF Rooms Core

**Prompt:**

> Você é o AG-02 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.3–4.6, 6.1, 6.2 e esta ficha). Trabalhe só no submódulo `backend/bff` (NestJS). Objetivo: transformar `src/modules/rooms/` do proxy legado `/v1/rooms` em `/api/v1/rooms` com composição das classes do semestre em curso nos dois GETs, seguindo exatamente `docs/open-api/bff.yaml`. Use `src/modules/courses/` como modelo de composição e `src/modules/students/` como modelo do 503 `BFF-DEPENDENCY`. Siga a regra de branches da seção 3.1: você é quem cria a principal `grupo08-bff` (a partir de `origin/main`, com push) e coda em `grupo08-bff-feat/rooms-core`, criada a partir de `grupo08-bff`; após o APROVADO do REV, merge `--no-ff` em `grupo08-bff` e push de `grupo08-bff`. Testes completos são do AG-03; você só ajusta `rooms.contract.spec.ts` o mínimo para a suíte não quebrar e adiciona testes unitários do service se quiser. Entregue o relatório da seção 8.0.

**Leia antes (inteiros):** `backend/bff/README.md`; `backend/bff/docs/superpowers/specs/2026-11-23-courses-bff-design.md`; `backend/bff/docs/superpowers/plans/2026-11-23-courses-bff-progress.md`; `src/app.module.ts`; `src/bootstrap.ts`; `src/common/http/downstream.service.ts`; `src/common/http/circuit-breaker.ts`; `src/common/auth/bearer-token.ts`; `src/common/academic/current-semester.ts`; todos os arquivos de `src/modules/courses/`, `src/modules/students/`, `src/modules/rooms/`; `docs/open-api/bff.yaml` (seções de rooms, `RoomView`, `RoomViewList`, `Problem`, `CompositionUnavailable`); `docs/open-api/grupo08-rooms-api.yaml`.

**Possui:** `src/modules/rooms/**` (exceto testes novos de integração, que são do AG-03), e **uma** linha em `src/bootstrap.ts` (parser `raw` para `/api/v1/rooms`, ver tarefa 5). Pode editar `src/modules/rooms/rooms.contract.spec.ts` só para mantê-lo compilando/verde.

**Proibido:** mudar `src/common/**`, outros módulos, `package.json`, `openapi/**`, `scripts/**`.

**Tarefas:**
1. **Module (`rooms.module.ts`)**
   - Manter `ROOMS_DOWNSTREAM` (base `ROOMS_BASE_URL`, default `http://rooms:8105`).
   - Adicionar `ROOMS_CLASSES_DOWNSTREAM` (base `CLASSES_BASE_URL`, default `http://classes:8107`), com circuit breaker **próprio** (instância separada, como o courses faz).
   - Nos dois: `retryMethods: ['GET', 'HEAD']` (hoje PUT/DELETE são repetidos; isso é bug porque pode duplicar escrita).
   - Validar config como o courses (URL válida, números positivos). Copiar a abordagem, não reinventar.
   - Adicionar `ROOMS_CLOCK` com `useValue: () => new Date()`.
   - Exportar os três tokens com os nomes exatos da seção 6.1.
2. **Controller (`rooms.controller.ts`)**
   - `@Controller('api/v1/rooms')`. **Remover** a rota `v1/rooms` (decisão D10).
   - Declarar `@Get()` (coleção, compose `'collection'`) e `@Get(':id')` (item, compose `'item'`) **antes** dos `@All` correspondentes, para o GET cair na composição e os demais verbos no proxy. HEAD segue o proxy.
   - `@All(':id/accessibility-features')` e `@All(':id/accessibility-features/:featureId')`: proxy puro.
   - Portar do courses: função `segment()` (aplica `encodeURIComponent` e rejeita `.`/`..` e vazio com **400** no envelope do BFF que o courses usa para isso — se o courses usa `CO-400`, para rooms usar `application/problem+json` `{type:'urn:closed-cras:bff:bad-request', title:'Requisição inválida', status:400, detail, code:'BFF-BAD-REQUEST'}`); `AbortController` abortando no evento `close` da requisição; rejeitar GET/HEAD com corpo não vazio do mesmo jeito que o courses.
   - Query string: repassar **crua** (`req.originalUrl` a partir do `?`), sem reconstruir (os operadores `{gteq}` e o `%` do `like` precisam chegar intactos).
   - Corpo: usar o `Buffer` cru (ver tarefa 5) e o `content-type` original; não reserializar com `JSON.stringify`.
   - Token: `bearerTokenOf(req)`.
   - Responder com status, `content-type` e headers retornados pelo service (incluindo `x-total-count` e `location`).
3. **Service (`rooms.service.ts`)** — implementar `forward(req, compose?)` conforme 6.1:
   - Sem `compose` (proxy): `send` ao rooms em `/api/v1/rooms{suffix}{query}`; devolver como veio. `DownstreamUnavailableError` → 503 problem+json `code: 'BFF-DEPENDENCY'` (alinhar o código antigo `BFF-DOWNSTREAM-UNAVAILABLE` ao contrato; conferir em `bff.yaml` qual `code` o 503 de proxy de rooms usa e seguir o contrato; se o contrato não especifica para o proxy, usar `BFF-DEPENDENCY`).
   - `compose === 'collection'`:
     1. `send` GET ao rooms `/api/v1/rooms{query}`.
     2. Se status ≠ 200 → devolver intacto (400/401/403/404 e headers).
     3. Parse do corpo; se não for array → 503 `BFF-DEPENDENCY`.
     4. Se array vazio → devolver `[]` com os headers do rooms, **sem chamar classes**.
     5. `const { year, semester } = currentSemester(clock())`.
     6. `send` GET ao classes `/api/v1/classes?year=${year}&semester=${semester}` com o mesmo `bearerToken` e `signal`.
     7. Classes lançou `DownstreamUnavailableError`, status ≠ 200, corpo não-array ou JSON inválido → 503 `BFF-DEPENDENCY` (seção 6.2). Nunca devolver sala sem `classes`.
     8. Filtrar classes em memória: `enabled === true`, `year === year`, `semester === semester`, `roomId` presente.
     9. Agrupar por `roomId`; para cada sala, `classes = grupo[sala.id] ?? []`. Manter a ordem das salas do rooms e a ordem das classes como vieram.
     10. Responder 200 `application/json` com o array composto; headers: copiar `x-total-count` (e demais repassáveis) do rooms, **remover** `etag` e `last-modified`, definir `cache-control: no-store`.
   - `compose === 'item'`: igual, com `send` GET ao rooms `/api/v1/rooms/{id}{query}`; se 200 e objeto, chamar classes com `&roomId=${encodeURIComponent(id)}`; filtrar também `roomId === id`; responder o objeto com `classes`.
   - Validação de payload (recomendado): criar `src/modules/rooms/composition-contract.ts` com Ajv validando a **Room antes** de acrescentar `classes` (o `RoomView` usa `allOf` com Room `additionalProperties:false`, que rejeitaria o objeto composto) e cada `Class` com os campos mínimos usados (`id`, `roomId`, `year`, `semester`, `enabled`). Payload inválido de rooms → 503 `BFF-DEPENDENCY`. **Não** importar o validador privado do courses; copiar o necessário.
   - Nunca logar o token.
4. **Spec existente** — `rooms.contract.spec.ts` vai quebrar (rota mudou, ids `'abc'` não são UUID, GET agora chama classes). Ajuste o mínimo: rotas para `/api/v1/rooms`, ids UUID (`'3f6c2b1e-8a4d-4c1f-9e2b-7d5a6c4b3a21'`), mock de GET devolvendo Room válida e mock de classes devolvendo `[]`. Os testes completos ficam com o AG-03.
5. **`src/bootstrap.ts`** — adicionar, ao lado do parser `raw` do courses, o equivalente para `/api/v1/rooms` (`raw({ type: () => true, limit: '1mb' })`), para o corpo chegar como `Buffer` sem passar pelo JSON parser global (corpo malformado deve chegar ao rooms e voltar como `RM-400`, não como erro do BFF). Única alteração permitida nesse arquivo. Garantir com `Buffer.isBuffer` no controller.
6. **README do BFF** — atualizar a seção do módulo rooms: rotas, composição, decisão D5 (classes filtradas por papel do usuário), remover a nota "mantém rotas legadas `/v1/rooms`". **Só a seção de rooms.**

**Verificação:**
```bash
cd backend/bff
npm ci
npm run build
npm test -- --runInBand          # suíte inteira verde, incluindo courses/students/reservations
npm run test:contract            # não pode piorar (o AG-03 vai estendê-lo)
```

**Critérios de aceite:**
- [ ] `GET /api/v1/rooms` e `GET /api/v1/rooms/{id}` compõem `classes` do semestre corrente; vazio → `[]`.
- [ ] Coleção vazia não chama classes.
- [ ] 4xx do rooms sobe intacto, com headers.
- [ ] Falha do classes → 503 problem+json `BFF-DEPENDENCY`, sem sala pela metade.
- [ ] `X-Total-Count` e `Location` preservados; `etag`/`last-modified` removidos nos GETs compostos; `cache-control: no-store`.
- [ ] PUT/PATCH/DELETE/POST não são repetidos em falha (só GET/HEAD).
- [ ] Rota `/v1/rooms` não existe mais.
- [ ] Query string com `{gteq}` e `%25` chega intacta ao rooms.
- [ ] Tokens de injeção com os nomes da 6.1.
- [ ] Suíte inteira verde; nenhum arquivo proibido alterado (exceto a linha do `bootstrap.ts`).

**Commits sugeridos:** `refactor(bff-rooms): move rotas para /api/v1/rooms`, `feat(bff-rooms): compõe classes do semestre em curso nos GETs`, `fix(bff-rooms): repete só GET e HEAD em falha`, `feat(bff-rooms): repassa corpo cru para rooms`, `docs(bff-rooms): atualiza README do módulo`.

---

### 8.3 AG-03 — BFF Rooms Testes e Contrato

**Prompt:**

> Você é o AG-03 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.3–4.7, 6.1, 6.2, 8.2 e esta ficha). O AG-02 já entregou o módulo `src/modules/rooms/` com composição. Sua missão é provar com testes que ele cumpre o contrato `docs/open-api/bff.yaml` e estender a validação offline de contrato. Siga a regra de branches da seção 3.1: atualize `grupo08-bff` (que já contém o merge do AG-02) e crie a partir dela `grupo08-bff-feat/rooms-tests`; após o APROVADO do REV, merge `--no-ff` em `grupo08-bff` e push de `grupo08-bff`. Se achar bug no código do AG-02, **não corrija em silêncio**: escreva o teste que falha, descreva no relatório e corrija só se for de uma linha e óbvio; senão devolva ao REV. Entregue o relatório da seção 8.0.

**Leia antes:** tudo que o AG-02 leu + `src/courses.contract.spec.ts`, `src/courses.integration.spec.ts`, `src/testing/http-fixture.ts`, `src/testing/domain-fixtures.ts`, `test/e2e/courses.e2e-spec.ts`, `test/e2e/support/e2e-env.ts`, `test/jest-e2e.json`, `scripts/validate-contract.cjs`, `openapi/README.md`, `openapi/openapi.json`, `openapi/domains/*.openapi.json`, `compose.courses.yaml`, `package.json`.

**Possui:** `src/modules/rooms/rooms.contract.spec.ts`, `src/rooms.integration.spec.ts` (novo), `src/rooms.contract-schema.spec.ts` (novo, opcional), `src/testing/rooms-fixtures.ts` (novo), `test/e2e/rooms.e2e-spec.ts` (novo), `openapi/domains/rooms.openapi.json` (novo), `openapi/openapi.json` (só entradas de rooms), `scripts/validate-contract.cjs` (generalizar sem quebrar courses), `package.json` (só o script `test:e2e:rooms`), `compose.rooms.yaml` (novo), `openapi/README.md` (só nota de rooms).

**Tarefas:**
1. **Fixtures (`src/testing/rooms-fixtures.ts`)**: `roomFixture(overrides)` com Room válida (UUID v4, todos os campos do schema), `classFixture(overrides)` com Class válida (`enabled:true`, `year`, `semester`, `roomId`), helpers para montar listas.
2. **Spec de contrato do módulo (`rooms.contract.spec.ts`)** — módulo isolado com `DownstreamService` falso por DI (estilo atual). Casos:
   - rotas: `/api/v1/rooms`, `/api/v1/rooms/{id}`, features e feature por id, para cada verbo; `/v1/rooms` → 404 do Nest.
   - query crua preservada (`?capacity=%7Bgteq%7D40&name=%7Blike%7D%25lab%25&page=0&size=20`).
   - Bearer do header e do cookie `closed_cras_session` chegam ao downstream; nada de token no log.
   - POST com 201 + `Location` intacto; 409 `RM-409` intacto (corpo byte a byte); DELETE 204 sem corpo.
   - `segment()` rejeita `..` e `.`.
   - GET com corpo → 400.
3. **Integração (`src/rooms.integration.spec.ts`)** — molde de `courses.integration.spec.ts`: `AppModule` real + `configureApp` + dois `httpFixture` (rooms e classes) + `overrideProvider(ROOMS_CLOCK)`. Casos mínimos (todos obrigatórios):
   1. Coleção com 3 salas e classes misturadas → cada sala recebe só as suas; ordem preservada; `X-Total-Count` igual ao do rooms.
   2. Item → classes chamadas com `roomId=<id>&year&semester`; resposta tem `classes`.
   3. Sala sem turmas → `classes: []`.
   4. Coleção vazia (`[]`, `X-Total-Count: 0`) → classes **não** é chamado.
   5. Class com `enabled:false` → excluída.
   6. Class de outra sala, outro ano ou outro semestre (mesmo se o classes devolver) → excluída.
   7. Relógio em `2026-07-31T23:59:59-03:00` → `semester=1`; em `2026-08-01T00:00:00-03:00` → `semester=2`; em `2026-12-31T23:30:00-03:00` → ano 2026 (mesmo já sendo 2027 em UTC); em `2027-01-01T00:00:00-03:00` → 2027/1.
   8. Classes fora do ar (porta fechada) → 503 `application/problem+json` com `code:'BFF-DEPENDENCY'`, `status:503`, `type`, `title`, `detail`; corpo **não** contém dados da sala.
   9. Classes responde 500 → 503; classes responde 401/403 → 503 (documentar no teste que o contrato manda 503 para falha de composição); classes devolve não-array → 503.
   10. Rooms responde 404 (filtro sem resultado) → 404 intacto, classes não chamado.
   11. Rooms responde 401/403/400 → intacto.
   12. Rooms devolve Room inválida (campo faltando) → 503 (se o AG-02 implementou validação Ajv).
   13. Headers: GET composto sem `etag`/`last-modified`, com `cache-control: no-store`.
   14. O mesmo Bearer chega ao rooms e ao classes.
   15. POST/PUT/PATCH/DELETE e accessibility-features não chamam classes.
   16. PUT com rooms caindo (500 ou conexão recusada) é enviado **uma vez só**; GET é repetido conforme `BFF_HTTP_RETRIES`.
   17. Corpo malformado no POST chega cru ao rooms (o fixture recebe exatamente os bytes enviados).
   18. Validação de resposta: cada `RoomView` composto valida contra o schema de `bff.yaml` (usar o mesmo truque do courses para o `allOf` fechado).
4. **Contrato offline**:
   - `openapi/domains/rooms.openapi.json`: converter `docs/open-api/grupo08-rooms-api.yaml` + schemas para JSON (mesmo formato dos domínios existentes) e acrescentar `RoomView` "achatado" (Room + `classes` obrigatório, sem `additionalProperties:false` conflitante) como o `CourseView`.
   - Registrar as operações de rooms em `openapi/openapi.json` (mesmo padrão de courses). Não corrigir o mojibake existente nas descrições de outros grupos.
   - `scripts/validate-contract.cjs`: generalizar a lista de documentos e as contagens (um `assert` por domínio). O total de courses (19) não pode mudar.
5. **E2E (`test/e2e/rooms.e2e-spec.ts`)** + script `"test:e2e:rooms"` no `package.json` (mesmo formato dos outros `test:e2e:*`): login via `POST {oauth}/login` com `admin@pucrs.br` (senha lida de variável de ambiente de teste já usada pelo e2e do courses — **não** hardcode), listar salas (200, cada item com `classes` array), item, criar sala com code único, PATCH, DELETE e conferir 404 depois, criar/listar/excluir feature; com `student@pucrs.br`: GET 200, POST 403 (envelope `RM-403`).
6. **`compose.rooms.yaml`**: cópia de `compose.courses.yaml` com `depends_on: !override` em `oauth` (healthy), `rooms` (healthy) e `classes` (healthy). Documentar no `README` do módulo (seção rooms) como rodar:
   ```bash
   docker compose -f docker-compose.yml -f backend/bff/compose.rooms.yaml up -d --build postgresql keycloak oauth rooms classes bff
   cd backend/bff && npm run test:e2e:rooms
   ```

**Verificação:**
```bash
cd backend/bff
npm run build
npm test -- --runInBand
npm run test:contract
npm run test:e2e:rooms     # se houver Docker com a stack de pé; senão, declarar no relatório
```

**Critérios de aceite:**
- [ ] Os 18 casos de integração existem e passam.
- [ ] Spec do módulo cobre rotas, query crua, token, 201/409/204, `segment()`.
- [ ] `test:contract` valida rooms sem mudar a contagem de courses.
- [ ] E2E escrito e (se possível) executado.
- [ ] Suíte inteira verde.

**Commits sugeridos:** `test(bff-rooms): fixtures e spec de contrato do módulo`, `test(bff-rooms): integração da composição com classes`, `test(bff-rooms): valida contrato offline de rooms`, `test(bff-rooms): e2e de rooms`, `chore(bff-rooms): compose.rooms.yaml`.

---

### 8.4 AG-04 — Frontend Fundação

**Prompt:**

> Você é o AG-04 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.1, 4.8, 5, 6.3–6.8 e esta ficha). O submódulo `frontend` hoje só tem `README.md`. Crie do zero o projeto Angular 22 (standalone, SCSS, Angular Material M3), a infraestrutura de build (Dockerfile + nginx), o tema com os tokens do `DESIGN.md`, o shell (app bar, menu, drawer) e os componentes de UI compartilhados, deixando stubs para login, lista e detalhe de salas. Siga a regra de branches da seção 3.1: você é quem cria a principal `grupo08-frontend` (a partir de `origin/main`, com push) e coda em `grupo08-frontend-feat/base`, criada a partir de `grupo08-frontend`; após o APROVADO do REV, merge `--no-ff` em `grupo08-frontend` e push de `grupo08-frontend`. Entregue o relatório da seção 8.0.

**Leia antes:** `frontend/README.md`; serviço `frontend` em `docker-compose.yml` da raiz (build args, portas, healthcheck, `depends_on`); `_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md` (inteiro); `EXPERIENCE.md` (seções de shell, menu, responsividade, login, salas); `mockups/closed-cras-responsivo.html` (estrutura do shell e das telas de salas); prints `.working/qa/responsive/*`.

**Possui:** tudo em `frontend/` exceto `src/app/core/auth/**` (implementação real é do AG-05; você cria só stubs), `src/app/core/http/**` (AG-06), `src/app/features/rooms/**` (AG-06/07/08; você cria só os stubs de página), `src/app/features/login/**` (AG-05; você cria só o stub).

**Tarefas:**
1. **Projeto**: `npx @angular/cli@22 new frontend --directory . --standalone --style=scss --routing --ssr=false --skip-git` (ajuste flags à versão; não commitar `node_modules`). `ng add @angular/material` com tema customizado (não usar tema pré-pronto). `LOCALE_ID` `pt-BR` com `registerLocaleData`. Strict mode ligado.
2. **Tokens e tema** (`src/styles/_tokens.scss`, `_theme.scss`, `_typography.scss`, `styles.scss`): cores, tipografia, espaçamentos e medidas da seção 4.8 como CSS custom properties e tema M3 (`mat.theme` com primary #0066B3, tertiary #6DCDF6, error #B1101A). Fontes Source Sans 3 e Source Code Pro via `@fontsource` **ou** arquivos self-hosted em `public/fonts` (sem CDN externo em runtime). Só tema claro.
3. **Config** (6.5): `public/config.json` com `{ "oauthBaseUrl": "/api/auth", "bffBaseUrl": "/api/bff" }`; `APP_CONFIG` carregado no bootstrap (`provideAppInitializer` com `fetch('/config.json')`), com fallback para os defaults.
4. **Dockerfile** multi-stage:
   - stage `build`: `node:24-alpine`, `ARG VITE_OAUTH_BASE_URL=/api/auth`, `ARG VITE_BFF_BASE_URL=/api/bff`, `npm ci`, gerar `public/config.json` a partir dos ARGs (`printf` ou `envsubst`), `npx ng build --configuration production`.
   - stage `runtime`: `nginx:alpine` + `apk add --no-cache curl` (healthcheck do compose usa curl), copiar `dist/<app>/browser` para `/usr/share/nginx/html` e `nginx.conf` para `/etc/nginx/conf.d/default.conf`, `EXPOSE 80`.
   - `.dockerignore`: `node_modules`, `dist`, `.angular`, `.git`.
5. **nginx.conf**:
   ```nginx
   server {
     listen 80;
     root /usr/share/nginx/html;
     location = /health { add_header Content-Type text/plain; return 200 'ok'; }
     location /api/auth/ { proxy_pass http://oauth:8088/; proxy_set_header Host $host; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; }
     location /api/bff/  { proxy_pass http://api:3001/;   proxy_set_header Host $host; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; }
     location / { try_files $uri $uri/ /index.html; }
   }
   ```
   A barra final em `proxy_pass` remove o prefixo. Conferir no compose se o BFF é alcançável como `api` (container_name) ou `bff` (serviço); ambos funcionam na rede `constrsw`; preferir o **nome do serviço** `bff` se `api` não resolver. Não reescrever `Origin` nem cookies.
6. **proxy.conf.json** (para `ng serve`): `/api/auth` → `http://localhost:8181` com `pathRewrite {"^/api/auth": ""}`; `/api/bff` → `http://localhost:8180` com `pathRewrite {"^/api/bff": ""}`; `changeOrigin: false` para o `BFF_ORIGIN` (`http://localhost:8080`) não bater; servir o `ng serve` na porta **8080** (`angular.json` → `serve.options.port: 8080`, `proxyConfig`). Documentar no README que o compose do front não pode estar de pé ao mesmo tempo (porta 8080).
7. **Rotas** exatamente como 6.4, com stubs: `features/login/login.page.ts`, `features/rooms/list/rooms-list.page.ts`, `features/rooms/detail/room-detail.page.ts` (componentes standalone com um `<h1>` e mais nada), `features/home/home.page.ts`, `features/placeholder/placeholder.page.ts` ("Esta área é de outro grupo e ainda não está disponível.").
8. **Stubs de auth** (6.6): `core/auth/auth.service.ts` com a assinatura exata e implementação fake (`isAuthenticated` true), `core/auth/auth.guard.ts` (`authGuard` retornando true), `core/auth/auth.interceptor.ts` (passa adiante). Em `app.config.ts`: `provideHttpClient(withInterceptors([authInterceptor]))` com comentário `// AG-05: interceptor real`.
9. **Shell** (`core/layout/`): `ShellComponent` com app bar 64dp (título "Closed CRAS", faixa tertiary 4dp no topo ou base conforme DESIGN.md, nome/e-mail do usuário vindo de `AuthService.identity()` e botão "Sair" chamando `logout()`), `NavDrawerComponent` com os 10 itens na ordem da seção 4.8 (`nav-items.ts`: `{label, route, icon}`; "Salas de Aula" → `/salas`; os outros → `/em-breve/<slug>`), item ativo com `routerLinkActive`. ≥ 1024px: `mat-sidenav` `mode="side"` aberto, 280px. < 1024px: `mode="over"`, botão de menu na app bar, Esc fecha, foco volta ao botão. Use `BreakpointObserver` do CDK com os breakpoints 600/1024/1280.
10. **UI compartilhada** (6.8): os 5 componentes, acessíveis (`role`, `aria-live` no error banner, foco no botão de confirmar, Esc cancela), usando os tokens.
11. **Lint/format**: manter o que o CLI gera; adicionar `npm run lint` só se o CLI oferecer sem pacote extra.
12. **README** do frontend: stack, como rodar (`npm ci`, `npm start` com a stack de backend de pé, `npm test`, `npm run build`), como buildar no compose, estrutura de pastas (6.3), convenções.

**Verificação:**
```bash
cd frontend
npm ci
npx ng build --configuration production
npx ng test --watch=false          # ou o runner padrão do CLI 22
docker build -t frontend-check --build-arg VITE_OAUTH_BASE_URL=/api/auth --build-arg VITE_BFF_BASE_URL=/api/bff .
docker run --rm -d -p 18080:80 --name frontend-check frontend-check && curl -fsS http://localhost:18080/health && curl -fsS http://localhost:18080/salas | head -5; docker rm -f frontend-check
```
(No `docker run` isolado o nginx pode reclamar que `oauth`/`api` não resolvem. Se isso impedir a subida, usar `resolver 127.0.0.11 valid=10s;` + variável no `proxy_pass` **ou** documentar que o teste do container só é feito no compose. Preferir que o nginx suba mesmo sem os upstreams.)

**Critérios de aceite:**
- [ ] `ng build` e `ng test` passam.
- [ ] `docker build` passa; `/health` 200; `/salas` devolve o `index.html`.
- [ ] Tema com tokens do DESIGN.md; fontes sem CDN externo.
- [ ] Shell responsivo nos 3 breakpoints, menu com 10 itens na ordem certa, Esc fecha o drawer modal.
- [ ] Rotas e stubs exatamente como 6.4; interfaces 6.5, 6.6 (stub) e 6.8 com as assinaturas combinadas.
- [ ] `ng serve` na 8080 com proxy funcionando.

**Commits sugeridos:** `feat(frontend): cria projeto Angular 22 com Material M3`, `feat(frontend): tema e tokens do Closed CRAS`, `feat(frontend): Dockerfile e nginx com proxy para oauth e BFF`, `feat(frontend): shell com app bar e menu responsivo`, `feat(frontend): componentes de UI compartilhados`, `docs(frontend): README`.

---

### 8.5 AG-05 — Frontend Auth e Shell

**Prompt:**

> Você é o AG-05 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.6, 4.7, 4.8, 6.4–6.6 e esta ficha). O AG-04 entregou o esqueleto Angular com stubs de auth. Implemente login, sessão por cookie, refresh, logout, identidade e guard, e ligue o shell à identidade real. Siga a regra de branches da seção 3.1: atualize `grupo08-frontend` (já com o merge do AG-04) e crie a partir dela `grupo08-frontend-feat/auth`; após o APROVADO do REV, merge `--no-ff` em `grupo08-frontend` (com `pull --ff-only` antes, porque o AG-06 mergeia em paralelo) e push. Não altere arquivos fora do seu escopo. Entregue o relatório da seção 8.0.

**Leia antes:** código do AG-04 (`app.config.ts`, `app.routes.ts`, `core/**`); `EXPERIENCE.md` (fluxo de login, mensagens, cabeçalho); prints `login*`; `backend/oauth/src/**` (controller de login/refresh/logout, para confirmar corpo e status); `backend/bff/src/modules/reservations/` (endpoint `identidade/me`) e `docs/open-api/bff.yaml` (`/api/v1/identidade/me`).

**Possui:** `src/app/core/auth/**`, `src/app/features/login/**`, e em `app.config.ts` só a linha do interceptor. Pode alterar `core/layout/shell.component.*` **apenas** para ligar nome/e-mail/botão Sair à identidade real (sem mudar layout).

**Tarefas:**
1. **AuthService** (assinatura 6.6, com `signal`/`computed`):
   - `login(username, password)`: `POST {oauthBaseUrl}/login` com `FormData` (`username`, `password`), `withCredentials: true`. 201 → `loadIdentity()`; sucesso. 400 → `LoginError{kind:'validation', message: error_description do envelope OA}`; 401 → `{kind:'invalid', message:'Não foi possível entrar. Verifique usuário e senha.'}`; 503/0/rede → `{kind:'unavailable', message:'Identidade indisponível.'}`. **Não** guardar o `access_token` do corpo em lugar nenhum (o cookie basta; decisão D9).
   - `loadIdentity()`: `GET {bffBaseUrl}/api/v1/identidade/me` com `withCredentials`. 200 → popular `identity`; 401 → `null`; 503/rede → lançar `{kind:'unavailable', message:'Identidade indisponível.'}`.
   - `refresh()`: `POST {oauthBaseUrl}/refresh` (sem corpo, `withCredentials`). **Single-flight**: chamadas concorrentes compartilham a mesma Promise. 201 → `true`; qualquer outra coisa → `false` e `identity = null`.
   - `logout()`: `POST {oauthBaseUrl}/logout`, limpar `identity`, navegar para `/login`. Falha de rede no logout ainda limpa o estado local.
   - `isAdmin = papeis.includes('administrator')`; `seesAllClasses = administrator || coordinator`.
2. **Interceptor** (`auth.interceptor.ts`, funcional):
   - Para URLs que começam com `bffBaseUrl` ou `oauthBaseUrl`: `withCredentials: true`.
   - Resposta 401 de chamada ao **BFF** (não ao oauth): chamar `refresh()` uma vez; se `true`, repetir a requisição original **uma** vez; se `false` ou se a repetição der 401 de novo → `logout` local e navegar para `/login?returnUrl=<url atual>`.
   - Não interceptar 401 do próprio `/login` nem do `/refresh` (evitar loop).
3. **Guard** (`auth.guard.ts`): se `identity()` é null, tentar `loadIdentity()`; se continuar null, tentar `refresh()` e `loadIdentity()` de novo; se ainda null → `UrlTree` para `/login?returnUrl=...`. Se `loadIdentity` lançar `unavailable`, ir para `/login` mostrando "Identidade indisponível.".
4. **Tela de login** (`features/login/login.page.*`), conforme EXPERIENCE.md e prints:
   - Campos "E-mail" (`type=email`, obrigatório, validação de e-mail) e "Senha" (obrigatório, botão mostrar/ocultar com `aria-label`), botão "Entrar" (desabilitado e com spinner durante a chamada).
   - Erros em `app-refusal-banner` (`role="alert"`), sem limpar o e-mail; foco vai para o banner.
   - Sucesso → `returnUrl` (validar que é rota interna) ou `/salas`.
   - Se já autenticado ao abrir `/login` → redirecionar para `/salas`.
   - Responsivo (card central ≥ 600px; tela cheia em compact).
5. **Shell**: nome/e-mail do `identity()` na app bar; "Sair" chama `logout()`.
6. **Testes** (`*.spec.ts` com `HttpTestingController`):
   - login 201 → chama identidade; 401/400/503 → mensagens certas.
   - interceptor: 401 → um refresh → retry → sucesso; duas requisições simultâneas com 401 → **um** refresh só; refresh falha → navega para login; 401 do `/login` não dispara refresh.
   - guard: sem identidade → redirect com `returnUrl`.
   - `isAdmin`/`seesAllClasses` para os 4 papéis.

**Verificação:** `npx ng build --configuration production`, `npx ng test --watch=false`. Se a stack estiver de pé (`docker compose up -d postgresql keycloak oauth rooms classes bff`), `npm start` e testar manualmente login com `admin@pucrs.br` e `student@pucrs.br` (senha do README do keycloak; não commitar).

**Critérios de aceite:**
- [ ] Nenhum token em `localStorage`/`sessionStorage` (verificar com `grep -rn "localStorage\|sessionStorage" src`).
- [ ] Mensagens exatas da seção 4.8.
- [ ] Refresh single-flight testado.
- [ ] Guard redireciona com `returnUrl` validado.
- [ ] Build e testes verdes.

**Commits sugeridos:** `feat(frontend): AuthService com login, refresh e logout por cookie`, `feat(frontend): interceptor com refresh único em 401`, `feat(frontend): guard de rota autenticada`, `feat(frontend): tela de login`, `test(frontend): auth, interceptor e guard`.

---

### 8.6 AG-06 — Frontend Dados de Rooms

**Prompt:**

> Você é o AG-06 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.2, 4.3, 4.6, 6.7 e esta ficha). O AG-04 entregou o esqueleto Angular. Implemente a camada de dados de rooms: modelos, serviço HTTP para o BFF, montagem de filtros, tradução de erros e testes. Não crie telas. Siga a regra de branches da seção 3.1: atualize `grupo08-frontend` (já com o merge do AG-04) e crie a partir dela `grupo08-frontend-feat/rooms-data`; após o APROVADO do REV, merge `--no-ff` em `grupo08-frontend` (com `pull --ff-only` antes, porque o AG-05 mergeia em paralelo) e push. Entregue o relatório da seção 8.0.

**Leia antes:** `docs/open-api/bff.yaml` (rooms, `RoomView`, `Problem`), `docs/open-api/grupo08-rooms-api.yaml` e `docs/open-api/schemas/room*.json`, `accessibility-feature*.json`, `error.schema.json`; `docs/open-api/grupo01-classes-api.yaml` e `grupo01-classes-schemas.json` (tipos exatos de `Class`); `core/config/app-config.ts` do AG-04.

**Possui:** `src/app/features/rooms/data/**`, `src/app/core/http/**`.

**Tarefas:**
1. **Modelos** (`rooms.models.ts`) exatamente como 6.7. Conferir `ClassSummary` contra o schema do classes e ajustar tipos (`string|null` etc.) se o contrato disser diferente — registrar no relatório qualquer ajuste.
2. **Filtros** (`core/http/filter-query.ts`): `toHttpParams(query: RoomQuery): HttpParams`:
   - `op === 'eq'` → `field=value`; demais → `field={op}value` (ex.: `capacity={gteq}40`, `name={like}%lab%`).
   - `like` sem `%` informado pelo usuário: envolver em `%…%` (busca "contém").
   - `sort` → `sort=field,dir`; `page`/`size` só se definidos.
   - Codificação: usar `HttpParams` com um `HttpParameterCodec` que use `encodeURIComponent` puro (o codec padrão do Angular **não** codifica `{`, `}` e alguns caracteres; o Tomcat do rooms recusa `{` cru). Testar que `{gteq}40` vira `%7Bgteq%7D40` e `%lab%` vira `%25lab%25`.
   - Rejeitar com erro de programação (`throw`) combinações proibidas pela API: `like` em `capacity`, operadores ≠ `eq/neq` em `active`, ≠ `eq` em `resourceIds`.
3. **Erros** (`core/http/api-error.ts`, `error-parser.ts`): `toApiError(err: HttpErrorResponse): ApiError`:
   - `status === 0` → `network`, mensagem "Não foi possível conectar. Verifique sua conexão.".
   - `content-type` contém `application/problem+json`: se `code === 'BFF-DEPENDENCY'` → `composition-unavailable`, mensagem "Serviço de composição indisponível."; senão usar `title`/`detail`.
   - Envelope com `error_code` (`RM-*`, `OA-*`): `code = error_code`, `message = error_description`; `kind` por status: 400 `validation`, 401 `unauthorized`, 403 `forbidden`, 404 `not-found`, 409 `conflict`, 503 `domain` (ex.: `RM-503` validação de recursos), outros `unknown`.
   - 403 sem corpo útil → mensagem "Você não tem permissão para esta ação.".
4. **Serviço** (`rooms-api.service.ts`), assinatura 6.7, base `${bffBaseUrl}/api/v1/rooms`, `observe: 'response'` nos GETs de lista para ler `X-Total-Count` (se ausente, `total = items.length`):
   - `list`: 404 → `{items: [], total: 0}` (decisão de contrato: 404 = filtro sem resultado).
   - `get`: 404 → `ApiError not-found`.
   - `create`: corpo só com campos definidos.
   - `update`: sempre envia todas as chaves de `RoomUpdate`, inclusive `capacity: null`.
   - `patch`: envia **exatamente** o objeto recebido; se vier vazio, `throw` (a API exige ≥ 1 campo).
   - `remove`, `removeFeature`: `Observable<void>` (204).
   - `listFeatures`: em 404, fazer `get(roomId)`; se a sala existe → `{items: [], total: 0}`; se não → propagar `not-found`.
   - Feature `create`/`update`/`patch`: mesmas regras de corpo.
   - Todos os erros convertidos com `toApiError` (`catchError` → `throwError(() => apiError)`).
   - Sem cache, sem retry automático (o retry de 401 é do interceptor do AG-05; o "Tentar novamente" é da UI).
5. **Helpers de domínio** (`rooms.utils.ts`): `currentTermLabel(classes)` → `"2026/2"` a partir de `classes[0]` ou, sem classes, do semestre calculado no cliente **apenas para exibição** (mesma regra 4.4; o cliente nunca envia ao BFF); `capacityLabel(room)` → `"40 lugares"` ou `"Capacidade não informada"`; `featureCodePattern = /^[A-Z][A-Z0-9_]*$/`.
6. **Testes** (`*.spec.ts`, `HttpTestingController`): codificação de filtros (casos acima + combinações proibidas); `list` com `X-Total-Count`, sem header e com 404; `get` 404; `update` com `capacity: null` presente no corpo; `patch` envia só os campos dados e recusa vazio; `listFeatures` 404 com sala existente/inexistente; `toApiError` para problem+json `BFF-DEPENDENCY`, `RM-409`, `RM-400`, 403 sem corpo, `status 0`.

**Verificação:** `npx ng build --configuration production`, `npx ng test --watch=false`.

**Critérios de aceite:**
- [ ] Interfaces exatamente como 6.7 (ou ajuste justificado no relatório e aprovado pelo REV).
- [ ] Filtros codificados corretamente (`%7B`, `%7D`, `%25`).
- [ ] 404 de lista vira vazio; 404 de item vira erro.
- [ ] PATCH nunca manda defaults.
- [ ] Erros sempre como `ApiError`.
- [ ] Testes verdes.

**Commits sugeridos:** `feat(frontend): modelos de rooms`, `feat(frontend): montagem e codificação de filtros da API`, `feat(frontend): tradução de erros do BFF e do rooms`, `feat(frontend): RoomsApiService`, `test(frontend): camada de dados de rooms`.

---

### 8.7 AG-07 — Frontend Lista de Salas

**Prompt:**

> Você é o AG-07 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.2, 4.8, 6.3–6.8 e esta ficha). AG-04, AG-05 e AG-06 já entregaram esqueleto, auth e camada de dados. Implemente a tela `/salas` (lista) e o dialog de formulário de sala (criar/editar), que também será reusado pelo detalhe. Siga a regra de branches da seção 3.1: atualize `grupo08-frontend` (já com os merges de AG-04, AG-05 e AG-06) e crie a partir dela `grupo08-frontend-feat/rooms-list`; após o APROVADO do REV, merge `--no-ff` em `grupo08-frontend` e push. Entregue o relatório da seção 8.0.

**Leia antes:** `EXPERIENCE.md` (UX-ROOMS lista, dialogs, confirmações, microcopy), `DESIGN.md`, mock `mockups/closed-cras-responsivo.html` (rota `#/salas` e o dialog), prints `salas-*.png` e `salas-dialog*`; código de `features/rooms/data/**`, `core/auth/**`, `core/ui/**`.

**Possui:** `src/app/features/rooms/list/**` (inclui `room-form.dialog.ts|html|scss|spec.ts`).

**Tarefas:**
1. **Página `RoomsListPage`** (substitui o stub):
   - Cabeçalho "Salas de Aula", chip "{total} salas" (singular "1 sala").
   - Busca (320px; tela cheia em compact) com debounce 300ms. Busca por texto faz `name={like}%texto%` **ou** `code={like}%texto%`? A API não tem OR: implementar um **seletor de campo** ao lado da busca ("Código", "Nome", "Prédio"; padrão "Código") e enviar só o campo escolhido. Filtros extras num painel "Filtros": Prédio (texto, like), Capacidade mínima (número → `capacity={gteq}N`), Situação (Todas / Ativas / Inativas → `active=true|false`).
   - Estado na URL (query params `q`, `campo`, `predio`, `capMin`, `ativa`, `page`, `size`, `sort`) para recarregar e compartilhar.
   - Tabela `mat-table` + `mat-sort` + `mat-paginator` server-side (`page` base 0, `size` 10/20/50, padrão 20, `total` do `X-Total-Count`).
   - Colunas: **Código** (Source Code Pro), **Nome**, **Prédio**, **Capacidade** (`capacityLabel`), **Situação** (chip "Ativa"/"Inativa"), **Turmas no semestre** (`classes.length`), **Ações** (Abrir; Editar e Excluir só se `isAdmin()`). Clique na linha abre o detalhe.
   - Ordenação permitida só em `code`, `name`, `building`, `capacity`, `active`.
   - CTA "Nova sala" (botão, sem FAB) só se `isAdmin()`.
   - Se `!seesAllClasses()`, mostrar nota discreta acima da tabela: "Você vê apenas as turmas vinculadas a você." (decisão D5).
2. **Estados**:
   - Carregando (primeira carga): `app-skeleton variant="table"`; recargas: barra de progresso fina, mantendo os dados antigos.
   - Vazio sem filtros: `app-empty-state` "Nenhuma sala cadastrada ainda." + "Nova sala" (só admin).
   - Vazio com filtros: "Nenhuma sala encontrada com esses filtros." + "Limpar filtros".
   - `composition-unavailable`: `app-error-banner` "Serviço de composição indisponível." + "Tentar novamente".
   - `network`/`unknown`: banner com a mensagem do `ApiError` + "Tentar novamente".
   - `forbidden`: "Você não tem permissão para ver as salas.".
3. **Responsivo** (seção 4.8):
   - expanded (≥ 1024): tabela completa.
   - medium (600–1023): ocultar "Nome" e "Situação" (manter Código, Prédio, Capacidade, Turmas, Ações).
   - compact (< 600): **lista** de 2 linhas, 72dp: linha 1 "Código · Prédio", linha 2 "{capacidade} · {N} turmas"; menu ⋮ com Editar/Excluir (admin); toque abre detalhe; paginação simplificada; sem scroll horizontal.
4. **Dialog `RoomFormDialog`** (`room-form.dialog.ts`), modo `create` ou `edit` (recebe `Room` no edit):
   - 560px; tela cheia em compact (`MatDialog` com `panelClass` e `BreakpointObserver`).
   - Campos e validação (iguais à API): Código (obrigatório, 1–20, não só espaços, Source Code Pro), Nome (obrigatório, 1–100), Prédio (obrigatório, 1–50), Capacidade (opcional, inteiro ≥ 1; vazio = sem capacidade), Ativa (toggle, padrão ligado), Recursos (`resourceIds`: campo de chips aceitando UUIDs válidos, opcional, sem duplicatas; texto de ajuda "Identificadores dos recursos do Grupo 06").
   - Mensagens de validação em pt-BR abaixo de cada campo.
   - Criar → `create` com só os campos preenchidos (capacidade vazia → omitir). Editar → `patch` com **só os campos alterados** (comparar com o original; se nada mudou, botão Salvar desabilitado). Capacidade apagada em edição → `capacity: null`.
   - Erro: `conflict` (`RM-409`) → `app-refusal-banner` com `error_description` (ex.: código duplicado ou recurso já em outra sala), formulário mantido; `validation` → banner + manter; `forbidden` → banner "Você não tem permissão para esta ação."; sucesso → fecha devolvendo a `Room`, a lista recarrega e mostra `MatSnackBar` "Sala {code} criada." / "Sala {code} atualizada.".
   - Botões "Cancelar" e "Criar sala"/"Salvar alterações"; spinner durante a chamada; Esc fecha só se não estiver salvando.
5. **Excluir**: `ConfirmDialogComponent` 400px, título "Excluir sala {code}?", mensagem "A sala {code} ({name}) deixará de aparecer nas listas e os recursos vinculados a ela serão liberados. Esta ação não pode ser desfeita pela interface.", botão destrutivo "Excluir sala". Sucesso → snackbar "Sala {code} excluída." e recarregar (se a página ficou vazia e `page > 0`, voltar uma página). 404 → snackbar "A sala já havia sido excluída." e recarregar.
6. **Acessibilidade**: `<caption>` ou `aria-label` na tabela, cabeçalhos de ordenação com `aria-sort`, foco gerenciado ao abrir/fechar dialogs, alvos de toque 48px, contraste conforme tokens.
7. **Testes** de componente: renderiza linhas e chip de total; esconde ações sem `isAdmin`; filtros geram a `RoomQuery` certa e atualizam a URL; 404 → estado vazio com filtros; `composition-unavailable` → banner com retry que refaz a chamada; dialog de edição envia só campos alterados e `capacity: null` quando apagada; 409 mantém o formulário com banner; exclusão chama `remove` após confirmar.

**Verificação:** `npx ng build --configuration production`, `npx ng test --watch=false`; com a stack de pé, `npm start` e checar os 3 breakpoints (DevTools 375, 768, 1280).

**Critérios de aceite:**
- [ ] Colunas e campos só os da API (nada de Andar/Observações).
- [ ] Paginação, ordenação e filtros server-side com estado na URL.
- [ ] Todos os estados implementados com a microcopy da ficha/EXPERIENCE.
- [ ] Ações de escrita só para administrator.
- [ ] Responsivo nos 3 breakpoints sem scroll horizontal.
- [ ] Dialog reutilizável exportado em `features/rooms/list/room-form.dialog.ts`.
- [ ] Testes verdes.

**Commits sugeridos:** `feat(frontend): lista de salas com filtros, ordenação e paginação`, `feat(frontend): dialog de criar e editar sala`, `feat(frontend): exclusão de sala com confirmação`, `feat(frontend): lista de salas responsiva`, `test(frontend): lista e formulário de salas`.

---

### 8.8 AG-08 — Frontend Detalhe de Sala

**Prompt:**

> Você é o AG-08 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia as seções 2, 3, 4.2, 4.3, 4.8, 6.3–6.8 e esta ficha). AG-04, AG-05 e AG-06 já entregaram esqueleto, auth e dados. Implemente a tela `/salas/:id`: dados da sala, turmas do semestre em curso e CRUD de recursos de acessibilidade. Para "Editar sala", reutilize `RoomFormDialog` de `features/rooms/list/room-form.dialog.ts` (do AG-07); não altere esse arquivo. Siga a regra de branches da seção 3.1: atualize `grupo08-frontend` (já com os merges de AG-04, AG-05 e AG-06) e crie a partir dela `grupo08-frontend-feat/rooms-detail`; antes de pedir revisão, se o AG-07 já mergeou, faça `git merge grupo08-frontend` na sua branch para usar o `RoomFormDialog` real; após o APROVADO do REV, merge `--no-ff` em `grupo08-frontend` e push. Entregue o relatório da seção 8.0.

**Leia antes:** `EXPERIENCE.md` (UX-ROOMS detalhe, painéis, recursos de acessibilidade, confirmações), `DESIGN.md`, mock (rota `#/salas/b201`), prints `sala-detalhe-*.png`; `features/rooms/data/**`, `core/**`; `docs/open-api/grupo01-classes-schemas.json` (significado de `status`, `modality`).

**Possui:** `src/app/features/rooms/detail/**`.

**Tarefas:**
1. **Carga**: ler `:id` (validar UUID; inválido → estado "Sala não encontrada."), `get(id)` e `listFeatures(id)` em paralelo. `get` com `composition-unavailable` → banner com retry (sem mostrar dados parciais). `not-found` → "Sala não encontrada." + link "Voltar para Salas de Aula".
2. **Cabeçalho**: breadcrumb "Salas de Aula › {code}" (link para `/salas` preservando os query params da lista, se vierem no `history.state`), título "Sala {code}", subtítulo `{name} · {building}`, chips "{capacidade} lugares" (ou "Capacidade não informada"), "{N} turmas em {ano}/{semestre}" (`currentTermLabel`), "Inativa" (se `!active`, chip de aviso em gold).
3. **Painel "Dados da sala"**: lista de definição com Código, Nome, Prédio, Capacidade, Situação, Recursos vinculados (quantidade + lista de UUIDs em Source Code Pro com botão copiar; nomes de recursos ficam fora do escopo). Botões "Editar sala" (abre `RoomFormDialog` em modo edit; ao fechar com sucesso, recarregar) e "Excluir sala" (mesmo ConfirmDialog e textos do AG-07; sucesso → snackbar e navegar para `/salas`). Só admin.
4. **Painel "Turmas no semestre {ano}/{semestre}"** (`room-classes.component.ts`):
   - Lista/tabela com: Código, Rótulo (`label`), Situação (`status`), Modalidade (`modality`), Período (`startDate`–`endDate` formatado `dd/MM/yyyy`), Vagas (`seats`). **Não exibir `studentIds`** nem quantidade de alunos.
   - Vazio: "Nenhuma turma sediada nesta sala em {ano}/{semestre}.".
   - Se `!seesAllClasses()`: nota "Você vê apenas as turmas vinculadas a você." (D5).
   - Somente leitura (turmas são do Grupo 01).
5. **Painel "Recursos de acessibilidade"** (borda esquerda tertiary 4px, contador "{n} recursos"):
   - Lista com `code` (Source Code Pro), `description` (ou "Sem descrição"), chip "Presente"/"Ausente".
   - "Adicionar recurso" (admin) → `feature-form.dialog.ts`: Código (obrigatório, 1–30, `^[A-Z][A-Z0-9_]*$`; converter para maiúsculas e trocar espaços por `_` enquanto digita; dica "Ex.: RAMP, ELEVATOR, TACTILE_FLOOR"), Descrição (opcional, ≤ 255, contador), Presente (toggle, padrão ligado). Criar → `createFeature` (campos preenchidos). Editar → `patchFeature` só com alterados (descrição apagada → `null`).
   - Por item (admin): Editar, Excluir (ConfirmDialog "Excluir recurso {code}?" / "O recurso {code} deixará de aparecer nesta sala." / "Excluir recurso").
   - Alternar "Presente" direto na lista (admin): `patchFeature({present})` com atualização otimista e reversão + snackbar em erro.
   - Estados próprios: skeleton, vazio "Nenhum recurso de acessibilidade cadastrado." (+ "Adicionar recurso" para admin), erro com retry (independente do resto da página).
6. **Layout**: expanded ≥ 1280 → 2 colunas (esquerda: Dados + Turmas; direita: Recursos); 1024–1279 e medium → 1 coluna; compact → 1 coluna, painéis em cards, ações em menu ⋮.
7. **Acessibilidade**: títulos de painel como `h2`, `aria-live="polite"` no contador e nos snackbars, foco volta ao gatilho após fechar dialogs, toggles com rótulo.
8. **Testes** de componente: carrega sala + features; UUID inválido → não encontrada; 404 → não encontrada; `composition-unavailable` → banner e retry; lista de turmas não mostra alunos; vazio de turmas; ações ocultas para não admin; criar feature com código normalizado; editar feature envia só alterados; toggle otimista reverte em erro; excluir sala navega para `/salas`.

**Verificação:** `npx ng build --configuration production`, `npx ng test --watch=false`; manual nos 3 breakpoints com a stack de pé.

**Critérios de aceite:**
- [ ] Dados, turmas e recursos exibidos só com campos da API.
- [ ] Turmas do semestre vindas de `classes` do `RoomView`, sem `studentIds`.
- [ ] CRUD completo de recursos de acessibilidade com validação do `code`.
- [ ] Editar/excluir sala reutilizando o dialog e os textos do AG-07.
- [ ] Layout 2 colunas ≥ 1280.
- [ ] Testes verdes.

**Commits sugeridos:** `feat(frontend): detalhe de sala com dados e turmas do semestre`, `feat(frontend): CRUD de recursos de acessibilidade`, `feat(frontend): detalhe de sala responsivo`, `test(frontend): detalhe de sala`.

---

### 8.9 AG-09 — Integrador e Entrega

**Prompt:**

> Você é o AG-09 do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` (leia o documento inteiro). Todos os agentes AG-01 a AG-08 foram aprovados pelo REV. As principais `grupo08` (rooms), `grupo08-bff` e `grupo08-frontend` já contêm tudo mergeado. Suba a stack a partir delas, rode o roteiro de aceitação ponta a ponta, corrija apenas problemas de integração (configuração, nomes de host) em branches `-feat/integracao` de cada repositório seguindo a seção 3.1, e atualize os ponteiros de submódulo no repo base na principal `grupo08-base`. Nunca a `main`. Push só das principais do grupo, depois do APROVADO do REV. Entregue o relatório da seção 8.0 com o resultado de cada passo do roteiro.

**Possui:** merges nas branches dos submódulos; `docker-compose.yml` da raiz **somente** se for indispensável para a stack subir (registrar cada linha alterada e o motivo); ponteiros de submódulo no repo base; `README.md` da raiz (seção curta "Rooms: como rodar").

**Tarefas:**
1. **Conferir as principais**: em cada submódulo, `git fetch origin && git checkout <principal> && git pull --ff-only`. Conferir com `git log --oneline --merges` que estão lá os merges esperados: `grupo08` (AG-01), `grupo08-bff` (AG-02, AG-03), `grupo08-frontend` (AG-04, AG-05, AG-06, AG-07, AG-08). Faltou algum → parar e reportar ao REV. No repo base: `git fetch origin`; se `grupo08-base` não existe, criar a partir da branch atual `claude/rooms-frontend-bff-dfae7e` (que contém este plano) e dar push; senão `checkout` + `pull --ff-only`. Nos submódulos, fazer `git checkout` da principal de cada um antes de subir a stack.
2. **Build de tudo**:
   ```bash
   docker volume create constrsw-prometheus-data; docker volume create constrsw-keycloak-data; docker volume create constrsw-postgresql-data; docker volume create constrsw-mongodb-data
   docker compose up -d --build postgresql keycloak oauth rooms classes
   docker compose -f docker-compose.yml -f backend/bff/compose.rooms.yaml up -d --build bff
   docker compose -f docker-compose.yml -f backend/bff/compose.rooms.yaml up -d --build --no-deps frontend
   docker compose ps
   ```
   O serviço `frontend` depende de `bff` (healthy) e `oauth`. Se o `depends_on` do `bff` no compose base exigir serviços de outros grupos, usar o override `compose.rooms.yaml` como acima.
3. **Testes automáticos**: `backend/rooms`: `./mvnw verify`; `backend/bff`: `npm test -- --runInBand`, `npm run test:contract`, `npm run test:e2e:rooms`; `frontend`: `npx ng test --watch=false`, `npx ng build`.
4. **Roteiro de aceitação manual** (em `http://localhost:8080`, registrar ✅/❌ e print quando falhar):
   1. `/salas` sem sessão → redireciona para `/login`.
   2. Login com senha errada → "Não foi possível entrar. Verifique usuário e senha.".
   3. Login `admin@pucrs.br` → `/salas`, menu com 10 itens, "Salas de Aula" ativo, nome na app bar.
   4. Lista mostra as 5 salas de exemplo com "Turmas no semestre" preenchida (número coerente com `GET /api/v1/classes?year=2026&semester=2` feito à mão no classes).
   5. Filtro Capacidade mínima 40 → só salas com capacidade ≥ 40; filtro que não casa → "Nenhuma sala encontrada com esses filtros.".
   6. Ordenar por capacidade; paginar com size 2.
   7. Nova sala (código único) → aparece; criar de novo com o mesmo código → banner de conflito, formulário mantido.
   8. Abrir detalhe → chips, turmas do semestre, recursos de acessibilidade.
   9. Adicionar recurso "rampa de acesso" → código vira `RAMPA_DE_ACESSO`; alternar Presente; editar descrição; excluir.
   10. Editar sala (capacidade apagada → "Capacidade não informada").
   11. Excluir sala → volta para `/salas`, sala sumiu; `GET /api/v1/rooms/{id}` via BFF → 404.
   12. Parar o classes (`docker compose stop classes`) → lista e detalhe mostram "Serviço de composição indisponível." + "Tentar novamente"; religar → retry funciona.
   13. Sair → `/login`; voltar com o botão do navegador não mostra dados.
   14. Login `student@pucrs.br` → lista sem "Nova sala", sem Editar/Excluir; nota "Você vê apenas as turmas vinculadas a você."; detalhe sem ações de escrita.
   15. Login `coordinator@pucrs.br` → leitura, sem escrita, sem a nota (vê todas as turmas).
   16. Responsivo: 375px (lista de 2 linhas, menu modal, Esc fecha), 768px (colunas reduzidas), 1280px (drawer fixo, detalhe em 2 colunas).
   17. Esperar > 10 min logado (ou forçar expiração) e navegar → refresh transparente, sem voltar ao login.
5. **Commits e ponteiros**:
   - Correções de integração em submódulo: branch `<principal>-feat/integracao` a partir da principal, commit, REV, merge `--no-ff` na principal, push da principal (seção 3.1).
   - No repo base, na branch `grupo08-base-feat/ponteiros` criada a partir de `grupo08-base`: com cada submódulo no último commit da sua principal **já pushado**, `git add backend/rooms backend/bff frontend` e commit `chore: atualiza ponteiros de rooms, bff e frontend (T3/T4 rooms)`. Alterações no `docker-compose.yml` ou `README.md` da raiz em commit separado.
   - Após o APROVADO do REV: merge `--no-ff` em `grupo08-base` e `git push origin grupo08-base`.
   - Listar no relatório: para cada submódulo, principal + hash final pushado; para o base, hash do merge em `grupo08-base`.

**Critérios de aceite:**
- [ ] Stack sobe com os comandos documentados.
- [ ] Todos os testes automáticos verdes (ou falhas explicadas).
- [ ] 17 passos do roteiro com resultado registrado.
- [ ] Ponteiros atualizados em `grupo08-base` e principais pushadas (nada em `main`).

---

## 9. Revisor (REV) — Claude

### 9.1 Prompt do REV

> Você é o REV, revisor do plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md`. Leia o documento inteiro uma vez. A cada entrega, você recebe o relatório de um agente (AG-01 a AG-09) e tem acesso ao repositório. Sua função é **verificar, não confiar**: abra os arquivos alterados (`git diff <base>..<branch>` no submódulo), rode os comandos de verificação da ficha do agente, e confira cada critério de aceite e cada item do checklist 9.2 aplicável. Procure especialmente: (1) divergência do contrato `docs/open-api/bff.yaml` / `grupo08-rooms-api.yaml`; (2) arquivos alterados fora do "Possui" da ficha; (3) interfaces da seção 6 alteradas; (4) segredos ou tokens em código, logs ou commits; (5) testes que passam por estarem fracos (asserts vazios, mocks que aceitam tudo). Responda no formato 9.3. Seja específico: arquivo, linha, o que está errado, o que é esperado. Não reescreva o código do agente; diga o que corrigir. Só aprove quando todos os critérios obrigatórios estiverem atendidos.

### 9.2 Checklist geral

**Todos**
- [ ] Só arquivos do "Possui" foram alterados (`git diff --stat`).
- [ ] Commits em pt-BR, Conventional Commits, na branch de desenvolvimento `grupo08…-feat/<slug>` criada a partir da principal do grupo (seção 3.1); nada em `main`; push só da principal, só depois do APROVADO.
- [ ] Nenhum valor de `.env`, senha, secret ou token no diff (`git diff | grep -iE "password|secret|eyJ"`).
- [ ] Comandos de verificação rodados de novo pelo REV com o mesmo resultado.
- [ ] Relatório completo no formato 8.0.

**AG-01 (rooms)**
- [ ] `git diff -- src/main openapi.yaml schemas` vazio.
- [ ] `docker build` passa; `/openapi/openapi.yaml` servido.
- [ ] Auditoria de contrato cobre `/api/v1/health`.

**AG-02/AG-03 (BFF)**
- [ ] Rotas `/api/v1/rooms*` e nenhuma `/v1/rooms`.
- [ ] Composição só nos dois GETs; resto é proxy (sem chamar classes).
- [ ] Semestre via `common/academic/current-semester.ts` com relógio injetável.
- [ ] Filtro em memória por `enabled`, `year`, `semester`, `roomId`.
- [ ] 503 `application/problem+json` com os 5 campos e `code: BFF-DEPENDENCY`; sala nunca parcial.
- [ ] `X-Total-Count` preservado; `etag`/`last-modified` removidos nos GETs compostos.
- [ ] `retryMethods` GET/HEAD nos dois downstreams.
- [ ] Query crua repassada; corpo cru repassado.
- [ ] Única alteração fora do módulo: a linha do `bootstrap.ts` (AG-02) e os arquivos listados do AG-03.
- [ ] Suíte inteira (courses/students/reservations) verde.
- [ ] Os 18 casos de integração realmente afirmam o comportamento (ler os `expect`).

**AG-04..AG-08 (frontend)**
- [ ] Angular 22, standalone, Material M3, SCSS; sem libs fora do combinado.
- [ ] Nenhuma chamada direta a `:8105`, `:8107`, `:8181`, `:8180` no código (só `bffBaseUrl`/`oauthBaseUrl`).
- [ ] Nenhum `localStorage`/`sessionStorage` com token.
- [ ] Campos só da API (sem Andar/Observações); `studentIds` nunca exibido.
- [ ] PATCH só com campos alterados; PUT com `capacity` presente.
- [ ] 404 de lista tratado como vazio.
- [ ] Microcopy da seção 4.8 e EXPERIENCE.md.
- [ ] Ações de escrita só para `administrator`.
- [ ] Responsivo nos 3 breakpoints (REV confere ao menos 375 e 1280 com `ng serve`).
- [ ] Acessibilidade: foco, `role="alert"`, `aria-label`s, Esc, alvos 48px.
- [ ] Interfaces 6.4–6.8 intactas.

**AG-09**
- [ ] Merges sem perda de commits.
- [ ] Roteiro de 17 passos com evidência.
- [ ] Ponteiros corretos (`git submodule status` aponta para os hashes do relatório).

### 9.3 Formato da resposta do REV

```markdown
## Revisão — <ID>
**Veredito:** APROVADO | APROVADO COM RESSALVAS | REPROVADO
**Verificações rodadas:** <comandos + resultado>
**Problemas:**
1. [bloqueante|ressalva] <arquivo:linha> — <o que está errado> → <o que fazer>
**Itens do checklist não atendidos:** <lista ou "nenhum">
**Liberado para:** <IDs dos agentes que podem começar agora>
```

---

## 10. Integração, commits e ponteiros

Resumo da regra 3.1 aplicada à entrega:

| Repositório | Principal do grupo (pushada) | Quem mergeia nela |
| --- | --- | --- |
| `backend/rooms` | `grupo08` | AG-01 (e AG-09 se houver correção de integração) |
| `backend/bff` | `grupo08-bff` | AG-02, depois AG-03 |
| `frontend` | `grupo08-frontend` | AG-04, AG-05, AG-06, AG-07, AG-08 |
| base | `grupo08-base` | AG-09 (ponteiros) |

1. Cada agente faz merge `--no-ff` da sua branch de desenvolvimento na principal **só depois do APROVADO do REV** e dá push **só da principal** (seção 3.1).
2. Os ponteiros no base apontam para o último commit **já pushado** de cada principal (`grupo08`, `grupo08-bff`, `grupo08-frontend`). Ponteiro para commit não pushado quebra o clone dos colegas.
3. Ninguém mergeia, commita ou dá push em `main` de nenhum repositório. Quando o grupo decidir entregar, abre **manualmente** os PRs `grupo08-bff → main` (bff), `grupo08-frontend → main` (frontend), `grupo08 → main` (rooms, se for o fluxo do repositório) e `grupo08-base → main` (base), e atualiza os ponteiros para os hashes finais mergeados.

Lembrete (AGENTS.md): alteração em submódulo pede commit naquele repositório **e** atualização do ponteiro no base; os dois precisam de push.

---

## 11. Riscos e armadilhas conhecidas

| # | Risco | Mitigação |
| --- | --- | --- |
| R1 | `RoomView` usa `allOf` com Room `additionalProperties:false`; validador estrito rejeita `classes`. | Validar Room antes de compor; schema achatado no contrato offline (como `CourseView`). |
| R2 | Rooms devolve 404 em lista filtrada sem resultado. | BFF repassa; front trata como vazio. |
| R3 | Dois formatos de erro (envelope `RM-*`/`OA-*` e `problem+json`). | `toApiError` decide por `Content-Type`. |
| R4 | `{`, `}`, `%` na query. | Codec `encodeURIComponent` no front; BFF repassa query crua. |
| R5 | PATCH com defaults dos schemas sobrescreve dados. | Front envia só alterados; testes. |
| R6 | Classes filtra por papel (D5). | Nota na UI; README; teste e2e com student. |
| R7 | Retry de escrita duplicava operações no BFF. | `retryMethods: ['GET','HEAD']`; teste 16. |
| R8 | Token direto do Keycloak tem `iss` diferente do token do oauth. | E2E loga via `POST {oauth}/login`. |
| R9 | Oauth sem CORS; cookie httpOnly. | Mesma origem via nginx/proxy; `withCredentials`. |
| R10 | `BFF_ORIGIN` bloqueia escrita por cookie com `Origin` diferente. | Front servido em `http://localhost:8080` (nginx e `ng serve`), proxy sem `changeOrigin`. |
| R11 | Dockerfile do rooms quebrado bloqueia a stack. | AG-01 na Onda 1. |
| R12 | `depends_on` do `bff` no compose base exige todos os grupos. | `compose.rooms.yaml` com `!override`. |
| R13 | Nome do host do BFF no nginx (`api` vs `bff`). | AG-04 confere; fallback para o nome do serviço. |
| R14 | Access token de 10 min. | Refresh single-flight no interceptor (AG-05); passo 17 do roteiro. |
| R15 | Mudanças em `common/` do BFF quebram outros grupos. | Proibido; suíte inteira obrigatória. |

---

## 12. Fora do escopo (não corrigir sem combinar com o grupo)

- `prometheus.yml` raspa `auth` (não existe; é `oauth`); blackbox sonda `rooms:3000`.
- Compose passa ao BFF `BFF_OAUTH_JWKS_PATH=/auth/jwks` e `BFF_OAUTH_VALIDATE_PATH=/auth/validate`, que não existem no oauth.
- Client `oauth-admin` citado no compose não existe no realm (`/roles` do oauth tende a 503).
- Realm legado `closed-cras` em `backend/oauth/keycloak/` e README do keycloak desatualizado (`backend/auth`, `/auth/*`).
- Segredos de desenvolvimento commitados em READMEs e JSONs de realm.
- `openapi/openapi.json` do BFF com acentos corrompidos (mojibake) em descrições de outros grupos.
- Nomes de recursos (Grupo 06) e de cursos/professores nas turmas: o `RoomView` só traz ids; resolver nomes exigiria chamadas extras não previstas no contrato de rooms.
- Telas dos outros itens do menu (são de outros grupos): ficam como placeholder.

---

## 13. Glossário

- **BFF**: Backend for Frontend, `backend/bff`, NestJS; única API que o navegador chama.
- **Composição (T3)**: o BFF junta a resposta do rooms com as classes do semestre em curso.
- **Proxy puro**: o BFF repassa a chamada ao rooms e devolve status, corpo e headers sem alterar.
- **Semestre em curso**: ano civil e semestre 1 (jan–jul) ou 2 (ago–dez), no fuso de São Paulo.
- **Exclusão lógica**: DELETE marca `enabled=false`; o registro some de tudo.
- **REV**: o agente revisor (Claude).
- **Onda**: grupo de agentes que roda em paralelo; a próxima onda só começa após o REV aprovar as dependências.
