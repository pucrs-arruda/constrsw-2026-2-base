## Revisão — AG-04 Frontend Fundação • seção 0 • `cd2ced5`

**Veredito:** REPROVADO para merge. Esta decisão substitui as rodadas anteriores. A chegada do scaffold do professor acionou a seção 0.1.

**Verificações rodadas:** `ls-remote --heads origin` confirmou a principal do grupo em `d6ee998`, a feature em `cd2ced5` e `main` em `f13f4d1`. O commit entregue descende da principal do grupo, mas não contém o scaffold oficial. Inspecionei ambos pelo Git. O oficial inclui Angular, bootstrap, tema Material, roteador, Dockerfile e nginx. O build Docker do hash entregue passou. Confirmei a reorganização em `shell/`, `shared/`, `auth/` e `surfaces/ux-rooms/`, o único `loadChildren` para `ROOMS_ROUTES`, o bloco Refs e a identificação de ownership.

**Problemas:**

1. [bloqueante] `AG-04-relatorio.md`, verificação 1 — a conclusão de que o scaffold do professor ainda não existe ficou desatualizada. Suspender o merge de `cd2ced5`. Preparar a entrega em branch do grupo sobre o scaffold oficial, preservando bootstrap e tema oficiais, uma única aplicação e o ownership do professor. Portar os incrementos de Rooms e coordenar com o responsável do projeto qualquer complemento necessário em shell/auth/shared. Sem checkout, commit ou push em `main` e sem reescrever a feature publicada por force push. Informar o hash de referência aos demais worktrees quando a base estiver validada.
2. [bloqueante] `src/app/shell/shell.component.ts:98` — em `cd2ced5`, o fechamento do menu restaura o foco, mas não há transferência para o `h1` quando muda a superfície. Na integração, validar navegação por link para outra rota, inclusive com a folha modal aberta. O Escape sem navegação continua devolvendo o foco ao botão.
3. [bloqueante] `src/app/shell/shell.component.spec.ts`, caso “larguras 360px ...” — atribui os signals manualmente. O teste passaria com media queries trocadas. Referenciar screenshots reais em 360/768/1280 ou teste que altere o viewport efetivo e observe a aplicação.
4. [bloqueante] `src/styles.scss:26` — as regras globais dependem de classes internas `.mat-mdc-*` da implementação Material. A spec de stack as proíbe. Preservar o tema oficial e aplicar as medidas por APIs públicas de tema ou por classes da aplicação.

**Itens do checklist não atendidos:** base oficial, foco após navegação, evidência real de viewport no relatório e tema conforme `spec-frontend/stack.md`.

**Liberado para:** nenhum merge. O desenvolvimento AG-05 a AG-08 já ocorre em worktrees independentes. A ordem de integração é AG-04 → AG-05 → AG-06 → AG-07 → AG-08.

---

## Revisão — AG-04 Frontend Fundação • segunda rodada

**Veredito:** REPROVADO para merge no hash `af62a7d` do relatório `msg_f6f92433b467`. Os quatro bloqueios funcionais da rodada anterior foram corrigidos. O bloqueio desta entrega é a base Git.

**Verificações rodadas:** suíte do Angular com as mudanças do shell em Node 24, **28/28**. No navegador do `ng serve` a 375 px, confirmei avatar, marca e Sair, fonte local `Material Symbols Outlined`, drawer modal e retorno de foco ao botão após Escape. Em 768 px o drawer ficou modal e em 1280 px fixo. Com o `nginx.conf` extraído do commit, o teste com upstreams de eco recebeu `POST /login` e `GET /api/v1/rooms?capacity=%7Bgteq%7D40&name=%7Blike%7D%25lab%25`.

**Problemas:**

1. [bloqueante] Relatório, campo “Branch / commits” — `git merge-base --is-ancestor origin/frontend/grupo08 af62a7d` retornou 1. A seção 3.1 atualizada exige partir de `frontend/grupo08` (remoto consultado em `d6ee998`). Entregar o hash já portado em `frontend/grupo08-feat/base`, preservando o README do professor, seu mapa de donos e a galeria de mockups. A comparação entre as duas árvores antes da migração mostrava 41 arquivos ausentes na árvore antiga. Não há necessidade de reimplementar os componentes. Atualizar o relatório e conferir build e testes depois da migração.
2. [ressalva] `nginx.conf:8` e árvore de pastas do `README.md` — ainda constam o tipo duplicado no health e o caminho de `public/` dentro de `src/`. Aproveitar a migração para corrigir os dois pontos de documentação/configuração.

**Itens do checklist não atendidos:** ancestralidade e nome da branch no hash entregue, relatório correspondente à branch vigente.

**Liberado para:** nenhum. Aguardar parecer sobre o novo hash antes do merge. AG-05 segue em espera.

---

## Revisão — AG-04 Frontend Fundação • primeira rodada

**Veredito:** REPROVADO no commit `c7a9e70`. Inspeção do estado recuperado em `grupo08-frontend-feat/base`, antes do relatório 8.0 da sessão retomada. A próxima avaliação deve citar o hash corrigido.

**Verificações rodadas:**

- `git diff --stat c1d00e9..c7a9e70` mostrou 57 arquivos no frontend. A seleção de arquivos, as rotas lazy e os stubs de autenticação e salas correspondem à ficha. `git diff --check` passou. A busca estática em `src` não encontrou chamadas às portas dos serviços, uso de armazenamento do navegador, JWT literal ou chave privada.
- O Angular CLI recusou o Node 22.14.0 da máquina antes de executar. No estágio `node:24-alpine` do Dockerfile, `npm ci` e `ng build --configuration production` concluíram. Na imagem desse estágio, `npx ng test --watch=false` passou com 27 testes em oito arquivos.
- Na imagem de produção, `GET /health` retornou `200` e corpo `ok`. `GET /salas` retornou `200` com o `app-root`. Em rede de teste isolada, dois serviços com os nomes `oauth` e `api` devolveram o método e a URI recebidos. O nginx perdeu caminho e query nas duas rotas (achado 1). O mesmo par de requisições pelo `ng serve` na porta 8080 do container chegou corretamente a `/login` e `/api/v1/rooms?capacity=%7Bgteq%7D40`.
- No navegador com `ng serve`, conferi 375, 768 e 1280 px. O drawer mediu 280 px, ficou modal em 375 e 768 e fixo em 1280. Os dez links estavam na ordem prevista. Testei abertura e Escape em 375 e inspecionei o foco após o fechamento.

**Problemas:**

1. [bloqueante] `nginx.conf:14` e `nginx.conf:22` — `POST /api/auth/login` chegou como `POST /`. `GET /api/bff/api/v1/rooms?capacity=%7Bgteq%7D40` chegou como `GET /`. O esperado é remover apenas o prefixo e preservar o restante e a query. Corrigir ambos e validar na imagem de produção com um upstream que registre a URI.
2. [bloqueante] `src/styles/_typography.scss:11` e `src/app/core/layout/shell.component.ts:45` — o projeto importa a fonte Material Symbols Outlined, mas o ícone do menu usa Arial e os ícones da navegação usam Source Sans 3 no navegador. Aplicar a fonte local e conferir os glifos renderizados no menu e no drawer.
3. [bloqueante] `src/app/core/layout/shell.component.ts:84` e `src/app/core/layout/shell.component.spec.ts:46` — em 375 px, após clicar no hambúrguer e pressionar Escape, o drawer fechou e o foco permaneceu num link interno. O teste chama o método diretamente e verifica apenas `close()`. Garantir foco no botão após o fechamento e validar a interação de teclado real.
4. [bloqueante] `src/app/core/layout/shell.component.ts:51` — em 375 px, legenda e e-mail seguem visíveis e falta o avatar definido em `EXPERIENCE.md:176`. Adequar o cabeçalho compacto e manter o botão Sair acessível.
5. [ressalva] `README.md` — indicar a versão mínima de Node para reproduzir os comandos locais. O CLI instalado exige 22.22.3, 24.15.0 ou versão compatível superior. A árvore também deve apontar para `public/config.json` na raiz do frontend.
6. [ressalva] `nginx.conf:8` — a resposta de health contém dois cabeçalhos Content-Type, `application/octet-stream` e `text/plain`. Emitir um único tipo de conteúdo.

**Itens do checklist não atendidos:** proxy de produção, ícones, retorno do foco e apresentação compacta. Relatório 8.0 da versão corrigida pendente. As verificações de salas, dados e auth real pertencem aos agentes seguintes.

**Liberado para:** nenhum. AG-05 aguarda aprovação do AG-04 e merge em `grupo08-frontend`.
