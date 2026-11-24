---
workflow: bmad-correct-course
date: 2026-11-24
project: constrsw-2026-2
mode: batch
scope_classification: Moderate
status: approved
approved_at: 2026-11-24
approved_by: EduardoArruda
baseline_epics: origin/cursor/epics-frontend-stories-3c61:_bmad-output/planning-artifacts/epics.md
trigger: frontend-coherence-for-quick-dev
user_partition_locked: 2026-11-24
handoff: moderate-po-dev
next_skills: [bmad-spec, bmad-create-epics-and-stories, bmad-check-implementation-readiness, bmad-quick-dev]
---

# Sprint Change Proposal — Frontend coerente para quick-dev

## 1. Issue Summary

**Problema.** O backlog FE (`epics.md`, épicos 0–8) foi gerado pelo CE em 2026-11-24 **antes/fora** do contrato `SPEC-frontend` e ainda materializa **frontend cruzado**. O contrato vigente (`spec-frontend/ownership.md`, EXPERIENCE 2026-11-23, AD-8) fechou OQ-1 como **UX do próprio serviço** (Prof. Arruda = shell + employees). Há também **namespace CAP dual** (produto CAP-1..12 vs SPEC-frontend CAP-1..6) e o `epics.md` **não existe** na branch `cursor/spec-bff-api` (só em `cursor/epics-frontend-stories-3c61`).

**Descoberta.** IR 2026-11-24 nesta branch → “épicos ausentes”; conferência Git → CE já rodou na outra branch; diff conceitual → partição e rastreabilidade divergem do SPEC-frontend.

**Evidência.**

| Fonte | Diz | Conflito |
|---|---|---|
| `epics.md` Overview / FR28 / títulos Epic 1–8 | “partição cruzada”, “FE cruzado” | `ownership.md`: próprio serviço |
| Epic 1 = Grupo 01 Funcionários | G01 faz employees | Arruda faz UX-EMPLOYEES |
| Epic 2–6 = G02…G06 em domínio “cruzado” | ex. G02=professors | ownership: G07=professors, G04=students, … |
| Epic 7 = G07 Turmas+Lessons | um épico | ownership: G01 classes/enrollments + G02 lessons |
| Epic 8 = G08 Reservas+vistas | um épico | ownership: G03 reservas/ocupação + G04 student-read + G07 professor-view |
| `inputDocuments` do epics.md | PRD + closed-cras + UX; **sem** spec-frontend | quick-dev precisa do contrato SPA |
| CAP nas stories/FRs | CAP do produto sem prefixo | SPEC-frontend CAP-1..6 = Login/Shell/Domínio/T3/Hierarquia/Ownership |

**Objetivo.** Deixar artefatos coerentes e stories Ready for Development para `bmad-quick-dev` (sem implementar Angular neste CC).

---

## 2. Impact Analysis

### Checklist (resumo)

| ID | Item | Status |
|---|---|---|
| 1.1–1.3 | Trigger / problema / evidência | [x] Done |
| 2.1–2.5 | Impacto em todos os épicos 0–8 + reordenação | [!] Action-needed — reescrever partição |
| 3.1 | PRD | [!] Action-needed — FR-28 texto vs decisão; OQ-PRD-1 ok |
| 3.2 | Architecture | [x] Done — AD-8 já alinhado; sem mudança estrutural |
| 3.3 | UX EXPERIENCE/DESIGN | [!] leve — coluna CAP produto vs FE-CAP; reviews em UX-CLASSES |
| 3.4 | sprint-status.yaml, contribution, branches | [!] Action-needed |
| 4.1 Direct Adjustment | Viable (reescrever backlog; conteúdo de stories reaproveitável) | Effort Med / Risk Med |
| 4.2 Rollback | Not viable — sem código FE de épicos a reverter | — |
| 4.3 MVP Review | Not needed — MVP UI intacto; só partição/rastreio | — |
| 4.4 Seleção | **Hybrid: Direct Adjustment via CE rewrite** | [x] Done |

### Epic Impact

Todos os épicos 1–8 mudam de **dono** e vários mudam de **escopo de superfície**. Epic 0 absorve employees. Conteúdo de ACs (BFF, GWT, responsivo) em grande parte reaproveitável; metadados Owner/Refs/FR Coverage Map devem ser regenerados.

**Matriz alvo — TRAVADA pelo usuário (2026-11-24)** — alinhada a `ownership.md`; CE não pode alterar donos/superfícies:

| Epic | Dono | Superfícies (somente estas) | Origem do conteúdo atual |
|---|---|---|---|
| 0 | Prof. Arruda | UX-LOGIN, UX-HOME, UX-EMPLOYEES (+ scaffold Angular + kit compartilhado BFF/UI, pré-requisito do shell) | Epic 0 + Epic 1 atual |
| 1 | Grupo 01 (`classes`) | UX-CLASSES, UX-CLASS-ENROLLMENTS | Fatia Epic 7 atual |
| 2 | Grupo 02 (`lessons`) | UX-CLASS-LESSONS | Fatia Epic 7 atual |
| 3 | Grupo 03 (`reservations`) | UX-LESSON-RESERVATIONS, UX-OCCUPANCY | Fatia Epic 8 atual |
| 4 | Grupo 04 (`students`) | UX-STUDENTS, UX-STUDENT-READ | Epic 3 + fatia Epic 8 |
| 5 | Grupo 05 (`courses`) | UX-COURSES | Epic 6 atual |
| 6 | Grupo 06 (`resources`) | UX-RESOURCES | Epic 5 atual |
| 7 | Grupo 07 (`professors`) | UX-PROFESSORS, UX-PROFESSOR-VIEW | Epic 2 + fatia Epic 8 |
| 8 | Grupo 08 (`rooms`) | UX-ROOMS | Epic 4 atual |

Ordem sugerida pós-rewrite: Epic 0 → (1–8 em paralelo após shell) com dependência soft: Lessons (2) após Classes (1); Reservations (3) após Lessons (2).

### Story Impact

- Renumerar stories após merge Epic 0←employees e splits 7/8.
- Toda story: bloco `Refs: SPEC-frontend CAP-N; UX-*; ownership:<dono>; pasta frontend/...`.
- Remover “cruzado” de títulos/overview/FR28 inventory.
- Garantir Ready for Development (GWT, sem TBD, um goal, paths, 360/768/1280).

### Artifact Conflicts

| Artefato | Ação |
|---|---|
| `specs/spec-frontend/*` | Update leve (SP): documentar alias `FE-CAP-N` = CAP-N do kernel; checklist quick-dev; confirmar CAP-6 = ownership próprio serviço |
| `specs/spec-closed-cras` CAP-12 / capability-map / FR-28 | Update se ainda disser cruzado; alinhar a próprio serviço + ponte EXPERIENCE IDs |
| `planning-artifacts/epics.md` | **Rewrite CE** (FR-fonte = SPEC-frontend + ownership) |
| `implementation-artifacts/sprint-status.yaml` | Regenerar IDs de stories pós-CE |
| PRD FR-28 / addendum | Nota de supersede ou patch curto — decisão ownership vence |
| EXPERIENCE | Opcional: coluna CAP → `produto CAP-*` vs `FE-CAP-*`; tirar “reviews” de UX-CLASSES se ainda houver |
| Architecture AD-8 | Sem mudança (já correto) |
| Branch `cursor/spec-bff-api` | Trazer `epics.md` + sprint-status após CE (ou merge da branch de épicos após rewrite) |

### Technical Impact

Nenhum código Angular neste CC. Quick-dev só após CE+IR. Compose/porta 4200 / BFF-only permanecem.

---

## 3. Recommended Approach

**Selecionado: Hybrid — Direct Adjustment via `bmad-create-epics-and-stories` (rewrite), precedido de `bmad-spec` update pontual no frontend (e closed-cras se necessário).**

- **Não** rollback (não há implementação FE dos épicos).
- **Não** cortar MVP de telas — só corrigir donos e refs.
- Reaproveitar ACs existentes onde a superfície não muda.
- Effort: Medium (1 sessão SP + 1 sessão CE + IR). Risk: Medium (renumeração quebra sprint-status antigo — aceitável, tudo ainda backlog).

**Racional.** O gap não é “falta story X”; é **matriz de ownership errada** + **contrato SPA não é FR-fonte**. Patch manual story-a-story é mais arriscado que CE com baseline + matriz alvo.

---

## 4. Detailed Change Proposals

### 4.1 SPEC-frontend (`bmad-spec` update)

**OLD:** Capabilities CAP-1..6 sem alias público para distinguir do produto; contribution aponta quick-dev mas epics não citam o SPEC.

**NEW:**

- Em SPEC.md (ou companion curto `traceability.md`):  
  `FE-CAP-N` ≡ Capability `CAP-N` deste SPEC (não confundir com CAP-N de closed-cras).
- CAP-6 success: reforçar mapa ownership.md (próprio serviço; Arruda = shell+employees).
- Frontmatter / notes: epics FE devem listar este SPEC + companions como inputs obrigatórios.
- Manter IDs CAP-1..6 estáveis.

**Rationale:** desambigua refs para quick-dev e IR.

### 4.2 SPEC-closed-cras (se ainda cruzado)

**OLD (epics inventory):** `FR28: Frontend cruzado — grupo não implementa UI do próprio backend`.

**NEW:** `FR-28 / CAP-12: cada grupo implementa a UX do próprio serviço; Arruda = shell + employees` (alinhar ao PRD memlog 2026-11-24 e ownership.md).

**Rationale:** produto e FE falam a mesma partição.

### 4.3 Epics.md — partição (exemplo de título)

**OLD:**
```
### Epic 1: Funcionários (Grupo 01 — FE cruzado)
### Epic 7: Turmas, matrículas e Aulas (Grupo 07 — FE cruzado)
```

**NEW (títulos alinhados à partição travada):**
```
### Epic 0: Scaffold, auth, shell e Funcionários (Prof. Arruda — UX-LOGIN, UX-HOME, UX-EMPLOYEES)
### Epic 1: Turmas e matrículas (Grupo 01 / classes — UX-CLASSES, UX-CLASS-ENROLLMENTS)
### Epic 2: Aulas da turma (Grupo 02 / lessons — UX-CLASS-LESSONS)
### Epic 3: Reservas e ocupação (Grupo 03 / reservations — UX-LESSON-RESERVATIONS, UX-OCCUPANCY)
### Epic 4: Alunos e minhas aulas (Grupo 04 / students — UX-STUDENTS, UX-STUDENT-READ)
### Epic 5: Disciplinas (Grupo 05 / courses — UX-COURSES)
### Epic 6: Recursos (Grupo 06 / resources — UX-RESOURCES)
### Epic 7: Professores e plano/roster (Grupo 07 / professors — UX-PROFESSORS, UX-PROFESSOR-VIEW)
### Epic 8: Salas de Aula (Grupo 08 / rooms — UX-ROOMS)
```

**Rationale:** 1:1 com a partição travada pelo usuário (= ownership.md / contribution.md).

### 4.4 Story — bloco Refs (template obrigatório)

**OLD:** stories sem `SPEC-frontend`; CAP produto implícito.

**NEW (exemplo Story 0.3):**
```
Refs: SPEC-frontend FE-CAP-1; UX-LOGIN; ownership:Prof. Arruda; paths: frontend/src/app/shell/...
Contract: _bmad-output/specs/spec-frontend/{SPEC,surfaces,ownership,contribution,stack}.md
UX: .../ux-constrsw-2026-2-2026-11-23/{EXPERIENCE,DESIGN}.md
OpenAPI: docs/open-api/bff.yaml
```

### 4.5 FR Coverage Map

Substituir mapa FR1→Epic1 (employees) por:

- FE-CAP-1 → Epic 0 (login/sessão)
- FE-CAP-2 → Epic 0 (shell)
- FE-CAP-3 → Epics 0–8 (master-detail por superfície)
- FE-CAP-4 → Epics com T3/vistas/ocupação (4,6,7,3,…)
- FE-CAP-5 → Epics 1–3 (hierarquia)
- FE-CAP-6 → transversal (ownership/contribution) + Epic 0 employees

Manter FRs de produto como **trace secundário** (closed-cras), não como FR-fonte do FE.

### 4.6 sprint-status.yaml

Regenerar após CE: novos IDs de stories; ordem recomendada Epic 0 → paralelo 1–8 com deps 1→2→3; remover IDs cruzados antigos.

### 4.7 PRD / UX

- PRD: addendum ou nota “FR-28 supersedido por ownership 2026-11-24 (próprio serviço)” se o corpo ainda disser cruzado.
- EXPERIENCE: opcional — renomear coluna CAP para `produto CAP`; garantir UX-CLASSES sem reviews na v1.

### 4.8 Architecture

Nenhuma edição obrigatória (AD-8 já Angular + próprio serviço).

---

## 5. Implementation Handoff

**Scope classification: Moderate** — reorganização de backlog + updates de SPEC; sem código de domínio.

### Sequência pós-aprovação (janelas novas)

1. **SP** `bmad-spec` — update `spec-frontend` (+ closed-cras se checklist SP achar cruzado residual).
2. **CE** `bmad-create-epics-and-stories` — rewrite `epics.md` (prompt abaixo).
3. **IR** `bmad-check-implementation-readiness` — escopo FE; meta Ready / Ready with gaps.
4. **QQ** `bmad-quick-dev` — Story 0.1 primeiro (prompt abaixo); depois 0.2… e épicos de grupo.

### Responsáveis

| Papel | Entrega |
|---|---|
| PO / Spec | Aprovar proposal; SP updates |
| PO / CE | Rewrite epics + sprint-status |
| IR | Gate de coerência |
| Dev (QQ) | Implementar story a story |

### Success criteria

- [ ] `epics.md` na branch de trabalho (não só na remota de épicos)
- [ ] Zero menção operacional a “FE cruzado” / “grupo não implementa UI do próprio”
- [ ] 15/15 UX-* com story dona = ownership.md
- [ ] Toda story com `Refs: SPEC-frontend FE-CAP-*` + UX-* + paths
- [ ] IR frontend ≠ Not ready por cobertura/ownership
- [ ] Story 0.1 passa checklist Ready for Development do quick-dev

### MVP

MVP de telas **inalterado**. OQ-PRD-1 permanece: cadastro Student na UI.

---

## 6. Prompt pronto — CE (reescrever epics)

```text
Rode bmad-create-epics-and-stories (rewrite / update do breakdown FE).

Baseline a preservar (conteúdo de ACs, não a partição cruzada):
- origin/cursor/epics-frontend-stories-3c61 → _bmad-output/planning-artifacts/epics.md
- sprint-status em _bmad-output/implementation-artifacts/sprint-status.yaml (mesma branch)

FR-fonte canônica (obrigatório nos inputDocuments):
- _bmad-output/specs/spec-frontend/SPEC.md (FE-CAP-1..6)
- surfaces.md, ownership.md, contribution.md, stack.md
- EXPERIENCE.md + DESIGN.md (ux-…-2026-11-23)
- docs/open-api/bff.yaml
Trace secundário: PRD + SPEC-closed-cras (não ditam dono de superfície).

Partição OBRIGATÓRIA — travada pelo usuário 2026-11-24 (próprio serviço, NÃO cruzado; não reordenar donos):
- Prof. Arruda → Epic 0: UX-LOGIN, UX-HOME, UX-EMPLOYEES (+ scaffold + kit compartilhado)
- Grupo 01 (classes) → Epic 1: UX-CLASSES, UX-CLASS-ENROLLMENTS
- Grupo 02 (lessons) → Epic 2: UX-CLASS-LESSONS
- Grupo 03 (reservations) → Epic 3: UX-LESSON-RESERVATIONS, UX-OCCUPANCY
- Grupo 04 (students) → Epic 4: UX-STUDENTS, UX-STUDENT-READ
- Grupo 05 (courses) → Epic 5: UX-COURSES
- Grupo 06 (resources) → Epic 6: UX-RESOURCES
- Grupo 07 (professors) → Epic 7: UX-PROFESSORS, UX-PROFESSOR-VIEW
- Grupo 08 (rooms) → Epic 8: UX-ROOMS

Regras de story:
- Refs: SPEC-frontend FE-CAP-N; UX-*; ownership; path sob frontend/
- ACs Given/When/Then; BFF-only; oauth-only; pt-BR; 360/768/1280
- Sem reviews UI; Lessons/Reservations fora do menu de topo
- Ready for Development para bmad-quick-dev (um goal; sem TBD)

Saída: _bmad-output/planning-artifacts/epics.md + sprint-status.yaml regenerado.
Fale pt-BR. Não implemente código.
```

---

## 7. Prompt pronto — QQ Story 0.1

```text
Rode bmad-quick-dev.

Intent: implementar Story 0.1 do epics.md FE (após CE aprovado) — Scaffold Angular 22 + Material + tema DESIGN em frontend/.

Contrato (ler nesta ordem):
- Story 0.1 em _bmad-output/planning-artifacts/epics.md
- _bmad-output/specs/spec-frontend/{SPEC,stack,contribution,ownership}.md
- EXPERIENCE.md + DESIGN.md (ux-…-2026-11-23)
Não inventar stack (proibido React/Vite/TanStack/keycloak-js).

Escopo: só scaffold + tema tokens + wire Compose/porta 4200 + shell em branco responsivo 360/768/1280.
Fora: login completo (0.3), HTTP kit (0.5), superfícies de domínio.

ACs da story são a verdade de aceite. Entregar código reviewável no submódulo frontend/ + ponteiro no repo base se necessário.
pt-BR na UI. Não imprimir .env.
```

---

## 8. Approval & Handoff Log

- **2026-11-24:** Review Continue [c]; Edit aplicou partição travada pelo usuário; Approval = **yes**.
- **Scope:** Moderate → PO/DEV (reorganização de backlog + updates de SPEC). Sem implementação Angular neste CC.
- **sprint-status.yaml:** não regenerado aqui — fica a cargo do CE pós-rewrite (checklist 6.4).
- **Working tree:** `epics.md` copiado da baseline para análise; ainda reflete partição cruzada até o CE.

### Next steps (janelas novas, nesta ordem)

1. `[SP]` `bmad-spec` — update `spec-frontend` (alias FE-CAP; CAP-6/ownership).
2. `[CE]` `bmad-create-epics-and-stories` — prompt §6 do proposal (partição travada).
3. `[IR]` `bmad-check-implementation-readiness` — escopo FE.
4. `[QQ]` `bmad-quick-dev` — prompt §7 (Story 0.1).
