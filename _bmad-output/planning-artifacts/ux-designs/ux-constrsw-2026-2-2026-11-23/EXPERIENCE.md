---
name: Closed CRAS
status: final
sources:
  - "{planning_artifacts}/../specs/spec-closed-cras/SPEC.md"
  - "{planning_artifacts}/../specs/spec-closed-cras/capability-map.md"
  - "docs/open-api/bff.yaml"
  - "docs/open-api/*.yaml"
  - "backend/oauth/README.md"
  - "backend/oauth/contracts/identity-gateway.yaml"
  - "https://portal.pucrs.br/wp-content/uploads/2025/02/2025_02_18-portal-sobre_a_pucrs-guias_de_comunicacao-01-dna.pdf"
  - "{planning_artifacts}/ux-designs/ux-constrsw-2026-2-2026-08-24/EXPERIENCE.md"
  - "https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp"
updated: 2026-11-24
---

# Closed CRAS — Experience Spine

Companion UX do **SPEC-closed-cras** (CAP-12) e do **SPEC-frontend** (`_bmad-output/specs/spec-frontend/`). UI web única Closed CRAS, ConstrSW PUCRS 2026/2. Identidade visual em `DESIGN.md` (tokens prevalecem sobre tema Material default). Autenticação só via `backend/oauth`; dados só via BFF. Sem Keycloak no browser. Sem chamar os nove serviços de domínio direto do browser.

**Autoridade:** SPEC-frontend vence em partição/stack/contribuição; SPEC-closed-cras vence em FRs de produto; este spine vence em IA, fluxos e microcopy; `DESIGN.md` vence em tokens; Figma `FTSWNiR5rQHXqDizXFJYqp` é composição de referência (spines vencem o mockup).

## Foundation

Form-factor: **uma** SPA web responsiva (compact, medium e expanded; ver Responsive & Platform), desenhada a partir do desktop. Tokens e anatomia: `DESIGN.md`.

**Stack de UI (SPEC Constraints / CAP-12 / AD-8):** Angular **22.x** + **Angular Material** (Material Design 3) + Angular CDK + SCSS + design tokens. Partição de implementação (OQ-1 fechada): Prof. Arruda → UX-LOGIN, UX-HOME, UX-EMPLOYEES; cada grupo → UX do **próprio** serviço. Sem React/Vite/TanStack Query como stack da SPA. Sem `keycloak-js`.

**UI system de implementação:** chrome/dados/forms mapeiam a Angular Material — `mat-toolbar`, `mat-sidenav`, `mat-nav-list`, `mat-table`, `mat-form-field`, `mat-chip` / `mat-chip-set`, `mat-tab-group`, `mat-dialog`, `mat-snack-bar`, `mat-progress-bar` (skeleton). Customização só via tema oficial / tokens SCSS de `DESIGN.md` — sem seletores frágeis em classes internas MDC.

**Autenticação (CAP-11 + Assumptions SPEC):**
1. `POST {oauth}/login` com `multipart/form-data` (`username`, `password`) e credentials.
2. Sucesso `201`: a sessão habilita chamadas à BFF com `Authorization: Bearer <access_token>`; refresh via `POST /refresh`; logout `POST /logout`.
3. Sem mockar Keycloak no browser; sem `keycloak-js`. Cookie httpOnly do oauth/BFF pode coexistir no transporte; a UI usa Bearer nas requests BFF.

**Dados (CAP-10):** proxy + composição T3 da BFF (`docs/open-api/bff.yaml`). `GET /health` da BFF **não** é tela. `GET /api/v1/identidade/me` alimenta a área do usuário no cabeçalho. UI não faz join das nove OpenAPIs de domínio; FR-19/FR-31 = composição **cliente** sobre proxies BFF (sem read-model BFF dedicado).

V1 claro apenas. Sem modo offline. Código Angular vive em `frontend/` (compose sobe a SPA com o envelope lab — AD-7 / OV-9).

## Information Architecture

Língua da UI: **português do Brasil**. Paths/tags do OpenAPI permanecem em inglês no contrato; rótulos principais em português; ids técnicos (`faixaId`, etc.) só como apoio. Traceability CAP ↔ UX: `capability-map.md`.

| ID | Superfície | CAP | Dono | Chega de | Propósito | BFF / OAuth |
|---|---|---|---|---|---|---|
| UX-LOGIN | Login | CAP-11, CAP-12 | Prof. Arruda | URL fria / sessão expirada | Autenticar | `POST {oauth}/login` (+ refresh/logout) |
| UX-HOME | Home / app-shell | CAP-12 | Prof. Arruda | Login ok | Shell + menu; landing autenticada | `GET /api/v1/identidade/me` |
| UX-EMPLOYEES | Funcionários | CAP-1 | Prof. Arruda | Menu | Lista + detalhe + dependents | `/api/v1/employees` |
| UX-PROFESSORS | Professores | CAP-2 | Grupo 07 | Menu | Lista + detalhe + academic-degrees + **Turmas do semestre em curso** (`classes` do GET BFF; `professorId`) | `/api/v1/professors` |
| UX-STUDENTS | Alunos | CAP-3 | Grupo 04 | Menu | Cadastro (Novo aluno) + lista + detalhe + AcademicAffiliation 1–N + **Turmas matriculadas no semestre em curso** (`classes` do GET BFF; `studentIds`) | `/api/v1/students` |
| UX-ROOMS | Salas de Aula | CAP-7, CAP-10 | Grupo 08 | Menu | Lista + detalhe + accessibility-features + **Turmas do semestre** (`classes` T3; `roomId`) | `/api/v1/rooms` |
| UX-RESOURCES | Recursos | CAP-7, CAP-10 | Grupo 06 | Menu | Lista + detalhe + occurrences + **reservations futuras** (T3) | `/api/v1/resources` |
| UX-COURSES | Disciplinas | CAP-4, CAP-10 | Grupo 05 | Menu | Lista + detalhe + bibliographic-references + syllabus-items + **Turmas do semestre** (`classes` T3; `courseId`) | `/api/v1/courses` |
| UX-CLASSES | Turmas | CAP-5 | Grupo 01 | Menu | Lista + detalhe com **2 abas** (Alunos \| Aulas) | `/api/v1/classes` (+ reviews/import) |
| UX-CLASS-ENROLLMENTS | Turma · Alunos matriculados | CAP-5, CAP-3 | Grupo 01 | Detalhe turma | Associa Students **já cadastrados** à Class (`studentIds`); sem criar Student aqui | `/api/v1/classes` + lista students |
| UX-CLASS-LESSONS | Turma · Aulas | CAP-6 | Grupo 02 | Detalhe turma | Lista + **CRUD** de Lesson da turma (gerar/criar/editar/excluir + tópicos) | `/api/v1/lessons` |
| UX-LESSON-RESERVATIONS | Aula · Reservas | CAP-8 | Grupo 03 | Detalhe da aula (a partir da lista de Aulas) | Lista + **CRUD** de Reservation daquela Lesson | `/api/v1/reservations` |
| UX-OCCUPANCY | Ocupação | CAP-10 (FR-29) | Grupo 03 | Menu | Recursos ocupados em **data + faixa**; **não nominativo** de Student | `GET /api/v1/reservations/ocupacao?data=&faixaId=` |
| UX-PROFESSOR-VIEW | Plano + roster | CAP-10 (FR-31) | Grupo 07 | Menu | Leitura composta plano + roster — **cliente** junta courses + classes (sem endpoint BFF dedicado) | proxy `/courses`, `/classes` |
| UX-STUDENT-READ | Minhas aulas | CAP-6 (FR-19) | Grupo 04 | Menu | Sala efetiva / tópico / avaliação + plano — **cliente** junta lessons + `classes` do student (sem endpoint BFF dedicado) | proxy `/lessons`, `/students`, `/courses` |

**Menu hambúrguer (ordem fixa; item ativo marcado; &lt;1024px = folha; Esc fecha):**
1. Funcionários → `/api/v1/employees`
2. Professores → `/api/v1/professors`
3. Alunos → `/api/v1/students` (cadastro + consulta)
4. Salas de Aula → `/api/v1/rooms`
5. Recursos → `/api/v1/resources`
6. Disciplinas → `/api/v1/courses`
7. Turmas → `/api/v1/classes`
8. Ocupação → BFF `ocupacao` (FR-29)
9. Plano + roster → BFF composição (FR-31)
10. Minhas aulas → BFF lessons (FR-19)

**Hierarquia de escrita:** Turma → (Alunos + Lessons CRUD) → Detalhe da Aula → Reservations CRUD. Lessons e Reservations **não** são itens de menu de topo. Ocupação / Plano+roster / Minhas aulas são superfícies de **leitura SPEC** no menu.

Cada contexto de domínio: **lista + detalhe/master-detail** cobrindo POST/PUT/PATCH/DELETE e secundárias 1–N do OpenAPI. **Turma · Alunos:** só associa/desassocia Students existentes. **Turma · Aulas:** CRUD de Lesson. **Aula · Reservas:** CRUD de Reservation da aula aberta.

**Composição BFF T3 (leitura):** o cliente **não** envia `year`/`semester` (fuso America/Sao_Paulo; semestre 1 se mês &lt; agosto, senão 2).

| GET BFF | Campo composto | Vínculo |
|---|---|---|
| `/api/v1/students` (+`/{id}`) | `classes[]` | `studentIds` contém o estudante |
| `/api/v1/professors` (+`/{id}`) | `classes[]` | `professorId` = id do professor |
| `/api/v1/courses` (+`/{id}`) | `classes[]` | `courseId` = id da disciplina |
| `/api/v1/rooms` (+`/{id}`) | `classes[]` | `roomId` = id da sala |
| `/api/v1/resources` (+`/{id}`) | `reservations[]` | reservations futuras do resource |

Array vazio se não houver. Escritas e GET de secundárias (ex. `enrollments`, titulações) **não** trazem `classes`. **AcademicAffiliation / enrollments ≠** `classes[]` do semestre. Falha T3 → 503 + banner, sem recurso pela metade.

**Ocupação:** `GET /api/v1/reservations/ocupacao?data=&faixaId=` devolve itens `{reservationId, professorId, lessonId, resourceId}` (só **recursos** ACTIVE). UI lista esses recursos; não monta grade de salas neste endpoint.

**Gerar aulas:** `POST /api/v1/lessons/generate` (não `/gerar`).

**Fora da UI v1:** `classes/.../reviews` (existe no BFF).

→ Composição: [Figma — Closed CRAS frontend PUCRS](https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp) (25 frames expanded). Referência responsiva compact/medium: [mockups/closed-cras-responsivo.html](mockups/closed-cras-responsivo.html). Plano de frames responsivos no Figma: [.working/figma-frame-map.md](.working/figma-frame-map.md). Spines vencem em conflito com mockups.

## Voice and Tone

Microcopy em pt-BR. Postura de marca (Cuidador / Criador / Cientista; jeito PUCRS) em `DESIGN.md`.

| Do | Don't |
|---|---|
| “Não foi possível entrar. Verifique usuário e senha.” | Enumerar se a conta existe |
| “Identidade indisponível.” | “Keycloak down” / stack trace |
| “Serviço de composição indisponível.” | Toast “Oops!” em inglês |
| “Nenhuma sala cadastrada ainda.” + CTA Nova sala | Empty ilustrado / inglês |
| “Sala efetiva B201” / “Remoto” | “Local: ver turma” |
| Glossário: disciplina, turma, aula, reserva, faixa | pessoa, slot, booking genérico na chrome |

## Component Patterns

Padrões de experiência ↔ Angular Material (CAP-12). Tokens de `DESIGN.md` prevalecem sobre o tema Material default.

| Component | Angular Material | Onde | Regras |
|---|---|---|---|
| app-shell | `mat-toolbar` + layout | Autenticadas | Hambúrguer esq.; Closed CRAS; usuário + **Sair** (`POST /logout` → UX-LOGIN). |
| hamburger-nav | `mat-sidenav` + `mat-nav-list` | Autenticadas | Ordem fixa: Funcionários, Professores, Alunos, Salas de Aula, Recursos, Disciplinas, Turmas, Ocupação, Plano + roster, Minhas aulas. Ativo marcado. Folha &lt;1024px; Esc fecha. |
| page-header | tipografia + `mat-chip` (contexto) | Cada contexto | Título pt-BR da superfície + caption de propósito. |
| login-panel | `mat-form-field` + `mat-button` | UX-LOGIN | Submit → `POST /login`. `201` → Bearer + Home. `401` banner sem enumerar conta. `503`/rede → “Identidade indisponível.” |
| data-table | `mat-table` (+ CDK) | Listas | Linha abre detalhe. Sem infinite scroll. |
| master-detail-panel | layout + `mat-card` opcional | Detalhes | Secundária 1–N só da principal selecionada. |
| class-tabs | `mat-tab-group` | Detalhe turma | Alunos matriculados \| Aulas. (Reservas vivem no detalhe da Aula.) |
| lesson-reservations | `mat-table` + actions | Detalhe aula | Tabela de reservations da Lesson + Nova reserva / editar / cancelar. |
| faixa-picker | `mat-select` / chips | Aulas / reservas / ocupação | Códigos canônicos A–E, F–N, P; sem time picker livre (Constraints SPEC). |
| refusal-banner | `mat-snack-bar` ou banner inline | Escritas / login 401 | `role="alert"`; prosa travada; `code` = id do FR quando o BFF devolver problem+json. |
| identity-banner | banner inline | Login 503; BFF 503 composição | Mensagem institucional, sem nomear microsserviço (`BFF-DEPENDENCY` onde aplicável). |
| confirm-dialog | `mat-dialog` | Destructive | Um por vez; nomeia objeto e efeito. |
| skeleton-block | `mat-progress-bar` / placeholders | Cold load | Chrome visível; corpo skeleton. |

## State Patterns

| Estado | Superfície | Tratamento |
|---|---|---|
| Repouso login | UX-LOGIN | Painel limpo; CTA Entrar. |
| Credencial recusada | UX-LOGIN | Banner no painel; sem enumerar conta. |
| Identidade indisponível | UX-LOGIN | Banner: “Identidade indisponível.” |
| Sessão ok | Shell | Bearer nas requests BFF; refresh conforme oauth. |
| Cold load | Autenticadas | Skeleton no corpo. |
| Empty lista | Contextos | Empty pt-BR + CTA se puder criar. |
| BFF 503 composição | Ex.: lista Alunos | Banner de página: composição indisponível; sem join local. |
| Recusa invariante | Escritas | refusal-banner; formulário retido. |
| Offline | Global | Sem fila local; banner identidade/BFF. |

## Interaction Primitives

- `Tab` / `Shift+Tab` — ordem de leitura.
- `Enter` — submete form; abre linha na tabela.
- `Esc` — fecha dialog e folha do menu; não descarta form sujo sem secondary.
- Foco visível: anel `{colors.ring}`.
- **Banido:** Keycloak / `keycloak-js` no browser; chamar nove OpenAPIs no browser; React/Vite como stack da SPA; drag-and-drop da grade; infinite scroll; time picker livre; Lessons/Reservations no menu de topo; CSS frágil em classes internas MDC.

## Accessibility Floor

- WCAG 2.2 AA.
- `h1` do page-header recebe foco de leitura na mudança de superfície.
- Banners de erro/identidade: `role="alert"`.
- Chip de sala efetiva anuncia código / divergência / remoto.
- AccessibilityFeature como lista nomeada, não checkbox “acessível”.
- Alvos ≥ 24px; célula de tabela inteira clicável.

## Responsive & Platform

Uma única SPA Angular, **responsiva de 360px a 1440px+**. Todas as superfícies do inventário (UX-LOGIN…UX-STUDENT-READ) funcionam em todas as classes; nenhuma tarefa é "só desktop". Classes de janela seguem a nomenclatura M3 (compact / medium / expanded), mantendo o pivô de navegação em **1024px** já decidido neste spine (o M3 padrão usa 840px).

| Classe | Largura | Frames de referência | Navegação | Conteúdo |
|---|---|---|---|---|
| Compact | 360–599px | 360 × 800 | Folha modal (drawer) com scrim; Esc / toque no scrim / item escolhido fecham | 1 coluna; padding `{spacing.page-compact}` |
| Medium | 600–1023px | 768 × 1024 | Folha modal, igual compact | 1 coluna; padding `{spacing.page}` |
| Expanded | ≥ 1024px | 1280 × 800 (vigente) | Drawer fixo `{spacing.sidebar}` | Master-detail em 2 colunas a partir de 1280px; padding `{spacing.page}` |

**Comportamento por componente:**

| Componente | Expanded | Medium | Compact |
|---|---|---|---|
| app-shell | Hambúrguer + marca + caption + nome do usuário + avatar + **Sair** | Igual expanded | Caption e nome do usuário somem; ficam hambúrguer, marca, avatar e **Sair** (nunca escondido em menu) |
| page-header | Título + caption + CTA primário à direita | Igual expanded | Título e caption quebram linha; CTA primário desce para a toolbar |
| toolbar (busca + CTA) | Busca 320px + CTA à direita | Busca fill + CTA à direita | Busca em linha inteira; CTA filled em linha inteira logo abaixo. **Sem FAB** |
| data-table | Todas as colunas a partir de 1280px (entre 1024–1279px, como medium) + `TableRowActions` (Abrir · Editar · Excluir) | Colunas de prioridade baixa ocultas; `TableRowActions` mantidas | Vira **lista**: item de 2 linhas (identificador + 1–2 atributos) e botão "Mais ações" (Editar · Excluir). Toque no item = Abrir. Sem scroll horizontal |
| master-detail-panel | Principal à esquerda, secundária à direita (≥1280px); empilhado entre 1024–1279px | Empilhado: principal, depois secundária | Empilhado; link "← Voltar para {lista}" acima do título; secundária como lista |
| class-tabs | Abas fixas | Abas fixas | Abas roláveis horizontalmente; aba ativa sempre visível |
| chips de contexto (período, sala, vagas) | Uma linha | Quebram linha | Quebram linha |
| formulários / edição | Dialog 560px, 2 colunas quando couber | Dialog 560px, 1 coluna | Dialog em tela cheia, 1 coluna, ações fixas no rodapé |
| confirm-dialog | 400px centrado | 400px centrado | Largura da tela − 48px; botões empilham se não couberem |
| login-panel | Split: painel de marca à esquerda, card à direita | Faixa de marca no topo + card centrado (máx. 440px) | Faixa de marca compacta + card sem elevação em largura total |
| refusal-banner / identity-banner | Linha única com ação à direita | Igual expanded | Texto quebra; ação desce para baixo do texto |
| occupancy-grid / faixa-picker | Grade completa | Grade completa | **Única exceção** ao "sem scroll horizontal": a grade rola na horizontal com a coluna de faixas fixa |

**Regras transversais:**

- Alvo de toque ≥ 48px em compact e medium (o botão visual continua 40dp; a área de toque cresce).
- Mudar de classe não perde estado: filtro, aba ativa, seleção e formulário sujo são preservados.
- A folha de navegação, ao fechar, devolve o foco ao hambúrguer.
- Zoom de 200% em 1280px deve cair no layout medium sem perda de conteúdo (WCAG 1.4.10 Reflow).

## Inspiration & Anti-patterns

- **Levantar:** DNA PUCRS (acolher + clareza + rigor); inventário BFF completo; Turma como hub de Aulas/Reservas; SPA Angular + Material com tokens DESIGN.md (CAP-12).
- **Rejeitado:** identidade “instrumento sem marca PUCRS” do spine 2026-08-24.
- **Rejeitado:** menu com Lessons e Reservations no topo; chrome em inglês.
- **Rejeitado:** Keycloak / keycloak-js no browser; nove OpenAPIs no browser; seletor de microsserviço na UI.
- **Rejeitado:** GET /health como tela; customização Angular Material via seletores MDC frágeis; stack SPA fora de Angular 22 + Material.

## Key Flows

### F1. Marina entra e abre a malha

**Persona:** Marina, professora, precisa ajustar a turma do período.

1. Abre UX-LOGIN (repouso). Informa usuário e senha → `POST /login`.
2. `201`: sessão com Bearer; Home; cabeçalho mostra identidade de `/identidade/me`.
3. Abre hambúrguer → **Turmas** → lista → detalhe.
4. **Climax:** nas abas **Alunos** e **Aulas** opera a turma; abre uma aula para CRUD de **Reservas**; Lessons/Reservations não existem no menu de topo.

**Falha:** `401` → banner sem enumerar conta. `503`/rede → “Identidade indisponível.”

### F2. Helena cadastra funcionário e papel docente

1. Login → **Funcionários** → cria Employee + Dependent.
2. **Professores** → cria Professor sobre Employee existente + AcademicDegree.
3. **Climax:** o papel docente nasce só com Employee endereçável; identidade não é re-digitada no Professor.

### F3. Rafael abre disciplina e turma

1. **Disciplinas** → Course + referências + syllabus-items; lista mostra classes do semestre.
2. **Turmas** → abre Class; gera/CRUD Lessons na aba Aulas; associa alunos na aba Alunos.
3. **Climax:** abre uma Lesson e faz CRUD de Reservation ali — sem Reservation de sala padrão no menu de topo.

### F4. Alunos — composição falha

1. Marina abre **Alunos**.
2. BFF responde `503` na composição T3.
3. **Climax:** banner “Serviço de composição indisponível.”; sem montar lista parcial no browser.

## Open Questions (UX)

| ID | Status | Efeito |
|---|---|---|
| Persistência do Bearer | `[ASSUMPTION]` alinhada ao SPEC | Memória de sessão da SPA (não `localStorage` longo); cookie httpOnly do oauth pode coexistir — implementação no `frontend/` Angular. |
| OQ-1 partição implementação | **Fechada (2026-11-24)** | Prof. Arruda → UX-LOGIN, UX-HOME, UX-EMPLOYEES; cada grupo → UX do próprio serviço (mapa em `spec-frontend/ownership.md`). |
| OQ-PRD-1 | Aberto no SPEC | PRD ainda seed-only para Student; SPEC+este spine+Figma = cadastro UI + associação na turma. |
