# Contribuição por grupo — Frontend

A SPA é compartilhada: **sem dono exclusivo** (exceto shell + employees = Prof. Arruda). Cada grupo entrega as superfícies do próprio contexto.

## Checklist da superfície

1. Criar/atualizar pasta da superfície sob `frontend/` (ex. `src/app/surfaces/<id>/` ou convenção já adotada no scaffold).
2. Registrar rota no roteador do shell; item de menu só se a superfície estiver no menu de topo (`surfaces.md`).
3. Consumir **somente** BFF (`/api/v1/...`) e oauth (`/login`, `/refresh`, `/logout`) — nunca OpenAPI de domínio direto.
4. Aplicar tokens SCSS / tema de `DESIGN.md`; componentes Material da tabela EXPERIENCE (Component Patterns).
5. Estados: cold skeleton, empty pt-BR, refusal-banner, banner 503 de composição quando a superfície usa T3.
6. Testes: unit do componente/serviço da superfície; E2E da jornada do domínio quando a stack Compose do domínio + BFF estiver no ar.
7. Não alterar superfícies de outro dono sem coordenação (`ownership.md`).
8. Mudanças no shell (UX-LOGIN/HOME) ou em shared UI exigem alinhamento com Prof. Arruda.

## Escopo típico por dono

| Dono | Escopo no `frontend/` |
|---|---|
| Prof. Arruda | `shell` (LOGIN, HOME, app-shell, nav) + `ux-employees` |
| Grupo 01 | `ux-classes` + aba enrollments |
| Grupo 02 | `ux-class-lessons` (aba Aulas) |
| Grupo 03 | `ux-lesson-reservations` + `ux-occupancy` |
| Grupo 04 | `ux-students` + `ux-student-read` |
| Grupo 05 | `ux-courses` |
| Grupo 06 | `ux-resources` |
| Grupo 07 | `ux-professors` + `ux-professor-view` |
| Grupo 08 | `ux-rooms` |

## O que não fazer

- Inventar segunda SPA ou tema fora de `DESIGN.md`.
- Colocar Lessons/Reservations no menu de topo.
- Chamar Keycloak no browser.
- Commitar só o ponteiro do repo base sem o commit no submódulo `frontend` (e vice-versa).

## Como apontar no bmad-quick-dev / build

```text
_bmad-output/specs/spec-frontend/SPEC.md
_bmad-output/specs/spec-frontend/surfaces.md
_bmad-output/specs/spec-frontend/ownership.md
_bmad-output/specs/spec-frontend/contribution.md
_bmad-output/specs/spec-frontend/stack.md
_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/EXPERIENCE.md
_bmad-output/planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-11-23/DESIGN.md
docs/open-api/bff.yaml
docs/open-api/<openapi-do-contexto>.yaml
```

Escopo típico: **somente** as pastas da superfície do dono + registro de rota. Parar se a tarefa exigir alterar shell ou superfície alheia sem coordenação.
