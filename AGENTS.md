# Cursor Cloud specific instructions

O Cloud Agent roda numa VM Ubuntu, não no notebook. O Docker local e os containers já em execução na máquina do desenvolvedor não existem nessa VM.

O `start` sobe o daemon do Docker e cria os volumes externos que o `docker-compose.yml` exige:

- `constrsw-prometheus-data`
- `constrsw-keycloak-data`
- `constrsw-postgresql-data`
- `constrsw-mongodb-data`

O `install` inicializa os submódulos. Cada serviço de aplicação vive no próprio repositório (`backend/*` e `frontend`).

A VM padrão tem pouca memória para a stack inteira. Suba só os serviços da tarefa, a partir da raiz do repositório:

```bash
docker compose up -d --build postgresql keycloak oauth
```

**Imagens Docker:** todo serviço com `build:` neste compose usa `image: constrsw/<container_name>` (igual ao `container_name`, ex. container `api` → `constrsw/api`). Não use o nome do service quando ele divergir do container. Ao rebuildar um serviço só, evite retaggar irmãos:

```bash
docker compose build frontend && docker compose up -d --no-deps frontend
```

O Compose lê o `.env` da raiz. Não imprima esses valores em logs, pull requests ou respostas.

Imagens e volumes permanecem em disco entre execuções. O daemon não permanece: o `start` sobe o Docker de novo a cada sessão. Confira com `docker info` antes de usar o Compose.

Alteração dentro de um submódulo pede commit naquele repositório e atualização do ponteiro no repositório base. Os dois precisam de push.
