# Review — Good-spine rubric walker

- **Alvo:** `ARCHITECTURE-SPINE.md` (Closed CRAS, altitude initiative, purpose build-substrate, status draft, `updated: 2026-10-14`)
- **Lens:** checklist good-spine (Reviewer Gate)
- **Nível abixo:** nove grupos de alunos + módulos compartilhados `oauth`, `bff`, `frontend`
- **Fonte lida:** somente `ARCHITECTURE-SPINE.md` nesta passagem
- **Spine não foi alterada por este reviewer**

## Verdict

**pass**

A spine fecha os pontos de divergência que quebravam malha paralela na revisão anterior: escrita `classes` → `POST /v1/lessons/gerar` (AD-9, seta negocial no mermaid, linha OV-10), junção IdP ↔ ids de domínio (schema pinado em AD-4), sala efetiva e merge de ocupação no escritor (AD-5, com explicitação de Professor/Recurso), tabela canônica OV-10 na altitude initiative, e envelope operacional de laboratório (AD-7). Restam ressalvas de exigibilidade e fio compartilhado (BFF público, `faixas.json` em submódulos, tokens de enum, AD-6 CORS) — médias, não bloqueiam o gate se o cold-start OpenAPI do BFF e o checklist AD-3 forem tratados como contrato executável.

## Scorecard

| Critério | Resultado | Nota |
| --- | --- | --- |
| Cobre os pontos reais de divergência do nível abaixo e não omite nenhum decisivo | **pass com ressalva** | Proxy BFF: path espelhando `/v1/<contexto>` e `credentials: 'include'` na UI ficam implícitos |
| Toda Rule de AD é exigível e impede a divergência declarada | **pass com ressalva** | AD-6 “recusam `Origin`” ambíguo; AD-10 não enumera `code` de infra; AD-2 não pin todos os enums de domínio |
| Nada em Deferred deixaria duas unidades divergirem incorretamente | **pass** | OQ-3 tem default em AD-8; OQ-ARCH-1 é por contexto (um dono); OQ-1 é alocação de turma, não contrato |
| Tech nomeada verificada-atual (versões presentes) | **pass** | Stack declara **“Verificado na web em 2026-10-14”**; pins com versão em cada linha; Compose `v2` é geração, não tag semver |
| Cobertura das dimensões da altitude initiative (incl. envelope operacional) | **pass com ressalva** | AD-7/10/11/12 fecham compose, resilience, testes, seed; CI/TLS/segredos do lab não estão decididos nem listados em Deferred |
| OV-10 domain-vs-BFF presente; AD-5 / AD-9 não enfraquecidos | **pass** | Tabela OV-10 em AD-1; AD-5: “OV-10 **não** enfraquece esta AD”; AD-9 classifica gerar como **negocial** |
| Spine = invariantes, não PRD copiado | **pass** | Propósito explícito; mapa de capability rastreável; terse onde cabe |
| Mermaid / estrutura mecânica | **pass** (por leitura) | Três diagramas coerentes com as Rules; AD-n com Binds/Prevents/Rule |

---

## Findings

### Medium

#### RW-M1 — Contrato público do BFF: convenção de path ainda implícita

- **Onde:** AD-6 (OpenAPI único do BFF, proxy vs read-model, módulos `backend/bff/src/modules/<contexto>/`); AD-2 (paths `/v1/...` declarados para “cada contexto” em `openapi/openapi.yaml` do domínio).
- **Divergência possível:** grupos expõem no BFF `/employees`, `/api/v1/employees`, ou prefixo único sem espelhar o submódulo; o frontend cruzado (FR-28) quebra em runtime apesar de um único `openapi.yaml` seed.
- **Por que a Rule não fecha totalmente:** AD-6 amarra envelope AD-2 e local dos módulos, mas não repete a regra de path `/v1/<nome-inglês-do-contexto>/...` para rotas **proxy** do BFF.
- **Severidade:** medium (demo e contrato BFF↔UI).
- **Ação sugerida:** uma linha em AD-6 ou Consistency Conventions: proxy BFF = mesmo path `/v1/<contexto>/...` que o domínio upstream (rewriting só de host); read-models em rotas nomeadas nos módulos FR-19/29/31.

#### RW-M2 — `faixas.json` no catálogo `oauth` vs submódulo isolado

- **Onde:** AD-2 (`backend/oauth/contracts/faixas.json`); AD-3 checklist item 6 (“faixas só em faixas.json”); Structural Seed (cada contexto = repo próprio).
- **Divergência possível:** nove OpenAPI copiam enum A–E, F–N, P; um grupo faz GET ao BFF/oauth em runtime; outro embute enum desatualizado após mudança no addendum.
- **Por que a Rule não fecha totalmente:** “não copiar” não vira mecanismo verificável (HTTP canônico, `$ref` no fragmento oauth, ou teste de contrato contra cânone).
- **Severidade:** medium (FR-13/15/23/29 e colisões de faixa).
- **Ação sugerida:** pin de consumo (fragmento OpenAPI oauth referenciado ou endpoint GET versionado) + AD-11 contract test contra cânone.

#### RW-M3 — AD-6 “contextos recusam `Origin` de browser”

- **Onde:** AD-6 Rule vs Prevents “CORS de SPA nos contextos”.
- **Divergência possível:** interpretações de 403 explícito em `Origin`, ausência de headers CORS, ou rejeição de preflight — comportamentos diferentes em ferramentas e testes E2E.
- **Por que a Rule não fecha totalmente:** o Prevents desejado é “só o BFF habilita CORS”; a redação atual convida implementações divergentes.
- **Severidade:** medium.
- **Ação sugerida:** reescrever: domínios **não** expõem CORS; browser não deve alcançá-los (OV-1); resource-server ignora CORS, não inventa política de `Origin`.

#### RW-M4 — Tokens / enums de domínio parcialmente pinados em AD-2

- **Onde:** AD-5 usa `ReservationLine.kind=SALA`, presencial/remoto, WeeklySlot; AD-2 lista IDs e `faixaId` mas não enumera `kind`, `modalidade`, `WeeklySlot.dia`, `flagAvaliacao`.
- **Divergência possível:** `SALA` vs `sala`, `presencial` vs `PRESENCIAL`, dia ISO vs seg–sáb literal — consumidores cruzados e BFF read-models interpretam payloads diferentes.
- **Severidade:** medium (SM-5 e escritores AD-5).
- **Ação sugerida:** estender AD-2 ou Consistency Conventions com tokens de enum do glossário (sem copiar o addendum inteiro).

### Low

#### RW-L1 — AD-10: `code` de infraestrutura não catalogado

- **Onde:** AD-10 Rule (“`code` de infraestrutura da malha, não inventar FR de produto”).
- **Divergência possível:** BFF e contextos usam códigos distintos para o mesmo 503 de dependência; UI de banner mapeia inconsistente.
- **Severidade:** low (comportamento UX, não invariante de domínio).
- **Ação sugerida:** catálogo mínimo em oauth ou BFF openapi, ou linha em SDD cold-start.

#### RW-L2 — Envelope operacional: CI, TLS, segredos do compose

- **Onde:** AD-7 (compose, health, métricas); ausência em Deferred.
- **Divergência possível:** pipelines incompatíveis entre submódulos; grupos assumem HTTPS no lab vs HTTP explícito.
- **Severidade:** low para divergência de produto; medium para operação de turma se não houver convenção mínima.
- **Ação sugerida:** uma linha em Deferred (“CI por submódulo vs malha”, “HTTP claro no lab”, “segredos compose = seed documentado”).

#### RW-L3 — Pin fraco Docker Compose `v2`

- **Onde:** Stack “Docker Compose | v2”.
- **Nota:** não gera divergência de API entre grupos se o `compose.yaml` seed for único na malha.
- **Severidade:** low.
- **Ação:** ignore ou pin da versão mínima do plugin no README da malha.

#### RW-L4 — `@nestjs/resilience` 0.0.2

- **Onde:** Stack (seed BFF).
- **Nota:** versão early; AD-10 fixa comportamento (timeout, breaker, retry), não a lib — aceitável como seed desde que cold-start não trate como única opção bloqueante.
- **Severidade:** low.

---

## Checklist explícito (good-spine)

### Fixes real divergence points for the level below

**Atende.** Malha AD-1 + OV-10, AD-2 fio HTTP, AD-3 checklist poliglota, AD-4 identidade, AD-5/6/9 donos de sala efetiva / BFF / geração de Lesson, ownership de módulos BFF (FR-19, FR-29, FR-31), AD-11/12 paralelismo de teste e seed. Ressalvas RW-M1–M4 são refinamento de exigibilidade, não buracos no grafo negocial.

### Every AD Rule enforceable and prevents stated divergence

**Atende com ressalva.** AD-1…AD-9 e AD-12 são auditáveis por review + OpenAPI + compose. AD-10 e AD-6 Origin (RW-M3, RW-L1) são os pontos mais moles. AD-4 marca Direct Access Grant como `[ASSUMPTION]` — ainda é regra de lab, não lacuna.

### Nothing under Deferred could let two units diverge incorrectly

**Atende.**

| Item Deferred | Risco | Por que é seguro |
| --- | --- | --- |
| OQ-1 emparelhamento grupo ↔ UX-S* | processo de turma | AD-8: no máximo um grupo por UX-S*; regra “não o próprio domínio” |
| OQ-3 LessonTopic | shape API | Default AD-8 até fechar: pelo menos um de `syllabusItemId` ou enunciado extra |
| OQ-ARCH-1 Mongo vs PG | store por contexto | Um submódulo por contexto; compose sobe ambos; checklist AD-3 isola DB |
| OQ-ARCH-2 display name Employee | enriquecimento | Default BFF visualização; linha OV-10 `[ASSUMPTION]` |
| Interno hexagonal/ORM, codegen, eventos, PKCE, K8s, escopos finos | altitude epic / v2 | Não autorizam dois grupos a contradizer AD-1…AD-9 |

### Named tech verified-current

**Atende.** Seção Stack: **“Verificado na web em 2026-10-14.”** Todas as linhas nomeadas trazem versão ou imagem pinada. Nota consciente OpenAPI 3.2.0 vs pin 3.1 nos contratos. Angular 22 / Nest 12 / Keycloak 26.8.1 / PG 18.6 / Mongo 8.3.13 alinhados à data de verificação declarada na spine (walker não re-checou registry nesta passagem).

### Initiative altitude dimensions (incl. operational envelope)

**Atende com ressalva.** Paradigma, invariants, stack, structural seed, capability map, authZ, LGPD v1, resilience, observabilidade scrapeável, ambientes `local`/`lab`, proibições K8s/sensor/IdP SaaS. CI/TLS/segredos (RW-L2) ficam em silêncio — promover a Deferred evita falso “decidido”.

### OV-10 table present; AD-5 / AD-9 not weakened

**Atende.**

- Tabela **“Classificação OV-10 (canônica na altitude initiative)”** em AD-1 (negocial vs visualização vs passthrough), com anti-padrão explícito para reclassificar merge/sala efetiva/gerar como “só visualização”.
- AD-5: derivação só em `lessons`; merge FR-13/23/24/30 no escritor; FR-29 no BFF; **“OV-10 não enfraquece esta AD.”**
- AD-9: **`POST /v1/lessons/gerar`** só via `classes`; imutabilidade data+faixa; **“OV-10 classifica esta seta como negocial.”**

---

## O que a spine acerta (baseline sólida)

- Propósito explícito: nove grupos + agentes SDD sem divergir em contrato, identidade, BFF, stores, frontend.
- Paradigma malha + BFF com tabela Pode/Não pode; `oauth` catálogo, não 10º domínio.
- AD-1: duas classes (negocial vs composição); ciclo GET `lessons`↔`reservations` profundidade 1; browser só BFF; seta **POST gerar** no diagrama.
- AD-2: inglês no path, RFC 9457 + `code=FR-*`, UUID/string, date+faixa, listas `items`.
- AD-3: poliglota com checklist não negociável; conflito upstream SPEC documentado com prevalência da spine.
- AD-5 + AD-6 + AD-9: núcleo UJ-2/UJ-3/UJ-4 (sala efetiva, ocupação, roster LGPD, geração de Lesson).
- AD-7: compose único, PG/Mongo por contexto, Prometheus/Grafana, sem sensor na v1.
- AD-8: Angular SPA única, shell vs surfaces, tokens DESIGN.md prevalecem.
- Mapa FR-1–FR-31, NFRs, UX-* governados por AD-n.

## Recomendações de triagem (Finalize; não aplicadas aqui)

1. **Autofix leve (opcional, pós-gate):** RW-M1, RW-M3, RW-M4; uma frase RW-M2 no cold-start oauth.
2. **Defer explícito:** RW-L2 (CI/TLS/segredos lab).
3. **Ignore ou documentar seed:** RW-L3, RW-L4.

Com RW-M1–M4 endereçados no companion OpenAPI BFF ou em emenda mínima da spine, o scorecard passa de “pass com ressalva” para **pass pleno** nos critérios de exigibilidade.

---

## Histórico

- Revisão anterior (mesmo arquivo) refletia spine pré-2026-10-14 (fail por FR-16, JWT, BFF público). A spine atual incorpora AD-9, tabela OV-10, schema `/v1/identidade/me`, e mermaid com POST gerar — esta passagem reavalia somente o documento vigente.
