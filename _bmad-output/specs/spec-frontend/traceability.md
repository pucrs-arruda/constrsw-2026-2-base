# Traceability — Frontend

Companion do `SPEC-frontend`. Amarram contrato → épicos/stories → `bmad-quick-dev`.

## Alias de capability

| Neste SPEC | Cite em épicos/stories | Não confundir com |
|---|---|---|
| CAP-1 … CAP-6 | **`FE-CAP-1` … `FE-CAP-6`** | CAP-1 … CAP-12 de `SPEC-closed-cras` (produto) |

`FE-CAP-N` **é** o mesmo ID kernel `CAP-N` deste SPEC — só o prefixo desambigua leitores.

## FR-fonte FE

Contrato obrigatório para CE / IR / quick-dev:

1. `SPEC.md` (este folder)
2. `surfaces.md`, `ownership.md`, `contribution.md`, `stack.md`, este arquivo
3. EXPERIENCE.md + DESIGN.md (ux-…-2026-11-23)
4. `docs/open-api/bff.yaml`

PRD e closed-cras = **trace secundário** (FRs de produto); não ditam dono de superfície.

## Bloco Refs (obrigatório em cada story FE)

```text
Refs: SPEC-frontend FE-CAP-N; UX-*; ownership:<dono>; paths: frontend/...
Contract: _bmad-output/specs/spec-frontend/{SPEC,surfaces,ownership,contribution,stack,traceability}.md
UX: _bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/{EXPERIENCE,DESIGN}.md
OpenAPI: docs/open-api/bff.yaml
```

## Mapa FE-CAP → superfícies (resumo)

| FE-CAP | Superfícies / escopo |
|---|---|
| FE-CAP-1 | UX-LOGIN (+ sessão oauth/Bearer) |
| FE-CAP-2 | UX-HOME / app-shell / menu |
| FE-CAP-3 | Master-detail de domínio (todas as UX de cadastro via BFF) |
| FE-CAP-4 | T3 `classes[]`/`reservations[]`; UX-OCCUPANCY; UX-PROFESSOR-VIEW; UX-STUDENT-READ |
| FE-CAP-5 | UX-CLASSES → UX-CLASS-ENROLLMENTS / UX-CLASS-LESSONS → UX-LESSON-RESERVATIONS |
| FE-CAP-6 | Partição ownership (Arruda + G01–G08); contribution; tokens DESIGN |

Donos por superfície: `ownership.md` (travado 2026-11-24).

## Épicos alvo (pós-CE)

| Epic | Dono | UX-* |
|---|---|---|
| 0 | Prof. Arruda | LOGIN, HOME, EMPLOYEES (+ scaffold/kit) |
| 1 | Grupo 01 | CLASSES, CLASS-ENROLLMENTS |
| 2 | Grupo 02 | CLASS-LESSONS |
| 3 | Grupo 03 | LESSON-RESERVATIONS, OCCUPANCY |
| 4 | Grupo 04 | STUDENTS, STUDENT-READ |
| 5 | Grupo 05 | COURSES |
| 6 | Grupo 06 | RESOURCES |
| 7 | Grupo 07 | PROFESSORS, PROFESSOR-VIEW |
| 8 | Grupo 08 | ROOMS |
