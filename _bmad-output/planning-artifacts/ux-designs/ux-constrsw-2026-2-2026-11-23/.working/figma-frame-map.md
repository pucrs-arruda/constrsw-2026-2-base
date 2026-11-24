# Figma frame map

File: https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp  
Update polish: 2026-11-23

Menu hambúrguer (ordem fixa): Funcionários → Professores → Alunos → Salas de Aula → Recursos → Disciplinas → Turmas.

## Product frames (22)

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
| 10 | Alunos — lista (com classes compostas) | `3:232` |
| 11 | Alunos — detalhe + matrículas | `3:283` |
| 12 | Salas — lista | `3:25` |
| 13 | Salas — detalhe + recursos de acessibilidade | `3:81` |
| 14 | Recursos — lista (com reservations futuras) | `3:429` |
| 15 | Recursos — detalhe + ocorrências | `3:480` |
| 16 | Disciplinas — lista (com classes compostas) | `3:528` |
| 17 | Disciplinas — detalhe + referências + itens de plano | `3:579` |
| 18 | Turmas — lista | `3:633` |
| 19 | Turma — detalhe, aba Alunos matriculados | `3:684` |
| 20 | Turma — detalhe, aba Aulas | `3:739` |
| 21 | Turma — detalhe, aba Reservas | `3:801` |
| 22 | Estado de erro BFF 503 composição | `3:860` |

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

## Responsive frames (planejados — ainda não criados no Figma)

Página nova no arquivo: **Responsivo**. Cada frame é uma variante editável (auto-layout + instances da Lib), não screenshot. Larguras: compact **360 × 800**, medium **768 × 1024**. Nome: `{#}C — {nome} (compact)` / `{#}M — {nome} (medium)`. Referência visual: `../mockups/closed-cras-responsivo.html` e `qa/responsive/*.png`. Spines vencem.

| # | Origem | Compact 360 | Medium 768 | O que o frame precisa provar |
|---|---|---|---|---|
| R01 | 01 Login — repouso | sim | sim | Faixa de marca no topo; card sem elevação em largura total (compact) |
| R02 | 02 Login — credencial recusada | sim | — | Banner quebrando linha dentro do card |
| R03 | 05 Home — folha do menu | sim | sim | Folha 280px + scrim; caption e nome do usuário ocultos (compact) |
| R04 | 12 Salas — lista | sim | sim | Compact: lista de 2 linhas + "Mais ações"; CTA filled em linha inteira. Medium: tabela com colunas de prioridade baixa ocultas |
| R05 | 13 Salas — detalhe | sim | sim | "← Voltar para Salas de Aula"; principal e secundária empilhadas |
| R06 | 07 Funcionários — detalhe + dependentes | sim | — | Secundária como lista; Adicionar dependente em linha inteira |
| R07 | 20 Turma — aba Aulas | sim | sim | Abas roláveis; chips de contexto quebrando; aulas como lista com chip «Com avaliação» |
| R08 | 21 Turma — aba Reservas | sim | — | Única grade com scroll horizontal e coluna de faixas fixa |
| R09 | 22 BFF 503 composição | sim | — | identity-banner com ação abaixo do texto |
| R10 | Edição (dialog genérico) | sim | sim | Compact: dialog tela cheia com ações no rodapé. Medium: dialog 560px |

As demais superfícies (Funcionários/Professores/Alunos/Recursos/Disciplinas/Turmas lista e detalhe) seguem o padrão de R04/R05 a partir das spines e não ganham frame próprio.

Componentes novos para a Lib: `ListItem/Compact` (72dp), `IconButton/MoreActions` (40dp, toque 48dp), `AppBar/Compact` (sem caption nem nome), `Dialog/FullScreen`.

Deep link: `https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp?node-id={id-with-hyphen}`  
Example: https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp?node-id=2-2
