---
name: Closed CRAS
description: Identidade visual da UI web Closed CRAS alinhada ao DNA PUCRS — ConstrSW 2026/2.
status: final
sources:
  - "docs/open-api/bff.yaml"
  - "docs/open-api/*.yaml"
  - "backend/oauth/README.md"
  - "backend/oauth/contracts/identity-gateway.yaml"
  - "https://portal.pucrs.br/wp-content/uploads/2025/02/2025_02_18-portal-sobre_a_pucrs-guias_de_comunicacao-01-dna.pdf"
  - "https://portal.pucrs.br/"
  - "{planning_artifacts}/ux-designs/ux-constrsw-2026-2-2026-08-24/DESIGN.md"
  - "https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp"
updated: 2026-11-23
colors:
  background: '#F5F7FA'
  foreground: '#1A2332'
  muted: '#E8EEF5'
  muted-foreground: '#4A5568'
  primary: '#0066B3'
  primary-foreground: '#FFFFFF'
  accent: '#6DCDF6'
  accent-foreground: '#0A2540'
  border: '#C5D0DE'
  ring: '#0066B3'
  card: '#FFFFFF'
  card-foreground: '#1A2332'
  destructive: '#B1101A'
  destructive-foreground: '#FFFFFF'
  success: '#1B6B4A'
  success-foreground: '#FFFFFF'
  warning: '#8A5A00'
  warning-foreground: '#FFFFFF'
  occupancy-free: '#E7F3EC'
  occupancy-taken: '#E8EEF5'
  occupancy-exception: '#E5F6FD'
typography:
  display:
    fontFamily: 'Source Sans 3'
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: '-0.01em'
  headline:
    fontFamily: 'Source Sans 3'
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.3'
  body:
    fontFamily: 'Source Sans 3'
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label:
    fontFamily: 'Source Sans 3'
    fontSize: 13px
    fontWeight: '600'
    lineHeight: '1.3'
    letterSpacing: '0.01em'
  caption:
    fontFamily: 'Source Sans 3'
    fontSize: 12px
    fontWeight: '400'
    lineHeight: '1.4'
  mono:
    fontFamily: 'Source Code Pro'
    fontSize: 13px
    fontWeight: '500'
    lineHeight: '1.3'
rounded:
  sm: 4px
  md: 6px
  lg: 8px
  full: 9999px
spacing:
  '1': 4px
  '2': 8px
  '3': 12px
  '4': 16px
  '5': 24px
  '6': 32px
  '7': 48px
  gutter: 24px
  page: 32px
  sidebar: 280px
components:
  app-shell:
    background: '{colors.background}'
    foreground: '{colors.foreground}'
    header-height: 56px
    sidebar-width: '{spacing.sidebar}'
  hamburger-nav:
    active-background: '{colors.primary}'
    active-foreground: '{colors.primary-foreground}'
    idle-foreground: '{colors.foreground}'
  page-header:
    title: '{typography.headline}'
    meta: '{typography.caption}'
  button-primary:
    background: '{colors.primary}'
    foreground: '{colors.primary-foreground}'
    radius: '{rounded.md}'
  button-secondary:
    background: '{colors.card}'
    foreground: '{colors.foreground}'
    border: '{colors.border}'
    radius: '{rounded.md}'
  button-destructive:
    background: '{colors.destructive}'
    foreground: '{colors.destructive-foreground}'
    radius: '{rounded.md}'
  data-table:
    header-background: '{colors.muted}'
    row-background: '{colors.card}'
    border: '{colors.border}'
  master-detail-panel:
    background: '{colors.card}'
    radius: '{rounded.lg}'
    border: '{colors.border}'
  form-field:
    border: '{colors.border}'
    radius: '{rounded.sm}'
    focus-ring: '{colors.ring}'
  faixa-picker:
    code: '{typography.mono}'
    selected-background: '{colors.primary}'
    selected-foreground: '{colors.primary-foreground}'
  occupancy-grid:
    free: '{colors.occupancy-free}'
    taken: '{colors.occupancy-taken}'
    exception: '{colors.occupancy-exception}'
    code: '{typography.mono}'
  refusal-banner:
    background: '#FDECEC'
    foreground: '{colors.destructive}'
    border: '{colors.destructive}'
    radius: '{rounded.md}'
  identity-banner:
    background: '#EEF5FB'
    foreground: '{colors.primary}'
    border: '{colors.primary}'
    radius: '{rounded.md}'
  empty-state:
    title: '{typography.headline}'
    body: '{typography.body}'
  status-pill:
    radius: '{rounded.full}'
    type: '{typography.label}'
  sala-efetiva-chip:
    default-background: '{colors.muted}'
    exception-background: '{colors.accent}'
    exception-foreground: '{colors.accent-foreground}'
    radius: '{rounded.full}'
  flag-avaliacao-mark:
    background: '{colors.warning}'
    foreground: '{colors.warning-foreground}'
  login-panel:
    background: '{colors.card}'
    radius: '{rounded.lg}'
    border: '{colors.border}'
  class-tabs:
    active-border: '{colors.primary}'
    idle-foreground: '{colors.muted-foreground}'
  confirm-dialog:
    background: '{colors.card}'
    radius: '{rounded.lg}'
  skeleton-block:
    background: '{colors.muted}'
    radius: '{rounded.sm}'
---

# Closed CRAS — Design Spine

Identidade visual da UI web única Closed CRAS, alinhada ao DNA da marca PUCRS. Comportamento em `EXPERIENCE.md`.

## Brand & Style

Closed CRAS é a malha acadêmica e de recursos da ConstrSW PUCRS 2026/2: registros de quem já existe, oferta do período e o que acontece na aula. A superfície herda a personalidade PUCRS — arquétipos **Cuidador**, **Criador** e **Cientista** (DNA da Marca, ed. 1 / jan 2025): acolhe sem paternalismo, comunica com clareza e propriedade, e trata o conhecimento operacional com rigor.

O **jeito PUCRS** na chrome: acolhedor, cordial, empático, claro, responsável e transparente. Não somos indiferentes, desonestos, negligentes ou crípticos. O produto continua instrumento de operação acadêmica — não portal de marketing nem SIS de mercado — mas **não** se apresenta como “laboratório sem marca”: o azul institucional e o nome **Closed CRAS** convivem com a postura verbal PUCRS.

Nome na chrome: **Closed CRAS**. Glossário de domínio (disciplina, turma, aula, reserva, faixa, sala padrão / sala efetiva) permanece; rótulos da UI em português do Brasil.

## Colors

O DNA PDF **não publica hex**. O portal confirma o **azul** como cor institucional. Tokens abaixo:

- **Primary `{colors.primary}` `#0066B3`** — Pantone 293C do Manual de Identidade Visual PUCRS (azul do logotipo “PUC”). Sustentado pelo azul institucional citado no portal. Ação afirmativa, item de nav ativo, anel de foco.
- **Accent `{colors.accent}` `#6DCDF6`** — Pantone 297C (azul “RS” do logotipo). Uso semântico estreito: **sala efetiva ≠ sala padrão** e célula de ocupação com exceção — não hover genérico.
- **Destructive `{colors.destructive}` `#B1101A`** — `[ASSUMPTION]` tom de recusa alinhado a vermelho heráldico/institucional observado em assets públicos; DNA PDF não define.
- **Background / muted / card** — `[ASSUMPTION]` superfície clara administrativa (papel frio azulado), não cream de consumer. V1 só claro.

Contraste alvo: WCAG 2.2 AA nas combinações de carga (`foreground`/`background`, `primary-foreground`/`primary`, texto de recusa).

## Typography

`[ASSUMPTION]` DNA PDF e portal não nomeiam família tipográfica para produto admin. UI: **Source Sans 3** (display → caption); **Source Code Pro** só para código de faixa, `id` canônico visível e intervalo `[início, fim)`. Mockups Figma podem usar **Inter** como substituto se a família não estiver disponível no arquivo — spines vencem.

- `{typography.display}` — Login e título da Home.
- `{typography.headline}` — page-header e empty states.
- `{typography.body}` — leitura e ajuda.
- `{typography.label}` — rótulos e pills.
- `{typography.mono}` — faixas (A–E, F–N, P); nunca o nome da disciplina.

## Layout & Spacing

Grade de 8px. Desktop-first. Lista | detalhe a partir de 1024px. `{components.app-shell}`: barra 56px com hambúrguer à esquerda, nome Closed CRAS, área do usuário à direita. Nav ≥1024px: painel `{spacing.sidebar}`; &lt;1024px: folha; `Esc` fecha. Um `{components.confirm-dialog}` por vez.

## Elevation & Depth

Hierarquia por borda `{colors.border}` e `{colors.card}` sobre `{colors.background}`. Sombra só em dialog e folha de nav (0 8px 24px / 12% preto). Sem glow de consumer.

## Shapes

`{rounded.sm}` inputs; `{rounded.md}` botões e banners; `{rounded.lg}` painéis e login; `{rounded.full}` pills e chip de sala efetiva.

## Components

- **app-shell** — Barra 56px; hambúrguer; **Closed CRAS**; usuário (nome de `GET /api/v1/identidade/me`) + link **Sair**.
- **hamburger-nav** — Ordem fixa pt-BR: Salas de Aula; Professores; Alunos; Funcionários; Recursos; Disciplinas; Turmas. Ativo = primary. Folha &lt;1024px.
- **page-header** — Headline + caption de contexto em português.
- **button-primary / secondary / destructive** — Altura 36px. Destructive via confirm-dialog.
- **data-table** — Densidade compacta; clique abre detalhe.
- **master-detail-panel** — Principal + secundária 1–N (acessibilidade, titulações, matrículas, dependentes, ocorrências, referências, itens de plano, etc.).
- **form-field** — Rótulo pt-BR; id técnico só como apoio.
- **faixa-picker / occupancy-grid** — Cânone de faixas; exceção usa accent.
- **refusal-banner** — Recusa de invariante / 401 login.
- **identity-banner** — “Identidade indisponível.” (503/rede no login) ou “Serviço de composição indisponível.” (BFF 503).
- **login-panel** — Card 400px; campos Usuário / Senha; CTA Entrar. Pode exibir marca Closed CRAS + menção institucional PUCRS discreta (não hero de marketing).
- **class-tabs** — No detalhe da Turma: Alunos matriculados | Aulas | Reservas.
- **empty-state / status-pill / sala-efetiva-chip / flag-avaliacao-mark / confirm-dialog / skeleton-block** — herdados comportamentalmente do spine anterior; visual com tokens PUCRS.

## Do's and Don'ts

| Do | Don't |
|---|---|
| Tom Cuidador/Criador/Cientista: claro, acolhedor, responsável | Instrumento “sem marca” ou tom lab frio do spine 2026-08-24 |
| Rótulos em português do Brasil | Chrome em inglês (“Employees”, “Rooms”) |
| `{colors.primary}` institucional no shell e CTA | Accent como cor de marca genérica |
| Accent só para sala efetiva divergente | Accent em hover/nav |
| Closed CRAS + postura PUCRS | Marca Malha / SIG* / “Campus AI” |
| Um dialog; densidade de tabela | Cards de consumo, empty ilustrado, Keycloak no browser |
