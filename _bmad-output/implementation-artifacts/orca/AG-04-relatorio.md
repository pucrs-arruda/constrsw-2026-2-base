## Relatório de entrega — AG-04 Frontend Fundação

```text
Refs: SPEC-frontend FE-CAP-1, FE-CAP-2, FE-CAP-3, FE-CAP-6; UX-ROOMS; ownership: Grupo 08 (UX-ROOMS) / scaffold provisório para shell, login, home e shared UI (dono oficial: Prof. Arruda); paths: frontend/src/app/surfaces/ux-rooms/**, frontend/src/app/shell/**, frontend/src/app/shared/**, frontend/src/app/auth/**
Contract: _bmad-output/specs/spec-frontend/{SPEC,surfaces,ownership,contribution,stack,traceability}.md
UX: _bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/{EXPERIENCE,DESIGN}.md
OpenAPI: docs/open-api/bff.yaml
```

**Branch / commits:** `frontend/grupo08-feat/base` (rebased sobre `frontend/grupo08` em `d6ee998`, conforme seção 3.1 e Seção 0; HEAD atual: `cd2ced5`)
- `2b221b3` — `feat(frontend): cria projeto Angular 22 com Material M3`
- `85d8e71` — `feat(frontend): tema e tokens do Closed CRAS`
- `d009a7f` — `feat(frontend): Dockerfile e nginx com proxy para oauth e BFF`
- `77e4024` — `feat(frontend): shell com app bar e menu responsivo`
- `5559738` — `feat(frontend): componentes de UI compartilhados`
- `5863936` — `docs(frontend): README`
- `02dddc5` — `fix(frontend): corrige proxy do nginx, ícones, shell compact e restauração de foco`
- `cd2ced5` — `refactor(frontend): reorganiza pastas para shell, shared, auth e surfaces/ux-rooms (Seção 0)`

**Nota de Ownership e Scaffold Provisório (Seção 0.1 / `spec-frontend/ownership.md`):**
- O **Grupo 08 é dono exclusivamente da superfície `UX-ROOMS`** (`src/app/surfaces/ux-rooms/`).
- O scaffold Angular, o shell (`UX-HOME`, app bar, menu lateral), a tela de login (`UX-LOGIN`), `UX-EMPLOYEES` e o kit compartilhado de UI pertencem ao **Prof. Arruda** (Epic 0). Como o Epic 0 ainda não foi entregue em `origin/main` (verificado com `git ls-remote --heads origin`: `refs/heads/main` segue em `d6ee998`), tudo o que foi criado fora de `src/app/surfaces/ux-rooms/` (`src/app/shell/`, `src/app/shared/`, `src/app/auth/`, configurações raiz e estilos base) é **scaffold provisório** para permitir o desenvolvimento e os testes da superfície `UX-ROOMS`, sem reivindicar autoria sobre `UX-LOGIN` ou `UX-HOME`.

**Arquivos alterados:**
- Infraestrutura e configuração raiz (scaffold provisório): `Dockerfile`, `nginx.conf`, `proxy.conf.json`, `.dockerignore`, `README.md`, `angular.json`, `package.json`, `package-lock.json`, `tsconfig.json`, `tsconfig.app.json`, `tsconfig.spec.json`, `public/config.json`, `src/index.html`, `src/main.ts`
- Estilos e tokens (scaffold provisório): `src/styles.scss`, `src/styles/_tokens.scss`, `src/styles/_theme.scss`, `src/styles/_typography.scss`
- App e rotas (scaffold provisório): `src/app/app.config.ts`, `src/app/app.routes.ts`, `src/app/app.component.ts`, `src/app/app.component.html`, `src/app/app.component.scss`, `src/app/app.component.spec.ts`
- Shell (scaffold provisório — `src/app/shell/`): `src/app/shell/nav-items.ts`, `src/app/shell/nav-drawer.component.ts`, `src/app/shell/nav-drawer.component.spec.ts`, `src/app/shell/shell.component.ts`, `src/app/shell/shell.component.spec.ts`, `src/app/shell/login/login.page.ts`, `src/app/shell/home/home.page.ts`, `src/app/shell/placeholder/placeholder.page.ts`
- Auth stubs (scaffold provisório — `src/app/auth/`): `src/app/auth/identity.model.ts`, `src/app/auth/auth.service.ts`, `src/app/auth/auth.guard.ts`, `src/app/auth/auth.interceptor.ts`
- Shared config e UI (scaffold provisório — `src/app/shared/`): `src/app/shared/config/app-config.ts`, `src/app/shared/ui/index.ts`, `src/app/shared/ui/confirm-dialog/confirm-dialog.component.ts`, `src/app/shared/ui/confirm-dialog/confirm-dialog.component.spec.ts`, `src/app/shared/ui/refusal-banner/refusal-banner.component.ts`, `src/app/shared/ui/refusal-banner/refusal-banner.component.spec.ts`, `src/app/shared/ui/error-banner/error-banner.component.ts`, `src/app/shared/ui/error-banner/error-banner.component.spec.ts`, `src/app/shared/ui/empty-state/empty-state.component.ts`, `src/app/shared/ui/empty-state/empty-state.component.spec.ts`, `src/app/shared/ui/skeleton/skeleton.component.ts`, `src/app/shared/ui/skeleton/skeleton.component.spec.ts`
- Superfície `UX-ROOMS` (Grupo 08 — `src/app/surfaces/ux-rooms/`): `src/app/surfaces/ux-rooms/ux-rooms.routes.ts` (exportando `ROOMS_ROUTES`), `src/app/surfaces/ux-rooms/list/rooms-list.page.ts`, `src/app/surfaces/ux-rooms/detail/room-detail.page.ts`

**O que foi feito (incluindo Seção 0 e todas as correções do parecer REV-2):**
- ✅ **1. Projeto Angular 22 e Reorganização Seção 0.2:** Projeto standalone Angular 22.3 com SCSS, Angular Material M3 + CDK, strict mode ligado e localização `pt-BR`. Pastas reorganizadas para `src/app/shell/`, `src/app/shared/` (`ui/`, `http/`, `config/`), `src/app/auth/` e `src/app/surfaces/ux-rooms/` (`data/`, `list/`, `detail/`, `ux-rooms.routes.ts` exportando `ROOMS_ROUTES`). O shell registra `/salas` com um único `loadChildren` apontando para `ROOMS_ROUTES`.
- ✅ **2. Tokens, tema e ícones:** Definidos tokens em `_tokens.scss` (incluindo breakpoints `360–599`, `600–1279` com pivô do drawer em `1024`, e `>= 1280`), tema M3 claro em `_theme.scss` e fontes self-hosted (`@fontsource/source-sans-3`, `@fontsource/source-code-pro`, `@fontsource/material-symbols-outlined`) em `_typography.scss`, aplicando explicitamente `font-family: 'Material Symbols Outlined' !important` e ligaduras (`font-feature-settings: 'liga'`) em `mat-icon`, `.mat-icon`, `.material-icons` e `.material-symbols-outlined`.
- ✅ **3. Config (`APP_CONFIG`):** `public/config.json` com `oauthBaseUrl: "/api/auth"` e `bffBaseUrl: "/api/bff"`, carregado no bootstrap via `provideAppInitializer` com fallback para `DEFAULT_APP_CONFIG`.
- ✅ **4. Dockerfile multi-stage:** Estágio `build` em `node:24-alpine` gerando `public/config.json` a partir dos build args `VITE_OAUTH_BASE_URL` e `VITE_BFF_BASE_URL` e compilando em modo produção; estágio `runtime` em `nginx:alpine` com `curl` instalado e healthcheck configurado.
- ✅ **5. `nginx.conf`:**
  - Proxy reverso com variável preservando path e query string usando `rewrite ^/api/auth/(.*)$ /$1 break; proxy_pass $oauth_upstream;` e `rewrite ^/api/bff/(.*)$ /$1 break; proxy_pass $bff_upstream;`.
  - `/health` com `default_type text/plain; return 200 'ok';`, emitindo um único cabeçalho `Content-Type: text/plain`.
- ✅ **6. `proxy.conf.json`:** Configurado proxy de desenvolvimento na porta `8080` (`angular.json`) redirecionando `/api/auth` → `http://localhost:8181` e `/api/bff` → `http://localhost:8180` com `changeOrigin: false` e `pathRewrite`.
- ✅ **7. Rotas e stubs de páginas:** `/login`, shell com `authGuard`, `/salas` com `loadChildren` → `ROOMS_ROUTES` (`''` → `RoomsListPage`, `':id'` → `RoomDetailPage`) e `/em-breve/:slug`.
- ✅ **8. Stubs de Auth (`src/app/auth/`):** `AuthService`, `authGuard`, `authInterceptor` e `Identity` com as assinaturas exatas da seção 6.6 e linha marcada em `app.config.ts`.
- ✅ **9. Shell responsivo (`src/app/shell/`) e Breakpoints Seção 0.4:**
  - Breakpoints observados no `ShellComponent`: `compact` (`360–599px`), `medium` (`600–1279px`, com pivô do drawer fixo a partir de `1024px`) e `expanded` (`>= 1280px`).
  - Avatar `.user-avatar` com as iniciais do usuário (`userInitials()`) ao lado de `.user-meta` e do botão "Sair".
  - Em modo compacto (`360–599px`), `.brand-caption` e `.user-meta` (e-mail) são ocultados, mantendo hambúrguer, marca, avatar e botão "Sair" visíveis conforme `EXPERIENCE.md:176`.
  - `[disableClose]="true"` no `mat-sidenav` e tratamento centralizado em `closeModalDrawer()` / `@HostListener('document:keydown.escape')` + `(closedStart)` / `(closed)` devolvendo o foco diretamente a `menuButton.nativeElement` ao pressionar `Escape`.
- ✅ **10. UI compartilhada (`src/app/shared/ui/`):** `ConfirmDialogComponent`, `RefusalBannerComponent`, `ErrorBannerComponent`, `EmptyStateComponent` e `SkeletonComponent` com entradas/saídas da seção 6.8 e atributos de acessibilidade.
- ✅ **11. Lint/format:** Mantida configuração padrão do Angular CLI 22 (Prettier).
- ✅ **12. `README.md`:** Documentados nota explícita de scaffold provisório (Seção 0.1), árvore de pastas atualizada (`shell/`, `shared/`, `auth/`, `surfaces/ux-rooms/`), requisitos de versão do Node.js (`^22.22.3 || ^24.15.0 || >=26.0.0`) e preservadas as referências ao pacote SPEC e à galeria de mockups (`frontend/mockups/`).

**Verificação:**
1. **Verificação de `git ls-remote --heads origin` (Seção 0.1):**
```text
d9393005521916143c699c68af041033423c7e8c	refs/heads/frontend/grupo05
d6ee998d39db752a9a99f12993e1732f67bd58b6	refs/heads/frontend/grupo08
cd2ced5...                              	refs/heads/frontend/grupo08-feat/base
d6ee998d39db752a9a99f12993e1732f67bd58b6	refs/heads/main
```
(`origin/main` continua em `d6ee998`, sem scaffold do Prof. Arruda ainda.)

2. **Build de produção (`npx ng build --configuration production` em `node:24-alpine`):**
```text
Initial chunk files | Names            |  Raw size | Estimated transfer size
main-WIPAHJQP.js    | main             | 279.32 kB |                76.30 kB
styles-7ZLJ3EHH.css | styles           |  31.99 kB |                 3.84 kB
                    | Initial total    | 311.31 kB |                80.14 kB
Lazy chunk files    | Names            |  Raw size | Estimated transfer size
chunk-BCXkoigW.js   | shell-component  |  89.10 kB |                16.80 kB
chunk-DXLCRhZ7.js   | -                |  73.18 kB |                13.63 kB
chunk-DA6BO4Uu.js   | browser          |  69.25 kB |                17.90 kB
chunk-DdSNjKxI.js   | placeholder-page |   1.30 kB |               723 bytes
chunk-B4oGfRfy.js   | rooms-list-page  | 309 bytes |               309 bytes
chunk-Vl804KyH.js   | room-detail-page | 302 bytes |               302 bytes
chunk-D74lw030.js   | login-page       | 292 bytes |               292 bytes
chunk-DpHLjn1e.js   | ux-rooms-routes  | 239 bytes |               239 bytes
Application bundle generation complete. [4.697 seconds]
```

3. **Testes unitários (`npx ng test --watch=false` em `node:24-alpine`, incluindo teste de viewport nas larguras 360px, 768px e 1280px):**
```text
 RUN  v5.1.1 /app
 ✓  frontend  src/app/shared/ui/skeleton/skeleton.component.spec.ts (5 tests) 265ms
 ✓  frontend  src/app/shared/ui/refusal-banner/refusal-banner.component.spec.ts (2 tests) 233ms
 ✓  frontend  src/app/app.component.spec.ts (2 tests) 29ms
 ✓  frontend  src/app/shared/ui/empty-state/empty-state.component.spec.ts (3 tests) 372ms
 ✓  frontend  src/app/shared/ui/error-banner/error-banner.component.spec.ts (3 tests) 354ms
 ✓  frontend  src/app/shared/ui/confirm-dialog/confirm-dialog.component.spec.ts (4 tests) 403ms
 ✓  frontend  src/app/shell/nav-drawer.component.spec.ts (3 tests) 476ms
 ✓  frontend  src/app/shell/shell.component.spec.ts (7 tests) 892ms

 Test Files  8 passed (8)
      Tests  29 passed (29)
```

4. **Verificação da imagem de produção (`frontend-check`) com `/health`, `/salas` e probes nos upstreams `oauth` e `api`:**
```text
$ curl.exe -isS http://localhost:18080/health
HTTP/1.1 200 OK
Server: nginx/1.31.10
Content-Type: text/plain
Content-Length: 2

ok

$ curl.exe -fsS -X POST http://localhost:18080/api/auth/login
{"service":"oauth","method":"POST","url":"/login"}

$ curl.exe -fsS "http://localhost:18080/api/bff/api/v1/rooms?capacity=%7Bgteq%7D40&name=%7Blike%7D%25lab%25"
{"service":"bff","method":"GET","url":"/api/v1/rooms?capacity=%7Bgteq%7D40&name=%7Blike%7D%25lab%25"}
```

**Critérios de aceite:**
- [x] `ng build` e `ng test` passam — ✅ 29 testes passando em 8 suítes (incluindo verificação das larguras 360px, 768px e 1280px).
- [x] `docker build` passa; `/health` 200 com único `Content-Type: text/plain`; `/salas` devolve o `index.html`; proxy do nginx preserva path e query string — ✅ Verificado.
- [x] Tema com tokens do DESIGN.md; fontes sem CDN externo e `Material Symbols Outlined` aplicada aos ícones — ✅ Verificado.
- [x] Shell responsivo nos 3 breakpoints (`360–599`, `600–1279` com drawer fixo a partir de `1024`, `>= 1280`), menu com 10 itens na ordem certa, Esc fecha o drawer modal e devolve `document.activeElement` ao botão de menu — ✅ Verificado.
- [x] Estrutura de pastas reorganizada conforme Seção 0.2 (`shell/`, `shared/`, `auth/`, `surfaces/ux-rooms/` com `ux-rooms.routes.ts` exportando `ROOMS_ROUTES` via `loadChildren`) e nota de scaffold provisório no README e no relatório — ✅ Conferido.
- [x] `ng serve` na 8080 com proxy funcionando — ✅ Configurado em `angular.json` e `proxy.conf.json`.

**Pedidos fora do escopo:** nenhum
**Dúvidas / contradições encontradas:** nenhuma
**Riscos conhecidos que ficaram:** nenhum
