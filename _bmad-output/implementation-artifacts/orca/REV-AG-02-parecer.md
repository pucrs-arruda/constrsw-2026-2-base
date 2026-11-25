## Revisão complementar — AG-02, seção 0.6

**Veredito:** APROVADO o complemento documental `54dcb187921f38914bdea5f8c67450939dc6d49c` em `bff/grupo08-feat/rooms-readme`.

**Verificações rodadas:** `git show 54dcb18 -- README.md` e `git diff --check bb0cd63..54dcb18`: somente três linhas no README da seção rooms, sem erro de whitespace. Documenta a linha raw do bootstrap e as exceções compartilhadas previstas na seção 0.6. Não há mudança executável; não foi necessário repetir testes para este complemento documental.

`git fetch origin bff/grupo08` e `git log origin/bff/grupo08` confirmaram o merge principal em **`bb0cd637a10863f1d3ac63ab8de4f2b4d96072e7`**, com pais `eec7798` e `0eccfbe`. Este é o hash completo verificado no Git; uma das mensagens do agente informou um hash completo diferente com o mesmo prefixo curto. A suíte independente de 154 testes, build e contrato desse merge já passou com Node 24.22.3, conforme adendo abaixo.

**Problemas:** nenhum bloqueante no complemento documental. O merge/push de `54dcb18` ainda precisa ser coordenado com AG-03, que já está trabalhando no mesmo checkout; não trocar branch enquanto ele trabalha.

**Itens do checklist não atendidos:** nenhum para aprovar este complemento; integração dele na principal pendente.

**Liberado para:** integrar o complemento documental com coordenação do checkout. AG-03 já iniciado pelo coordenador no GPT (`orca_session_id:dd59715c-7a17-4b99-90a0-502fc5fba250`); não reenviar liberação à sessão antiga. A revisão do AG-03 exigirá a seção 0.6 e duas execuções E2E consecutivas verdes.

---

## Adendo — REV-1b, 24/11/2026

**Veredito:** APROVADO pelo REV-1; verificações de build, suíte e contrato corroboradas pelo REV-1b no merge local `bb0cd63`. Liberação do AG-03 ainda depende de confirmar o push.

**Verificações rodadas:**
- `git diff bb0cd63^1..bb0cd63 --stat`: oito arquivos, mesmos arquivos da entrega aprovada. `git diff --check`: sem erros.
- Em cópia isolada do checkout, usando `node:24-alpine`, Node `v24.22.3`: `npm ci --no-audit --no-fund`, `npm test -- --runInBand`, `npm run build`, `npm run test:contract`. Todos concluíram com código zero.
- Jest: **10 suítes e 154 testes aprovados**, zero snapshots, 30,749 s. Contrato offline: **3 documentos, 352 referências, 19 operações Courses**, todos os schemas compilados.
- `git fetch origin bff/grupo08` e `git log origin/bff/grupo08`: remoto ainda em `eec7798` nesta conferência; merge local `bb0cd63` sete commits à frente.

**Problemas:** confirmação de merge no remoto pendente. O ruleset e os nomes antigos abaixo são históricos; a principal correta agora é `bff/grupo08`, conforme seção 3.1 e instrução atual do Lucas.

**Itens do checklist não atendidos para liberar a próxima onda:** hash pushado e saída Jest da conclusão do AG-02 ainda não recebidos pelo REV-1b; presença do merge no remoto ainda não confirmada.

**Liberado para:** nenhum novo agente nesta conferência. AG-03 aguarda o portão acima. O parecer original é preservado abaixo para rastreabilidade.

---

## Revisão — AG-02 BFF Rooms Core (Revisão 2)

**Veredito:** APROVADO (o merge `--no-ff` em `grupo08-bff` pode ser executado localmente; o **push** ainda depende da decisão do Lucas sobre o ruleset GH013, que é externa ao AG-02).

**Contexto da retomada:** o Orca foi fechado e tanto o REV-1 (Claude) quanto o AG-02 (Antigravity) retomaram em endereços novos. O trabalho oficial do AG-02 está preservado no checkout `backend/bff` (branch `grupo08-bff-feat/rooms-core`), nos 6 commits abaixo. Existe uma segunda sessão do AG-02 (`orca_session_id:221b2244-c5e4-428b-9d21-5288d9a9ee2d`) com commits paralelos (`a6afeba, fbfc09a, 27d83fb, e4fd3ee, bd3a8b4`) que **não** estão refletidos no disco e cuja verificação **não** incluiu a execução da suíte em Node 24. Esse parecer trata **apenas do trabalho que está no disco**; a duplicata precisa ser resolvida pelo Lucas antes de qualquer merge.

**Verificações rodadas (no submódulo `backend/bff`, branch `grupo08-bff-feat/rooms-core`, HEAD `0eccfbe`):**
- `git log --oneline main..grupo08-bff-feat/rooms-core` — 6 commits (`0eccfbe, 4423621, c766720, e979475, 7f22745, 0cccb52`), mensagens em pt-BR no padrão Conventional.
- `git diff --stat main..grupo08-bff-feat/rooms-core` — 8 arquivos; `src/bootstrap.ts` com +1 linha; demais dentro do módulo rooms ou README.md.
- `git show 0eccfbe` — commit de correção das ressalvas aplica:
  - `composition-contract.ts`: `format: 'uuid'` nos campos `id` e `roomId` do `classSchema` + comentário explicando que `additionalProperties` ficou aberto de propósito (ressalva 3 ✅).
  - `rooms.service.ts`: validação explícita `isObject(payload)` antes de embrulhar o payload em lista no modo `item`; mensagens de erro mais específicas (ressalva 4 ✅).
  - `rooms.controller.ts`: guard de corpo em GET/HEAD agora usa `Buffer.isBuffer(body) && body.length > 0` **ou** `typeof body === 'string' && body.length > 0`, além de tratamento explícito para `Content-Length: 0` (ressalva 5 ✅).
  - `rooms.service.spec.ts`: ids das classes nos fixtures agora são UUIDs válidos (`c1111111-…`, `c2222222-…`, `c4444444-…`), coerente com `format: 'uuid'`.
- `node --version` nesta máquina: `v22.14.0`. Não executei `npm test -- --runInBand` localmente; **confio na saída completa colada pelo AG-02 no relatório da Revisão 2**, que mostra 10/10 test suites e 154/154 testes verdes com Node v24.22.3. (Ressalva 1 ✅.)

**Problemas:**

1. **[fora do escopo do AG-02]** A ressalva 2 (push de `grupo08-bff` bloqueado pelo ruleset `GH013` do remoto `pucrs-arruda/constrsw-2026-2-bff`) continua pendente de decisão do Lucas. Isso **não** bloqueia a aprovação do trabalho do AG-02: o código está pronto, testado e merecedor de merge. Bloqueia apenas o `git push origin grupo08-bff` previsto pela seção 3.1 do plano. Até o Lucas responder, mantenho o merge local sem push (ou aguardo a liberação completa).

2. **[a decidir pelo Lucas]** Há duas sessões do AG-02 vivas no Orca: a original (`orca_session_id:44390df2-ffda-4c3d-96d4-bf96b6883da1`, cujos commits estão no disco) e a retomada (`orca_session_id:221b2244-c5e4-428b-9d21-5288d9a9ee2d`, com commits paralelos não aplicados no disco e sem execução em Node 24). Precisamos decidir qual sessão continua "oficial" e descartar a outra para evitar divergência.

**Itens do checklist atendidos:**
- Comandos de verificação rodados pelo REV com o mesmo resultado: ✅ (exceto `npm test`, cuja execução foi evidenciada pelo próprio AG-02 em Node 24).
- Suíte inteira (courses/students/reservations/rooms) verde: ✅ (154/154).
- Única alteração fora do módulo é a linha do `raw()` em `bootstrap.ts`: ✅.
- Rotas em `/api/v1/rooms*`, `/v1/rooms` removida (D10): ✅.
- `@Get()`/`@Get(':id')` antes dos `@All`: ✅.
- Coleção vazia não chama classes: ✅.
- 503 `application/problem+json` com `code: 'BFF-DEPENDENCY'` nas duas rotas compostas e no proxy puro: ✅.
- `X-Total-Count` preservado; `etag`/`last-modified` removidos; `cache-control: no-store`: ✅.
- `retryMethods: ['GET', 'HEAD']` nos dois downstreams: ✅.
- Tokens de injeção exatos da 6.1 (`ROOMS_DOWNSTREAM`, `ROOMS_CLASSES_DOWNSTREAM`, `ROOMS_CLOCK`): ✅.
- Query crua e corpo cru (Buffer) repassados: ✅.
- Validação Ajv isolada em `composition-contract.ts`, sem importar validador privado do courses: ✅.

**Liberação do AG-03:** ainda **não libero**, porque a seção 3.1 do plano exige que o AG-03 crie a branch de desenvolvimento a partir da principal `grupo08-bff` **atualizada**, e enquanto o ruleset GH013 não for resolvido o push dessa principal fica no ar. Assim que o Lucas confirmar (a) o ajuste do ruleset ou (b) o novo nome aceito para a principal, faço o merge `--no-ff` da `grupo08-bff-feat/rooms-core` na principal, roto a Verificação da ficha de novo na principal, dou push e **imediatamente** envio `LIBERADO AG-03`.
