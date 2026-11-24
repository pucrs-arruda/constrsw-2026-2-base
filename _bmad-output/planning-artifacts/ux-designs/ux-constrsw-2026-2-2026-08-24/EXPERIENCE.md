---
name: Closed CRAS
status: final
sources:
  - "{planning_artifacts}/prds/prd-constrsw-2026-2-2026-08-19/prd.md"
  - "{planning_artifacts}/prds/prd-constrsw-2026-2-2026-08-19/addendum.md"
  - "{planning_artifacts}/briefs/brief-constrsw-2026-2-2026-08-17/brief.md"
  - "{planning_artifacts}/research/domain-university-academic-and-resource-management-research-2026-08-17.md"
  - "backend/oauth/README.md"
updated: 2026-11-16
---

# Closed CRAS — Experience Spine

UI web única, acesso por papel, ConstrSW PUCRS 2026/2. Identidade visual em `DESIGN.md`. Mecanismo e stack no addendum do PRD — este spine não os relita. Glossário, FRs e OQ-1–OQ-3 permanecem no PRD; aqui só o que a superfície faz.

## Foundation

Form-factor: **uma** UI web com acesso por papel — não app nativo, não totem, não quatro produtos. Desktop-first (laboratório); leitura de Student cabe em viewport estreita; cadastro e grade não.

Não há sistema de UI nomeado. Tokens e anatomia visual: `DESIGN.md`. A UI autentica com `POST /login` de `backend/oauth` (`multipart/form-data`: `username`, `password`; credentials incluídos). Sucesso `201` segue o cookie httpOnly que o oauth grava; a UI não persiste `access_token` nem `refresh_token`. Logout é `POST /logout` e volta a UX-LOGIN. Sem Keycloak no browser e sem `keycloak-js`. A UI não faz join de nove OpenAPIs no browser.

Neste corte, a chrome lista nove serviços. O papel continua na barra (Funcionário, Coordenador, Professor, Student). UX-S1–UX-S9 permanecem especificadas e fora deste corte: o item do menu não abre CRUD.

V1 claro apenas. Sem modo offline. Sem tela de alta de Student.

## Information Architecture

Inventário herdado do addendum **Telas v1**, mais Login e Home. Onze superfícies. Nove exclusivas (um grupo dono cada, OQ-1) + duas compartilhadas.

| ID | Superfície | Chega de | Propósito | Dono de implementação |
|---|---|---|---|---|
| UX-LOGIN | Login institucional | URL fria / sessão expirada | Autenticar com `POST /login` de `backend/oauth` | Compartilhada (todos os grupos) |
| UX-HOME | Home do shell | Login ok | Marcar o item ativo da lista; sem CRUD | Compartilhada (todos os grupos) |
| UX-S1 | Employee + Dependent | Home / nav (Funcionário) | Cadastrar/editar Employee e vínculos 1–N | Exclusiva — OQ-1 |
| UX-S2 | Professor + AcademicDegree | Home / nav (Funcionário); atalho pós-Employee | Criar papel docente sobre Employee existente; titulações | Exclusiva — OQ-1 |
| UX-S3 | Room + AccessibilityFeature; Resource + InventoryItem | Home / nav (Funcionário) | Cadastro-mestre de espaço e recurso (duas zonas, uma superfície) | Exclusiva — OQ-1 |
| UX-S4 | Ocupação por data + faixa | Home / nav (Funcionário) | Ocupação **agendada** de Room/Resource na data+faixa; sala efetiva | Exclusiva — OQ-1 |
| UX-S5 | Course + plano de ensino | Home / nav (Coordenador) | Disciplina + SyllabusItem; publicar plano datado | Exclusiva — OQ-1 |
| UX-S6 | Abrir Class + esqueleto | Home / nav (Coordenador); exige plano publicado | Turma: sala padrão, vagas, WeeklySlot, gerar Lesson | Exclusiva — OQ-1 |
| UX-S7 | Ajustar Lesson + Reservation | Home / nav (Professor) | Tópicos, flags, modalidade; Resource feliz; Room exceção; cancelar | Exclusiva — OQ-1 |
| UX-S8 | Plano + roster da Class | Home / nav (Professor) | Leitura do plano da disciplina e roster da turma | Exclusiva — OQ-1 |
| UX-S9 | Onde / o quê / avaliação + plano | Home / nav (Student) | Sala efetiva, tópico, `flagAvaliacao`, plano publicado | Exclusiva — OQ-1 |

Neste corte, `{components.role-nav}` é a lista do hambúrguer, nesta ordem: Employees, Professors, Students, Rooms, Courses, Classes, Lessons, Resources, Reservations. Item ativo marcado. Abaixo de 1024px a lista é folha; `Esc` fecha. Nenhum item chama serviço de domínio.

O mapa por papel não é a chrome deste corte. Vale quando UX-S1–UX-S9 entrarem:

| Papel | Superfícies |
|---|---|
| Funcionário | UX-HOME, UX-S1, UX-S2, UX-S3, UX-S4 |
| Coordenador | UX-HOME, UX-S5, UX-S6 |
| Professor | UX-HOME, UX-S7, UX-S8 |
| Student | UX-HOME, UX-S9 |

Modal: no máximo um `{components.confirm-dialog}`. Sem rota para cadastro de Student. A lista do shell é fixa; não há um segundo seletor de backend.

IA fecha: UJ-1→S1–S4; UJ-2→S5–S6; UJ-3→S7–S8; UJ-4→S9; autenticação→LOGIN. Toda superfície tem jornada que a alcança (Login/Home = todas).

→ Composição: **spine-only** para UX-LOGIN, UX-HOME e UX-S1–UX-S9. Sem `mockups/` nem `wireframes/` nesta rodada. Spines vencem em conflito.

## Partição de telas (nove grupos)

> **Superseded 2026-11-24.** Autoridade vigente: EXPERIENCE 2026-11-23 + `capability-map.md`. OQ-1 fechada: Prof. Arruda → UX-LOGIN, UX-HOME, UX-EMPLOYEES; cada grupo → UX do **próprio** serviço (reverte frontend cruzado).

~~Cada grupo implementa telas de **um domínio que não é o seu** (FR-28). Emparelhamento grupo↔telas = **OQ-1** (aberto).~~

Regra legada (inventário UX-S* desta rodada — só rastreio):

- **UX-S1–UX-S9:** no máximo **um** grupo por superfície.
- UX-S3 era uma superfície (Room+Resource); no inventário 2026-11-23 virou UX-ROOMS + UX-RESOURCES.
- UX-S7 era Lesson+Reservation; no inventário vigente = UX-CLASS-LESSONS + UX-LESSON-RESERVATIONS.

## Língua na UI

Travada. Contratos e rótulos usam os mesmos termos. Proibido na chrome, form, tabela, empty state e recusa: pessoa, evento, slot, “horário” no lugar de faixa, local no lugar de sala efetiva.

| Usar | Não usar |
|---|---|
| disciplina | curso genérico quando o objeto é Course |
| turma | oferta / turma-disciplina fundidos |
| aula | encontro / sessão / evento |
| reserva | booking / hold genérico |
| faixa (código A–P) | slot, time range editável |
| Employee | pessoa, staff, usuário institucional |
| Professor (is-a Employee) | cadastro de nome/e-mail no papel docente |
| Student | aluno como Employee |
| sala padrão | “sala da turma” como se fosse o *onde* da aula |
| sala efetiva | local, “sala da aula” ambíguo |
| Dependent, AcademicDegree, SyllabusItem, WeeklySlot, LessonTopic, AccessibilityFeature, InventoryItem, ReservationLine | terceira classe inventada na UI |

Professor na UX-S2 mostra nome/e-mail **resolvidos** do Employee (`employeeId`); campos de identidade não são editáveis no papel docente. Student na UX-S9 nunca vê “sala padrão” quando a efetiva for outra.

## Voice and Tone

Microcopy. Postura de marca em `DESIGN.md`.

| Do | Don't |
|---|---|
| “Não há Employee com este id. O papel docente não nasce.” | “Erro 409. Professor órfão.” |
| “Sala padrão não cabe nas vagas (capacidade 30, vagas 40).” | “Validação falhou.” |
| “Esta faixa já tem sala efetiva em outra aula.” | “Conflito de slot.” |
| “Onde: sala efetiva B201” / “Onde: remoto” | “Local: ver turma” |
| “Cancelar a reserva devolve a faixa ao Resource.” | “Tem certeza? ⚠️” genérico sem consequência |
| Recusa em `{components.refusal-banner}`, termo travado | Toast “Oops! Something went wrong” |
| Mesmo tom para os quatro papéis: operador de laboratório | Tom “aluno digital” na UX-S9 e tom ERP na UX-S1 |

## Component Patterns

Comportamento. Visual em `DESIGN.md.Components`.

| Component | Onde | Regras |
|---|---|---|
| app-shell | Todas autenticadas | Barra com hambúrguer à esquerda e **Closed CRAS**. Papel e identidade à direita. Logout: `POST /logout` e volta a UX-LOGIN. |
| role-nav | Todas autenticadas | Lista fixa: Employees, Professors, Students, Rooms, Courses, Classes, Lessons, Resources, Reservations. Ativo = item corrente. Neste corte não abre CRUD e não chama o serviço. |
| page-header | Cada UX-S* e Home | Título = nome da superfície (tabela IA). Caption = uma linha de língua (ex. “Reserva de Room é exceção, não a sala padrão”). |
| button-primary | Afirmar | Um primário visível por zona. Disabled até o formulário poder submeter; o clique ainda pode recusar invariante no servidor — a recusa sobe no banner, não some o botão. |
| button-secondary | Navegar / abortar form | Nunca destrói Reservation. |
| button-destructive | Desativar Employee; cancelar Reservation | Sempre via `{components.confirm-dialog}`. |
| data-table | S1–S9 listas | Clique na linha abre o detalhe. Ordenação estável por `id` ou data+faixa. Coluna de faixa em código. Sem paginação infinita. |
| master-detail-panel | S1, S2, S3, S5, S6, S7 | Principal selecionada; secundária 1–N só daquela principal. Criar secundária órfã é impossível (controle só no detalhe). |
| form-field | S1–S3, S5–S7, LOGIN | Rótulo = termo travado. `employeeId` em S2 é busca/seleção de Employee existente, não texto de nome. |
| faixa-picker | S4, S6, S7 | Opções = A–E, F–N, P. Caption = horário do addendum. Recusa E1/E2/O se vierem por engano. Extremos que se tocam não são apresentados como colisão. |
| occupancy-grid | S4 | Data no filtro + todas as faixas do cânone no eixo X. Célula = agendado, não sensor. Exceção usa token de exceção. Sem coluna nominativa de Student. |
| refusal-banner | Qualquer escrita recusada | Substitui o sucesso. Texto nomeia a invariante (Employee ausente, capacidade, AccessibilityFeature, colisão de sala efetiva / Resource / Professor, plano depois do período, segunda linha SALA). |
| empty-state | Listas vazias | S1: “Nenhum Employee ainda.” + cadastrar. S9: “Nenhuma turma no seed desta conta.” Sem CTA de matrícula. |
| status-pill | S1–S3, S7, S9 | Ativo/inativo; presencial/remoto; Reservation ad hoc vs ligada à aula. |
| sala-efetiva-chip | S4, S7, S9 | Valor = sala efetiva. Se divergir, variante accent e a padrão **não** compete como *onde*. Remoto: sem Room. |
| flag-avaliacao-mark | S7, S9 | Visível quando `flagAvaliacao`. Student pergunta “tem avaliação?” neste marca. |
| login-panel | UX-LOGIN | Submit: `POST /login` (`username`, `password`, credentials incluídos). `201`: cookie httpOnly; a UI não persiste `access_token` nem `refresh_token`; navega a UX-HOME. `401`: banner no painel, sem enumerar conta. `503` ou rede: banner “Identidade indisponível.” |
| journey-card | UX-HOME | Fora deste corte. Quando UX-S* entrarem, um card por verbo do papel (tabela Home). |
| confirm-dialog | Destructive | Nomeia o objeto (Employee, Reservation) e o efeito (faixa devolvida; Class somente leitura se OQ-2 default). |
| skeleton-block | Cold load | Espelha tabela ou grid da superfície; some quando o BFF responde. |

## State Patterns

| Estado | Superfície | Tratamento |
|---|---|---|
| Cold load | Todas autenticadas | `{components.skeleton-block}` no corpo; chrome do shell já visível com papel. |
| Sessão ausente / expirada | Qualquer URL autenticada | Redirect UX-LOGIN; depois, volta à URL pedida se o papel puder. |
| Credencial recusada | UX-LOGIN | Banner no `{components.login-panel}`. Não revela existência de conta. |
| Gateway de identidade indisponível | UX-LOGIN | Banner: “Identidade indisponível.” Sem Keycloak no browser e sem `keycloak-js`. |
| BFF indisponível | Qualquer autenticada | Banner de página: jornada ilegível; sem join local de APIs. |
| Permission denied (papel) | URL de outra papel | Redirect UX-HOME do papel atual. Sem “403” com nome de serviço. |
| Permission denied (Professor sem atribuição) | UX-S7, UX-S8 | Lista só Class atribuídas; Class alheia não aparece. |
| Student sem Class no seed | UX-S9 | Empty state sem CTA de matrícula. |
| Empty lista | S1–S8 | Empty da superfície; um primário se o papel puder criar. |
| Recusa FR-4 | UX-S2 | Banner: Professor sem Employee existente. Formulário retido. |
| Recusa FR-13/15 | UX-S6 | Banner: colisão de sala efetiva ou Professor; ou capacidade; ou zero AccessibilityFeature. Não abre a turma; não gera Lesson. |
| Recusa FR-23/24/30 | UX-S7 zona Reservation | Banner: Resource tomado/inativo; segunda SALA na Lesson; capacidade/acessibilidade; sobreposição de Professor. Reservation não confirma. |
| Recusa FR-11 | UX-S5 | Publicar plano com data ≥ início do período da turma alvo: recusa. |
| Exceção de sala | S4, S7, S9 | `{components.sala-efetiva-chip}` accent. S9 nunca mostra a padrão nesse caso. |
| Aula remota | S7, S9 | Modalidade remoto; chip sem Room. S4 não conta essa aula como ocupação de Room. |
| Employee desativado (OQ-2 default de demo) | S1, S6, S7 | S1 mostra inativo. Class atribuídas ficam somente leitura. Nova Reservation recusada. Não exige substituir Professor. |
| Occupied vs recusa | S4 vs S6/S7 | S4: célula tomada (muted). S6/S7: tentativa de gravar colisão = `{components.refusal-banner}` (destructive). |
| Sem AccessibilityFeature | S3, S6, S7 | S3 permite cadastrar Room assim; S6/S7 recusam usar essa Room como sala padrão ou linha SALA. |
| Roster | UX-S8 só | Lista `Class.studentIds` resolvidos. **Ausente** em UX-S7. Ausente em S4. |
| Offline | Global | Sem modo offline. Banner de BFF/identidade. Escritas não entram em fila local. |

## Interaction Primitives

Mouse e teclado de formulário, não paleta estilo IDE.

- `Tab` / `Shift+Tab` — ordem de leitura em toda superfície.
- `Enter` — submete o formulário focado; na tabela, abre a linha.
- `Esc` — fecha `{components.confirm-dialog}` e a nav-folha; não descarta formulário sujo sem o secondary explícito.
- Foco visível: anel `{colors.ring}` em todo controle.
- `{components.faixa-picker}`: setas entre códigos; `Enter` seleciona.
- `{components.occupancy-grid}`: foco por célula; leitor vê “Room {código}, faixa {código}, {livre\|tomada\|exceção}”.
- Sem atalho que troque de papel. Sem `⌘K` obrigatório na v1. `[ASSUMPTION]`
- Hover não é a única via para ação destrutiva: cancelar Reservation é botão visível + dialog.

**Banido:** drag-and-drop da grade, infinite scroll, time picker livre, stack de modal > 1, chamar as nove APIs no browser, cadastrar Student.

## Accessibility Floor

Comportamento. Contraste em `DESIGN.md`.

- WCAG 2.2 AA na UI web.
- Mudança de superfície: o `h1` do `{components.page-header}` recebe foco de leitura (“Turma, oferta do período”).
- `{components.refusal-banner}` é `role="alert"`.
- `{components.sala-efetiva-chip}` anuncia “sala efetiva {código}” ou “sala efetiva diferente da padrão, {código}” ou “remoto, sem sala”.
- `{components.flag-avaliacao-mark}` não depende só de cor: texto “avaliação”.
- AccessibilityFeature da Room é lista nomeada (rampa, elevador, …), não um checkbox “acessível”.
- `{components.occupancy-grid}` tem cabeçalhos de faixa e de Room/Resource; não é só cor de célula.
- Alvo de clique ≥ 24px nos pickers de faixa; tabelas compactas mas a célula inteira é alvo.
- Não usar `{colors.accent}` como único indicador sem o código da Room no chip.

## Responsive & Platform

| Breakpoint | Comportamento |
|---|---|
| ≥ 1024px | `{components.role-nav}` ao lado do conteúdo (`{spacing.sidebar}`), aberta pelo hambúrguer. master-detail em duas colunas. occupancy-grid em largura útil. |
| 768–1023px | Nav em folha a partir do hambúrguer; `Esc` fecha. master-detail empilha (lista acima). Grid de ocupação com scroll horizontal nas faixas; códigos de faixa permanecem visíveis. |
| < 768px | Mesmo que 768, densidade menor. UX-S9 usável. UX-S1–S6 e S4 não são o recorte de demo no telefone. |

Não é app nativo. Não há paridade iOS/Android.

## Inspiration & Anti-patterns

Herdado das alternativas rejeitadas do addendum e do recorte do PRD — não de produtos de mercado a copiar.

- **Levantar:** língua única API/BFF/UI; sala padrão na abertura da turma; *onde* = sala efetiva; faixa canônica; Recurso no feliz, Room na exceção; roster longe da Reservation.
- **Rejeitado — nove CRUDs com `pessoa`:** a chrome não tem “Pessoas”. Employee e Student não compartilham ficha.
- ~~**Rejeitado — cada grupo implementa as próprias telas**~~ **Revertido 2026-11-24:** UX do próprio serviço; ver EXPERIENCE 2026-11-23.
- **Rejeitado — adaptador JS da UI no IdP:** Login só em `POST /login` de `backend/oauth`. Sem Keycloak no browser e sem `keycloak-js`.
- **Rejeitado — app nativo / totem / quatro produtos.**
- **Rejeitado — tela de alta de Student.**
- **Rejeitado — 18 reservas da sala padrão:** UX-S6 não cria Reservation ao abrir a turma; UX-S7 não oferece “reservar sala padrão”.
- **Rejeitado — faixas E1, E2, O; horário solto.**
- **Rejeitado — ocupação por sensor / no-show na v1:** S4 é agendada.
- **Rejeitado — marca PUCRS como produto, nome Malha, SIG*.**
- **Não copiar:** SIS de mercado (SIGAA/TOTVS) como visual ou IA. Closed CRAS senta ao lado do registro, não o imita.

## Superfícies e LGPD

- **NFR-LGPD-2.** Lesson + Student nomeado é localização. UX-S9 mostra ao próprio Student. S4 agrega ocupação **não** nominativa de Student. Professor lê roster só em UX-S8 e só da Class atribuída.
- **NFR-LGPD-3.** UX-S7 (Reservation) **não** lista roster. Plano+roster = UX-S8, superfície distinta, dono distinto possível.
- **NFR-LGPD-4.** Desativar/esconder na UI não apaga `id` canônico “para limpar a tela”.
- Sem CPF na ficha de Employee (v1).

## Grade de faixas

Picker e grid usam a tabela do addendum (A 08:00–08:45 … P 21:45–22:30). Cada faixa `[início, fim)`. Depois de E, a próxima opção é F (almoço visível como lacuna, não como faixa). Aulas seg–sáb em UX-S6 (WeeklySlot). Feriados não são filtrados na geração (v1).

## Home (por papel)

Neste corte a Home não renderiza estes cards. A navegação é a lista do hambúrguer, sem CRUD. A tabela permanece o mapa das superfícies UX-S*, fora deste update.

| Papel | Cards (verbo → superfície) |
|---|---|
| Funcionário | Cadastrar quem trabalha → S1; Criar papel docente → S2; Cadastrar Room e Resource → S3; Consultar ocupação por data + faixa → S4 |
| Coordenador | Publicar disciplina e plano → S5; Abrir turma com sala padrão → S6 |
| Professor | Ajustar aula e reserva → S7; Ler plano e roster → S8 |
| Student | Onde / o quê / tem avaliação? → S9 |

## Key Flows

Nomes UJ verbatim do PRD. Climax em negrito. Falha = recusa de invariante, não crash genérico. Neste corte o shell autentica no oauth e a Home só marca o item da lista. Os passos que entram em UX-S* descrevem as superfícies futuras, fora deste update.

### UJ-1. Helena cadastra quem trabalha — e só então o papel docente existe.

**Persona + contexto:** Helena, funcionária, steward de master data; um docente novo precisa existir como Employee antes de lecionar.

1. Helena abre a UI, autentica em UX-LOGIN (`POST /login` de `backend/oauth`) e cai em UX-HOME.
2. Card “Cadastrar quem trabalha” → UX-S1. Cria Employee e um Dependent.
3. Sem sair do papel, abre UX-S2. Seleciona o `employeeId` recém-criado (nome resolvido, não copiado). Cria Professor e um AcademicDegree.
4. Em UX-S3 cadastra a Room (capacidade + pelo menos um AccessibilityFeature) e um Resource com InventoryItem.
5. **Climax:** em UX-S4 escolhe uma data e lê o grid por faixa — salas e recursos ainda livres na grade. O `id` de Employee que ela acabou de gravar é o que S2 usou; não há segunda ficha de pessoa. No shell deste corte o menu só nomeia o destino; Helena não chamou as APIs dos nove serviços.

**Falha:** em S2 ela tenta criar Professor sem Employee → `{components.refusal-banner}` FR-4; o papel docente não nasce. Tentar “novo Student” não existe na nav.

### UJ-2. Rafael abre a oferta do período com sala padrão, não com 18 reservas.

**Persona + contexto:** Rafael, coordenador; o plano de ensino já está publicado e datado *antes* do período.

1. Rafael autentica no papel Coordenador. UX-HOME.
2. Se o plano ainda não existe: UX-S5 — Course + SyllabusItem; publica com data anterior ao início do período.
3. UX-S6: escolhe a disciplina, período, vagas, Professor(es) existentes, Room como **sala padrão**, esqueleto em `{components.faixa-picker}` (seg–sáb).
4. Confirma a abertura. O sistema gera Lesson; **nenhuma** Reservation de sala padrão é criada.
5. **Climax:** a turma existe com sala padrão; Marina poderá ver as aulas; Caio verá a sala efetiva (ainda igual à padrão). Rafael não “reservou 18 vezes”. A UI de S6 não oferece fluxo de Reservation.

**Falha:** capacidade < vagas, Room sem AccessibilityFeature, ou esqueleto em colisão de sala efetiva ou Professor → abertura recusada; Lesson não nascem. Publicar plano tarde demais → recusa em S5.

### UJ-3. Marina reserva o projetor — e só troca a sala quando a padrão não serve.

**Persona + contexto:** Marina, no papel Professor, atribuída à Class; a aula de quinta, faixa H, precisa de kit e de outra Room.

1. Marina autentica. UX-HOME → UX-S8: lê plano e roster da turma (FR-31). Roster **não** segue com ela para a reserva.
2. UX-S7 zona Lesson: quinta, faixa H. Ajusta LessonTopic, `flagAvaliacao`, deixa presencial.
3. Zona Reservation: cria Reservation ligada à aula, linha RECURSO (projetor). Caminho feliz.
4. A sala padrão não serve: **uma** ReservationLine SALA para outra Room (capacidade ≥ vagas, com AccessibilityFeature). Não há botão “segurar a sala padrão”.
5. **Climax:** a aula fica com Resource retido e sala efetiva = Room da exceção; a padrão libera naquela data+faixa. Caio, em S9, passará a ver a efetiva. Marina cancela se precisar: a faixa volta; sala efetiva volta à padrão. Em S7 em nenhum momento aparece a lista de Student.

**Falha:** segunda linha SALA na mesma Lesson; Resource tomado; Room sem capacidade/feature; Professor já ocupado na faixa → recusa, sem fila de aprovação. Ad hoc (sem `lessonId`) disponível na mesma zona, rotulado **ad hoc**, não “evento”.

### UJ-4. Caio vê a sala efetiva — não um local mentiroso.

**Persona + contexto:** Caio, Student; o vínculo com a Class já veio no seed/import.

1. Caio autentica no papel Student. UX-HOME → UX-S9.
2. Lê o plano publicado da disciplina (SyllabusItem, não nota de reserva).
3. Lista as Lesson da(s) turma(s) em que está referenciado: faixa (nunca hora solta), tópico, `{components.flag-avaliacao-mark}` se houver.
4. **Climax:** *onde* = `{components.sala-efetiva-chip}`. Se Marina trocou a sala, Caio vê só a efetiva — a padrão não está na linha. Aula remota: “remoto”, sem Room.

**Falha:** sem Class no seed → empty state, sem “matricular”. Tentativa de escrever alocação: controles inexistentes. Lesson remota não mostra Room.

## Open Questions (UX)

| ID | Status | Efeito na UI |
|---|---|---|
| OQ-1 | **Fechada (2026-11-24)** | UX do próprio serviço; shell + employees = Prof. Arruda. Mapa vigente no companion 2026-11-23 / `capability-map.md`. |
| OQ-2 | Default de demo no PRD | Employee desativado: Class somente leitura; nova Reservation recusada; sem fluxo de substituir Professor. |
| OQ-3 | Aberto | LessonTopic em S7: `[ASSUMPTION]` pelo menos um de `syllabusItemId` ou enunciado extra até o PRD fechar. |

Stack, Keycloak, submódulos Git, OpenAPI: addendum do PRD, não este spine.
