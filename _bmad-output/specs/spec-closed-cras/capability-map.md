# Capability map — CAP ↔ FR ↔ AD ↔ UX

Traceability do kernel SPEC para PRD, Architecture Spine e EXPERIENCE. IDs CAP são estáveis; não renumerar.

## Matriz

| CAP | Intent (curto) | FR | AD | UX | SM |
| --- | --- | --- | --- | --- | --- |
| CAP-1 | Employee + EmploymentBond + FR-1a | FR-1, FR-1a, FR-2, FR-3 | AD-1, AD-2 | UX-S1 | SM-1, SM-4 |
| CAP-2 | Professor is-a + AcademicDegree | FR-4, FR-5, FR-6 | AD-1, AD-2, AD-3 | UX-S2 | SM-1, SM-4 |
| CAP-3 | Student seed + AcademicAffiliation | FR-7, FR-8, FR-9 | AD-2, AD-7, AD-12 | — (sem alta UI); consumo UX-S9 | SM-4 |
| CAP-4 | Course + SyllabusItem / plano | FR-10, FR-11, FR-12 | AD-2 | UX-S5 | SM-4 |
| CAP-5 | Abrir Class + gerar Lesson | FR-13, FR-14, FR-15, FR-16 | AD-5, AD-9, OV-10 | UX-S6 | SM-2, SM-5 |
| CAP-6 | Lesson + sala efetiva + leitura Student | FR-17, FR-18, FR-19 | AD-5, AD-6 | UX-S7 (zona Lesson), UX-S9 | SM-2, SM-3 |
| CAP-7 | Room + Resource mestres | FR-20, FR-21, FR-22 | AD-2 | UX-S3 | SM-4 |
| CAP-8 | Reservation + linhas + cancelar | FR-23, FR-24, FR-30 | AD-5 | UX-S7 (zona Reservation) | SM-5 |
| CAP-9 | OpenAPI contract-first | FR-25 | AD-2, AD-3, AD-11 | — (contrato) | SM-4 |
| CAP-10 | BFF proxy + composição + ocupação + vistas | FR-26, FR-29, FR-31 | AD-6, AD-10, OV-10 | UX-S4, UX-S8, UX-S9 | SM-3, SM-4 |
| CAP-11 | oauth/Keycloak + resource-server | FR-27 | AD-4 | UX-LOGIN | SM-3, SM-4 |
| CAP-12 | UI única + frontend cruzado | FR-28 | AD-8 | UX-LOGIN, UX-HOME, UX-S1–S9 | SM-3, SM-4 |

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

## Superfícies UX (inventário)

| Superfície | CAP primário | Papel |
| --- | --- | --- |
| UX-LOGIN | CAP-11, CAP-12 | Todos |
| UX-HOME | CAP-12 | Todos |
| UX-S1 | CAP-1 | Funcionário |
| UX-S2 | CAP-2 | Funcionário |
| UX-S3 | CAP-7 | Funcionário |
| UX-S4 | CAP-10 (FR-29) | Funcionário |
| UX-S5 | CAP-4 | Coordenador |
| UX-S6 | CAP-5 | Coordenador |
| UX-S7 | CAP-6 + CAP-8 | Professor |
| UX-S8 | CAP-10 (FR-31) | Professor |
| UX-S9 | CAP-6 (FR-19) | Student |

Emparelhamento grupo↔UX-S* permanece **OQ-1** (não resolvido neste SPEC).

## Jornadas → capabilities

| UJ | Caps críticos |
| --- | --- |
| UJ-1 Helena (Employee → Professor → Room/Resource → ocupação) | CAP-1, CAP-2, CAP-7, CAP-10, CAP-11, CAP-12 |
| UJ-2 Rafael (plano → Class → Lesson sem reserva padrão) | CAP-4, CAP-5, CAP-11, CAP-12 |
| UJ-3 Marina (Lesson + Reservation Resource/Room) | CAP-6, CAP-8, CAP-10, CAP-11, CAP-12 |
| UJ-4 Caio (sala efetiva / plano / avaliação) | CAP-3, CAP-6, CAP-10, CAP-11, CAP-12 |
