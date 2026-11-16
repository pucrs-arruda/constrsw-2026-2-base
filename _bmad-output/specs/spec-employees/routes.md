# Rotas — employees

Prefixo `/api/v1`. Coleção devolve array JSON, nunca um envelope `items`. Recurso excluído logicamente não entra em lista nem em GET por id.

Autorização: health anônimo; demais rotas exigem `Authorization: Bearer`. GET: `funcionario`, `coordenador`, `professor`, `student`. POST, PUT, PATCH e DELETE: só `funcionario`. Sem o header ou com token inválido: 401, sem dizer se a conta existe. Papel autenticado sem permissão: 403.

GET de coleção e GET por id, de Employee e de Dependent, incluem `ativo` (boolean). POST, PUT e PATCH não o incluem no pedido nem na resposta. Não há query de filtro, `sort`, `page` nem `size`. Não há `GET /api/v1/identidade/me`.

Recusas 400, 401, 403, 404 e 409 respondem `application/problem+json` com `type`, `title`, `status`, `detail`, `code` e `instance`. `status` repete o HTTP da tabela. 400 pode incluir `errors` (`field`, `message`). Health não usa esse envelope.

| Rota | Método | Sucesso | Outros |
| --- | --- | --- | --- |
| `/api/v1/health` | GET | 200 `{status: ok}` | 503 `{status: down}` se o Mongo não responde |
| `/api/v1/employees` | GET | 200 array; vazio é `[]` | 401, 403 |
| `/api/v1/employees` | POST | 201 corpo do Employee e header `Location` | 400 corpo inválido; 409 e-mail duplicado; 401, 403 |
| `/api/v1/employees/{id}` | GET | 200 Employee, com dependents visíveis | 404 id desconhecido ou logicamente excluído; 401, 403 |
| `/api/v1/employees/{id}` | PUT | 200 Employee substituído; dependents intocados | 400, 404, 409, 401, 403 |
| `/api/v1/employees/{id}` | PATCH | 200 Employee com só os campos enviados alterados; dependents intocados | 400, 404, 409, 401, 403 |
| `/api/v1/employees/{id}` | DELETE | 204 sem corpo; Employee e dependents ficam `enabled=false` | 404; 401, 403 |
| `/api/v1/employees/{id}/dependents` | GET | 200 array dos dependents visíveis; vazio é `[]` | 404 se o Employee não está endereçável; 401, 403 |
| `/api/v1/employees/{id}/dependents` | POST | 201 Dependent criado | 400, 404 Employee; 401, 403 |
| `/api/v1/employees/{id}/dependents/{dependentId}` | GET | 200 Dependent | 404 Employee ou Dependent; 401, 403 |
| `/api/v1/employees/{id}/dependents/{dependentId}` | PUT | 200 Dependent substituído | 400, 404, 401, 403 |
| `/api/v1/employees/{id}/dependents/{dependentId}` | PATCH | 200 Dependent parcial | 400, 404, 401, 403 |
| `/api/v1/employees/{id}/dependents/{dependentId}` | DELETE | 204; só esse Dependent fica `enabled=false` | 404; 401, 403 |
