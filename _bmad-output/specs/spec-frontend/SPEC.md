---
id: SPEC-frontend
companions:
  - surfaces.md
  - ownership.md
  - contribution.md
  - stack.md
  - traceability.md
  - ../../planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md
  - ../../planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md
sources:
  - ../spec-closed-cras/SPEC.md
  - ../spec-closed-cras/capability-map.md
  - ../spec-closed-cras/domain-pairs.md
  - ../spec-bff/SPEC.md
  - ../../planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
  - ../../planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/prd.md
  - ../../planning-artifacts/sprint-change-proposal-2026-11-24.md
  - ../../../docs/open-api/bff.yaml
  - ../../../frontend/README.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability only — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Frontend

## Why

**Mandato + dor.** Nove grupos e o docente precisam entregar, em paralelo, uma única SPA Closed CRAS sem inventar stack, shell ou partição de telas. Sem este contrato, o inventário EXPERIENCE, o CAP-12 do produto e o FR-28 divergem: quem implementa login, quem faz employees e quem pluga a UX do próprio serviço. O frontend é a evidência de jornada (UJ-1–UJ-4) sobre BFF + OAuth — não nove UIs nem join de OpenAPI no browser. É também a **FR-fonte** dos épicos/stories FE e do `bmad-quick-dev` (não o PRD genérico sozinho).

## Capabilities

IDs estáveis `CAP-1`…`CAP-6`. Em épicos/stories cite **`FE-CAP-N`** (= o mesmo `CAP-N` deste kernel) para não colidir com CAPs do `SPEC-closed-cras`. Detalhe: `traceability.md`.

- **CAP-1** (`FE-CAP-1`)
  - **intent:** Operador autentica e encerra sessão só via gateway OAuth; a SPA usa Bearer nas chamadas à BFF.
  - **success:** UX-LOGIN: `POST {oauth}/login` (multipart `username`/`password`); `201` → sessão + UX-HOME; `401` banner sem enumerar conta; `503`/rede → “Identidade indisponível.”; Sair → `POST /logout` → UX-LOGIN; refresh via `POST /refresh`. Sem `keycloak-js` e sem URL do IdP no browser.

- **CAP-2** (`FE-CAP-2`)
  - **intent:** Após login, o operador navega pelo app-shell único (hambúrguer, marca, identidade, Sair) sem escolher microsserviço.
  - **success:** UX-HOME + shell em todas as rotas autenticadas; `GET /api/v1/identidade/me` alimenta o cabeçalho; menu na ordem fixa de `surfaces.md`; item ativo marcado; folha &lt;1024px; Esc fecha. Sessão ausente/expirada → UX-LOGIN.

- **CAP-3** (`FE-CAP-3`)
  - **intent:** Cada superfície de domínio lista e detalha o agregado via BFF (master-detail + secundárias 1–N), na língua do glossário.
  - **success:** Superfícies de `surfaces.md` cobrem POST/PUT/PATCH/DELETE e secundárias do OpenAPI espelhado na BFF; empty pt-BR + CTA quando puder criar; cold load com skeleton; recusa FR → refusal-banner com formulário retido; dados **só** via BFF (`docs/open-api/bff.yaml`).

- **CAP-4** (`FE-CAP-4`)
  - **intent:** Leitura composta do semestre e vistas SPEC aparecem sem o cliente inventar join das nove OpenAPIs de domínio.
  - **success:** GETs T3 de students/professors/courses/rooms exibem `classes` do semestre (cliente **não** envia `year`/`semester`); resources exibem `reservations` futuras; falha T3 → 503 + banner “Serviço de composição indisponível.” sem payload pela metade. UX-OCCUPANCY = `GET /api/v1/reservations/ocupacao`; UX-PROFESSOR-VIEW (FR-31) e UX-STUDENT-READ (FR-19) = composição **cliente** sobre proxies BFF.

- **CAP-5** (`FE-CAP-5`)
  - **intent:** Hierarquia Turma → Aulas → Reservas opera no detalhe, sem Lessons/Reservations no menu de topo.
  - **success:** UX-CLASSES com abas Alunos \| Aulas; UX-CLASS-ENROLLMENTS só associa Students existentes; UX-CLASS-LESSONS faz CRUD de Lesson (`POST /api/v1/lessons/generate` incluso); UX-LESSON-RESERVATIONS faz CRUD de Reservation da aula aberta. Reviews de Class fora da UI v1.

- **CAP-6** (`FE-CAP-6`)
  - **intent:** Prof. Arruda e cada grupo entregam as superfícies do mapa fechado sem ser dono exclusivo da SPA.
  - **success:** Donos = `ownership.md` (**travado 2026-11-24**, próprio serviço — não cruzado): Arruda → UX-LOGIN, UX-HOME, UX-EMPLOYEES; G01 classes → UX-CLASSES, UX-CLASS-ENROLLMENTS; G02 lessons → UX-CLASS-LESSONS; G03 reservations → UX-LESSON-RESERVATIONS, UX-OCCUPANCY; G04 students → UX-STUDENTS, UX-STUDENT-READ; G05 courses → UX-COURSES; G06 resources → UX-RESOURCES; G07 professors → UX-PROFESSORS, UX-PROFESSOR-VIEW; G08 rooms → UX-ROOMS. Checklist `contribution.md`; tokens `DESIGN.md` prevalecem; Figma `FTSWNiR5rQHXqDizXFJYqp` é composição de referência (spines vencem mockup).

## Constraints

- Stack: Angular **22.x** + Angular Material (M3) + CDK + SCSS + design tokens. Sem React/Vite/TanStack como stack da SPA. Detalhe: `stack.md`.
- Código em `frontend/` (Compose sobe a SPA — AD-7 / OV-9). Dados só BFF; autenticação só `backend/oauth`. Sem CORS/chamada direta aos nove contextos.
- UI 100% pt-BR (chrome, forms, empty, banners). Paths OpenAPI em inglês; glossário travado (disciplina, turma, aula, reserva, faixa).
- Tokens e anatomia: companion `DESIGN.md` prevalecem sobre tema Material default. Sem seletores frágeis em classes internas MDC.
- Responsivo 360px–1440px+ (compact / medium / expanded); pivô de nav em **1024px**. Regras: companion EXPERIENCE § Responsive.
- WCAG 2.2 AA; banners `role="alert"`; alvos ≥ 24px (toque ≥ 48px em compact/medium).
- Bearer em memória de sessão (não `localStorage` longo); cookie httpOnly do oauth pode coexistir no transporte.
- Autoridade: este SPEC vence em partição/stack/contribuição; EXPERIENCE vence em IA/fluxos/microcopy; DESIGN vence em tokens; produto closed-cras vence em FRs/invariantes.
- Épicos/stories FE e `bmad-quick-dev` **devem** apontar este SPEC + companions como contrato; cada story carrega `Refs: FE-CAP-N; UX-*; ownership; path frontend/`. Ver `traceability.md` e `contribution.md`.

## Non-goals

- Quatro SPAs, SPA por papel, seletor de microsserviço.
- Frontend cruzado (grupo implementando UX de outro serviço) — supersedido por CAP-6 / ownership.md.
- `keycloak-js` / adapter JS ao IdP; join de nove OpenAPIs no browser.
- UI de `classes/.../reviews`; GET `/health` da BFF como tela.
- Grade de ocupação de **salas** distinta de `reservations/ocupacao` (v1 = recursos por data+faixa).
- Modo offline / fila local; app nativo / totem.
- Implementação dos writers de domínio, BFF ou Keycloak admin (apontar `spec-bff` / OpenAPI do contexto).

## Success signal

No Compose, as quatro personas completam UJ-1–UJ-4 na SPA sem escolher microsserviço (SM-3); shell + employees demonstráveis pelo Prof. Arruda; cada grupo demonstra a UX do próprio serviço (SM-4 / FR-28); falha de login/composição mostra banner institucional sem stack trace; Figma e EXPERIENCE batem com as superfícies de `surfaces.md`; backlog FE cita `FE-CAP-*` + `UX-*` sem ambiguidade com CAPs do produto.

## Assumptions

- Persistência do Bearer = memória de sessão da SPA até decisão contrária.
- Cadastro de Student na UI (UX-STUDENTS) e associação na turma (UX-CLASS-ENROLLMENTS) vencem o PRD seed-only (OQ-PRD-1 aberta no produto).
- Faixas só pelos códigos A–E, F–N, P (sem time picker livre).
- Scaffold Angular + kit compartilhado no Epic 0 (Arruda) são pré-requisito do shell; não alteram o mapa de superfícies de CAP-6.

## Open Questions

- **OQ-PRD-1.** PRD FR-7/FR-9 ainda seed-only vs cadastro UI — dono: produto (closed-cras). Não bloqueia implementação das superfícies deste SPEC.
- ~~**OQ-1.** Partição grupo↔superfície~~ **Fechada (2026-11-24)** — ver `ownership.md` (travada no CC).
