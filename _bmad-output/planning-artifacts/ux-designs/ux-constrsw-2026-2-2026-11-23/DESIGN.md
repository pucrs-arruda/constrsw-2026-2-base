---
name: Closed CRAS
description: Identidade visual Closed CRAS — DNA PUCRS + Material Design 3 estrito — ConstrSW 2026/2.
status: final
sources:
  - "docs/open-api/bff.yaml"
  - "docs/open-api/*.yaml"
  - "backend/oauth/README.md"
  - "backend/oauth/contracts/identity-gateway.yaml"
  - "https://portal.pucrs.br/wp-content/uploads/2025/02/2025_02_18-portal-sobre_a_pucrs-guias_de_comunicacao-01-dna.pdf"
  - "https://m3.material.io/"
  - "https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp"
updated: 2026-11-23
figma: https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp
uiSystem: Material Design 3
colors:
  background: '#F5F8FC'
  foreground: '#0A2540'
  muted: '#E8EEF5'
  muted-foreground: '#4A5568'
  primary: '#0066B3'
  primary-foreground: '#FFFFFF'
  primary-container: '#D0E5F4'
  on-primary-container: '#00386B'
  secondary: '#0A2540'
  secondary-foreground: '#FFFFFF'
  secondary-container: '#D6DEE8'
  on-secondary-container: '#0A2540'
  tertiary: '#6DCDF6'
  tertiary-foreground: '#0A2540'
  tertiary-container: '#E5F6FD'
  on-tertiary-container: '#063A55'
  accent: '#6DCDF6'
  accent-foreground: '#0A2540'
  gold: '#C4A035'
  gold-foreground: '#1A1400'
  gold-container: '#F7EBC7'
  on-gold-container: '#4A3A00'
  border: '#C5D0DE'
  outline: '#C5D0DE'
  outline-variant: '#E8EEF5'
  ring: '#0066B3'
  card: '#FFFFFF'
  card-foreground: '#0A2540'
  surface: '#F5F8FC'
  surface-container: '#E4EBF3'
  surface-container-low: '#EEF3F8'
  surface-container-high: '#D8E2EC'
  surface-container-lowest: '#FFFFFF'
  on-surface: '#0A2540'
  on-surface-variant: '#4A5568'
  destructive: '#B1101A'
  destructive-foreground: '#FFFFFF'
  error: '#B1101A'
  on-error: '#FFFFFF'
  error-container: '#FDECEC'
  success: '#1B6B4A'
  success-foreground: '#FFFFFF'
  warning: '#C4A035'
  warning-foreground: '#1A1400'
  occupancy-free: '#E7F3EC'
  occupancy-taken: '#E8EEF5'
  occupancy-exception: '#E5F6FD'
typography:
  display:
    fontFamily: 'Source Sans 3'
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '36px'
  headline:
    fontFamily: 'Source Sans 3'
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '32px'
  title:
    fontFamily: 'Source Sans 3'
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '24px'
  body:
    fontFamily: 'Source Sans 3'
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '20px'
  label:
    fontFamily: 'Source Sans 3'
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '20px'
  caption:
    fontFamily: 'Source Sans 3'
    fontSize: 12px
    fontWeight: '400'
    lineHeight: '16px'
  mono:
    fontFamily: 'Source Code Pro'
    fontSize: 13px
    fontWeight: '500'
    lineHeight: '1.3'
rounded:
  sm: 4px
  md: 8px
  lg: 12px
  full: 20px
spacing:
  '1': 4px
  '2': 8px
  '3': 12px
  '4': 16px
  '5': 24px
  '6': 32px
  '7': 48px
  gutter: 24px
  page: 24px
  sidebar: 280px
components:
  app-shell:
    background: '{colors.surface}'
    foreground: '{colors.on-surface}'
    header-height: 64px
    sidebar-width: '{spacing.sidebar}'
  hamburger-nav:
    item-height: 56px
    icon-size: 24px
    active-background: '{colors.primary-container}'
    active-foreground: '{colors.primary}'
    idle-foreground: '{colors.on-surface}'
  page-header:
    title: '{typography.headline}'
    meta: '{typography.body}'
  button-filled:
    height: 40px
    padding-x: 24px
    radius: '{rounded.full}'
    background: '{colors.primary}'
    foreground: '{colors.primary-foreground}'
    type: '{typography.label}'
  button-outlined:
    height: 40px
    padding-x: 24px
    radius: '{rounded.full}'
    border: '{colors.outline}'
    foreground: '{colors.primary}'
    type: '{typography.label}'
  button-text:
    height: 40px
    padding-x: 12px
    radius: '{rounded.full}'
    foreground: '{colors.primary}'
    type: '{typography.label}'
  button-destructive:
    height: 40px
    background: '{colors.error}'
    foreground: '{colors.on-error}'
    radius: '{rounded.full}'
  text-field-outlined:
    height: 56px
    radius: '{rounded.sm}'
    border: '{colors.outline}'
  data-table:
    header-background: '{colors.surface-container}'
    row-height: 52px
    header-height: 48px
    row-background: '{colors.surface-container-lowest}'
    border: '{colors.outline}'
  table-row-actions:
    height: 40px
    open: '{colors.primary}'
    edit: '{colors.on-surface}'
    delete: '{colors.error}'
    type: '{typography.label}'
  master-detail-panel:
    background: '{colors.surface-container-lowest}'
    radius: '{rounded.lg}'
    border: '{colors.outline}'
  form-field:
    border: '{colors.outline}'
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
    background: '{colors.error-container}'
    foreground: '{colors.error}'
    border: '{colors.error}'
    radius: '{rounded.md}'
  identity-banner:
    background: '{colors.primary-container}'
    foreground: '{colors.primary}'
    border: '{colors.primary}'
    radius: '{rounded.md}'
  empty-state:
    title: '{typography.title}'
    body: '{typography.body}'
  status-pill:
    radius: '{rounded.md}'
    type: '{typography.caption}'
  sala-efetiva-chip:
    default-background: '{colors.surface-container}'
    exception-background: '{colors.accent}'
    exception-foreground: '{colors.accent-foreground}'
    radius: '{rounded.md}'
  flag-avaliacao-mark:
    background: '{colors.warning}'
    foreground: '{colors.warning-foreground}'
  login-panel:
    background: '{colors.surface-container-lowest}'
    radius: '{rounded.lg}'
  class-tabs:
    active-border: '{colors.primary}'
    idle-foreground: '{colors.on-surface-variant}'
  confirm-dialog:
    background: '{colors.surface-container-lowest}'
    radius: '{rounded.lg}'
  skeleton-block:
    background: '{colors.surface-container}'
    radius: '{rounded.sm}'
---

# Closed CRAS — Design Spine

Identidade visual da UI web única Closed CRAS. **UI system: Material Design 3** ([m3.material.io](https://m3.material.io/)), com tokens de marca PUCRS. Comportamento em `EXPERIENCE.md`.

## Brand & Style

Closed CRAS herda a personalidade PUCRS (Cuidador / Criador / Cientista) e a anatomia **estrita** do Material Design 3. O azul institucional `#0066B3` mapeia para M3 **primary**. Accent `#6DCDF6` permanece semântico (sala efetiva), não secondary de marketing.

Nome na chrome: **Closed CRAS** + caption `PUCRS · ConstrSW`. UI em português do Brasil.

## UI system: Material Design 3

Métricas travadas (desktop admin):

| Elemento | Valor |
|---|---|
| App bar | 64dp |
| Nav item | 56dp |
| Ícone nav | 24dp |
| Button filled / outlined / text | **40dp** (único) |
| Text field outlined | 56dp |
| Table header / row | 48dp / 52dp |
| Content padding | 24dp |
| Toolbar → tabela gap | 16dp |

Proibido: botão one-off, altura ≠ 40dp em filled/outlined/text, FAB, nav com ícone 16px, app bar 56 misturado com 64.

## Colors

Roles M3 mapeados nos tokens do frontmatter. Contraste WCAG 2.2 AA. V1 só claro.

| Role | Hex | Uso |
|---|---|---|
| primary | `#0066B3` | CTAs filled, marca, item ativo |
| primary-container | `#D0E5F4` | Mark wrap, nav ativo, headers de painel secundário |
| secondary (navy) | `#0A2540` | Títulos, avatar, chrome denso `[ASSUMPTION]` |
| tertiary / sky | `#6DCDF6` | Faixa sob app bar, chips de contexto, stroke esquerdo em itens secundários |
| gold | `#C4A035` | Só warning / flag de avaliação `[ASSUMPTION]` — **nunca CTA** |
| error | `#B1101A` | Banners de recusa, Excluir, 503 |
| surface hierarchy | `#F5F8FC` → `#EEF3F8` → `#E4EBF3` → `#FFFFFF` | Fundo, toolbar, header de tabela, cards |

Anti-esqueleto: login com painel geométrico + faixa tertiary; zebra + selected nas tabelas; painéis secundários com count chip tertiary; empty states com accent geométrico — não blocos cinza flat.

## Typography

`[ASSUMPTION]` Source Sans 3 no lugar das famílias M3 padrão. Escala: display / headline / title / body / label / caption. Botões = `{typography.label}` (label-large). Mono só para faixa/ids.

## Layout & Spacing

Grade 8dp. Desktop-first. Lista | detalhe ≥1024px. Nav drawer 280px; folha &lt;1024px com scrim. Densidade comfortable.

## Elevation & Depth

Preferir surface containers. Sombras M3 level 1 (app bar) e level 2 (login card, nav sheet). Sem glow.

## Shapes

Text fields `{rounded.sm}` (4). Cards/panels `{rounded.lg}` (12). Buttons M3 `{rounded.full}` (20). Chips `{rounded.md}` (8).

## Components

- **app-shell / app-bar** — 64dp; marca; avatar; **Sair** = text button 40dp.
- **hamburger-nav** — itens 56dp, ícone 24dp, ativo = `primary-container` + barra 4dp.
- **Button/Filled · Outlined · Text · Destructive** — altura **40dp**; padding H 24 (text 12); shape full; label-large. Fill width só quando o parent exige (login).
- **TextField/Outlined** — input 56dp; label above 12 SemiBold.
- **data-table** — row 52; coluna Ações com `TableRowActions` (três text buttons 40dp).
- **table-row-actions** — Abrir (primary) · Editar (on-surface) · Excluir (error). Nunca filled na linha.
- **master-detail-panel** — cards surface; secundária com título + count; Adicionar = Outlined 40dp.
- **login-panel** — split brand primary + card elev-2; Entrar = Filled fill 40dp.
- **class-tabs / banners / chips** — anatomia M3; banners com dot + prosa pt-BR.

Biblioteca Figma: Lib 5 — M3 Buttons; Lib 6 — M3 Metrics; Lib 7 — Paleta PUCRS (chips Tertiary/Gold/Primary/Secondary).

## Do's and Don'ts

| Do | Don't |
|---|---|
| Instances de Button/* com h=40 | Botões redesenhados por tela / h≠40 |
| CTA filled só em primary `#0066B3` | Gold ou error como cor de botão primário |
| M3 navigation drawer metrics | Item ativo = bloco primary sólido aleatório |
| Text buttons na coluna Ações | Filled gigante dentro da tabela |
| Surface hierarchy + faixa tertiary + zebra | Esqueleto cinza flat / cards consumer / purple glow |
| Gold só em warning / «Com avaliação» | Gold em nav, app bar ou CTA |
| Captions de propósito em pt-BR | Path OpenAPI como rótulo principal |
