# ConstrSW 2026/2 — base · Grupo 04

Ambiente local do ConstrSW. Esta branch (`grupo04`) sobe, com um único comando, a **API
`oauth`** do grupo (autenticação, usuários e roles sobre o Keycloak), o **Keycloak**, e o
monitoramento com **Prometheus** e **Grafana**.

> **Documentação completa da API** (rotas, exemplos, arquitetura, erros, observabilidade e
> testes): [`backend/oauth/README.md`](backend/oauth/README.md)

## Como executar

Pré-requisito: Docker Desktop em execução.

```bash
git clone --recurse-submodules -b grupo04 <url-do-repo-base>
cd <repo-base>
git submodule update --init backend/oauth      # se clonou sem --recurse-submodules

docker volume create constrsw-keycloak-data    # apenas na primeira vez
docker compose up -d --build
docker compose ps                               # aguarde tudo "healthy" (~1 min)
```

## O que sobe

| Serviço      | URL                                          | Acesso                         |
| ------------ | -------------------------------------------- | ------------------------------ |
| **Swagger**  | http://localhost:8181/swagger-ui/index.html  | login: `admin@pucrs.br` / `a12345678` |
| API oauth    | http://localhost:8181                        | Bearer token via `POST /login` |
| Grafana      | http://localhost:3000                        | leitura anônima; `admin` / `a12345678` |
| Prometheus   | http://localhost:9090                        | —                              |
| Keycloak     | http://localhost:8180                        | `admin` / `a12345678`          |

## Testes

Roda todos os testes (unitários, integração, contrato e fim a fim contra a stack real) e
limpa tudo no final. Não precisa de Java nem de Maven na máquina:

```powershell
.\scripts\run-all-tests.ps1        # Windows
```

```bash
./scripts/run-all-tests.sh         # Linux / macOS / Git Bash
```

Detalhes na [seção de testes do README da API](backend/oauth/README.md#12-testes).

## Estrutura

```
.
├── docker-compose.yml             # keycloak, oauth, prometheus, grafana
├── .env                           # portas e credenciais do ambiente local
├── backend/oauth/                 # submódulo: API do grupo 04 (Spring Boot, Clean Architecture)
├── infrastructure/dev.local/services/
│   ├── keycloak/                  # imagem + export do realm constrsw
│   ├── prometheus/                # prometheus.yml + regras de alerta
│   └── grafana/                   # datasource, provisionamento e dashboard
└── scripts/
    ├── run-all-tests.ps1          # roda todos os testes e limpa (Windows)
    └── run-all-tests.sh           # idem (Linux/macOS/Git Bash)
```

Os demais serviços em `backend/` são submódulos de outros grupos e não fazem parte do compose
desta branch.
