---
name: Closed CRAS
status: final
sources:
  - "docs/open-api/bff.yaml"
  - "docs/open-api/*.yaml"
  - "backend/oauth/README.md"
  - "backend/oauth/contracts/identity-gateway.yaml"
  - "https://portal.pucrs.br/wp-content/uploads/2025/02/2025_02_18-portal-sobre_a_pucrs-guias_de_comunicacao-01-dna.pdf"
  - "{planning_artifacts}/ux-designs/ux-constrsw-2026-2-2026-08-24/EXPERIENCE.md"
  - "https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp"
updated: 2026-11-23
---

# Closed CRAS — Experience Spine

UI web única Closed CRAS, ConstrSW PUCRS 2026/2. Identidade visual em `DESIGN.md`. Autenticação só via `backend/oauth`; dados só via BFF. Sem Keycloak no browser. Sem chamar os nove serviços de domínio direto do browser. Sem Angular neste spine.

## Foundation

Form-factor: **uma** UI web desktop-first. Tokens e anatomia: `DESIGN.md`.

**Autenticação (vigente):**
1. `POST {oauth}/login` com `multipart/form-data` (`username`, `password`) e credentials.
2. Sucesso `201`: a sessão habilita chamadas à BFF com `Authorization: Bearer <access_token>`; refresh via `POST /refresh`; logout `POST /logout`.
3. Sem mockar Keycloak no browser; sem `keycloak-js`.

**Dados:** proxy + composição T3 da BFF (`docs/open-api/bff.yaml`). `GET /health` da BFF **não** é tela. `GET /api/v1/identidade/me` alimenta a área do usuário no cabeçalho.

V1 claro apenas. Sem modo offline. Sem implementação Angular neste artefato.

## Information Architecture

Língua da UI: **português do Brasil**. Paths/tags do OpenAPI permanecem em inglês no contrato; rótulos principais em português; ids técnicos (`faixaId`, etc.) só como apoio.

| ID | Superfície | Chega de | Propósito | BFF / OAuth |
|---|---|---|---|---|
| UX-LOGIN | Login | URL fria / sessão expirada | Autenticar | `POST {oauth}/login` (+ refresh/logout) |
| UX-HOME | Home / app-shell | Login ok | Shell + menu; landing autenticada | `GET /api/v1/identidade/me` |
| UX-EMPLOYEES | Funcionários | Menu | Lista + detalhe + dependents | `/api/v1/employees` |
| UX-PROFESSORS | Professores | Menu | Lista + detalhe + academic-degrees | `/api/v1/professors` |
| UX-STUDENTS | Alunos | Menu | Lista (GET com classes do semestre) + detalhe + enrollments | `/api/v1/students` |
| UX-ROOMS | Salas de Aula | Menu | Lista + detalhe + accessibility-features | `/api/v1/rooms` |
| UX-RESOURCES | Recursos | Menu | Lista (GET com reservations futuras) + detalhe + occurrences | `/api/v1/resources` |
| UX-COURSES | Disciplinas | Menu | Lista (GET com classes do semestre) + detalhe + bibliographic-references + syllabus-items | `/api/v1/courses` |
| UX-CLASSES | Turmas | Menu | Lista + detalhe com 3 abas | `/api/v1/classes` (+ reviews/import) |
| UX-CLASS-ENROLLMENTS | Turma · Alunos matriculados | Detalhe turma | Roster / vínculos da turma | composição classes + students |
| UX-CLASS-LESSONS | Turma · Aulas | Detalhe turma | Lessons filtradas pela turma; generate/topics | `/api/v1/lessons` |
| UX-CLASS-RESERVATIONS | Turma · Reservas | Detalhe turma | Reservations ligadas à turma; details/ocupação | `/api/v1/reservations` |

**Menu hambúrguer (ordem fixa; item ativo marcado; &lt;1024px = folha; Esc fecha):**
1. Funcionários → `/api/v1/employees`
2. Professores → `/api/v1/professors`
3. Alunos → `/api/v1/students`
4. Salas de Aula → `/api/v1/rooms`
5. Recursos → `/api/v1/resources`
6. Disciplinas → `/api/v1/courses`
7. Turmas → `/api/v1/classes`

Lessons e Reservations **não** são itens de topo; entram pelo detalhe da Turma.

Cada contexto de topo: **lista + detalhe/master-detail** cobrindo POST/PUT/PATCH/DELETE e secundárias 1–N do OpenAPI referenciado pela BFF.

→ Composição: [Figma — Closed CRAS frontend PUCRS](https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp) (22 frames). Spines vencem em conflito com mockups.

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

| Component | Onde | Regras |
|---|---|---|
| app-shell | Autenticadas | Hambúrguer esq.; Closed CRAS; usuário + **Sair** (`POST /logout` → UX-LOGIN). |
| hamburger-nav | Autenticadas | Ordem fixa: Funcionários, Professores, Alunos, Salas de Aula, Recursos, Disciplinas, Turmas. Ativo marcado. Folha &lt;1024px; Esc fecha. |
| page-header | Cada contexto | Título pt-BR da superfície + caption de propósito. |
| login-panel | UX-LOGIN | Submit → `POST /login`. `201` → Bearer + Home. `401` banner sem enumerar conta. `503`/rede → “Identidade indisponível.” |
| data-table | Listas | Linha abre detalhe. Sem infinite scroll. |
| master-detail-panel | Detalhes | Secundária 1–N só da principal selecionada. |
| class-tabs | Detalhe turma | Alunos matriculados \| Aulas \| Reservas. |
| faixa-picker | Aulas / reservas / ocupação | Códigos canônicos; sem time picker livre. |
| refusal-banner | Escritas / login 401 | `role="alert"`; prosa travada. |
| identity-banner | Login 503; BFF 503 composição | Mensagem institucional, sem nomear microsserviço. |
| confirm-dialog | Destructive | Um por vez; nomeia objeto e efeito. |
| skeleton-block | Cold load | Chrome visível; corpo skeleton. |

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
- **Banido:** Keycloak no browser; chamar nove APIs no browser; drag-and-drop da grade; infinite scroll; time picker livre; Lessons/Reservations no menu de topo.

## Accessibility Floor

- WCAG 2.2 AA.
- `h1` do page-header recebe foco de leitura na mudança de superfície.
- Banners de erro/identidade: `role="alert"`.
- Chip de sala efetiva anuncia código / divergência / remoto.
- AccessibilityFeature como lista nomeada, não checkbox “acessível”.
- Alvos ≥ 24px; célula de tabela inteira clicável.

## Responsive & Platform

| Breakpoint | Comportamento |
|---|---|
| ≥ 1024px | Nav lateral `{spacing.sidebar}`; master-detail duas colunas. |
| &lt; 1024px | Nav em folha; Esc fecha; master-detail empilha. |
| &lt; 768px | Mesmo padrão; cadastro denso não é o recorte de demo no telefone. |

## Inspiration & Anti-patterns

- **Levantar:** DNA PUCRS (acolher + clareza + rigor); inventário BFF completo; Turma como hub de Aulas/Reservas.
- **Rejeitado:** identidade “instrumento sem marca PUCRS” do spine 2026-08-24.
- **Rejeitado:** menu com Lessons e Reservations no topo; chrome em inglês.
- **Rejeitado:** Keycloak / keycloak-js no browser; nove OpenAPIs no browser.
- **Rejeitado:** GET /health como tela; Angular nesta rodada.

## Key Flows

### F1. Marina entra e abre a malha

**Persona:** Marina, professora, precisa ajustar a turma do período.

1. Abre UX-LOGIN (repouso). Informa usuário e senha → `POST /login`.
2. `201`: sessão com Bearer; Home; cabeçalho mostra identidade de `/identidade/me`.
3. Abre hambúrguer → **Turmas** → lista → detalhe.
4. **Climax:** nas abas **Alunos matriculados**, **Aulas** e **Reservas** opera o período sem sair do hub da turma; Lessons/Reservations não existem no menu de topo.

**Falha:** `401` → banner sem enumerar conta. `503`/rede → “Identidade indisponível.”

### F2. Helena cadastra funcionário e papel docente

1. Login → **Funcionários** → cria Employee + Dependent.
2. **Professores** → cria Professor sobre Employee existente + AcademicDegree.
3. **Climax:** o papel docente nasce só com Employee endereçável; identidade não é re-digitada no Professor.

### F3. Rafael abre disciplina e turma

1. **Disciplinas** → Course + referências + syllabus-items; lista mostra classes do semestre.
2. **Turmas** → abre Class; gera Lessons na aba Aulas.
3. **Climax:** oferta do período sem inventar Reservation de sala padrão no topo do menu.

### F4. Alunos — composição falha

1. Marina abre **Alunos**.
2. BFF responde `503` na composição T3.
3. **Climax:** banner “Serviço de composição indisponível.”; sem montar lista parcial no browser.

## Open Questions (UX)

| ID | Status | Efeito |
|---|---|---|
| Persistência do Bearer | `[ASSUMPTION]` | Memória de sessão da SPA (não `localStorage` longo); cookie httpOnly do oauth pode coexistir — implementação no frontend. |
| OQ-1 partição nove grupos | Aberto no PRD | Não bloqueia inventário BFF deste spine. |
