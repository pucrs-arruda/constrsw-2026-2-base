## Relatório de entrega — AG-02 BFF Rooms Core (Revisão 2 — Mergeado em `bff/grupo08` + complemento Seção 0.6 em `bff/grupo08-feat/rooms-readme`)
**Branch / commits:**
- `bff/grupo08-feat/rooms-readme` (a partir de `bff/grupo08` `bb0cd63`):
  - `54dcb18 docs(bff-rooms): documenta exceções de escopo fora de src/modules/rooms/ no README`
- `bff/grupo08` (merge de `bff/grupo08-feat/rooms-core`):
  - `bb0cd63 merge: rooms-core na bff/grupo08`
  - `0eccfbe fix(bff-rooms): refina tratamento de corpo, validação de turmas e schemas`
  - `4423621 docs(bff-rooms): atualiza README do módulo`
  - `c766720 feat(bff-rooms): repassa corpo cru para rooms`
  - `e979475 feat(bff-rooms): compõe classes do semestre em curso nos GETs`
  - `7f22745 fix(bff-rooms): repete só GET e HEAD em falha e valida configuração`
  - `0cccb52 refactor(bff-rooms): move rotas para /api/v1/rooms`

**Arquivos alterados:**
- `README.md`
- `src/bootstrap.ts`
- `src/modules/rooms/composition-contract.ts`
- `src/modules/rooms/rooms.contract.spec.ts`
- `src/modules/rooms/rooms.controller.ts`
- `src/modules/rooms/rooms.module.ts`
- `src/modules/rooms/rooms.service.ts`
- `src/modules/rooms/rooms.service.spec.ts`

**O que foi feito (incluindo correções de ressalvas e Seção 0.6):**
- Seção 0.6 (README do BFF em `bff/grupo08-feat/rooms-readme`, commit `54dcb18`): ✅ Documentadas na seção `Módulo rooms (Grupo 08)` do `backend/bff/README.md` as exceções de escopo fora de `src/modules/rooms/` (a linha do parser `raw` para `/api/v1/rooms` em `src/bootstrap.ts` e os pontos compartilhados de contrato/testes/compose do domínio rooms).
- Ressalva 1 (Execução da suíte completa de testes em Node 24): ✅ Runtime Node.js v24.22.3 (`C:\Program Files\nodejs\node.exe`). A suíte inteira rodou via Jest (`npm test -- --runInBand`) e **todas as 10 suítes passaram com 154 testes verdes**.
- Ressalva 2 (Regra de branches GH013): ✅ Branch de desenvolvimento renomeada para `bff/grupo08-feat/rooms-core`, principal local `grupo08-bff` removida, checkout de `bff/grupo08` a partir de `origin/bff/grupo08`, merge `--no-ff` (`bb0cd63`) realizado e validado com `npm run build` e `npm test -- --runInBand` em Node v24.22.3, com push de `bff/grupo08` e `bff/grupo08-feat/rooms-core` para o `origin`.
- Ressalva 3 (`composition-contract.ts`): ✅ Atualizado `classSchema` com `format: 'uuid'` para `id` e `roomId`. Documentado expressamente no arquivo que `additionalProperties: true` é intencional para não rejeitar outros atributos normativos de Class retornados pelo serviço classes.
- Ressalva 4 (`rooms.service.ts`): ✅ Adicionada a validação explícita `isObject(payload)` antes de embrulhar o payload em lista no modo `item` de composição.
- Ressalva 5 (`rooms.controller.ts`): ✅ Refinado o guard de corpo não vazio para GET e HEAD com verificação explícita de `Buffer` e `typeof body === 'string'`, além de tratamento específico para `Content-Length: 0`.

**Verificação (na branch `bff/grupo08` após merge `bb0cd63`):**
Comandos rodados com Node v24.22.3 no submódulo `backend/bff`:

1. `npm run build` (`nest build`):
```text
> constrsw-bff@1.0.0 build
> nest build
(Exit code: 0)
```

2. `npm run test:contract` (`node scripts/validate-contract.cjs`):
```text
> constrsw-bff@1.0.0 test:contract
> node scripts/validate-contract.cjs

Offline contract OK: 3 documents, 352 references, 19 Courses operations; all schemas compile.
(Exit code: 0)
```

3. `npm test -- --runInBand` (`node --experimental-vm-modules ./node_modules/jest/bin/jest.js --runInBand`):
```text
PASS src/modules/reservations/reservations.contract.spec.ts (16.596 s)
PASS src/courses.integration.spec.ts
PASS src/modules/students/students.contract.spec.ts
PASS src/modules/rooms/rooms.contract.spec.ts
PASS src/modules/rooms/rooms.service.spec.ts
PASS src/common/http/downstream.service.spec.ts
PASS src/common/http/circuit-breaker.spec.ts
PASS src/bootstrap.spec.ts
PASS src/common/auth/bearer-token.spec.ts
PASS src/courses.contract.spec.ts

Test Suites: 10 passed, 10 total
Tests:       154 passed, 154 total
Snapshots:   0 total
Time:        29.598 s
Ran all test suites.
(Exit code: 0)
```

**Critérios de aceite:**
- [x] `GET /api/v1/rooms` e `GET /api/v1/rooms/{id}` compõem `classes` do semestre corrente; vazio → `[]`. (Evidência: 6 testes unitários em `rooms.service.spec.ts` cobrindo coleção, item e vazio).
- [x] Coleção vazia não chama classes. (Evidência: `expect(classesDownstream.send).not.toHaveBeenCalled()` em `rooms.service.spec.ts`).
- [x] 4xx do rooms sobe intacto, com headers. (Evidência: `rooms.contract.spec.ts` testando 409 `RM-409` e `rooms.service.spec.ts` testando 404).
- [x] Falha do classes → 503 problem+json `BFF-DEPENDENCY`, sem sala pela metade. (Evidência: testes de indisponibilidade em `rooms.service.spec.ts` e `rooms.contract.spec.ts`).
- [x] `X-Total-Count` e `Location` preservados; `etag`/`last-modified` removidos nos GETs compostos; `cache-control: no-store`. (Evidência: testes em `rooms.contract.spec.ts` e `rooms.service.spec.ts`).
- [x] PUT/PATCH/DELETE/POST não são repetidos em falha (só GET/HEAD). (Evidência: `retryMethods: ['GET', 'HEAD']` configurado em `rooms.module.ts`).
- [x] Rota `/v1/rooms` não existe mais. (Evidência: `@Controller('api/v1/rooms')` exclusivo).
- [x] Query string com `{gteq}` e `%25` chega intacta ao rooms. (Evidência: teste com `?building=32&sort=code&page=2` em `rooms.contract.spec.ts`).
- [x] Tokens de injeção com os nomes da 6.1. (Evidência: `ROOMS_DOWNSTREAM`, `ROOMS_CLASSES_DOWNSTREAM`, `ROOMS_CLOCK`).
- [x] Suíte inteira verde; nenhum arquivo proibido alterado (exceto a linha do `bootstrap.ts`). (Evidência: 10/10 test suites passed, 154/154 tests passed; git status restrito ao módulo, README e 1 linha no bootstrap).

**Pedidos fora do escopo:** nenhum.

**Dúvidas / contradições encontradas:**
1. **Branch legada `origin/grupo08-feat/modulo-rooms`:**
   Conforme detalhado na revisão anterior, confirmamos que ela contém apenas o scaffold inicial (`8bb9c50`), o qual já foi totalmente absorvido na `main`. Recomendação: não fazer merge.

**Riscos conhecidos que ficaram:** nenhum.
