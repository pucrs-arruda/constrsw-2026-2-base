## Relatório de entrega — AG-01 Rooms Backend Fixer

**Branch / commits:** `grupo08-feat/t3-fix-build-health` (criada a partir de `grupo08` em `f660712`)
- `2899403` — `fix(rooms): corrige cópia do contrato no Dockerfile`
- `ec2b416` — `fix(rooms): usa /api/v1/health em scripts, e2e e README`
- `6ddd52c` — `test(rooms): cobre GET /api/v1/health na auditoria de contrato`
- `b15005e` — `docs(rooms): atualiza README com V4 e exclusão lógica`
- `ef30cd0` — `docs(rooms): registra épicos 6 e 7`

**Arquivos alterados:**
- `backend/rooms/Dockerfile`
- `backend/rooms/README.md`
- `backend/rooms/e2e/run.sh`
- `backend/rooms/scripts/trafego.sh`
- `backend/rooms/e2e/bruno/05-permissoes/09-health-e-swagger-abertos.bru`
- `backend/rooms/src/test/java/br/pucrs/constrsw/rooms/ContractCoverageIntegrationTests.java`
- `backend/rooms/_bmad-output/implementation-artifacts/sprint-status.yaml`
- `backend/rooms/_bmad-output/planning-artifacts/epics.md`

**O que foi feito:**
- ✅ **1. Dockerfile:** substituído `COPY openapi ./openapi` por `COPY openapi.yaml ./openapi.yaml` e `COPY schemas ./schemas` antes do `./mvnw clean package -DskipTests -B`, alinhado ao `maven-resources-plugin` (`copy-openapi`) do `pom.xml`, sem alterar imagem base ou usuário.
- ✅ **2. Health:** substituídas todas as chamadas a `/actuator/health` na porta da API (`8105`) por `/api/v1/health` em `README.md`, `e2e/run.sh`, `scripts/trafego.sh` e `e2e/bruno/05-permissoes/09-health-e-swagger-abertos.bru`, preservando `/health` na porta de gestão `9091`.
- ✅ **3. Teste de cobertura de contrato:** adicionado cenário anônimo `GET /api/v1/health` (`200`, validando `"status":"UP"`) em `ContractCoverageIntegrationTests` e incluído `Endpoint("GET", "/api/v1/health", 503)` em `COVERED_ELSEWHERE` com a justificativa de que exige derrubar o banco de dados para o health reportar `DOWN`.
- ✅ **4. README:** corrigidos os caminhos do contrato (`openapi.yaml` e `schemas/` na raiz do submódulo), adicionada a migração `V4` (`enabled` em `rooms` e `accessibility_features`, `ak_rooms_code` como índice único parcial `WHERE enabled`), documentada a exclusão lógica no `DELETE` (sala e características ficam `enabled=false` e recursos são soltos, sem cascata física), atualizado o health para `/api/v1/health` e adicionada nota informando que o diagrama lógico PNG reflete até a V2 e não exibe `enabled`.
- ✅ **5. Planejamento:** marcada a story `4-4-tag-e-envio-no-moodle` (e `epic-4`) como `done` em `sprint-status.yaml` (pois `git tag -l` lista a tag `release-1.0-grupo08`) e acrescentados ao final de `epics.md` os títulos "Épico 6 — BFF rooms (T3)" e "Épico 7 — Frontend rooms (T4)", cada um com 1 parágrafo apontando para o plano `_bmad-output/planning-artifacts/rooms-t3-t4-plano-orca.md`.

**Verificação:**
- `./mvnw.cmd verify` (com Docker Desktop e Testcontainers PostgreSQL 18.6):
  ```text
  [INFO] Running br.pucrs.constrsw.rooms.ContractCoverageIntegrationTests
  [INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 32.70 s -- in br.pucrs.constrsw.rooms.ContractCoverageIntegrationTests
  ...
  [INFO] Results:
  [INFO]
  [INFO] Tests run: 416, Failures: 0, Errors: 0, Skipped: 0
  [INFO]
  [INFO] ------------------------------------------------------------------------
  [INFO] BUILD SUCCESS
  [INFO] ------------------------------------------------------------------------
  [INFO] Total time:  03:54 min
  [INFO] Finished at: 2026-11-24T20:38:40-03:00
  [INFO] ------------------------------------------------------------------------
  ```
- `docker build -t rooms-check .`:
  ```text
  #15 [build 7/9] COPY openapi.yaml ./openapi.yaml
  #15 DONE 0.2s
  #16 [build 8/9] COPY schemas ./schemas
  #16 DONE 0.5s
  #17 [build 9/9] RUN ./mvnw clean package -DskipTests -B
  #17 8.698 [INFO] Copying 1 resource from . to target/classes/static/openapi
  #17 8.716 [INFO] Copying 9 resources from schemas to target/classes/static/openapi/schemas
  #17 21.07 [INFO] BUILD SUCCESS
  #18 [stage-1 4/4] COPY --from=build /app/target/*.jar app.jar
  #19 naming to docker.io/library/rooms-check:latest done
  ```
- `git grep -n "actuator/health"`: nenhuma ocorrência em código, scripts, coleção Bruno ou `README.md` (restam apenas menções históricas nos artefatos antigos do T2 em `_bmad-output/`, que a ficha instrui a não reescrever).

**Critérios de aceite:**
- [x] `docker build` do submódulo passa (`docker.io/library/rooms-check:latest` gerada com `BUILD SUCCESS` e `copy-openapi` copiando `openapi.yaml` e os 9 schemas).
- [x] `./mvnw verify` verde (`Tests run: 416, Failures: 0, Errors: 0, Skipped: 0`).
- [x] Nenhuma alteração em `src/main/**`, `openapi.yaml`, `schemas/**` (`git diff grupo08..grupo08-feat/t3-fix-build-health --stat` toca apenas os 8 arquivos permitidos).
- [x] `grep actuator/health` sem ocorrências indevidas.
- [x] README coerente com V4 e exclusão lógica.

**Pedidos fora do escopo:** nenhum

**Dúvidas / contradições encontradas:**
- Conforme orientado na tarefa 5 da ficha 8.1: a tag `release-1.0-grupo08` existe localmente (`git tag -l` retornou `release-1.0-grupo08`), por isso marquei `4-4-tag-e-envio-no-moodle: done` em `sprint-status.yaml`. Confirma se a tag `release-1.0-grupo08` já foi enviada ao remoto / Moodle?

**Riscos conhecidos que ficaram:** nenhum
