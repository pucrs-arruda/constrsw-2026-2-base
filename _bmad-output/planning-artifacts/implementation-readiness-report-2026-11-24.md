---
stepsCompleted: ['step-01-document-discovery', 'step-02-prd-analysis', 'step-03-epic-coverage-validation', 'step-04-ux-alignment', 'step-05-epic-quality-review', 'step-06-final-assessment']
project_name: constrsw-2026-2
date: 2026-11-24
documentsSelected:
  - prds/prd-constrsw-2026-2-2026-08-19/prd.md
  - architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
  - epics.md
  - ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md
  - ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md
  - specs/spec-closed-cras (supplement)
uxResolved: ux-constrsw-2026-2-2026-11-23
---

# Implementation Readiness Assessment Report

**Date:** 2026-11-24
**Project:** constrsw-2026-2

## Document Discovery

### PRD Files Found

**Whole Documents:**
- `prds/prd-constrsw-2026-2-2026-08-19/prd.md` (34919 bytes)
- `prds/prd-constrsw-2026-2-2026-08-19/polish-structure-prd.md` (8776 bytes) — polish companion, not primary PRD

**Sharded Documents:**
- Folder: `prds/prd-constrsw-2026-2-2026-08-19/`
  - `prd.md` (primary)
  - addenda / reconcile / review companions (not a second PRD body)

**Proposed for assessment:** `prd.md` (+ addenda only if FR gaps require them)

### Architecture Files Found

**Whole Documents:**
- `architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md` (29937 bytes)

**Sharded Documents:**
- Folder: `architecture/architecture-constrsw-2026-2-2026-08-24/`
  - `ARCHITECTURE-SPINE.md` (primary)
  - `reviews/*` (reconcile PRD/SPEC/UX — supporting)

**Proposed for assessment:** `ARCHITECTURE-SPINE.md` (note: SPEC/UX may supersede some spine paths)

### Epics & Stories Files Found

**Whole Documents:**
- `epics.md` (44907 bytes) — Epics 0–8, 41 stories, Step 4 PASSED

**Sharded Documents:** none

**Proposed for assessment:** `epics.md`

### UX Design Files Found

**Whole Documents:** none at planning root matching `*ux*.md`

**Sharded / folder versions (TWO generations):**
- Folder: `ux-designs/ux-constrsw-2026-2-2026-08-24/`
  - `DESIGN.md`, `EXPERIENCE.md` (legacy spine)
- Folder: `ux-designs/ux-constrsw-2026-2-2026-11-23/`
  - `DESIGN.md`, `EXPERIENCE.md` (Angular 22 + Material, CAP-12, responsive DoD)

**Proposed for assessment:** **2026-11-23** (current Closed CRAS UX)

### Related (out of IR primary set, noted)

- `_bmad-output/specs/spec-closed-cras/` — CAP spine used by epics (recommended as architecture supplement)
- `_bmad-output/specs/spec-employees/` — domain spec

### Issues

- **Version duplicate (UX):** Aug-24 vs Nov-23 folders — must pick one (recommend Nov-23)
- **No classic whole+sharded PRD conflict** — single primary `prd.md`
- **Architecture age:** spine dated 2026-08-24; epics already record overrides (e.g. `/lessons/generate`, client composition FR-19/31)

## PRD Analysis

**Source:** `prds/prd-constrsw-2026-2-2026-08-19/prd.md` (primary) + `addendum.md` (mechanism/stack/screens). Companions (polish/reconcile/review) reference the same FR IDs; no additional FR IDs found.

### Functional Requirements

Total FRs: 32

#### FR-1: Ciclo de vida do Employee

Texto original do PRD. Para o serviço `employees`, vale o bloco vigente de 2026-11-16 acima: atributos do JSON Schema, `status` distinto da exclusão lógica, e `ativo` só na leitura.

Funcionário cria, edita, desativa e reativa Employee com `id` estável, nome, e-mail institucional e flag `ativo`.

**Atores / pré-condições:**
- Ator: Funcionário autenticado (papel Administrator no gateway).
- Criação: nome e e-mail institucionais obrigatórios e não vazios; `id` gerado ou atribuído na create e **imutável** depois.
- Edição de cadastro: Employee existente; altera nome e/ou e-mail (respeitando unicidade); não altera `id`.
- Desativação / reativação: Employee existente; altera somente `ativo`.

**Consequences (testable):**
- Employee (ativo ou não) permanece endereçável por `id` estável; consumidores nunca “perdem” a chave.
- E-mail institucional é único entre **todos** os Employee (ativos e desativados).
- Desativar não apaga o `id` e não remove o registro (soft-deactivate). Reativar restaura `ativo=true` sem novo `id`.
- Delete físico de Employee está fora da v1 (NFR-LGPD-4; §7).
- Employee com `ativo=false` **não** satisfaz a pré-condição de **criar** Professor (FR-4 / FR-5).
- Sinal publicado aos consumidores: `ativo`. Efeito em Class / Reservation já existentes: FR-1a.

**Edge cases / recusas:**
- Create ou update com nome ou e-mail vazios → recusa.
- Create ou update cujo e-mail já exista em outro Employee → recusa.
- Operação de escrita por papel que não seja Administrator → recusa no gateway / BFF.

---

#### FR-1a: Employee desativado e alocação já existente

Fecha OQ-2. Quando `employees` publica `ativo=false` para um Employee que já é referenciado via Professor:

- Class já atribuídas a esse Professor ficam **somente leitura** para mutações de oferta que dependem do docente.
- Novas Reservation cujo `professorId` resolve para esse Employee são **recusadas**.
- A v1 **não** exige substituição de Professor nem apaga Class / Lesson / Reservation históricas.

A enforcement dessas consequências cabe aos contextos consumidores (`professors`, `classes`, `reservations`); `employees` só publica o sinal `ativo` e o contrato (FR-3).

---

#### FR-2: Dependent 0..*

Funcionário adiciona, altera e exclui logicamente Dependent de um Employee existente, somente pelas rotas aninhadas.

**Atores / pré-condições:**
- Ator: Funcionário com papel `funcionario`.
- Employee-alvo deve existir e estar endereçável.
- Não existe Dependent sem Employee endereçável.

**Consequences (testable):**
- Um Employee tem zero ou mais Dependent.
- Atributos: `name`, `birthDate`, `dependencyType`, `status` (`Active` | `Inactive`).
- PUT e PATCH de Employee não alteram a coleção.
- Exclusão lógica esconde o Dependent e não apaga o documento.

**Edge cases / recusas:**
- Dependent sob Employee inexistente ou já excluído → recusa.
- Campo obrigatório ausente → recusa.

---

#### FR-3: Publicar identidade, não copiar cadastro

Alocação e o papel docente consomem o `id` de Employee; nenhum contexto replica nome, e-mail ou documento pessoal do Employee como cópia de cadastro.

**Consequences (testable):**
- Contrato publicado por `employees` nesta entrega inclui o Employee do JSON Schema, `ativo` derivado na leitura e os Dependent ainda visíveis. O mínimo que consumidores leem continua `id` e `ativo`.
- Consumidores (`professors`, `classes`, BFF) guardam o `id` (e resolvem nome/e-mail/`ativo` sob demanda ou via projeção do BFF); não embutem `pessoa` própria no OpenAPI.
- Não há campo CPF (nem documento pessoal equivalente) em Employee na v1.
- Falha de produto: nove OpenAPIs com `pessoa` copiada ou cadastro de “professor” com nome/e-mail duplicados fora de `employees`.

---

#### FR-4: Professor não nasce sem Employee

Não se cria Professor sem Employee **existente e ativo**. Realiza UJ-1. O contexto `employees` **não** implementa a classe Professor — só publica a pré-condição.

**Consequences (testable):**
- O `id` de Employee ativo é pré-condição do papel docente (FR-5) e a chave que a alocação referencia via Professor (`employeeId`).
- Tentativa de criar Professor com `employeeId` inexistente ou com Employee `ativo=false` → recusa (enforcement em `professors`; contrato de existência/`ativo` em `employees`).
- Nem todo Employee tem Professor; todo Professor aponta para exatamente um Employee.

---

#### FR-5: Criar Professor sobre Employee existente

Funcionário cria Professor somente se o `employeeId` já existir **e** o Employee estiver `ativo` (FR-4).

**Consequences (testable):**
- `employeeId` obrigatório, cardinalidade 1–1 (um Professor por Employee que leciona).
- Recusa criação sem Employee ou com Employee `ativo=false`.
- Professor **não** copia nome nem e-mail; leitura de cadastro resolve via Employee.
- Nem todo Employee tem Professor.

---

#### FR-6: Titulações 1–N

Funcionário registra AcademicDegree do Professor (grau, área, instituição, ano).

**Consequences (testable):**
- Zero ou mais AcademicDegree por Professor; sem terceira classe.

---

#### FR-7: Seed/import de Student

Operação de carga (não UI de cadastro) persiste Student já existente: `id`, nome, e-mail, ativo.

**Consequences (testable):**
- Não existe jornada de “novo Student” na UI do Closed CRAS.
- Funcionário não dá alta de Student.
- `id` permanece compatível com uso futuro de diploma/Censo (sem emitir XML na v1).
- Carga recusa `studentId` que não exista em `students`. Formato do artefato de carga no addendum.

---

#### FR-8: AcademicAffiliation 1–N

A carga persiste AcademicAffiliation (código do curso, período de ingresso, situação).

**Consequences (testable):**
- AcademicAffiliation não lista turmas; roster é atributo de Class.

---

#### FR-9: Vínculo Student↔turma no mesmo fluxo

`Class.studentIds` chega no seed/import. `[ASSUMPTION]` Realiza UJ-4.

**Consequences (testable):**
- Student só vê Lesson das Class em que já está referenciado.
- Não há secretaria de matrícula na UI.

---

#### FR-10: Disciplina com identificador alinhável

Coordenador mantém Course (`id`/código, nome, carga horária). `[ASSUMPTION]` um código alinhável a cadastro oficial basta na v1.

**Consequences (testable):**
- Não há Course sem identificador.
- Carga horária é da disciplina, não da Reservation.

---

#### FR-11: Plano datado antes do período

Coordenador publica plano de ensino com data de publicação *antes* do início do período da Class.

**Consequences (testable):**
- Student e Professor leem o plano publicado; não há “nota de reserva” no lugar do plano.
- Publicar depois do início do período é recusado. `[ASSUMPTION]`

---

#### FR-12: SyllabusItem 1–N

Course tem SyllabusItem com `kind` conteúdo \| bibliografia \| critério, enunciado e ordem.

**Consequences (testable):**
- Plano estruturado (não blob único) alimenta LessonTopic e a leitura do Student.

---

#### FR-13: Abrir turma

Coordenador cria Class com `courseId`, período início/fim, vagas, `roomId` (sala padrão), `professorIds`, `studentIds` e esqueleto.

**Consequences (testable):**
- `courseId` e cada `professorId` referenciam registros existentes (não copiam nome/carga).
- Professor não cria Class.
- Várias Class com o mesmo `courseId` e período são permitidas.
- Abertura recusada se o esqueleto colidir, em qualquer `data+faixa` do período, com a sala efetiva de outra Lesson ou com outro compromisso do mesmo Professor. Recurso não entra nesta recusa — só na Reservation (FR-23).

---

#### FR-14: Esqueleto 1–N

Class tem WeeklySlot (seg–sáb, `faixaId` da grade canônica).

**Consequences (testable):**
- Não se grava horário solto; só código de faixa.
- Códigos E1, E2 e O são recusados.

---

#### FR-15: Sala padrão cabe e é acessível

Atribuir sala padrão exige capacidade da Room ≥ vagas da Class e pelo menos um AccessibilityFeature.

**Consequences (testable):**
- Sem capacidade suficiente **ou** sem AccessibilityFeature, a abertura não confirma.
- Acessibilidade v1 = presença de pelo menos um AccessibilityFeature, não conformidade com código de bombeiros. `[NOTE FOR PM]`
- Não gera 18 Reservation da sala padrão.

---

#### FR-16: Gerar aulas a partir do esqueleto

Ao confirmar a Class, o sistema gera Lesson datadas para cada WeeklySlot no período.

**Consequences (testable):**
- Cada par (dia, faixa) no intervalo início/fim vira Lesson com `classId`, data, `faixaId` — só depois da abertura confirmada (FR-13, FR-15).
- Feriados não são excluídos na v1. `[ASSUMPTION]`
- Depois de geradas, data e `faixaId` da Lesson são imutáveis na v1; correção de oferta = nova Class. `[NON-GOAL for MVP]`

---

#### FR-17: Ajustar aula

Professor atribuído à Class altera LessonTopic, `flagAvaliacao` e modalidade (presencial \| remoto) das Lesson daquela Class.

**Consequences (testable):**
- Professor não cria Class nem disciplina.
- LessonTopic referencia `syllabusItemId` e/ou enunciado extra, com ordem.
- Coordenador não confirma Reservation aula a aula.

---

#### FR-31: Professor lê plano e roster

Professor atribuído à Class lê, via BFF, o plano de ensino do Course e o roster (`Class.studentIds`) daquela Class. Realiza UJ-3.

**Consequences (testable):**
- Leitura do roster não aparece na tela de Reservation (NFR-LGPD-3).
- Professor sem atribuição à Class não lê o roster dela.

---

#### FR-18: Sala efetiva derivada

Ocupação, conflito e *onde* do Student usam somente a sala efetiva.

**Consequences (testable):**
- Presencial sem ReservationLine SALA → sala efetiva = sala padrão.
- Presencial com ReservationLine SALA daquela Lesson → sala efetiva = `targetId`; a sala padrão é liberada naquela `data+faixa`.
- Lesson remota → sem Room.
- Duas Lesson não compartilham a mesma sala efetiva na mesma `data+faixa` — recusa na abertura da Class (FR-13) e na ReservationLine SALA (FR-24), não numa operação “confirmar Lesson”.
- O contexto `lessons` lê `rooms` pelo valor da sala efetiva (não o BFF inventa a Room).

---

#### FR-19: Leitura do Student

Student autenticado lê, só via BFF: o plano de ensino publicado da disciplina; as Lesson das Class em que está referenciado (sala efetiva ou remoto, LessonTopic, `flagAvaliacao`).

**Consequences (testable):**
- Nunca horário solto; sempre faixa.
- Nunca exibe a sala padrão quando a sala efetiva for outra (“local mentiroso”).
- Student não escreve alocação.

---

#### FR-20: Cadastrar Room

Funcionário mantém Room (`id`, código/nome, prédio em texto, capacidade, ativo).

**Consequences (testable):**
- Prédio é agrupador textual, não classe nem contexto.
- Capacidade é obrigatória para atribuir sala padrão ou confirmar ReservationLine SALA.

---

#### FR-21: AccessibilityFeature 1–N

Room tem AccessibilityFeature (código, descrição/presente).

**Consequences (testable):**
- Acessibilidade não é booleano na principal.
- Sem feature, FR-15 e ReservationLine SALA não confirmam.

---

#### FR-22: Cadastrar Resource

Funcionário mantém Resource (`id`, nome, tipo, ativo) e InventoryItem 1–N (identificador, descrição, estado).

**Consequences (testable):**
- Resource não é especialização de Room.
- InventoryItem não é terceira classe de outro contexto; não existe InventoryItem órfão.
- Resource inativo não confirma Reservation (FR-23).
- `estado` v1 de InventoryItem: disponível \| indisponível. `[ASSUMPTION]`

---

#### FR-23: Reservar Resource

Professor cria Reservation com ReservationLine `kind=RECURSO` para uma `data+faixa`, com `lessonId` (caminho feliz) ou ad hoc.

**Consequences (testable):**
- Confirmação recusada se o Resource já estiver tomado na mesma `data+faixa`, se o Resource estiver inativo, ou se o mesmo Professor já tiver Lesson ou Reservation na mesma `data+faixa`.
- Recusa se faltar capacidade/acessibilidade **da Room** quando a linha for SALA (FR-24), não quando for só RECURSO.

---

#### FR-30: Alterar e cancelar Reservation

Professor titular da Reservation altera linhas ou cancela a Reservation. Realiza UJ-3.

**Consequences (testable):**
- Cancelar libera a `data+faixa` do Resource e, se houver linha SALA, a sala efetiva volta à sala padrão da Class.
- As mesmas recusas de FR-23/FR-24 valem na alteração.
- Não há fila de aprovação para cancelar.

---

#### FR-24: Reservar Room só na exceção ou ad hoc

Professor cria ReservationLine `kind=SALA` somente para trocar a sala padrão daquela Lesson ou em Reservation ad hoc.

**Consequences (testable):**
- No máximo uma ReservationLine SALA por Lesson.
- Não é o caminho para “segurar” a sala padrão.
- Ad hoc: `lessonId` ausente.
- Recusa sobreposição de sala efetiva, Resource ou Professor na mesma `data+faixa` (qualquer `kind` de Reservation).
- Recusa SALA com capacidade insuficiente **ou** sem AccessibilityFeature.
- Ligada a Lesson: capacidade da Room ≥ `Class.vagas`. Ad hoc: capacidade maior que zero e pelo menos um AccessibilityFeature, sem denominador de turma.
- Funcionário não “aprova” Reservation na v1: a confirmação é a invariante de conflito. `[ASSUMPTION]`

---

#### FR-25: Contract-first por contexto

Cada contexto publica OpenAPI na língua do Glossário.

**Consequences (testable):**
- Nomes disciplina, turma, aula, reserva, faixa, Employee, sala padrão, sala efetiva aparecem nos contratos e na UI — não `pessoa`, `evento`, `slot` genérico.
- IDs canônicos estáveis (Glossário): Student, Employee, Professor, disciplina (Course), turma (Class), aula (Lesson), Room, Resource, Reservation, faixa.

---

#### FR-26: Incorporar o domínio no BFF

Cada grupo adiciona composição/rotas do próprio contexto no BFF compartilhado.

**Consequences (testable):**
- A UI não faz join de nove OpenAPIs no browser para UJ-1–UJ-4.
- Student lê Lesson e plano de ensino via BFF (FR-19). Professor lê plano e roster via BFF (FR-31). Funcionário lê ocupação via BFF (FR-29).
- Não há grupo dono exclusivo do BFF.

---

#### FR-29: Consultar ocupação por data + faixa

Funcionário lê, via BFF, a ocupação agendada de Room e Resource numa **data + faixa**, usando somente a sala efetiva. Realiza UJ-1.

**Consequences (testable):**
- O resultado não é nominativo de Student (NFR-LGPD-2).
- Mostra a sala efetiva, não a sala padrão quando houver exceção.
- Ocupação **agendada** (o que o Closed CRAS reserva nesta faixa) — não ocupação real/sensor. Evento de no-show fica fora da v1 (NFR-Q-2).

---

#### FR-27: Gateway REST de identidade em todos os grupos

Cada um dos nove grupos implementa um gateway REST de identidade para o provedor compartilhado, declarando papéis e escopos do próprio domínio.

**Consequences (testable):**
- Login institucional na v1 para as quatro personas.
- A UI autentica via gateway REST de identidade, não via adaptador direto ao IdP. `[ASSUMPTION]`
- Não há grupo dono exclusivo do OAuth.
- Provedor da disciplina e o desenho do gateway estão no addendum (Keycloak).

---

#### FR-28: Frontend cruzado

Cada grupo implementa, no `frontend` compartilhado, as telas de **um domínio que não é o seu** contexto de backend.

**Consequences (testable):**
- Uma UI web com acesso por papel, não quatro produtos.
- O grupo de `employees` não implementa as telas de Employee/Dependent; implementa as de outro domínio. O mesmo vale, cruzado, para os outros oito. `[ASSUMPTION]` o emparelhamento grupo↔telas é decisão de turma (OQ-1).
- Contratos e telas usam a língua travada.
- Operador não escolhe microsserviço; escolhe a jornada do papel.

**Feature-specific NFRs:**
- O frontend cruzado **força** consumo do contrato alheio: quem desenha a tela de Class consome `courseId` / `employeeId` via Professor, não inventa `pessoa`.

---

### Non-Functional Requirements

Total NFR bullets: 11 (+ 1 feature-specific under FR-28)

- **NFR-ID-1 / NFR-ID-2:** Um dono por tipo de pessoa (Employee, Professor is-a, Student); consumidores guardam IDs — sem `Pessoa` genérica e sem cópia cruzada de CPF/e-mail (FR-3, FR-5).
- **NFR-LGPD-1:** LGPD vale para cadastro administrativo, roster e avaliação. A exceção “fins exclusivamente acadêmicos” (art. 4º) é estreita; não é isenção do Closed CRAS.
- **NFR-LGPD-2:** Lesson + Student nomeado é dado de localização: o BFF só mostra ao próprio Student (e papéis autorizados daquela Class). Agregados de ocupação não são nominativos.
- **NFR-LGPD-3:** Reservation sozinha (Professor + Room/Resource) não é roster; combinada com `Class.studentIds` torna-se dado pessoal de encontro — o BFF não vaza roster em tela de reserva.
- **NFR-LGPD-4:** Student e Employee são titulares distintos. Direito de eliminação cede onde a lei de acervo exigir retenção — a v1 não implementa acervo, mas não apaga `id` canônico para “limpar tela”.
- **NFR-CTR-1:** `classes` consome Course, Professor, Room, Student IDs. `lessons` consome Class e lê Room pela sala efetiva. `reservations` consome Lesson (se houver), Room, Resource, Professor.
- **NFR-CTR-2:** Mapa de escrita: funcionário escreve Employee, Room, Resource e cria Professor; coordenador escreve Course e Class (que gera Lesson); Professor escreve ajuste de Lesson e Reservation (inclui cancelar); Student só lê via BFF.
- **NFR-CTR-3:** Quebra de contrato (renomear ID, copiar cadastro, terceira classe no domínio) é defeito de produto, não “detalhe de implementação”.
- **NFR-CTR-4:** Faixas que só se tocam no extremo não conflitam (`[início, fim)`). Depois de E, a próxima é F.
- **NFR-Q-1:** Formato: APIs contract-first + BFF + UI web. Não app nativo, não hardware.
- **NFR-Q-2:** Sem sensores no caminho crítico. A v1 expõe ocupação **agendada** (FR-29). Ocupação real (sala vazia, no-show) é outra coisa: o evento pode existir no modelo depois; não na v1.
- - Frontend cruzado força consumo do contrato alheio (feature-specific NFR sob FR-28).

### Additional Requirements

- **Constraints §4:** nine groups; one principal + one 1–N secondary; success = pair + BFF routes + identity gateway + cross-domain frontend; Keycloak via REST gateway; canonical faixa A–E,F–N,P.
- **Non-goals §7:** no Student registration UI in PRD body; no Keycloak auto-provision on Employee create; no physical delete; no native app/IoT; no regenerate Lesson skeleton edits in MVP.
- **Addendum:** OpenAPI contract-first; git submodules layout; Keycloak; BFF composition; faixa timetable; 1–N attribute tables; Telas v1 matrix (OQ-1 pairing).
- **Tension recorded later in epics:** SPEC CAP-3 / UX-STUDENTS override allows Student UI create vs PRD FR-7 seed-only / §7 “Tela de cadastro de Student”.
- **Success metrics SM-1…SM-5** map to FR-1a/4/5, FR-15/18/19/24, FR-26/28/29, pairs + FR-26/27/28, conflict ops FR-13/23/24/30.
- **OQ-1** open for group↔screen pairing (epics materialize matrix).

### PRD Completeness Assessment

PRD is **final** with stable FR-1…FR-31 (incl. FR-1a) and cross-cutting NFRs. Clarity is high on domain language and consequences. Known planning tensions for later IR steps: (1) FR-7/§7 vs SPEC/UX Student UI create; (2) FR-9 seed roster vs UX-CLASS-ENROLLMENTS association UI; (3) FR-16 “ao confirmar Class gera Lesson” vs BFF explicit `POST /lessons/generate`; (4) FR-26/19/31 BFF composition vs SPEC client-side composition for professor/student reads. Architecture/addendum hold mechanism detail outside FR IDs.

## Epic Coverage Validation

### Epic FR Coverage Extracted

From `epics.md` FR Coverage Map + stories: all PRD FR-1…FR-31 (incl. FR-1a) claimed; plus FR-UI-T3 and FR-UI-NAV.

### Coverage Matrix

| FR Number | PRD Requirement (short) | Epic Coverage | Status |
| --------- | ----------------------- | ------------- | ------ |
| FR-1 | Ciclo de vida Employee | Epic 1 Stories 1.1–1.4 | ✓ Covered |
| FR-1a | Employee desativado → Class RO / nova Reservation recusada | Epic 1 (sinal) + Epic 2/7/8 (recusas UI) | ✓ Covered (UI signal) |
| FR-2 | Dependent 0..* | Epic 1 Story 1.2 | ✓ Covered |
| FR-3 | IDs only / sem cópia cadastro | Epics 0–8 (cross) | ✓ Covered |
| FR-4 | Professor não nasce sem Employee | Epic 2 Story 2.2 | ✓ Covered |
| FR-5 | Criar Professor sobre Employee ativo | Epic 2 Story 2.2 | ✓ Covered |
| FR-6 | AcademicDegree 1–N | Epic 2 Story 2.3 | ✓ Covered |
| FR-7 | Seed/import Student (PRD: sem UI alta) | Epic 3 Stories 3.1–3.2 | ⚠ Covered with SPEC override (UI create) |
| FR-8 | AcademicAffiliation 1–N | Epic 3 Story 3.3 | ✓ Covered |
| FR-9 | Vínculo Student↔turma (PRD: seed) | Epic 7 Story 7.4 | ⚠ Covered with UX override (associate existing) |
| FR-10 | Course identificador | Epic 6 Stories 6.1–6.2 | ✓ Covered |
| FR-11 | Plano datado antes do período | Epic 6 Story 6.2 | ✓ Covered |
| FR-12 | SyllabusItem 1–N | Epic 6 Story 6.3 | ✓ Covered |
| FR-13 | Abrir turma + colisões | Epic 7 Story 7.2 | ✓ Covered |
| FR-14 | Esqueleto WeeklySlot | Epic 7 Story 7.2 | ✓ Covered |
| FR-15 | Sala padrão cabe e acessível | Epic 7 Story 7.2 | ✓ Covered |
| FR-16 | Gerar aulas do esqueleto | Epic 7 Story 7.5 (`/lessons/generate`) | ✓ Covered (path BFF) |
| FR-17 | Ajustar aula | Epic 7 Story 7.6 | ✓ Covered |
| FR-18 | Sala efetiva derivada | Epic 7.6 / Epic 8.3 / 8.6 | ✓ Covered |
| FR-19 | Leitura Student | Epic 8 Story 8.6 | ✓ Covered (client compose) |
| FR-20 | Cadastrar Room | Epic 4 Stories 4.1–4.2 | ✓ Covered |
| FR-21 | AccessibilityFeature 1–N | Epic 4 Story 4.3 | ✓ Covered |
| FR-22 | Resource + InventoryItem | Epic 5 Stories 5.1–5.3 | ✓ Covered |
| FR-23 | Reservar Resource | Epic 8 Story 8.2 | ✓ Covered |
| FR-24 | Reservar Room exceção/ad hoc | Epic 8 Story 8.2 | ✓ Covered |
| FR-25 | Contract-first OpenAPI | Epic 0 Story 0.5 (FE client) | ✓ Covered (FE scope) |
| FR-26 | Domínio no BFF; UI via BFF | Epic 0 Stories 0.2/0.5 | ✓ Covered (FE consume) |
| FR-27 | Gateway identidade / UI sem IdP direto | Epic 0 Stories 0.2–0.3 | ✓ Covered (FE) |
| FR-28 | Frontend cruzado OQ-1 | Epics 0–8 owners matrix | ✓ Covered |
| FR-29 | Ocupação data+faixa | Epic 8 Story 8.4 | ✓ Covered |
| FR-30 | Alterar/cancelar Reservation | Epic 8 Story 8.3 | ✓ Covered |
| FR-31 | Professor lê plano+roster | Epic 8 Story 8.5 | ✓ Covered (client compose) |
| FR-UI-T3 | T3 classes[]/reservations[] | Epics 2–6 | ✓ Epics-only (UX/SPEC) |
| FR-UI-NAV | Menu + nested Lessons/Reservations | Epics 0,7,8 | ✓ Epics-only (UX/SPEC) |

### Missing Requirements

### Critical Missing FRs

None — every PRD FR ID appears in epics with at least one story path.

### High Priority / documented tensions (not missing IDs)

1. **FR-7:** PRD = seed/import only, §7 forbids Student registration UI; epics/SPEC = UX-STUDENTS create. **Recommendation:** keep override explicit in story ACs and readiness risk register; PM accept SPEC/CAP-3 as source of truth for FE.
2. **FR-9:** PRD = roster via seed; epics = UX-CLASS-ENROLLMENTS associate existing. **Recommendation:** treat association UI as intentional CAP override; ensure seed still valid path.
3. **FR-16:** PRD implies generate on Class confirm; epics use explicit `POST /api/v1/lessons/generate`. **Recommendation:** SPEC/BFF path wins (already in stories).
4. **FR-19 / FR-31 / FR-26:** PRD wording “via BFF”; epics = client composition over BFF proxies. **Recommendation:** SPEC CAP-10 supersede already noted in epics — acceptable if IR accepts.

### Coverage Statistics

- Total PRD FRs (incl. FR-1a): 32
- FRs covered in epics: 32 (30 clean + 2 with documented override)
- FRs missing: 0
- Coverage percentage (ID presence): 100.0%
- Extra epics-only FRs: FR-UI-T3, FR-UI-NAV

## UX Alignment Assessment

### UX Document Status

**Found** — selected generation `ux-designs/ux-constrsw-2026-2-2026-11-23/` (`EXPERIENCE.md` + `DESIGN.md`). Legacy `2026-08-24` exists but is **not** used for this assessment.

### UX ↔ PRD Alignment

| Area | Result |
| ---- | ------ |
| UJ-1…UJ-4 personas/jobs | Aligned (Helena/Rafael/Marina/Caio flows present as Key Flows / IA) |
| Surfaces for FR-1…FR-31 UI needs | Aligned via UX-* inventory (Employees…Student-read + Occupancy) |
| FR-28 cross-frontend | Aligned (OQ-1 open; matrix deferred to epics) |
| FR-7 Student create | **Tension:** PRD seed-only / §7 forbids registration UI; EXPERIENCE UX-STUDENTS = Novo aluno (OQ-PRD-1) |
| FR-9 roster | **Tension:** PRD seed; EXPERIENCE UX-CLASS-ENROLLMENTS associates existing |
| FR-19/31 “via BFF” | **Tension softened:** EXPERIENCE = client composition over BFF proxies (matches SPEC CAP-10; differs from PRD “via BFF” read-model wording) |
| Responsive / a11y | UX adds NFR-RESP DoD beyond PRD §6 (acceptable product hardening) |

### UX ↔ Architecture Alignment

| Area | Result |
| ---- | ------ |
| AD-8 Angular + Material SPA | **Aligned** with EXPERIENCE/DESIGN (Angular 22.x + M3) |
| AD-1/AD-6 browser only BFF | **Aligned** |
| AD-4 no keycloak-js | **Aligned** (oauth login + Bearer) |
| Tokens DESIGN vs AD-8 examples | **Drift:** AD-8 cites primary `#1E3A5F` / accent `#C45C26` / IBM Plex; DESIGN 2026-11-23 uses `#0066B3` / `#6DCDF6` / PUCRS tokens — **DESIGN wins** (also stated in EXPERIENCE authority) |
| AD-9 `POST /v1/lessons/gerar` | **Superseded for FE:** EXPERIENCE/epics use `POST /api/v1/lessons/generate` (BFF path) |
| AD-6 BFF dedicated FR-19/31 modules | **Superseded by SPEC/EXPERIENCE:** client composition; no dedicated BFF read-model |
| UX-S1…S9 naming | Architecture still uses legacy UX-S*; EXPERIENCE uses UX-EMPLOYEES… — epics map correctly; rename debt in architecture docs |
| Responsive gate CAP-12 | Architecture AD-8 does not spell 360/768/1280 DoD; UX/epics do — architecture should ratify or defer to UX |

### Alignment Issues

1. PRD FR-7/§7 vs UX Student registration (documented OQ-PRD-1).
2. Architecture spine stale paths (`/gerar`) and BFF read-model ownership vs live SPEC/UX.
3. Token color examples in AD-8 stale vs DESIGN.md.
4. Dual UX folders (Aug vs Nov) — risk of agents picking legacy.

### Warnings

- Treat **SPEC + UX 2026-11-23 + epics** as FE source of truth where they explicitly supersede Architecture spine wording.
- Architecture should be updated (or OV noted) before backend groups rely on `/gerar` or dedicated FR-19/31 BFF modules for UI contracts.
- Responsive DoD is mandatory in UX/epics; ensure Architecture/CI acknowledge it to avoid desktop-only merges.

## Epic Quality Review

### User value & independence

| Epic | User value? | Independence notes |
| ---- | ----------- | ------------------ |
| 0 Scaffold/Auth/Shell | Borderline technical foundation, but delivers login + navigation (user outcome) | Stands alone; enables 1–8 |
| 1 Employees | Yes | Needs Epic 0 only |
| 2 Professors | Yes | Needs 0; desirably 1 for live Employee data (stubs OK) |
| 3 Students | Yes | Needs 0 |
| 4 Rooms | Yes | Needs 0 |
| 5 Resources | Yes | Needs 0 |
| 6 Courses | Yes | Needs 0 |
| 7 Classes/Lessons | Yes | Needs 0; master data from 2–6 desirable not hard-wired in stories |
| 8 Reservations/Occupancy/Reads | Yes | Needs 0; Lesson detail from 7 (stub route documented in 8.1) |

No epic requires a *future* epic to deliver its primary UX. Epic 0 is numbered 0 (not 1) by design for Arruda ownership — starter is Story **0.1** (Angular scaffold), which satisfies the architecture “starter first” intent under this numbering.

### Story quality

- **41 stories** all use Given/When/Then.
- **No forward within-epic dependencies** detected (list → create → detail/secondary → refusals/nested).
- **No big-bang DB creation** (FE-only; BFF entities).
- **Responsive:** 39/41 stories cite 360/768/1280 explicitly; Story **0.2** (oauth session) and **1.3** cite UX-DR17 / rules without the three viewport numbers — minor gap.

### Best practices checklist (aggregate)

- [x] Epics deliver user value (Epic 0 is foundation + login/home — accept with note)
- [x] Epic independence (no N→N+1 hard require)
- [x] Stories sized for single-agent completion
- [x] No forward story deps
- [x] Entities via BFF when needed
- [x] Clear ACs (GWT)
- [x] FR traceability map present
- [ ] Uniform explicit 360/768/1280 on every story (2 minor misses)

### Quality findings by severity

#### Critical Violations

None for FE story structure.

#### Major Issues

1. **Scope tension accepted in stories:** FR-7 / FR-9 overrides vs PRD — quality OK only if PM treats SPEC/UX as authority; otherwise stories implement the “wrong” PRD.
2. **Epic 8.1 allows Lesson stub** if Epic 7 incomplete — risk of orphaned reservation UI without generate path; mitigate by sequencing Sprint Planning (7 before 8).

#### Minor Concerns

1. Story 0.2 / 1.3 should add explicit `360 / 768 / 1280` lines for DoD uniformity.
2. Duplicate heading `### FR Coverage Map` in epics.md (cosmetic).
3. Epic 0 title reads technical (“Scaffold…”) — user value is authentication + shell; consider renaming in a polish pass.
4. Architecture starter rule expected “Epic 1 Story 1”; here **Epic 0 Story 0.1** — document as intentional.

### Recommendations (quality)

1. Patch Stories 0.2 and 1.3 ACs with explicit viewport trio.
2. In sprint plan, gate Epic 8 on Epic 7 Lesson navigation (or keep stub but track as tech debt).
3. PM decision log for OQ-PRD-1 / FR-7 before Grupo 03 starts Story 3.2.


## Summary and Recommendations

### Overall Readiness Status

**NEEDS WORK** for full-stack document convergence; **READY (conditional)** to start frontend implementation of Epics 0–8 if SPEC + UX 2026-11-23 overrides are accepted as authority over stale PRD/Architecture wording.

### Critical Issues Requiring Immediate Action

1. **Authority conflict FR-7 / OQ-PRD-1:** PRD forbids Student registration UI; UX/epics require it — get explicit PM accept/reject before Grupo 03 implements Story 3.2.
2. **Architecture spine stale for FE contracts:** `/v1/lessons/gerar`, dedicated BFF FR-19/31 modules, AD-8 token examples — must not be used as FE source of truth without OV/update.
3. **Dual UX folders:** quarantine or clearly deprecate `ux-...-2026-08-24` to prevent agent/human drift.

### Recommended Next Steps

1. Record PM decision on Student UI create (accept SPEC override or revert Epic 3 stories).
2. Add Architecture OV or patch for BFF paths (`/api/v1/lessons/generate`, client composition FR-19/31) and DESIGN tokens.
3. Minor epics.md polish: viewport ACs on 0.2/1.3; remove duplicate FR Coverage Map heading.
4. Run **Sprint Planning** (`bmad-sprint-planning`) for FE Epic 0 first, then groups 1–8 in dependency order.
5. Optionally open/refresh PR containing `epics.md` + this readiness report.

### Issues tally

| Category | Count |
| -------- | ----- |
| Critical (block full-stack truth) | 3 |
| Major (process/sequencing) | 2 (quality) + coverage tensions noted in Step 3 |
| Minor | 4 |
| FR ID coverage gaps | 0 |

### Final Note

This assessment identified **documented authority conflicts and architecture drift**, not missing FR IDs in epics. Frontend epics/stories are structurally sound for implementation **once** the Student-UI override and BFF path authority are confirmed. Assessor: Cloud Agent IR workflow · Date: 2026-11-24 · User: EduardoArruda.
