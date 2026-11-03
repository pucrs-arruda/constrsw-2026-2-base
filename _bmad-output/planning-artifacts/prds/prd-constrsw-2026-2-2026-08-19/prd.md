---
title: Closed CRAS
status: final
created: 2026-08-19
updated: 2026-10-07
---

# PRD: Closed CRAS

Documento interno da ConstrSW (PUCRS, 2026/2) para os nove grupos alinharem FRs do produto inteiro — não só `employees` — e para UX, arquitetura e épicos. Vocabulário âncora no Glossário; FRs com IDs estáveis; `[ASSUMPTION]` só no que ainda não estava travado. Parte do brief e da pesquisa de 2026-08-17. Mecanismo e stack: `addendum.md` neste workspace. Não é pitch de mercado: quem implementa um contexto lê os outros oito como contrato, não como CRUD genérico.

## 1. Vision

**Closed CRAS** é a gestão acadêmica e de recursos desta ConstrSW: mesh de nove contextos, APIs contract-first, BFF e UI web. Pessoas e disciplinas já existem (o Student noutro sistema); o que quebra é juntar *quem já existe*, *a oferta do período com sala padrão nas faixas da grade* e *o que acontece nesta aula* — e as quatro personas não compartilham a língua.

Não compete com SIGAA, TOTVS ou Ellucian; senta *ao lado* do sistema de registro. Não há moat: o diferencial é execução e língua. Se der certo, não vira ERP — vira evidência de mesh contract-first: disciplina ≠ turma ≠ aula ≠ reserva ≠ faixa, Student sem local mentiroso, operador sem escolher microsserviço, zero Professor órfão de Employee.

## 2. Glossary

- **Closed CRAS** — produto: mesh de nove contextos + BFF + OAuth + UI web. Não é SIS nem ERP. (Nome de trabalho no brief: Malha.)
- **registros** — `students`, `courses`, `professors`, `employees`. Publicam identidade e documentos.
- **alocação** — `classes`, `lessons`, `rooms`, `resources`, `reservations`. Consome IDs de registros; não os copia.
- **disciplina** — Course: componente curricular com identificador, carga e plano de ensino. Não é turma, não é aula.
- **turma** — Class: oferta da disciplina num período, com Professor(es), vagas, sala padrão, esqueleto e IDs de Student. Não é a disciplina; não é reserva avulsa.
- **aula** — Lesson: encontro datado da turma (data + faixa, modalidade, `flagAvaliacao`, LessonTopic). Não é o plano de ensino inteiro.
- **reserva** — Reservation: retenção de Resource e/ou Room numa `data+faixa`, muitas vezes ligada a uma aula; também ad hoc. Não é matrícula.
- **faixa** — código da grade canônica (A–E, F–N, P). Intervalo `[início, fim)`. Nunca horário solto. Não é um décimo contexto.
- **esqueleto** — lista de WeeklySlot da turma: `(dia da semana, faixaId)`, seg–sáb.
- **sala padrão** — Room da turma na abertura (`Class.roomId`). Toda turma tem uma.
- **sala efetiva** — Room da aula, **derivada**: ReservationLine `kind=SALA` daquela aula, senão sala padrão; aula remota sem sala. Ocupação, conflito e *onde* do Student usam somente a sala efetiva.
- **Employee** — identidade da pessoa que trabalha na IES, inclusive quem leciona. Dono: `employees`.
- **EmploymentBond** — vínculo 1–N do Employee (tipo, início, fim?, unidade/setor em texto, situação: ativo \| encerrado). Não é SIGRH: sem cargo, salário ou ponto.
- **Professor** — papel docente **is-a** Employee: `employeeId` obrigatório 1–1; não copia nome/e-mail. Todo Professor é Employee; nem todo Employee é Professor.
- **AcademicDegree** — titulação 1–N do Professor (grau, área, instituição, ano).
- **Student** — aprendiz; não é Employee. Identidade **não se cadastra** no Closed CRAS; chega pronta (seed/import).
- **AcademicAffiliation** — vínculo acadêmico 1–N do Student (código do curso, período de ingresso, situação). Não é roster da turma.
- **SyllabusItem** — item 1–N do plano de ensino (`kind`: conteúdo \| bibliografia \| critério).
- **plano de ensino** — publicação datada *antes* do período, em Course + SyllabusItem. Não é nota de reserva.
- **WeeklySlot** — par 1–N da turma: dia da semana + `faixaId`.
- **LessonTopic** — tópico 1–N da aula (`syllabusItemId` e/ou enunciado extra, ordem).
- **Room** — espaço reservável (código/nome, prédio em texto, capacidade, ativo). Não é o prédio.
- **AccessibilityFeature** — feature 1–N da Room (código, descrição/presente). Acessibilidade não é booleano na principal.
- **Resource** — ativo reservável (kit, projetor, …). Não é Room.
- **InventoryItem** — item 1–N do Resource (identificador, descrição, estado).
- **ReservationLine** — linha 1–N da reserva (`kind`: SALA \| RECURSO, `targetId`).
- **ad hoc** — Reservation sem `lessonId`.
- **BFF** — módulo compartilhado de composição/rotas. Sem grupo dono exclusivo.
- **OAuth** — módulo compartilhado de identidade. Sem grupo dono exclusivo.
- **frontend** — UI web única, acesso por papel; fora do par 1–N. Cada grupo implementa as telas de um domínio que **não** é o seu.
- **gateway REST de identidade** — superfície REST que cada grupo entrega para o provedor de identidade (Keycloak — ver addendum). A UI não fala com o IdP por adaptador próprio.

## 3. Target User

**Papel ≠ serviço.** A persona opera a jornada; o dono de identidade permanece no contexto.

### 3.1 Jobs To Be Done

- **Funcionário** — deixar Employee + EmploymentBond prontos *antes* do papel docente; manter Room e Resource com capacidade e acessibilidade; consultar ocupação por **data + faixa**.
- **Coordenador** — publicar o plano de ensino datado antes do período; abrir Class com professor(es), vagas, sala padrão e esqueleto; gerar Lesson.
- **Professor** — ajustar a Lesson da Class a que está atribuído; ler plano de ensino e roster; reservar Resource no caminho feliz; reservar Room só para trocar a sala padrão (ou ad hoc); alterar/cancelar a Reservation.
- **Student** — só leitura: *onde / o quê / tem avaliação?* Onde = sala efetiva (nunca a sala padrão quando a efetiva for outra).

### 3.2 Non-Users (v1)

Folha/SIGRH, secretaria de matrícula no Closed CRAS, protocolo e-MEC, operador de LMS, app nativo, SIS ao vivo, agente de booking, sensor de ocupação.

### 3.3 Key User Journeys

- **UJ-1. Helena cadastra quem trabalha — e só então o papel docente existe.**
  - **Persona + context:** Helena, funcionária, steward de master data; um docente novo precisa existir como Employee antes de lecionar.
  - **Entry state:** autenticada na UI web no papel funcionário.
  - Cria Employee e EmploymentBond; só então Professor + AcademicDegree; cadastra Room e Resource; consulta ocupação por data + faixa. O `id` de Employee é o que alocação e o papel docente consomem.
  - **Edge case:** criar Professor sem Employee existente é recusado.

- **UJ-2. Rafael abre a oferta do período com sala padrão, não com 18 reservas.**
  - **Persona + context:** Rafael, coordenador; o plano de ensino já está publicado e datado *antes* do período.
  - **Entry state:** autenticado; Course e Professor existem; Room cabe nas vagas e tem AccessibilityFeature.
  - Abre Class com sala padrão e esqueleto; as Lesson nascem na grade se não houver colisão de sala efetiva nem de Professor. Marina vê Lesson, plano e roster; Caio verá a sala efetiva.
  - **Edge case:** capacidade menor que as vagas, sem AccessibilityFeature, ou esqueleto em colisão na mesma `data+faixa` — a abertura não confirma.

- **UJ-3. Marina reserva o projetor — e só troca a sala quando a padrão não serve.**
  - **Persona + context:** Marina, no papel Professor, atribuída à Class; a aula de quinta, faixa H, precisa de kit e de outra Room.
  - **Entry state:** autenticada; Lesson já existe (gerada do esqueleto).
  - Lê plano e roster; ajusta a Lesson; reserva Resource; reserva Room só na exceção (ou ad hoc). Cancelar devolve a `data+faixa`; Caio lê a sala efetiva.
  - **Edge case:** segunda ReservationLine SALA na mesma Lesson, ou sobreposição de sala efetiva, Resource ou Professor — não confirma.

- **UJ-4. Caio vê a sala efetiva — não um local mentiroso.**
  - **Persona + context:** Caio, Student; o vínculo com a Class já veio no seed/import.
  - **Entry state:** autenticado, só leitura.
  - Lê o plano publicado e as Lesson: *onde / o quê / tem avaliação?* Onde = sala efetiva; nunca horário solto; se Marina trocou a sala, Caio não vê a padrão.
  - **Edge case:** Lesson remota não mostra Room.

## 4. Constraints (ConstrSW)

- Nove grupos; cada domínio = **uma classe principal + uma secundária 1–N**. IDs de outros contextos são atributos, não terceira classe.
- Sucesso de grupo = par 1–N **e** rotas do domínio no BFF **e** gateway REST de identidade **e** telas de **outro** domínio no frontend.
- Não é sucesso: um grupo com modelo mais rico que os outros; backend órfão do BFF; grupo dono exclusivo de BFF ou OAuth.
- Provedor de identidade da disciplina: Keycloak, via gateway REST em todos os grupos (mecanismo no addendum).
- Grade canônica A–E, F–N, P; aulas seg–sáb; sem E1, E2, O. Tabela horária no addendum.

## 5. Features

### 5.1 Identidade de quem trabalha (Employee 1–N EmploymentBond)

`employees` é o **system of record** da pessoa institucional que trabalha na IES. Publica identidade consumível por `id` estável; não é dono de Room, Resource nem da classe Professor; não é SIGRH (folha, cargo, salário, ponto). Realiza UJ-1. Fora: §7.

**Papel IdP × escrita neste contexto.** Só a persona Funcionário — papel **Administrator** no Keycloak, autorizado via gateway REST de identidade (FR-27) — cria, edita, desativa e reativa Employee e EmploymentBond. Coordenador, Professor e Student **não** escrevem em `employees`. Autenticação no IdP ≠ cadastro Employee: o subject Keycloak autoriza a sessão; o `employeeId` vive só neste contexto e é a chave que `professors` e a alocação consomem.

**Junção sessão ↔ Employee (v1).** Quando o operador autenticado é um Employee, a sessão resolve para no máximo um `employeeId` via claim/atributo estável do realm (mecanismo no addendum). `employees` não armazena senha nem replica roles do IdP. Criar Employee **não** provisiona automaticamente usuário no Keycloak na v1 — provisionamento IdP é seed/admin do realm (fora do CRUD de cadastro-mestre).

#### FR-1: Ciclo de vida do Employee

Funcionário cria, edita, desativa e reativa Employee com `id` estável, nome, e-mail institucional e flag `ativo`.

**Atores / pré-condições:**
- Ator: Funcionário autenticado (papel Administrator no gateway).
- Criação: nome e e-mail institucionais obrigatórios e não vazios; `id` gerado ou atribuído na create e **imutável** depois.
- Edição de cadastro: Employee existente; altera nome e/ou e-mail (respeitando unicidade); não altera `id`.
- Desativação / reativação: Employee existente; altera somente `ativo`.

**Consequences (testable):**
- Employee (ativo ou não) permanece endereçável por `id` estável; consumidores nunca “perdem” a chave.
- E-mail institucional é único entre **todos** os Employee (ativos e desativados).
- Desativar não apaga EmploymentBond, não apaga o `id` e não remove o registro (soft-deactivate). Reativar restaura `ativo=true` sem novo `id`.
- Delete físico de Employee está fora da v1 (NFR-LGPD-4; §7).
- Employee com `ativo=false` **não** satisfaz a pré-condição de **criar** Professor (FR-4 / FR-5).
- Sinal publicado aos consumidores: `ativo`. Efeito em Class / Reservation já existentes: FR-1a.

**Edge cases / recusas:**
- Create ou update com nome ou e-mail vazios → recusa.
- Create ou update cujo e-mail já exista em outro Employee → recusa.
- Operação de escrita por papel que não seja Administrator → recusa no gateway / BFF.

#### FR-1a: Employee desativado e alocação já existente

Fecha OQ-2. Quando `employees` publica `ativo=false` para um Employee que já é referenciado via Professor:

- Class já atribuídas a esse Professor ficam **somente leitura** para mutações de oferta que dependem do docente.
- Novas Reservation cujo `professorId` resolve para esse Employee são **recusadas**.
- A v1 **não** exige substituição de Professor nem apaga Class / Lesson / Reservation históricas.

A enforcement dessas consequências cabe aos contextos consumidores (`professors`, `classes`, `reservations`); `employees` só publica o sinal `ativo` e o contrato (FR-3).

#### FR-2: Vínculos 1–N (EmploymentBond)

Funcionário adiciona, altera e encerra EmploymentBond de um Employee existente.

**Atores / pré-condições:**
- Ator: Funcionário (Administrator).
- Employee-alvo deve existir (ativo ou não — vínculos históricos permanecem legíveis).
- Não existe EmploymentBond sem `employeeId` válido.

**Consequences (testable):**
- Um Employee tem zero ou mais EmploymentBond; não existe EmploymentBond órfão.
- Atributos v1: tipo de vínculo, início, fim (opcional), unidade/setor (texto), situação (`ativo` \| `encerrado`).
- Tipos v1: efetivo, temporário, bolsista. `[ASSUMPTION]`
- Encerrar vínculo: situação → `encerrado` e `fim` preenchido (ou igual à data de encerramento); não apaga o registro do vínculo.
- Não há cargo, salário, carga de ponto nem tabela SIGRH neste contexto.
- Unidade/setor não é terceira classe nem contexto `rooms`.

**Edge cases / recusas:**
- Bond com `fim` anterior a `início` → recusa.
- Bond órfão (Employee inexistente) → recusa.
- Múltiplos vínculos ativos no mesmo Employee → permitido na v1 (não há regra de exclusividade).

#### FR-3: Publicar identidade, não copiar cadastro

Alocação e o papel docente consomem o `id` de Employee; nenhum contexto replica nome, e-mail ou documento pessoal do Employee como cópia de cadastro.

**Consequences (testable):**
- Contrato publicado por `employees` inclui no mínimo: `id`, nome, e-mail, `ativo` — e, sob o agregado, EmploymentBond quando a leitura for do próprio contexto / BFF autorizado.
- Consumidores (`professors`, `classes`, BFF) guardam o `id` (e resolvem nome/e-mail/`ativo` sob demanda ou via projeção do BFF); não embutem `pessoa` própria no OpenAPI.
- Não há campo CPF (nem documento pessoal equivalente) em Employee na v1.
- Falha de produto: nove OpenAPIs com `pessoa` copiada ou cadastro de “professor” com nome/e-mail duplicados fora de `employees`.

#### FR-4: Professor não nasce sem Employee

Não se cria Professor sem Employee **existente e ativo**. Realiza UJ-1. O contexto `employees` **não** implementa a classe Professor — só publica a pré-condição.

**Consequences (testable):**
- O `id` de Employee ativo é pré-condição do papel docente (FR-5) e a chave que a alocação referencia via Professor (`employeeId`).
- Tentativa de criar Professor com `employeeId` inexistente ou com Employee `ativo=false` → recusa (enforcement em `professors`; contrato de existência/`ativo` em `employees`).
- Nem todo Employee tem Professor; todo Professor aponta para exatamente um Employee.

### 5.2 Papel docente (Professor is-a Employee)

Especialização 1–1 sobre Employee, com AcademicDegree 1–N. Realiza UJ-1, UJ-3. Fora: §7.

#### FR-5: Criar Professor sobre Employee existente

Funcionário cria Professor somente se o `employeeId` já existir **e** o Employee estiver `ativo` (FR-4).

**Consequences (testable):**
- `employeeId` obrigatório, cardinalidade 1–1 (um Professor por Employee que leciona).
- Recusa criação sem Employee ou com Employee `ativo=false`.
- Professor **não** copia nome nem e-mail; leitura de cadastro resolve via Employee.
- Nem todo Employee tem Professor.

#### FR-6: Titulações 1–N

Funcionário registra AcademicDegree do Professor (grau, área, instituição, ano).

**Consequences (testable):**
- Zero ou mais AcademicDegree por Professor; sem terceira classe.

### 5.3 Identidade de Student recebida

Identidade **recebida** (sem tela de alta). AcademicAffiliation não é roster. Realiza UJ-4. Fora: §7.

#### FR-7: Seed/import de Student

Operação de carga (não UI de cadastro) persiste Student já existente: `id`, nome, e-mail, ativo.

**Consequences (testable):**
- Não existe jornada de “novo Student” na UI do Closed CRAS.
- Funcionário não dá alta de Student.
- `id` permanece compatível com uso futuro de diploma/Censo (sem emitir XML na v1).
- Carga recusa `studentId` que não exista em `students`. Formato do artefato de carga no addendum.

#### FR-8: AcademicAffiliation 1–N

A carga persiste AcademicAffiliation (código do curso, período de ingresso, situação).

**Consequences (testable):**
- AcademicAffiliation não lista turmas; roster é atributo de Class.

#### FR-9: Vínculo Student↔turma no mesmo fluxo

`Class.studentIds` chega no seed/import. `[ASSUMPTION]` Realiza UJ-4.

**Consequences (testable):**
- Student só vê Lesson das Class em que já está referenciado.
- Não há secretaria de matrícula na UI.

### 5.4 Disciplina e plano de ensino

Course é agregado regulado, não linha de catálogo. Realiza UJ-2, UJ-4. Fora: §7.

#### FR-10: Disciplina com identificador alinhável

Coordenador mantém Course (`id`/código, nome, carga horária). `[ASSUMPTION]` um código alinhável a cadastro oficial basta na v1.

**Consequences (testable):**
- Não há Course sem identificador.
- Carga horária é da disciplina, não da Reservation.

#### FR-11: Plano datado antes do período

Coordenador publica plano de ensino com data de publicação *antes* do início do período da Class.

**Consequences (testable):**
- Student e Professor leem o plano publicado; não há “nota de reserva” no lugar do plano.
- Publicar depois do início do período é recusado. `[ASSUMPTION]`

#### FR-12: SyllabusItem 1–N

Course tem SyllabusItem com `kind` conteúdo \| bibliografia \| critério, enunciado e ordem.

**Consequences (testable):**
- Plano estruturado (não blob único) alimenta LessonTopic e a leitura do Student.

### 5.5 Oferta do período (turma)

Coordenador abre Class; Professor não cria turma órfã. Realiza UJ-2. Fora: §7.

#### FR-13: Abrir turma

Coordenador cria Class com `courseId`, período início/fim, vagas, `roomId` (sala padrão), `professorIds`, `studentIds` e esqueleto.

**Consequences (testable):**
- `courseId` e cada `professorId` referenciam registros existentes (não copiam nome/carga).
- Professor não cria Class.
- Várias Class com o mesmo `courseId` e período são permitidas.
- Abertura recusada se o esqueleto colidir, em qualquer `data+faixa` do período, com a sala efetiva de outra Lesson ou com outro compromisso do mesmo Professor. Recurso não entra nesta recusa — só na Reservation (FR-23).

#### FR-14: Esqueleto 1–N

Class tem WeeklySlot (seg–sáb, `faixaId` da grade canônica).

**Consequences (testable):**
- Não se grava horário solto; só código de faixa.
- Códigos E1, E2 e O são recusados.

#### FR-15: Sala padrão cabe e é acessível

Atribuir sala padrão exige capacidade da Room ≥ vagas da Class e pelo menos um AccessibilityFeature.

**Consequences (testable):**
- Sem capacidade suficiente **ou** sem AccessibilityFeature, a abertura não confirma.
- Acessibilidade v1 = presença de pelo menos um AccessibilityFeature, não conformidade com código de bombeiros. `[NOTE FOR PM]`
- Não gera 18 Reservation da sala padrão.

#### FR-16: Gerar aulas a partir do esqueleto

Ao confirmar a Class, o sistema gera Lesson datadas para cada WeeklySlot no período.

**Consequences (testable):**
- Cada par (dia, faixa) no intervalo início/fim vira Lesson com `classId`, data, `faixaId` — só depois da abertura confirmada (FR-13, FR-15).
- Feriados não são excluídos na v1. `[ASSUMPTION]`
- Depois de geradas, data e `faixaId` da Lesson são imutáveis na v1; correção de oferta = nova Class. `[NON-GOAL for MVP]`

### 5.6 Encontro datado (aula) e sala efetiva

Lesson nasce do esqueleto; sala efetiva é derivada. Realiza UJ-3, UJ-4. Fora: §7.

#### FR-17: Ajustar aula

Professor atribuído à Class altera LessonTopic, `flagAvaliacao` e modalidade (presencial \| remoto) das Lesson daquela Class.

**Consequences (testable):**
- Professor não cria Class nem disciplina.
- LessonTopic referencia `syllabusItemId` e/ou enunciado extra, com ordem.
- Coordenador não confirma Reservation aula a aula.

#### FR-31: Professor lê plano e roster

Professor atribuído à Class lê, via BFF, o plano de ensino do Course e o roster (`Class.studentIds`) daquela Class. Realiza UJ-3.

**Consequences (testable):**
- Leitura do roster não aparece na tela de Reservation (NFR-LGPD-3).
- Professor sem atribuição à Class não lê o roster dela.

#### FR-18: Sala efetiva derivada

Ocupação, conflito e *onde* do Student usam somente a sala efetiva.

**Consequences (testable):**
- Presencial sem ReservationLine SALA → sala efetiva = sala padrão.
- Presencial com ReservationLine SALA daquela Lesson → sala efetiva = `targetId`; a sala padrão é liberada naquela `data+faixa`.
- Lesson remota → sem Room.
- Duas Lesson não compartilham a mesma sala efetiva na mesma `data+faixa` — recusa na abertura da Class (FR-13) e na ReservationLine SALA (FR-24), não numa operação “confirmar Lesson”.
- O contexto `lessons` lê `rooms` pelo valor da sala efetiva (não o BFF inventa a Room).

#### FR-19: Leitura do Student

Student autenticado lê, só via BFF: o plano de ensino publicado da disciplina; as Lesson das Class em que está referenciado (sala efetiva ou remoto, LessonTopic, `flagAvaliacao`).

**Consequences (testable):**
- Nunca horário solto; sempre faixa.
- Nunca exibe a sala padrão quando a sala efetiva for outra (“local mentiroso”).
- Student não escreve alocação.

### 5.7 Espaço reservável (Room)

Room tem capacidade e acessibilidade; não é o prédio. Realiza UJ-1, UJ-2. Fora: §7.

#### FR-20: Cadastrar Room

Funcionário mantém Room (`id`, código/nome, prédio em texto, capacidade, ativo).

**Consequences (testable):**
- Prédio é agrupador textual, não classe nem contexto.
- Capacidade é obrigatória para atribuir sala padrão ou confirmar ReservationLine SALA.

#### FR-21: AccessibilityFeature 1–N

Room tem AccessibilityFeature (código, descrição/presente).

**Consequences (testable):**
- Acessibilidade não é booleano na principal.
- Sem feature, FR-15 e ReservationLine SALA não confirmam.

### 5.8 Recurso reservável (Resource)

Resource ≠ Room. Reserva de Resource é o caminho feliz. Realiza UJ-1, UJ-3. Fora: §7.

#### FR-22: Cadastrar Resource

Funcionário mantém Resource (`id`, nome, tipo, ativo) e InventoryItem 1–N (identificador, descrição, estado).

**Consequences (testable):**
- Resource não é especialização de Room.
- InventoryItem não é terceira classe de outro contexto; não existe InventoryItem órfão.
- Resource inativo não confirma Reservation (FR-23).
- `estado` v1 de InventoryItem: disponível \| indisponível. `[ASSUMPTION]`

### 5.9 Reserva: Resource no feliz, Room na exceção

Recurso = Reservation no caminho feliz; Room = exceção ou ad hoc. Realiza UJ-3. Fora: §7.

#### FR-23: Reservar Resource

Professor cria Reservation com ReservationLine `kind=RECURSO` para uma `data+faixa`, com `lessonId` (caminho feliz) ou ad hoc.

**Consequences (testable):**
- Confirmação recusada se o Resource já estiver tomado na mesma `data+faixa`, se o Resource estiver inativo, ou se o mesmo Professor já tiver Lesson ou Reservation na mesma `data+faixa`.
- Recusa se faltar capacidade/acessibilidade **da Room** quando a linha for SALA (FR-24), não quando for só RECURSO.

#### FR-30: Alterar e cancelar Reservation

Professor titular da Reservation altera linhas ou cancela a Reservation. Realiza UJ-3.

**Consequences (testable):**
- Cancelar libera a `data+faixa` do Resource e, se houver linha SALA, a sala efetiva volta à sala padrão da Class.
- As mesmas recusas de FR-23/FR-24 valem na alteração.
- Não há fila de aprovação para cancelar.

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

### 5.10 Superfície compartilhada: contratos, BFF, UI, identidade

Par 1–N **e** domínio no BFF e no OAuth; frontend cruzado; gateway REST de identidade em todos os grupos. Realiza UJ-1–UJ-4.

#### FR-25: Contract-first por contexto

Cada contexto publica OpenAPI na língua do Glossário.

**Consequences (testable):**
- Nomes disciplina, turma, aula, reserva, faixa, Employee, sala padrão, sala efetiva aparecem nos contratos e na UI — não `pessoa`, `evento`, `slot` genérico.
- IDs canônicos estáveis (Glossário): Student, Employee, Professor, disciplina (Course), turma (Class), aula (Lesson), Room, Resource, Reservation, faixa.

#### FR-26: Incorporar o domínio no BFF

Cada grupo adiciona composição/rotas do próprio contexto no BFF compartilhado.

**Consequences (testable):**
- A UI não faz join de nove OpenAPIs no browser para UJ-1–UJ-4.
- Student lê Lesson e plano de ensino via BFF (FR-19). Professor lê plano e roster via BFF (FR-31). Funcionário lê ocupação via BFF (FR-29).
- Não há grupo dono exclusivo do BFF.

#### FR-29: Consultar ocupação por data + faixa

Funcionário lê, via BFF, a ocupação agendada de Room e Resource numa **data + faixa**, usando somente a sala efetiva. Realiza UJ-1.

**Consequences (testable):**
- O resultado não é nominativo de Student (NFR-LGPD-2).
- Mostra a sala efetiva, não a sala padrão quando houver exceção.
- Ocupação **agendada** (o que o Closed CRAS reserva nesta faixa) — não ocupação real/sensor. Evento de no-show fica fora da v1 (NFR-Q-2).

#### FR-27: Gateway REST de identidade em todos os grupos

Cada um dos nove grupos implementa um gateway REST de identidade para o provedor compartilhado, declarando papéis e escopos do próprio domínio.

**Consequences (testable):**
- Login institucional na v1 para as quatro personas.
- A UI autentica via gateway REST de identidade, não via adaptador direto ao IdP. `[ASSUMPTION]`
- Não há grupo dono exclusivo do OAuth.
- Provedor da disciplina e o desenho do gateway estão no addendum (Keycloak).

#### FR-28: Frontend cruzado

Cada grupo implementa, no `frontend` compartilhado, as telas de **um domínio que não é o seu** contexto de backend.

**Consequences (testable):**
- Uma UI web com acesso por papel, não quatro produtos.
- O grupo de `employees` não implementa as telas de Employee/EmploymentBond; implementa as de outro domínio. O mesmo vale, cruzado, para os outros oito. `[ASSUMPTION]` o emparelhamento grupo↔telas é decisão de turma (OQ-1).
- Contratos e telas usam a língua travada.
- Operador não escolhe microsserviço; escolhe a jornada do papel.

**Feature-specific NFRs:**
- O frontend cruzado **força** consumo do contrato alheio: quem desenha a tela de Class consome `courseId` / `employeeId` via Professor, não inventa `pessoa`.

## 6. Cross-Cutting NFRs

### 6.1 Identidade e LGPD

- **NFR-ID-1 / NFR-ID-2.** Um dono por tipo de pessoa (Employee, Professor is-a, Student); consumidores guardam IDs — sem `Pessoa` genérica e sem cópia cruzada de CPF/e-mail (FR-3, FR-5).
- **NFR-LGPD-1.** LGPD vale para cadastro administrativo, roster e avaliação. A exceção “fins exclusivamente acadêmicos” (art. 4º) é estreita; não é isenção do Closed CRAS.
- **NFR-LGPD-2.** Lesson + Student nomeado é dado de localização: o BFF só mostra ao próprio Student (e papéis autorizados daquela Class). Agregados de ocupação não são nominativos.
- **NFR-LGPD-3.** Reservation sozinha (Professor + Room/Resource) não é roster; combinada com `Class.studentIds` torna-se dado pessoal de encontro — o BFF não vaza roster em tela de reserva.
- **NFR-LGPD-4.** Student e Employee são titulares distintos. Direito de eliminação cede onde a lei de acervo exigir retenção — a v1 não implementa acervo, mas não apaga `id` canônico para “limpar tela”.

### 6.2 Contratos entre contextos

- **NFR-CTR-1.** `classes` consome Course, Professor, Room, Student IDs. `lessons` consome Class e lê Room pela sala efetiva. `reservations` consome Lesson (se houver), Room, Resource, Professor.
- **NFR-CTR-2.** Mapa de escrita: funcionário escreve Employee, Room, Resource e cria Professor; coordenador escreve Course e Class (que gera Lesson); Professor escreve ajuste de Lesson e Reservation (inclui cancelar); Student só lê via BFF.
- **NFR-CTR-3.** Quebra de contrato (renomear ID, copiar cadastro, terceira classe no domínio) é defeito de produto, não “detalhe de implementação”.
- **NFR-CTR-4.** Faixas que só se tocam no extremo não conflitam (`[início, fim)`). Depois de E, a próxima é F.

### 6.3 Qualidade da demo

- **NFR-Q-1.** Formato: APIs contract-first + BFF + UI web. Não app nativo, não hardware.
- **NFR-Q-2.** Sem sensores no caminho crítico. A v1 expõe ocupação **agendada** (FR-29). Ocupação real (sala vazia, no-show) é outra coisa: o evento pode existir no modelo depois; não na v1.

## 7. Non-Goals (Explicit)

- Diploma XML, ICP-Brasil por chamada, acervo RDC-Arq, extrato Censo (IDs devem permanecer *compatíveis*).
- Otimizador de grade; editar esqueleto / regenerar Lesson / cancelar aula como encontro na v1 (correção de oferta = nova Class). `[NON-GOAL for MVP]`
- IA no hot path de reserva, digital twin, frota IoT, BMS, sensor/no-show, agente de booking.
- App nativo, totem, hardware.
- Substituir SIGAA/TOTVS/Lyceum/Ellucian; tesouraria/ERP; LMS como produto (AVA).
- Tela de cadastro de Student; histórico, notas/frequência; faixas E1 e E2; SIS de Student ao vivo.
- Folha, cargos SIGRH, ponto, alvará; Lattes/progressão/encargos; protocolo e-MEC, DCN, autorização/reconhecimento.
- Delete físico de Employee / EmploymentBond para “limpar tela”; exclusividade de um único EmploymentBond ativo por Employee.
- Provisionar automaticamente usuário Keycloak ao criar Employee (provisionamento IdP = seed/admin do realm na v1).
- Federação CAFe/BAITA de produção; planta BIM; motor de alvará de bombeiros.

## 8. MVP Scope

**In scope:** UJ-1–UJ-4, nove pares 1–N, superfície FR-25–FR-31.

**Estacionado (não compromisso):** extrato Censo → evento de ocupação → OneRoster/Edu-API → federação → agente de grade com confirmação humana. Demais recusas: §7.

## 9. Success Metrics

Critérios demonstráveis em laboratório — não há rubrica numérica da disciplina neste repositório. `[ASSUMPTION]`

**Primary**
- **SM-1:** Zero Professor sem Employee **ativo**; tentativa com `employeeId` inexistente ou Employee inativo é recusada. Valida FR-4, FR-5, FR-1a.
- **SM-2:** UJ-2 sem criar Reservation da sala padrão; Student em UJ-4 vê sala efetiva (nunca a padrão quando a efetiva for outra). Valida FR-15, FR-18, FR-19, FR-24.
- **SM-3:** As quatro personas completam UJ-1–UJ-4 na UI sem escolher microsserviço. Valida FR-26, FR-28, FR-29.
- **SM-4:** Cada grupo demonstra par 1–N + rota BFF + gateway REST de identidade + telas de domínio alheio. Valida FR-2/6/8/12/14/21/22 (pares), FR-26, FR-27, FR-28.

**Secondary**
- **SM-5:** Conflito recusado na operação certa: gerar/abrir Class (sala efetiva ou Professor, FR-13) e confirmar/alterar Reservation (sala efetiva, Resource ou Professor, FR-23/FR-24/FR-30). Valida FR-18, FR-23, FR-24.

**Counter-metrics (do not optimize)**
- **SM-C1:** Número de endpoints ou de telas por grupo — não é riqueza de modelo; a equidade é o par 1–N.
- **SM-C2:** Cobertura de RH (cargo, salário, ponto) — otimizar isso quebra o recorte de EmploymentBond.
- **SM-C3:** “Reservas criadas” como KPI — empurraria 18 retenções da sala padrão.
- **SM-C4:** Share de mercado, NPS de campus, “IA na reserva” — não são sucesso desta disciplina.

## 10. Open Questions

1. **OQ-1.** Emparelhamento: qual grupo implementa as telas de qual domínio (restrição: não o próprio). Dono: turma/docente. Bloqueia UX detalhada, não o restante deste PRD. Inventário v1 das telas está no addendum.
2. ~~**OQ-2.** Employee desativado…~~ **Fechada** → FR-1a: Class somente leitura; nova Reservation recusada; sem exigência de substituição na v1.
3. **OQ-3.** LessonTopic: `syllabusItemId` obrigatório, enunciado extra obrigatório, ou pelo menos um dos dois?

## 11. Assumptions Index

| Assunção / decisão | Onde |
|---|---|
| E-mail institucional único entre Employee (ativos e desativados) — **decisão** | FR-1 |
| Soft-deactivate: não apaga EmploymentBond nem `id`; reativar reusa `id` — **decisão** | FR-1 |
| Employee inativo bloqueia criar Professor; Class RO + recusa nova Reservation — **decisão (ex-OQ-2)** | FR-1a, FR-4 |
| Tipos de vínculo v1: efetivo, temporário, bolsista | FR-2 |
| Situação do vínculo: ativo \| encerrado — **decisão** | FR-2 |
| Sem campo CPF em Employee na v1 — **decisão** | FR-3 |
| Criar Employee não provisiona Keycloak automaticamente na v1 — **decisão** | §5.1, §7 |
| Roster Student↔Class no mesmo seed/import | FR-9 |
| Código de Course alinhável a cadastro oficial basta na v1 | FR-10 |
| Publicar plano depois do início do período é recusado | FR-11 |
| Feriados não excluídos na geração de Lesson | FR-16 |
| Sem fila de “aprovar reserva”; confirmação = invariante de conflito | FR-24 |
| UI autentica via gateway REST de identidade, não adaptador direto ao IdP | FR-27 |
| Emparelhamento frontend cruzado em OQ-1; a regra “não o próprio domínio” já vale | FR-28 |
| Sucesso = demo de laboratório das quatro personas | SM |
| Uma UI web com acesso por papel, não quatro produtos | FR-28 / brief |
| `estado` v1 de InventoryItem: disponível \| indisponível | FR-22 |
