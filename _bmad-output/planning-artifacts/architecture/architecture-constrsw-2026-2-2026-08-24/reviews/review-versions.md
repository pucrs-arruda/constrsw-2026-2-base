# Review: versões e realidade da stack — Architecture Spine Closed CRAS

- **Data da revisão:** 2026-10-14
- **Alvo:** `ARCHITECTURE-SPINE.md` (status `draft`, `updated: 2026-10-14`)
- **Lente:** cada decisão de Stack/tecnologia foi conferida na web (existência, versão corrente em 2026-10-14, fit com starters) — não inferida só de training data.
- **Veredito:** **CONDICIONAL.** A tabela Stack e a nota “Verificado na web em 2026-10-14” batem com npm/Maven/registries na maior parte dos pins críticos (Angular 22, NestJS 12, drivers Mongo, Prometheus/Grafana, Keycloak 26.8.1). Ressalvas: classificação factual errada de `keycloak-js` em AD-4; artefato Spring de resilience4j não nomeado para Boot 4; dois pins um patch atrás do `latest` estável (springdoc); seed `@nestjs/resilience` em semver `0.0.x` recém-publicado.

A revisão anterior (2026-08-24) refletia stack React/Vite/Nest 11 — **obsoleta**. Este documento cobre o spine pós-OV (Angular + Nest 12 + malha poliglota).

---

## Método

Spot-checks executados em **2026-10-14**:

| Fonte | O que foi consultado |
| --- | --- |
| npm registry (`npm view`) | `@nestjs/core`, `@nestjs/resilience`, `@angular/core`, `@angular/material`, `@angular/cdk`, `@angular/build`, `mongodb`, `express`, `typescript`, `@nestjs/platform-express` |
| Maven Central / repo1.maven.org (web) | `mongodb-driver-sync:5.13.0`, `resilience4j-*:2.4.0`, `resilience4j-spring-boot4:2.4.0` |
| spring.io / springdoc.org / GitHub tags | Spring Boot 4.1.1, springdoc-openapi 3.1.x |
| keycloak.org / GitHub keycloak-js | Keycloak 26.8.1, status do adapter JS |
| prometheus.io / GitHub releases | Prometheus 3.15.0 |
| grafana.com / Docker Hub | Grafana OSS 13.2.4 |
| Docker Hub / docker-library | `mongo:8.3.13`, `postgres:18.6` (referência spine) |
| nodejs.org / GitHub node releases | Node 24 LTS linha Krypton |

Não foi feita varredura exaustiva de **todos** os pins da tabela (ex.: `@fontsource/*`, patch exato Temurin 21). Itens não spot-checkados estão listados em “Residual”.

---

## Spot-checks críticos (3–5 pedidos)

### 1. Angular 22 + Angular Material

| Pin spine | npm `latest` (2026-10-14) | Fit |
| --- | --- | --- |
| `@angular/core` 22.2.2 | **22.2.2** | OK |
| `@angular/material` 22.2.3 | **22.2.3** | OK |
| `@angular/cdk` 22.2.3 | **22.2.3** | OK |
| TypeScript (frontend) 6.0.x | `typescript@6.0.2` existe; npm `latest` = **7.0.2** | OK — spine documenta faixa **`>=6.0 <6.1`** via `@angular/build@22.2.2` (`typescript: '>=6.0 <6.1'`). Pin 6.0.x é **fit correto** para o paved path Angular; não usar TS 7 no frontend sem quebrar peer do CLI/build. |

### 2. NestJS 12 + resilience BFF

| Pin spine | Registro | Fit |
| --- | --- | --- |
| `@nestjs/core` 12.1.3 | npm `latest` = **12.1.3** | OK |
| `@nestjs/resilience` 0.0.2 | npm `latest` = **0.0.2** (publicado ~6 dias antes da revisão; pacote oficial Nest, docs em [nestjs.com/reliability/resilience](https://docs.nestjs.com/reliability/resilience)) | **OK (existência)** / **ressalva (maturidade)** — semver `0.0.x` indica API ainda instável; comportamento AD-10 é invariante, mas cold-start assume lib verde. |
| Express 5.2.x | npm `latest` = **5.3.0**; `@nestjs/platform-express@12.1.3` depende de **`express@5.2.1`** | OK — spine **5.2.x** alinha ao Nest 12, não ao Express isolado. |

### 3. Drivers Mongo (Java + Node)

| Pin spine | Registro | Fit |
| --- | --- | --- |
| `mongodb-driver-sync` 5.13.0 | Maven Central, release **2026-09-25** | OK — latest estável da linha 5.x spot-checkada. |
| `mongodb` (Node) 7.7.0 | npm `latest` = **7.7.0** | OK |

### 4. Observabilidade (Prometheus + Grafana)

| Pin spine | Fonte | Fit |
| --- | --- | --- |
| Prometheus 3.15.0 | [prometheus.io/download](https://prometheus.io/download/) — “Latest” **3.15.0** (2026-09-24) | OK |
| Grafana (OSS) 13.2.4 | [grafana.com download](https://grafana.com/grafana/download/13.2.4?edition=oss&platform=docker) — release **2026-10-13**; tag `grafana/grafana:13.2.4` | OK |

### 5. Spring seed (amostra)

| Pin spine | Fonte | Fit |
| --- | --- | --- |
| Spring Boot 4.1.1 | [spring.io blog 2026-08-20](https://spring.io/blog/2026/08/20/spring-boot-4-1-1-available-now/), Maven Central | OK |
| springdoc-openapi 3.1.0 | [springdoc.org](https://springdoc.org/) documenta **3.1.1** como versão atual da linha Boot 4 | **Patch atrás** — 3.1.0 existe e suporta Boot 4; **3.1.1** (2026-09-06) é o patch estável corrente. |
| resilience4j 2.4.0 | Maven Central / [release v2.4.0](https://github.com/resilience4j/resilience4j/releases/tag/v2.4.0) | **OK (versão)** / **gap de artefato** — com Boot **4.1.x** o starter correto é **`resilience4j-spring-boot4:2.4.0`**, não `resilience4j-spring-boot3` (Boot 3 falha startup com mensagem explícita). A spine só cita “resilience4j 2.4.0” sem módulo. |

---

## Tabela Stack — síntese item a item

| Pin | Existe? | Corrente em 2026-10-14? | Status |
| --- | --- | --- | --- |
| OpenAPI contratos 3.1 | Sim | Spec latest = **3.2.0**; spine explica pin 3.1 | OK (conservador, documentado) |
| Java 21 | Sim | 25 LTS também disponível; Boot 4.1 suporta 17–26 | OK (conservador) |
| Spring Boot 4.1.1 | Sim | Sim (patch estável 4.1.x) | OK |
| springdoc-openapi 3.1.0 | Sim | **3.1.1** é latest da linha | Menor drift |
| resilience4j 2.4.0 | Sim | Sim | OK + nomear `spring-boot4` |
| mongodb-driver-sync 5.13.0 | Sim | Sim (5.13.0) | OK |
| Node.js 24.x (>=24.15) | Sim | LTS **24.22.0** publicado **no dia da revisão**; floor >=24.15 válido | OK (range, não pin único) |
| NestJS 12.1.3 | Sim | Sim | OK |
| @nestjs/resilience 0.0.2 | Sim | Sim | OK + maturidade 0.0.x |
| Express 5.2.x | Sim | 5.3.0 no npm; Nest trava 5.2.1 | OK |
| TypeScript 6.0.x (frontend) | Sim | 7.0.2 é npm latest | OK (fit Angular) |
| mongodb 7.7.0 | Sim | Sim | OK |
| Keycloak 26.8.1 / imagem Quay | Sim | Release **2026-10-13** | OK |
| PostgreSQL 18.6 | Sim (spine) | Release 2026-08-13 (histórico conhecido) | OK — não revalidado patch do dia nesta sessão |
| mongo:8.3.13 | Sim | Tag oficial [docker-library/mongo](https://github.com/docker-library/docs/blob/master/mongo/README.md) | OK |
| Angular / Material / CDK 22.2.x | Sim | Sim | OK |
| @fontsource/ibm-plex-* 5.3.0 | Não revalidado nesta sessão | — | Assumido OK (memlog) |
| Prometheus 3.15.0 | Sim | Sim | OK |
| Grafana 13.2.4 | Sim | Sim | OK |
| Docker Compose v2 | Família existe | Plugin atual = linha **5.x** (“v2” é vago) | OK fraco |

---

## Tecnologias fora da tabela — claims AD / operacional

| Claim | Veredito web |
| --- | --- |
| AD-4: `keycloak-js` **proibido** / listado junto a “adapter Node.js (DEPRECATED)” | **Decisão arquitetural válida** (UI não fala com IdP). **Classificação DEPRECATED para `keycloak-js` continua falsa** — adapter JS mantido (repo [keycloak/keycloak-js](https://github.com/keycloak/keycloak-js), releases 26.x); deprecated são adapter **Node.js** (`keycloak-connect`) e subpartes **Cordova** / proposta `keycloak-js/authz`. |
| AD-4: Direct Access Grant / ROPC | Ainda implementável em Keycloak 26.x; não é pin de versão; risco de produto (RFC 9700) já marcado `[ASSUMPTION]`. |
| AD-7: PostgreSQL 18 volume mount | Breaking change conhecido da imagem 18 (`/var/lib/postgresql` vs `/data`) — spine não detalha mount; risco operacional de compose copiado de PG 16/17. |
| AD-10: libs seed | Nest: `@nestjs/resilience` confirmado oficial. Spring: usar **`resilience4j-spring-boot4`**, não BOM genérico sem módulo Boot 4. |

---

## O que estava desatualizado ou não confirmável

1. **springdoc-openapi 3.1.0** — um patch atrás de **3.1.1** (documentação springdoc, set/2026).
2. **resilience4j** — versão **2.4.0** correta; falta explicitar **`resilience4j-spring-boot4`** para domínios Spring Boot 4.1.1 (fit, não versão).
3. **AD-4 / `keycloak-js`** — não deprecado; só confundir com adapter Node ou Cordova.
4. **`@nestjs/resilience@0.0.2`** — existe e é o latest, porém **pré-1.0** e muito recente; cold-start deve tratar como seed experimental.
5. **Docker Compose “v2”** — não é pin de versão; preferir “plugin `docker compose` (não Compose v1)”.

**Residual (baixa confiança, não spot-check nesta sessão):** patch exato JDK Temurin 21; `@fontsource/*`; se **PostgreSQL 18.6** ainda é o patch mais recente da série 18 em 2026-10-14; compatibilidade cruzada Nest 12 × TS 6 no BFF quando divergir do frontend (spine permite divergência — OK conceitualmente, validar no `nest new` 12).

---

## Evidência de pesquisa vs assertiva

A spine **declara** verificação web em 2026-10-14. Esta revisão **confirma independentemente** a maioria dos números spot-checkados (Angular, Nest, Mongo drivers, Prometheus, Grafana, Keycloak 26.8.1, Spring Boot 4.1.1, imagem Mongo 8.3.13). Os achados acima são **ajustes de fit/classificação** ou **drift menor de patch**, não pins inventados ou tecnologias inexistentes.

---

## Recomendações (não aplicadas no spine)

1. AD-4: trocar “`keycloak-js` DEPRECATED” por “UI **sem** `keycloak-js`; adapter **Node.js** deprecated; JS adapter mantido fora da malha”.
2. Stack: `springdoc-openapi-starter-webmvc-ui` **3.1.1** (ou nota “>=3.1.0, prefer 3.1.1”).
3. Stack / AD-10 nota Spring: **`io.github.resilience4j:resilience4j-spring-boot4:2.4.0`**.
4. Node: documentar exemplo **24.22.0** LTS mantendo floor `>=24.15`.
5. `@nestjs/resilience`: manter pin, acrescentar nota “semver 0.0.x — acompanhar releases”.

---

## Fontes (principais)

- npm: `@nestjs/core@12.1.3`, `@nestjs/resilience@0.0.2`, `@angular/core@22.2.2`, `@angular/material@22.2.3`, `mongodb@7.7.0`, `express@5.2.1` (via `@nestjs/platform-express`)
- Angular TS peers: `@angular/build@22.2.2` → `typescript: '>=6.0 <6.1'`
- Spring Boot 4.1.1: https://spring.io/blog/2026/08/20/spring-boot-4-1-1-available-now/
- springdoc: https://springdoc.org/ (v3.1.1)
- Mongo Java driver 5.13.0: https://repo1.maven.org/maven2/org/mongodb/mongodb-driver-sync/5.13.0/
- resilience4j Spring Boot 4: https://central.sonatype.com/artifact/io.github.resilience4j/resilience4j-spring-boot4
- Keycloak 26.8.1: https://www.keycloak.org/2026/10/keycloak-2681-released
- keycloak-js: https://github.com/keycloak/keycloak/discussions/11975
- Prometheus 3.15.0: https://prometheus.io/download/
- Grafana 13.2.4: https://grafana.com/grafana/download/13.2.4?edition=oss&platform=docker
- Node 24.22.0 LTS: https://nodejs.org/en/blog/release/v24.22.0
- mongo:8.3.13: https://github.com/docker-library/docs/blob/master/mongo/README.md
- Nest resilience docs: https://docs.nestjs.com/reliability/resilience
