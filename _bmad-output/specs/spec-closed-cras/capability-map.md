# Capability map — CAP ↔ FR ↔ AD ↔ UX

Traceability do kernel SPEC para PRD, Architecture Spine e EXPERIENCE **2026-11-23**. IDs CAP são estáveis; não renumerar. IDs de superfície UX canônicos = companion EXPERIENCE (UX-LOGIN, UX-HOME, UX-EMPLOYEES…UX-CLASS-*).

## Matriz

| CAP | Intent (curto) | FR | AD | UX (EXPERIENCE 2026-11-23) | SM |
| --- | --- | --- | --- | --- | --- |
| CAP-1 | Employee + Dependent + FR-1a | FR-1, FR-1a, FR-2, FR-3 | AD-1, AD-2 | UX-EMPLOYEES | SM-1, SM-4 |
| CAP-2 | Professor is-a + AcademicDegree + turmas semestre | FR-4, FR-5, FR-6 | AD-1, AD-2, AD-3, AD-6 | UX-PROFESSORS (+ `classes` BFF) | SM-1, SM-4 |
| CAP-3 | Student cadastro UI + AcademicAffiliation + turmas semestre | FR-7*, FR-8, FR-9* (*override PRD) | AD-2, AD-7, AD-12, AD-6 | UX-STUDENTS CRUD (+ `classes` BFF); associação = UX-CLASS-ENROLLMENTS; FR-19 = UX-STUDENT-READ | SM-4 |
| CAP-4 | Course + SyllabusItem / plano | FR-10, FR-11, FR-12 | AD-2 | UX-COURSES | SM-4 |
| CAP-5 | Abrir Class + associar Students + gerar Lesson | FR-13, FR-14, FR-15, FR-16, FR-9* | AD-5, AD-9, OV-10 | UX-CLASSES; roster UX-CLASS-ENROLLMENTS; `POST /api/v1/lessons/generate` | SM-2, SM-5 |
| CAP-6 | Lesson CRUD na Turma + sala efetiva + leitura Student | FR-17, FR-18, FR-19 | AD-5, AD-6 | UX-CLASS-LESSONS (CRUD); FR-19 = UX-STUDENT-READ (cliente + proxy lessons) | SM-2, SM-3 |
| CAP-7 | Room + Resource mestres | FR-20, FR-21, FR-22 | AD-2 | UX-ROOMS + UX-RESOURCES | SM-4 |
| CAP-8 | Reservation CRUD na Aula + linhas + cancelar | FR-23, FR-24, FR-30 | AD-5 | UX-LESSON-RESERVATIONS | SM-5 |
| CAP-9 | OpenAPI contract-first | FR-25 | AD-2, AD-3, AD-11 | — (contrato) | SM-4 |
| CAP-10 | BFF proxy + composição + ocupação + vistas | FR-26, FR-29, FR-31 | AD-6, AD-10, OV-10 | T3 classes/reservations; UX-OCCUPANCY=`/reservations/ocupacao`; FR-31=UX-PROFESSOR-VIEW (cliente); 503 | SM-3, SM-4 |
| CAP-11 | oauth/Keycloak + resource-server | FR-27 | AD-4 | UX-LOGIN | SM-3, SM-4 |
| CAP-12 | UI única + frontend cruzado | FR-28 | AD-8 | UX-LOGIN, UX-HOME, UX-EMPLOYEES…UX-CLASSES (+ abas) | SM-3, SM-4 |

## NFRs cobertos no kernel (Constraints / Success)

| NFR | Onde no SPEC |
| --- | --- |
| NFR-ID-1, NFR-ID-2 | CAP-1, CAP-2, CAP-3; Constraints LGPD/IDs |
| NFR-LGPD-1..4 | Constraints LGPD; CAP-10 (roster/ocupação) |
| NFR-CTR-1..4 | CAP-5–8; Constraints grade/deps/OV-10; `domain-pairs.md` |
| NFR-Q-1, NFR-Q-2 | Non-goals (sensor/app nativo); CAP-10 ocupação agendada; Constraints compose + Prometheus/Grafana |

## Plataforma (Constraints → AD)

| Tema | Constraints / CAP | AD |
| --- | --- | --- |
| Poliglota linguagem + store | Constraints stack; CAP-2/9 | AD-3 |
| Angular + Material | Constraints stack; CAP-12 | AD-8 |
| Resilience | Constraints; CAP-10 success 503 | AD-10 |
| Testes | Constraints | AD-11 |
| Seed/fixtures | Constraints; CAP-3 | AD-12 |
| Observabilidade | Constraints envelope | AD-7 |

## Superfícies UX (inventário EXPERIENCE 2026-11-23)

| Superfície | CAP primário | Notas |
| --- | --- | --- |
| UX-LOGIN | CAP-11, CAP-12 | Todos |
| UX-HOME | CAP-12 | Shell + menu domínio |
| UX-EMPLOYEES | CAP-1 | Lista + detalhe + dependents |
| UX-PROFESSORS | CAP-2 | Lista + detalhe + titulações + **Turmas do semestre** (`classes` BFF) |
| UX-STUDENTS | CAP-3 | Cadastro + detalhe + afiliações + **Turmas do semestre** (`classes` BFF) |
| UX-ROOMS | CAP-7 / CAP-10 | Lista + detalhe + accessibility + **Turmas semestre** (`classes` T3) |
| UX-RESOURCES | CAP-7 / CAP-10 | Lista + detalhe + ocorrências + **reservations futuras** (T3) |
| UX-COURSES | CAP-4 / CAP-10 | Lista + detalhe + plano + **Turmas semestre** (`classes` T3) |
| UX-CLASSES | CAP-5 | Lista + detalhe (abas Alunos \| Aulas) |
| UX-CLASS-ENROLLMENTS | CAP-5 / CAP-3 | Aba Alunos matriculados — associa Students já existentes |
| UX-CLASS-LESSONS | CAP-6 | Aba Aulas — lista + CRUD de Lesson da turma |
| UX-LESSON-RESERVATIONS | CAP-8 | Detalhe da Aula — lista + CRUD de Reservation da aula |
| UX-OCCUPANCY | CAP-10 (FR-29) | `GET /api/v1/reservations/ocupacao` — recursos ocupados (data+faixa) |
| UX-PROFESSOR-VIEW | CAP-10 (FR-31) | Plano + roster — composição cliente (courses + classes) |
| UX-STUDENT-READ | CAP-6 (FR-19) | Minhas aulas — composição cliente (lessons + classes) |

Composição Figma: [Closed CRAS frontend PUCRS](https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp) (25 frames). Emparelhamento grupo↔superfície = **OQ-1**.

## Ponte legada UX-S* → EXPERIENCE (somente rastreio UJ)

| Legado (PRD / SPEC antigo) | Superfície vigente |
| --- | --- |
| UX-S1 | UX-EMPLOYEES |
| UX-S2 | UX-PROFESSORS |
| UX-S3 | UX-ROOMS + UX-RESOURCES |
| UX-S4 (ocupação FR-29) | UX-OCCUPANCY |
| UX-S5 | UX-COURSES |
| UX-S6 | UX-CLASSES (+ gerar em UX-CLASS-LESSONS) |
| UX-S7 | UX-CLASS-LESSONS + UX-LESSON-RESERVATIONS |
| UX-S8 (vista Professor FR-31) | UX-PROFESSOR-VIEW |
| UX-S9 (leitura Student FR-19) | UX-STUDENT-READ |

## Jornadas → capabilities

| UJ | Caps críticos |
| --- | --- |
| UJ-1 Helena (Employee → Professor → Room/Resource → ocupação) | CAP-1, CAP-2, CAP-7, CAP-10, CAP-11, CAP-12 |
| UJ-2 Rafael (plano → Class → Lesson sem reserva padrão) | CAP-4, CAP-5, CAP-11, CAP-12 |
| UJ-3 Marina (Lesson + Reservation Resource/Room) | CAP-6, CAP-8, CAP-10, CAP-11, CAP-12 |
| UJ-4 Caio (sala efetiva / plano / avaliação) | CAP-3, CAP-6, CAP-10, CAP-11, CAP-12 |
