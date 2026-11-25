# Composição T3 — BFF

Normativo para CAP-2 e CAP-3. Schemas: companion adotado `docs/open-api/bff.yaml` (`StudentView`, `CourseView`, `ProfessorView`, `RoomView`, `ResourceView`, `ResourceAggregateView`).

## Semestre em curso

Calculado pela BFF no fuso **America/Sao_Paulo**:

| Campo | Regra |
| --- | --- |
| `year` | Ano civil atual nesse fuso |
| `semester` | `1` se mês &lt; agosto; `2` se mês ≥ agosto |

O cliente **não** envia `year` nem `semester`. Relógio injetável nos testes para cobrir fronteira julho/agosto.

## Quando compor

| GET bem-sucedido (200) | Campo acrescentado | Fonte |
| --- | --- | --- |
| `/api/v1/students`, `/api/v1/students/{id}` | `classes` | `classes` |
| `/api/v1/courses`, `/api/v1/courses/{courseId}` | `classes` | `classes` |
| `/api/v1/professors`, `/api/v1/professors/{id}` | `classes`; `employeeName`; `employeeEmail` (se houver) | `classes` + `employees` |
| `/api/v1/rooms`, `/api/v1/rooms/{id}` | `classes` | `classes` |
| `/api/v1/resources`, `/api/v1/resources/{resourceId}` | `reservations` | `reservations` |

Não compor se o recurso principal não for 200 (400/401/403/404 sobem intactos, sem chamar a dependência de composição quando o contrato do módulo assim definir — preferência: chamar em paralelo só se o principal for 200, ou abortar merge se principal ≠ 200).

POST/PUT/PATCH/DELETE e GETs secundários **não** acrescentam `classes` nem `reservations`.

## Filtro de `classes`

Uma class entra quando pertence ao semestre em curso **e**:

| Recurso | Vínculo |
| --- | --- |
| Student | `studentIds` contém o `id` do estudante |
| Course | `courseId` = id da disciplina |
| Professor | `professorId` = `_id` do professor |
| Room | `roomId` = id da sala |

Classes excluídas logicamente não entram (o serviço `classes` não as devolve). Sem correspondência → `classes: []`. Preferir **uma** consulta de classes por semestre (coleção) em vez de N chamadas por item.

## Display name na vista Professor (OQ-ARCH-2)

No GET de coleção e item de professors, além de `classes`, a BFF resolve o Employee por `employeeId` e acrescenta:

| Campo | Regra |
| --- | --- |
| `employeeName` | Obrigatório; `Employee.name` |
| `employeeEmail` | Presente só se o Employee tiver e-mail; omitido se ausente |

O OpenAPI de `professors` **não** passa a carregar nome/e-mail (is-a continua só `employeeId`). Employee inexistente ou excluído → 503 `BFF-DEPENDENCY` (mesmo tratamento de falha de composição; não inventar nome). Falha de `employees` ou de `classes` → 503 sem professor pela metade.

## Filtro de `reservations` futuras

Uma reservation é futura quando:

1. o resource está em `resourceIds`; e
2. o início da faixa (`data` + horário de início de `faixaId` no cânone oauth) é **posterior** ao instante atual em `America/Sao_Paulo`.

`status` **não** é filtrado. Sem match → `reservations: []`.

Implementação: módulo `src/modules/resources/` (Grupo 06), que lê a coleção de reservations do contexto `reservations`; o contexto `resources` não expõe reservations, availability ou occupancy e não muda por causa desta composição. Falha do hop `reservations` → **503** sem resource pela metade (mesmo envelope do 503 de resources).

## Falha da composição

| Situação | Resposta |
| --- | --- |
| Dependência de composição fora do ar, timeout, circuito aberto, corpo malformado | **503**; recurso principal **não** volta pela metade |
| students / professors / rooms | `application/problem+json` com `code` **`BFF-DEPENDENCY`** (schema `Problem` do `bff.yaml`); em professors inclui falha de `employees` |
| courses / resources | Reutilizar o **503 já no contrato do contexto** também quando classes/reservations falham |

Envelopes **não** são unificados entre contextos (OQ-503-ENVELOPE fechada).

## Anti-padrões

- Recalcular `salaEfetivaId` na BFF.
- Embutir roster (`Class.studentIds`) em respostas de `reservations`.
- Endpoint BFF dedicado para FR-19 ou FR-31.
- Devolver aluno/disciplina/sala/professor sem `classes` quando o GET principal foi 200 e a composição deveria rodar.
