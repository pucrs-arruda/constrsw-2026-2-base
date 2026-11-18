---
name: Closed CRAS
description: Identidade visual da UI web única da ConstrSW PUCRS 2026/2 — instrumento administrativo de registros e alocação, não portal de mercado.
status: final
sources:
  - "{planning_artifacts}/prds/prd-constrsw-2026-2-2026-08-19/prd.md"
  - "{planning_artifacts}/prds/prd-constrsw-2026-2-2026-08-19/addendum.md"
  - "{planning_artifacts}/briefs/brief-constrsw-2026-2-2026-08-17/brief.md"
  - "{planning_artifacts}/research/domain-university-academic-and-resource-management-research-2026-08-17.md"
  - "backend/oauth/README.md"
updated: 2026-11-16
colors:
  background: '#F4F1EC'
  foreground: '#1A1F24'
  muted: '#E8E4DC'
  muted-foreground: '#3F3B36'
  primary: '#1E3A5F'
  primary-foreground: '#FFFFFF'
  accent: '#C45C26'
  accent-foreground: '#FFFFFF'
  border: '#D4CFC5'
  ring: '#1E3A5F'
  card: '#FFFCF7'
  card-foreground: '#1A1F24'
  destructive: '#B42318'
  destructive-foreground: '#FFFFFF'
  success: '#176B4A'
  success-foreground: '#FFFFFF'
  warning: '#8A5A00'
  warning-foreground: '#FFFFFF'
  occupancy-free: '#E7F0EA'
  occupancy-taken: '#E8E4DC'
  occupancy-exception: '#F8E6D9'
typography:
  display:
    fontFamily: 'IBM Plex Sans'
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: '-0.02em'
  headline:
    fontFamily: 'IBM Plex Sans'
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.3'
  body:
    fontFamily: 'IBM Plex Sans'
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label:
    fontFamily: 'IBM Plex Sans'
    fontSize: 13px
    fontWeight: '500'
    lineHeight: '1.3'
    letterSpacing: '0.02em'
  caption:
    fontFamily: 'IBM Plex Sans'
    fontSize: 12px
    fontWeight: '400'
    lineHeight: '1.4'
  mono:
    fontFamily: 'IBM Plex Mono'
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
  sidebar: 260px
components:
  app-shell:
    background: '{colors.background}'
    foreground: '{colors.foreground}'
    sidebar-width: '{spacing.sidebar}'
  role-nav:
    active-background: '{colors.primary}'
    active-foreground: '{colors.primary-foreground}'
    idle-foreground: '{colors.muted-foreground}'
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
  journey-card:
    background: '{colors.card}'
    radius: '{rounded.lg}'
    border: '{colors.border}'
  confirm-dialog:
    background: '{colors.card}'
    radius: '{rounded.lg}'
  skeleton-block:
    background: '{colors.muted}'
    radius: '{rounded.sm}'
---

# Closed CRAS — Design Spine

Identidade visual da UI web única. Mecanismo e stack ficam no addendum do PRD; este spine não nomeia biblioteca de componentes nem provedor de identidade. `EXPERIENCE.md` descreve o comportamento.

`[ASSUMPTION]` Paleta, tipo e raios abaixo — o PRD não fixa marca visual. Postura: instrumento de laboratório, não launch.

## Brand & Style

Closed CRAS é a malha acadêmica e de recursos desta ConstrSW: registros de quem já existe, oferta do período com **sala padrão** nas **faixas** da grade, e o que acontece nesta **aula**. A superfície parece um instrumento de operação — papel, tinta, uma cor de exceção — não um SIS de mercado, não um portal institucional PUCRS, não um app de consumo.

A língua visível é a do Glossário do PRD. Código de **faixa** (A–E, F–N, P) usa mono; o restante, sans humanista. `{colors.accent}` existe para um único significado: **sala efetiva ≠ sala padrão** (e a célula de ocupação correspondente). Não é cor de marca, não é hover, não é “destaque genérico”.

Nome na chrome: **Closed CRAS**. Não Malha, não `SIG*`, não “Campus AI”, não marca PUCRS como produto.

## Colors

Contraste alvo: WCAG 2.2 AA. Combinações de carga: `{colors.foreground}` sobre `{colors.background}` (≥ 12:1); `{colors.primary-foreground}` sobre `{colors.primary}` (≥ 8:1); `{colors.muted-foreground}` sobre `{colors.background}` (≥ 7:1); `{colors.accent-foreground}` sobre `{colors.accent}` (≥ 4.5:1); `{colors.destructive}` sobre `{colors.background}` para texto de recusa (≥ 4.5:1).

- **Background (`{colors.background}`)** — papel de trabalho. Nunca puro `#FFFFFF` em canvas cheio; o branco quente `{colors.card}` é só para painéis.
- **Foreground (`{colors.foreground}`)** — tinta. Texto primário, ícones de chrome, bordas de foco quando o anel não basta.
- **Primary (`{colors.primary}`)** — ação afirmativa (salvar, abrir turma, confirmar reserva de Resource). Navegação ativa. Não significa “exceção de sala”.
- **Accent (`{colors.accent}`)** — só sala efetiva divergente e célula de ocupação com exceção. Se a tela não fala de sala efetiva, o accent não aparece.
- **Muted (`{colors.muted}` / `{colors.muted-foreground}`)** — chrome, cabeçalho de tabela, sala padrão quando **não** há exceção, ocupação tomada sem drama.
- **Destructive (`{colors.destructive}`)** — recusa de invariante (Professor sem Employee, colisão, roster na tela errada é bug — não um estado). Também cancelar Reservation.
- **Success (`{colors.success}`)** — confirmação discreta (turma aberta, Reservation confirmada). Sem confete.
- **Warning (`{colors.warning}`)** — só `{components.flag-avaliacao-mark}`: a aula tem avaliação. Não reutilizar para validação de formulário (isso é recusa).
- **Occupancy (`{colors.occupancy-free}` / `{colors.occupancy-taken}` / `{colors.occupancy-exception}`)** — células do grid FR-29. Taken não é vermelho: vermelho é recusa, não “ocupado”.

V1 é só claro. Sem tokens `*-dark`.

## Typography

IBM Plex Sans para display, headline, body, label e caption. IBM Plex Mono **somente** para código de faixa, `id` canônico visível e intervalo `[início, fim)` ao lado do código.

- `{typography.display}` — título da Home e do Login. Não em formulários.
- `{typography.headline}` — `{components.page-header}` e empty states.
- `{typography.body}` — leitura (plano de ensino, recusa, ajuda).
- `{typography.label}` — rótulos de campo e pills.
- `{typography.caption}` — horário da faixa (08:00–08:45) como secundário do código; meta de página.
- `{typography.mono}` — A, B, H, P; nunca o nome da disciplina.

Não há serifa de marca. Não há display em tabela.

## Layout & Spacing

Grade de 8px (`{spacing.1}`–`{spacing.7}`). Gutter `{spacing.gutter}`; padding de página `{spacing.page}`.

Desktop-first. Conteúdo de cadastro e oferta: duas colunas (lista | detalhe) a partir de 1024px; tabela de ocupação e esqueleto usam a largura útil inteira — Closed CRAS **é** produto de grade, não coluna única de leitura.

`{components.app-shell}`: barra superior 56px com hambúrguer à esquerda e o nome **Closed CRAS**. `{components.role-nav}` abre dessa barra. Em ≥1024px a lista ocupa `{spacing.sidebar}` ao lado do conteúdo. Abaixo de 1024px a lista é folha; `Esc` fecha. Abaixo de 768px as duas colunas de cadastro empilham. A v1 não otimiza telefone: Student lê, Funcionário não cadastra Employee num polegar.

Máximo de um `{components.confirm-dialog}` por vez. Sem stack de modal.

## Elevation & Depth

Hierarquia por borda `{colors.border}` e superfície `{colors.card}` sobre `{colors.background}`. Sombra só no `{components.confirm-dialog}` e na folha de nav estreita — 0 8px 24px com 12% de preto. Hover de linha de tabela: `{colors.muted}`, sem elevação. Accent não “acende” com sombra.

## Shapes

`{rounded.sm}` inputs; `{rounded.md}` botões e banners; `{rounded.lg}` painéis, login, cards da Home, dialogs; `{rounded.full}` só pills e `{components.sala-efetiva-chip}`. Cantos modestos = ferramenta. Sem gotícula consumer.

## Components

- **app-shell** — Canvas `{colors.background}`. Barra superior 56px, borda inferior `{colors.border}`. Hambúrguer à esquerda; nome **Closed CRAS** ao lado. À direita, nome da pessoa autenticada e papel (Funcionário, Coordenador, Professor, Student).
- **role-nav** — Lista aberta pelo hambúrguer, nesta ordem: Employees, Professors, Students, Rooms, Courses, Classes, Lessons, Resources, Reservations. Item ativo: `{colors.primary}` / `{colors.primary-foreground}`. Em ≥1024px ocupa `{spacing.sidebar}`. Abaixo de 1024px é folha. Neste corte os itens não abrem CRUD.
- **page-header** — `{typography.headline}` + uma linha `{typography.caption}` com o termo travado da superfície (ex.: “Turma — oferta do período, não a disciplina”).
- **button-primary / button-secondary / button-destructive** — Altura 36px, `{rounded.md}`. Primário = afirmar invariante. Secundário = cancelar navegação, “voltar”. Destructive = cancelar Reservation ou desativar Employee. Disabled: 40% de opacidade, cursor `not-allowed`.
- **data-table** — Cabeçalho `{colors.muted}`, linhas `{colors.card}`, divisórias `{colors.border}`. Densidade compacta (linha ~40px). Sem zebra. Coluna de faixa em `{typography.mono}`.
- **master-detail-panel** — Principal à esquerda, secundária 1–N à direita (Dependent, AcademicDegree, SyllabusItem, WeeklySlot, LessonTopic, ReservationLine, AccessibilityFeature, InventoryItem). A secundária nunca vira página órfã.
- **form-field** — Borda `{colors.border}`, foco anel 2px `{colors.ring}` offset 2px. Rótulo `{typography.label}` acima. Erro de invariante não fica só no campo: sobe para `{components.refusal-banner}`.
- **faixa-picker** — Grade de códigos canônicos; cada célula mostra `{typography.mono}` (H) e caption (15:45–16:30). E1, E2 e O não são opções. Sem input de hora livre.
- **occupancy-grid** — Eixo Y: Room ou Resource; eixo X: faixas do dia. Célula livre / tomada / exceção com os três tokens. Texto na célula: identificador, não nome de Student.
- **refusal-banner** — Recusa de invariante em prosa travada (“Não há Employee com este id — o papel docente não nasce.”). Ícone desnecessário; o texto é o estado.
- **empty-state** — Headline + uma frase + no máximo um primário. Sem ilustração mascote.
- **status-pill** — Ativo / inativo / presencial / remoto / ad hoc. Cores muted ou primary; nunca accent.
- **sala-efetiva-chip** — Padrão: muted com o código da Room. Exceção: `{colors.accent}` e o código da sala efetiva; a padrão não aparece ao lado como se fosse o *onde*. Remoto: pill “remoto”, sem Room.
- **flag-avaliacao-mark** — Ponto ou rótulo “avaliação” em `{colors.warning}`. Presente ou ausente; sem semáforo.
- **login-panel** — Card centrado, largura 400px. Título display. Campos de credencial institucional. Banner de recusa dentro do card. Sem logotipo PUCRS.
- **journey-card** — Fora deste corte. Quando UX-S* entrarem: título da jornada do papel + verbo. Sem ícone de microsserviço.
- **confirm-dialog** — Uma pergunta, primário + secondary. Cancelar Reservation usa destructive no confirmar.
- **skeleton-block** — Retângulos `{colors.muted}` no lugar de tabela ou grid; 4–6 linhas. Sem spinner de marca.

## Do's and Don'ts

| Do | Don't |
|---|---|
| Usar **disciplina, turma, aula, reserva, faixa, Employee, sala padrão, sala efetiva** no rótulo visível | Pessoa, evento, slot, horário solto, “local”, “professor” como cadastro no lugar de Employee |
| `{colors.accent}` só quando a sala efetiva diverge | Accent em hover, links, badges de papel ou nav |
| Código de faixa em `{typography.mono}` com horário na caption | Time picker livre ou “18 faixas iguais à sala padrão” |
| Occupied = `{colors.occupancy-taken}` | Occupied = `{colors.destructive}` |
| Chip de sala efetiva; padrão some quando há exceção | Mostrar sala padrão e efetiva juntas como se ambas fossem o *onde* |
| Chrome **Closed CRAS** | Malha, SIGAA, marca PUCRS, “Campus AI” |
| Um dialog por vez, densidade de tabela | Cards de consumo, kanban, empty state ilustrado |
| Contraste AA nas combinações listadas | Texto `{colors.muted-foreground}` sobre `{colors.muted}` para corpo |
