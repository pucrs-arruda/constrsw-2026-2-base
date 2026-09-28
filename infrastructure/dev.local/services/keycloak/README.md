# Keycloak — Identity Provider do constrsw

Este serviço provê o [Keycloak](https://www.keycloak.org/) como **provedor de identidade**
do ambiente local. Ele emite os tokens JWT (`RS256`) e publica as chaves públicas (JWKS)
usadas por todos os serviços para validar autenticação e autorização.

- O serviço `auth` (`backend/auth`) é o **gateway/API** na frente do Keycloak (login, JWKS,
  introspecção, gestão de usuários/roles). Os clientes não falam direto com o Keycloak.
- Os resource servers (`employees`, `professors`, BFF, …) validam o token **localmente** via
  JWKS — o Keycloak/`auth` não é chamado a cada requisição.

| Item | Valor (dev local) |
|---|---|
| Realm | `constrsw` |
| Console | `http://localhost:8180` (admin `admin` / `a12345678`) |
| Issuer (`iss`) | `http://keycloak:8080/realms/constrsw` (interno) |
| Client de aplicação | `oauth` (confidencial, Direct Access Grant habilitado) |
| Audience (`aud`) | **`oauth`** (estrito, em todos os serviços) |
| Import do realm | `constrsw.json` (via `start-dev --import-realm`) |

## Arquivos

| Arquivo | Função |
|---|---|
| `constrsw.json` | Export/import completo do realm `constrsw` (clients, roles, users, scopes, mappers) |
| `Dockerfile` | Imagem do Keycloak para o ambiente local |

## Como o realm é carregado (⚠️ importante)

O container sobe com `start-dev --import-realm` e usa o **volume externo persistente**
`constrsw-keycloak-data`. O import **só ocorre se o realm ainda não existir** no volume.
Portanto, **alterações no `constrsw.json` não têm efeito** enquanto o volume mantiver um
realm antigo. Para reimportar:

```bash
docker compose down
docker volume rm constrsw-keycloak-data
docker volume create constrsw-keycloak-data
docker compose up --build
```

## Roles do realm

Realm roles que dirigem a autorização (claim `realm_access.roles`):

| Role | Acesso esperado nos resource servers |
|---|---|
| `administrator` | Total (todos os métodos/rotas) |
| `coordinator` | Somente `GET` |
| `professor` | Somente `GET` |
| `student` | Somente `GET` |

> O role `professor` é apenas um papel de usuário no realm — **não** tem relação com o
> serviço de domínio `professors`.

## Usuários de teste

Um usuário por role, todos com a **mesma senha** (`a12345678`):

| Usuário | Realm role |
|---|---|
| `admin@pucrs.br` | `administrator` |
| `coordinator@pucrs.br` | `coordinator` |
| `professor@pucrs.br` | `professor` |
| `student@pucrs.br` | `student` |

```bash
# Obter um token (via serviço auth)
curl -s -X POST http://localhost:8181/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"student@pucrs.br","password":"a12345678"}' | jq -r .access_token
```

## Tokens JWT e o claim `aud`

Os access tokens são `RS256`, emitidos para o client `oauth`. Por decisão de projeto, todos
os serviços validam **`aud = ["oauth"]` estrito** (`JWT_AUDIENCE=oauth`). Dois ajustes no
realm garantem isso:

1. **Audience mapper** (`oidc-audience-mapper`) no client `oauth`, com
   `included.client.audience = oauth` e `access.token.claim = true` → adiciona `oauth` ao
   `aud` de todo token emitido por esse client.
2. **Remoção** do mapper `audience resolve` (`oidc-audience-resolve-mapper`) do client scope
   `roles` → impede que audiences dinâmicos (`account`, `realm-management`, `broker`) sejam
   injetados a partir dos client roles do usuário.

Resultado: `aud` contém **apenas** `oauth`, enquanto `realm_access.roles` continua trazendo
os realm roles do usuário (mappers `realm roles` e `client roles` permanecem).

### Verificação

```bash
TOKEN=$(curl -s -X POST http://localhost:8181/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin@pucrs.br","password":"a12345678"}' | jq -r .access_token)

echo "$TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq '{aud, roles: .realm_access.roles}'
# aud deve ser "oauth"; roles deve conter "administrator"
```

## Endpoints relevantes do Keycloak (proxied pelo `auth`)

| Keycloak | Via `auth` |
|---|---|
| `/realms/constrsw/protocol/openid-connect/token` | `POST /login`, `POST /auth/refresh` |
| `/realms/constrsw/protocol/openid-connect/certs` (JWKS) | `GET /auth/jwks` |
| `/realms/constrsw/protocol/openid-connect/token/introspect` | `POST /auth/validate` |

Políticas de autenticação/autorização do lado dos serviços:
[`backend/auth/README.md`](../../../../backend/auth/README.md),
[`backend/employees/README.md`](../../../../backend/employees/README.md),
[`backend/professors/README.md`](../../../../backend/professors/README.md).
