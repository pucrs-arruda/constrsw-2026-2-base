# Reconcile SPEC Closed CRAS → Architecture Spine

| | |
|---|---|
| **Lente** | Reconcile de contrato canônico (SPEC + brownfield → spine) |
| **Alvo** | `ARCHITECTURE-SPINE.md` (status: draft, atualizado 2026-10-14) |
| **Fontes** | `SPEC.md`, `brownfield-2026-1.md` (companions listados no frontmatter do SPEC) |
| **Não relido como produto** | Glossário PRD, UJ-1–UJ-4 nominais, narrativa de personas |
| **Spine alterada?** | Não |
| **Veredito** | **conflict** |

## Escopo desta lente

Duas perguntas:

1. **Requisitos quietos** do SPEC (Capabilities, Constraints, Non-goals, Assumptions, Success signal) e lições do brownfield que a spine **não aterrissou** em Rule/Prevents/convenção — onde dois grupos ainda podem divergir sem violar texto da spine.
2. **Conflitos de plataforma** onde OV-1…OV-10 **substituem de propósito** Constraints, non-goals ou rejeições do brownfield — e se esse override está **explícito na spine** para handoff `bmad-spec` (bloco “Conflito upstream” ou equivalente normativo, não só `.memlog.md`).

A spine é build-substrate: detalhe interno de um contexto não entra. O que entra é regra de malha, equidade ConstrSW, invariantes de produto que o mapa reivindica, e transparência de override de stack.

---

## Veredito

**conflict.** A malha de produto (AD-1, AD-5, AD-9, AD-2 pós-emenda FR-7/FR-10) está **materialmente mais alinhada** ao SPEC do que a spine de 2026-08-24 estava ao PRD. Permanecem (a) **gaps quietos** de recusa, LGPD/leitura, recursos/reservas e equidade de demo; (b) **handoff incompleto de override**: só AD-3 documenta conflito upstream de forma explícita — React/Vite, paved path Spring\|Nest vs checklist OV-2, e drift de pins de versão do SPEC não têm callout simétrico; (c) **registro OV-1…OV-10** referenciado no lead mas **não definido** no corpo da spine (só binds dispersos + memlog).

---

## Conflitos de plataforma (OV vs SPEC / brownfield)

### P1 — EXPLÍCITO na spine — persistência poliglota + paved path

| Upstream | Spine (OV-2, OV-4) |
|---|---|
| SPEC Constraints: stack pinada inclui **PostgreSQL 18.6**; domínios **Spring Boot 4.1.x ou NestJS 11.2.x**; sem FastAPI/.NET/Express solto. Non-goal: **MongoDB para professors**. Brownfield: rejeitar Professor em Mongo e polyglot “fora do paved path”. | AD-3: checklist de conformidade; **PG ou Mongo por contexto**; compose sobe ambos; starters Spring/Nest são seed, não lista fechada. |

**Spine:** bloco em AD-3:

> **Conflito upstream:** SPEC Constraints (PG-only; paved Spring\|Nest) e non-goal / brownfield “rejeitar Mongo professors” contradizem OV-2/OV-4. Spine prevalece para plataforma; refresh do companion via `bmad-spec` é obrigatório.

**Avaliação:** adequado para handoff Mongo/PG e non-goal Mongo professors. **Incompleto** no mesmo bloco: não cita a proibição SPEC/brownfield de **FastAPI/.NET/Express** nem a abertura total de linguagem do OV-2 (qualquer stack que passe o checklist).

---

### P2 — FALTANDO callout explícito — frontend React+Vite (SPEC) vs Angular (OV-6)

| Upstream | Spine (OV-6, AD-8) |
|---|---|
| SPEC Constraints: **BFF NestJS, React+Vite**. CAP-12 amarra frontend cruzado à stack UX (companion DESIGN/EXPERIENCE no contexto da edição SPEC). Brownfield: rejeitar mocks default / MUI tema próprio → **tokens DESIGN.md** (alinhado à spine, não conflito). | Design Paradigm + AD-8: **uma SPA Angular + Material**; Prevents **React/Vite/TanStack**; tokens DESIGN.md prevalecem. |

**Spine:** override operacional claro em AD-8, **sem** bloco “Conflito upstream” espelhando AD-3.

**Risco handoff:** agentes e grupos que leem SPEC Constraints antes da spine implementam Vite; SPEC companion list ainda aponta spine sem refresh. **Flag: conflito intencional não explicitado para bmad-spec** (só inferível por Prevents).

---

### P3 — FALTANDO callout explícito — linguagem de domínio “paved path” vs checklist OV-2

| Upstream | Spine |
|---|---|
| SPEC: “cada um dos nove escolhe Spring **ou** Nest — **sem FastAPI/.NET/Express solto**”. Brownfield tabela “O que não carregar”: mesma rejeição. | AD-3: linguagem/framework **livre** se checklist passar; FastAPI/.NET não aparecem em Prevents. |

**Produto preservado:** invariantes OpenAPI, AD-1, `employeeId` 1–1 (AD-3 Rule).

**Flag:** override de **política de equidade/stack docente** não documentado como conflito upstream; distinto de P1 (store), mas mesmo mecanismo OV-2.

---

### P4 — FALTANDO callout explícito — pins de versão do SPEC vs tabela Stack

| SPEC Constraints | Spine Stack (2026-10-14) |
|---|---|
| Keycloak **26.7.x** | Keycloak **26.8.1** |
| NestJS **11.2.x** (domínio ou BFF no texto SPEC) | NestJS BFF **12.1.3**; seed domínio Nest **12.x** |
| Spring Boot **4.1.x** | Spring Boot **4.1.1** (compatível) |
| PostgreSQL **18.6** | PostgreSQL **18.6** (compatível) |

**Natureza:** emenda de plataforma por verificação web (lead da spine), não contradição de produto. **Flag:** SPEC Constraints ficam **stale**; spine não declara que pins do companion SPEC foram superseded — handoff `bmad-spec` deve atualizar Constraints ou spine deve listar “SPEC stack pins superseded by Stack table”.

---

### P5 — Ambiguidade SPEC vs spine (produto, não stack) — “SPA por papel”

| Upstream | Spine |
|---|---|
| CAP-12 **intent:** “Uma SPA por papel (UX-LOGIN/HOME + UX-S1–S9)”. | Design Paradigm: **uma** SPA Angular com acesso por papel — “**não** uma SPA por papel”. AD-8 Prevents quatro SPAs / SPA por papel. |

**Leitura correta da malha:** uma SPA, navegação por papel (consistente com Success signal SM-3 e CAP-10). **Risco:** literal do CAP-12 no SPEC ainda sugere quatro apps; spine corrige sem callout “SPEC CAP-12 intent wording superseded”. Recomendado no refresh companion, não na spine — mas **ausente na cadeia de handoff**.

---

### P6 — EXPLÍCITO ou N/A — overrides alinhados ao SPEC

| OV | SPEC / brownfield | Spine |
|---|---|---|
| OV-1, OV-10 | Browser só BFF; negocial vs composição (brownfield anti-monolito por tela) | AD-1, AD-6, tabela OV-10 |
| OV-3 | CAP-11; non-goal provisionar Keycloak na create Employee | AD-4, AD-12 Prevents |
| OV-5, OV-7, OV-8, OV-9 | Não contradizem; estendem NFR-Q / demo | AD-10, AD-11, AD-12, AD-7 |
| OV-6 tokens | Brownfield DESIGN.md | AD-8 Rule |

**Não conflito:** Mongo **proibido como identidade Professor=Employee** — spine AD-3 Rule preserva `employeeId` 1–1 (non-goal Mongo professors = padrão 2026-1, não “Mongo banido”).

---

### P7 — Registro OV-1…OV-10 no corpo da spine

Lead afirma overrides OV-1…OV-10 (2026-10-14); **não há seção** que enumere OV com texto normativo one-liner e ligação SPEC/brownfield. Definições completas estão em `.memlog.md` (fora do artefato de handoff).

**Flag:** para `bmad-spec`, falta **índice de overrides** + pointer “quais Constraints/non-goals ficam stale”.

---

## Requisitos quietos que não aterrissaram

Itens abaixo estão no SPEC (ou brownfield como anti-padrão) e **não** têm Rule/Prevents/convenção suficiente na spine atual. Agrupados por severidade.

### G1 — gap (alto) — LGPD e recorte de leitura (CAP-3, CAP-6, CAP-10, Constraints LGPD)

**SPEC:** ocupação não nominativa de Student; roster não vaza em Reservation; Student só lê Lesson das Class referenciadas; FR-19/FR-31 implícitos no PRD companion.

**Spine:** AD-6 carrega NFR-LGPD-3 (roster fora de `reservations` BFF), FR-29 sem `studentIds`, “sem CPF”, NFR-LGPD-4 no Rule (não apagar `id`). **Mapa** reivindica “NFR-LGPD-1–4 | AD-6, AD-12”.

**Quiet drops:**

- **NFR-LGPD-1** (escopo LGPD cadastro administrativo / avaliação — tom de compliance).
- **NFR-LGPD-2** (Student vê **só** própria jornada “onde”; professor/coordenador só papéis autorizados **daquela Class**).
- **AuthZ de leitura** FR-19: predicado “Student ∈ `Class.studentIds`” no read-model BFF `lessons`.
- **FR-31:** Professor **sem atribuição** à Class não lê roster/plano daquela turma — AD-6 diz “Class atribuída” na UX-S8 mas não normatiza filtro por `professorIds`.

AuthZ na convenção cobre **escrita** (NFR-CTR-2); leitura escopada ficou de fora.

---

### G2 — gap (alto) — eixos finos de recusa Reservation / Room / Resource (CAP-7, CAP-8)

**SPEC CAP-7/CAP-8 success:** Resource **inativo** não confirma Reservation; InventoryItem **sem órfãos**; recusa segunda SALA; cancelar **libera faixa e restaura sala efetiva à padrão**; conflitos no escritor (SM-5).

**Spine AD-5:** merge FR-13 vs FR-23/24/30; no máximo uma SALA por `lessonId`; recurso **fora** de FR-13. **Não escrito:**

- Resource **inativo** na confirmação (só “Resource” no merge genérico).
- **Cancelamento** e efeito na derivação AD-5 (remover linha SALA → `lessons` recalcula para padrão) — comportamento inferido, não Rule.
- **FR-24** distinção capacidade SALA ligada a Lesson (≥ vagas da Class) vs ad hoc (capacidade > 0, a11y, sem denominador de turma).
- **InventoryItem** órfão / ciclo de vida com Resource — mapa FR-22 → AD-1 apenas.

Dois grupos podem recusar PATCH de Reservation de formas incompatíveis com CAP-8 success.

---

### G3 — gap (médio-alto) — FR-15 / FR-21 / FR-11 (CAP-4, CAP-5, CAP-7)

**SPEC:** abertura recusa capacidade insuficiente ou **zero AccessibilityFeature**; Course publicar plano com data ≥ início do período **recusado**; plano **estruturado** (SyllabusItem), não blob.

**Spine:** AD-5 “FR-15 via GET `rooms`”; AD-2 Binds FR-11/FR-15 (envelope `code`). **Quiet:** pré-condição temporal FR-11; regra capacidade ≥ vagas **e** ≥1 feature na abertura; a11y não booleano na principal Room.

---

### G4 — gap (médio) — identidade Employee / Professor (CAP-1, CAP-2, Assumptions)

**SPEC success CAP-1:** e-mail **único** (ativos e inativos); **sem delete físico**; desativar não apaga vínculos.

**SPEC CAP-2:** `employeeId` **1–1**.

**Spine:** Equidade “Professor via `employeeId`; nem todo Employee é Professor”; OQ-2 FR-1a via GET `ativo`. **Quiet:** unicidade de e-mail; proibição de DELETE físico Employee; cardinalidade **1–1** explícita Professor↔Employee; tipos EmploymentBond (Assumption: efetivo \| temporário \| bolsista).

---

### G5 — gap (médio) — Student seed e AcademicAffiliation (CAP-3, brownfield)

**SPEC:** AcademicAffiliation **não é roster**; `Class.studentIds` no mesmo seed/import; carga idempotente.

**Spine:** AD-12 + convenção Student seed; mapa FR-7–9. **Quiet:**

- Semântica **AcademicAffiliation ≠ roster** (evitar grupo modelar matrícula como secundária substituta de `Class.studentIds`).
- **Coordenação artefato único** seed Student + roster Class (FR-9) — dono e ordem entre contextos `students` e `classes`.

Brownfield alerta “BFF sem wiring students” — spine assume módulo `students` no BFF via padrão AD-6, **sem** Prevents explícito “BFF deve expor módulo students”.

---

### G6 — gap (médio) — equidade ConstrSW e Success signal (Constraints, CAP-12)

**SPEC Constraints:** sucesso de grupo = par 1–N + **rotas BFF do domínio** + **gateway REST identidade** + **telas de domínio alheio**; BFF e OAuth **sem dono exclusivo**.

**Spine:** AD-4 Prevents dono exclusivo IdP; AD-8 Prevents grupo implementar **tela do próprio contexto** (FR-28 quiet no SPEC, **aterrissou**). **Quiet:**

- Conjunção “não basta só o par 1–N” como invariante de demo/SM-4.
- Anti-sucesso “modelo mais rico que os outros” / backend órfão do BFF — brownfield lição 1–2, não Prevents na spine.

---

### G7 — gap (baixo) — non-goals que alargam agregado se ignorados

SPEC Non-goals (notas, frequência, histórico; EmploymentBond estilo SIGRH; fila de aprovação de reserva) **não** viraram Prevents. AD-8 cobre tela de alta Student; AD-5 cobre 18 reservas padrão.

**Risco:** `lessons` ou `employees` alargam secundárias com campos de SIGRH ou lançamento de nota sem violar AD atuais.

---

## O que aterrissou bem (pós-emenda 2026-10-14)

Relativo ao contrato SPEC, estes pontos **não** são achado nesta lente:

| Área | Evidência spine |
|---|---|
| Malha BFF única, CORS, módulos `ocupacao` / `lessons` / `classes` | AD-1, AD-6, CAP-10 |
| Contract-first, faixas, problem+json, Student.id opaco + Course.codigo | AD-2 |
| Sala efetiva só em `lessons`; FR-13 sem Recurso; merge escritor | AD-5 |
| Gerar Lesson só via `classes`; imutabilidade data+faixa; feriados | AD-9 |
| Keycloak via oauth REST; sem provision na create Employee | AD-4, AD-12 |
| Frontend cruzado; não telas do próprio domínio; OQ-1 aberto | AD-8, Deferred |
| Compose lab; health; métricas; testes camadas; seed idempotente | AD-7, AD-10–12 |
| Brownfield: derivação sala efetiva, GET por id, não copiar pessoa | AD-1, AD-5 |
| Ciclo escrita lessons↔reservations | AD-1 |

---

## Matriz CAP → spine (compacta)

| CAP | Cobertura | Nota |
|---|---|---|
| CAP-1 Employee/Bond | parcial | FR-1a/OQ-2 sim; e-mail único, no DELETE físico: G4 |
| CAP-2 Professor | parcial | Ativo + is-a sim; 1–1: G4 |
| CAP-3 Student seed | parcial | Seed sim; Affiliation≠roster, carga cruzada: G5 |
| CAP-4 Course/plano | parcial | Mapa; FR-11 data, blob vs estruturado: G3 |
| CAP-5 Class/Lesson gerar | sim o bastante | AD-5, AD-9 |
| CAP-6 Lesson/sala efetiva | sim | AD-5, AD-6 FR-19 read-model (authZ leitura: G1) |
| CAP-7 Room/Resource | parcial | Contextos; inativo/órfão: G2 |
| CAP-8 Reservation | parcial | Merge sim; cancel/inativo/capacidade ad hoc: G2 |
| CAP-9 OpenAPI | sim | AD-2, AD-3 checklist |
| CAP-10 BFF | sim | AD-6, OV-1 |
| CAP-11 Identidade | sim | AD-4 |
| CAP-12 Frontend | conflito stack | Angular OK na spine; SPEC React: P2; FR-28: sim AD-8 |

---

## Handoff `bmad-spec` — o que a spine deveria ganhar (prescrição de reconcile, não texto proposto)

1. **Callouts simétricos a AD-3** para P2 (React+Vite → Angular OV-6), P3 (paved path linguagem → checklist OV-2), P4 (pins SPEC stale → Stack table).
2. **Seção Overrides OV-1…OV-10** one-liner + coluna “SPEC/brownfield superseded”.
3. **Companion SPEC refresh:** Constraints stack, CAP-12 wording “uma SPA com acesso por papel”, non-goals Mongo (clarificar “Mongo permitido por contexto, não identidade Professor”), alinhar pins ou referenciar spine Stack.
4. **Gaps produto (G1–G2):** Rules de leitura LGPD/FR-19/FR-31 e recusa Resource inativo / cancel / capacidade SALA — spine ou explicit defer “OpenAPI de domínio carrega FR completo” (hoje mapa oversell).

---

## Não é achado

- Relitigar glossário disciplina/turma/aula/reserva/faixa.
- OQ-1/OQ-3 abertos no SPEC — spine coerente (Deferred + default AD-8).
- Arquitetura interna hexagonal, portas seed, codegen — além do SPEC.
- AD-11/AD-12 como extensão de plataforma — não contradizem non-goals SPEC.

---

*Reconcile somente. SPEC não modificado. Spine não modificada. 2026-10-14.*
