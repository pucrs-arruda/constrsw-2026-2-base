# Passagem de bastão: Rooms (Grupo 08), BFF + frontend

Data: 24/11/2026. Grupo 08, rooms: Anthony, Lucas Simão, Arthur Maciel, João Biasoli.
Quem vai continuar: comece **por este arquivo**. Ele resume o que existe, em que branch está, o que falta e o que melhorar. O detalhe fino está em `rooms-t3-t4-plano-orca.md` (mesma pasta), que é o plano completo com 9 fichas de tarefa.

---

## 0. Leia isto primeiro

1. **Nunca trabalhar na `main` de nenhum repositório.** Toda branch nossa sai da principal do grupo (seção 2).
2. **Use as skills do BMAD** para fazer o trabalho (seção 7). O professor pediu isso por e-mail ("preferencialmente bmad-build utilizando as Specs da BFF API").
3. **O contrato manda.** BFF e telas têm de responder exatamente a `docs/open-api/bff.yaml` (rooms) e `docs/open-api/grupo08-rooms-api.yaml`. O backend de rooms **já cumpre** o contrato; não precisa mudar endpoint.
4. **O que o professor cobra no T3:** os dois GETs de rooms no BFF (`/api/v1/rooms` e `/api/v1/rooms/{id}`) devolvem as classes sediadas na sala no **semestre em curso** (`year` = ano atual; `semester` = 1 antes de agosto, 2 de agosto em diante; fuso America/Sao_Paulo; o cliente nunca manda year/semester). Se o serviço de classes cair, resposta 503 `application/problem+json` com `code: "BFF-DEPENDENCY"`, nunca a sala pela metade. Exclusão lógica (`enabled=false`) em tudo.
5. **O e-mail do professor também pede:** teste fim a fim do BFF que percorra **todos** os endpoints de rooms e seja **idempotente**, e frontend de cada grupo só do próprio serviço (nós: salas).
6. **Os agentes do Orca ainda podem estar abertos e gastando cota.** Feche todos (seção 9) antes de começar.
7. **O plano `rooms-t3-t4-plano-orca.md` foi escrito para vários agentes trabalhando em paralelo** (fichas AG-01 a AG-09, revisores REV). Quem assume sozinho pode **ignorar a parte de orquestração** (ondas, "LIBERADO", correio entre agentes) e usar as fichas apenas como **lista de tarefas com critérios de aceite**. O que continua valendo integralmente: seção 0 (specs do professor), seção 3.1 (regra de branches), seção 4 (fatos de contrato) e seção 6 (interfaces).

## 0.1 Status de revisão e o que ainda NÃO existe (leia antes de confiar em qualquer branch)

Dois revisores atuaram: REV-1 (Claude) e REV-1b/REV-2 (GPT, no Codex). Só o que está na primeira tabela foi revisado. **Tudo o mais é código escrito por agente e conferido apenas pelo próprio agente** (o que ele diz ter rodado está nos relatórios em `_bmad-output/implementation-artifacts/orca/`, mas ninguém confirmou).

### Revisado e aprovado
| Peça | Branch / hash | Quem aprovou e como |
| --- | --- | --- |
| BFF núcleo de rooms | `bff/grupo08-feat/rooms-core` `0eccfbe`, mergeado em `bff/grupo08` (`bb0cd63`, **publicado**) | REV-1 aprovou o diff; REV-1b corroborou build, suíte e contrato (parecer `REV-AG-02-parecer.md`). O próprio AG-02 relatou 154 testes verdes em Node 24. |
| README do módulo BFF | `bff/grupo08-feat/rooms-readme` `54dcb18` | REV-1b, só o complemento documental. Não mergeado. |

### Revisado e reprovado (não usar)
| Peça | Resultado |
| --- | --- |
| Base antiga do frontend (AG-04, `cd2ced5`) | REV-2 reprovou em 3 rodadas: (1) o proxy do nginx perdia caminho e query (`POST /api/auth/login` chegava como `POST /`) e os ícones usavam a fonte errada; (2) a branch não partia da principal; (3) o professor publicou o scaffold oficial. Os bugs 1 foram corrigidos, mas **a base foi descartada** (parecer `REV2-AG-04-parecer.md`). O nginx corrigido pode ser reaproveitado. |

### Escrito mas NUNCA revisado
| Peça | Branch / hash | O que o agente afirma (não confirmado) |
| --- | --- | --- |
| Correções do backend rooms | `grupo08-feat/t3-fix-build-health` `ef30cd0` (5 commits) | relatório em `AG-01-relatorio.md`; a imagem do rooms chegou a ser construída no Docker, mas `./mvnw verify` e `docker build` não foram confirmados por revisor |
| Testes e e2e do BFF | `bff/grupo08-feat/rooms-tests` `9d672e8` (12 arquivos: contrato offline `openapi/domains/rooms.openapi.json`, `rooms.integration.spec.ts`, `rooms.e2e-spec.ts`, `compose.rooms.yaml`, script `test:e2e:rooms`, ajuste de 3 linhas no controller) | build e suíte completa com 203 testes verdes; o e2e **não chegou a rodar** |
| Login e sessão | `frontend/grupo08-feat/auth` `35a575f` (10 arquivos) | relatório do AG-05 não foi escrito |
| Camada de dados de salas | `frontend/grupo08-feat/rooms-data` `db20174` (10 arquivos) | build de produção passou (relato do AG-06); relatório `AG-06-relatorio.md` |
| Lista de salas e formulário | `frontend/grupo08-feat/rooms-list` `216bb22`, `5c5a61f` (8 arquivos) | nenhum relatório |
| Detalhe de sala | `frontend/grupo08-feat/rooms-detail` `f8a42e2` (7 arquivos) | nenhum relatório |

### Não existe (nunca foi feito)
- Base do frontend sobre o scaffold do professor (`frontend/grupo08-feat/base-v2`): a branch existe mas está **igual ao scaffold dele**, sem nada nosso. Por isso as 4 branches do frontend acima ainda estão sobre a base antiga e precisam de rebase.
- Teste E2E do frontend com Playwright: nada escrito (`frontend/grupo08-feat/e2e` sem commits).
- Integração final (ficha 8.9) e o roteiro de aceitação de 17 passos: nunca executados.
- Teste fim a fim do BFF rodado **duas vezes seguidas** (exigência do professor): nunca rodou nem uma.
- Verificação visual das telas em 360, 768 e 1280: nunca feita.
- Merge em branches principais: só o `bff/grupo08` recebeu merge. `frontend/grupo08` está no ponto da `main` (sem código nosso); `grupo08` do rooms não recebeu as correções; `base/grupo08` nem foi criada.
- PRs para a `main` e atualização dos ponteiros de submódulo no repositório base: nada feito (de propósito).
- Shell, login e home oficiais: são do professor e ainda não foram entregues; o que existe de shell/login é provisório e estava na base antiga descartada.

---

## 1. Repositórios e branches (estado em 24/11/2026)

São 4 repositórios no GitHub `pucrs-arruda/`. O repositório base tem os 3 outros como submódulos (`backend/rooms`, `backend/bff`, `frontend`).

### Por que os nomes são estranhos (erro GH013)
Nos repositórios `constrsw-2026-2-base`, `-bff` e `-frontend`, o professor criou *rulesets* que **bloqueiam criar ou atualizar** branches começando com `grupo08`. Testado: `bff/grupo08` e `frontend/grupo08` foram aceitos; `grupo08-frontend` foi recusado. Por isso usamos o prefixo do repositório. No `rooms` (repositório próprio do grupo) continua `grupo08`.

| Repositório | Principal do grupo (recebe merges) | Branch de desenvolvimento | Estado da principal no GitHub |
| --- | --- | --- | --- |
| `constrsw-2026-2-base` | `base/grupo08` (**ainda não criada no GitHub**) | `base/grupo08-feat/<slug>` | não existe |
| `constrsw-2026-2-rooms` (`backend/rooms`) | `grupo08` | `grupo08-feat/<slug>` | **NÃO existe no GitHub** (conferido em 24/11). Criar a partir de `origin/main` (`ce07d8c`, que é o commit apontado pelo submódulo no repo base). O `origin/grupo08` que aparece em clones antigos é referência velha (`f660712`). |
| `constrsw-2026-2-bff` (`backend/bff`) | `bff/grupo08` | `bff/grupo08-feat/<slug>` | `bb0cd63` (já tem o merge do AG-02) |
| `constrsw-2026-2-frontend` (`frontend`) | `frontend/grupo08` | `frontend/grupo08-feat/<slug>` | `d6ee998` (só nasceu da main, **sem código nosso**) |

Fluxo: atualiza a principal → cria `<principal>-feat/<slug>` a partir dela → codifica e commita → depois de revisado, `git merge --no-ff` na principal e `git push` da principal. Não existe `git push --force`.

### Onde está cada trabalho (hashes)
Em 24/11/2026, depois da primeira versão deste documento, o Lucas autorizou o push e **todas as branches de desenvolvimento com trabalho foram enviadas ao GitHub** (nenhuma da `main`, sem force). A única que não foi: `base-v2` e `e2e` do frontend, que ainda não têm trabalho nosso.

| Peça | Branch | Último commit | No GitHub? | Revisão |
| --- | --- | --- | --- | --- |
| BFF, núcleo (AG-02) | `bff/grupo08-feat/rooms-core` e já mergeada em `bff/grupo08` | `0eccfbe` / merge `bb0cd63` | **sim** | **Aprovado** (REV-1, REV-1b corroborou) |
| BFF, testes e e2e (AG-03) | `bff/grupo08-feat/rooms-tests` | `9d672e8` | sim (push em 24/11) | pendente |
| README do módulo BFF (AG-02) | `bff/grupo08-feat/rooms-readme` | ver `git branch -a` no `backend/bff` | sim (push em 24/11) | **aprovado** pelo REV-1b (só documentação, `54dcb18`; **não mergeado** em `bff/grupo08`) |
| Backend rooms, correções (AG-01) | `grupo08-feat/t3-fix-build-health` | `ef30cd0` (5 commits) | sim (push em 24/11) | relatório entregue, revisão não concluída |
| Frontend, base antiga (AG-04) | `frontend/grupo08-feat/base` | `cd2ced5` | sim | reprovado 2x, corrigido; **base descartada** (ver abaixo) |
| Frontend, base nova (AG-04b) | `frontend/grupo08-feat/base-v2` | `f13f4d1` (= scaffold do professor, **ainda sem trabalho nosso**) | não | não começou |
| Frontend, login e sessão (AG-05) | `frontend/grupo08-feat/auth` | `35a575f` | sim (push em 24/11) | pendente |
| Frontend, dados de rooms (AG-06) | `frontend/grupo08-feat/rooms-data` | `db20174` | sim | pendente |
| Frontend, lista de salas (AG-07) | `frontend/grupo08-feat/rooms-list` | `5c5a61f` (2 commits) | sim | pendente |
| Frontend, detalhe de sala (AG-08) | `frontend/grupo08-feat/rooms-detail` | `f8a42e2` | sim (push em 24/11) | pendente |
| Frontend, e2e Playwright (AG-09a) | `frontend/grupo08-feat/e2e` | `cd2ced5` (nada novo ainda) | não | não começou |
| Plano, specs e relatórios (base) | `base/grupo08-feat/orquestracao` | ver `git log` | só se for feito push | n/a |

Atenção: as branches do frontend `rooms-data`, `rooms-list`, `auth`, `rooms-detail` e `e2e` foram criadas a partir da **base antiga** `cd2ced5` (do AG-04). Depois apareceu o scaffold oficial do professor (`f13f4d1` na `main` do frontend) e a decisão foi **reencaixar tudo em cima dele**. Esse reencaixe (AG-04b) **não foi feito**. Cada branch precisa de `git rebase --onto origin/frontend/grupo08-feat/base-v2 origin/frontend/grupo08-feat/base <branch>` assim que a base nova existir.

### Pastas locais (worktrees do Orca)
Se o Lucas mandar a pasta inteira, o amigo tem tudo:
- `G08-Rooms/` é o repo base (branch `base/grupo08-feat/orquestracao`), com os submódulos baixados.
- `G08-fe-ag04b`, `G08-fe-ag05` … `G08-fe-ag09` são `git worktree` do frontend, uma por branch acima.
Em outro computador basta `git fetch` e `git checkout` das branches da tabela: tudo que tem trabalho já está no GitHub.

---

## 2. O que foi feito

### Pesquisa e decisões
- Leitura de todo o repositório, submódulos, specs e e-mails do professor. Resultados consolidados no plano, seção 4 ("Fatos verificados").
- Comparação byte a byte: `docs/open-api/grupo08-rooms-api.yaml` é **idêntico** a `backend/rooms/openapi.yaml`, e os schemas também. **Nenhum endpoint do backend precisa mudar.**
- Decisões fechadas: telas de rooms são nossas; Angular 22 + Material M3; campos da tela seguem a API (sem "Andar"/"Observações" do mock); BFF repassa o token do usuário (consequência: o serviço de classes filtra por papel, então professor/aluno só veem as próprias turmas; coordenador e admin veem todas); capacidade obrigatória no formulário.

### Backend rooms (AG-01), local, não revisado
5 commits em `grupo08-feat/t3-fix-build-health`:
- `2899403` corrige o `COPY openapi` quebrado do Dockerfile (a imagem não compilava);
- `ec2b416` usa `/api/v1/health` em scripts, e2e e README (antes chamavam `/actuator/health`, que dá 401);
- `6ddd52c` cobre `GET /api/v1/health` na auditoria de contrato (`ContractCoverageIntegrationTests`);
- `b15005e` atualiza o README (migração V4 `enabled`, exclusão lógica);
- `ef30cd0` registra "Épico 6 (BFF rooms)" e "Épico 7 (frontend rooms)" e marca a story 4-4 como done (a tag `release-1.0-grupo08` existe).
Relatório: `_bmad-output/implementation-artifacts/orca/AG-01-relatorio.md`. **Conferir** se `./mvnw verify` e `docker build` realmente passaram.

### BFF de rooms (AG-02 aprovado, AG-03 local)
- `src/modules/rooms/` foi de proxy legado `/v1/rooms` para `/api/v1/rooms`, com composição de `classes` nos dois GETs, segundo downstream para classes, retry só em GET/HEAD (antes repetia PUT/DELETE), corpo cru repassado, 503 `BFF-DEPENDENCY`, `X-Total-Count` preservado, `etag`/`last-modified` removidos e `cache-control: no-store`, validação com Ajv. 154 testes verdes (Node 24), build ok. **Mergeado e publicado em `bff/grupo08` (`bb0cd63`).**
- AG-03 (commit `9d672e8`, só local): contrato offline validando as 12 operações, testes de composição e e2e. Achou e corrigiu um ETag que o Express recriava. Relatório: `orca/AG-03-relatorio.md`. **Falta:** conferir que o e2e cobre **todos** os endpoints, é **idempotente** e roda **duas vezes seguidas verde** (exigência do professor, item 5b da ficha 8.3).

### Frontend (parcial, nada mergeado)
- Base antiga (AG-04): projeto Angular 22 + Material, tema, shell com menu de 10 itens, nginx com proxy `/api/auth` e `/api/bff`, componentes de UI. Reprovada duas vezes pelo REV-2 (primeiro: proxy do nginx perdia caminho e query, ícones com fonte errada; depois: a branch não partia da principal). Os bugs foram corrigidos, mas **essa base foi descartada** porque o professor publicou o scaffold oficial.
- AG-05 (`35a575f`): autenticação (login, token em memória + cookie, refresh em 401).
- AG-06 (`db20174`): camada de dados de salas (modelos, filtros com codificação correta, erros, `RoomsApiService`).
- AG-07 (`216bb22`, `5c5a61f`): lista de salas e formulário.
- AG-08 (`f8a42e2`): detalhe de sala e recursos de acessibilidade.
Os relatórios dos que entregaram estão em `orca/`. **Nenhuma dessas entregas foi revisada.**

---

## 3. O que falta (em ordem)

1. **Base do frontend sobre o scaffold do professor.** O scaffold oficial está em `origin/main` do frontend (`f13f4d1`): Angular 22 + Material + tema, Dockerfile, nginx **sem proxy**, **sem shell, sem login, sem rotas**. Criar `frontend/grupo08-feat/base-v2` a partir dele, mantendo `angular.json`, `package.json`, tema e estrutura `app.*` dele, e trazendo por cima o que o AG-04 fez (`git show origin/frontend/grupo08-feat/base:<arquivo>`): shell, `shared/ui`, config, stubs de auth, nginx com proxy e health, Dockerfile com build args `VITE_OAUTH_BASE_URL` e `VITE_BFF_BASE_URL`, `proxy.conf.json`. Marcar no README que shell/login/kit são **provisórios** (dono: Prof. Arruda). Nunca dois `angular.json`.
2. **Reencaixar** `auth`, `rooms-data`, `rooms-list`, `rooms-detail` nessa base (rebase, seção 1), rodar `ng build` e `ng test`, corrigir.
3. **Terminar e revisar as telas**:
   - estrutura de pastas da spec: `shell/`, `shared/`, `auth/`, `surfaces/ux-rooms/{data,list,detail}` com `ROOMS_ROUTES` carregado por um único `loadChildren` em `/salas`;
   - responsividade: compact 360 a 599, medium 600 a 1279, expanded a partir de 1280 (tabela completa só ≥ 1280); screenshots em 360, 768 e 1280;
   - capacidade obrigatória no formulário; confirmação ao descartar formulário com alterações; foco no `h1` ao trocar de rota; link "← Voltar para Salas de Aula" no celular;
   - microcopy do `EXPERIENCE.md` (ex.: "Serviço de composição indisponível." + "Tentar novamente", "Nenhuma sala cadastrada ainda.").
4. **Fechar o BFF**: revisar `rooms-tests` (e2e completo + idempotente, duas execuções verdes, `GET /health`, criar uma class com o `roomId` da sala para provar `classes`, login via `POST {oauth}/login` e não direto no Keycloak), mergear em `bff/grupo08`, push. Documentar no README do módulo as exceções fora de `src/modules/rooms/` (linha em `bootstrap.ts`, `openapi/*`, `scripts/validate-contract.cjs`, script `test:e2e:rooms`, `compose.rooms.yaml`).
5. **Backend rooms**: revisar as 5 correções, rodar `./mvnw verify` e `docker build`. **Atenção à base:** a branch `grupo08-feat/t3-fix-build-health` partiu de `f660712`, que está **1 commit atrás** da `main` do rooms (`ce07d8c`: "Lê a porta da variável de ambiente e corrige a quebra de linha do Maven wrapper"). Simulei o merge (`git merge-tree`) e ele é **limpo, sem conflito**. Sequência: `git checkout -b grupo08 origin/main` → `git merge --no-ff grupo08-feat/t3-fix-build-health` → rodar os testes → `git push -u origin grupo08`. A migração V4 (exclusão lógica) existe nas duas.
6. **E2E do frontend (Playwright)**: não começou. Jornada: login → lista → criar sala → detalhe → recurso de acessibilidade → editar → excluir; idempotente; nas 3 larguras. Senha só por variável de ambiente, nunca no código.
7. **Integração final**: subir a stack e rodar o roteiro de aceitação (ficha 8.9 do plano, 17 passos). Depois, `base/grupo08` com os ponteiros dos submódulos (só **depois** do push de cada submódulo; ponteiro para commit local quebra o clone dos colegas) e os PRs para a `main` abertos à mão pelo grupo.

---

## 4. O que precisa melhorar / riscos

- **Docker do rooms**: sem a correção do `COPY openapi`, a imagem não compila e o `bff` depende dela para subir.
- **Classes filtra por papel** (decisão D5): um aluno vê "0 turmas" numa sala que tem 3. Decidir se aceita e deixa uma nota na tela, ou usa token de serviço no BFF.
- **`RoomView`** usa `allOf` com Room fechada (`additionalProperties:false`); validar a Room **antes** de acrescentar `classes` (o courses "achatou" o schema pelo mesmo motivo).
- **404 de lista**: o rooms devolve 404 quando o filtro não casa nada; o front trata como lista vazia. Em `accessibility-features`, 404 pode ser "sala inexistente" ou "sem resultado".
- **Filtros na URL**: `{`, `}` e `%` precisam de codificação (`%7B`, `%7D`, `%25`); o BFF repassa a query crua.
- **PATCH** nunca pode mandar os `default` dos schemas; só os campos alterados.
- **Porta do frontend**: o compose usa `BFF_ORIGIN=http://localhost:8080` (o BFF bloqueia escrita por cookie com `Origin` diferente). O README do professor fala em 4200 no lab. Manter 8080 no compose e no `ng serve` (ou ajustar `BFF_ORIGIN`).
- **Compose**: `prometheus.yml` coleta métricas de um serviço `auth` que não existe (é `oauth`); `blackbox` sonda `rooms:3000`; o BFF recebe `/auth/jwks` e `/auth/validate`, que o oauth não tem; falta o client `oauth-admin` no realm. Nada disso bloqueia rooms; **não corrigir sem combinar**.
- **Segredos de desenvolvimento** estão commitados em READMEs e JSON de realm do professor. Não copiar para código nosso.
- **Qualidade da orquestração** (lição): 11 agentes esperando "LIBERADO" gastaram cota sem produzir. Funciona melhor com poucos agentes trabalhando de verdade, cada um com pasta própria, e revisão no fim de cada pedaço.

---

## 5. Como rodar e testar (máquina do Lucas, Windows)

- **Node 24.x** (`node -v` deve mostrar v24) e **Docker Desktop ligado**. Os testes do BFF exigem Node ≥ 24.15.
- **Submódulos**: `git submodule update --init --jobs 12`.
- **Volumes externos** (uma vez): `docker volume create constrsw-prometheus-data`, `constrsw-keycloak-data`, `constrsw-postgresql-data`, `constrsw-mongodb-data`.
- **Subir só o necessário**: `docker compose up -d --build postgresql keycloak oauth rooms classes` e depois `docker compose -f docker-compose.yml -f backend/bff/compose.rooms.yaml up -d --build bff` (o `compose.rooms.yaml` foi criado pelo AG-03; se ainda não existir, copiar `compose.courses.yaml`).
- **BFF**: em `backend/bff`: `npm ci`, `npm run build`, `npm test -- --runInBand`, `npm run test:contract`, `npm run test:e2e:rooms` (duas vezes).
- **Rooms**: em `backend/rooms`: `./mvnw verify` (exige Docker), `docker build -t rooms-check .`.
- **Frontend**: `npm ci`, `npx ng build --configuration production`, `npx ng test --watch=false`; `docker build` com os dois build args.
- **Login de teste**: `POST {oauth}/login` (multipart `username` e `password`). Usuários: `admin@pucrs.br` (administrator, escreve), `coordinator@pucrs.br`, `professor@pucrs.br`, `student@pucrs.br` (só leem). A senha está no README do keycloak (`infrastructure/dev.local/services/keycloak/README.md`); não copiar para código.
- **Portas**: BFF 8180, oauth 8181, rooms 8105 (8189 no host), classes 8107 (8182 no host), frontend 8080.

---

## 6. Mapa de documentos

| Arquivo | Para quê |
| --- | --- |
| `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md` | plano completo: decisões, regras, fatos de contrato, interfaces entre telas, 9 fichas com tarefas e critérios. **Seção 0 prevalece** (specs do professor). |
| `_bmad-output/specs/spec-bff/` e `spec-frontend/` | specs do professor (rotas, composição, ownership, contribuição). Leitura obrigatória. |
| `docs/open-api/bff.yaml`, `grupo08-rooms-api.yaml`, `grupo01-classes-api.yaml` | contratos. |
| `_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/` | `EXPERIENCE.md`, `DESIGN.md`, mockups; `frontend/mockups/` tem os PNG (salas: frames 12, 13, 22 e `responsive/salas-*`). |
| `_bmad-output/implementation-artifacts/orca/` | relatórios dos agentes e pareceres dos revisores (o que cada um fez e o que o revisor achou). |
| `avaliacao.md` | critérios do professor (T2 exclusão lógica; T3 BFF). |

---

## 7. Use as skills do BMAD

O repositório traz as skills em `.agents/skills/` (~85) e o motor em `_bmad/`. Para este trabalho, as mais úteis, na ordem de uso:

1. **`bmad-create-epics-and-stories`** (ou `bmad-create-story`): transformar os itens da seção 3 em stories com critérios de aceite. O `rooms` já tem os épicos 1 a 5 em `backend/rooms/_bmad-output/planning-artifacts/epics.md`; faltam o 6 (BFF) e o 7 (frontend), já com título registrado.
2. **`bmad-dev-story`** ou **`bmad-quick-dev`**: implementar cada story com testes. O professor pediu "bmad-build utilizando as Specs da BFF API": confirme em `.agents/skills/` se existe com esse nome; senão use as acima apontando para `_bmad-output/specs/spec-bff/` e `spec-frontend/`.
3. **`bmad-code-review`**: revisar cada entrega antes de mergear.
4. **`bmad-correct-course`**: se aparecer divergência grande (como o scaffold do professor chegando no meio).
5. Toda story de frontend precisa do bloco `Refs: FE-CAP-N; UX-ROOMS; ownership: Grupo 08; paths: <arquivos>` (`spec-frontend/traceability.md`).

---

## 8. Ordem sugerida para quem assume (poucas peças, sem fila)

1. Fechar os agentes do Orca (seção 9) e conferir `git status` em cada pasta da seção 1.
2. `git fetch` nos 4 repositórios (as branches de trabalho já estão no GitHub desde 24/11).
3. Frontend: criar `base-v2` (seção 3, item 1) → rebase das 4 branches → build e testes.
4. Em paralelo, num segundo terminal: revisar e mergear BFF (`rooms-tests`) e rooms (`t3-fix-build-health`).
5. Playwright e roteiro de aceitação com a stack no ar.
6. `base/grupo08` com os ponteiros e PRs para a `main`.

## 9. Agentes ainda abertos no Orca (fechar!)
No Orca, projeto "G08 Rooms": REV-1b (Codex), REV-2 (Codex), AG-03, AG-04b, AG-05, AG-06, AG-07, AG-08 e AG-09a (Codex `gpt-6.2-sol`), mais agentes antigos do Antigravity esperando (AG-01 a AG-09) e um terminal "Coordenador". Eles consomem cota ao acordar. Endereços em `_bmad-output/implementation-artifacts/orca/agentes.md`. O terminal "Coordenador" (`term_e7327707-...`) é só a caixa de saída para mensagens do Orca.

---

## 10. Estado exato ao desligar os agentes (24/11/2026)

Todos os agentes estavam parados (nenhum no meio de uma edição) e todo trabalho real está commitado e no GitHub. Resumo por agente:

| Agente | Resultado final |
| --- | --- |
| AG-01 (rooms) | 5 commits de correção; relatório entregue; **não revisado**; `mvnw verify` e `docker build` a conferir |
| AG-02 (BFF núcleo) | **aprovado e mergeado** em `bff/grupo08` (`bb0cd63`); README do módulo em `bff/grupo08-feat/rooms-readme` |
| AG-03 (BFF testes) | commit `9d672e8` em `bff/grupo08-feat/rooms-tests`; **build e suíte completa passaram (203 testes)**; subiu a stack no Docker mas **o e2e não terminou de rodar** (esperava classes e BFF ficarem saudáveis); falta rodar o e2e 2x e a revisão |
| AG-04 / AG-04b (base do frontend) | AG-04: base antiga descartada. AG-04b: **não produziu nada** (branch `base-v2` ainda igual ao scaffold do professor) |
| AG-05 (login) | commit `35a575f` em `frontend/grupo08-feat/auth`; não revisado; precisa de rebase na base nova |
| AG-06 (dados) | commit `db20174` em `frontend/grupo08-feat/rooms-data`; não revisado |
| AG-07 (lista) | commits `216bb22` e `5c5a61f` em `frontend/grupo08-feat/rooms-list`; não revisado |
| AG-08 (detalhe) | commit `f8a42e2` em `frontend/grupo08-feat/rooms-detail`; não revisado |
| AG-09a (e2e Playwright) | **não produziu nada** (branch `e2e` sem commits novos) |

Arquivos soltos que **não** devem ser commitados: nas pastas `G08-fe-ag07` e `G08-fe-ag08` há `src/app/shared/http/` e `src/app/surfaces/ux-rooms/data/` sem commit; são cópias provisórias da camada de dados do AG-06 (que está commitada em `rooms-data`). O `room-form.dialog.ts` solto em `G08-fe-ag08` é um stub do formulário do AG-07 (o real está em `rooms-list`).

Containers do Docker que ficaram no ar (podem ser desligados com `docker compose down`): `api`, `otel-collector`, `prometheus`, `classes`, `rooms`, `oauth`, `keycloak`, `postgresql` e quatro `grupo08-rev2-ag04-*` (testes do REV-2). A imagem do rooms foi construída, o que indica que o Dockerfile corrigido compila, mas confirme com o `docker build`.
