## Relatório de entrega — AG-06 Dados de Rooms

**Branch / commits:** `frontend/grupo08-feat/rooms-data` — `db20174` `feat(frontend): implementa camada de dados de salas`. Base do AG-04 em `cd2ced5`.

**Arquivos alterados:**

- `frontend/src/app/shared/http/`: `api-error.ts`, `error-parser.ts`, `error-parser.spec.ts`, `filter-query.ts`, `filter-query.spec.ts`.
- `frontend/src/app/surfaces/ux-rooms/data/`: `rooms.models.ts`, `rooms-api.service.ts`, `rooms-api.service.spec.ts`, `rooms.utils.ts`, `rooms.utils.spec.ts`.

**O que foi feito:**

- ✅ Modelos e assinaturas públicas da seção 6.7, nas pastas da seção 0.2.
- ✅ Filtros com codificação por `encodeURIComponent`, regras de operadores, curingas, ordenação e paginação.
- ✅ Conversão de falhas HTTP em `ApiError`, incluindo o problema de composição, envelopes de domínio e falha de rede.
- ✅ Serviço HTTP para salas e características de acessibilidade via BFF. Paginação por `X-Total-Count`, tratamento de 404, corpos de escrita conforme a ficha e exclusões 204.
- ✅ Helpers de capacidade, código de característica e semestre. Na ausência de turmas, o semestre é calculado para exibição no fuso de São Paulo.
- ✅ Testes com `HttpTestingController`, além de testes de filtros, parser e helpers.

**Verificação:**

- `npm ci` no Node `v24.22.3`: `added 294 packages, and audited 295 packages` e `found 0 vulnerabilities`. O npm 11 emitiu avisos de `allowScripts` para quatro dependências da base.
- `node node_modules/typescript/bin/tsc --noEmit -p tsconfig.spec.json`: sem diagnósticos.
- `node node_modules/@angular/cli/bin/ng.js build --configuration production`: `Application bundle generation complete. [60.990 seconds]`.
- `npx ng test --watch=false`: `Test Files 12 passed (12)`, `Tests 57 passed (57)`.
- `git diff --cached --check`: sem ocorrências.
- As evidências de viewport 360, 768 e 1280 se aplicam às entregas das telas e ao E2E. A ficha AG-06 cobre a camada de dados.

**Critérios de aceite:**

- ✅ Interfaces públicas da seção 6.7 preservadas. Divergências com o schema de classes registradas abaixo.
- ✅ Teste de filtros confere `%7Bgteq%7D40` e `%7Blike%7D%25lab%25`.
- ✅ Testes distinguem 404 de lista, sala individual e lista de características com ou sem sala existente.
- ✅ Testes verificam PATCH com o objeto fornecido, campos nulos ou falsos e recusa de corpo vazio.
- ✅ Falhas HTTP observáveis chegam como `ApiError`. Filtro inválido e PATCH vazio geram erro de programação conforme a ficha.
- ✅ Build e suíte Angular verdes.

**Pedidos fora do escopo:** revisão da integração sobre o scaffold oficial pelo REV-2. O `origin/main` já contém o commit `f13f4d1` (`feat: scaffold Angular 22 + Material with DESIGN theme`). Aplicar a seção 0.1 antes de integrar. A branch de entrega permanece sobre o scaffold provisório do AG-04, conforme instrução do despacho.

**Dúvidas / contradições encontradas:** o schema `Class` do Grupo 01 permite omissão e valor nulo em `code`, `label` e `modality`, exige `averageRating` (que pode ser nulo), define `professorId` como UUID obrigatório, inclui `studentIds` e referencia um enum para `status`. `ClassSummary` segue exatamente a seção 6.7, conforme instrução do despacho. Qualquer ajuste deve ser combinado com REV-2, AG-07 e AG-08.

**Riscos conhecidos que ficaram:** a tipagem combinada de `ClassSummary` declara como strings campos que a API pode omitir ou enviar nulos. A validação da jornada com a stack real fica para o E2E da integração.

```text
Refs: FE-CAP-3, FE-CAP-4; UX-ROOMS; ownership: Grupo 08; paths: frontend/src/app/shared/http/, frontend/src/app/surfaces/ux-rooms/data/
```
