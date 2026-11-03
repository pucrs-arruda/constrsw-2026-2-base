---
id: SPEC-closed-cras
companions:
  - brownfield-2026-1.md
  - domain-pairs.md
  - capability-map.md
  - ../../planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/prd.md
  - ../../planning-artifacts/prds/prd-constrsw-2026-2-2026-08-19/addendum.md
  - ../../planning-artifacts/architecture/architecture-constrsw-2026-2-2026-08-24/ARCHITECTURE-SPINE.md
  - ../../planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-08-24/EXPERIENCE.md
  - ../../planning-artifacts/ux-designs/ux-constrsw-2026-2-2026-08-24/DESIGN.md
sources:
  - C:/Users/EduardoArruda/Documents/Pessoal/src/pucrs-arruda/constrsw/constrsw-2026-1/architecture-insights.md
  - C:/Users/EduardoArruda/Documents/Pessoal/src/pucrs-arruda/constrsw/constrsw-2026-1/data-model/README.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability only — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Closed CRAS

## Why

**Pain + mandate.** Na ConstrSW (PUCRS, 2026/2), nove grupos precisam implementar em paralelo uma malha acadêmica/recursos sem língua compartilhada: disciplina ≠ turma ≠ aula ≠ reserva ≠ faixa. O registro de pessoas e disciplinas já existe fora; o que quebra é juntar *quem já existe*, *a oferta do período com sala padrão nas faixas* e *o que acontece nesta aula* — sem local mentiroso para o Student e sem cada grupo inventar microsserviço, IdP ou UI própria. Closed CRAS é a evidência demonstrável de mesh contract-first com BFF e OAuth compartilhados; não é SIS nem ERP.

## Capabilities

- **CAP-1**
  - **intent:** Funcionário cria, edita, desativa e reativa Employee e mantém EmploymentBond 1–N, publicando `id` + `ativo` para alocação e papel docente.
  - **success:** `id` estável e e-mail único (ativos e inativos); desativar não apaga vínculos nem registro; Employee inativo bloqueia criar Professor; Class já atribuídas ficam RO e nova Reservation é recusada (FR-1a); sem delete físico nem provisionamento automático no Keycloak.

- **CAP-2**
  - **intent:** Funcionário cria Professor somente sobre Employee existente e ativo, com AcademicDegree 1–N, sem duplicar cadastro pessoal.
  - **success:** Criação sem Employee ou com `ativo=false` é recusada; `employeeId` 1–1; leitura de nome/e-mail resolve via Employee; SM-1 demonstrável; store do contexto (PG ou Mongo) não define identidade — is-a é só `employeeId`.

- **CAP-3**
  - **intent:** Sistema recebe Student e AcademicAffiliation por seed/import (não por UI de alta) e vincula `Class.studentIds` no mesmo fluxo.
  - **success:** Não existe jornada de cadastro de Student na UI; carga idempotente por `id` opaco; Student só lê Lesson das Class referenciadas; AcademicAffiliation não é roster.

- **CAP-4**
  - **intent:** Coordenador mantém Course com SyllabusItem 1–N e publica plano de ensino datado antes do período da Class.
  - **success:** Course tem `id` UUID e `codigo` alinhável; publicar plano com data ≥ início do período é recusado; plano estruturado (não blob) alimenta LessonTopic e leitura do Student/Professor.

- **CAP-5**
  - **intent:** Coordenador abre Class com sala padrão, WeeklySlot (esqueleto) e gera Lesson datadas sem criar Reservation da sala padrão.
  - **success:** Abertura recusada em colisão de sala efetiva ou Professor, capacidade insuficiente ou zero AccessibilityFeature; `classes` chama `POST /v1/lessons/gerar` após confirmação (efeito negocial, não join de UI); zero Reservation da sala padrão; data/`faixaId` da Lesson imutáveis (SM-2 parcial).

- **CAP-6**
  - **intent:** Professor atribuído ajusta Lesson (tópicos, `flagAvaliacao`, modalidade); `lessons` deriva e publica `salaEfetivaId`; Student lê via BFF onde/o quê/avaliação sem local mentiroso.
  - **success:** Presencial sem linha SALA → sala efetiva = sala padrão; com linha SALA → `targetId` e padrão liberada; remoto → nulo; Student nunca vê a padrão quando a efetiva diverge; só `lessons` deriva (AD-5); BFF não recalcula.

- **CAP-7**
  - **intent:** Funcionário mantém Room + AccessibilityFeature 1–N e Resource + InventoryItem 1–N como espaços/ativos reserváveis distintos.
  - **success:** Room tem capacidade obrigatória e ≥1 feature para FR-15/SALA; Resource ≠ Room; InventoryItem sem órfãos; Resource inativo não confirma Reservation.

- **CAP-8**
  - **intent:** Professor cria/altera/cancela Reservation com ReservationLine (RECURSO no caminho feliz; SALA só na exceção ou ad hoc); conflitos resolvidos no escritor.
  - **success:** Recusa Resource tomado/inativo, segunda SALA na mesma Lesson, sobreposição de sala efetiva/Resource/Professor; cancelar libera faixa e restaura sala efetiva à padrão; sem fila de aprovação (SM-5).

- **CAP-9**
  - **intent:** Cada contexto publica OpenAPI 3.1 como fonte da verdade na língua do glossário, com IDs e envelopes uniformes.
  - **success:** Paths `/v1/<contexto>`; JSON camelCase com tokens do glossário; listas em `items`; IDs de contrato = string (store não vaza); refs por id (sem embutir payload de outro contexto); recusas `application/problem+json` com `code` = id do FR; sem `pessoa`/`evento`/`slot` genéricos.

- **CAP-10**
  - **intent:** BFF é a única superfície do browser: proxy de domínio, login/cookie, ocupação agendada e vistas compostas sem persistir agregado nem aplicar regra negocial.
  - **success:** UI não faz join de nove OpenAPIs; OpenAPI BFF distingue **proxy** (`/v1/<contexto>/...`, pass-through sem pré-validar FR) vs **read-model de composição** (OV-10); FR-29 em módulo `ocupacao` (não nominativo); FR-19 só no módulo lessons do BFF; roster só no módulo classes e nunca em reservations; CORS só no BFF; falha crítica de hop → 503 problem+json + banner (SM-3 parcial).

- **CAP-11**
  - **intent:** Identidade institucional via REST API `backend/oauth` sobre Keycloak; BFF faz login browser; cada contexto é resource-server JWKS e expõe `GET /v1/identidade/me` com o mesmo schema.
  - **success:** UI não chama o IdP (`keycloak-js` proibido); papéis literais `funcionario`|`coordenador`|`professor`|`student`; claims com IDs opacos; escritura obedece NFR-CTR-2; credencial recusada = 401 sem enumerar conta; create Employee não provisiona usuário no Keycloak.

- **CAP-12**
  - **intent:** Uma SPA por papel (UX-LOGIN/HOME + UX-S1–S9) com frontend cruzado: cada grupo implementa telas de domínio alheio usando tokens de DESIGN.md.
  - **success:** Sem seletor de microsserviço; grupo não implementa telas do próprio backend; Student/Professor/Coordenador/Funcionário completam UJ-1–UJ-4 na UI (SM-3, SM-4); emparelhamento grupo↔UX-S* = OQ-1; dados só via BFF.

## Constraints

- Equidade ConstrSW: cada domínio = uma classe principal + uma secundária 1–N; sucesso de grupo = par + rotas BFF do domínio + gateway REST de identidade + telas de domínio alheio; BFF e OAuth sem dono exclusivo.
- Dependências de runtime apenas as de AD-1; IDs alheios são atributos, não terceira classe; sem ciclo de escrita `lessons` ↔ `reservations`.
- **OV-10:** regra/invariante/pré-condição/is-a → API do contexto escritor (+ GET por `id`); join/agregação só para UI → BFF read-model. Escrita e recusa nunca no BFF; composição de tela nunca como fonte da verdade no domínio. Detalhe e anti-padrões: spine AD-1/AD-6 e `domain-pairs.md`.
- Grade canônica A–E, F–N, P (sem E1/E2/O); par `data` + `faixaId`; intervalo `[início, fim)`; tabela só em `backend/oauth/contracts/faixas.json`.
- Stack compartilhada: OpenAPI 3.1; Keycloak 26.8.x; BFF NestJS 12.x; UI Angular 22.x + Angular Material (tokens DESIGN.md prevalecem). Domínios: linguagem/framework **poliglota** desde que o checklist AD-3 passe (não lista fechada Spring|Nest). Persistência **PG ou Mongo** por contexto, isolamento `cras_<contexto>`; IDs no contrato = string. Pins finos: companion spine Stack.
- Envelope lab: Docker Compose na raiz com Keycloak, PostgreSQL, MongoDB, 9 APIs, BFF, frontend Angular, Prometheus, Grafana; `GET /health` + readiness; métricas scrapáveis; logs estruturados; sem Kubernetes/Helm na v1 (AD-7 / OV-9).
- Resilience (AD-10): circuit breaker + timeout (+ retry com política explícita) em BFF→domínios e GETs domínio→domínio da malha.
- Testes (AD-11): unit/component + contrato BFF↔domínios + regressão CI + E2E UJ-1…UJ-4.
- Seed (AD-12): fixtures versionados idempotentes em cada REST API (9 + oauth + BFF); sem CPF; cobrem UJs e conflitos FR.
- LGPD: sem CPF na v1; ocupação não nominativa de Student; roster não vaza em Reservation; não apagar `id` canônico para “limpar tela”.
- `constrsw-2026-1` informa padrões operacionais (BFF, JWKS, contract-first, compose); o modelo de domínio e a stack daquela edição **não** são autoridade — ver `brownfield-2026-1.md`.

## Non-goals

- Diploma XML, ICP-Brasil, acervo RDC-Arq, extrato Censo (IDs só precisam permanecer compatíveis).
- Otimizador de grade; editar/regenerar esqueleto; cancelar aula como encontro; 18 reservas da sala padrão.
- IA no hot path, IoT/sensor/no-show, digital twin, agente de booking, app nativo/totem.
- Substituir SIS/ERP/LMS; folha/SIGRH/ponto; Lattes; protocolo e-MEC.
- Tela de alta de Student; histórico acadêmico, notas e frequência; faixas E1/E2/O.
- Federação CAFe/BAITA de produção; EKS/Terraform cloud da edição 2026-1; identidade Mongo=Employee (mesmo UUID) ou copiar cadastro pessoal no contexto `professors` (Mongo como store é permitido se `employeeId` 1–1 e o store não vaza no contrato); provisionar Keycloak automaticamente ao criar Employee.

## Success signal

Em laboratório (compose), as quatro personas completam UJ-1–UJ-4 na UI sem escolher microsserviço (SM-3); zero Professor sem Employee **ativo** (SM-1 / FR-1a); abertura de Class sem Reservation da sala padrão e Student vê só sala efetiva (SM-2); cada grupo demonstra par 1–N + BFF + gateway + tela alheia (SM-4); conflitos de sala efetiva/Resource/Professor são recusados no escritor certo (SM-5).

## Assumptions

- Login de laboratório: Direct Access Grant no client confidencial `bff`; cookies httpOnly no BFF (AD-4).
- BFF em NestJS 12.x (não Spring) — composição TypeScript.
- E-mail institucional de Employee é único; tipos de EmploymentBond v1: efetivo | temporário | bolsista.
- `Class.studentIds` chega no mesmo seed/import que Student (FR-9).
- OQ-3 default até fechar: LessonTopic exige pelo menos um de `syllabusItemId` ou enunciado extra.
- Feriados não são excluídos na geração de Lesson na v1.
- OQ-ARCH-2 default: enriquecimento de display name Employee na vista Professor é composição BFF.
- Não há rubrica numérica oficial da disciplina neste repositório — sucesso = SM-1–SM-5 demonstráveis.

## Open Questions

- **OQ-1.** Qual grupo implementa qual UX-S* (restrição: não o próprio domínio de backend)? Dono: turma/docente. Bloqueia emparelhamento de implementação de telas, não o restante deste SPEC.
- **OQ-3.** LessonTopic: `syllabusItemId` obrigatório, enunciado extra obrigatório, ou pelo menos um dos dois? Default de demo acima até fechar.
- **OQ-ARCH-1.** Qual contexto usa Mongo vs PostgreSQL no cold-start? Default: escolha por grupo no README do submódulo; compose sempre sobe ambos. Dono: bootstrap da malha / grupos.
- **OQ-ARCH-2.** Enriquecimento de display name Employee na vista Professor fica no BFF (default) ou no OpenAPI de `professors`? Default de demo: BFF.
