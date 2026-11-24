---
stepsCompleted: ['step-01-validate-prerequisites', 'step-02-design-epics', 'step-03-create-stories', 'step-04-final-validation']
inputDocuments:
  - planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/prd.md
  - planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
  - planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md
  - planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md
  - specs/spec-closed-cras/SPEC.md
  - specs/spec-closed-cras/capability-map.md
  - specs/spec-closed-cras/domain-pairs.md
  - specs/spec-closed-cras/brownfield-2026-1.md
  - docs/open-api/bff.yaml
project_name: constrsw-2026-2
date: 2026-11-24
notes: >
  Scope deste breakdown = implementação do frontend Angular (CAP-12) com numeração
  Epic 0=Arruda, Epic 1..8=Grupos 01..08. SPEC prevalece sobre PRD (OQ-PRD-1 Student cadastro)
  e sobre Architecture onde paths/FR-19/31 divergem (/generate; composição cliente).
---

# constrsw-2026-2 - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for constrsw-2026-2, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

**Frontend focus:** SPA única Angular 22 + Material; browser só BFF; épicos 0–8 conforme partição cruzada (OQ-1); responsividade obrigatória em toda superfície.

## Requirements Inventory

### Functional Requirements

FR1: Employee tem ciclo de vida com `id` estável e `ativo`; e-mail único quando presente; sem delete físico nem provisionamento Keycloak na create (PRD FR-1; CAP-1).
FR1a: Employee `ativo=false` bloqueia criar Professor; Class atribuídas ficam RO; nova Reservation é recusada nos escritores consumidores (PRD FR-1a).
FR2: Dependent 0..* sob Employee; secundária do contexto `employees` (PRD FR-2; CAP-1; spec-employees).
FR3: Consumidores guardam IDs — sem copiar cadastro pessoal entre contextos (PRD FR-3).
FR4: Professor não nasce sem Employee (PRD FR-4).
FR5: Criar Professor só sobre Employee existente e ativo via `employeeId` 1–1; sem duplicar nome/e-mail (PRD FR-5; CAP-2).
FR6: AcademicDegree 1–N sob Professor (PRD FR-6; CAP-2).
FR7: Student tem `id` string opaco; **override SPEC:** cadastro na UI UX-STUDENTS (não só seed) (PRD FR-7 tensionado; CAP-3; OQ-PRD-1).
FR8: AcademicAffiliation 1–N sob Student (PRD FR-8; CAP-3).
FR9: Vínculo Student↔turma: associação de Students **já existentes** via `studentIds` em UX-CLASS-ENROLLMENTS; sem criar Student na tela de Turmas (PRD FR-9 override; CAP-3/5).
FR10: Course com identificador alinhável (`id` + `codigo`) (PRD FR-10; CAP-4).
FR11: Plano de ensino datado antes do período da Class (PRD FR-11; CAP-4).
FR12: SyllabusItem 1–N no Course (PRD FR-12; CAP-4).
FR13: Abrir Class com sala padrão, esqueleto, recusas de colisão (PRD FR-13; CAP-5).
FR14: WeeklySlot 1–N (esqueleto) (PRD FR-14; CAP-5).
FR15: Sala padrão cabe e é acessível (≥1 AccessibilityFeature) (PRD FR-15; CAP-5/7).
FR16: Gerar Lessons a partir do esqueleto via `POST /api/v1/lessons/generate` (BFF path vigente; não `/gerar`) sem Reservation da sala padrão (PRD FR-16; CAP-5; SPEC).
FR17: Ajustar Lesson (tópicos, flagAvaliacao, modalidade) só no contexto da Turma UX-CLASS-LESSONS (PRD FR-17; CAP-6).
FR18: `salaEfetivaId` derivada em `lessons` (AD-5); Student nunca vê sala padrão quando efetiva diverge (PRD FR-18; CAP-6).
FR19: Student lê sala efetiva / tópico / avaliação + plano — **composição cliente** sobre proxies BFF (UX-STUDENT-READ); sem read-model BFF dedicado (PRD FR-19; CAP-6/10; SPEC).
FR20: Cadastrar Room com capacidade obrigatória (PRD FR-20; CAP-7).
FR21: AccessibilityFeature 1–N sob Room (PRD FR-21; CAP-7).
FR22: Cadastrar Resource ≠ Room; InventoryItem 1–N; inativo não confirma Reservation (PRD FR-22; CAP-7).
FR23: Reservar Resource (caminho feliz) no detalhe da Aula UX-LESSON-RESERVATIONS (PRD FR-23; CAP-8).
FR24: ReservationLine SALA só na exceção ou ad hoc (PRD FR-24; CAP-8).
FR30: Alterar e cancelar Reservation no detalhe da Aula (PRD FR-30; CAP-8).
FR25: Contract-first OpenAPI 3.1 por contexto (PRD FR-25; CAP-9) — FE consome via BFF OpenAPI.
FR26: Domínio incorporado no BFF (proxy + composição); UI só fala com BFF (PRD FR-26; CAP-10).
FR29: Consultar ocupação por `data` + `faixaId` via `GET /api/v1/reservations/ocupacao` — recursos ocupados, não nominativo de Student (UX-OCCUPANCY) (PRD FR-29; CAP-10; SPEC).
FR27: Gateway REST de identidade; UI sem `keycloak-js`; login via oauth/BFF (PRD FR-27; CAP-11).
FR28: Frontend cruzado — grupo não implementa UI do próprio backend; OQ-1 (PRD FR-28; CAP-12).
FR31: Professor lê plano + roster — **composição cliente** (UX-PROFESSOR-VIEW); roster nunca em Reservation (PRD FR-31; CAP-10; SPEC).
FR-UI-T3: GETs BFF de professors/students/courses/rooms incluem `classes[]` do semestre (fuso America/Sao_Paulo; cliente **não** envia year/semester); resources incluem `reservations[]` futuras; falha T3 → 503 + banner (CAP-10).
FR-UI-NAV: Menu hambúrguer ordem fixa EXPERIENCE; Lessons e Reservations **fora** do menu de topo; Turma = abas Alunos | Aulas; Reservations só no detalhe da Aula (EXPERIENCE; CAP-5/6/8).

### NonFunctional Requirements

NFR-ID-1 / NFR-ID-2: Um dono por tipo de pessoa; consumidores guardam IDs — sem Pessoa genérica nem cópia cruzada (PRD §6.1).
NFR-LGPD-1: LGPD aplica-se a cadastro, roster e avaliação.
NFR-LGPD-2: Ocupação e leituras não são nominativas de Student indevidamente; agregados sem nome de aluno.
NFR-LGPD-3: Roster não vaza em tela de Reservation.
NFR-LGPD-4: Não apagar `id` canônico para “limpar tela”.
NFR-CTR-1: Dependências cross-context por IDs conforme domain-pairs.
NFR-CTR-2: Mapa de escrita por papel (funcionario|coordenador|professor|student).
NFR-CTR-3: Quebra de contrato (renomear ID, copiar cadastro) = defeito de produto.
NFR-Q: Sem sensor/IoT/app nativo na v1; ocupação é agendada.
NFR-STACK: Angular 22.x + Angular Material; tokens DESIGN.md prevalecem; OpenAPI 3.1; BFF Nest; Keycloak via oauth (SPEC Constraints; AD-8).
NFR-RESP: UI responsiva obrigatória compact/medium/expanded (360–1440px+; pivô nav 1024); ACs nas três classes; sem desktop-only (CAP-12; EXPERIENCE DoD).
NFR-A11Y: WCAG 2.2 AA; foco visível; banners `role="alert"`; alvos ≥24px (≥48px touch compact/medium) (EXPERIENCE).
NFR-I18N-UI: Chrome/forms/empty/banners em pt-BR; paths OpenAPI em inglês (EXPERIENCE).
NFR-OBS: Compose sobe FE; health BFF não é tela; logs/métricas nos serviços (AD-7) — FE não implementa GET /health como superfície.
NFR-TEST: E2E UJ-1…UJ-4 na UI contra compose (AD-11) — escopo posterior às stories de superfície.

### Additional Requirements

- **Starter FE (AD-8 / Stack spine):** SPA Angular em `frontend/`; Angular 22.x + Angular Material 22.x; TypeScript no range do Angular 22; porta lab **4200**; sem SSR competindo com BFF.
- Browser fala **somente** com BFF (AD-1 / OV-1); CORS só no BFF (AD-6).
- Auth UI: `POST {oauth}/login` multipart → Bearer nas requests BFF; refresh/logout; cookie httpOnly pode coexistir (EXPERIENCE / SPEC Assumptions — supersede cookie-only wording legado).
- **Path vigente BFF:** `POST /api/v1/lessons/generate` (não `/gerar` da Architecture spine legada); `GET /api/v1/reservations/ocupacao`.
- **FR-19 / FR-31:** composição **no cliente** sobre proxies (SPEC CAP-10) — supersede módulos BFF dedicados descritos na Architecture spine antiga.
- Proxy BFF sob `/api/v1/<contexto>/...`; T3 embute `classes`/`reservations` nos GETs listados; 503 `BFF-DEPENDENCY` + banner, sem join local.
- Envelope compose inclui frontend Angular (AD-7).
- Tokens DESIGN.md prevalecem sobre tema Material default; proibido CSS frágil em `.mdc-*` (AD-8; DESIGN).
- Architecture menciona superfícies UX-S1…S9 — mapear para IDs EXPERIENCE 2026-11-23 (capability-map ponte legada).
- Sem UI de `classes/.../reviews` na v1 (SPEC non-goal).
- Emparelhamento grupo↔superfície = OQ-1; matriz proposta no prompt do usuário (Epic 0–8) deve ser materializada no step de design de épicos.

### UX Design Requirements

UX-DR1: Implementar tema Angular Material com tokens DESIGN.md (primary `#0066B3`, navy, sky `#6DCDF6`, surfaces, error; v1 light-only).
UX-DR2: Mapear chrome para `mat-toolbar`, `mat-sidenav`, `mat-nav-list`, `mat-table`, `mat-form-field`, `mat-chip`, `mat-tab-group`, `mat-dialog`, `mat-snack-bar`, `mat-progress-bar` (EXPERIENCE Component Patterns).
UX-DR3: Métricas M3 travadas — app bar 64dp, nav item 56dp, ícone 24dp, botões 40dp, field 56dp; sem FAB; sem botão one-off (DESIGN).
UX-DR4: UX-LOGIN — login-panel split/faixa/compact; 401 banner sem enumerar conta; 503 “Identidade indisponível.”
UX-DR5: UX-HOME / app-shell — hambúrguer, marca Closed CRAS, caption PUCRS·ConstrSW, usuário de `/identidade/me`, Sair → logout.
UX-DR6: hamburger-nav ordem fixa 10 itens; folha modal &lt;1024px; Esc/scrim fecham; item ativo marcado.
UX-DR7: page-header + toolbar (busca + CTA) por contexto; empty pt-BR + CTA quando puder criar.
UX-DR8: data-table → lista compacta 2 linhas + “Mais ações” em compact; TableRowActions Abrir/Editar/Excluir; sem infinite scroll; sem scroll horizontal (exceto ocupação/faixas).
UX-DR9: master-detail-panel — 2 colunas ≥1280; empilhado abaixo; link voltar em compact.
UX-DR10: class-tabs — somente Alunos matriculados | Aulas; abas roláveis em compact.
UX-DR11: UX-CLASS-ENROLLMENTS — picker de Students existentes; sem criar Student.
UX-DR12: UX-CLASS-LESSONS — CRUD Lesson + generate; navegação ao detalhe da aula.
UX-DR13: UX-LESSON-RESERVATIONS — CRUD Reservation da Lesson aberta; faixa-picker canônico A–E,F–N,P.
UX-DR14: UX-OCCUPANCY — data + faixaId → lista OccupancyItem (recursos); não grade de salas.
UX-DR15: UX-PROFESSOR-VIEW e UX-STUDENT-READ — composição cliente; banners 503.
UX-DR16: refusal-banner / identity-banner / confirm-dialog / skeleton-block conforme State Patterns.
UX-DR17: Responsivo gate — toda superfície (incl. nested Lessons/Reservations) passa compact 360, medium 768, expanded 1280; DoD EXPERIENCE (touch ≥48px compact/medium; dialog fullscreen compact; preservar estado ao mudar classe; WCAG 1.4.10 reflow).
UX-DR18: Microcopy pt-BR (Voice and Tone); glossário disciplina/turma/aula/reserva/faixa.
UX-DR19: Acessibilidade — WCAG 2.2 AA; `h1` page-header; `role="alert"` em banners; AccessibilityFeature como lista nomeada.
UX-DR20: Exibir `classes[]` T3 em Professors/Students/Rooms/Courses e `reservations[]` em Resources; AcademicAffiliation ≠ classes[].

### FR Coverage Map

### FR Coverage Map

FR1: Epic 1 — UX-EMPLOYEES ciclo de vida Employee
FR1a: Epic 1 / Epic 7–8 — sinal `ativo` consumido em Professors/Reservations/Classes (UI reflete RO/recusa)
FR2: Epic 1 — Dependent 1–N em UX-EMPLOYEES
FR3: Epic 0–8 — IDs only; sem cópia de cadastro na UI
FR4: Epic 2 — pré-condição Employee ao criar Professor
FR5: Epic 2 — UX-PROFESSORS criar sobre Employee ativo
FR6: Epic 2 — AcademicDegree 1–N
FR7: Epic 3 — UX-STUDENTS cadastro UI (override SPEC)
FR8: Epic 3 — AcademicAffiliation 1–N
FR9: Epic 7 — UX-CLASS-ENROLLMENTS associa existentes
FR10: Epic 6 — UX-COURSES identificador
FR11: Epic 6 — plano datado
FR12: Epic 6 — SyllabusItem 1–N
FR13: Epic 7 — UX-CLASSES abrir turma
FR14: Epic 7 — WeeklySlot / esqueleto na UI de turma
FR15: Epic 7 — validação sala padrão (UI + recusas)
FR16: Epic 7 — generate Lessons via BFF `/lessons/generate`
FR17: Epic 7 — UX-CLASS-LESSONS CRUD
FR18: Epic 7 / Epic 8 — sala efetiva refletida; Student/Reserva
FR19: Epic 8 — UX-STUDENT-READ composição cliente
FR20: Epic 4 — UX-ROOMS cadastro
FR21: Epic 4 — AccessibilityFeature 1–N
FR22: Epic 5 — UX-RESOURCES + InventoryItem
FR23: Epic 8 — UX-LESSON-RESERVATIONS Resource
FR24: Epic 8 — linha SALA exceção
FR30: Epic 8 — alterar/cancelar Reservation
FR25: Epic 0 — cliente OpenAPI BFF
FR26: Epic 0 — HTTP só BFF
FR29: Epic 8 — UX-OCCUPANCY
FR27: Epic 0 — login oauth / identidade
FR28: Epic 0–8 — partição cruzada OQ-1 (matriz épicos)
FR31: Epic 8 — UX-PROFESSOR-VIEW composição cliente
FR-UI-T3: Epic 2–6 — exibir `classes[]`/`reservations[]` T3 + 503
FR-UI-NAV: Epic 0 + 7–8 — menu, abas Turma, nested Lessons/Reservations

## Epic List

### Epic 0: Scaffold, autenticação e app-shell (Arruda)
Usuários autenticam-se e navegam na SPA Angular responsiva com tema PUCRS; base técnica compartilhada pronta para os grupos.
**Owner:** Eduardo Arruda (`employees` backend; FE = scaffold/shell — Employees UI no Epic 1)
**FRs covered:** FR25, FR26, FR27, FR28 (parcial — base cruzada), FR-UI-NAV (shell/menu)
**Depends on:** —
**Enables:** Epics 1–8

### Epic 1: Funcionários (Grupo 01 — FE cruzado)
Funcionário mantém Employees e Dependents na UI (lista, detalhe, CRUD) via BFF, responsivo.
**Owner:** Grupo 01 (backend `classes`; FE = UX-EMPLOYEES)
**FRs covered:** FR1, FR1a (sinal na UI), FR2, FR3
**Depends on:** Epic 0
**Enables:** Epic 2 (Employee ativo como pré-condição de Professor)

### Epic 2: Professores (Grupo 02 — FE cruzado)
Funcionário cria Professors sobre Employee ativo, gerencia AcademicDegrees e vê turmas do semestre (`classes[]` T3).
**Owner:** Grupo 02 (backend `lessons`; FE = UX-PROFESSORS)
**FRs covered:** FR4, FR5, FR6, FR-UI-T3 (professors)
**Depends on:** Epic 0 (shell); Epic 1 desejável para dados Employee
**Enables:** Epic 7 (alocação docente)

### Epic 3: Alunos (Grupo 03 — FE cruzado)
Funcionário cadastra Students e AcademicAffiliations; vê turmas do semestre (`classes[]` T3).
**Owner:** Grupo 03 (backend `reservations`; FE = UX-STUDENTS)
**FRs covered:** FR7, FR8, FR-UI-T3 (students)
**Depends on:** Epic 0
**Enables:** Epic 7 (associação à turma)

### Epic 4: Salas de Aula (Grupo 04 — FE cruzado)
Funcionário mantém Rooms e AccessibilityFeatures; vê turmas do semestre na sala.
**Owner:** Grupo 04 (backend `students`; FE = UX-ROOMS)
**FRs covered:** FR20, FR21, FR-UI-T3 (rooms)
**Depends on:** Epic 0
**Enables:** Epic 7 (sala padrão)

### Epic 5: Recursos (Grupo 05 — FE cruzado)
Funcionário mantém Resources e InventoryItems; vê reservations futuras (T3).
**Owner:** Grupo 05 (backend `courses`; FE = UX-RESOURCES)
**FRs covered:** FR22, FR-UI-T3 (resources)
**Depends on:** Epic 0
**Enables:** Epic 8 (reservar recurso)

### Epic 6: Disciplinas (Grupo 06 — FE cruzado)
Coordenador mantém Courses, referências e SyllabusItems; vê turmas do semestre.
**Owner:** Grupo 06 (backend `resources`; FE = UX-COURSES)
**FRs covered:** FR10, FR11, FR12, FR-UI-T3 (courses)
**Depends on:** Epic 0
**Enables:** Epic 7 (abrir Class / plano)

### Epic 7: Turmas, matrículas e Aulas (Grupo 07 — FE cruzado)
Coordenador abre Classes, associa Students existentes, gera e faz CRUD de Lessons **dentro** da Turma (abas Alunos | Aulas).
**Owner:** Grupo 07 (backend `professors`; FE = UX-CLASSES + UX-CLASS-ENROLLMENTS + UX-CLASS-LESSONS)
**FRs covered:** FR9, FR13, FR14, FR15, FR16, FR17, FR18 (parcial), FR-UI-NAV (Turma/Lessons)
**Depends on:** Epic 0; Epics 2–6 para dados mestres
**Enables:** Epic 8 (Reservations no detalhe da Aula)

### Epic 8: Reservas na Aula, ocupação e vistas de leitura (Grupo 08 — FE cruzado)
Professor faz CRUD de Reservations **no detalhe da Aula**; Funcionário consulta ocupação; Professor/Student leem plano+roster e minhas aulas (composição cliente).
**Owner:** Grupo 08 (backend `rooms`; FE = UX-LESSON-RESERVATIONS + UX-OCCUPANCY + UX-PROFESSOR-VIEW + UX-STUDENT-READ)
**FRs covered:** FR18 (leitura), FR19, FR23, FR24, FR29, FR30, FR31, FR-UI-NAV (Reservations nested)
**Depends on:** Epic 0; Epic 7 (Lesson existente; stub de rota permitido se documentado)
**Enables:** UJ-1…UJ-4 completas na UI

## Epic 0: Scaffold, autenticação e app-shell (Arruda)

Usuários autenticam-se e navegam na SPA Angular responsiva com tema PUCRS; base técnica compartilhada pronta para os grupos.
**Owner:** Eduardo Arruda · **FRs:** FR25, FR26, FR27, FR28 (base), FR-UI-NAV · **UX-DRs:** UX-DR1–7, UX-DR16–19

### Story 0.1: Scaffold Angular 22 + Material + tema DESIGN

As a developer on the Closed CRAS frontend,
I want an Angular 22 SPA with Angular Material themed to DESIGN.md tokens in `frontend/`,
So that all groups share one runnable UI baseline on compose (port 4200).

**Acceptance Criteria:**

**Given** the empty `frontend/` submodule
**When** the scaffold is generated and built
**Then** the app starts with Angular 22.x + Angular Material + CDK + SCSS
**And** DESIGN.md tokens (primary `#0066B3`, surfaces, typography) override default Material theme without fragile `.mdc-*` selectors
**And** the project is wired for Docker Compose / local port 4200
**And** viewport layouts at 360 / 768 / 1280 render without horizontal overflow on the blank shell (NFR-RESP)

### Story 0.2: Sessão oauth Bearer para o BFF

As a lab user,
I want login/refresh/logout against `backend/oauth` with Bearer on BFF calls,
So that authenticated API access works without Keycloak in the browser.

**Acceptance Criteria:**

**Given** valid credentials
**When** the client submits `POST {oauth}/login` as `multipart/form-data` (`username`, `password`)
**Then** a `201` yields an access token used as `Authorization: Bearer` on BFF requests
**And** refresh uses `POST /refresh` and logout uses `POST /logout`
**And** `keycloak-js` is not used; IdP is never called from the browser
**And** session storage follows EXPERIENCE assumption (no long-lived `localStorage` for the Bearer)

### Story 0.3: UX-LOGIN responsivo

As a funcionario/coordenador/professor/student,
I want a Portuguese login screen with clear error states,
So that I can enter the system safely.

**Acceptance Criteria:**

**Given** a cold URL or expired session
**When** I open UX-LOGIN
**Then** the login-panel matches EXPERIENCE (split expanded / brand strip medium / full-width compact)
**When** credentials are rejected (`401`)
**Then** a refusal-banner shows without enumerating whether the account exists
**When** identity is unavailable (`503`/network)
**Then** the banner shows “Identidade indisponível.”
**And** success (`201`) navigates to UX-HOME with Bearer session
**And** ACs hold at 360, 768 and 1280 px (UX-DR4, UX-DR17)

### Story 0.4: UX-HOME app-shell e navegação

As an authenticated user,
I want the Closed CRAS shell with hamburger menu and my identity,
So that I can reach domain surfaces without choosing a microservice.

**Acceptance Criteria:**

**Given** a valid session
**When** UX-HOME loads
**Then** `GET /api/v1/identidade/me` populates the header user area
**And** the hamburger lists the fixed EXPERIENCE order (10 items); active item is marked
**And** **Sair** calls logout and returns to UX-LOGIN
**And** below 1024px the nav is a modal sheet (Esc/scrim/item close; focus returns to hamburger)
**And** at ≥1024px the drawer is fixed; caption/user name may hide only in compact per EXPERIENCE
**And** `GET /health` is not exposed as a screen
**And** layouts work at 360 / 768 / 1280 (UX-DR5–6, UX-DR17)

### Story 0.5: Kit compartilhado (tabela/lista, dialogs, banners, HTTP BFF)

As a frontend developer on any epic,
I want shared responsive UI primitives and a BFF HTTP client,
So that domain stories reuse one pattern.

**Acceptance Criteria:**

**Given** the shell from 0.4
**When** shared components are available
**Then** data-table becomes a 2-line list + “Mais ações” in compact; no table horizontal scroll
**And** edit dialogs are fullscreen with sticky footer actions in compact; confirm-dialog stacks buttons if needed
**And** refusal-banner, identity-banner (`role="alert"`), skeleton-block, and empty states follow EXPERIENCE State Patterns
**And** the HTTP client targets only the BFF OpenAPI base; 401/503 map to the correct banners
**And** T3 503 responses show “Serviço de composição indisponível.” without client-side join fallback
**And** all kit demos/docs pages (if any) pass 360 / 768 / 1280 (UX-DR8–9, UX-DR16–17; FR25–26)

## Epic 1: Funcionários (Grupo 01 — FE cruzado)

Funcionário mantém Employees e Dependents na UI (lista, detalhe, CRUD) via BFF, responsivo.
**Owner:** Grupo 01 (backend `classes`; FE = UX-EMPLOYEES) · **FRs:** FR1, FR1a, FR2, FR3 · **UX-DRs:** UX-DR7–9, UX-DR16–18

### Story 1.1: Lista de Funcionários responsiva

As a funcionario,
I want to browse Employees from the BFF in a responsive list,
So that I can find and open a person to maintain.

**Acceptance Criteria:**

**Given** I am authenticated and open Funcionários from the menu
**When** `GET /api/v1/employees` succeeds
**Then** UX-EMPLOYEES shows a data-table (expanded/medium) or 2-line list + “Mais ações” (compact)
**And** page-header and toolbar (search + primary CTA) follow EXPERIENCE
**And** empty state is pt-BR with CTA when creation is allowed
**And** T3/composition 503 (if applicable) shows the composition banner without partial local joins
**And** layouts work at 360 / 768 / 1280 without horizontal table scroll

### Story 1.2: Detalhe Employee + Dependent 1–N

As a funcionario,
I want Employee detail with Dependent secondary CRUD,
So that personal dependents stay with the employee record.

**Acceptance Criteria:**

**Given** I open an Employee row
**When** `GET /api/v1/employees/{id}` returns the aggregate
**Then** master-detail shows Employee fields and Dependent 1–N for that employee only
**And** create/edit/delete Dependent uses the BFF employee secondary routes
**And** below 1280px the panels stack; compact shows “← Voltar para {lista}”
**And** edit dialogs are fullscreen in compact with footer actions
**And** destructive actions use confirm-dialog naming the object
**And** responsive ACs hold at 360 / 768 / 1280

### Story 1.3: Criar e editar Employee (ciclo de vida)

As a funcionario,
I want to create and update Employees (including `ativo`),
So that identity for allocation stays accurate without Keycloak provisioning.

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-EMPLOYEES
**When** I submit a valid Employee payload via BFF POST/PUT/PATCH
**Then** the list/detail refresh with the stable `id`
**And** email uniqueness violations surface via refusal-banner (problem+json), form retained
**And** setting `ativo=false` is allowed; UI does not call Keycloak to provision users on create
**And** no physical delete is offered in v1
**And** forms meet compact/medium/expanded dialog rules (UX-DR17)

### Story 1.4: Estados de recusa e Employee inativo na UI

As a funcionario,
I want clear feedback when writes fail or an employee is inactive,
So that I understand FR-1a impact without stack traces.

**Acceptance Criteria:**

**Given** a BFF write returns problem+json (`code` = FR id when present)
**When** the UI handles the response
**Then** refusal-banner shows institutional pt-BR copy (`role="alert"`)
**And** inactive employees are visible but labeled so consumers (later epics) can enforce FR-1a
**And** network/BFF identity-style 503 uses identity-banner patterns where appropriate
**And** behavior is verified at 360 / 768 / 1280

## Epic 2: Professores (Grupo 02 — FE cruzado)

Funcionário cria Professors sobre Employee ativo, gerencia AcademicDegrees e vê turmas do semestre (`classes[]` T3).
**Owner:** Grupo 02 (backend `lessons`; FE = UX-PROFESSORS) · **FRs:** FR4, FR5, FR6, FR-UI-T3 · **UX-DRs:** UX-DR7–9, UX-DR16–18, UX-DR20

### Story 2.1: Lista de Professores responsiva

As a funcionario,
I want to browse Professors from the BFF in a responsive list,
So that I can find and open a professor record.

**Acceptance Criteria:**

**Given** I am authenticated and open Professores from the menu
**When** `GET /api/v1/professors` succeeds
**Then** UX-PROFESSORS shows data-table (expanded/medium) or 2-line list + “Mais ações” (compact)
**And** page-header + toolbar (search + CTA Nova) follow EXPERIENCE
**And** empty state is pt-BR with CTA when creation is allowed
**And** T3 `classes[]` (when present on list/detail payloads) is display-only for the semester
**And** layouts work at 360 / 768 / 1280 without horizontal table scroll

### Story 2.2: Criar Professor sobre Employee ativo

As a funcionario,
I want to create a Professor linked 1–1 to an existing active Employee,
So that teaching identity starts from Employee without copying personal data.

**Acceptance Criteria:**

**Given** I choose Nova on UX-PROFESSORS
**When** I pick an `employeeId` of an existing active Employee and submit via BFF POST
**Then** the Professor is created with stable `id` and no duplicated name/email fields from Employee
**And** inactive or missing Employee yields refusal-banner from problem+json (FR-4 / FR-5 / FR-1a)
**And** UI does not invent a second personal cadastro
**And** create dialog follows compact fullscreen / medium-expanded rules (UX-DR17)
**And** verified at 360 / 768 / 1280

### Story 2.3: Detalhe Professor + AcademicDegree 1–N

As a funcionario,
I want Professor detail with AcademicDegree secondary CRUD,
So that degrees stay under the professor context.

**Acceptance Criteria:**

**Given** I open a Professor
**When** `GET /api/v1/professors/{id}` returns the aggregate
**Then** master-detail shows Professor + AcademicDegree 1–N
**And** create/edit/delete Degree uses BFF professor secondary routes
**And** `classes[]` T3 (if embedded) lists semester classes read-only; AcademicAffiliation is not shown here
**And** panels stack below 1280px; compact shows “← Voltar”
**And** destructive actions use confirm-dialog naming the object
**And** responsive ACs hold at 360 / 768 / 1280

### Story 2.4: Editar Professor e estados de recusa

As a funcionario,
I want to update Professor fields and see clear refusals,
So that FR-1a and contract errors are actionable in pt-BR.

**Acceptance Criteria:**

**Given** I edit a Professor
**When** BFF PUT/PATCH succeeds or returns problem+json
**Then** success refreshes detail/list
**And** refusals surface via refusal-banner (`role="alert"`) retaining the form
**And** UI never offers Keycloak provisioning or physical delete of Employee via this screen
**And** verified at 360 / 768 / 1280

## Epic 3: Alunos (Grupo 03 — FE cruzado)

Funcionário cadastra Students e AcademicAffiliations; vê turmas do semestre (`classes[]` T3).
**Owner:** Grupo 03 (backend `reservations`; FE = UX-STUDENTS) · **FRs:** FR7, FR8, FR-UI-T3 · **UX-DRs:** UX-DR7–9, UX-DR16–18, UX-DR20

### Story 3.1: Lista de Alunos responsiva

As a funcionario,
I want to browse Students from the BFF in a responsive list,
So that I can find students to maintain.

**Acceptance Criteria:**

**Given** I open Alunos from the menu
**When** `GET /api/v1/students` succeeds
**Then** UX-STUDENTS shows table or compact 2-line list + “Mais ações”
**And** page-header/toolbar/empty follow EXPERIENCE (pt-BR)
**And** layouts work at 360 / 768 / 1280 without horizontal table scroll

### Story 3.2: Criar e editar Student na UI

As a funcionario,
I want to create and update Students in the UI (SPEC override),
So that student identity exists for enrollment without seed-only limitation.

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-STUDENTS
**When** I submit a valid Student payload via BFF POST/PUT/PATCH
**Then** list/detail refresh with opaque string `id`
**And** validation/uniqueness refusals use refusal-banner; form retained
**And** no physical delete in v1 UI
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 3.3: Detalhe Student + AcademicAffiliation 1–N

As a funcionario,
I want Student detail with AcademicAffiliation secondary CRUD,
So that affiliations stay under the student context.

**Acceptance Criteria:**

**Given** I open a Student
**When** detail loads
**Then** master-detail shows Student + AcademicAffiliation 1–N (create/edit/delete via BFF)
**And** `classes[]` T3 (if embedded) is semester classes read-only and is **not** conflated with AcademicAffiliation
**And** stacked layout + voltar link in compact; confirm-dialog on destructive actions
**And** verified at 360 / 768 / 1280

### Story 3.4: Recusas e composição T3 no Student

As a funcionario,
I want clear feedback when writes fail or T3 composition is down,
So that I never invent local joins.

**Acceptance Criteria:**

**Given** a write fails or T3 `classes[]` composition returns 503
**When** the UI handles the response
**Then** refusal-banner or composition identity-banner shows institutional pt-BR copy
**And** UI does not join classes locally as a fallback
**And** behavior verified at 360 / 768 / 1280

## Epic 4: Salas de Aula (Grupo 04 — FE cruzado)

Funcionário mantém Rooms e AccessibilityFeatures; vê turmas do semestre na sala.
**Owner:** Grupo 04 (backend `students`; FE = UX-ROOMS) · **FRs:** FR20, FR21, FR-UI-T3 · **UX-DRs:** UX-DR7–9, UX-DR16–19, UX-DR20

### Story 4.1: Lista de Salas responsiva

As a funcionario,
I want to browse Rooms from the BFF,
So that I can manage classroom inventory.

**Acceptance Criteria:**

**Given** I open Salas de Aula from the menu
**When** `GET /api/v1/rooms` succeeds
**Then** UX-ROOMS shows responsive table/list with capacity visible
**And** page-header/toolbar/empty follow EXPERIENCE
**And** layouts work at 360 / 768 / 1280

### Story 4.2: Criar e editar Room (capacidade obrigatória)

As a funcionario,
I want to create and update Rooms with required capacity,
So that classes can pick a valid default room later.

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-ROOMS
**When** I submit without capacity
**Then** client validation blocks submit with pt-BR field error
**When** I submit a valid Room via BFF
**Then** list/detail refresh with stable `id`
**And** refusals use refusal-banner
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 4.3: AccessibilityFeature 1–N na Room

As a funcionario,
I want AccessibilityFeature secondary CRUD on Room detail,
So that accessibility is a named list (not free-text dump).

**Acceptance Criteria:**

**Given** I open a Room
**When** I manage AccessibilityFeatures via BFF secondary routes
**Then** features render as a named accessible list (UX-DR19)
**And** create/edit/delete use confirm-dialog when destructive
**And** master-detail stacks below 1280px; compact shows voltar
**And** verified at 360 / 768 / 1280

### Story 4.4: `classes[]` T3 e recusas na Room

As a funcionario,
I want to see semester classes for the room and clear errors,
So that room usage is visible without local joins.

**Acceptance Criteria:**

**Given** Room detail includes T3 `classes[]` or composition 503
**When** the UI renders
**Then** classes are read-only when present
**And** 503 shows composition banner without client-side join fallback
**And** write refusals use refusal-banner
**And** verified at 360 / 768 / 1280

## Epic 5: Recursos (Grupo 05 — FE cruzado)

Funcionário mantém Resources e InventoryItems; vê reservations futuras (T3).
**Owner:** Grupo 05 (backend `courses`; FE = UX-RESOURCES) · **FRs:** FR22, FR-UI-T3 · **UX-DRs:** UX-DR7–9, UX-DR16–18, UX-DR20

### Story 5.1: Lista de Recursos responsiva

As a funcionario,
I want to browse Resources (distinct from Rooms) from the BFF,
So that movable/bookable assets are manageable.

**Acceptance Criteria:**

**Given** I open Recursos from the menu
**When** `GET /api/v1/resources` succeeds
**Then** UX-RESOURCES shows responsive table/list
**And** Resource is never presented as a Room substitute in labels
**And** layouts work at 360 / 768 / 1280

### Story 5.2: Criar e editar Resource (ativo/inativo)

As a funcionario,
I want to create and update Resources including active flag,
So that inactive resources cannot be confirmed in later reservations.

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-RESOURCES
**When** I submit a valid Resource via BFF
**Then** list/detail refresh; `ativo=false` is clearly labeled
**And** refusals use refusal-banner; form retained
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 5.3: InventoryItem 1–N no Resource

As a funcionario,
I want InventoryItem secondary CRUD on Resource detail,
So that inventory lines stay under the resource.

**Acceptance Criteria:**

**Given** I open a Resource
**When** I manage InventoryItems via BFF
**Then** 1–N list supports create/edit/delete with confirm-dialog
**And** master-detail responsive rules apply
**And** verified at 360 / 768 / 1280

### Story 5.4: `reservations[]` T3 futuras e recusas

As a funcionario,
I want to see future reservations embedded for the resource,
So that booking pressure is visible without inventing joins.

**Acceptance Criteria:**

**Given** Resource payload includes T3 `reservations[]` or composition 503
**When** the UI renders
**Then** future reservations show read-only when present
**And** 503 shows composition banner without client join fallback
**And** verified at 360 / 768 / 1280

## Epic 6: Disciplinas (Grupo 06 — FE cruzado)

Coordenador mantém Courses, referências e SyllabusItems; vê turmas do semestre.
**Owner:** Grupo 06 (backend `resources`; FE = UX-COURSES) · **FRs:** FR10, FR11, FR12, FR-UI-T3 · **UX-DRs:** UX-DR7–9, UX-DR16–18, UX-DR20

### Story 6.1: Lista de Disciplinas responsiva

As a coordenador,
I want to browse Courses from the BFF,
So that I can open and maintain disciplinas.

**Acceptance Criteria:**

**Given** I open Disciplinas from the menu
**When** `GET /api/v1/courses` succeeds
**Then** UX-COURSES shows responsive table/list with `codigo`/`id` visible
**And** page-header/toolbar/empty follow EXPERIENCE (glossário: disciplina)
**And** layouts work at 360 / 768 / 1280

### Story 6.2: Criar e editar Course (plano datado)

As a coordenador,
I want to create and update Courses including dated teaching plan fields,
So that a Class period can be validated against the plan later.

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-COURSES
**When** I submit Course with identifiable `id`/`codigo` and plan dating fields via BFF
**Then** list/detail refresh
**And** invalid/missing plan dating relative to expected Class period rules surfaces as refusal-banner when BFF refuses (FR-11)
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 6.3: SyllabusItem 1–N no Course

As a coordenador,
I want SyllabusItem secondary CRUD on Course detail,
So that syllabus lines stay under the course.

**Acceptance Criteria:**

**Given** I open a Course
**When** I manage SyllabusItems via BFF
**Then** 1–N create/edit/delete works with confirm-dialog
**And** master-detail responsive rules apply
**And** verified at 360 / 768 / 1280

### Story 6.4: `classes[]` T3 e recusas na Disciplina

As a coordenador,
I want semester classes for the course and clear write errors,
So that offering context is visible without local joins.

**Acceptance Criteria:**

**Given** Course detail includes T3 `classes[]` or composition/write errors
**When** the UI handles them
**Then** classes are read-only when present; 503 uses composition banner
**And** write refusals use refusal-banner
**And** verified at 360 / 768 / 1280

## Epic 7: Turmas, matrículas e Aulas (Grupo 07 — FE cruzado)

Coordenador abre Classes, associa Students existentes, gera e faz CRUD de Lessons **dentro** da Turma (abas Alunos | Aulas).
**Owner:** Grupo 07 (backend `professors`; FE = UX-CLASSES + UX-CLASS-ENROLLMENTS + UX-CLASS-LESSONS) · **FRs:** FR9, FR13–FR18 (parcial), FR-UI-NAV · **UX-DRs:** UX-DR7–12, UX-DR16–18

### Story 7.1: Lista de Turmas responsiva

As a coordenador,
I want to browse Classes from the BFF,
So that I can open a turma to manage enrollments and aulas.

**Acceptance Criteria:**

**Given** I open Turmas from the menu
**When** `GET /api/v1/classes` succeeds
**Then** UX-CLASSES shows responsive table/list
**And** page-header/toolbar/empty follow EXPERIENCE (glossário: turma)
**And** layouts work at 360 / 768 / 1280

### Story 7.2: Abrir Class (esqueleto, sala padrão, colisões)

As a coordenador,
I want to create/open a Class with WeeklySlot skeleton and default room,
So that the offering is valid before generating lessons.

**Acceptance Criteria:**

**Given** I create or edit a Class
**When** I set course, professor, period, WeeklySlots (FR-14), and `salaPadraoId`
**Then** BFF create/update succeeds or refuses with collision/capacity/accessibility problem+json (FR-13, FR-15)
**And** refusal-banner shows institutional copy; form retained
**And** inactive Employee/Professor constraints surface when BFF refuses (FR-1a signal)
**And** dialogs/forms meet UX-DR17 at 360 / 768 / 1280

### Story 7.3: Detalhe Turma com abas Alunos | Aulas

As a coordenador,
I want Class detail with exactly two tabs (Alunos matriculados | Aulas),
So that enrollments and lessons stay nested under the turma.

**Acceptance Criteria:**

**Given** I open a Class
**When** the detail loads
**Then** `mat-tab-group` shows only **Alunos matriculados** and **Aulas** (UX-DR10)
**And** tabs are scrollable/usable in compact; state preserved across viewport class changes
**And** compact shows “← Voltar para Turmas”
**And** verified at 360 / 768 / 1280

### Story 7.4: UX-CLASS-ENROLLMENTS — associar Students existentes

As a coordenador,
I want to associate existing Students to the Class via picker,
So that roster is built without creating students here.

**Acceptance Criteria:**

**Given** I am on the Alunos matriculados tab
**When** I add/remove students via `studentIds` (or equivalent BFF enrollment routes)
**Then** only existing Students can be picked (UX-DR11); no “criar aluno” CTA on this screen
**And** removals use confirm-dialog
**And** refusals use refusal-banner
**And** verified at 360 / 768 / 1280

### Story 7.5: Gerar Lessons a partir do esqueleto

As a coordenador,
I want to generate Lessons from the Class weekly skeleton,
So that aulas exist for the period without auto-reserving the default room.

**Acceptance Criteria:**

**Given** Class has a valid skeleton
**When** I trigger generate
**Then** UI calls `POST /api/v1/lessons/generate` (not `/gerar`)
**And** success refreshes the Aulas tab list
**And** generation does not create a Reservation for the default room
**And** BFF refusals use refusal-banner
**And** verified at 360 / 768 / 1280

### Story 7.6: UX-CLASS-LESSONS — CRUD Lesson no contexto da Turma

As a coordenador,
I want to create, edit, and adjust Lessons only inside the Class,
So that topics, `flagAvaliacao`, modality, and effective room stay coherent.

**Acceptance Criteria:**

**Given** I am on the Aulas tab
**When** I create/edit/delete a Lesson via BFF under the Class context
**Then** fields include tópicos, `flagAvaliacao`, modalidade; `salaEfetivaId` reflects derived/effective room when present (FR-17/FR-18 parcial)
**And** there is navigation to Lesson detail (for Epic 8 reservations)
**And** no standalone Lessons menu item is introduced
**And** compact dialogs fullscreen; list uses kit patterns
**And** verified at 360 / 768 / 1280

## Epic 8: Reservas na Aula, ocupação e vistas de leitura (Grupo 08 — FE cruzado)

Professor faz CRUD de Reservations **no detalhe da Aula**; Funcionário consulta ocupação; Professor/Student leem plano+roster e minhas aulas (composição cliente).
**Owner:** Grupo 08 (backend `rooms`; FE = UX-LESSON-RESERVATIONS + UX-OCCUPANCY + UX-PROFESSOR-VIEW + UX-STUDENT-READ) · **FRs:** FR18 (leitura), FR19, FR23, FR24, FR29, FR30, FR31 · **UX-DRs:** UX-DR13–18

### Story 8.1: UX-LESSON-RESERVATIONS — lista no detalhe da Aula

As a professor,
I want to see Reservations for the open Lesson,
So that booking work stays nested under the aula.

**Acceptance Criteria:**

**Given** I open a Lesson detail from UX-CLASS-LESSONS (or documented stub route if Epic 7 shell is incomplete)
**When** reservations load via BFF
**Then** UX-LESSON-RESERVATIONS lists reservations for that Lesson only
**And** no roster of Students appears on this surface (NFR-LGPD-3)
**And** responsive kit patterns apply at 360 / 768 / 1280

### Story 8.2: Criar Reservation de Resource (caminho feliz)

As a professor,
I want to reserve an active Resource for the Lesson with canonical faixa,
So that resources are booked for the aula.

**Acceptance Criteria:**

**Given** I create a Reservation on the Lesson
**When** I pick Resource + faixa-picker A–E, F–N, P (UX-DR13) and submit
**Then** BFF create succeeds for active Resource (FR-23)
**And** inactive Resource refusal surfaces via refusal-banner (FR-22 consumer)
**And** SALA line is only offered for exception/ad-hoc paths (FR-24), not as the happy-path default
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 8.3: Alterar e cancelar Reservation

As a professor,
I want to update and cancel Reservations on the Lesson,
So that schedule changes stay in one place.

**Acceptance Criteria:**

**Given** an existing Reservation on the Lesson
**When** I edit or cancel via BFF
**Then** list refreshes; cancel uses confirm-dialog naming the object
**And** refusals use refusal-banner (FR-30)
**And** Student never sees default room when effective room diverges (FR-18 — honored on read surfaces that show room)
**And** verified at 360 / 768 / 1280

### Story 8.4: UX-OCCUPANCY — consulta por data + faixa

As a funcionario,
I want to query occupancy by `data` + `faixaId`,
So that I see occupied resources without nominative student data.

**Acceptance Criteria:**

**Given** I open Ocupação from the menu
**When** I submit `data` + `faixaId` and call `GET /api/v1/reservations/ocupacao`
**Then** UX-OCCUPANCY lists OccupancyItem resources (not a room grid) (UX-DR14; FR-29)
**And** results are non-nominative of Student (NFR-LGPD-2)
**And** empty/error states are pt-BR; horizontal scroll allowed only if required for faixa chrome
**And** verified at 360 / 768 / 1280

### Story 8.5: UX-PROFESSOR-VIEW — plano + roster (composição cliente)

As a professor,
I want to read teaching plan + roster for my class,
So that I prepare class without a dedicated BFF read-model.

**Acceptance Criteria:**

**Given** I open Plano+roster (professor view)
**When** the client composes BFF proxy responses
**Then** plan + roster render; roster is never taken from Reservation payloads (FR-31)
**And** dependency 503 shows composition/identity banners without inventing joins (UX-DR15)
**And** verified at 360 / 768 / 1280

### Story 8.6: UX-STUDENT-READ — minhas aulas (composição cliente)

As a student,
I want to read my lessons with effective room, topic, and evaluation flag,
So that I know where and what to study without seeing the default room when it differs.

**Acceptance Criteria:**

**Given** I open Minhas aulas
**When** the client composes BFF proxy responses
**Then** UX-STUDENT-READ shows sala efetiva / tópico / `flagAvaliacao` + plan context (FR-19)
**And** when `salaEfetivaId` diverges from default, only effective room is shown (FR-18)
**And** 503 banners apply; no local join fallback
**And** verified at 360 / 768 / 1280


## Final Validation (Step 4)

**Status:** PASSED — ready for development

### FR coverage
- FR1–FR3 → Stories 1.1–1.4
- FR4–FR6, FR-UI-T3 (professors) → Stories 2.1–2.4
- FR7–FR8, FR-UI-T3 (students) → Stories 3.1–3.4
- FR20–FR21, FR-UI-T3 (rooms) → Stories 4.1–4.4
- FR22, FR-UI-T3 (resources) → Stories 5.1–5.4
- FR10–FR12, FR-UI-T3 (courses) → Stories 6.1–6.4
- FR9, FR13–FR18 (parcial), FR-UI-NAV (Turma/Lessons) → Stories 7.1–7.6
- FR18 (leitura), FR19, FR23–FR24, FR29–FR31, FR-UI-NAV (Reservations) → Stories 8.1–8.6
- FR25–FR28 (base) → Stories 0.1–0.5; FR28 matrix enforced by Epic 0–8 owners

### UX-DR coverage
- UX-DR1–7, 16–19 → Epic 0
- UX-DR8–9, 16–18, 20 → Epics 1–6 (list/detail/T3)
- UX-DR10–12 → Epic 7
- UX-DR13–15 → Epic 8
- UX-DR17 (responsive gate) → every story AC at 360 / 768 / 1280

### Architecture / dependencies
- Starter FE is Epic 0 Story 0.1 (Angular 22 + Material + DESIGN tokens) — correct for this FE-only spine
- No big-bang DB creation in FE stories; entities consumed via BFF only
- Within-epic stories build forward only (list → create → detail/secondary → refusals/nested)
- Cross-epic: Epics 1–6 independent given Epic 0; Epic 7 needs master data desirably; Epic 8 nests under Lesson (stub route allowed if documented)
- File churn: intentional shared kit from Epic 0.5; domain epics own distinct UX-* routes — acceptable

### NFR highlights in stories
- NFR-RESP / NFR-A11Y / NFR-I18N-UI embedded in ACs
- NFR-LGPD-2/3 in Stories 8.1 / 8.4
- NFR-STACK / BFF-only paths (`/lessons/generate`, `/reservations/ocupacao`) in Stories 7.5 / 8.4
