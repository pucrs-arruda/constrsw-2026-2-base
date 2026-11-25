# Epic 0 Context: Scaffold, autenticação, shell e Funcionários (Prof. Arruda)

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Entregar a baseline compartilhada da SPA Closed CRAS: scaffold Angular 22 + Material com tokens de marca, autenticação só via oauth (Bearer no BFF), app-shell único com menu fixo, kit UI/HTTP reutilizável, e a superfície de Funcionários (lista/detalhe + dependents). Isso desbloqueia os grupos 01–08 para plugar as UXs do próprio serviço sem inventar stack, shell ou tema.

## Stories

- Story 0.1: Scaffold Angular 22 + Material + tema DESIGN
- Story 0.2: Sessão oauth Bearer para o BFF
- Story 0.3: UX-LOGIN responsivo
- Story 0.4: UX-HOME app-shell e navegação
- Story 0.5: Kit compartilhado (tabela/lista, dialogs, banners, HTTP BFF)
- Story 0.6: Lista de Funcionários responsiva
- Story 0.7: Detalhe Employee + Dependent 1–N
- Story 0.8: Criar e editar Employee (ciclo de vida)
- Story 0.9: Estados de recusa e Employee inativo na UI

## Requirements & Constraints

- Operador autentica/encerra só pelo gateway oauth; SPA envia `Authorization: Bearer` às chamadas BFF. Login multipart (`username`/`password`); 201 → sessão + Home; 401 → banner sem enumerar conta; 503/rede → “Identidade indisponível.”; refresh/logout nos endpoints oauth. Sem `keycloak-js` e sem URL do IdP no browser.
- Após login, shell único (hambúrguer, marca Closed CRAS, identidade via `GET /api/v1/identidade/me`, Sair) em rotas autenticadas; sessão ausente/expirada → Login. Menu de topo com 10 itens em ordem fixa; Lessons/Reservations fora do topo; `/health` da BFF não é tela.
- UX-EMPLOYEES: master-detail via BFF (`/api/v1/employees`) — lista, detalhe, CRUD de Employee e Dependent aninhados. Empty pt-BR + CTA; skeleton no cold load; refusal-banner com formulário retido em recusas (ex. e-mail duplicado / problem+json). Criar Employee não provisiona Keycloak; sem delete físico na v1; `ativo=false` permitido e visível (rotulado) para consumidores posteriores. Escrita de employees só com papel `funcionario`.
- Stack: Angular 22.x + Material M3 + CDK + SCSS + tokens; código em `frontend/`; lab na porta 4200; Compose sobe a SPA. Dados só BFF; auth só oauth. UI 100% pt-BR; paths OpenAPI em inglês. Responsivo 360–1440px+ (compact/medium/expanded); pivô de nav 1024px; ACs em 360/768/1280; sem desktop-only. WCAG 2.2 AA; banners `role="alert"`; alvos ≥24px (toque ≥48px em compact/medium). Bearer em memória de sessão (não `localStorage` longo); cookie httpOnly do oauth pode coexistir.
- Ownership travado: Prof. Arruda = LOGIN, HOME, EMPLOYEES (+ scaffold/kit); grupos não alteram shell/shared sem coordenação. Autoridade: SPEC-frontend > EXPERIENCE (fluxos/microcopy) > DESIGN (tokens) > Figma.

## Technical Decisions

- Uma SPA; browser fala só com BFF + oauth — nunca com os nove OpenAPIs de domínio.
- Tema Material sobrescrito por tokens DESIGN (primary `#0066B3`, navy/secondary, sky/tertiary `#6DCDF6`, surfaces, error `#B1101A`; tipografia Source Sans 3; v1 light-only). Sem seletores frágeis `.mdc-*`.
- Chrome Material: toolbar, sidenav, nav-list, table, form-field, chip, tab-group, dialog, snack-bar, progress-bar. Métricas M3: app bar 64dp, nav 56dp, ícone 24dp, botões 40dp, field 56dp; sem FAB.
- HTTP client compartilhado: base BFF OpenAPI; 401/503 mapeiam a banners; falha T3 → “Serviço de composição indisponível.” sem join local (kit já prevê o padrão para épicos posteriores).
- Pastas: shell em `frontend/src/app/shell/`; employees em `frontend/src/app/surfaces/ux-employees/`; primitivos em `frontend/src/app/shared/`. Stories FE carregam bloco Refs (capacidade FE + superfície UX + ownership + path).
- Employee é identidade de quem trabalha; Dependent é composição 0..*; `id` estável UUID; `ativo` é sinal de leitura para alocação/Professor (enforcement nos consumidores, não na UI de employees além de rotular inativos).

## UX & Interaction Patterns

- Login-panel: split (expanded) / faixa de marca + card (medium) / full-width compact; CTA Entrar.
- App-shell: hambúrguer esq.; marca; caption PUCRS·ConstrSW; usuário; Sair. Nav: folha modal &lt;1024 (Esc/scrim/item fecham; foco volta ao hambúrguer); drawer fixo ≥1024; item ativo marcado. Ordem do menu: Funcionários, Professores, Alunos, Salas de Aula, Recursos, Disciplinas, Turmas, Ocupação, Plano + roster, Minhas aulas.
- Listagens: page-header + toolbar (busca + CTA); data-table em expanded/medium; em compact → lista 2 linhas + “Mais ações” (sem scroll horizontal). Master-detail: 2 colunas ≥1280; empilhado abaixo; “← Voltar para {lista}” em compact. Dialogs de edição fullscreen com footer sticky em compact; confirm-dialog nomeia o objeto em ações destrutivas.
- State patterns: skeleton, empty + CTA, refusal-banner, identity-banner; microcopy institucional pt-BR.

## Cross-Story Dependencies

- 0.1 → 0.2–0.5 (scaffold/tema antes de sessão, shell e kit).
- 0.2 → 0.3–0.4 (Bearer/sessão antes de Login/Home usáveis).
- 0.4 + 0.5 → 0.6–0.9 (shell + kit antes da superfície employees).
- 0.6 → 0.7 → 0.8–0.9 (lista → detalhe/dependents → ciclo de vida e estados de recusa).
- Soft out: Epics 1–8 dependem deste baseline (shell, tema, HTTP, banners); `ativo` de Employee alimenta recusas em Professors/Classes/Reservations nos épicos seguintes.
