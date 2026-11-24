# Stack — Frontend

## Runtime

| Peça | Pin / escolha |
|---|---|
| Framework | Angular **22.x** (SPA, sem SSR competindo com o BFF) |
| UI kit | Angular Material (Material Design 3) + Angular CDK |
| Estilo | SCSS + design tokens (`DESIGN.md`) |
| Língua UI | pt-BR |
| Host | container `frontend` no Compose da raiz |
| Origem HTTP de dados | BFF (`BFF_ORIGIN` / porta pública do compose, tipicamente `localhost:8180`) |
| Auth | `backend/oauth` — login/refresh/logout; Bearer nas requests BFF |

## Proibido na SPA

- React / Vite / TanStack Query como stack da aplicação
- `keycloak-js` ou qualquer adapter JS direto ao IdP
- Chamadas browser → nove OpenAPIs de domínio
- Tema Material default sem tokens DESIGN.md
- Seletores CSS em classes internas MDC

## Observabilidade / lab

- Compose sobe a SPA com o envelope lab (AD-7 / OV-9).
- Sem Kubernetes/Helm na v1.
- Health da BFF não é tela; health do container frontend segue o Dockerfile/compose do submódulo.

## Referência visual

- Figma: https://www.figma.com/design/FTSWNiR5rQHXqDizXFJYqp  
- Spines (EXPERIENCE / DESIGN / este SPEC) vencem o mockup em conflito.
