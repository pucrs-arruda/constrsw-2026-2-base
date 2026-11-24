# Figma frame map

File: https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp  
Update polish: 2026-11-23

Menu hambúrguer (ordem fixa): Funcionários → Professores → Alunos → Salas de Aula → Recursos → Disciplinas → Turmas → Ocupação → Plano + roster → Minhas aulas.

## Product frames (25)

| # | Frame | node id |
|---|---|---|
| 01 | Login — repouso | `2:2` |
| 02 | Login — credencial recusada | `2:16` |
| 03 | Login — identidade indisponível | `2:32` |
| 04 | Home — menu aberto (desktop) | `2:48` |
| 05 | Home — folha do menu (<1024px) | `2:79` |
| 06 | Funcionários — lista | `3:331` |
| 07 | Funcionários — detalhe + dependentes | `3:382` |
| 08 | Professores — lista | `3:133` |
| 09 | Professores — detalhe + titulações | `3:184` |
| 10 | Alunos — lista + cadastro | `3:232` |
| 11 | Alunos — detalhe + cadastro + afiliações | `3:283` |
| 12 | Salas — lista | `3:25` |
| 13 | Salas — detalhe + recursos de acessibilidade | `3:81` |
| 14 | Recursos — lista (com reservations futuras) | `3:429` |
| 15 | Recursos — detalhe + ocorrências | `3:480` |
| 16 | Disciplinas — lista (com classes compostas) | `3:528` |
| 17 | Disciplinas — detalhe + referências + itens de plano | `3:579` |
| 18 | Turmas — lista | `3:633` |
| 19 | Turma — detalhe, aba Alunos matriculados (associar existentes) | `3:684` |
| 20 | Turma — detalhe, aba Aulas (CRUD lessons) | `3:739` |
| 21 | Aula — detalhe + reservas (CRUD reservations) | `3:801` |
| 22 | Estado de erro BFF 503 composição | `3:860` |
| 23 | Ocupação — grade data+faixa (FR-29) | `85:744` |
| 24 | Professor — plano + roster (FR-31) | `85:958` |
| 25 | Student — sala efetiva / plano / avaliação (FR-19) | `85:1124` |

## Library frames (≤6, não são telas de produto)

| # | Frame | node id |
|---|---|---|
| Lib 1 | Chrome (header + nav) | `13:79` |
| Lib 2 | Controles (botões + campos) | `13:103` |
| Lib 3 | Dados (tabela + pills) | `13:122` |
| Lib 4 | Feedback (banners + abas) | `13:139` |
| Lib 5 | M3 Buttons (h=40) | `21:1108` |
| Lib 6 | M3 Metrics | `21:1125` |
| Lib 7 | Paleta PUCRS (chips Tertiary/Gold/Primary/Secondary) | `23:620` |

## Responsive frames (página Responsivo, 2026-11-24)

Variantes editáveis (auto-layout + instances). Larguras: compact **360**, medium **768**. Spines vencem.

| # | Frame | node id |
|---|---|---|
| R01C | Login — repouso (compact) | `37:615` |
| R01M | Login — repouso (medium) | `37:637` |
| R02C | Login — credencial recusada (compact) | `37:659` |
| R03C | Home — folha do menu (compact) | `37:684` |
| R03M | Home — folha do menu (medium) | `37:734` |
| R04C | Salas — lista (compact) | `37:786` |
| R04M | Salas — lista (medium) | `37:910` |
| R05C | Salas — detalhe (compact) | `39:792` |
| R05M | Salas — detalhe (medium) | `39:875` |
| R06C | Funcionários — detalhe (compact) | `39:960` |
| R07C | Turma — aba Aulas (compact) | `39:1021` |
| R07M | Turma — aba Aulas (medium) | `39:1122` |
| R08C | Turma — aba Reservas (compact) | `39:1208` |
| R09C | BFF 503 composição (compact) | `39:1321` |
| R10C | Edição — dialog tela cheia (compact) | `39:1349` |
| R10M | Edição — dialog 560 (medium) | `39:1380` |

Componentes novos na página Components: `IconButton/MoreActions` `35:652`, `ListItem/Compact` `35:688` (Meta Nenhuma/Tertiary/Gold), `AppBar/Compact` `35:689`.

As demais superfícies (Funcionários/Professores/Alunos/Recursos/Disciplinas/Turmas lista e detalhe) seguem o padrão de R04/R05 a partir das spines e não ganham frame próprio.

Componentes novos para a Lib: `ListItem/Compact` (72dp), `IconButton/MoreActions` (40dp, toque 48dp), `AppBar/Compact` (sem caption nem nome), `Dialog/FullScreen`.

Deep link: `https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp?node-id={id-with-hyphen}`  
Example: https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp?node-id=2-2
