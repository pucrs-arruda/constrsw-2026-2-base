# Divergências registradas

Nenhuma linha abaixo foi apagada. A coluna Decisão é o que esta spec executa.

| Tema | Fonte A | Fonte B | Decisão |
| --- | --- | --- | --- |
| Classe secundária | JSON Schema: `Dependent` (composição 0..*) | spec-employees | `Dependent`. |
| Atributos de Employee | Schema: `registrationNumber`, `salary`, `position`, `hireDate`, `phone` opcional, `email` opcional | PRD FR-1: nome, e-mail obrigatório, `ativo`; texto diz que não é SIGRH (sem cargo nem salário) | Corpo segue o schema. Cargo e salário aqui são atributos, não módulo de folha. |
| Sinal para consumidores | Pedido: `Active` → `ativo` true, `Inactive` → `ativo` false, na leitura | Schema: sem propriedade `ativo` e `additionalProperties: false` | GET de coleção e GET por id incluem `ativo` derivado. Não é persistido e não entra em POST, PUT nem PATCH. |
| Exclusão | Pares: DELETE lógico, 204, some dos GET | PRD: desativar/reativar via `ativo`, sem delete | DELETE lógico com `enabled`. `status` cobre desativar sem esconder o registro. Sem undelete. |
| Paths e lista | OpenAPI dos outros serviços: `/api/v1` e array JSON | Spine AD-2: `/v1` e propriedade `items` | `/api/v1` e array JSON. |
| Papel de escrita | Spine: literal `funcionario` | PRD: `Administrator`. Rooms: `administrator` | `funcionario`. |
| Erro | Rooms e students: `error_code`, `error_description`, `error_source`, `error_stack` | `backend/resources/openapi.yaml` e spine: `application/problem+json` (RFC 9457) | `application/problem+json` com `type`, `title`, `status`, `detail`, `code`, `instance`. HTTP de `routes.md` permanece; 400 não vira 422. |
| Lista | Rooms: filtro, `sort`, `page`, `size`, 404 sem match | Professors: sem essa paginação, match vazio é `[]`. Spine: sem paginação na v1 | Sem filtro, `sort`, `page` nem `size`. Coleção vazia é 200 `[]`. |
| Identidade da sessão | AD-3 item 5 e AD-4: `GET /v1/identidade/me` em todo contexto | Grade pedida: só CRUD e health | Fora desta entrega. A spine registra a exceção só para o serviço `employees`. |
| Par de domínio | `domain-pairs.md` | spec-employees | Secundária `Dependent`. PRD §5.1, `domain-pairs.md` e spec-closed-cras registram Dependent. |

O diagrama `Arruda - Employees.asta` não foi lido: o arquivo é binário. O JSON Schema ao lado dele é o modelo usado.
