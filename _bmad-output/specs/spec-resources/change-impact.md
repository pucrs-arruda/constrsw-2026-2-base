# Resources Change Impact — Upstream Artifacts

Status: **handoff only**. No PRD, UX, or architecture file was edited in this run. Line numbers refer to the current versions listed below; re-locate by heading if a source has changed. The **v1.1 delta** section below extends the v1.0 handoff and must be applied together with it.

| Source | Version / date | Path |
|---|---|---|
| PRD | 2026-08-24 | `_bmad-output/planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/prd.md` |
| PRD addendum | 2026-08-24 | `_bmad-output/planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/addendum.md` |
| UX DESIGN | 2026-08-24 | `_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-08-24/DESIGN.md` |
| UX EXPERIENCE | 2026-08-24 | `_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-08-24/EXPERIENCE.md` |
| Architecture spine | 2026-08-24 | `_bmad-output/planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md` |

**Language rule for the edits:** the PRD, addendum, UX, and architecture are Portuguese documents. Apply the proposed wording in Portuguese there, even though this handoff is in English. The resources contract itself is English (`SPEC-resources`).

## Summary

| Area | Required | Recommended | Blocking for the resources group |
|---|---:|---:|---|
| PRD glossary + FR-22 + assumptions | 5 | 4 | Yes |
| PRD FR-23 / NFR-CTR / SM | 3 | 1 | No, but prevents drift |
| Addendum pair/attributes/screens/alternatives | 4 | 2 | Yes for the pair table |
| UX EXPERIENCE (UX-S3, language, components, states, flows) | 6 | 3 | No, but the UI contract will be stale |
| UX DESIGN (master-detail, status pill) | 2 | 1 | No, but visual behavior will be undefined |
| Architecture (AD-1, AD-5, equality, capability map) | 4 | 2 | Yes for equality/capability map |

## v1.1 delta — type expansion, audit actors, tags (lifecycle simplified in v1.3)

Added on 2026-10-27. These edits are additive to the sections below; where a v1.0 proposal says `OPEN → RESOLVED` only, this delta wins.

| # | Artifact | Required edit |
|---|---|---|
| D-1 | PRD glossary, `prd.md` | Add **Occurrence** states: `OPEN` (registrada), `RESOLVED` (resolvida). Add **auditoria da ocorrência**: `reportedBy` (quem registrou) e `resolvedBy` (quem resolveu), uuid de funcionário. Não existe estado intermediário nem responsável atribuído. |
| D-2 | PRD FR-22, `prd.md:325` | Extend the Occurrence attribute list with `reportedBy` and `resolvedBy`. Keep "nasce OPEN e transita uma única vez para RESOLVED; RESOLVED é terminal". Add: "toda escrita de ocorrência exige token com `employeeId`". |
| D-3 | PRD FR-22 consequences | Add: "`resource_type` cobre PROJECTOR, HEALTH_KIT, COMPUTER, NOTEBOOK, CAMERA, MICROPHONE, DISPLAY, CABLE, ADAPTER; não há valor OTHER: equipamento fora da lista exige migração de enum. O tipo é descritivo e não altera elegibilidade". |
| D-4 | Addendum pair table, `addendum.md:48` | Occurrence gains `status` (2 valores: OPEN, RESOLVED), `reportedBy`, `resolvedBy`. Note: sem FK cross-context para employees. |
| D-5 | Addendum principal attributes, `addendum.md:62` | Add `reportedBy` and `resolvedBy`; note that `status`, `resolvedBy`, `resolvedAt` são do servidor. |
| D-6 | UX EXPERIENCE, state patterns, `EXPERIENCE.md:130-160` | Two statuses in the `status-pill` (Aberta, Resolvida); only the action "Resolver" (obrigatório informar resolução). Show `reportedBy`, `resolvedBy`, `resolvedAt`. |
| D-7 | UX EXPERIENCE, key flow UJ-1, `EXPERIENCE.md:242` | Insert the start step between record and resolve; keep the immediate-resolve path. |
| D-8 | UX DESIGN, `status-pill`, `DESIGN.md:237` | Third state variant for EM ANDAMENTO; status not conveyed by color alone. |
| D-9 | Architecture, AD-1 write map, `ARCHITECTURE-SPINE.md:65` | Add the `PATCH occurrence` action body (`START`/`RESOLVE`) and the `employeeId` claim requirement. |
| D-10 | Architecture, capability map, `ARCHITECTURE-SPINE.md:291` | CAP-6 stays "Resolve Occurrence" (single transition); CAP-9 keeps only `openOccurrenceCount`. |

Portuguese wording for the PRD glossary:

> **Ocorrência** — evento 1–N de um Resource (falha, dano, extravio, outro), com `status` OPEN ou RESOLVED, resolução quando concluída e auditoria de quem registrou (`reportedBy`) e de quem resolveu (`resolvedBy`).

Portuguese wording for the lifecycle sentence:

> A Occurrence nasce OPEN e transita uma única vez para RESOLVED; RESOLVED é terminal, sem reabrir nem editar.

Until these edits land, `SPEC-resources` v1.1 remains authoritative for the resources context.

| D-11 | PRD FR-22 + addendum, attributes | `tags` é atributo multivalorado normalizado em `resource_tags (resource_id, tag)`, PK composta, 0–10 por Resource, `ON DELETE CASCADE`. O contrato HTTP continua expondo `tags` como array ordenado. |
| D-12 | UX-S3 / EXPERIENCE | O seletor de tipo lista 9 opções e não tem "Outro"; o campo de tags continua aceitando 0–10 etiquetas. |

Decision log for the delta (2026-10-28): no `OTHER` fallback for `resource_type`; tags normalized to 1NF; timestamps remain `TIMESTAMP WITH TIME ZONE` (not date-only); no `IN_PROGRESS`/assignee — Occurrence is `OPEN → RESOLVED` only.

## PRD changes

### 1. Glossary — Resource (`prd.md:43`)

Current:

> **Resource** — ativo reservável (kit, projetor, …). Não é Room.

Proposed:

> **Resource** — ativo reservável; **uma unidade física** (Model A), não uma quantidade, estoque ou componente. Não é Room.

Reason: Model A changes the meaning from a catalog asset to one physical unit.

### 2. Glossary — InventoryItem (`prd.md:44`)

Current:

> **InventoryItem** — item 1–N do Resource (identificador, descrição, estado).

Proposed:

> **Occurrence** — ocorrência 1–N do Resource (descrição, tipo, prioridade, situação, resolução). Substitui InventoryItem; não existe entidade nem tabela `inventory_items`. `createdAt` é do servidor e substitui o antigo `dataHora`.

Reason: the required model replacement. Delete the InventoryItem definition; do not keep both.

### 3. §5.8 introduction (`prd.md:323`)

Current:

> Resource ≠ Room. Reserva de Resource é o caminho feliz. Realiza UJ-1, UJ-3. Fora: §7.

Proposed:

> Resource ≠ Room. Cada Resource é **uma unidade física reservável** e tem Occurrence 1–N. Reserva de Resource é o caminho feliz. Realiza UJ-1, UJ-3. Fora: §7.

Reason: establishes the pair and Model A before FR-22.

### 4. FR-22 — replace the whole section (`prd.md:325-333`)

The current FR-22 says Resource and InventoryItem with `identificador`, `descrição`, `estado`. Replace the title, body, and consequences with:

```markdown
#### FR-22: Cadastrar Resource e registrar ocorrências

Funcionário mantém Resource (`id`, `code`, `name`, `type`, `active`, `tags`) e Occurrence 1–N (`id`, `resourceId`, `description`, `type`, `priority`, `status`, `resolution`, `createdAt`, `resolvedAt`, `updatedAt`).

**Consequences (testable):**
- Resource não é especialização de Room; um Resource é uma unidade física reservável (Model A).
- `code` é obrigatório, único, maiúsculo, imutável, 3–32 caracteres, `^[A-Z0-9]+(-[A-Z0-9]+)*$`.
- `active` é o único gate de Reservation; uma Occurrence OPEN não bloqueia Reservation; o funcionário desativa o Resource quando ele está inutilizável.
- Occurrence nasce OPEN e só transita para RESOLVED; não há reabrir nem excluir; `createdAt`, `updatedAt` e `resolvedAt` são do servidor.
- `resolution` é obrigatória e não vazia ao resolver; `resolvedAt >= createdAt`.
- Não existe entidade nem tabela `inventory_items`; não existe `estado` de InventoryItem.
- Resource inativo não confirma Reservation (FR-23).
- O antigo `dataHora` não existe; `createdAt` é o horário de registro, não o horário do evento.
```

Reason: this is the primary source rewrite. It preserves FR-22's authority over Resource registration while moving the secondary class to Occurrence.

### 5. FR-23 — preserve semantics with an explicit occurrence clause (`prd.md:339-346`)

Do **not** change the reservation rules. Add one sentence after the consequences:

> Uma Occurrence OPEN não bloqueia nem altera `Resource.active`; somente `active` participa da recusa de FR-23.

Reason: prevents a future reader from treating an open occurrence as an availability signal. The resources context must not become a second reservation gate.

### 6. NFR-CTR-2 — write map (`prd.md:435`)

Current:

> ... funcionário escreve Employee, Room, Resource e cria Professor ...

Proposed:

> ... funcionário escreve Employee, Room, Resource, Occurrence e cria Professor ...

Reason: occurrence create/resolve are `funcionario` writes. Without this, the authorization matrix is incomplete.

### 7. NFR-CTR-1 — consumer boundary (`prd.md:434`)

Current:

> `reservations` consome Lesson (se houver), Room, Resource, Professor.

Proposed:

> `reservations` consome Lesson (se houver), Room, Resource (id e active), Professor. Não consome Occurrence.

Reason: makes the integration boundary explicit. Reservations never reads occurrence history.

### 8. SM-4 — pair validation (`prd.md:469`)

Current:

> ... Valida FR-2/6/8/12/14/21/22 (pares), FR-26, FR-27, FR-28.

Proposed:

> ... Valida FR-2/6/8/12/14/21/22 (pares; o par de FR-22 é Resource/Occurrence), FR-26, FR-27, FR-28.

Reason: the pair name changed; the metric otherwise hides the replacement.

### 9. Assumptions Index (`prd.md:503`)

Remove the row:

> `estado` v1 de InventoryItem: disponível \| indisponível | FR-22

Add these rows (or equivalent):

| Assumption | Where |
|---|---|
| Uma Occurrence OPEN não bloqueia Reservation; `active` é o único gate | FR-22, FR-23 |
| `resolution` é obrigatória e não vazia ao resolver; `resolvedAt` é do servidor | FR-22 |
| Não há reabrir nem excluir Occurrence na v1 | FR-22 |
| Várias Occurrences OPEN por Resource são permitidas | FR-22 |
| Não há auditoria de autor (`reportedBy`/`resolvedBy`) na v1 | FR-22 |

Reason: the old assumption is obsolete; the replacement records the decisions a reader would otherwise have to infer.

### 10. Non-Goals — recommended (`prd.md:455-465`)

Add to §7:

- Modelo de estoque, quantidade, componentes de kit ou número de série.
- Excluir, reabrir ou corrigir uma Occurrence resolvida.
- `occurredAt` separado de `createdAt`.
- Cancelamento automático de Reservation ao desativar um Resource.

Reason: these are the boundaries the resources spec explicitly excludes; without them, downstream may assume a richer asset model.

### 11. UJ-1 / Open Questions — recommended

- **UJ-1 (`prd.md:72`):** add “e registra uma Occurrence quando o recurso apresenta defeito” to Helena's master-data journey, or add a short occurrence flow. The current UJ-1 stops at Resource creation; occurrence recording has no named journey.
- **§10 (`prd.md:490-497`):** add open questions for actor audit, `occurredAt`, code reuse after retirement, and deactivation-vs-existing-reservations. The resources spec lists them as OQ-R1, OQ-R5, OQ-R7, OQ-R8.

## Addendum changes

### 12. Pair table (`addendum.md:48`)

Current:

> | `resources` | Resource | InventoryItem | identificador, descrição, estado |

Proposed:

> | `resources` | Resource | Occurrence | descrição, tipo, prioridade, situação, resolução; `createdAt`/`resolvedAt` |

Also change the section heading at `addendum.md:39` from “Pares 1–N e atributos v1 (herdados)” to “Pares 1–N e atributos v1” because the resources pair is no longer inherited unchanged.

Reason: the pair table is the canonical one-glance contract for all nine groups.

### 13. Principal attributes (`addendum.md:62`)

Current:

> | Resource | `id`, nome, tipo (kit, projetor, …), ativo |

Proposed:

> | Resource | `id`, `code`, `name`, `type` (`PROJECTOR`, `KIT`, `COMPUTER`, `AUDIO_VISUAL`, `OTHER`), `active`, `tags` |

Add a note below the table:

> `resources`: Resource 1–N Occurrence. `active` é o único gate de Reservation; Occurrence OPEN não bloqueia. O antigo `dataHora` foi substituído por `createdAt` (servidor).

Reason: Resource fields and the gate rule changed; the principal table must match the API.

### 14. Screens v1 (`addendum.md:79`)

Current:

> | Room + AccessibilityFeature; Resource + InventoryItem | Funcionário | Cadastro-mestre de espaço e recurso |

Proposed:

> | Room + AccessibilityFeature; Resource + Occurrence | Funcionário | Cadastro-mestre de espaço e recurso; registrar e resolver ocorrências |

Reason: the screen's secondary class is Occurrence; it is still one UX-S3 surface with two zones.

### 15. Rejected alternatives (`addendum.md:87-107`)

Add rows:

| Alternative | Why not |
|---|---|
| `InventoryItem` as a nested item list or separate entity/table | Replaced by Occurrence; Model A treats each Resource as one physical unit. |
| Quantity, stock, kit components, or serial-number tracking | Out of v1; a `KIT` is one reservable unit. |
| Delete, reopen, or edit a resolved Occurrence | Out of v1; a new Occurrence is the workaround. |
| Automatic reservation block or resource deactivation from an OPEN occurrence | `active` is the only gate; staff deactivates explicitly. |

Reason: records the design choices that would otherwise be re-litigated.

### 16. Known gaps (`addendum.md:109-117`)

Add bullets:

- No actor audit on occurrences (`reportedBy`/`resolvedBy`).
- No quantity/stock/component model; a KIT is one unit.
- No `occurredAt`; `createdAt` is report time.
- No automatic cancellation of existing reservations when a resource is deactivated.
- No reopen/delete/correction workflow for occurrences.
- The BFF `openOccurrenceCount` is an N+1 read at lab scale.

Reason: makes the v1 boundaries explicit and points to the resources spec's open questions.

## UX EXPERIENCE changes

### 17. Information Architecture — UX-S3 (`EXPERIENCE.md:36`)

Current:

> | UX-S3 | Room + AccessibilityFeature; Resource + InventoryItem | Home / nav (Funcionário) | Cadastro-mestre de espaço e recurso (duas zonas, uma superfície) | Exclusiva — OQ-1 |

Proposed:

> | UX-S3 | Room + AccessibilityFeature; Resource + Occurrence | Home / nav (Funcionário) | Cadastro-mestre de espaço e recurso (duas zonas, uma superfície); registrar e resolver ocorrências | Exclusiva — OQ-1 |

Reason: the surface inventory must name the new secondary class.

### 18. Surface partition (`EXPERIENCE.md:68`)

Add to the UX-S3 sentence:

> Na zona Resource, Occurrence é a secundária 1–N; não é uma tela separada e não cria secundária órfã.

Reason: preserves the one-surface/two-zone decision and the master-detail rule.

### 19. Locked UI language (`EXPERIENCE.md:86`)

Replace the token `InventoryItem` with `Occurrence` in the “Usar” row. Keep the rest of the row:

> EmploymentBond, AcademicDegree, SyllabusItem, WeeklySlot, LessonTopic, AccessibilityFeature, Occurrence, ReservationLine

Reason: the UI must not display a domain entity that no longer exists.

### 20. Component Patterns — master-detail-panel (`EXPERIENCE.md:117`)

Current:

> ... (EmploymentBond, AcademicDegree, SyllabusItem, WeeklySlot, LessonTopic, AccessibilityFeature, InventoryItem, ReservationLine). ...

Proposed:

> ... (EmploymentBond, AcademicDegree, SyllabusItem, WeeklySlot, LessonTopic, AccessibilityFeature, Occurrence, ReservationLine). A lista de Occurrences é ordenada por `createdAt` decrescente; a criação só existe com o Resource selecionado.

Reason: aligns the component rule with the aggregate shape and the no-orphan invariant.

### 21. Component Patterns — status-pill (`EXPERIENCE.md:128`)

Current:

> | status-pill | S1–S3, S7, S9 | Ativo/inativo; presencial/remoto; Reservation ad hoc vs ligada à aula. |

Proposed:

> | status-pill | S1–S3, S7, S9 | Ativo/inativo; presencial/remoto; Reservation ad hoc vs ligada à aula; Occurrence OPEN/RESOLVED. Prioridade é texto, não a cor de warning reservada a `flag-avaliacao-mark`. |

Reason: occurrence status needs a defined visual behavior without stealing the warning token.

### 22. Component Patterns — refusal-banner (`EXPERIENCE.md:121`)

Add to the list of named refusals:

> código de Resource duplicado; Occurrence já resolvida.

Reason: the resources 409 reasons must map to the existing refusal banner.

### 23. Component Patterns — empty-state (`EXPERIENCE.md:124`)

Add:

> S3 (zona Resource): “Nenhuma ocorrência ainda.” + registrar, para `funcionário`.

Reason: the occurrence secondary needs an empty state; it is not an orphan page.

### 24. State Patterns — add occurrence states (`EXPERIENCE.md:130-160`)

Add rows to the State Patterns table:

| Estado | Superfície | Tratamento |
|---|---|---|
| Occurrence OPEN | UX-S3 zona Resource | `status-pill` OPEN; o Resource continua com o `active` atual; o badge `openOccurrenceCount` é informativo. |
| Occurrence RESOLVED | UX-S3 zona Resource | `status-pill` RESOLVED; resolução e `resolvedAt` visíveis; sem botão de reabrir ou excluir. |
| Recusa FR-22 — código duplicado | UX-S3 zona Resource | `refusal-banner` com o `detail`/`reason` do servidor; formulário retido; `code` não é alterado. |
| Recusa FR-22 — Occurrence já resolvida | UX-S3 zona Resource | `refusal-banner`; a linha permanece RESOLVED; nenhuma segunda resolução. |
| Várias Occurrences OPEN | UX-S3 zona Resource | Todas listadas; o badge reflete a contagem; nenhuma bloqueia Reservation. |
| Empty Occurrences | UX-S3 zona Resource | Empty state; um primário “Registrar ocorrência” para `funcionário`. |

Reason: the states are new and must not be inferred from the Reservation surface.

### 25. Key Flows — UJ-1 (`EXPERIENCE.md:242`)

Current:

> 4. Em UX-S3 cadastra a Room (capacidade + pelo menos um AccessibilityFeature) e um Resource com InventoryItem.

Proposed:

> 4. Em UX-S3 cadastra a Room (capacidade + pelo menos um AccessibilityFeature), um Resource e, quando aplicável, uma Occurrence com descrição, tipo e prioridade.

Reason: UJ-1 is the only flow that reaches UX-S3's Resource zone; occurrence recording needs a named step.

### 26. Home card — recommended (`EXPERIENCE.md:226`)

Change the Funcionário card:

> Cadastrar Room e Resource → S3

to:

> Cadastrar Room, Resource e ocorrências → S3

Reason: discoverability; optional if the surface label already covers it.

### 27. Open Questions (UX) — recommended (`EXPERIENCE.md:288-294`)

Add rows for the resources open questions that affect UX:

| ID | Status | Effect |
|---|---|---|
| OQ-R1 | Open | Actor audit (`reportedBy`/`resolvedBy`) would add read-only fields to the occurrence list. |
| OQ-R2 | Open | Reopen/correction would add a control that v1 forbids. |
| OQ-R9 | Open | Visible label “Occurrence” vs “Ocorrência”. |

Reason: the UX should not silently decide product questions the spec leaves open.

## UX DESIGN changes

### 28. `master-detail-panel` (`DESIGN.md:231`)

Replace `InventoryItem` with `Occurrence` in the secondary list:

> ... (EmploymentBond, AcademicDegree, SyllabusItem, WeeklySlot, LessonTopic, ReservationLine, AccessibilityFeature, Occurrence). A secundária nunca vira página órfã.

Reason: the component's contract names every secondary class in the product.

### 29. `status-pill` (`DESIGN.md:237`)

Current:

> Ativo / inativo / presencial / remoto / ad hoc. Cores muted ou primary; nunca accent.

Proposed:

> Ativo / inativo / presencial / remoto / ad hoc / Occurrence OPEN / Occurrence RESOLVED. Cores muted ou primary; nunca accent. Prioridade de Occurrence é texto, não `warning` (warning fica reservado a `flag-avaliacao-mark`).

Reason: defines the visual treatment without adding colors or misusing the accent/warning tokens.

### 30. Design note — recommended

Add a line to `DESIGN.md` under Components or Do's and Don'ts:

> Occurrence não é sala efetiva: o token `accent` não aparece por causa de uma ocorrência; `openOccurrenceCount` é um badge muted, não um alerta vermelho.

Reason: prevents the new entity from inheriting the accent/warning semantics reserved for room exceptions and assessment flags.

## Architecture spine changes

### 31. AD-1 write map (`ARCHITECTURE-SPINE.md:65`)

Current:

> ... (funcionário: Employee/Room/Resource/cria Professor; coordenador: Course/Class; ...)

Proposed:

> ... (funcionário: Employee/Room/Resource/Occurrence/cria Professor; coordenador: Course/Class; ...)

Reason: occurrence create/resolve are domain writes; the dependency/write map must include them.

### 32. AD-5 reservation gate (`ARCHITECTURE-SPINE.md:129`)

Current sentence:

> FR-23/24/30 usam o mesmo union de sala e professor **mais** Recurso tomado/inativo (só linhas RECURSO); ...

Add after it:

> `Resource.active` é o único gate de Recurso; uma Occurrence OPEN não entra no union, não bloqueia e não desativa. `resources` não expõe rota de availability/occupancy.

Reason: the architecture's merge rule must state that occurrences are not reservation occupancy. Without this, an implementer could add occurrence status to the union.

### 33. Equality rule (`ARCHITECTURE-SPINE.md:163`)

Current:

> ... Room/AccessibilityFeature, Resource/InventoryItem, Class/WeeklySlot, ...

Proposed:

> ... Room/AccessibilityFeature, Resource/Occurrence, Class/WeeklySlot, ...

Add at the end of the cell:

> Occurrence é a única secundária de `resources`; não existe `inventory_items` nem terceira classe.

Reason: the equality rule is the one-glance pair contract for the nine groups.

### 34. Capability → Architecture Map (`ARCHITECTURE-SPINE.md:291`)

Current:

> | FR-22 Resource + InventoryItem | `resources` + UX-S3 zona Resource | AD-1 |

Proposed:

> | FR-22 Resource + Occurrence | `resources` + UX-S3 zona Resource + BFF módulo `resources` | AD-1, AD-2, AD-6 |

Reason: the capability map must name the new pair and the BFF read model. AD-2 covers the error/envelope contract; AD-6 covers the browser-only BFF.

### 35. Deferred — recommended (`ARCHITECTURE-SPINE.md` Deferred)

Add:

- Occurrence actor audit (`reportedBy`/`resolvedBy`), reopen/correction, `occurredAt`.
- Quantity/stock/component tracking; a KIT is one unit in v1.

Reason: records the deferred model growth so it is not smuggled into the resources service.

## Cross-checks after the source edits

1. **Glossary consistency:** no occurrence of `InventoryItem` remains in PRD, addendum, UX, or architecture, except in a historical/rejected-alternatives note.
2. **Pair consistency:** every pair list shows `Resource/Occurrence`; the addendum table and the architecture equality rule match.
3. **FR-22/FR-23 consistency:** FR-22 describes Resource + Occurrence; FR-23 still refuses only on Resource occupancy, active state, or Professor conflict; an OPEN occurrence never appears in the FR-23 refusal list.
4. **Screen consistency:** UX-S3 remains one surface with Room and Resource zones; the Resource zone's secondary is Occurrence; no roster appears.
5. **Architecture consistency:** AD-5's union still excludes occurrences; the capability map row names the BFF module; AD-1's write map includes occurrences.
6. **API consistency:** the PRD/UX prose does not introduce `dataHora`, `identifier`, `estado`, `inventory_items`, DELETE, reopen, or availability/occupancy routes.
7. **Ownership:** OQ-1 (group ↔ UX-S*) remains open; these edits do not assign UX-S3 to the resources group.

## Not changed by this handoff

- FR-13/FR-15/FR-24 Reservation rules, room capacity, accessibility, and the effective-room derivation.
- The nine-context mesh, the BFF ownership model, the Keycloak gateway model, or the frontend-crossing rule.
- The canonical faixa table (A–E, F–N, P; no E1, E2, O).
- The LGPD boundary: no Student/roster data in resources or in the BFF resources module.
- The source artifacts themselves. Apply the edits in a separate change, then update the resources spec only if a decision changes.
