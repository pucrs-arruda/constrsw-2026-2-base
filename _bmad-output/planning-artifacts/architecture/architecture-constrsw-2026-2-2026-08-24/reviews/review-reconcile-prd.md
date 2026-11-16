# Reconcile PRD → Architecture Spine

| | |
|---|---|
| **Lente** | Reconcile de input load-bearing (PRD → spine) |
| **Alvo** | `ARCHITECTURE-SPINE.md` (status: draft, 2026-08-24) |
| **Fonte** | `prd.md` Closed CRAS (status: final, atualizado 2026-08-24) |
| **Não relido como produto** | Glossário §2, UJ-1–UJ-4, personas nominais |
| **Spine alterada?** | Não |
| **Veredito** | **conflict** |

## Escopo desta lente

Pergunta única: o que o PRD exige e a spine **não aterrissou**, **contradisse**, ou **reivindicou no mapa sem carregar na Rule**. Tom, restrição de ConstrSW, consequência testável de FR e NFR cruzado entram. Glossário e jornadas não se relitam. Atributos v1 que o addendum já tabela e a convenção Equidade aponta (“tabela do addendum”) não são gap se o AD não precisava copiá-los.

A spine é build-substrate: omitir detalhe de um único contexto não é achado. Omitir regra que **dois grupos escolheriam de forma incompatível**, ou NFR/FR que o *Capability → Architecture Map* declara governado por um AD que não a contém, é achado.

## Veredito

**conflict.** Há override silencioso de identidade canônica (AD-2 UUID v4 vs FR-7 / FR-10 / FR-25) e uma Rule de recusa (AD-5) que pode ser lida contra FR-13. Em volta disso, o mapa FR/NFR está mais largo que as Rules: várias consequências testáveis e NFRs “quietos” caíram no AD sem texto normativo.

---

## Achados

### C1 — conflict — ID de agregado UUID v4 vs identidade recebida / alinhável

**PRD.** FR-7: Student chega com `id` já existente; o `id` permanece compatível com diploma/Censo (sem emitir XML na v1). FR-10: Course tem `id`/código alinhável a cadastro oficial — `[ASSUMPTION]` isso basta na v1. FR-25: IDs canônicos estáveis do Glossário incluem Student e disciplina (Course). §7: extrato Censo/diploma fora, mas IDs devem permanecer *compatíveis*.

**Spine.** AD-2 Rule: “ID de agregado = UUID v4 (string)” — único regime de identidade, sem campo paralelo `codigo`, sem exceção para identidade recebida, sem “UUID interno + identificador alinhável”.

**Por que é conflito, não defer.** Quem implementar `students` ou `courses` não consegue obedecer os dois textos: ou mint UUID e quebra FR-7/FR-10 (o `id` canônico deixa de ser o do outro sistema / código oficial), ou persiste o id recebido e viola AD-2. O mapa (FR-7/FR-8/FR-9 → convenção Student; FR-10 → AD-1, AD-2) dá a impressão de cobertura.

**Não é:** relitigar o glossário. É o **formato** do ID que o AD travou contra o PRD.

---

### C2 — conflict — AD-5 “chamando essa ocupação” vs FR-13 (recurso não entra na abertura)

**PRD FR-13.** Abertura recusada se o esqueleto colidir, em qualquer `data+faixa` do período, com a **sala efetiva** de outra Lesson **ou** com outro compromisso do mesmo **Professor**. “Recurso não entra nesta recusa — só na Reservation (FR-23).”

**Spine AD-5.** Depois de definir `GET /v1/lessons/ocupacao` (devolve `salaEfetivaId`) **e** o read-model FR-29 do BFF (une salas efetivas **com linhas RECURSO** e SALA ad hoc), a Rule diz: “`classes` (FR-13) e `reservations` (FR-23/24/30) recusam no próprio POST/PATCH/DELETE **chamando essa ocupação**.”

**Por que é conflito.** O pronome “essa ocupação” é ambíguo. Leitura A: `lessons.ocupacao` (só sala efetiva) — então falta o eixo Professor de FR-13/SM-5, mas não contradiz o “recurso não entra”. Leitura B: ocupação FR-29 (inclui RECURSO) — `classes` recusaria abertura por kit/projetor tomado, **contra FR-13**. Dois grupos podem implementar as duas leituras. SM-5 está no Binds do AD-2 (envelope), não na Rule do AD-5 (quem recusa o quê).

---

### G1 — gap (alto) — eixos de recusa de FR-13/15/21/23/24/30 não estão na Rule

AD-2 trata o **envelope** (RFC 9457, `code` = id do FR, 409). AD-5 trata a **derivação** da sala efetiva e manda os escritores “chamarem ocupação”. As consequências testáveis abaixo não aparecem em nenhuma Rule; o mapa as comprime em “recusa via ocupação `lessons`”.

| Eixo no PRD | Onde | Na spine |
|---|---|---|
| Colisão de **Professor** (Lesson ou Reservation na mesma `data+faixa`) | FR-13, FR-23, SM-5 | Não. Ocupação AD-5 devolve `salaEfetivaId`. |
| Resource **já tomado** na `data+faixa` | FR-23 | Não (não é ocupação de `lessons`). |
| Resource **inativo** não confirma | FR-22, FR-23 | Não. |
| Capacidade da Room ≥ vagas **e** ≥1 AccessibilityFeature na abertura | FR-15, FR-21 | AD-2 *Binds* FR-15 (envelope). A regra de negócio não está em AD. |
| SALA ligada a Lesson: capacidade ≥ `Class.vagas`; ad hoc: capacidade > 0 + ≥1 feature, **sem** denominador de turma | FR-24 | Não. Um único check de capacidade nos dois casos diverge os grupos. |
| Acessibilidade ≠ booleano na principal; sem feature, FR-15 e SALA não confirmam | FR-21 | Não. |
| **No máximo uma** ReservationLine `kind=SALA` por Lesson | FR-24 | Não. Sem isso a fórmula AD-5 (`salaEfetivaId` = `targetId` da linha SALA) é mal definida se houver duas linhas. |
| As mesmas recusas valem no PATCH de Reservation | FR-30 | AD-5 cita PATCH/DELETE; os eixos acima continuam ausentes. |
| Sem fila de “aprovar reserva”; funcionário não aprova na v1 | FR-24 `[ASSUMPTION]` | Implícito no mapa de escrita (funcionário não escreve Reservation). Não está como recusa/ausência de workflow. |

Isso é drop silencioso típico de estrutura AD: o *Prevents* “UI decidindo colisão” aterrissou; o *quê* o escritor deve recusar, não.

---

### G2 — gap (alto) — FR-16 imutabilidade de `data`+`faixaId` e non-goal de regenerar oferta

**PRD FR-16.** Feriados não são excluídos na v1 `[ASSUMPTION]`. Depois de geradas, **data e `faixaId` da Lesson são imutáveis na v1**; correção de oferta = nova Class `[NON-GOAL for MVP]`.

**PRD §7.** Fora: editar esqueleto / regenerar Lesson / cancelar aula como encontro na v1.

**Spine.** AD-5 assume Lesson já datada. Deferred lista OQ-3, barramento, K8s, CAFe/BAITA — **não** imutabilidade de data/faixa, **não** proibição de PATCH de esqueleto/regeneração. Nenhum AD impede `lessons` de expor alteração de `data`/`faixaId` ou `classes` de regenerar a malha de aulas.

**Por que a malha diverge.** Occupação, Reservation e sala efetiva indexam `data+faixa`. Se um grupo mutar a chave e o outro tratar como estável, FR-18/FR-23/FR-29 quebram sem violar o texto atual do AD-5.

**Anexo do mesmo FR:** “feriados não excluídos” também não aterrissou. Dois calendários (com/sem feriado) geram conjuntos de Lesson incompatíveis no mesmo período.

---

### G3 — gap (alto) — NFR-LGPD-1/2/4 reivindicados no mapa, ausentes na Rule; recorte de leitura FR-19/FR-31

**Mapa da spine:** “NFR-LGPD-1–4 | BFF recortes + sem CPF v1 | AD-6, AD-2”.

**O que AD-6/AD-2 realmente carregam.** AD-6: CORS só no BFF; módulo `reservations` do BFF **não** inclui `Class.studentIds`; roster só no módulo `classes` (isso é NFR-LGPD-3 + FR-31 superfície). AD-5: ocupação FR-29 “nunca nominativa de Student” (metade de NFR-LGPD-2). AD-2: CPF não está na Rule; o mapa é que diz “sem CPF v1” (FR-3 `[ASSUMPTION]`).

**Caiu:**

- **NFR-LGPD-1.** LGPD vale para cadastro administrativo, roster e avaliação. A exceção “fins exclusivamente acadêmicos” (art. 4º) é estreita; **não é isenção** do Closed CRAS. Tom de compliance: grupo pode assumir “trabalho de disciplina = fora da LGPD”.
- **NFR-LGPD-2 (sujeito).** Lesson + Student nomeado é dado de localização: o BFF **só mostra ao próprio Student** (e papéis autorizados **daquela Class**). Occupação não nominativa aterrissou; o recorte da jornada “onde” do Caio, não.
- **NFR-LGPD-4.** Student e Employee são titulares distintos. Direito de eliminação cede onde a lei de acervo exigir retenção — a v1 **não implementa acervo**, mas **não apaga `id` canônico** para “limpar tela”. Combina com FR-1 `[ASSUMPTION]`: desativar Employee não apaga o histórico de `id`. Convenção OQ-2 cobre Class/Reservation após desativação; não cobre retenção de `id`/vínculos.
- **FR-19 / FR-9.** Student só lê Lesson das Class em que **já está referenciado**. O read-model FR-19 está no mapa; o predicado de autorização não.
- **FR-31.** Professor **sem atribuição** à Class não lê o roster dela. AD-6 coloca o roster no módulo `classes`; não restringe por `professorIds`.

AuthZ da spine (“quatro papéis; gateway recusa **escrita** fora de NFR-CTR-2; Student sem rota de escrita”) é mapa de **mutação**. Leitura escopada (própria Class / próprio Student) ficou de fora.

---

### G4 — gap (médio-alto) — FR-28 “não o próprio domínio” caiu no OQ-1

**PRD §4 + FR-28.** Sucesso de grupo inclui telas de **outro** domínio. O grupo de `employees` **não** implementa as telas de Employee; a restrição “não o próprio” já vale; o emparelhamento é OQ-1. NFR de feature: quem desenha a tela de Class consome `courseId` / `employeeId` via Professor, não inventa `pessoa`.

**Spine AD-8.** Superfícies exclusivas; “no máximo um grupo por UX-S*”; emparelhamento = OQ-1. **Deferred OQ-1:** a spine não atribui donos — e **não herda a restrição** “não o próprio contexto de backend”.

**Efeito.** OQ-1 pode ser fechado atribuindo ao grupo `employees` a superfície de Employee (único dono, satisfaz “máximo um grupo”) e ainda violar FR-28. A peça “força consumo do contrato alheio” depende dessa restrição, não só de tokens no AD-2.

**§4 “sucesso = par 1–N **e** BFF **e** gateway **e** telas alheias” / “não é sucesso: modelo mais rico; backend órfão do BFF; dono exclusivo de BFF/OAuth”.** Os ADs 4/6/8 fatiam as peças; a conjunção (não vale entregar só o par 1–N) e o anti-sucesso “modelo mais rico que os outros” (SM-C1) não viram invariante. Relacionado: SM-C2 (não otimizar cobertura SIGRH) e SM-C3 (não usar “reservas criadas” como KPI — empurraria 18 retenções) — AD-5 *Prevents* 18 reservas; o counter-metric como restrição de produto não aterrissou.

---

### G5 — gap (médio) — carga cruzada Student ↔ `Class.studentIds` (FR-7 / FR-9)

**PRD.** FR-7: carga recusa `studentId` que não exista em `students`. FR-9 `[ASSUMPTION]`: `Class.studentIds` chega **no mesmo** seed/import; não há secretaria de matrícula.

**Spine (convenção Student).** “Seed/import JSON idempotente por `id` em `students`; sem tela de alta.”

**Drop.** O artefato único (ou a ordem: persistir Student, depois recusar roster órfão) é coordenação `students` × `classes`. Com a convenção só em `students`, os dois grupos podem publicar seeds incompatíveis (CSV vs JSON já foi evitado na spine; dono do roster na carga, não).

---

### G6 — gap (médio) — recorte de non-goal que dois contextos ainda podem dourar

Não se pede que a spine copie o §7. Os itens abaixo mudam contrato compartilhado se um grupo os implementar e o outro não:

- **Notas / frequência / histórico** em Lesson (§7) — `flagAvaliacao` (FR-17/FR-19) é flag, não lançamento. Sem non-goal na spine, `lessons` pode alargar o agregado.
- **Folha como SIGRH** (FR-2: sem módulo de cargo, salário e ponto; SM-C2) — Equidade impede terceira classe, não impede atributos de folha na secundária.
- **Secretaria de matrícula / SIS ao vivo / tela de alta** — tela de alta está no *Prevents* do AD-8; matrícula como escrita em `Class.studentIds` via UI não está recusada além de “Student sem rota de escrita”.
- **Tom de visão §1 / non-users 3.2:** senta *ao lado* do SIS; não substitui SIGAA/TOTVS/Ellucian; não é ERP. A spine não precisa de pitch; precisa de um Deferred/Prevents de “não virar SIS nesta malha” se o mapa já puxa FR-1–FR-31 como se o recorte estivesse fechado.

Itens §7 já cobertos e **não** são achado: app nativo/hardware (NFR-Q / AD-7–8), sensor/no-show (AD-7, Deferred), CAFe/BAITA (Deferred), tela de alta de Student (AD-8), 18 reservas (AD-5), E1/E2/O (AD-2).

---

### G7 — gap (baixo) — restrições pontuais ainda sem dono na malha

Não bloqueiam o paradigma; dois implementadores ainda podem divergir:

- **FR-1 `[ASSUMPTION]`:** e-mail institucional único entre Employee. Só `employees`, mas consumidores podem querer lookup por e-mail vs `id`.
- **FR-2 `[ASSUMPTION]`:** tipos de vínculo efetivo | temporário | bolsista. Enum não pinado (o addendum também não está citado na Rule, só na Equidade).
- **FR-5:** cardinalidade **1–1** (um Professor por Employee que leciona); “nem todo Employee tem Professor”. Spine: “exige `employeeId`”. Não diz 1–1.
- **FR-10:** carga horária é da disciplina, não da Reservation. `reservations` pode inventar duração.
- **FR-14 / §4:** aulas **seg–sáb**. AD-2 trava códigos de faixa, não o domínio do dia da semana no WeeklySlot (domingo / feriado-como-grade).
- **FR-17:** o que o Professor **pode** PATCH (LessonTopic, `flagAvaliacao`, modalidade). Sem isso, a imutabilidade de G2 fica só implícita.
- **FR-22 `[ASSUMPTION]`:** `estado` de InventoryItem = disponível \| indisponível — distinto de `Resource.ativo`.
- **FR-11:** publicar plano depois do início do período é recusado. AD-2 *Binds* FR-11 (código de recusa). A pré-condição temporal não está escrita. Risco menor (um contexto).
- **FR-13:** várias Class com o mesmo `courseId` e período são **permitidas**. Silêncio pode virar unique constraint indevida em `classes`.

---

## Não é achado (aterrissou ou fora de escopo)

Relitado de propósito **não** entra: vocabulário disciplina ≠ turma ≠ aula ≠ reserva ≠ faixa; sala padrão vs efetiva; Professor is-a Employee; Student ≠ Employee; narrativas UJ-1–UJ-4.

Aterrissou de forma suficiente para esta lente:

- Paradigma malha + BFF; UI não fala com domínio; papéis ≠ seletor de serviço (AD-1, AD-8).
- Direção NFR-CTR-1/2 (diagrama + mapa de escrita na Rule AD-1).
- Contract-first OpenAPI, língua do glossário vs `pessoa`/`evento`/`slot`, `data`+`faixaId`, `[início, fim)`, cânone A–E F–N P (AD-2).
- Envelope de recusa RFC 9457 / UI `refusal-banner` (AD-2) — o *formato*, não os eixos (G1).
- Sala efetiva derivada só em `lessons`; 18 reservas da padrão; BFF/UI não calculam (AD-5).
- NFR-LGPD-3 roster fora de Reservation (AD-6).
- FR-26/27/28 peças de BFF compartilhado, resource-server em todos, SPA única, sem dono exclusivo de BFF/OAuth (AD-4, AD-6, AD-8).
- NFR-Q-1/2, compose, ocupação agendada, sem sensor (AD-7).
- OQ-1 aberto (emparelhamento), OQ-2 default de demo, OQ-3 no grupo `lessons`.
- Equidade 1+1 1–N; IDs alheios = atributos; Student sem tela de alta (convenções).

Arquitetura *além* do PRD (ROPC, NestJS no BFF, portas, paved path Spring vs Nest, `GET /v1/identidade/me`) não é drop do PRD.

---

## Matriz compacta FR / NFR

| ID | Na spine? | Nota |
|---|---|---|
| FR-1 | parcial | Mapa + employees. Unicidade de e-mail e retenção ao desativar: G7 / G3. |
| FR-2 | parcial | Equidade 1–N. Recorte anti-SIGRH e enums: G6 / G7. |
| FR-3 / NFR-ID-1/2 | sim | AD-1, AD-2, mapa. CPF só no mapa. |
| FR-4, FR-5, FR-6 | parcial | Dependência e recusa FR-4 no envelope. 1–1 e “não copia nome”: G7 / AD-1. |
| FR-7, FR-8, FR-9 | parcial | Convenção seed JSON. Carga cruzada e id recebido: C1, G5. |
| FR-10, FR-11, FR-12 | parcial | Mapa. Código alinhável vs UUID: C1. Data do plano: envelope FR-11, não a regra. |
| FR-13 | conflict/gap | C2, G1 (Professor, recurso não entra). |
| FR-14 | parcial | Faixa cânone sim; seg–sáb e horário solto via AD-2. |
| FR-15, FR-21 | gap | Envelope FR-15; regra capacidade/a11y: G1. |
| FR-16 | gap | G2. |
| FR-17 | parcial | Mapa de escrita. PATCH permitido vs chave imutável: G2, G7. |
| FR-18 | sim | AD-5. |
| FR-19 | parcial | Read-model BFF. Filtro por roster e local mentiroso (derivação): G3 / AD-5. |
| FR-20 | sim o bastante | Contexto + Equidade (prédio texto). |
| FR-22 | parcial | Contexto. Inativo e estado de InventoryItem: G1, G7. |
| FR-23, FR-24, FR-30 | gap | Escritor certo sim; eixos G1; 1× SALA; ad hoc vs turma. |
| FR-25 | sim | AD-2. Tensão com UUID: C1. |
| FR-26, FR-29 | sim | AD-5, AD-6. |
| FR-27 | sim | AD-4. |
| FR-28 | parcial | SPA única sim; “não o próprio”: G4. |
| FR-31 | parcial | Superfície UX-S8. AuthZ por atribuição: G3. |
| NFR-CTR-1–4 | sim o bastante | Diagrama, escrita, `[início,fim)`, E1/E2. CTR-3 como “defeito de produto”: tom, não Rule. |
| NFR-LGPD-1–4 | reivindicado ≠ carregado | G3. LGPD-3 sim. |
| NFR-Q-1, Q-2 | sim | AD-7, AD-8. |
| SM-1–SM-4 | não (métrica) | Comportamento via FRs. SM-4 conjunção: G4. |
| SM-5 | binds só | Envelope AD-2; operação certa incompleta: C2, G1. |
| SM-C1–C4 | drop | G4, G6. |
| OQ-1 restrição cruzada | drop | G4. |
| OQ-2, OQ-3 | sim | Convenção / Deferred. |

---

## O que a spine deveria carregar (sem prescrever texto)

Só o que esta lente exige para deixar de ser conflict/gap; a distilação é do arquiteto:

1. Regime de ID: UUID interno **xor** id/código recebido alinhável — com campo explícito se forem dois, e exceção documentada para Student/Course.
2. AD-5 (ou convenção de recusa): quem chama qual ocupação; eixo Professor; Resource tomado/inativo; capacidade/a11y com regra Lesson vs ad hoc; **no máximo uma** linha SALA por Lesson; FR-13 sem Recurso.
3. Imutabilidade v1 de `Lesson.data` + `Lesson.faixaId`; correção = nova Class; feriados não cortam geração.
4. Rules reais para NFR-LGPD-1, recorte de leitura LGPD-2/FR-19/FR-31, retenção de `id` (LGPD-4 / FR-1), ou então o mapa deixar de reivindicar “NFR-LGPD-1–4”.
5. OQ-1 Deferred com a restrição FR-28 já vinculante (“não o próprio domínio”), emparelhamento ainda aberto.

---

*Reconcile somente. Spine não modificada. 2026-08-24.*
