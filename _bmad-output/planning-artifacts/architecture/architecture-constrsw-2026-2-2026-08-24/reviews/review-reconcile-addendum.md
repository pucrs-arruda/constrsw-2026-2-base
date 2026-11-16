# Review — Reconcile addendum × architecture spine

- **Lente:** reconcile de input (addendum do PRD)
- **Fonte:** `_bmad-output/planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/addendum.md`
- **Contra:** `_bmad-output/planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md` (draft, 2026-08-24)
- **Regra:** extrair o que o addendum pedia e **não pousou** na spine — sobretudo grade A–E / F–N / P, layout de submódulos, Keycloak, pares 1–N, alternativas rejeitadas, e o mecanismo que o PRD deixou para a arquitetura. Não alterar a spine. Não relitigar glossário, UJs nem OQ-1.

**Veredicto: PARCIAL.** Paradigma, submódulos, IdP/BFF e a maior parte das recusas pousaram. O cânone de **relógio** da grade e o **esquema 1–N nomeado** (tipos e atributos) ficaram só como ponteiro ao addendum — nove grupos ainda podem divergir nisso sem violar um `AD`.

---

## Covered (pousou)

### Mecanismo e stack (o que o addendum já travou)

| Pedido do addendum | Onde na spine |
| --- | --- |
| Contract-first OpenAPI como formato do produto, não stack à escolha | AD-2 (YAML 3.1 fonte da verdade) + AD-3 (Spring **ou** Nest por contexto; OpenAPI pinado) |
| Layout **submódulos** Git, um repo por contexto, não pastas de monorepo | Structural Seed + comentário explícito; lista `backend/{oauth, employees…reservations, bff}` + `frontend`. Confere com `.gitmodules` (11 entradas). |
| Keycloak = IdP da disciplina; UI sem adapter JS | AD-4 Prevents `keycloak-js` / adapter Node DEPRECATED; UI não conhece URL do Keycloak |
| Nove grupos implementam gateway REST no próprio serviço (papéis/escopos); sem dono exclusivo do IdP | AD-4: resource-server + JWKS + `GET /v1/identidade/me` + catálogo `roles-scopes.yaml` por PR; Prevents “um grupo dono do IdP” e “nove endpoints de login” |
| Módulo `oauth` compartilhado (contratos); todos plugam | Paradigma + AD-3/AD-4: realm + fragmento OpenAPI + catálogo + adapters de referência; não é 10º domínio |
| Federação CAFe/BAITA fora da v1 | AD-4 + Deferred |
| BFF: composição; cada grupo incorpora o **próprio** domínio; telas de domínio alheio = frontend cruzado | AD-6 módulos `backend/bff/src/modules/<contexto>/`; AD-8 superfícies UX-S* + OQ-1 |
| Sem sensores no caminho crítico | AD-7 / NFR-Q-2: ocupação v1 agendada |
| Sem app nativo (formato web) | AD-8: uma SPA Vite; sem SSR/RSC |

### Grade (códigos e semântica de intervalo)

- Códigos **A–E, F–N, P**; sem **O**, **E1**, **E2** — AD-2.
- Intervalo **`[início, fim)`** — AD-2 (implica “extremos que se tocam não conflitam”, embora a frase não esteja na Rule).
- Catálogo único `backend/oauth/contracts/faixas.json`; grupos **não** copiam a tabela — AD-2. Isso honra NFR-CTR-4 como *fonte única*, não como *valores*.

### Pares 1–N (equidade, não o schema)

- Convenção Equidade: “Uma principal + uma secundária 1–N por contexto **(tabela do addendum)**. IDs alheios = atributos.”
- Capability map cita Dependent, AcademicDegree, affiliation, SyllabusItem, AccessibilityFeature, InventoryItem; AD-5 nomeia `ReservationLine.kind=SALA` / linhas `RECURSO`.
- Professor is-a Employee (`employeeId`), sem copiar cadastro — AD-1 / mapa FR-3–FR-6.
- Student seed/import JSON idempotente por `id`; sem tela de alta — convenção Student + AD-8 Prevents.
- Sala efetiva = linha SALA senão `Class.roomId`; remoto sem Room — AD-5 (fórmula completa).
- OQ-3 LessonTopic deixado ao grupo `lessons` — coerente com o addendum (par existe; detalhe `syllabusItemId` e/ou enunciado é lacuna).

### Telas v1 (sem relitigar)

A spine declara que telas não se relitam. Ainda assim o mapa de capacidades amarra UX-S1 (Employee), S2 (Professor), S3 (Room/Resource), S4 (ocupação FR-29), S5 (Course), S8 (roster FR-31), S9 (Student FR-19), shell LOGIN/HOME. Frontend cruzado e “no máximo um grupo por UX-S*” estão em AD-8.

### Alternativas rejeitadas que viraram Prevents

| Rejeição do addendum | Spine |
| --- | --- |
| Nove CRUDs com `pessoa` | AD-2 Prevents `pessoa`/`evento`/`slot` |
| Cada grupo implementa as *próprias* telas | AD-8 Prevents quatro SPAs; frontend cruzado |
| Um grupo dono do Keycloak | AD-4 |
| Adapter JS da UI no Keycloak | AD-4 |
| Tela de alta de Student | AD-8 |
| 18 reservas da sala padrão | AD-5 |
| Faixas E1/E2 | AD-2 |
| Terceira classe / N–N com entidade própria | AD-1 “IDs alheios são atributos, não terceira classe” + Equidade |
| `Pessoa` genérica Student/staff | AD-2 + convenção Student |
| Copiar nome/e-mail de Employee em Professor | mapa FR-3 / NFR-ID |
| Otimizador / IoT / sensores na v1 | AD-7 + Deferred ocupação real/no-show |
| Nome Closed CRAS | frontmatter + título |

### Mecanismo que o addendum **deixou** para a arquitetura — e a spine **preencheu**

O addendum disse explicitamente: Spring vs Express etc. é da arquitetura; detalhe OIDC vs SAML/CAFe de produção é da arquitetura.

| Aberto no addendum | Preenchido na spine |
| --- | --- |
| Stack por contexto | AD-3: Spring Boot 4.1.x **ou** NestJS 11.2.x; BFF **só** NestJS `[ASSUMPTION]`; UI React+Vite `[ASSUMPTION]` |
| OIDC vs SAML / CAFe | Keycloak 26.7.2; login = Direct Access Grant no BFF `[ASSUMPTION]`; Auth Code+PKCE e CAFe/BAITA no Deferred |
| Envelope operacional (implícito) | AD-7 Compose, um DB `cras_<contexto>`, portas seed |

Isso **não** é miss: é o trabalho que o addendum pediu. Tensões dessa preenchidura estão em Conflicts.

---

## Gaps (não pousou ou diluiu)

### G1 — Horários concretos da grade (A 08:00–08:45 … P 21:45–22:30) e calendário seg–sáb

- **No addendum:** tabela completa de 15 faixas com relógio; “Aulas de segunda a sábado”; “Depois de E vem F (almoço)”; “Extremos que se tocam não conflitam.”
- **Na spine:** só os **códigos** e `[início, fim)`; “não copiar a tabela”; ponteiro a `faixas.json`. Structural Seed cita o arquivo, **não** o conteúdo nem a obrigação “reproduz o addendum”. “Seg–sáb” não aparece em AD nenhum (só na tabela do addendum, se o grupo abrir o PRD).
- **Por que diverge:** ocupação FR-13/23/29 e o intervalo meio-aberto só são testáveis com os instantes. Sem pin, `oauth` (ou qualquer contexto) pode gravar B=09:00–09:45, inventar O, ou gerar Lesson no domingo. O buraco E→F (almoço) e o furo 09:30–09:45 (B→C) somem.
- **Severidade:** high (cânone compartilhado; nove writers de `data+faixa`).
- **Ação sugerida:** na AD-2 ou no seed, uma linha: `faixas.json` reproduz a tabela do addendum (código + início + fim); WeeklySlot / geração de Lesson só seg–sáb. Não relitigar os horários.

### G2 — Pares 1–N: tipos e atributos v1 não são invariante da malha

- **No addendum:** duas tabelas — principal/secundária por contexto **e** atributos v1 de cada uma (Dependent, AcademicDegree, AcademicAffiliation, SyllabusItem.`kind`, AccessibilityFeature, InventoryItem, **WeeklySlot (dia seg–sáb + `faixaId`)**, LessonTopic, ReservationLine `kind` SALA\|RECURSO + `targetId`; principals com `id`/nome/e-mail/ativo, Class.`roomId`+`professorIds`+`studentIds`, Lesson modalidade + `flagAvaliacao`, Reservation.`lessonId` opcional, etc.).
- **Na spine:** uma frase “tabela do addendum”. O nome **WeeklySlot** não ocorre. Atributos das secundárias (exceto ReservationLine na AD-5 e LessonTopic no Deferred OQ-3) não são Rule. Capability map ecoa alguns rótulos FR, não o schema mínimo.
- **Por que diverge:** equidade ConstrSW *é* “1 principal + 1 secundária”. Sem os **nomes**, o grupo `classes` pode modelar esqueleto como RFC 5545, `employees` pode criar terceira classe Vínculo–Setor, `courses` pode soltar SyllabusItem num blob. Isso é exatamente a divergência que a tabela do addendum existia para impedir — e que a altitude da spine deveria fixar porque nove unidades escolhem incompatível.
- **Severidade:** high (equidade + geração Lesson depende de WeeklySlot).
- **Ação sugerida:** uma tabela seed “par 1–N” (contexto / principal / secundária / 2–4 atributos v1). Detalhe de ORM continua Deferred; os **nomes** não.

### G3 — Feriados não excluídos da geração de Lesson (lacuna conhecida da v1)

- **No addendum:** lacuna explícita — feriados **não** saem da geração na v1.
- **Na spine:** silêncio. FR-16 no mapa é “gerar Lesson”; nada impede um calendário municipal em `classes` enquanto `lessons` assume toda data do período.
- **Severidade:** high (write-path compartilhado Class → Lesson).
- **Ação sugerida:** AD-5 ou convenção: geração v1 materializa **todas** as datas do período × WeeklySlot; feriado não é filtro.

### G4 — Recusa FR-7 (roster com `studentId` inexistente) fora do envelope AD-2

- **No addendum:** “Recusa roster cujo `studentId` não exista (FR-7)” ao lado do seed JSON.
- **Na spine:** seed JSON + idempotência pousaram; a lista de `code` FR da AD-2 é FR-13, 15, 23, 24, 30, 4, 11 — **sem FR-7**.
- **Severidade:** medium (`classes` vs `students` no 409).
- **Ação sugerida:** incluir FR-7 no conjunto `application/problem+json` da AD-2.

### G5 — Alternativas rejeitadas que não viraram Prevents / Deferred

| Rejeição | Efeito se um grupo relitigar |
| --- | --- |
| Folha como SIGRH (cargo, salário, ponto) | `employees` estoura o par 1–N e o recorte v1 |
| Todo Employee é Professor | cadastro-mestre vira só docentes; is-a num sentido some |
| Ser o SIGAA/TOTVS da disciplina | escopo de SIS ao vivo (já “sem SIS” nas lacunas) |
| App nativo ou totem | AD-8 implica web, mas não Prevents nativo |
| Otimizador / IA / twin (além de sensor) | Deferred fala evento/no-show e Edu-API, não “sem otimizador na v1” |
| Nomes `SIG*`, suíte, “Campus AI”, marca PUCRS como produto | naming; baixo risco de contrato |

- **Severidade:** medium (SIGRH + “todo Employee é Professor”); o resto low.
- **Ação sugerida:** duas linhas em Prevents da AD-1/convenção Equidade; SIGAA/nativo/IA podem ir ao Deferred como “não é o recorte”.

### G6 — Estrada pós-v1 incompleta no Deferred

- **No addendum (ordem, *não* compromisso):** (1) extrato Censo em `courses`/`students`/`professors`/`classes`; (2) evento ocupação/no-show; (3) OneRoster/Edu-API; (4) CAFe/BAITA; (5) agente de grade com IDs estáveis + confirmação humana.
- **Na spine Deferred:** (2)(3)(4) aproximados (evento/no-show, OneRoster/Edu-API, CAFe). **Faltam Censo e agente de grade.**
- **Severidade:** low (estacionado). Sem eles, um grupo “prestativo” pode protocolar Censo ou otimizar grade na v1.
- **Ação sugerida:** duas bullets no Deferred.

### G7 — Lacunas conhecidas não arquiteturais (registrar, não pin)

Não são invariantes da malha, mas o addendum pedia que não se inventasse motor no lugar:

- Capacidade vs código de bombeiros: v1 = atributo, **não** motor de alvará — silêncio na spine (Room.capacidade nem é seed).
- Sem entrevistas / rubrica / SIS ao vivo — fora de altitude; SIS ao vivo já é coberto pelo seed JSON.

**Severidade:** low. Opcional: Deferred “sem motor de alvará”.

### G8 — Mapa de capacidades some UX-S6 / UX-S7

- **No addendum:** “Abrir Class + esqueleto” (coordenador) e “Ajustar Lesson + Reservation” (professor) são superfícies de primeiro nível.
- **Na spine:** FR-13–16 e FR-17/18/23/24 **não** citam UX-S6/S7, enquanto S1–S5 e S8–S9 citam. A spine disse que não relita telas — ok — mas o mapa ficou assimétrico.
- **Severidade:** low (OQ-1 continua aberto; não atribui donos).
- **Ação sugerida:** duas células no mapa, sem fechar OQ-1.

---

## Conflicts (tensão, não override duro)

Nenhuma Rule da spine **anula** uma trava do addendum. Há três preenchiduras que um grupo lendo só o addendum interpretaria diferente:

### C1 — “Gateway REST” nos nove vs login só no BFF

- **Addendum:** cada um dos nove implementa gateway REST para o Keycloak no próprio serviço; a UI fala com **o** gateway (não com o IdP).
- **Spine:** browser autentica **só** no BFF (`POST /v1/auth/login`); os nove são **resource-server** (JWKS + papéis); contextos recusam Origin de SPA (AD-6).
- **Leitura:** compatível se “gateway” = resource-server + `identidade/me`, e o BFF é o único gateway *de browser*. Incompatível se o aluno do addendum expuser login em cada um dos nove (a spine Prevents isso).
- **Ação:** uma frase na AD-4: o gateway de browser é o BFF; o gateway de cada contexto é resource-server, não login.

### C2 — Direção OIDC vs Direct Access Grant (ROPC)

- **Addendum:** “Direção de protocolo: OIDC (pesquisa RNP/BAITA). Detalhe OIDC vs SAML/CAFe de produção é da arquitetura.”
- **Spine:** ROPC/Direct Access Grant `[ASSUMPTION]`; Authorization Code + PKCE no Deferred. ROPC é OAuth2, não o fluxo OIDC que a pesquisa RNP/BAITA aponta.
- **Leitura:** o addendum *autorizou* a arquitetura a escolher o detalhe; a tag ASSUMPTION está correta. Ainda assim a “direção OIDC” não é nomeada como herdada — só o desvio de laboratório.
- **Ação:** na AD-4, uma linha: direção de produto = OIDC; v1 de laboratório = ROPC no client `bff`; promoção = Code+PKCE (já Deferred).

### C3 — Keycloak “dentro” de `oauth` vs processo no Compose

- **Addendum:** módulo `oauth` compartilhado = **Keycloak +** contratos.
- **Spine:** Keycloak é serviço Compose `:8080` `start-dev`; `oauth` é catálogo (realm, `faixas.json`, `roles-scopes.yaml`, adapters). Seta pontilhada `oauth -.-> KC`.
- **Leitura:** split razoável (processo ≠ git). Risco: grupo procura o IdP *dentro* do repo `oauth` e não sobe o Compose.
- **Ação:** seed já lista os dois; basta uma cláusula “IdP = imagem Compose; `oauth` = realm+contratos, não o processo.”

Não é conflito: BFF NestJS, React, ROPC — o addendum mandou a arquitetura escolher.

---

## Matriz pedida (pousou? / miss)

| Tema | Pousou? | Nota |
| --- | --- | --- |
| Grade A–E, F–N, P | **Parcial** | Códigos + `[início,fim)` + sem E1/E2/O. **Horários, almoço E→F, seg–sáb** não. G1. |
| Layout submódulos | **Sim** | Seed + “não pasta de monorepo”; 1:1 com `.gitmodules`. |
| Keycloak | **Sim, com tensão** | IdP, sem JS adapter, sem dono exclusivo, 9 resource-servers, oauth catálogo. C1–C3. |
| Pares 1–N | **Parcial** | Equidade e fórmula de sala efetiva. **Tipos/atributos (WeeklySlot!) não.** G2. |
| Alternativas rejeitadas | **Parcial** | Pessoa, telas próprias, dono IdP, adapter JS, alta Student, 18 reservas, E1/E2, terceira classe. **Faltam SIGRH, Employee≠Professor universal, SIGAA, nativo, IA.** G5. |
| Mecanismo deixado à arquitetura | **Sim** | AD-3 stack; AD-4 fluxo de login; AD-7 compose. Preenchido, não omitido. C2. |

---

## O que *não* é lacuna desta lente

- Relitar UJs, glossário, OQ-1, tokens visuais — a spine recusou de propósito; o addendum de telas é coberto pelo UX, não precisa ser copiado.
- Versões pinadas (Keycloak 26.7.2, Nest 11, …) — acréscimo válido da arquitetura.
- Envelope RFC 9457, cookie httpOnly, um DB por contexto — mecanismo, não pedido literal do addendum, alinhado a FR/NFR.
- Rubrica da disciplina, entrevistas com secretaria — lacunas de produto, não de malha.

---

## Prioridade se a spine for atualizada (este review não aplica)

1. **G1** pin de `faixas.json` = tabela do addendum + seg–sáb.
2. **G2** tabela seed dos pares 1–N (nomes; WeeklySlot obrigatório).
3. **G3** feriados não filtram geração v1.
4. **C1+C2** uma frase cada na AD-4 (browser vs resource-server; OIDC vs ROPC).
5. **G4** FR-7 no envelope de recusa.

Spine **não** foi modificada nesta lente.
