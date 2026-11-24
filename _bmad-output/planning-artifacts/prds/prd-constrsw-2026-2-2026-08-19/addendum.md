# Addendum — PRD Closed CRAS

Profundidade que não cabe no corpo do PRD: mecanismo, grade, pares/atributos v1, telas, alternativas, lacunas e estrada estacionada. Auditoria e overrides ficam no `.memlog.md`.

## Mecanismo e stack (não relitigar no corpo)

- **Contract-first (OpenAPI)** é formato do produto, não stack à escolha (Spring vs Express etc. é da arquitetura).
- Layout de repositório herdado: **submódulos** Git `backend/{oauth,classes,lessons,reservations,students,courses,resources,professors,rooms,employees,bff}` + `frontend` (um repositório por contexto, não pastas de um monorepo).
- **Keycloak** é o provedor de identidade da disciplina. Cada um dos nove grupos implementa um **REST API gateway** para o Keycloak no próprio serviço (papéis/escopos do domínio). A UI não usa adaptador JS direto ao Keycloak — fala com o gateway. `[ASSUMPTION]` alinhada a FR-27.
- Módulo `oauth` compartilhado: Keycloak + contratos de papéis/escopos. Sem grupo dono exclusivo; todos plugam.
- Direção de protocolo: OIDC (pesquisa RNP/BAITA). Detalhe OIDC vs SAML/CAFe de produção é da arquitetura, não deste PRD. Federação CAFe/BAITA está fora da v1.
- BFF: composição/rotas para a UI não explodir join nem contaminar contextos. Cada grupo incorpora o **próprio** domínio no BFF e a UX do **próprio** serviço no frontend — ver **Telas v1**.
- Sem hardware, sem sensores no caminho crítico, sem app nativo.

## Grade de faixas (cânone)

Aulas de segunda a sábado, somente estes códigos. Sem E1, E2, O.

| Código | Horário |
|---|---|
| A | 08:00–08:45 |
| B | 08:45–09:30 |
| C | 09:45–10:30 |
| D | 10:30–11:15 |
| E | 11:30–12:15 |
| F | 14:00–14:45 |
| G | 14:45–15:30 |
| H | 15:45–16:30 |
| I | 16:30–17:15 |
| J | 17:30–18:15 |
| K | 18:15–19:00 |
| L | 19:15–20:00 |
| M | 20:00–20:45 |
| N | 21:00–21:45 |
| P | 21:45–22:30 |

Cada faixa é `[início, fim)`. Extremos que se tocam não conflitam. Depois de E vem F (almoço).

## Pares 1–N e atributos v1 (herdados)

| Contexto | Principal | Secundária (1–N) | Atributos da secundária (v1) |
|---|---|---|---|
| `employees` | Employee | Dependent | `name`, `birthDate`, `dependencyType`, `status` (spec-employees, 2026-11-16) |
| `professors` | Professor | AcademicDegree | grau, área, instituição, ano. Principal: is-a Employee (`employeeId` 1–1) |
| `students` | Student | AcademicAffiliation | código do curso, período de ingresso, situação (não é roster) |
| `courses` | Course | SyllabusItem | `kind` (conteúdo \| bibliografia \| critério), enunciado, ordem |
| `rooms` | Room | AccessibilityFeature | código (rampa, elevador, …), descrição/presente |
| `resources` | Resource | InventoryItem | identificador, descrição, estado |
| `classes` | Class | WeeklySlot | dia da semana (seg–sáb), `faixaId` |
| `lessons` | Lesson | LessonTopic | `syllabusItemId` e/ou enunciado extra, ordem |
| `reservations` | Reservation | ReservationLine | `kind` (SALA \| RECURSO), `targetId` |

Principais — atributos v1:

| Principal | Atributos |
|---|---|
| Employee | `id`, `registrationNumber`, `name`, `salary`, `hireDate`, `position`, `status`; `phone` e `email` opcionais; GET publica `ativo` derivado de `status` |
| Professor | `employeeId` (obrigatório, 1–1); **não** copia nome/e-mail |
| Student | `id` (já existente), nome, e-mail, ativo; origem seed/import |
| Course | `id`/código, nome, carga horária, data de publicação do plano |
| Room | `id`, código/nome, prédio (texto), capacidade, ativo |
| Resource | `id`, nome, tipo (kit, projetor, …), ativo |
| Class | `id`, `courseId`, período início/fim, vagas, `roomId` (sala padrão), `professorIds`, `studentIds` |
| Lesson | `id`, `classId`, data, `faixaId`, modalidade (presencial \| remoto), `flagAvaliacao` |
| Reservation | `id`, `professorId`, data, `faixaId`, `lessonId` (ausente se ad hoc) |

Sala efetiva = linha SALA da Reservation da aula, senão `Class.roomId`; aula remota sem sala.

Carga de Student: `[ASSUMPTION]` artefato JSON (não CSV) no seed/import; idempotente por `id`. Recusa roster cujo `studentId` não exista (FR-7).

## Telas v1 (UX do próprio serviço)

Cada grupo pluga o **próprio** domínio no BFF e a UX do **próprio** serviço no frontend. Shell (UX-LOGIN, UX-HOME) e UX-EMPLOYEES ficam com o **Prof. Arruda**. Quem implementa a UI de Class continua cliente do contrato via BFF (Course/Professor/Room) — não inventa `pessoa` nem ignora sala padrão vs sala efetiva. **OQ-1 fechada (2026-11-24).**

| Superfície EXPERIENCE | Dono | Persona | O que mostra / faz |
|---|---|---|---|
| UX-LOGIN, UX-HOME | Prof. Arruda | — | Shell compartilhado |
| UX-EMPLOYEES | Prof. Arruda | Funcionário | Employee + Dependent |
| UX-PROFESSORS (+ UX-PROFESSOR-VIEW) | Grupo 07 | Funcionário / Professor | Professor + AcademicDegree; plano + roster (FR-31) |
| UX-STUDENTS (+ UX-STUDENT-READ) | Grupo 04 | Funcionário / Student | Student + AcademicAffiliation; minhas aulas (FR-19) |
| UX-ROOMS | Grupo 08 | Funcionário | Room + AccessibilityFeature |
| UX-RESOURCES | Grupo 06 | Funcionário | Resource + InventoryItem |
| UX-OCCUPANCY | Grupo 03 | Funcionário | Ocupação por data + faixa (FR-29) |
| UX-COURSES | Grupo 05 | Coordenador | Course + plano de ensino |
| UX-CLASSES (+ UX-CLASS-ENROLLMENTS) | Grupo 01 | Coordenador | Abrir Class + roster |
| UX-CLASS-LESSONS | Grupo 02 | Professor | CRUD Lesson / tópicos |
| UX-LESSON-RESERVATIONS | Grupo 03 | Professor | CRUD Reservation da aula |

## Alternativas rejeitadas

| Alternativa | Por que não |
|---|---|
| Nove CRUDs com `pessoa` em cada um | Combate registros vs alocação e a LGPD |
| Frontend cruzado (telas de domínio alheio) | Revertido 2026-11-24: cada grupo implementa a UX do próprio serviço; shell + employees = Prof. Arruda |
| Um grupo dono do Keycloak; os outros só “usam login” | Rejeitado: todos implementam gateway REST |
| Adaptador JS da UI direto no Keycloak | Rejeitado: gateway REST |
| Ser o SIGAA/TOTVS da disciplina | Não é o recorte |
| Otimizador / IA / twin / IoT na v1 | Adiar; APIs prontas para evento, não o produto |
| App nativo ou totem | Formato: web |
| Tela de alta de Student | Identidade chega pronta (seed/import) |
| 18 reservas da sala padrão | Sala padrão na abertura; Reservation de Room é exceção |
| Faixas E1 e E2 | Fora do cânone; depois de E vem F |
| Terceira classe ou N–N com entidade própria | Quebra equidade dos 9 grupos |
| `Pessoa` genérica para Student e staff | Student não é Employee; Professor is-a Employee |
| Copiar nome/e-mail de Employee em Professor | Identidade fica em `employees` |
| Todo Employee é Professor | Especialização só num sentido |
| Folha, ponto ou módulo SIGRH | `salary` e `position` são atributos do Employee nesta entrega, não um módulo de folha |

Nomes: **Closed CRAS** (travado 2026-08-24). Nome de trabalho no brief: Malha. Descartados: qualquer `SIG*`, nome de suíte, “Campus AI”, marca PUCRS como produto institucional.

## Lacunas conhecidas

- Sem entrevistas com secretaria PUCRS.
- Sem rubrica oficial de nota da disciplina no repositório.
- Capacidade vs código de bombeiros é municipal; v1 = atributos obrigatórios, não motor de alvará.
- Sem SIS ao vivo.
- ~~Emparelhamento frontend (OQ-1)~~ fechada 2026-11-24 (UX do próprio serviço).
- Feriados não excluídos da geração de Lesson na v1.
- Ocupação da v1 é **agendada**; ocupação real/no-show estacionada.

## Estrada depois da v1 (estacionado)

Ordem sugerida pela pesquisa, *não* compromisso:

1. Extrato Censo em `courses` / `students` / `professors` / `classes`
2. Evento de ocupação / no-show em `reservations` (modelo do evento; sem IoT)
3. Roster OneRoster / Edu-API
4. Federação CAFe/BAITA
5. Agente de grade só com IDs estáveis e confirmação humana na escrita
