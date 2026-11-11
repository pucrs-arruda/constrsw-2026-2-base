// Script para popular a collection de funcionários no MongoDB
// Este script deve ser executado após a inicialização do MongoDB

// Conectar ao banco de dados
db = db.getSiblingDB('employees');

// Limpar collections existentes
db.employees.drop();
db.Tasks.drop();

print('Iniciando população da collection de funcionários...');

// Criar índices para otimizar consultas
db.employees.createIndex({ "contractNumber": 1 }, { unique: true });
db.employees.createIndex({ "name": "text", "organizationalUnit": "text" });
db.employees.createIndex({ "organizationalUnit": 1 });
db.employees.createIndex({ "role": 1 });

db.Tasks.createIndex({ "employeeId": 1 });
db.Tasks.createIndex({ "description": "text" });
db.Tasks.createIndex({ "startDate": 1 });
db.Tasks.createIndex({ "expectedEndDate": 1 });

print('Índices criados com sucesso!');

// Dados de funcionários para inserir
const employees = [
  {
    _id: UUID(),
    contractNumber: 10001,
    name: "João Silva Santos",
    role: "Desenvolvedor Senior",
    salary: NumberDecimal("8500.50"),
    organizationalUnit: "TI",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440001"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10002,
    name: "Maria Oliveira Costa",
    role: "Analista de Sistemas",
    salary: NumberDecimal("7200.00"),
    organizationalUnit: "TI",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440002"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10003,
    name: "Carlos Eduardo Pereira",
    role: "Gerente de Projetos",
    salary: NumberDecimal("12000.00"),
    organizationalUnit: "Gestão",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440003"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10004,
    name: "Ana Paula Rodrigues",
    role: "Designer UX/UI",
    salary: NumberDecimal("6800.00"),
    organizationalUnit: "Design",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440004"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10005,
    name: "Roberto Almeida",
    role: "Arquiteto de Software",
    salary: NumberDecimal("15000.00"),
    organizationalUnit: "TI",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440005"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10006,
    name: "Fernanda Lima",
    role: "Analista de Qualidade",
    salary: NumberDecimal("6500.00"),
    organizationalUnit: "Qualidade",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440006"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10007,
    name: "Pedro Henrique Souza",
    role: "Desenvolvedor Pleno",
    salary: NumberDecimal("6000.00"),
    organizationalUnit: "TI",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440007"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10008,
    name: "Juliana Martins",
    role: "Product Owner",
    salary: NumberDecimal("11000.00"),
    organizationalUnit: "Produto",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440008"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10009,
    name: "Lucas Ferreira",
    role: "DevOps Engineer",
    salary: NumberDecimal("9000.00"),
    organizationalUnit: "Infraestrutura",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440009"
    }
  },
  {
    _id: UUID(),
    contractNumber: 10010,
    name: "Camila Santos",
    role: "Scrum Master",
    salary: NumberDecimal("8000.00"),
    organizationalUnit: "Gestão",
    tasks: [],
    room: {
      idRoom: "550e8400-e29b-41d4-a716-446655440010"
    }
  }
];

// Inserir funcionários
print('Inserindo funcionários...');
const employeeResult = db.employees.insertMany(employees);
print(`Inseridos ${employeeResult.insertedIds.length} funcionários com sucesso!`);

// Obter IDs dos funcionários inseridos para criar tarefas
const insertedEmployeeIds = employeeResult.insertedIds;

// Dados de tarefas para inserir
const tasks = [
  // Tarefas para João Silva Santos (índice 0)
  {
    _id: UUID(),
    description: "Implementar sistema completo de autenticação OAuth2 com integração ao Keycloak, incluindo fluxos de autorização, refresh tokens, logout e validação de permissões. Deve suportar múltiplos provedores de identidade e incluir logs de auditoria para todas as operações de autenticação.",
    startDate: ISODate("2024-01-15"),
    expectedEndDate: ISODate("2024-02-15"),
    actualEndDate: ISODate("2024-02-10"),
    employeeId: insertedEmployeeIds[0].toString()
  },
  {
    _id: UUID(),
    description: "Criar API REST para gerenciamento de funcionários com operações CRUD completas, validação de dados, paginação e filtros de busca. Implementar documentação automática com OpenAPI/Swagger e testes unitários com cobertura mínima de 80%.",
    startDate: ISODate("2024-02-16"),
    expectedEndDate: ISODate("2024-03-16"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[0].toString()
  },
  {
    _id: UUID(),
    description: "Implementar sistema de notificações em tempo real usando WebSockets para alertas de tarefas, prazos e atualizações do sistema. Incluir configurações de preferências de notificação por usuário.",
    startDate: ISODate("2024-03-01"),
    expectedEndDate: ISODate("2024-04-01"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[0].toString()
  },

  // Tarefas para Maria Oliveira Costa (índice 1)
  {
    _id: UUID(),
    description: "Analisar e documentar requisitos funcionais e não funcionais do sistema de gestão de funcionários. Criar especificações técnicas detalhadas e diagramas de arquitetura.",
    startDate: ISODate("2024-01-01"),
    expectedEndDate: ISODate("2024-01-31"),
    actualEndDate: ISODate("2024-01-28"),
    employeeId: insertedEmployeeIds[1].toString()
  },
  {
    _id: UUID(),
    description: "Realizar testes de integração e validação de performance do sistema. Identificar gargalos e otimizar consultas ao banco de dados para melhorar tempo de resposta.",
    startDate: ISODate("2024-02-01"),
    expectedEndDate: ISODate("2024-02-28"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[1].toString()
  },

  // Tarefas para Carlos Eduardo Pereira (índice 2)
  {
    _id: UUID(),
    description: "Gerenciar cronograma do projeto de desenvolvimento do sistema de gestão. Coordenar equipe de 8 desenvolvedores e acompanhar marcos de entrega.",
    startDate: ISODate("2024-01-01"),
    expectedEndDate: ISODate("2024-06-30"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[2].toString()
  },
  {
    _id: UUID(),
    description: "Implementar metodologia ágil com sprints de 2 semanas. Configurar ferramentas de gestão de projeto e treinar equipe nos processos estabelecidos.",
    startDate: ISODate("2024-01-15"),
    expectedEndDate: ISODate("2024-02-15"),
    actualEndDate: ISODate("2024-02-12"),
    employeeId: insertedEmployeeIds[2].toString()
  },

  // Tarefas para Ana Paula Rodrigues (índice 3)
  {
    _id: UUID(),
    description: "Criar protótipos de alta fidelidade para interface do sistema de gestão de funcionários. Desenvolver design system consistente com identidade visual da empresa.",
    startDate: ISODate("2024-01-01"),
    expectedEndDate: ISODate("2024-02-15"),
    actualEndDate: ISODate("2024-02-10"),
    employeeId: insertedEmployeeIds[3].toString()
  },
  {
    _id: UUID(),
    description: "Implementar interface responsiva para dispositivos móveis. Garantir acessibilidade seguindo diretrizes WCAG 2.1 e testar usabilidade com usuários finais.",
    startDate: ISODate("2024-02-16"),
    expectedEndDate: ISODate("2024-03-31"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[3].toString()
  },

  // Tarefas para Roberto Almeida (índice 4)
  {
    _id: UUID(),
    description: "Definir arquitetura de microserviços para o sistema de gestão. Criar diagramas de componentes, fluxos de dados e especificações de APIs entre serviços.",
    startDate: ISODate("2024-01-01"),
    expectedEndDate: ISODate("2024-01-31"),
    actualEndDate: ISODate("2024-01-25"),
    employeeId: insertedEmployeeIds[4].toString()
  },
  {
    _id: UUID(),
    description: "Implementar padrões de segurança e monitoramento distribuído. Configurar logging centralizado, métricas de performance e alertas automáticos.",
    startDate: ISODate("2024-02-01"),
    expectedEndDate: ISODate("2024-03-15"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[4].toString()
  },

  // Tarefas para Fernanda Lima (índice 5)
  {
    _id: UUID(),
    description: "Criar estratégia de testes automatizados para todas as funcionalidades do sistema. Implementar testes unitários, de integração e end-to-end.",
    startDate: ISODate("2024-01-15"),
    expectedEndDate: ISODate("2024-03-15"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[5].toString()
  },
  {
    _id: UUID(),
    description: "Executar testes de carga e stress para validar performance do sistema sob diferentes cenários de uso. Documentar resultados e recomendações de otimização.",
    startDate: ISODate("2024-03-01"),
    expectedEndDate: ISODate("2024-04-15"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[5].toString()
  },

  // Tarefas para Pedro Henrique Souza (índice 6)
  {
    _id: UUID(),
    description: "Desenvolver módulo de relatórios com gráficos interativos e exportação em múltiplos formatos (PDF, Excel, CSV). Implementar filtros avançados e agendamento de relatórios.",
    startDate: ISODate("2024-02-01"),
    expectedEndDate: ISODate("2024-04-01"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[6].toString()
  },
  {
    _id: UUID(),
    description: "Integrar sistema com APIs externas para validação de CPF, consulta de CEP e envio de notificações por email e SMS. Implementar cache para otimizar performance.",
    startDate: ISODate("2024-03-01"),
    expectedEndDate: ISODate("2024-04-30"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[6].toString()
  },

  // Tarefas para Juliana Martins (índice 7)
  {
    _id: UUID(),
    description: "Definir backlog de produto e priorizar funcionalidades baseado em feedback de usuários e métricas de negócio. Criar roadmap de desenvolvimento para próximos 6 meses.",
    startDate: ISODate("2024-01-01"),
    expectedEndDate: ISODate("2024-01-31"),
    actualEndDate: ISODate("2024-01-28"),
    employeeId: insertedEmployeeIds[7].toString()
  },
  {
    _id: UUID(),
    description: "Conduzir sessões de descoberta com stakeholders para mapear jornada do usuário e identificar oportunidades de melhoria na experiência do produto.",
    startDate: ISODate("2024-02-01"),
    expectedEndDate: ISODate("2024-03-15"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[7].toString()
  },

  // Tarefas para Lucas Ferreira (índice 8)
  {
    _id: UUID(),
    description: "Configurar pipeline de CI/CD com GitHub Actions, incluindo testes automatizados, análise de código com SonarQube e deploy automático em ambientes de desenvolvimento e produção.",
    startDate: ISODate("2024-01-01"),
    expectedEndDate: ISODate("2024-02-15"),
    actualEndDate: ISODate("2024-02-10"),
    employeeId: insertedEmployeeIds[8].toString()
  },
  {
    _id: UUID(),
    description: "Implementar infraestrutura como código usando Terraform para provisionamento automático de recursos na AWS. Configurar monitoramento com CloudWatch e alertas.",
    startDate: ISODate("2024-02-16"),
    expectedEndDate: ISODate("2024-04-15"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[8].toString()
  },

  // Tarefas para Camila Santos (índice 9)
  {
    _id: UUID(),
    description: "Facilitar cerimônias ágeis (Daily, Sprint Planning, Review, Retrospective) para equipe de desenvolvimento. Acompanhar métricas de velocidade e qualidade do time.",
    startDate: ISODate("2024-01-01"),
    expectedEndDate: ISODate("2024-06-30"),
    actualEndDate: null,
    employeeId: insertedEmployeeIds[9].toString()
  },
  {
    _id: UUID(),
    description: "Identificar e remover impedimentos que afetam a produtividade da equipe. Implementar melhorias nos processos de desenvolvimento e comunicação.",
    startDate: ISODate("2024-01-15"),
    expectedEndDate: ISODate("2024-02-15"),
    actualEndDate: ISODate("2024-02-12"),
    employeeId: insertedEmployeeIds[9].toString()
  }
];

// Inserir tarefas
print('Inserindo tarefas...');
const taskResult = db.Tasks.insertMany(tasks);
print(`Inseridas ${taskResult.insertedIds.length} tarefas com sucesso!`);

// Atualizar funcionários com suas tarefas
print('Atualizando funcionários com suas tarefas...');
for (let i = 0; i < insertedEmployeeIds.length; i++) {
  const employeeId = insertedEmployeeIds[i].toString();
  const employeeTasks = tasks.filter(task => task.employeeId === employeeId);
  
  if (employeeTasks.length > 0) {
    db.employees.updateOne(
      { _id: insertedEmployeeIds[i] },
      { $set: { tasks: employeeTasks } }
    );
    print(`Atualizado funcionário ${i + 1} com ${employeeTasks.length} tarefas`);
  }
}

// Estatísticas finais
print('\n=== ESTATÍSTICAS FINAIS ===');
print(`Total de funcionários: ${db.employees.countDocuments()}`);
print(`Total de tarefas: ${db.Tasks.countDocuments()}`);
print(`Funcionários com tarefas: ${db.employees.countDocuments({ tasks: { $exists: true, $ne: [] } })}`);

// Mostrar alguns exemplos
print('\n=== EXEMPLOS DE DADOS INSERIDOS ===');
print('Funcionários:');
db.employees.find({}, { name: 1, role: 1, organizationalUnit: 1, salary: 1 }).limit(5).forEach(printjson);

print('\nTarefas:');
db.Tasks.find({}, { description: 1, startDate: 1, expectedEndDate: 1, actualEndDate: 1, employeeId: 1 }).limit(5).forEach(printjson);

print('\n=== POPULAÇÃO CONCLUÍDA COM SUCESSO! ===');
print('O banco de dados está pronto para uso com dados de exemplo.');
print('Você pode agora testar a API usando as collections do Postman.');

