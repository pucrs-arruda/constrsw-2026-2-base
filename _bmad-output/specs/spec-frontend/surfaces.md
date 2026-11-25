# Superfícies — Frontend

Inventário canônico da SPA (IDs EXPERIENCE 2026-11-23). Detalhe de fluxo/microcopy: companion EXPERIENCE. Donos: `ownership.md`.

## Menu de topo (ordem fixa)

1. Funcionários  
2. Professores  
3. Alunos  
4. Salas de Aula  
5. Recursos  
6. Disciplinas  
7. Turmas  
8. Ocupação  
9. Plano + roster  
10. Minhas aulas  

Lessons e Reservations **não** entram no menu de topo.

## Catálogo

| ID | Rótulo UI | Chega de | Propósito | BFF / OAuth |
|---|---|---|---|---|
| UX-LOGIN | Login | URL fria / sessão expirada | Autenticar | `POST {oauth}/login` (+ refresh/logout) |
| UX-HOME | Home / app-shell | Login ok | Shell + menu; landing | `GET /api/v1/identidade/me` |
| UX-EMPLOYEES | Funcionários | Menu | Lista + detalhe + dependents | `/api/v1/employees` |
| UX-PROFESSORS | Professores | Menu | Lista + detalhe + academic-degrees + turmas do semestre (`classes` T3) | `/api/v1/professors` |
| UX-STUDENTS | Alunos | Menu | Cadastro + lista + detalhe + AcademicAffiliation + turmas (`classes` T3) | `/api/v1/students` |
| UX-ROOMS | Salas de Aula | Menu | Lista + detalhe + accessibility-features + turmas (`classes` T3) | `/api/v1/rooms` |
| UX-RESOURCES | Recursos | Menu | Lista + detalhe + occurrences + reservations futuras (T3) | `/api/v1/resources` |
| UX-COURSES | Disciplinas | Menu | Lista + detalhe + bibliographic-references + syllabus-items + turmas (`classes` T3) | `/api/v1/courses` |
| UX-CLASSES | Turmas | Menu | Lista + detalhe (**3 abas** Alunos \| Aulas \| Reservas — Figma R07/R08) | `/api/v1/classes` |
| UX-CLASS-ENROLLMENTS | Turma · Alunos | Detalhe turma | Associa/desassocia Students **já cadastrados** | `/api/v1/classes` + lista students |
| UX-CLASS-LESSONS | Turma · Aulas | Detalhe turma | CRUD Lesson (+ `POST /api/v1/lessons/generate`) | `/api/v1/lessons` |
| UX-LESSON-RESERVATIONS | Turma · Reservas / Aula · Reservas | Aba **Reservas** da turma **e** detalhe da aula | Grade do período + Nova reserva (R08C); CRUD Reservation da Lesson (frame 21) | `/api/v1/reservations` |
| UX-OCCUPANCY | Ocupação | Menu | Recursos ocupados em data + faixa (FR-29) | `GET /api/v1/reservations/ocupacao?data=&faixaId=` |
| UX-PROFESSOR-VIEW | Plano + roster | Menu | Leitura composta (FR-31) — cliente junta courses + classes | proxy `/courses`, `/classes` |
| UX-STUDENT-READ | Minhas aulas | Menu | Sala efetiva / tópico / avaliação + plano (FR-19) | proxy `/lessons`, `/students`, `/courses` |

## Hierarquia de escrita

```
Turma (UX-CLASSES)
  ├── Alunos matriculados (UX-CLASS-ENROLLMENTS)
  ├── Aulas (UX-CLASS-LESSONS)
  │     └── (detalhe) Reservas da aula (UX-LESSON-RESERVATIONS)
  └── Reservas (aba) — hub do período (UX-LESSON-RESERVATIONS / Figma R08C)
```

## Composição T3 (leitura)

Cliente **não** envia `year`/`semester`. Semestre: fuso `America/Sao_Paulo`; 1 se mês &lt; agosto, senão 2.

| GET BFF | Campo | Vínculo |
|---|---|---|
| `/api/v1/students` (+`/{id}`) | `classes[]` | `studentIds` contém o estudante |
| `/api/v1/professors` (+`/{id}`) | `classes[]` | `professorId` |
| `/api/v1/courses` (+`/{id}`) | `classes[]` | `courseId` |
| `/api/v1/rooms` (+`/{id}`) | `classes[]` | `roomId` |
| `/api/v1/resources` (+`/{id}`) | `reservations[]` | reservations futuras |

Array vazio se não houver. Falha T3 → 503 + banner; sem montar lista parcial.

## Fora da UI v1

- `classes/.../reviews`
- `GET /health` da BFF como tela
