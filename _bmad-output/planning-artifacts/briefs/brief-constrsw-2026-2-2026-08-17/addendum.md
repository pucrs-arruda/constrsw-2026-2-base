---
title: "Addendum: Malha (product brief)"
status: draft
created: 2026-08-17
updated: 2026-08-19
---

# Addendum — o que não cabe no brief

Este arquivo guarda profundidade para o PRD e decisões estacionadas. Não é arquitetura. Fonte de domínio: `_bmad-output/planning-artifacts/research/domain-university-academic-and-resource-management-research-2026-08-17.md`.

## Herança da pesquisa (não relitigar)

- Split **registros** vs **alocação**.
- Língua: disciplina ≠ turma ≠ aula ≠ reserva ≠ faixa (tabela canônica na pesquisa + grade neste addendum).
- Nove contextos e quatro personas, como no brief. Papel ≠ dono de contexto.
- Estudante: identidade **não se cadastra** na Malha; chega pronta (ConstrSW: seed/import).
- Toda turma tem **sala padrão** na abertura do período. Aula tem **sala efetiva**.
- Posição: mesh + integração, padrão specialists (CollegeNET/Ad Astra ao lado do SIS), não suíte.
- Fora da v1 salvo decisão explícita: diploma XML, otimizador com IA, frota IoT, digital twin.
- Equidade ConstrSW: 9 grupos; cada domínio = 1 classe principal + 1 secundária **1–N**.
- Cada grupo incorpora o próprio domínio no **BFF** e no **OAuth** compartilhados (não há grupo BFF/OAuth).
- **Professor is-a Employee** (1–1 via `employeeId`); nem todo Employee é Professor.

## Mapa de interação (para o PRD, não para o brief)

Registros publicam; alocação consome.

- `courses` → `classes` (componente autorizado da turma)
- `professors` → `classes` (quem leciona). **Professor is-a Employee:** não existe professor sem `employeeId` válido
- `students` persiste identidade **recebida** (seed/import); **[ASSUMPTION]** o vínculo estudante↔turma chega no mesmo fluxo — não há secretaria de matrícula na UI
- `classes` → `lessons` (esqueleto gera aulas datadas no período)
- Sala **efetiva** da aula = reserva de sala daquela aula, senão sala padrão da turma; `lessons` lê `rooms` por esse valor
- `reservations` → `resources` (caminho feliz) e `rooms` (exceção à padrão ou ad hoc); `professors` solicita
- `employees` é dono da identidade da pessoa institucional; **não** é dono de sala/recurso nem da classe Professor. A **persona** funcionário opera esses cadastros
- Estudante **lê** `lessons` (via BFF), não escreve alocação

IDs canônicos a congelar no PRD (antes de tela): estudante, **employee** (pessoa que trabalha na IES), professor (= papel docente sobre um employee), disciplina, turma, aula, sala, recurso, reserva, **faixa**.

## Esquema conceitual padronizado (equidade dos 9 grupos)

Turma ConstrSW dividida em **9 grupos**, um por contexto de domínio. Critério único: o esquema conceitual de cada domínio tem **exatamente duas classes** — principal (agregado) e secundária em associação **1–N**. Exemplo canônico do grupo `employees`: **Employee** 1–N **Dependent**. IDs de outros contextos são atributos da principal, não uma terceira classe. `bff` / `frontend` / `oauth` e o catálogo de **faixas** ficam fora desse critério.

| Contexto | Principal | Secundária (1–N) | Atributos da secundária (v1) |
|---|---|---|---|
| `employees` | Employee | Dependent | `name`, `birthDate`, `dependencyType`, `status` |
| `professors` | Professor | AcademicDegree | grau, área, instituição, ano. Principal: **is-a** Employee (`employeeId` 1–1 obrigatório) |
| `students` | Student | AcademicAffiliation | código do curso, período de ingresso, situação (não é roster da turma) |
| `courses` | Course | SyllabusItem | `kind` (conteúdo \| bibliografia \| critério), enunciado, ordem |
| `rooms` | Room | AccessibilityFeature | código (rampa, elevador, …), descrição/presente |
| `resources` | Resource | InventoryItem | identificador, descrição, estado |
| `classes` | Class | WeeklySlot | dia da semana (seg–sáb), `faixaId` |
| `lessons` | Lesson | LessonTopic | `syllabusItemId` e/ou enunciado extra, ordem |
| `reservations` | Reservation | ReservationLine | `kind` (SALA \| RECURSO), `targetId` |

**Employee** (principal): `id`, `registrationNumber`, `name`, `salary`, `hireDate`, `position`, `status`; `phone` e `email` opcionais. Não é módulo de folha: sem ponto.

Principais — atributos próprios e referências (sem terceira classe):

| Principal | Atributos da v1 |
|---|---|
| Employee | `id`, nome, e-mail, ativo |
| Professor | `employeeId` (obrigatório, 1–1, identidade = Employee); **não** copia nome/e-mail |
| Student | `id` (já existente), nome, e-mail, ativo; origem seed/import |
| Course | `id`/código, nome, carga horária, data de publicação do plano |
| Room | `id`, código/nome, prédio (texto), capacidade, ativo |
| Resource | `id`, nome, tipo (kit, projetor, …), ativo |
| Class | `id`, `courseId`, período início/fim, vagas, `roomId` (sala padrão), `professorIds`, `studentIds` |
| Lesson | `id`, `classId`, data, `faixaId`, modalidade (presencial \| remoto), `flagAvaliacao` |
| Reservation | `id`, `professorId`, data, `faixaId`, `lessonId` (ausente se ad hoc) |

Sala efetiva permanece **derivada**: linha `SALA` da reserva da aula, senão `Class.roomId`; aula remota sem sala. Acessibilidade obrigatória para atribuir sala padrão = existência de `AccessibilityFeature` pertinente + capacidade preenchida.

## Grade de faixas (cânone)

Aulas de **segunda a sábado**, somente nestes códigos. Não há **E1**, **E2** nem **O**.

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

Esqueleto, aula e conflito falam `dia da semana + código de faixa`. Faixas que só se tocam no extremo **não** conflitam: cada faixa é `[início, fim)`. Depois de E, a próxima é F (intervalo de almoço).

## Invariantes de costura (v1)

1. Identidade de estudante **não se cadastra** na Malha; `students` persiste a identidade recebida (seed/import).
2. **[ASSUMPTION]** o vínculo estudante↔turma chega no mesmo fluxo; funcionário não opera matrícula.
3. Coordenador cria a oferta; várias turmas por disciplina e período são permitidas. Professor não cria turma órfã.
4. Toda turma tem **sala padrão** na abertura. Só atribui se capacidade ≥ vagas e a sala tem **AccessibilityFeature** (acessibilidade não é um booleano na principal).
5. Esqueleto = lista de `(dia, faixa)` no período (início/fim). Gerar aulas datadas para cada par. **[ASSUMPTION]** feriados não são excluídos na v1.
6. **Sala efetiva** da aula = reserva de sala daquela aula, senão sala padrão da turma. Ocupação, conflito e *onde* do estudante usam **somente** a sala efetiva. Trocar a sala de uma data **libera** a padrão naquela `data+faixa`.
7. Reserva de sala é exceção ou ad hoc. Recurso é reserva no caminho feliz quando a aula precisa de equipamento. No máximo uma reserva de sala por aula.
8. Não confirma reserva (nem sala padrão na abertura) com sobreposição de **sala efetiva**, **recurso** ou **professor** na mesma `data+faixa`.
9. Prédio é agrupador de `rooms`. A tabela de faixas é dado de calendário da solução, não um décimo contexto de negócio.
10. **BFF e OAuth são módulos compartilhados.** Cada um dos 9 grupos incorpora o seu domínio: composição/rotas no BFF; papéis e escopos no OAuth. Não existe grupo dono exclusivo desses módulos.
11. **Professor is-a Employee.** Não se cria Professor sem Employee existente. Nem todo Employee é Professor. Estudante continua tipo de pessoa distinto. `Class.professorIds` e `Reservation.professorId` referem o papel docente (employee que tem Professor).

## Invariantes de regulação (entrada do PRD)

Não forçam monolito. Forçam identidades e documentos:

- `courses` é agregado regulado (e-MEC / Decreto 9.235): a v1 não protocola no MEC; também não inventa disciplina “de mentira” sem identificador de oferta. **[ASSUMPTION]** um código/id alinhável a cadastro oficial basta na v1.
- Plano de ensino é publicação datada *antes* do período (CNE/CES) — payload `courses` → consulta do estudante.
- LGPD vale para matrícula, avaliação, RH (ANPD: exceção “fins acadêmicos” é estreita). Sem cópia cruzada de CPF; identidade de quem trabalha na IES é **Employee**; Professor is-a Employee (não duplica cadastro); estudante é outro titular.
- Sala: capacidade na principal; acessibilidade via **AccessibilityFeature**. Sala padrão e reserva de sala não confirmam sem capacidade e sem features; sala padrão também exige capacidade ≥ vagas da turma.
- Diploma XML, acervo RDC-Arq e extrato Censo **não** são v1; identificadores de `students`/`courses` devem permanecer *compatíveis* para não fechar a porta.

## Formato e restrições técnicas (não desenhar solução aqui)

Repositório base: submódulos `backend/{oauth,classes,lessons,reservations,students,courses,resources,professors,rooms,employees,bff}` + `frontend`.

- Contract-first (OpenAPI) é **formato do produto**, não stack à escolha.
- BFF existe para não explodir o join nas UIs e para não contaminar os contextos. **Cada grupo incorpora o seu domínio no BFF.**
- OAuth: login institucional na v1; **cada grupo declara/pluga os papéis e escopos do seu domínio**. Detalhe OIDC vs SAML/CAFe é do PRD/arquitetura. Pesquisa: `oauth` no lado OIDC (direção RNP/BAITA).
- Sem app nativo, sem hardware, sem sensores no caminho crítico.

## Estrada depois da v1 (estacionado)

Ordem sugerida pela pesquisa, *não* compromisso do brief:

1. Forma de extrato Censo em `courses`/`students`/`professors`/`classes`
2. Evento de ocupação / no-show em `reservations` (modelo do evento; sem comprar IoT)
3. Roster estilo OneRoster / alinhamento Edu-API
4. Federação CAFe/BAITA
5. Agente de grade só se IDs e contratos já forem estáveis (humano confirma escrita)

## Alternativas rejeitadas

| Alternativa | Por que não |
|---|---|
| Nove CRUDs independentes com `pessoa` em cada um | Combate o split registros/alocação e a LGPD |
| “Vamos ser o SIGAA/TOTVS da disciplina” | Barreira de suíte; não é o recorte nem o diferencial honesto |
| Otimizador / IA / digital twin / IoT na v1 | Pesquisa: adiar; APIs prontas para evento, não o produto |
| App nativo ou totem | Formato travado: web |
| Brief em inglês (config BMM) | Conversa, personas e língua ubíqua são pt-BR; **[ASSUMPTION]** o artefato segue a disciplina |
| Tela de alta de estudante na Malha | Cadastro chega pronto de outro sistema (v1: seed/import) |
| 18 reservas da sala padrão | Sala padrão na abertura da turma; reserva de sala é exceção |
| Faixas E1 e E2 | Fora do cânone; depois de E vem F |
| Terceira classe ou N–N com entidade própria num domínio | Quebra a equidade entre os 9 grupos |
| `Pessoa` genérica compartilhada por estudante e staff | Estudante não é Employee; Professor is-a Employee |
| Copiar nome/e-mail de Employee em Professor | Is-a: identidade e dados cadastrais ficam em `employees` |
| Todo Employee é Professor | A especialização é só num sentido |

## Nomes considerados

- **Malha** — nome de trabalho no brief (mesh de contextos + integração).
- Descartados informalmente: qualquer `SIG*`, nome de suíte, “Campus AI”, marca PUCRS como se fosse produto institucional.

## Lacunas conhecidas

- Sem entrevistas com secretaria PUCRS (limitação da pesquisa).
- Sem rubrica oficial de nota da disciplina no repositório; critérios de sucesso do brief são demonstráveis em laboratório.
- Capacidade de sala vs. código de bombeiros é municipal; v1 trata capacidade + acessibilidade como atributos obrigatórios, não como motor de alvará.
- Sem SIS ao vivo: identidade e vínculo de estudante na ConstrSW são seed/import.
- Feriados não são excluídos da geração de aulas na v1.
