---
reviewer: adversarial-finalize
lens: duas unidades um nível abaixo que obedecem todos os ADs à letra e mesmo assim divergem (OV-10: regra no BFF / join no domínio)
spine: ARCHITECTURE-SPINE.md
spine_updated: 2026-10-14
date: 2026-10-14
status: complete
spine_unchanged: true
altitude: initiative
---

# Review adversarial (finalize) — Architecture Spine Closed CRAS

Ataque à spine **atual** (AD-1…AD-12, overrides OV-1…OV-10, AD-9 `POST /v1/lessons/gerar`, FR-29 em `modules/ocupacao`, `classes`/`reservations` → `employees.ativo`). Para cada buraco: **duas unidades** (contexto, módulo BFF ou par domínio×BFF) que passam o checklist de conformidade e respeitam cada Rule **como escrita**, e ainda assim não integram — formas compartilhadas incompatíveis, dois donos da mesma associação, dois caminhos de mutação do mesmo fato, divergência poliglota, ou modos de falha OV-10 (“BFF roubou regra negocial” / “domínio embutiu join de tela”).

Spine **não** alterada neste review. Fechos apontam qual AD apertar.

Glossário, UJs e OQ-1 não são relitigados como produto; entram só onde a spine deixa escolha de implementação.

## Veredito

**Quase-handoff, ainda não contrato fechado para nove grupos em paralelo.** Os emendamentos de 2026-10-14 fecharam buracos graves (geração de Lesson, dono nominal de FR-29/FR-19 no BFF, leitura de `employees.ativo`, classificação OV-10 na tabela AD-1). O que resta é o **interior do fio compartilhado** e o **limite BFF↔domínio**: dois times AD-compliant ainda colidem em ocupação de Professor, chave canônica `professorId`, schema de `GET …/ocupacao`, identidade JWT→ids, e em “proxy puro” vs read-model que filtra/recalcula. Não é nitpick de stack — quebra UJ-2/UJ-3/UJ-4 na demo.

## Método

Uma unidade “obedece à letra” se:

- Respeita as setas AD-1 (negocial vs composição; `POST /v1/lessons/gerar` só `classes`→`lessons`; ciclo `lessons`↔`reservations` só GET profundidade 1; browser só BFF).
- Publica OpenAPI 3.1 em `openapi/openapi.yaml`, paths `/v1/<contexto>`, tokens citados, UUID/string, `data`+`faixaId`, listas `items`, RFC 9457 (AD-2).
- Passa checklist AD-3 (incl. poliglota PG/Mongo por contexto; Professor is-a só via `employeeId`).
- Resource-server + `GET /v1/identidade/me` conforme fragmento oauth; BFF login/cookie; sem browser→Keycloak (AD-4).
- `lessons` único dono de derivação `salaEfetivaId`; escritores fazem merge de conflito; BFF não recalcula sala efetiva (AD-5).
- CORS só BFF; proxy vs read-model rotulados; FR-29 só `modules/ocupacao/`; FR-19 só módulo `lessons` do BFF; roster só módulo `classes`; sem roster em `reservations` (AD-6).
- Compose, `cras_<contexto>`, `/health`, métricas, seed idempotente (AD-7, AD-12).
- SPA única Angular; dados só via BFF (AD-8).
- Geração/imutabilidade data+faixa (AD-9); resilience nos hops (AD-10); camadas de teste (AD-11).

O teste **falha** se duas unidades compliant não fecham malha ou produzem SM-5/identidade quebrada.

## O que a revisão anterior já não precisa relitigar

- **P1 antigo (quem dispara gerar Lesson):** AD-9 + seta `CLA → POST gerar → LES` no mermaid fecham o dono do protocolo; resta pinar **payload** e **forma do esqueleto** (WeeklySlot), não a existência da seta.
- **Dois módulos BFF donos de FR-29:** AD-6 fixa `modules/ocupacao/` — desde que ninguém reimplemente ocupação “de zelo” noutro módulo (buraco novo abaixo).

## Pares (buracos)

### H1 — `classes` × `reservations`: ocupação AD-5 cumprida, universo de Professor incompatível

**Unidade A (`lessons`, dono de `GET /v1/lessons/ocupacao`).** Rule AD-5: resposta com `salaEfetivaId` já resolvido por par `data`+`faixaId`. Implementação mínima: lista de `{ salaEfetivaId }` (ou só salas) derivada das Lessons da faixa. Não inclui `professorId` — a prosa de FR-13 fala em “union salas/professores”, mas o Rule pinado na mesma AD cita explicitamente `salaEfetivaId` no GET ocupacao, não um envelope de professores.

**Unidade B (`classes`, FR-13).** Antes de abrir Class, chama **só** `GET /v1/lessons/ocupacao` (seta permitida). Interpreta o payload como **ocupação de salas** única. Para Professor, faz union **local**: percorre `professorIds` da própria Class em draft e consulta GET em `professors` — **não** vê Reservation ad hoc do mesmo Professor na faixa (seta CLA→RSV não existe para ocupação; CLA→RSV só GET ocupacao no diagrama é CLA→LES e CLA→RSV para merge AD-5 — reservations tem GET ocupacao próprio).

**Unidade B′ (`reservations`, FR-23/24/30).** Recusa POST com merge AD-5: chama `GET /v1/lessons/ocupacao` **e** olha linhas locais. Assume que ocupacao traz **professores ocupados** na faixa; se A não mandar, B só vê Reservation local — Lesson de outra turma não bloqueia.

**ADs cumpridos:** AD-1 (setas corretas), AD-5 letra (escritores recusam; BFF não calcula sala efetiva), AD-2 (`data`, `faixaId`).

**Colisão:** Rafael abre Class com Professor já reservado ad hoc (B′ autoriza se ocupacao não listar professor). Marina reserva Professor em faixa com Lesson presencial (A listou só sala; B′ autoriza). SM-5 quebra com duas implementações “corretas”. **Não** é violação óbvia de OV-10 — é **forma compartilhada** do endpoint que AD-5 usa como único leitor de composição para escritores.

**Fechar:** apertar **AD-5** + **AD-2** — JSON Schema canônico de `OcupacaoFaixa` (campos obrigatórios: `data`, `faixaId`, `items` com pelo menos `salaEfetivaId` **e** `professorIds` ocupados na faixa, origem Lesson via Class **e** Reservation `professorId`; RECURSO **fora** deste GET — permanece no escritor `reservations`). Proibir segundo algoritmo de “professor livre?” em `classes` sem GET em `reservations` quando a regra exigir union com reserva.

---

### H2 — `lessons` × `reservations` × `classes`: dois caminhos de mutação da “sala na faixa” (AD-5 explícito, efeito colateral não)

**Unidade A (`lessons`).** PATCH `modalidade=remoto` permitido (FR-17). AD-5: remoto → `salaEfetivaId` nulo **mesmo com** linha SALA existente; `lessons` não apaga Reservation. Ocupacao de A deixa de emitir a sala da Lesson **e** não emite `targetId` da linha SALA (não é Lesson).

**Unidade B (`reservations`).** Linha `kind=SALA` com `lessonId` permanece até FR-30. `GET /v1/reservations/ocupacao` continua a expor a linha. AD-5 diz que FR-29 no BFF une salas efetivas + SALA ad hoc + RECURSO — linha SALA **ligada a Lesson** não está nomeada como “ad hoc”; interpretação B: linha com `lessonId` **não** entra no join FR-29 (só ad hoc).

**Unidade C (`classes`, nova abertura FR-13).** Consulta só `GET /v1/lessons/ocupacao` — vê faixa **sem** aquela Room (remoto). Autoriza nova Class na Room que B ainda “segura” via linha SALA não cancelada.

**ADs cumpridos:** AD-1 (sem escrita lessons→reservations), AD-5 (ordem da fórmula remoto; dono derivação), AD-6 (BFF não recalcula sala efetiva).

**Colisão:** estado espacial da faixa depende de **PATCH Lesson** vs **POST/DELETE linha** sem invariante de compensação ou recusa cruzada. Cancelamento tardio de reserva reexpõe conflito com Class já aberta. Escritores legais, malha inconsistente.

**Fechar:** apertar **AD-5** — uma das opções pinadas (não três): (i) PATCH remoto **recusa** FR-* enquanto existir linha SALA da `lessonId` (`lessons` GET linhas RSV, 409); (ii) linha SALA ligada a Lesson **entra** no universo de ocupacao de salas que `classes`/`reservations` consultam mesmo com `salaEfetivaId` nulo; (iii) única liberação espacial na faixa = FR-30, e modalidade remota exige pré-condição documentada.

---

### H3 — `professors` × `classes`: mesma equidade AD-3, duas chaves canônicas para alocação

**Unidade A (`professors`, MongoDB).** Checklist AD-3: `employeeId` 1–1, documento Professor keyed por `employeeId` (um UUID, PK = FK). OpenAPI: `GET /v1/professors/{employeeId}`. `professorId` **ausente** — identidade de papel docente = Employee id.

**Unidade B (`classes`).** FR-13 guarda `professorIds[]` como ids retornados por listagem de professors — implementação seed Spring usa UUID **próprio** emitido em create Professor (Nest no outro grupo). GET Professor por id funciona; GET por `employeeId` 404.

**Unidade C (BFF módulo `professors`, OQ-ARCH-2 [ASSUMPTION]).** Read-model de vista enriquece display name com GET Employee — usa `{employeeId}` de A; proxy CRUD usa `{professorId}` de B.

**ADs cumpridos:** AD-3 (A: “não identidade Mongo=Employee” lido como PK distinto permitido; B: `employeeId` obrigatório no agregado), AD-2 (`employeeId` token existe), AD-1 (PRO→EMP negocial).

**Colisão:** `professorIds` na Class apontam para entidades inexistentes no outro modelo; FR-31 roster e FR-13 abertura falham de forma intermitente. `/v1/identidade/me` devolve `professorId` **e** `employeeId` (AD-4) — qual entra em `professorIds`? Dois consumidores compliant, contrato de alocação não fechado.

**Fechar:** apertar **AD-2** + **AD-4** — Professor tem `professorId` UUID v4 **próprio**; `employeeId` obrigatório 1–1; **consumidores de alocação** (`classes`, `reservations`) persistem **somente** `professorId`; paths pinados `/v1/professors/{professorId}`; fragmento oauth fixa mapeamento claim → `professorId`.

---

### H4 — módulo BFF `classes` × contexto `lessons`: OV-10 “BFF roubou regra negocial” via proxy “inteligente”

**Unidade A (BFF, módulo `classes`).** AD-6: proxy CRUD pass-through, envelope AD-2, **sem regra nova**. Implementação: antes de `POST /v1/classes` repassado ao domínio, BFF chama `GET /v1/employees/{id}` para cada `professorId` resolvido e recusa 409 se `ativo=false` — “melhor UX”, “OQ-2 visible no BFF”. Anti-padrão AD-1 cita BFF validando Employee ativo **no lugar de** `professors`; aqui BFF valida no **lugar de** `classes` (que AD-1 já manda GET `employees.ativo`).

**Unidade B (`classes`).** Implementa FR-1a: GET `employees` para `ativo` no escritor. Recusa 409 `code=FR-1a` quando inativo.

**Unidade C (frontend UX-S5, outro grupo).** Trata 409 do BFF com `code` inventado `BFF-EMP-INACTIVE` vs 409 `FR-1a` do domínio — ambos “legal” sob AD-2 se BFF usar problem+json genérico.

**ADs cumpridos:** AD-6 (proxy vs read-model — A rotula proxy), AD-1 (B não deixa de validar), AD-4 (auth via BFF).

**Colisão:** duas fontes de recusa para o mesmo invariante; códigos FR divergem; testes de contrato AD-11 na fronteira BFF↔domínio **passam** (BFF forwarda body) mas comportamento observado pela UI diverge. **OV-10 failure mode:** regra negocial (`employees.ativo` na abertura) executada no BFF — tabela AD-1 diz que validação `employees.ativo` em `classes` é negocial, não visualização.

**Fechar:** apertar **AD-1** + **AD-6** — definição operacional de **proxy**: proibido hop extra a domínios para **validar** invariante FR antes do forward; permitido só authZ de papel no BFF. Lista fechada de exceções (só login). Proxy deve repassar 409 do domínio byte-a-byte (`code` FR-*). OQ-2 só nos escritores pinados.

---

### H5 — contexto `lessons` × módulo BFF `lessons`: OV-10 “domínio embutiu join de tela”

**Unidade A (`lessons`).** `GET /v1/lessons/{lessonId}` devolve agregado Lesson + objeto aninhado `room: { codigo, predio, capacidade }` obtido por GET interno em `rooms` — “evita N+1 para o BFF”, “ainda é dono da derivação”. Não inclui `studentIds`. Argumento: não é join de **nove** contextos, só Room.

**Unidade B (BFF módulo `lessons`, FR-19).** Read-model Student consome AD-5: usa `salaEfetivaId` + GET `/v1/rooms/{id}` separado — não espera nested `room`. OpenAPI BFF documenta shape flat.

**Unidade C (`lessons`, alternativa compliant).** Devolve só `salaEfetivaId` + `roomId` padrão; zero nested.

**ADs cumpridos:** AD-1 (anti-padrão fala em payload Lesson completo **no agregado Class**, não proíbe explicitamente Room nested em Lesson), AD-5 (sala efetiva derivada no domínio), AD-6 (FR-19 no BFF).

**Colisão:** A e C publicam OpenAPI 3.1 válidos com **schemas diferentes** para o mesmo path de domínio; BFF FR-19 quebra ou bifurca. Cadastro Room duplicado na resposta (FR-3 espírito). **OV-10:** domínio fez join de UI (código/nome/capacidade da sala para Caio) no agregado Lesson.

**Fechar:** apertar **AD-1** (anti-padrões) + **AD-2** — `GET Lesson` **proíbe** objetos nested de outros contextos; só ids (`roomId`, `classId`, `salaEfetivaId`). Join de nome/código Room **só** read-model BFF (visualização OV-10). Teste de contrato: schema Lesson sem `$ref` a Room.

---

### H6 — `modules/ocupacao` × módulo BFF `lessons`: FR-29 legal, FR-19 “quase ocupacao” (dupla contagem / regra smuggled)

**Unidade A (`modules/ocupacao`).** AD-6: único dono de FR-29. Chama `GET lessons/ocupacao` + `GET reservations/ocupacao`, une salas efetivas + SALA ad hoc + RECURSO, **sem** `studentIds`. Não deduplica linha SALA de Lesson já refletida em `salaEfetivaId`.

**Unidade B (módulo BFF `lessons`, FR-19).** Para agenda Student, além de lessons+courses, chama `reservations` filtrado por `lessonId` e **recalcula** “onde está a aula” se `modalidade=remoto` — lógica espelhada de AD-5 “para exibir certo”. Não persiste — argumento read-model.

**Unidade C (módulo BFF `lessons`).** Implementação mínima: só campos do domínio; remoto mostra null mesmo com linha SALA (fiel AD-5).

**ADs cumpridos:** AD-6 (FR-19 só módulo lessons; FR-29 só ocupacao), AD-5 (domínio deriva; BFF consome).

**Colisão:** Caio vê sala “fantasma” ou null inconsistente entre UX-S9 e UX-S4; A conta slot duas vezes na grade FR-29. B cruza linha de **regra de derivação** (quando mostrar sala) — **OV-10 BFF** reimplementa pedaço de AD-5 no read-model FR-19.

**Fechar:** apertar **AD-6** + **AD-5** — FR-19 **só** exibe `salaEfetivaId` e metadados Lesson/Course já resolvidos; proibido reinterpretar linha SALA no BFF. FR-29: regra pinada de deduplicação SALA Lesson vs ad hoc. Um único documento de composição BFF (rotas → módulo → fontes GET).

---

### H7 — `employees` (Spring) × `reservations` (Nest): poliglota compliant, mesmo JWT, malha AuthZ divergente

**Unidade A (`employees`, Spring Boot seed).** Checklist AD-3 item 5: JWKS + `/v1/identidade/me`. Guard exige `ROLE_coordenador` com prefixo Spring; `iss` = `http://localhost:8080/realms/closed-cras`.

**Unidade B (`reservations`, Nest seed).** Guard lê `realm_access.roles` literal `funcionario`; `iss` = `http://keycloak:8080/realms/closed-cras` (hostname compose). Ignora `aud`.

**Unidade C (BFF).** Propaga o mesmo Bearer do cookie para ambos — AD-10 resilience ok.

**ADs cumpridos:** AD-3 (linguagens diferentes permitidas), AD-4 (papéis v1 nomeados; adapters oauth são referência — spine diz **seed**, não obrigatório idêntico).

**Colisão:** Helena autentica; POST Employee 201; POST Reservation 403 em B, GET Employee 403 em A para papel `professor`. UJ-1 morta sem violar checklist. **Polyglot divergence** onde o compartilhado deveria ser comportamento de identidade.

**Fechar:** apertar **AD-4** + **AD-3** item 5 — adapters em `backend/oauth/adapters/*` passam a **norma de conformidade** (não exemplo): extractor de papéis sem `ROLE_`, issuers aceitos (lista env), audience; teste de fumaça JWT único roda contra os nove no compose da malha.

---

### H8 — `students` × `classes`: roster FR-9, dois escritores possíveis da associação

**Unidade A (`students`).** Seed idempotente AD-12. Interpreta FR-9 como vínculo Student↔Class no **próprio** store (`classIds[]` no import) — “roster no seed” sem chamar `classes` (STU→CLA não existe).

**Unidade B (`classes`).** `studentIds[]` na principal Class; seed de lab PATCH Class com roster; GET `students` só para validar id (FR-7).

**ADs cumpridos:** AD-1 (sem seta de escrita cruzada), AD-8/AD-12 (Student seed, sem tela alta), convenção “mutação no dono” (ambos claimam ser dono da associação).

**Colisão:** Caio em `students` sem Class; ou Class com ids fantasma; UJ-4 quebra. Dois donos da mesma relação N-N lógica.

**Fechar:** apertar **AD-1** ou convenção **Student** — **único escritor** de `Class.studentIds` = `classes`; artefato de roster consumido só por `classes`; proibir `classIds` persistido em `students`.

---

### H9 — catálogo `oauth` × dois contextos: `faixas.json` AD-2 compliant, semântica de extremo divergente

**Unidade A (`lessons`).** Carrega `backend/oauth/contracts/faixas.json` no build via submodule oauth. Parser: objeto map `{ "H": { "inicio", "fim" } }`; intervalo **[inicio, fim)** em minutos locais.

**Unidade B (`reservations`).** Mesmo arquivo; interpreta lista `[{ faixaId, inicio, fim }]` com extremo **fechado** em `fim`; comparação UTC.

**ADs cumpridos:** AD-2 (não copiar tabela; cânone A–E F–N P; par data+faixa), AD-3 (faixas só no catálogo).

**Colisão:** duas reservas/aulas adjacentes: 409 num, 201 no outro; faixa-picker UX-S4/S6/S7 desalinhado. Forma compartilhada do catálogo não pinada além da prosa.

**Fechar:** apertar **AD-2** — JSON Schema de `faixas.json` no catálogo (ordem, enum `faixaId`, `HH:mm`, timezone America/Sao_Paulo, regra **[inicio,fim)** explícita); teste CI malha compara enum OpenAPI ↔ arquivo.

---

### H10 — BFF × `frontend` (shell): sessão AD-4/AD-6 compliant, identidade de UI ausente

**Unidade A (BFF).** `POST /v1/auth/login`, cookie httpOnly SameSite=Lax, CORS com credentials na origem `:4200`. Não expõe `GET /v1/auth/me` — AD-4 não pina path único de sessão UI.

**Unidade B (`frontend/src/shell`).** Após login, chama `GET /v1/identidade/me` no **proxy BFF** roteado para módulo `employees` (primeiro módulo registrado). Student recebe shape Employee; papel errado na home.

**Unidade C (superfície UX-S*, grupo cruzado).** TanStack Query **sem** `credentials: 'include'` em metade das superfícies — AD-8 não pina QueryClient global.

**ADs cumpridos:** AD-4 (sem Keycloak no browser), AD-6 (CORS BFF), AD-8 (uma SPA, dados via BFF).

**Colisão:** login aparente e jornada morta; quatro papéis, múltiplos `/me`, zero contrato de sessão UI. Cross-port `:4200`/`:8088` exige credentials — comportamento não inexigível hoje.

**Fechar:** apertar **AD-4** + **AD-8** — `GET /v1/auth/me` no BFF (schema oauth); shell + QueryClient com `credentials: 'include'` obrigatório; seed compose **mesma origem** (proxy dev ou gateway) documentado em AD-7.

---

## Achados laterais (mesmo teste)

- **AD-2:** `ReservationLine` (`kind`, `targetId`), `WeeklySlot.diaDaSemana`, Room/Resource/InventoryItem, envelope `OcupacaoFaixa`, query `GET /v1/reservations?lessonId=&kind=` — tokens citados na prosa AD-5, não no Rule AD-2.
- **OQ-3 + UX-S7:** default AD-8 até fechar; grupo `lessons` vs superfície cruzada ainda pode publicar shapes diferentes em paralelo — consumidor deve ser OpenAPI de `lessons` (pinar em AD-8).
- **OQ-ARCH-1:** Mongo vs PG por contexto não quebra HTTP, mas duplica mental model de Employee/Professor se grupos escolherem stores opostos para pares simétricos — risco de cópia de campo (`ativo` vs `active`).
- **AD-11:** contrato BFF↔domínio verifica YAML; não detecta nested Room em Lesson (H5) se teste só na fronteira BFF.
- **Deferred codegen OpenAPI:** dois geradores “green” amplificam H1/H3/H9.

## O que a spine já impede (não relitigar)

Browser→domínio/IdP; BFF persistir agregado ou recalcular `salaEfetivaId`; CORS nos nove; join de nove OpenAPIs na UI; ausência da seta `classes`→`POST …/gerar`; FR-29/FR-19 em módulos BFF errados **por nome**; `employees.ativo` classificado negocial; classificação OV-10 explícita na tabela AD-1; anti-padrões nomeados (BFF valida ativo **no lugar de professors**, Class com payload Lesson completo).

## Fechos sugeridos (prioridade para finalize)

1. **AD-5 + AD-2:** schema e universo de ocupacao (sala **e** professor; linha SALA ligada a Lesson vs remoto; dedup FR-29).
2. **AD-2 + AD-4:** `professorId` canônico vs `employeeId`; shape Employee; identidade UI (`/v1/auth/me`).
3. **AD-1 + AD-6:** definição de proxy (sem validação FR); proibição de nested cross-context em GET de domínio (OV-10 join).
4. **AD-4 + AD-3:** adapters oauth = norma JWT, não seed decorativo.
5. **AD-1 / convenção Student:** único escritor de `Class.studentIds`.
6. **AD-2:** schema `faixas.json` + WeeklySlot enum.

Sem (1)–(3), duas unidades AD-compliant ainda falham SM-5 e OV-10 na demo.
