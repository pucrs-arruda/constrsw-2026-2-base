# Deferred work

- source_spec: `_bmad-output/implementation-artifacts/spec-0-1-scaffold-angular-22-material-tema-design.md`
  summary: Compose `frontend` still `depends_on` healthy oauth + bff even though Story 0.1 serves a static blank SPA
  evidence: Pre-existing compose envelope; scaffold image is nginx-only and does not call oauth/BFF, but changing depends_on was out of the minimal wire for port/health
- source_spec: none
  summary: Story 0.3 UX-LOGIN responsivo
  evidence: Split from Epic 0 quick-dev; deferred after choosing Story 0.2 first
- source_spec: none
  summary: Story 0.4 UX-HOME app-shell e navegação
  evidence: Split from Epic 0 quick-dev; depends on 0.2/0.3 session+login
- source_spec: none
  summary: Story 0.5 Kit compartilhado (tabela/lista, dialogs, banners, HTTP BFF)
  evidence: Split from Epic 0 quick-dev; after shell baseline
- source_spec: none
  summary: Story 0.6 Lista de Funcionários responsiva
  evidence: Split from Epic 0 quick-dev; needs shell+kit
- source_spec: none
  summary: Story 0.7 Detalhe Employee + Dependent 1–N
  evidence: Split from Epic 0 quick-dev; after employees list
- source_spec: none
  summary: Story 0.8 Criar e editar Employee (ciclo de vida)
  evidence: Split from Epic 0 quick-dev; after employee detail
- source_spec: none
  summary: Story 0.9 Estados de recusa e Employee inativo na UI
  evidence: Split from Epic 0 quick-dev; after create/edit employee

- source_spec: `_bmad-output/implementation-artifacts/spec-0-2-sessao-oauth-bearer-para-o-bff.md`
  summary: BFF may still accept httpOnly session cookie when SPA memory Bearer is cleared
  evidence: Adversarial review — oauth cookie Path=/ is sent on /api; BFF bearerTokenOf can fall back to cookie
- source_spec: `_bmad-output/implementation-artifacts/spec-0-2-sessao-oauth-bearer-para-o-bff.md`
  summary: No boot-time refresh/rehydrate when access token memory is empty but refresh cookie remains
  evidence: Edge/adversarial review — F5 drops in-memory token; Story 0.3/0.4 should own session restore UX
- source_spec: `_bmad-output/implementation-artifacts/spec-0-2-sessao-oauth-bearer-para-o-bff.md`
  summary: expires_in unused; no proactive refresh before access token expiry
  evidence: Adversarial review — out of Story 0.2 minimal session API scope
- source_spec: `_bmad-output/implementation-artifacts/spec-0-2-sessao-oauth-bearer-para-o-bff.md`
  summary: nginx/proxy upstream ports hardcoded (8088/3001, 8181/8180)
  evidence: Adversarial review — Ask First if lab ports diverge from defaults
- source_spec: `_bmad-output/implementation-artifacts/spec-0-2-sessao-oauth-bearer-para-o-bff.md`
  summary: AuthSession exposes getters only; no signal/observable for UI binding
  evidence: Adversarial review — Story 0.3 login UI can introduce reactive session state

- source_spec: `_bmad-output/implementation-artifacts/spec-0-3-ux-login-responsivo.md`
  summary: Boot refresh is one-shot per SPA load; transient network failure blocks restore until full reload
  evidence: Edge/adversarial review — SessionBootstrap.bootStarted stays true after failed refresh by design of “one boot refresh”

- source_spec: `_bmad-output/implementation-artifacts/spec-0-3-ux-login-responsivo.md`
  summary: No returnUrl / deep-link restore after login; always lands on HOME stub `/`
  evidence: Adversarial review — authGuard drops original path; out of Story 0.3 stub scope

- source_spec: `_bmad-output/implementation-artifacts/spec-0-3-ux-login-responsivo.md`
  summary: App toolbar chrome still visible on UX-LOGIN alongside login-panel brand strip
  evidence: Adversarial review — EXPERIENCE login-panel is its own surface; hiding global chrome deferred to Story 0.4 shell work

- source_spec: `_bmad-output/implementation-artifacts/spec-0-4-ux-home-app-shell-e-navegacao.md`
  summary: routerLinkActive uses exact:true — nested routes (e.g. /funcionarios/:id) will not mark parent nav item
  evidence: Adversarial review — acceptable until employees detail routes exist in later stories

- source_spec: `_bmad-output/implementation-artifacts/spec-0-4-ux-home-app-shell-e-navegacao.md`
  summary: No skip-link to #conteudo-principal; after modal nav item click focus returns to hamburger
  evidence: Adversarial review — WCAG polish beyond Story 0.4 minimal shell

- source_spec: `_bmad-output/implementation-artifacts/spec-0-4-ux-home-app-shell-e-navegacao.md`
  summary: No timeout/loading state if identidade/me or logout HTTP hangs without emit
  evidence: Edge review — HttpClient normally completes; hang UX deferred

- source_spec: `_bmad-output/implementation-artifacts/spec-0-5-kit-compartilhado-tabela-lista-dialogs-banners-http-bff.md`
  summary: Edit/confirm dialogs do not re-apply fullscreen/stack classes when viewport crosses 600px while open
  evidence: Adversarial review — panelClass fixed at open time

- source_spec: `_bmad-output/implementation-artifacts/spec-0-5-kit-compartilhado-tabela-lista-dialogs-banners-http-bff.md`
  summary: AlertBanner has no right-side action slot (EXPERIENCE “ação à direita”)
  evidence: Adversarial review — text-only banner sufficient for 0.5; CTA slot later if needed

- source_spec: `_bmad-output/implementation-artifacts/spec-0-5-kit-compartilhado-tabela-lista-dialogs-banners-http-bff.md`
  summary: mapBffHttpError 401 always returns refusal bannerKind (no session-clear-only option)
  evidence: Edge review — callers that only clear session can ignore bannerKind

- source_spec: `_bmad-output/implementation-artifacts/spec-0-6-lista-de-funcionarios-responsiva.md`
  summary: Employees list uses parallel me()+list() without switchMap; create stubs lack Voltar CTA
  evidence: Adversarial review 0.6 — polish for reload races and stub UX

- source_spec: `_bmad-output/implementation-artifacts/spec-0-7-detalhe-employee-dependent-1-n.md`
  summary: Falha de identidade/me (incl. 401) só desliga canWrite; não limpa sessão nem redireciona — mesmo padrão da lista 0.6
  evidence: Adversarial/edge review 0.7 — alinhado a employees-list-page; unificar auth em story de sessão

- source_spec: `_bmad-output/implementation-artifacts/spec-0-7-detalhe-employee-dependent-1-n.md`
  summary: IDs de employee/dependent sem encodeURIComponent nos path segments do EmployeesApi
  evidence: Edge review 0.7 — UUIDs atuais ok; reforçar se IDs opacos ganharem caracteres reservados

- source_spec: `_bmad-output/implementation-artifacts/spec-0-7-detalhe-employee-dependent-1-n.md`
  summary: Sem suite dedicada dependent-form-dialog.spec (validação/refusal/401 no write do dialog)
  evidence: Adversarial review 0.7 — cobertura parcial via page + api specs; expandir depois

- source_spec: `_bmad-output/implementation-artifacts/spec-0-8-criar-e-editar-employee-ciclo-de-vida.md`
  summary: Sinal canWriteDependents no detalhe também gateia Editar funcionário (mesma role funcionario)
  evidence: Adversarial review 0.8 — renomear para canWriteEmployee quando papéis divergirem

- source_spec: `_bmad-output/implementation-artifacts/spec-0-8-criar-e-editar-employee-ciclo-de-vida.md`
  summary: Sem timeout no save do EmployeeFormDialog; hang deixa disableClose ativo
  evidence: Edge review 0.8 — padrão compartilhado de writes; tratar no kit se recorrente

- source_spec: `_bmad-output/implementation-artifacts/spec-0-9-estados-de-recusa-e-employee-inativo-na-ui.md`
  summary: problem+json `errors[]` (400 validation) ainda não entra no banner — só detail/title/code
  evidence: Adversarial review 0.9 — mapear field errors no formulário quando UX pedir

- source_spec: `_bmad-output/implementation-artifacts/spec-0-9-estados-de-recusa-e-employee-inativo-na-ui.md`
  summary: Banner identity em falha isolada de identidade/me (503) não foi ligado nas páginas employees
  evidence: Adversarial review 0.9 — evita esconder master; unificar em story de sessão/shell

- source_spec: `_bmad-output/implementation-artifacts/spec-bff-employees-proxy.md`
  summary: Contract tests for employees proxy use bare createNestApplication without bootstrap configureApp (CORS/bodyParser)
  evidence: Review of employees proxy — same pattern as rooms; browser cookie/CORS not exercised in unit contract layer

- source_spec: `_bmad-output/implementation-artifacts/spec-bff-employees-proxy.md`
  summary: Full Playwright UX-EMPLOYEES suite green proof after removing BFF bridge was not re-run in this story
  evidence: Spec Ask First limited live e2e beyond contract; smoke via curl/BFF + 9 contract tests covered the ship gate
