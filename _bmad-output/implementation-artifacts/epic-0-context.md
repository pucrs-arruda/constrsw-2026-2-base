# Epic 0 Context: Scaffold, autenticação, shell e Funcionários (Prof. Arruda)

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Entregar a baseline compartilhada da SPA Closed CRAS: scaffold Angular 22 + Material com tokens de marca, autenticação só via oauth (Bearer no BFF), app-shell com menu fixo e a superfície de Funcionários (Employee + Dependent). Sem isso, os grupos não têm shell, kit HTTP/UI nem identidade operacional para plugar as demais superfícies em paralelo.

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

- Operador autentica/encerra só pelo gateway oauth; SPA usa `Authorization: Bearer` nas chamadas à BFF. Login: `POST {oauth}/login` multipart (`username`/`password`); `201` → sessão + Home; `401` banner sem enumerar conta; `503`/rede → “Identidade indisponível.”; refresh `POST /refresh`; logout `POST /logout`. Proibido `keycloak-js` e URL do IdP no browser.
- Após login, shell único (hambúrguer, marca Closed CRAS, identidade, Sair) em rotas autenticadas; cabeçalho via `GET /api/v1/identidade/me`; sessão ausente/expirada → Login. Menu de topo (ordem fixa, 10 itens): Funcionários, Professores, Alunos, Salas de Aula, Recursos, Disciplinas, Turmas, Ocupação, Plano + roster, Minhas aulas. Lessons/Reservations fora do menu. `GET /health` da BFF não é tela.
- UX-EMPLOYEES: lista/detalhe via BFF `/api/v1/employees`; Dependent 1–N só no agregado do funcionário; empty pt-BR + CTA; skeleton no cold load; recusas com refusal-banner e formulário retido. Criar/editar Employee (incl. `ativo`); e-mail único → recusa problem+json; criar **não** provisiona Keycloak; sem delete físico na v1. Inativos visíveis e rotulados (consumidores posteriores usam o sinal `ativo`).
- Stack: Angular 22.x + Material M3 + CDK + SCSS + tokens; código em `frontend/`; Compose sobe a SPA (lab ~4200); dados só BFF; UI 100% pt-BR. Responsivo 360–1440px+ (compact/medium/expanded; ACs em 360/768/1280); pivô de nav 1024px; WCAG 2.2 AA; banners `role="alert"`; toque ≥48px em compact/medium. Bearer em memória de sessão (não `localStorage` longo); cookie httpOnly pode coexistir.
- Ownership: Prof. Arruda = LOGIN, HOME, EMPLOYEES (+ scaffold/kit). Mudanças em shell/shared exigem alinhamento com Arruda. Autoridade: SPEC-frontend > EXPERIENCE (fluxos/microcopy) > DESIGN (tokens); produto closed-cras vence FRs de domínio.

## Technical Decisions

- Browser fala só com BFF (dados) e oauth (login/refresh/logout); nunca com os nove OpenAPIs de domínio.
- Origem HTTP de dados: BFF do Compose (tipicamente `localhost:8180`); auth no módulo `backend/oauth`.
- Tema: tokens DESIGN prevalecem (primary `#0066B3`, navy, sky `#6DCDF6`, surfaces, error); v1 light-only; sem seletores frágeis `.mdc-*`; sem FAB / botão one-off fora das métricas M3 (app bar 64dp, nav item 56dp, ícone 24dp, botão 40dp, field 56dp).
- Kit compartilhado: cliente HTTP só na base OpenAPI BFF; 401/503 mapeiam a banners; composição T3 503 → “Serviço de composição indisponível.” sem join parcial no cliente (padrão para epics seguintes).
- Contribuição: superfícies sob `frontend/` (ex. `shell/`, `shared/`, `surfaces/ux-employees/`); registrar rotas no shell; item de menu só se estiver no menu de topo.
- Employee é system-of-record da pessoa institucional; Dependent é composição 0..\*; `id` estável; escrita típica com papel `funcionario`. Professor (epics posteriores) é is-a Employee — cadastro Employee precisa existir antes.

## UX & Interaction Patterns

- Login: painel split (expanded) / faixa de marca + card (medium) / faixa compacta + card full-width (compact). Sucesso navega para Home com sessão Bearer.
- Shell: toolbar com hambúrguer, marca, caption PUCRS·ConstrSW, usuário, Sair. Em compact, caption/nome podem sumir; Sair permanece. &lt;1024px: nav em folha modal (Esc/scrim/item fecham; foco volta ao hambúrguer); ≥1024px: drawer fixo. Item ativo marcado.
- Domínio: page-header + toolbar (busca + CTA); data-table → lista 2 linhas + “Mais ações” em compact; sem scroll horizontal de tabela; master-detail 2 colunas ≥1280, empilhado abaixo com “← Voltar” em compact; dialogs fullscreen com footer sticky em compact; confirm-dialog nomeando o objeto em ações destrutivas.
- Estados: refusal-banner / identity-banner / skeleton-block / empty + CTA; microcopy institucional pt-BR; sem stack traces.

## Cross-Story Dependencies

- Ordem interna: 0.1 scaffold → 0.2 sessão → 0.3 Login → 0.4 shell → 0.5 kit; 0.6–0.9 Funcionários dependem de sessão + shell + kit.
- Epics 1–8 soft-dependem deste épico para app-shell, cliente HTTP BFF, banners/tabela/dialogs e identidade de Employee (`ativo` / `id`) consumida por Professors, Classes e Reservations.
- Partição travada: grupos não implementam LOGIN/HOME/EMPLOYEES; Arruda não entrega UX dos nove serviços.
