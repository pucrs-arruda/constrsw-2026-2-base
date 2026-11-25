# REV-1b — critérios adicionais de revisão do AG-03

Instrução recebida do coordenador em `msg_57c3466fdad7`, referente à exigência do professor de 24/11/2026. O item 5b da ficha 8.3 foi relido, assim como `SPEC.md`, `routes.md`, `composition.md` e `contribution.md` de `_bmad-output/specs/spec-bff/`.

Atualização do coordenador `msg_640b1aef0984`: AG-03 já iniciado no GPT em `orca_session_id:dd59715c-7a17-4b99-90a0-502fc5fba250`; ignorar a sessão antiga e não reenviar liberação. O REV confirmou via fetch/log `origin/bff/grupo08` em `bb0cd637a10863f1d3ac63ab8de4f2b4d96072e7`, merge de `0eccfbe`.

## Evidência obrigatória para aprovação

- Complementar `backend/bff/test` e reutilizar os helpers e a estrutura E2E existentes, sem framework paralelo.
- Conforme seção 0.6, usar `students.e2e-spec.ts` como modelo, validar `GET /health`, autenticar via `POST {oauth}/login` e criar uma class real com o `roomId` da sala e o semestre corrente, comprovando sua presença nos GETs compostos. Remover também a class e quaisquer fixtures criadas na limpeza. Não usar o helper `accessToken()` que obtém token diretamente no Keycloak.
- Cobrir todas as 12 operações públicas de rooms no BFF, com ao menos um teste por operação:
  - `GET` e `POST /api/v1/rooms`;
  - `GET`, `PUT`, `PATCH` e `DELETE /api/v1/rooms/{id}`;
  - `GET` e `POST /api/v1/rooms/{id}/accessibility-features`;
  - `GET`, `PUT`, `PATCH` e `DELETE /api/v1/rooms/{id}/accessibility-features/{featureId}`.
- Lista sem filtro, filtro com resultado, filtro sem resultado com 404, paginação e ordenação com `X-Total-Count`; composição `classes` nos dois GETs principais; GET após exclusão com 404.
- Recusas 401 sem token e 403 de escrita com student, preservando o envelope de domínio previsto.
- Códigos únicos por execução dentro do limite de 20 caracteres, sem depender de execução anterior nem de contagem fixa de salas.
- Limpeza em `afterAll`/`finally` de todos os recursos criados pelo teste, inclusive em falha intermediária. Ignorar 404 na limpeza; não apagar dados preexistentes nem esconder outros erros de limpeza. Exclusão lógica conforme contrato é a limpeza disponível pela API.
- Relatório com hash testado e saídas de **duas execuções consecutivas de `npm run test:e2e:rooms`, ambas verdes**, na mesma stack, sem reset do banco entre elas. Testes ignorados ou execução parcial não satisfazem esse critério. O REV repetirá a verificação aplicável conforme seção 9.
- Permanecem obrigatórios os 18 casos de integração, suíte completa em Node 24, build e contrato offline, preservando as 19 operações Courses e os módulos alheios.

## Aplicação da spec-bff

Revisar o módulo rooms sob `/api/v1`, composição apenas nos GETs principais, semestre em `America/Sao_Paulo` com relógio injetável, vínculo por `roomId`, classes excluídas fora da composição, resposta 503 `BFF-DEPENDENCY` sem sala parcial, proxy preservando corpo/status/headers e identidade encaminhada pelo helper compartilhado. Manter circuitos independentes e escopo do Grupo 08. A nova spec não autoriza reescrever módulos de outros grupos.

A exigência explícita de duas execuções verdes prevalece sobre o texto anterior “se possível” ainda presente nos critérios genéricos da ficha. Ausência de stack ou falha de execução deve ser reportada como pendência, não como aprovação.

O AG-09 também deverá preservar a cobertura e a idempotência na entrega integrada. Sua liberação continua condicionada a AG-01 e AG-03 aprovados e mergeados e ao aviso `Frontend concluído` do REV-2.

Seção 0 lida integralmente: ela prevalece. AG-09 também assume o E2E frontend em Playwright nas larguras 360, 768 e 1280, base contendo as specs trazidas em `4174494` a partir de `grupo08-base-feat/orquestracao`, sem editar `docker-compose.yml` e mantendo frontend na porta 8080.
