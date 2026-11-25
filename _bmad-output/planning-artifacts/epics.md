---
stepsCompleted: ['step-01-validate-prerequisites', 'step-02-design-epics', 'step-03-create-stories', 'step-04-final-validation']
inputDocuments:
  - specs/spec-frontend/SPEC.md
  - specs/spec-frontend/surfaces.md
  - specs/spec-frontend/ownership.md
  - specs/spec-frontend/contribution.md
  - specs/spec-frontend/stack.md
  - specs/spec-frontend/traceability.md
  - planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
  - planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md
  - planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md
  - planning-artifacts/sprint-change-proposal-2026-11-24.md
  - planning-artifacts/epics.md
  - planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/prd.md
project_name: constrsw-2026-2
date: 2026-11-24
notes: >
  CE rewrite FE: FR-fonte = SPEC-frontend (FE-CAP-1..6). Partição travada CC 2026-11-24
  (próprio serviço). Baseline epics.md usado só para reaproveitar ACs/UX-DRs — não a
  matriz cruzada. PRD = trace secundário.
pmDecisions:
  - id: partition-locked
    date: 2026-11-24
    decision: >
      Arruda=UX-LOGIN,HOME,EMPLOYEES; G01=CLASSES+ENROLLMENTS; G02=CLASS-LESSONS;
      G03=LESSON-RESERVATIONS+OCCUPANCY; G04=STUDENTS+STUDENT-READ; G05=COURSES;
      G06=RESOURCES; G07=PROFESSORS+PROFESSOR-VIEW; G08=ROOMS.
  - id: OQ-PRD-1
    date: 2026-11-24
    decision: >
      Cadastro Student na UI (UX-STUDENTS) e associação em UX-CLASS-ENROLLMENTS;
      SPEC-frontend vence PRD seed-only para implementação FE.
---

# constrsw-2026-2 - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for constrsw-2026-2, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

**Frontend rewrite:** SPA Angular 22 + Material; FR-fonte = SPEC-frontend (`FE-CAP-*`); partição **próprio serviço** (não cruzado); épicos 0–8 conforme ownership travado; responsividade obrigatória.

## Requirements Inventory

### Functional Requirements

FE-CAP-1: Operador autentica/encerra sessão só via oauth; SPA usa Bearer na BFF. Success: UX-LOGIN `POST {oauth}/login` multipart; 201→sessão+HOME; 401 banner sem enumerar conta; 503 “Identidade indisponível.”; logout/refresh; sem keycloak-js/URL IdP.

FE-CAP-2: App-shell único (hambúrguer, marca, identidade, Sair) sem escolher microsserviço. Success: UX-HOME + shell em rotas autenticadas; `GET /api/v1/identidade/me`; menu ordem `surfaces.md`; folha &lt;1024px; sessão ausente→LOGIN.

FE-CAP-3: Superfícies de domínio lista/detalhe + secundárias 1–N via BFF, glossário pt-BR. Success: POST/PUT/PATCH/DELETE + secundárias OpenAPI BFF; empty+CTA; skeleton; refusal-banner com form retido; dados só BFF.

FE-CAP-4: Leitura composta T3 + vistas sem join de nove OpenAPIs. Success: GETs students/professors/courses/rooms com `classes[]` (sem year/semester no cliente); resources com `reservations[]`; T3 falha→503 banner; UX-OCCUPANCY; UX-PROFESSOR-VIEW; UX-STUDENT-READ = composição cliente.

FE-CAP-5: Hierarquia Turma→(Alunos|Aulas|Reservas) no detalhe; Lessons/Reservations fora do menu. Success: UX-CLASSES abas Alunos|Aulas|Reservas (Figma R07/R08); ENROLLMENTS só associa existentes; CLASS-LESSONS CRUD+`/lessons/generate`; LESSON-RESERVATIONS = aba Reservas (grade) + CRUD no detalhe da aula; sem reviews UI v1.

FE-CAP-6: Entrega paralela sem dono exclusivo da SPA. Success: ownership travado (Arruda + G01–G08 próprio serviço); contribution checklist; tokens DESIGN; Figma referência (spines vencem).

FR-SURF-LOGIN: UX-LOGIN — autenticar (oauth).
FR-SURF-HOME: UX-HOME — shell + menu + landing autenticada.
FR-SURF-EMPLOYEES: UX-EMPLOYEES — lista/detalhe Employee + Dependent 1–N (Arruda).
FR-SURF-PROFESSORS: UX-PROFESSORS — lista/detalhe + academic-degrees + classes T3 (G07).
FR-SURF-STUDENTS: UX-STUDENTS — cadastro UI + lista/detalhe + AcademicAffiliation + classes T3 (G04).
FR-SURF-ROOMS: UX-ROOMS — lista/detalhe + accessibility-features + classes T3 (G08).
FR-SURF-RESOURCES: UX-RESOURCES — lista/detalhe + occurrences + reservations T3 (G06).
FR-SURF-COURSES: UX-COURSES — lista/detalhe + bibliographic-references + syllabus-items + classes T3 (G05).
FR-SURF-CLASSES: UX-CLASSES — lista/detalhe abas Alunos|Aulas (G01).
FR-SURF-ENROLLMENTS: UX-CLASS-ENROLLMENTS — associa/desassocia Students existentes (G01).
FR-SURF-LESSONS: UX-CLASS-LESSONS — CRUD Lesson + generate (G02).
FR-SURF-RESERVATIONS: UX-LESSON-RESERVATIONS — CRUD Reservation da aula (G03).
FR-SURF-OCCUPANCY: UX-OCCUPANCY — ocupação data+faixaId (G03).
FR-SURF-PROF-VIEW: UX-PROFESSOR-VIEW — plano+roster composição cliente (G07).
FR-SURF-STUDENT-READ: UX-STUDENT-READ — minhas aulas composição cliente (G04).

FR-UI-T3: Cliente não envia year/semester; semestre America/Sao_Paulo; array vazio se não houver; 503 sem lista parcial.
FR-UI-NAV: Menu 10 itens ordem fixa; Lessons/Reservations fora do topo; Reservations só no detalhe da Aula.
FR-UI-REFS: Toda story FE inclui Refs FE-CAP-N + UX-* + ownership + path (`traceability.md`).

### NonFunctional Requirements

NFR-STACK: Angular 22.x + Angular Material M3 + CDK + SCSS + tokens DESIGN; sem React/Vite/TanStack; código em `frontend/`; porta lab 4200 (AD-8 / stack.md).
NFR-BOUNDARY: Dados só BFF; auth só oauth; sem CORS/chamada aos nove contextos; sem keycloak-js.
NFR-I18N: UI 100% pt-BR; paths OpenAPI em inglês; glossário disciplina/turma/aula/reserva/faixa.
NFR-DESIGN: Tokens DESIGN.md prevalecem; sem seletores frágeis `.mdc-*`.
NFR-RESP: 360–1440px+ compact/medium/expanded; pivô nav 1024; ACs em 360/768/1280; sem desktop-only.
NFR-A11Y: WCAG 2.2 AA; banners `role="alert"`; alvos ≥24px (toque ≥48px compact/medium).
NFR-SESSION: Bearer em memória de sessão (não localStorage longo); cookie httpOnly pode coexistir.
NFR-AUTHORITY: SPEC-frontend > EXPERIENCE > DESIGN > Figma; closed-cras vence FRs de produto.
NFR-LGPD-2/3: Ocupação/vistas sem nominativo indevido; roster não em Reservation.
NFR-OBS: Compose sobe FE; `/health` BFF não é tela.
NFR-TEST: E2E UJ-1…UJ-4 na UI contra compose (AD-11) — após superfícies.

### Additional Requirements

- Starter FE (AD-8): scaffold Angular 22 + Material no Epic 0 Story 1 (`frontend/`); sem SSR competindo com BFF.
- Path BFF vigente: `POST /api/v1/lessons/generate`; `GET /api/v1/reservations/ocupacao`.
- FR-19/FR-31: composição **cliente** sobre proxies (não read-model BFF dedicado legado).
- Envelope Compose inclui frontend (AD-7 / OV-9).
- Baseline `epics.md` (branch épicos): reaproveitar ACs GWT/responsivo; **descartar** títulos/donos “FE cruzado”.
- Sprint Change Proposal 2026-11-24: matriz épicos 0–8 travada; regenerar sprint-status após stories.

### UX Design Requirements

UX-DR1: Tema Angular Material com tokens DESIGN.md (primary `#0066B3`, navy, sky `#6DCDF6`, surfaces, error; v1 light-only).
UX-DR2: Chrome → `mat-toolbar`, `mat-sidenav`, `mat-nav-list`, `mat-table`, `mat-form-field`, `mat-chip`, `mat-tab-group`, `mat-dialog`, `mat-snack-bar`, `mat-progress-bar`.
UX-DR3: Métricas M3 — app bar 64dp, nav 56dp, ícone 24dp, botões 40dp, field 56dp; sem FAB; sem botão one-off.
UX-DR4: UX-LOGIN — login-panel split/faixa/compact; 401/503 banners.
UX-DR5: UX-HOME — hambúrguer, marca Closed CRAS, caption PUCRS·ConstrSW, usuário `/identidade/me`, Sair.
UX-DR6: hamburger-nav 10 itens; folha modal &lt;1024px; Esc/scrim; item ativo.
UX-DR7: page-header + toolbar (busca + CTA); empty pt-BR + CTA.
UX-DR8: data-table → lista 2 linhas + “Mais ações” em compact; TableRowActions; sem infinite scroll; sem scroll H (exceto ocupação).
UX-DR9: master-detail-panel — 2 colunas ≥1280; empilhado abaixo; voltar em compact.
UX-DR10: class-tabs — Alunos | Aulas | Reservas (Figma R07/R08); roláveis em compact.
UX-DR11: UX-CLASS-ENROLLMENTS — picker Students existentes; sem criar Student.
UX-DR12: UX-CLASS-LESSONS — CRUD + generate; nav ao detalhe da aula.
UX-DR13: UX-LESSON-RESERVATIONS — CRUD; faixa-picker A–E,F–N,P.
UX-DR14: UX-OCCUPANCY — data + faixaId → OccupancyItem (recursos); não grade de salas.
UX-DR15: UX-PROFESSOR-VIEW e UX-STUDENT-READ — composição cliente; banners 503.
UX-DR16: refusal-banner / identity-banner / confirm-dialog / skeleton-block (State Patterns).
UX-DR17: Gate responsivo 360/768/1280 em toda superfície; touch ≥48px compact/medium; dialog fullscreen compact; WCAG 1.4.10.
UX-DR18: Microcopy pt-BR; glossário travado.
UX-DR19: A11y — h1 page-header; `role="alert"`; AccessibilityFeature lista nomeada.
UX-DR20: Exibir `classes[]` T3 em Professors/Students/Rooms/Courses e `reservations[]` em Resources; AcademicAffiliation ≠ classes[].

### FR Coverage Map

FE-CAP-1: Epic 0 — auth oauth / UX-LOGIN / sessão Bearer
FE-CAP-2: Epic 0 — app-shell / UX-HOME / menu
FE-CAP-3: Epics 0–8 — master-detail BFF por superfície do dono
FE-CAP-4: Epics 3,4,6,7,8 — T3 + UX-OCCUPANCY + vistas (OCCUPANCY=E3; STUDENT-READ=E4; RESOURCES T3=E6; PROF-VIEW=E7; rooms/professors/students/courses T3 nos respectivos)
FE-CAP-5: Epics 1–3 — hierarquia Turma→Aulas→Reservas
FE-CAP-6: Epic 0–8 — ownership/contribution (transversal; employees em E0)

FR-SURF-LOGIN: Epic 0
FR-SURF-HOME: Epic 0
FR-SURF-EMPLOYEES: Epic 0
FR-SURF-CLASSES: Epic 1
FR-SURF-ENROLLMENTS: Epic 1
FR-SURF-LESSONS: Epic 2
FR-SURF-RESERVATIONS: Epic 3
FR-SURF-OCCUPANCY: Epic 3
FR-SURF-STUDENTS: Epic 4
FR-SURF-STUDENT-READ: Epic 4
FR-SURF-COURSES: Epic 5
FR-SURF-RESOURCES: Epic 6
FR-SURF-PROFESSORS: Epic 7
FR-SURF-PROF-VIEW: Epic 7
FR-SURF-ROOMS: Epic 8

FR-UI-T3: Epics 4–8 (+ E6 resources) — exibir classes[]/reservations[] + 503
FR-UI-NAV: Epic 0 (+ E1–3 nested) — menu fixo; Lessons/Reservations fora do topo
FR-UI-REFS: Epic 0–8 — bloco Refs FE-CAP/UX/ownership/path em toda story

## Epic List

### Epic 0: Scaffold, autenticação, shell e Funcionários (Prof. Arruda)
Operadores entram na SPA Angular, navegam pelo shell Closed CRAS e gerenciam Funcionários (+ dependents); baseline técnica compartilhada pronta para os grupos.
**Owner:** Prof. Arruda · **FRs:** FE-CAP-1, FE-CAP-2, FE-CAP-3 (employees), FE-CAP-6 (base), FR-SURF-LOGIN/HOME/EMPLOYEES, FR-UI-NAV, FR-UI-REFS · **UX:** UX-LOGIN, UX-HOME, UX-EMPLOYEES

### Epic 1: Turmas e matrículas (Grupo 01 / classes)
Operadores abrem turmas e associam Students já cadastrados nas abas da turma.
**Owner:** Grupo 01 · **FRs:** FE-CAP-3, FE-CAP-5, FR-SURF-CLASSES, FR-SURF-ENROLLMENTS · **UX:** UX-CLASSES, UX-CLASS-ENROLLMENTS

### Epic 2: Aulas da turma (Grupo 02 / lessons)
Operadores geram e mantêm Lessons da turma (CRUD + generate) na aba Aulas.
**Owner:** Grupo 02 · **FRs:** FE-CAP-5, FE-CAP-3, FR-SURF-LESSONS · **UX:** UX-CLASS-LESSONS  
**Dep soft:** Epic 1 (detalhe de turma / abas)

### Epic 3: Reservas da aula e ocupação (Grupo 03 / reservations)
Operadores reservam recursos no detalhe da aula e consultam ocupação por data+faixa.
**Owner:** Grupo 03 · **FRs:** FE-CAP-4, FE-CAP-5, FR-SURF-RESERVATIONS, FR-SURF-OCCUPANCY · **UX:** UX-LESSON-RESERVATIONS, UX-OCCUPANCY  
**Dep soft:** Epic 2 (detalhe da aula)

### Epic 4: Alunos e minhas aulas (Grupo 04 / students)
Operadores cadastram Students (+ affiliations) e alunos leem “Minhas aulas” (composição cliente).
**Owner:** Grupo 04 · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-STUDENTS, FR-SURF-STUDENT-READ, FR-UI-T3 · **UX:** UX-STUDENTS, UX-STUDENT-READ

### Epic 5: Disciplinas (Grupo 05 / courses)
Operadores gerenciam Courses (+ syllabus / bibliographic) e veem turmas T3 do semestre.
**Owner:** Grupo 05 · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-COURSES, FR-UI-T3 · **UX:** UX-COURSES

### Epic 6: Recursos (Grupo 06 / resources)
Operadores gerenciam Resources (+ inventory/occurrences) e veem reservations futuras T3.
**Owner:** Grupo 06 · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-RESOURCES, FR-UI-T3 · **UX:** UX-RESOURCES

### Epic 7: Professores e plano/roster (Grupo 07 / professors)
Operadores gerenciam Professors (+ degrees, T3) e leem plano+roster (composição cliente).
**Owner:** Grupo 07 · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-PROFESSORS, FR-SURF-PROF-VIEW, FR-UI-T3 · **UX:** UX-PROFESSORS, UX-PROFESSOR-VIEW

### Epic 8: Salas de Aula (Grupo 08 / rooms)
Operadores gerenciam Rooms (+ accessibility-features) e veem turmas T3 do semestre.
**Owner:** Grupo 08 · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-ROOMS, FR-UI-T3 · **UX:** UX-ROOMS

## Epic 0: Scaffold, autenticação, shell e Funcionários (Prof. Arruda)

Operadores entram na SPA Angular, navegam pelo shell Closed CRAS e gerenciam Funcionários (+ dependents); baseline técnica compartilhada pronta para os grupos.
**Owner:** Prof. Arruda · **FRs:** FE-CAP-1, FE-CAP-2, FE-CAP-3 (employees), FE-CAP-6 · **UX:** UX-LOGIN, UX-HOME, UX-EMPLOYEES · **UX-DRs:** UX-DR1–9, 16–19

### Story 0.1: Scaffold Angular 22 + Material + tema DESIGN

As a developer on the Closed CRAS frontend,
I want an Angular 22 SPA with Angular Material themed to DESIGN.md tokens in `frontend/`,
So that all groups share one runnable UI baseline on compose (port 4200).

**Refs:** SPEC-frontend FE-CAP-6, FE-CAP-2; ownership:Prof. Arruda; paths: frontend/ (scaffold)

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

**Refs:** SPEC-frontend FE-CAP-1; UX-LOGIN; ownership:Prof. Arruda; paths: frontend/src/app/shell/

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

**Refs:** SPEC-frontend FE-CAP-1; UX-LOGIN; ownership:Prof. Arruda; paths: frontend/src/app/shell/

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

**Refs:** SPEC-frontend FE-CAP-2; UX-HOME; ownership:Prof. Arruda; paths: frontend/src/app/shell/

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

**Refs:** SPEC-frontend FE-CAP-2, FE-CAP-3, FE-CAP-4; ownership:Prof. Arruda; paths: frontend/src/app/shared/

**Acceptance Criteria:**

**Given** the shell from 0.4
**When** shared components are available
**Then** data-table becomes a 2-line list + “Mais ações” in compact; no table horizontal scroll
**And** edit dialogs are fullscreen with sticky footer actions in compact; confirm-dialog stacks buttons if needed
**And** refusal-banner, identity-banner (`role="alert"`), skeleton-block, and empty states follow EXPERIENCE State Patterns
**And** the HTTP client targets only the BFF OpenAPI base; 401/503 map to the correct banners
**And** T3 503 responses show “Serviço de composição indisponível.” without client-side join fallback
**And** all kit demos/docs pages (if any) pass 360 / 768 / 1280 (UX-DR8–9, UX-DR16–17; FR25–26)

### Story 0.6: Lista de Funcionários responsiva

As a funcionario,
I want to browse Employees from the BFF in a responsive list,
So that I can find and open a person to maintain.

**Refs:** SPEC-frontend FE-CAP-3, FE-CAP-6; UX-EMPLOYEES; ownership:Prof. Arruda; paths: frontend/src/app/surfaces/ux-employees/

**Acceptance Criteria:**

**Given** I am authenticated and open Funcionários from the menu
**When** `GET /api/v1/employees` succeeds
**Then** UX-EMPLOYEES shows a data-table (expanded/medium) or 2-line list + “Mais ações” (compact)
**And** page-header and toolbar (search + primary CTA) follow EXPERIENCE
**And** empty state is pt-BR with CTA when creation is allowed
**And** T3/composition 503 (if applicable) shows the composition banner without partial local joins
**And** layouts work at 360 / 768 / 1280 without horizontal table scroll

### Story 0.7: Detalhe Employee + Dependent 1–N

As a funcionario,
I want Employee detail with Dependent secondary CRUD,
So that personal dependents stay with the employee record.

**Refs:** SPEC-frontend FE-CAP-3; UX-EMPLOYEES; ownership:Prof. Arruda; paths: frontend/src/app/surfaces/ux-employees/

**Acceptance Criteria:**

**Given** I open an Employee row
**When** `GET /api/v1/employees/{id}` returns the aggregate
**Then** master-detail shows Employee fields and Dependent 1–N for that employee only
**And** create/edit/delete Dependent uses the BFF employee secondary routes
**And** below 1280px the panels stack; compact shows “← Voltar para {lista}”
**And** edit dialogs are fullscreen in compact with footer actions
**And** destructive actions use confirm-dialog naming the object
**And** responsive ACs hold at 360 / 768 / 1280

### Story 0.8: Criar e editar Employee (ciclo de vida)

As a funcionario,
I want to create and update Employees (including `ativo`),
So that identity for allocation stays accurate without Keycloak provisioning.

**Refs:** SPEC-frontend FE-CAP-3; UX-EMPLOYEES; ownership:Prof. Arruda; paths: frontend/src/app/surfaces/ux-employees/

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-EMPLOYEES
**When** I submit a valid Employee payload via BFF POST/PUT/PATCH
**Then** the list/detail refresh with the stable `id`
**And** email uniqueness violations surface via refusal-banner (problem+json), form retained
**And** setting `ativo=false` is allowed; UI does not call Keycloak to provision users on create
**And** no physical delete is offered in v1
**And** forms meet compact/medium/expanded dialog rules (UX-DR17)

### Story 0.9: Estados de recusa e Employee inativo na UI

As a funcionario,
I want clear feedback when writes fail or an employee is inactive,
So that I understand FR-1a impact without stack traces.

**Refs:** SPEC-frontend FE-CAP-3; UX-EMPLOYEES; ownership:Prof. Arruda; paths: frontend/src/app/surfaces/ux-employees/

**Acceptance Criteria:**

**Given** a BFF write returns problem+json (`code` = FR id when present)
**When** the UI handles the response
**Then** refusal-banner shows institutional pt-BR copy (`role="alert"`)
**And** inactive employees are visible but labeled so consumers (later epics) can enforce FR-1a
**And** network/BFF identity-style 503 uses identity-banner patterns where appropriate
**And** behavior is verified at 360 / 768 / 1280

## Epic 1: Turmas e matrículas (Grupo 01 / classes)

Operadores abrem turmas e associam Students já cadastrados nas abas da turma.
**Owner:** Grupo 01 (`classes`) · **FRs:** FE-CAP-3, FE-CAP-5, FR-SURF-CLASSES, FR-SURF-ENROLLMENTS · **UX:** UX-CLASSES, UX-CLASS-ENROLLMENTS · **UX-DRs:** UX-DR7–11, 16–18

### Story 1.1: Lista de Turmas responsiva

As a coordenador,
I want to browse Classes from the BFF,
So that I can open a turma to manage enrollments and aulas.

**Refs:** SPEC-frontend FE-CAP-3, FE-CAP-5; UX-CLASSES; ownership:Grupo 01; paths: frontend/src/app/surfaces/ux-classes/

**Acceptance Criteria:**

**Given** I open Turmas from the menu
**When** `GET /api/v1/classes` succeeds
**Then** UX-CLASSES shows responsive table/list
**And** page-header/toolbar/empty follow EXPERIENCE (glossário: turma)
**And** layouts work at 360 / 768 / 1280

### Story 1.2: Abrir Class (esqueleto, sala padrão, colisões)

As a coordenador,
I want to create/open a Class with WeeklySlot skeleton and default room,
So that the offering is valid before generating lessons.

**Refs:** SPEC-frontend FE-CAP-3, FE-CAP-5; UX-CLASSES; ownership:Grupo 01; paths: frontend/src/app/surfaces/ux-classes/

**Acceptance Criteria:**

**Given** I create or edit a Class
**When** I set course, professor, period, WeeklySlots (FR-14), and `salaPadraoId`
**Then** BFF create/update succeeds or refuses with collision/capacity/accessibility problem+json (FR-13, FR-15)
**And** refusal-banner shows institutional copy; form retained
**And** inactive Employee/Professor constraints surface when BFF refuses (FR-1a signal)
**And** dialogs/forms meet UX-DR17 at 360 / 768 / 1280

### Story 1.3: Detalhe Turma com abas Alunos | Aulas | Reservas

As a coordenador,
I want Class detail with three tabs (Alunos matriculados | Aulas | Reservas),
So that enrollments, lessons and the period reservation hub stay nested under the turma (Figma R07/R08).

**Refs:** SPEC-frontend FE-CAP-5; UX-CLASSES; ownership:Grupo 01; paths: frontend/src/app/surfaces/ux-classes/

**Acceptance Criteria:**

**Given** I open a Class
**When** the detail loads
**Then** `mat-tab-group` shows **Alunos matriculados**, **Aulas** and **Reservas** (UX-DR10; Figma R07/R08)
**And** the Reservas tab hosts UX-LESSON-RESERVATIONS hub content (Grupo 03; grade faixa×dia + Nova reserva)
**And** tabs are scrollable/usable in compact; state preserved across viewport class changes
**And** compact shows “← Voltar para Turmas”
**And** verified at 360 / 768 / 1280

### Story 1.4: UX-CLASS-ENROLLMENTS — associar Students existentes

As a coordenador,
I want to associate existing Students to the Class via picker,
So that roster is built without creating students here.

**Refs:** SPEC-frontend FE-CAP-5; UX-CLASS-ENROLLMENTS; ownership:Grupo 01; paths: frontend/src/app/surfaces/ux-classes/

**Acceptance Criteria:**

**Given** I am on the Alunos matriculados tab
**When** I add/remove students via `studentIds` (or equivalent BFF enrollment routes)
**Then** only existing Students can be picked (UX-DR11); no “criar aluno” CTA on this screen
**And** removals use confirm-dialog
**And** refusals use refusal-banner
**And** verified at 360 / 768 / 1280

## Epic 2: Aulas da turma (Grupo 02 / lessons)

Operadores geram e mantêm Lessons da turma (CRUD + generate) na aba Aulas.
**Owner:** Grupo 02 (`lessons`) · **FRs:** FE-CAP-5, FR-SURF-LESSONS · **UX:** UX-CLASS-LESSONS · **Dep soft:** Epic 1 · **UX-DRs:** UX-DR10, 12, 16–18

### Story 2.1: Gerar Lessons a partir do esqueleto

As a coordenador,
I want to generate Lessons from the Class weekly skeleton,
So that aulas exist for the period without auto-reserving the default room.

**Refs:** SPEC-frontend FE-CAP-5; UX-CLASS-LESSONS; ownership:Grupo 02; paths: frontend/src/app/surfaces/ux-class-lessons/

**Acceptance Criteria:**

**Given** Class has a valid skeleton
**When** I trigger generate
**Then** UI calls `POST /api/v1/lessons/generate` (not `/gerar`)
**And** success refreshes the Aulas tab list
**And** generation does not create a Reservation for the default room
**And** BFF refusals use refusal-banner
**And** verified at 360 / 768 / 1280

### Story 2.2: UX-CLASS-LESSONS — CRUD Lesson no contexto da Turma

As a coordenador,
I want to create, edit, and adjust Lessons only inside the Class,
So that topics, `flagAvaliacao`, modality, and effective room stay coherent.

**Refs:** SPEC-frontend FE-CAP-5; UX-CLASS-LESSONS; ownership:Grupo 02; paths: frontend/src/app/surfaces/ux-class-lessons/

**Acceptance Criteria:**

**Given** I am on the Aulas tab
**When** I create/edit/delete a Lesson via BFF under the Class context
**Then** fields include tópicos, `flagAvaliacao`, modalidade; `salaEfetivaId` reflects derived/effective room when present (FR-17/FR-18 parcial)
**And** there is navigation to Lesson detail (for Epic 3 reservations)
**And** no standalone Lessons menu item is introduced
**And** compact dialogs fullscreen; list uses kit patterns
**And** verified at 360 / 768 / 1280

## Epic 3: Reservas da aula e ocupação (Grupo 03 / reservations)

Operadores reservam recursos pela aba Reservas da turma e no detalhe da aula; consultam ocupação por data+faixa.
**Owner:** Grupo 03 (`reservations`) · **FRs:** FE-CAP-4, FE-CAP-5, FR-SURF-RESERVATIONS, FR-SURF-OCCUPANCY · **UX:** UX-LESSON-RESERVATIONS, UX-OCCUPANCY · **Dep soft:** Epic 2 · **UX-DRs:** UX-DR10, 13–14, 16–18

### Story 3.1: UX-LESSON-RESERVATIONS — hub da aba Reservas + lista no detalhe da Aula

As a professor,
I want the Turma Reservas tab (period grid) and the open Lesson reservation list,
So that booking work matches Figma R08C and frame 21.

**Refs:** SPEC-frontend FE-CAP-5; UX-LESSON-RESERVATIONS; ownership:Grupo 03; paths: frontend/src/app/surfaces/ux-lesson-reservations/

**Acceptance Criteria:**

**Given** I open the **Reservas** tab on a Class (Figma R08C)
**When** the hub loads
**Then** I see a faixa×dia period grid with Livre/Ocup states and a **Nova reserva** CTA
**Given** I open a Lesson detail from UX-CLASS-LESSONS (or documented stub route if Epic 2 shell is incomplete)
**When** reservations load via BFF
**Then** UX-LESSON-RESERVATIONS lists reservations for that Lesson only
**And** no roster of Students appears on this surface (NFR-LGPD-3)
**And** responsive kit patterns apply at 360 / 768 / 1280

### Story 3.2: Criar Reservation de Resource (caminho feliz)

As a professor,
I want to reserve an active Resource for the Lesson with canonical faixa,
So that resources are booked for the aula.

**Refs:** SPEC-frontend FE-CAP-5; UX-LESSON-RESERVATIONS; ownership:Grupo 03; paths: frontend/src/app/surfaces/ux-lesson-reservations/

**Acceptance Criteria:**

**Given** I create a Reservation on the Lesson
**When** I pick Resource + faixa-picker A–E, F–N, P (UX-DR13) and submit
**Then** BFF create succeeds for active Resource (FR-23)
**And** inactive Resource refusal surfaces via refusal-banner (FR-22 consumer)
**And** SALA line is only offered for exception/ad-hoc paths (FR-24), not as the happy-path default
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 3.3: Alterar e cancelar Reservation

As a professor,
I want to update and cancel Reservations on the Lesson,
So that schedule changes stay in one place.

**Refs:** SPEC-frontend FE-CAP-5; UX-LESSON-RESERVATIONS; ownership:Grupo 03; paths: frontend/src/app/surfaces/ux-lesson-reservations/

**Acceptance Criteria:**

**Given** an existing Reservation on the Lesson
**When** I edit or cancel via BFF
**Then** list refreshes; cancel uses confirm-dialog naming the object
**And** refusals use refusal-banner (FR-30)
**And** Student never sees default room when effective room diverges (FR-18 — honored on read surfaces that show room)
**And** verified at 360 / 768 / 1280

### Story 3.4: UX-OCCUPANCY — consulta por data + faixa

As a funcionario,
I want to query occupancy by `data` + `faixaId`,
So that I see occupied resources without nominative student data.

**Refs:** SPEC-frontend FE-CAP-4; UX-OCCUPANCY; ownership:Grupo 03; paths: frontend/src/app/surfaces/ux-occupancy/

**Acceptance Criteria:**

**Given** I open Ocupação from the menu
**When** I submit `data` + `faixaId` and call `GET /api/v1/reservations/ocupacao`
**Then** UX-OCCUPANCY lists OccupancyItem resources (not a room grid) (UX-DR14; FR-29)
**And** results are non-nominative of Student (NFR-LGPD-2)
**And** empty/error states are pt-BR; horizontal scroll allowed only if required for faixa chrome
**And** verified at 360 / 768 / 1280

## Epic 4: Alunos e minhas aulas (Grupo 04 / students)

Operadores cadastram Students (+ affiliations) e alunos leem “Minhas aulas” (composição cliente).
**Owner:** Grupo 04 (`students`) · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-STUDENTS, FR-SURF-STUDENT-READ, FR-UI-T3 · **UX:** UX-STUDENTS, UX-STUDENT-READ · **UX-DRs:** UX-DR7–9, 15–18, 20

### Story 4.1: Lista de Alunos responsiva

As a funcionario,
I want to browse Students from the BFF in a responsive list,
So that I can find students to maintain.

**Refs:** SPEC-frontend FE-CAP-3; UX-STUDENTS; ownership:Grupo 04; paths: frontend/src/app/surfaces/ux-students/

**Acceptance Criteria:**

**Given** I open Alunos from the menu
**When** `GET /api/v1/students` succeeds
**Then** UX-STUDENTS shows table or compact 2-line list + “Mais ações”
**And** page-header/toolbar/empty follow EXPERIENCE (pt-BR)
**And** layouts work at 360 / 768 / 1280 without horizontal table scroll

### Story 4.2: Criar e editar Student na UI

As a funcionario,
I want to create and update Students in the UI (SPEC override),
So that student identity exists for enrollment without seed-only limitation.

**Refs:** SPEC-frontend FE-CAP-3; UX-STUDENTS; ownership:Grupo 04; paths: frontend/src/app/surfaces/ux-students/

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-STUDENTS
**When** I submit a valid Student payload via BFF POST/PUT/PATCH
**Then** list/detail refresh with opaque string `id`
**And** validation/uniqueness refusals use refusal-banner; form retained
**And** no physical delete in v1 UI
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 4.3: Detalhe Student + AcademicAffiliation 1–N

As a funcionario,
I want Student detail with AcademicAffiliation secondary CRUD,
So that affiliations stay under the student context.

**Refs:** SPEC-frontend FE-CAP-3, FE-CAP-4; UX-STUDENTS; ownership:Grupo 04; paths: frontend/src/app/surfaces/ux-students/

**Acceptance Criteria:**

**Given** I open a Student
**When** detail loads
**Then** master-detail shows Student + AcademicAffiliation 1–N (create/edit/delete via BFF)
**And** `classes[]` T3 (if embedded) is semester classes read-only and is **not** conflated with AcademicAffiliation
**And** stacked layout + voltar link in compact; confirm-dialog on destructive actions
**And** verified at 360 / 768 / 1280

### Story 4.4: Recusas e composição T3 no Student

As a funcionario,
I want clear feedback when writes fail or T3 composition is down,
So that I never invent local joins.

**Refs:** SPEC-frontend FE-CAP-4; UX-STUDENTS; ownership:Grupo 04; paths: frontend/src/app/surfaces/ux-students/

**Acceptance Criteria:**

**Given** a write fails or T3 `classes[]` composition returns 503
**When** the UI handles the response
**Then** refusal-banner or composition identity-banner shows institutional pt-BR copy
**And** UI does not join classes locally as a fallback
**And** behavior verified at 360 / 768 / 1280

### Story 4.5: UX-STUDENT-READ — minhas aulas (composição cliente)

As a student,
I want to read my lessons with effective room, topic, and evaluation flag,
So that I know where and what to study without seeing the default room when it differs.

**Refs:** SPEC-frontend FE-CAP-4; UX-STUDENT-READ; ownership:Grupo 04; paths: frontend/src/app/surfaces/ux-student-read/

**Acceptance Criteria:**

**Given** I open Minhas aulas
**When** the client composes BFF proxy responses
**Then** UX-STUDENT-READ shows sala efetiva / tópico / `flagAvaliacao` + plan context (FR-19)
**And** when `salaEfetivaId` diverges from default, only effective room is shown (FR-18)
**And** 503 banners apply; no local join fallback
**And** verified at 360 / 768 / 1280

## Epic 5: Disciplinas (Grupo 05 / courses)

Operadores gerenciam Courses (+ syllabus / bibliographic) e veem turmas T3 do semestre.
**Owner:** Grupo 05 (`courses`) · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-COURSES, FR-UI-T3 · **UX:** UX-COURSES · **UX-DRs:** UX-DR7–9, 16–18, 20

### Story 5.1: Lista de Disciplinas responsiva

As a coordenador,
I want to browse Courses from the BFF,
So that I can open and maintain disciplinas.

**Refs:** SPEC-frontend FE-CAP-3; UX-COURSES; ownership:Grupo 05; paths: frontend/src/app/surfaces/ux-courses/

**Acceptance Criteria:**

**Given** I open Disciplinas from the menu
**When** `GET /api/v1/courses` succeeds
**Then** UX-COURSES shows responsive table/list with `codigo`/`id` visible
**And** page-header/toolbar/empty follow EXPERIENCE (glossário: disciplina)
**And** layouts work at 360 / 768 / 1280

### Story 5.2: Criar e editar Course (plano datado)

As a coordenador,
I want to create and update Courses including dated teaching plan fields,
So that a Class period can be validated against the plan later.

**Refs:** SPEC-frontend FE-CAP-3; UX-COURSES; ownership:Grupo 05; paths: frontend/src/app/surfaces/ux-courses/

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-COURSES
**When** I submit Course with identifiable `id`/`codigo` and plan dating fields via BFF
**Then** list/detail refresh
**And** invalid/missing plan dating relative to expected Class period rules surfaces as refusal-banner when BFF refuses (FR-11)
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 5.3: SyllabusItem 1–N no Course

As a coordenador,
I want SyllabusItem secondary CRUD on Course detail,
So that syllabus lines stay under the course.

**Refs:** SPEC-frontend FE-CAP-3; UX-COURSES; ownership:Grupo 05; paths: frontend/src/app/surfaces/ux-courses/

**Acceptance Criteria:**

**Given** I open a Course
**When** I manage SyllabusItems via BFF
**Then** 1–N create/edit/delete works with confirm-dialog
**And** master-detail responsive rules apply
**And** verified at 360 / 768 / 1280

### Story 5.4: `classes[]` T3 e recusas na Disciplina

As a coordenador,
I want semester classes for the course and clear write errors,
So that offering context is visible without local joins.

**Refs:** SPEC-frontend FE-CAP-4; UX-COURSES; ownership:Grupo 05; paths: frontend/src/app/surfaces/ux-courses/

**Acceptance Criteria:**

**Given** Course detail includes T3 `classes[]` or composition/write errors
**When** the UI handles them
**Then** classes are read-only when present; 503 uses composition banner
**And** write refusals use refusal-banner
**And** verified at 360 / 768 / 1280

## Epic 6: Recursos (Grupo 06 / resources)

Operadores gerenciam Resources (+ inventory/occurrences) e veem reservations futuras T3.
**Owner:** Grupo 06 (`resources`) · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-RESOURCES, FR-UI-T3 · **UX:** UX-RESOURCES · **UX-DRs:** UX-DR7–9, 16–18, 20

### Story 6.1: Lista de Recursos responsiva

As a funcionario,
I want to browse Resources (distinct from Rooms) from the BFF,
So that movable/bookable assets are manageable.

**Refs:** SPEC-frontend FE-CAP-3; UX-RESOURCES; ownership:Grupo 06; paths: frontend/src/app/surfaces/ux-resources/

**Acceptance Criteria:**

**Given** I open Recursos from the menu
**When** `GET /api/v1/resources` succeeds
**Then** UX-RESOURCES shows responsive table/list
**And** Resource is never presented as a Room substitute in labels
**And** layouts work at 360 / 768 / 1280

### Story 6.2: Criar e editar Resource (ativo/inativo)

As a funcionario,
I want to create and update Resources including active flag,
So that inactive resources cannot be confirmed in later reservations.

**Refs:** SPEC-frontend FE-CAP-3; UX-RESOURCES; ownership:Grupo 06; paths: frontend/src/app/surfaces/ux-resources/

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-RESOURCES
**When** I submit a valid Resource via BFF
**Then** list/detail refresh; `ativo=false` is clearly labeled
**And** refusals use refusal-banner; form retained
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 6.3: InventoryItem 1–N no Resource

As a funcionario,
I want InventoryItem secondary CRUD on Resource detail,
So that inventory lines stay under the resource.

**Refs:** SPEC-frontend FE-CAP-3; UX-RESOURCES; ownership:Grupo 06; paths: frontend/src/app/surfaces/ux-resources/

**Acceptance Criteria:**

**Given** I open a Resource
**When** I manage InventoryItems via BFF
**Then** 1–N list supports create/edit/delete with confirm-dialog
**And** master-detail responsive rules apply
**And** verified at 360 / 768 / 1280

### Story 6.4: `reservations[]` T3 futuras e recusas

As a funcionario,
I want to see future reservations embedded for the resource,
So that booking pressure is visible without inventing joins.

**Refs:** SPEC-frontend FE-CAP-4; UX-RESOURCES; ownership:Grupo 06; paths: frontend/src/app/surfaces/ux-resources/

**Acceptance Criteria:**

**Given** Resource payload includes T3 `reservations[]` or composition 503
**When** the UI renders
**Then** future reservations show read-only when present
**And** 503 shows composition banner without client join fallback
**And** verified at 360 / 768 / 1280

## Epic 7: Professores e plano/roster (Grupo 07 / professors)

Operadores gerenciam Professors (+ degrees, T3) e leem plano+roster (composição cliente).
**Owner:** Grupo 07 (`professors`) · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-PROFESSORS, FR-SURF-PROF-VIEW, FR-UI-T3 · **UX:** UX-PROFESSORS, UX-PROFESSOR-VIEW · **UX-DRs:** UX-DR7–9, 15–18, 20

### Story 7.1: Lista de Professores responsiva

As a funcionario,
I want to browse Professors from the BFF in a responsive list,
So that I can find and open a professor record.

**Refs:** SPEC-frontend FE-CAP-3, FE-CAP-4; UX-PROFESSORS; ownership:Grupo 07; paths: frontend/src/app/surfaces/ux-professors/

**Acceptance Criteria:**

**Given** I am authenticated and open Professores from the menu
**When** `GET /api/v1/professors` succeeds
**Then** UX-PROFESSORS shows data-table (expanded/medium) or 2-line list + “Mais ações” (compact)
**And** page-header + toolbar (search + CTA Nova) follow EXPERIENCE
**And** empty state is pt-BR with CTA when creation is allowed
**And** T3 `classes[]` (when present on list/detail payloads) is display-only for the semester
**And** layouts work at 360 / 768 / 1280 without horizontal table scroll

### Story 7.2: Criar Professor sobre Employee ativo

As a funcionario,
I want to create a Professor linked 1–1 to an existing active Employee,
So that teaching identity starts from Employee without copying personal data.

**Refs:** SPEC-frontend FE-CAP-3; UX-PROFESSORS; ownership:Grupo 07; paths: frontend/src/app/surfaces/ux-professors/

**Acceptance Criteria:**

**Given** I choose Nova on UX-PROFESSORS
**When** I pick an `employeeId` of an existing active Employee and submit via BFF POST
**Then** the Professor is created with stable `id` and no duplicated name/email fields from Employee
**And** inactive or missing Employee yields refusal-banner from problem+json (FR-4 / FR-5 / FR-1a)
**And** UI does not invent a second personal cadastro
**And** create dialog follows compact fullscreen / medium-expanded rules (UX-DR17)
**And** verified at 360 / 768 / 1280

### Story 7.3: Detalhe Professor + AcademicDegree 1–N

As a funcionario,
I want Professor detail with AcademicDegree secondary CRUD,
So that degrees stay under the professor context.

**Refs:** SPEC-frontend FE-CAP-3, FE-CAP-4; UX-PROFESSORS; ownership:Grupo 07; paths: frontend/src/app/surfaces/ux-professors/

**Acceptance Criteria:**

**Given** I open a Professor
**When** `GET /api/v1/professors/{id}` returns the aggregate
**Then** master-detail shows Professor + AcademicDegree 1–N
**And** create/edit/delete Degree uses BFF professor secondary routes
**And** `classes[]` T3 (if embedded) lists semester classes read-only; AcademicAffiliation is not shown here
**And** panels stack below 1280px; compact shows “← Voltar”
**And** destructive actions use confirm-dialog naming the object
**And** responsive ACs hold at 360 / 768 / 1280

### Story 7.4: Editar Professor e estados de recusa

As a funcionario,
I want to update Professor fields and see clear refusals,
So that FR-1a and contract errors are actionable in pt-BR.

**Refs:** SPEC-frontend FE-CAP-3; UX-PROFESSORS; ownership:Grupo 07; paths: frontend/src/app/surfaces/ux-professors/

**Acceptance Criteria:**

**Given** I edit a Professor
**When** BFF PUT/PATCH succeeds or returns problem+json
**Then** success refreshes detail/list
**And** refusals surface via refusal-banner (`role="alert"`) retaining the form
**And** UI never offers Keycloak provisioning or physical delete of Employee via this screen
**And** verified at 360 / 768 / 1280

### Story 7.5: UX-PROFESSOR-VIEW — plano + roster (composição cliente)

As a professor,
I want to read teaching plan + roster for my class,
So that I prepare class without a dedicated BFF read-model.

**Refs:** SPEC-frontend FE-CAP-4; UX-PROFESSOR-VIEW; ownership:Grupo 07; paths: frontend/src/app/surfaces/ux-professor-view/

**Acceptance Criteria:**

**Given** I open Plano+roster (professor view)
**When** the client composes BFF proxy responses
**Then** plan + roster render; roster is never taken from Reservation payloads (FR-31)
**And** dependency 503 shows composition/identity banners without inventing joins (UX-DR15)
**And** verified at 360 / 768 / 1280

## Epic 8: Salas de Aula (Grupo 08 / rooms)

Operadores gerenciam Rooms (+ accessibility-features) e veem turmas T3 do semestre.
**Owner:** Grupo 08 (`rooms`) · **FRs:** FE-CAP-3, FE-CAP-4, FR-SURF-ROOMS, FR-UI-T3 · **UX:** UX-ROOMS · **UX-DRs:** UX-DR7–9, 16–20

### Story 8.1: Lista de Salas responsiva

As a funcionario,
I want to browse Rooms from the BFF,
So that I can manage classroom inventory.

**Refs:** SPEC-frontend FE-CAP-3; UX-ROOMS; ownership:Grupo 08; paths: frontend/src/app/surfaces/ux-rooms/

**Acceptance Criteria:**

**Given** I open Salas de Aula from the menu
**When** `GET /api/v1/rooms` succeeds
**Then** UX-ROOMS shows responsive table/list with capacity visible
**And** page-header/toolbar/empty follow EXPERIENCE
**And** layouts work at 360 / 768 / 1280

### Story 8.2: Criar e editar Room (capacidade obrigatória)

As a funcionario,
I want to create and update Rooms with required capacity,
So that classes can pick a valid default room later.

**Refs:** SPEC-frontend FE-CAP-3; UX-ROOMS; ownership:Grupo 08; paths: frontend/src/app/surfaces/ux-rooms/

**Acceptance Criteria:**

**Given** I choose Nova / Editar on UX-ROOMS
**When** I submit without capacity
**Then** client validation blocks submit with pt-BR field error
**When** I submit a valid Room via BFF
**Then** list/detail refresh with stable `id`
**And** refusals use refusal-banner
**And** dialogs meet UX-DR17 at 360 / 768 / 1280

### Story 8.3: AccessibilityFeature 1–N na Room

As a funcionario,
I want AccessibilityFeature secondary CRUD on Room detail,
So that accessibility is a named list (not free-text dump).

**Refs:** SPEC-frontend FE-CAP-3; UX-ROOMS; ownership:Grupo 08; paths: frontend/src/app/surfaces/ux-rooms/

**Acceptance Criteria:**

**Given** I open a Room
**When** I manage AccessibilityFeatures via BFF secondary routes
**Then** features render as a named accessible list (UX-DR19)
**And** create/edit/delete use confirm-dialog when destructive
**And** master-detail stacks below 1280px; compact shows voltar
**And** verified at 360 / 768 / 1280

### Story 8.4: `classes[]` T3 e recusas na Room

As a funcionario,
I want to see semester classes for the room and clear errors,
So that room usage is visible without local joins.

**Refs:** SPEC-frontend FE-CAP-4; UX-ROOMS; ownership:Grupo 08; paths: frontend/src/app/surfaces/ux-rooms/

**Acceptance Criteria:**

**Given** Room detail includes T3 `classes[]` or composition 503
**When** the UI renders
**Then** classes are read-only when present
**And** 503 shows composition banner without client-side join fallback
**And** write refusals use refusal-banner
**And** verified at 360 / 768 / 1280


## Final Validation (Step 4)

**Status:** PASSED — ready for development (FE rewrite, partição próprio serviço)

### FR coverage (SPEC-frontend)
- FE-CAP-1/2 → Stories 0.2–0.4
- FE-CAP-3 employees → Stories 0.6–0.9; demais superfícies → Epics 1–8
- FE-CAP-4 → Stories 3.4, 4.3–4.5, 5.4, 6.4, 7.1/7.3/7.5, 8.4
- FE-CAP-5 → Stories 1.1–1.4, 2.1–2.2, 3.1–3.3
- FE-CAP-6 → Epic 0 ownership/scaffold + contribution em Refs
- FR-SURF-* → 15/15 superfícies com story dona = ownership travado
- FR-UI-NAV/T3/REFS → Epic 0 + domain epics

### UX-DR coverage
- UX-DR1–7, 16–19 → Epic 0
- UX-DR8–11 → Epic 1 (+ kit 0.5)
- UX-DR12 → Epic 2
- UX-DR13–14 → Epic 3
- UX-DR15, 20 → Epics 4–8 as applicable
- UX-DR17 → every story AC at 360 / 768 / 1280

### Architecture / dependencies
- Starter FE = Story 0.1
- Soft deps: Epic 1 → 2 → 3; Epics 4–8 parallel after Epic 0
- BFF-only; `/lessons/generate`; `/reservations/ocupacao`
- No FE cruzado remaining in titles/owners

### NFR highlights
- NFR-RESP / A11Y / I18N / SESSION / BOUNDARY / STACK embedded in ACs
- NFR-LGPD-2/3 in Stories 3.1 / 3.4
