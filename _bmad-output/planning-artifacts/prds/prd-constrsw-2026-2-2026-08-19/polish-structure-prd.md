## Document Summary
- **Purpose:** PRD interno ConstrSW para os nove grupos alinharem FRs do produto inteiro (Malha), e para os fluxos seguintes de UX, arquitetura e épicos.
- **Audience:** Grupos da disciplina + leitores de UX/arquitetura/épicos.
- **Reader type:** humans
- **Structure model:** Strategic/Context (Pyramid) — PRD; o bloco §4 Features também opera como Reference (schema estável por FR).
- **Current length:** ~4.830 palavras em 12 seções H2 (1 H1, 18 H3, 31 H4; ~553 linhas). **Não cabe em 5–8 páginas** (~10–12 páginas em markdown impresso / ~400–500 palavras por página).

Este documento existe para ajudar os nove grupos (e os fluxos UX/arquitetura/épicos) a alinhar contratos FR estáveis da Malha inteira, não só de `employees`.

**O que o modelo Pyramid exige aqui:** tese no topo; língua compartilhada antes do detalhe; FRs como evidência da tese; uma fonte só para “fora de escopo”. **O que o leitor humano precisa:** Glossário e jornadas como andaime — não como reprise dos FRs.

**Mapa (palavras, aprox.):**

| Seção | Palavras | Serve o propósito? |
|---|---|---|
| Abertura (antes do §0) | 55 | Parcial — duplica o §0 |
| 0. Document Purpose | 49 | Sim |
| 1. Vision | 165 | Sim; parágrafos 2–3 reprisam Non-Goals e SMs |
| 2. Target User (JTBD + Non-Users + UJs) | 718 | Sim para UX; UJs (555) são o maior bloco não-FR |
| 3. Glossary | 510 | Sim — âncora de vocabulário |
| 4. Features (FR-1–FR-31) | ~2.260 | Sim — contrato de alinhamento |
| 5. Cross-Cutting NFRs | 322 | Sim; parte sobrepõe FR-3/FR-5/Glossário |
| 6. Constraints | 110 | Sim — chega *depois* de todos os FRs |
| 7. Non-Goals | 96 | Sim |
| 8. MVP Scope | 102 | Fraco — §8.1 recita o §4; §8.2 aponta o §7 |
| 9. Success Metrics | 197 | Sim |
| 10. Open Questions | 96 | Sim |
| 11. Assumptions Index | 149 | Sim como índice; é reprise das tags já no corpo |

**Fluxo atual vs. jornada do leitor:** Purpose → Vision → JTBD → UJs (Dependent, faixa, sala efetiva ainda indefinidos) → Glossário → Features → NFRs → Constraints (regra 1–N) → Non-Goals → MVP → SMs. Detalhe prematuro nas UJs; andaime do par 1–N enterrado depois dos FRs. Quatro superfícies de “não é isto” (§2.2, Out of Scope por 4.x, §7, §8.2).

**Fora desta revisão (conteúdo sacrossanto):** não se cortam termos do Glossário, IDs de FR, nem bullets de **Consequences (testable)**. Propostas abaixo são só CUT / MERGE / MOVE / CONDENSE / PRESERVE.

## Recommendations

### 1. MOVE - §3 Glossary para imediatamente após §1 Vision
**Rationale:** UJs e FRs usam Dependent, faixa, esqueleto, sala efetiva, ReservationLine e is-a *antes* de o Glossário definir a língua que o próprio PRD declara âncora.
**Impact:** ~0 palavras (reordenação)
**Comprehension note:** Melhora o andaime humano (overview da língua antes do detalhe). Não corta termos.

### 2. CONDENSE - §2.3 Key User Journeys (Path / Climax / Resolution)
**Rationale:** As quatro UJs são o insumo de UX, mas Path + Climax + Resolution repetem o JTBD e as consequências que FR-4/5, FR-13–16, FR-18/19, FR-23/24 e SM-1/2 já tornam testáveis (“Professor órfão”, “18 reservas”, “local mentiroso”).
**Impact:** ~−220 palavras (555 → ~335)
**Comprehension note:** This cut may impact reader comprehension/engagement se apagar protagonista, estado de entrada ou edge case — **manter** título, persona, entry e edge; colapsar Path+Climax+Resolution em 2–3 frases por UJ.

### 3. CONDENSE - Descriptions dos blocos §4.1–§4.10
**Rationale:** Cada Description reexplica o termo do Glossário e aponta “Realiza UJ-x”, adiando o FR sem acrescentar contrato.
**Impact:** ~−220 palavras (descriptions ~375 → ~155)
**Comprehension note:** Preservar a ponte “Realiza UJ-x” numa frase; não tocar IDs nem Consequences.

### 4. MERGE - Out of Scope local (§4.1–§4.9) + §8.2 no §7 Non-Goals
**Rationale:** A mesma recusa aparece até quatro vezes (Non-Users, Out of Scope por contexto, §7, §8.2 “Itens da §7”) — uma fonte de verdade para “não construir”.
**Impact:** ~−90 palavras
**Comprehension note:** This cut may impact reader comprehension/engagement para quem abre só o seu 4.x — deixar um ponteiro de uma linha (“Fora: ver §7”) em cada bloco 4.x. **Preservar §2.2 Non-Users** (é recorte de persona, não lista de features).

### 5. MERGE + CONDENSE - blurb inicial + §0 Document Purpose + §1 Vision (parágrafos 2–3)
**Rationale:** O leitor é orientado três vezes seguidas: o parágrafo pré-§0 e o §0 dizem o mesmo público; Vision §2–3 reprisam “não é SIS”, registros/alocação (Glossário + NFR-CTR-1) e o critério de sucesso (SM-1–SM-3).
**Impact:** ~−140 palavras (269 → ~130)
**Comprehension note:** Manter a tese do parágrafo 1 da Vision (“juntar quem já existe / oferta com sala padrão / o que acontece nesta aula”). Pyramid: uma orientação, depois a tese.

### 6. MOVE - §6 Constraints (ConstrSW) para imediatamente antes do §4 Features
**Rationale:** A regra “uma principal + uma 1–N; IDs alheios não são terceira classe” é o filtro com que os grupos leem FR-2/6/8/12/14/21/22 — hoje só aparece depois de ~2.200 palavras de FRs.
**Impact:** ~0 palavras (reordenação)
**Comprehension note:** Grupos entendem *por que* Dependent existe antes de implementar o par.

### 7. CONDENSE - §8.1 In Scope; MERGE - §8.2 no §7
**Rationale:** §8.1 é o tour do §4 numa frase só; §8.2 redireciona ao §7 — overview que recita o corpo.
**Impact:** ~−70 palavras
**Comprehension note:** Substituir §8.1 por um checklist curto: UJ-1–UJ-4 + nove pares 1–N + superfície FR-25–FR-31. A estrada estacionada (Censo → OneRoster → federação) pode ficar como único conteúdo extra do §8.2, ou ir ao addendum já citado.

### 8. CONDENSE - §5.1 NFR-ID e §5.2 NFR-CTR-1 (sobreposição com Glossário / FR-3 / FR-5)
**Rationale:** NFR-ID-1/2 e NFR-CTR-1 repetem “sem Pessoa genérica / consumidores guardam IDs / registros publicam, alocação consome” já travado no Glossário e em FR-3/FR-5.
**Impact:** ~−80 palavras
**Comprehension note:** **Preservar** NFR-LGPD-1–4 (único lugar da regra de localização/roster), NFR-CTR-2 (mapa de escrita — uma fonte), NFR-CTR-3/4 e NFR-Q. Não apagar IDs de NFR; encurtar o prosa que duplica o FR.

### 9. CONDENSE - §11 Assumptions Index (formato, não itens)
**Rationale:** O índice é reprise linear das tags `[ASSUMPTION]` já no corpo; como índice humano vale, como prosa não.
**Impact:** ~−50 palavras (149 → ~100, p.ex. tabela Assunção | FR)
**Comprehension note:** Não remover linhas — só compactar. Roundtrip das tags permanece.

### 10. CONDENSE - FR-4 (prosa de encaminhamento; manter o ID)
**Rationale:** FR-4 existe como ID estável, mas o corpo só aponta “detalhe em §4.2”; a consequência testável já está em FR-5.
**Impact:** ~−25 palavras
**Comprehension note:** Manter o cabeçalho **FR-4** e um bullet de consequência; não fundir o ID com FR-5.

### 11. PRESERVE - Glossário (todos os termos), IDs de FR, Consequences (testable), protagonistas das UJs, SMs, OQs
**Rationale:** São o contrato de alinhamento e os andaimes de compreensão que o length_target explicitamente não pode cortar; JTBD (§2.1, 120) e Non-Users (§2.2, 26) já estão densos.
**Impact:** ~0 palavras (não cortar)
**Comprehension note:** FR-29/30/31 fora de ordem numérica **permanecem no bloco de contexto** (4.6 / 4.9 / 4.10) — não renumerar nem espalhar por ordem de ID.

### 12. PRESERVE - §2.1 Jobs To Be Done como camada de varredura
**Rationale:** Quatro bullets compactos dão o mapa mental antes das UJs; fundir no §2.3 economiza pouco e tira o “o que cada papel faz” em uma tela.
**Impact:** ~0 palavras (não cortar; ~120 já densos)
**Comprehension note:** Se a rec. 2 (CONDENSE UJs) for aceita, o JTBD fica ainda mais útil como índice — não o elimine para “ganhar” uma dezena de palavras.

## Summary
- **Total recommendations:** 12 (10 de estrutura/redução + 2 PRESERVE)
- **Estimated reduction:** ~895 palavras (~19% do original) se 1–10 forem aceitas; ~4.830 → ~3.935 palavras
- **Meets length target:** **Não** no estado atual (~10–12 páginas). **Sim no teto de 8 páginas** se MOVE/CONDENSE/MERGE 1–7 forem aceitos (~7,5–8 páginas a ~500 palavras/página). As rec. 8–10 são folga; as 11–12 impedem corte do contrato.
- **Comprehension trade-offs:** Condensar UJs e Out of Scope local reduz reforço (clímax repetido, lista “fora” ao lado do FR). Mitigação: manter persona/entry/edge e um ponteiro “ver §7”. Não condensar Consequences nem termos do Glossário.
