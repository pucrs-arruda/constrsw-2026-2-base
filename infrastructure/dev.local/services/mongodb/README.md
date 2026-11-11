# Scripts de Inicialização do MongoDB

Este diretório contém scripts para configurar e popular o banco de dados MongoDB com dados de exemplo.

## Arquivos

### Scripts de Inicialização
- **`init-mongo.js`** - Script principal que cria databases e usuários para todos os serviços
- **`init-employees.js`** - Script específico para popular a collection de funcionários com dados de exemplo
- **`run-init-employees.sh`** - Script bash para executar a população de funcionários
- **`run-init-employees.ps1`** - Script PowerShell para executar a população de funcionários

### Docker
- **`Dockerfile`** - Configuração do container MongoDB com todos os scripts

## Como Usar

### 1. Execução Automática (Docker)

Os scripts são executados automaticamente quando o container MongoDB é iniciado:

```bash
docker-compose up mongodb
```

### 2. Execução Manual

#### Linux/macOS
```bash
# Executar script de funcionários
./run-init-employees.sh
```

#### Windows (PowerShell)
```powershell
# Executar script de funcionários
.\run-init-employees.ps1
```

#### Execução Direta com mongosh
```bash
# Executar script de funcionários diretamente
mongosh --host localhost --port 27017 \
        --username admin \
        --password a12345678 \
        --authenticationDatabase admin \
        --file init-employees.js
```

## Dados Inseridos

### Funcionários (10 registros)
- **João Silva Santos** - Desenvolvedor Senior (TI)
- **Maria Oliveira Costa** - Analista de Sistemas (TI)
- **Carlos Eduardo Pereira** - Gerente de Projetos (Gestão)
- **Ana Paula Rodrigues** - Designer UX/UI (Design)
- **Roberto Almeida** - Arquiteto de Software (TI)
- **Fernanda Lima** - Analista de Qualidade (Qualidade)
- **Pedro Henrique Souza** - Desenvolvedor Pleno (TI)
- **Juliana Martins** - Product Owner (Produto)
- **Lucas Ferreira** - DevOps Engineer (Infraestrutura)
- **Camila Santos** - Scrum Master (Gestão)

### Tarefas (20 registros)
Cada funcionário possui 2 tarefas com descrições detalhadas, incluindo:
- Tarefas concluídas e em andamento
- Datas de início, fim esperado e fim real
- Descrições detalhadas (até 1000 caracteres)
- Relacionamento com funcionários

### Estrutura dos Dados

#### Funcionário
```javascript
{
  _id: ObjectId(),
  contractNumber: Number, // Único
  name: String,
  role: String,
  salary: NumberDecimal, // Opcional
  organizationalUnit: String, // Opcional
  tasks: [Task], // Array de tarefas
  room: {
    idRoom: String // UUID da sala
  }
}
```

#### Tarefa
```javascript
{
  _id: ObjectId(),
  description: String, // 1-1000 caracteres
  startDate: Date,
  expectedEndDate: Date,
  actualEndDate: Date, // Opcional
  employeeId: String // Referência ao funcionário
}
```

## Índices Criados

### Collection Employees
- `contractNumber` (único)
- `name` e `organizationalUnit` (texto)
- `organizationalUnit` (simples)
- `role` (simples)

### Collection Tasks
- `employeeId` (referência)
- `description` (texto)
- `startDate` (data)
- `expectedEndDate` (data)

## Verificação

Após executar os scripts, você pode verificar os dados:

```javascript
// Conectar ao MongoDB
mongosh --host localhost --port 27017 --username admin --password a12345678 --authenticationDatabase admin

// Selecionar database
use Employees

// Verificar funcionários
db.Employees.find().count()
db.Employees.find({}, {name: 1, role: 1, organizationalUnit: 1}).limit(5)

// Verificar tarefas
db.Tasks.find().count()
db.Tasks.find({}, {description: 1, startDate: 1, expectedEndDate: 1}).limit(5)

// Verificar funcionários com tarefas
db.Employees.find({tasks: {$exists: true, $ne: []}}).count()
```

## Troubleshooting

### Erro de Conexão
- Verifique se o MongoDB está rodando
- Confirme as credenciais de acesso
- Verifique se a porta 27017 está disponível

### Erro de Permissão
- Execute com usuário admin
- Verifique se o usuário tem permissões de escrita no database

### Dados Duplicados
- O script verifica se já existem dados antes de inserir
- Para limpar dados existentes, descomente as linhas de `drop()` no script

### Script Não Executa
- Verifique se o mongosh está instalado
- Confirme se o arquivo está no local correto
- Verifique as permissões de execução (Linux/macOS)

## Personalização

Para adicionar mais dados ou modificar os existentes:

1. Edite o arquivo `init-employees.js`
2. Modifique os arrays `employees` e `tasks`
3. Execute o script novamente

Para limpar dados existentes antes de inserir novos:

1. Descomente as linhas:
   ```javascript
   db.Employees.drop();
   db.Tasks.drop();
   ```
2. Execute o script

## Integração com API

Os dados inseridos são compatíveis com a API REST de funcionários:

- **Base URL**: `http://localhost:8080/api/v1`
- **Endpoints**: Conforme documentação da API
- **Formato**: JSON compatível com os schemas definidos

## Monitoramento

O script exibe estatísticas durante a execução:

- Número de funcionários inseridos
- Número de tarefas inseridas
- Funcionários atualizados com tarefas
- Exemplos de dados inseridos
- Confirmação de conclusão

