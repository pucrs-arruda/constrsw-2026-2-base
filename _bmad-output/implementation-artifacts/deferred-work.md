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
