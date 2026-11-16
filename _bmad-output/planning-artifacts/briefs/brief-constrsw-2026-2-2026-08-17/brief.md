---
title: "Product Brief: Malha"
status: draft
created: 2026-08-17
updated: 2026-08-19
---

# Product Brief: Malha

## Resumo

**[ASSUMPTION] Nome de trabalho: Malha.** É a gestão acadêmica e de recursos desta ConstrSW (PUCRS, 2026/2): nove contextos, APIs contract-first, BFF e UI web. Não é pitch de mercado nem substituto de SIS.

**Problema em uma frase:** pessoas e disciplinas já existem (o estudante, noutro sistema); o que quebra é juntar *quem já existe*, *a oferta do período com sala padrão nas faixas da grade* e *o que acontece nesta aula* — e as quatro personas não compartilham a língua (`disciplina` ≠ `turma` ≠ `aula` ≠ `reserva` ≠ `faixa`).

A primeira versão existe para a disciplina ConstrSW: **9 grupos** (um por contexto de domínio; este briefing é do grupo `employees`). Cada grupo entrega o par 1–N do seu contexto **e incorpora esse domínio no BFF e no OAuth** compartilhados — não há grupo separado de BFF/OAuth. A posição é a dos specialists de grade: **mesh de contextos + integração**, não competir com SIGAA, TOTVS ou Ellucian.

## O problema

Pessoas e disciplinas já existem. O funcionário governa cadastro-mestre (staff, professor, sala, recurso) que a alocação precisa consumir — **não** dá alta de estudante. O coordenador escreve currículo e plano soltos da oferta: turma com **sala padrão**, vagas e esqueleto em **dia + faixa**. Sem isso, o professor ou inventa 18 reservas da mesma sala ou o estudante lê um local mentiroso. O estudante não responde *onde / o quê / tem avaliação?* se o *onde* não for a **sala efetiva** da aula.

O atalho errado, neste repositório, é nove CRUDs que reinventam `pessoa` e `espaço`. Suítes colapsam os contextos; planilhas os separam. O custo aqui não é TAM: é demo incoerente, cadastro de aluno inventado, horário fora da grade e plano que não vira dado.

## A solução

UI web + BFF sobre nove APIs de contexto. **Registros** (`students`, `courses`, `professors`, `employees`) publicam identidade e documentos. **Alocação** (`classes`, `lessons`, `rooms`, `resources`, `reservations`) consome esses IDs — não os copia.

`students` persiste identidade **recebida** (seed/import); não há tela de alta. O coordenador publica o plano, abre a turma com sala padrão e esqueleto na grade, e gera as aulas. O professor ajusta conteúdo/flag, reserva **recurso** e **sala só quando troca** a padrão. O estudante lê a **sala efetiva**. O funcionário mantém o cadastro-mestre e consulta ocupação por data + faixa.

Formato travado: **APIs contract-first, BFF, UI web**. Não é app nativo. Não é hardware.

## Quem usa

**Papel ≠ serviço.** A persona opera a jornada; o dono de identidade permanece no contexto.

| Persona | Opera na v1 | Não opera | Sucesso demonstrável |
|---|---|---|---|
| Funcionário | Cadastro de Employee (+ bonds), depois Professor (+ degrees) só se o Employee já existir; sala, recurso; consulta ocupação por **data + faixa** | Folha, ponto, alvará, **alta de estudante**, matrícula, aprovar reserva | O ID de Employee é o que alocação e o papel docente consomem; não há professor órfão de employee |
| Coordenador | Disciplinas da coordenação + plano estruturado, datado antes do período; abre uma ou mais turmas com professor(es), **vagas**, **sala padrão**, período (início/fim) e esqueleto = **lista (seg–sáb, faixa)**; gera aulas; vê turmas e flags | e-MEC/PPC, alta de estudante, confirmar reserva aula a aula | Plano é dado; cada turma tem sala padrão que **cabe nas vagas**; aulas nascem na grade |
| Professor | Ajusta aulas da turma a que está atribuído; referencia o plano; reserva **recurso**; reserva **sala só para trocar** a padrão naquela aula (ou ad hoc); altera/cancela; lê plano e roster | Criar turma/disciplina, cadastrar estudante, editar a tabela de faixas | Não reserva a sala padrão 18 vezes; exceção e recurso sem sobreposição; o estudante vê a sala efetiva |
| Estudante | Só leitura das turmas cujo vínculo **já veio** no seed/import: *onde / o quê / tem avaliação?* | Cadastro, matrícula, reserva, editar plano | Onde = **sala efetiva** da aula (exceção ou padrão); remoto se a aula for remota; nunca horário solto |

**[ASSUMPTION]** Uma UI web com acesso por papel, não quatro produtos. Na ConstrSW, “outro sistema” de estudante = **import/seed**, não SIS ao vivo.

## Escopo da primeira versão

Língua travada (não relitigar): **disciplina ≠ turma ≠ aula ≠ reserva ≠ faixa**. Sala ≠ prédio. Recurso ≠ sala. **Professor is-a Employee** (todo professor é funcionário; nem todo funcionário é professor). Estudante não é Employee. Plano de ensino ≠ nota de reserva. **Sala padrão** da turma ≠ **sala efetiva** da aula. Grade canônica no addendum: A–E, F–N e P; **sem E1, E2 ou O**.

**Equidade entre grupos (não relitigar):** o esquema conceitual de **cada um dos 9 domínios** tem exatamente **duas classes** — uma **principal** (o agregado do contexto) e uma **secundária** em associação **1–N** com a principal (ex.: `Employee` 1–N `Dependent`). IDs de *outros* contextos são atributos, não uma terceira classe. Os módulos `bff` e `oauth` são **compartilhados**: cada grupo incorpora *o seu* domínio neles (rotas/composição no BFF; papéis/escopos no OAuth). `frontend` fica fora do par 1–N. Detalhe no addendum.

### O que cada grupo entrega

| Serviço | Principal 1–N secundária (v1) | Fica para depois (neste grupo) |
|---|---|---|
| `employees` | **Employee** 1–N **Dependent** (identidade da pessoa que trabalha na IES, inclusive quem leciona) | Folha, cargos SIGRH, ponto |
| `professors` | **Professor** 1–N **AcademicDegree**. **Is-a Employee:** `employeeId` obrigatório (1–1); não copia nome/e-mail | Lattes, progressão, encargos completos |
| `students` | **Student** 1–N **AcademicAffiliation** (seed/import; sem UX de alta). Roster da turma fica em `classes` | Histórico, diploma XML, acervo, notas/frequência, SIS ao vivo |
| `courses` | **Course** 1–N **SyllabusItem** (`kind`: conteúdo \| bibliografia \| critério) | Protocolo e-MEC, DCN, autorização/reconhecimento |
| `rooms` | **Room** 1–N **AccessibilityFeature** (capacidade na principal) | Gêmeo digital, BMS/HVAC, planta BIM |
| `resources` | **Resource** 1–N **InventoryItem** | Frota IoT, manutenção preditiva |
| `classes` | **Class** 1–N **WeeklySlot** (sala padrão, vagas, IDs de professor/estudante na principal) | Otimizador de grade |
| `lessons` | **Lesson** 1–N **LessonTopic**; sala efetiva é **derivada** | AVA/LMS, exclusão de feriados |
| `reservations` | **Reservation** 1–N **ReservationLine** (RECURSO e/ou SALA-exceção; ad hoc permitido) | Sensor/no-show, agente de booking |
| `bff` (compartilhado) | Cada grupo incorpora as jornadas que tocam **o seu** domínio (sem par 1–N próprio) | App nativo, portal público MEC |
| `frontend` | UI web das quatro personas (fora do par 1–N). **[ASSUMPTION]** dono da tela ainda não padronizado como o BFF | App nativo, totem, hardware |
| `oauth` (compartilhado) | Cada grupo declara e pluga papéis/escopos do **seu** domínio | Federação CAFe/BAITA de produção |

### Fora da v1 salvo decisão explícita

Diploma XML; otimizador com IA; frota IoT; digital twin; app nativo; hardware; substituir SIGAA/TOTVS/Lyceum/Ellucian; tesouraria/ERP; LMS como produto; tela de cadastro de estudante; faixas E1 e E2; SIS de estudante ao vivo.

## Sucesso (recorte da disciplina)

**[ASSUMPTION]** Não há rubrica numérica da disciplina neste repositório; sucesso é demonstrável em laboratório, não TAM.

A v1 funcionou se, na UI, sem o operador saber em qual microsserviço clicar:

1. Funcionário cadastra staff/espaços/professores e lê ocupação por faixa; não dá alta de estudante. Coordenador publica plano, abre turma(s) com sala padrão e esqueleto na grade, gera aulas. Professor ajusta e reserva só exceção/recurso. Estudante responde onde / o quê / tem avaliação? com **sala efetiva**.
2. Contratos e telas usam a língua travada (incluindo **faixa**); identidade de quem trabalha na IES é **Employee**; **Professor is-a Employee**; estudante só referenciado; alocação não duplica documento pessoal.
3. Sala padrão cabe nas vagas e só se atribui com capacidade e **AccessibilityFeature**. Duas aulas não compartilham a mesma sala efetiva na mesma `data+faixa`. Reserva não confirma sem esses atributos nem com sobreposição de sala, recurso ou professor.
4. Cada um dos 9 grupos entrega o par **principal 1–N secundária** **e** incorpora esse domínio no **BFF** e no **OAuth** compartilhados — não um CRUD genérico, nem uma terceira classe, nem um backend órfão do BFF.

Não é sucesso: share de mercado, NPS de campus, “IA na reserva”, tela de novo estudante, 18 reservas da sala padrão, horário fora da tabela de faixas, nove OpenAPIs com `pessoa` copiada, um grupo com modelo mais rico que os outros.

## O que diferencia (honesto)

Não há moat. O diferencial é **execução e linguagem de domínio**: os mesmos termos na API, no BFF e na UI; registros e alocação separados como os specialists de grade já fazem ao lado do SIS. Se os grupos entregarem nove CRUDs com `pessoa` copiada, o produto falhou — mesmo com todos os endpoints no ar.

## Se der certo

Não vira ERP universitário. Vira evidência de que uma malha contract-first pode sentar *ao lado* do sistema de registro (inclusive do cadastro de estudante que já existe). Censo, evento de ocupação, Edu-API e federação de identidade são caminho posterior — ver addendum — não compromisso desta v1.
