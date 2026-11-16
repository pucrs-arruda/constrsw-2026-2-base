# Agregado — Employee e Dependent

A lista de propriedades e de `required` é a do companion `Arruda - Employees.json`. Este arquivo fixa o que o schema não decide sozinho. Defaults de exemplo do schema (`""`, `0`, `1970-01-01`, `user@example.com`) não são gravados no lugar de campo omitido.

## Employee

Obrigatórios no POST e no PUT: `registrationNumber`, `name`, `salary`, `hireDate`, `position`, `status`. Opcionais: `phone`, `email`. `id` não vem no corpo; o serviço emite UUID v4 e não o altera. `dependents` não entra no corpo de POST, PUT nem PATCH do Employee.

`status` é `Active` ou `Inactive`. `Inactive` continua endereçável. GET de coleção e GET por id incluem `ativo`: `Active` true, `Inactive` false. `ativo` não é persistido e não entra no pedido nem na resposta de POST, PUT e PATCH. Enviá-lo responde 400. O mesmo vale para Dependent. O schema persistido continua sem a propriedade; a exceção é só o JSON desses GET.

`email`, quando presente e não branco, é único entre todos os documentos Employee, inclusive `Inactive` e `enabled=false`. Omitido ou branco não ocupa o índice. `phone` não é único.

`registrationNumber` não é único nesta entrega.

PUT substitui os atributos de Employee e não mexe em `dependents` nem em `enabled`. PATCH altera só atributos enviados desse mesmo conjunto. `null` não é valor aceito. Campo fora do schema responde 400.

## Dependent

Composição 0..* dentro do documento do Employee. Obrigatórios no POST e no PUT: `name`, `birthDate`, `dependencyType`, `status`. `id` é UUID v4 emitido pelo serviço e imutável. Não existe Dependent sem Employee endereçável.

PUT e PATCH do Dependent não criam nem removem outros itens do array. DELETE do Dependent só marca aquele item `enabled=false`. DELETE do Employee marca o Employee e todos os dependents.

## Exclusão lógica

`enabled` começa `true`, não faz parte do JSON Schema publicado e não aparece no corpo de sucesso. `false` retira o registro de toda leitura e de PUT, PATCH e DELETE seguintes (404). O documento permanece no Mongo. Não há operação de undelete. `enabled=false` não é o mesmo que `status=Inactive`.

GET do Employee omite dependents com `enabled=false`.
