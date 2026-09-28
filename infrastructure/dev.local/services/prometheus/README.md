# Prometheus para ConstrSW 2025-1

Este diretório contém a configuração do Prometheus para monitoramento e observabilidade da solução ConstrSW 2025-1.

## Configuração

### Arquivos de Configuração

- `prometheus.yml`: Configuração principal do Prometheus
- `Dockerfile`: Dockerfile para construir a imagem do Prometheus

### Serviços Monitorados

O Prometheus está configurado para coletar métricas dos seguintes serviços:

#### Microserviços
1. **BFF** (`bff:3000`) - Backend for Frontend
2. **OAuth** (`oauth:3000`) - Serviço de autenticação
3. **Classes** (`classes:8080`) - Gerenciamento de classes
4. **Courses** (`courses:8080`) - Gerenciamento de cursos
5. **Lessons** (`lessons:8000`) - Gerenciamento de aulas
6. **Professors** (`professors:3000`) - Gerenciamento de professores
7. **Reservations** (`reservations:8080`) - Gerenciamento de reservas
8. **Resources** (`resources:3000`) - Gerenciamento de recursos
9. **Rooms** (`rooms:8080`) - Gerenciamento de salas
10. **Students** (`students:8080`) - Gerenciamento de estudantes

#### Infraestrutura
- **Keycloak** (`keycloak:8080`) - Servidor de autenticação
- **PostgreSQL** (`postgresql:5432`) - Banco de dados principal
- **MongoDB** (`mongodb:27017`) - Banco de dados NoSQL

## Endpoints de Métricas

Todos os microserviços expõem métricas através do endpoint `/actuator/prometheus`:

- **Spring Boot Services**: `/actuator/prometheus`
- **Node.js Services**: `/actuator/prometheus`
- **Python/FastAPI Services**: `/actuator/prometheus`

## Configuração do Docker Compose

### Variáveis de Ambiente

```env
# Prometheus
PROMETHEUS_INTERNAL_HOST=prometheus
PROMETHEUS_EXTERNAL_HOST=localhost
PROMETHEUS_INTERNAL_PORT=9090
PROMETHEUS_EXTERNAL_PORT=9090
```

### Volume de Dados

```bash
# Criar volume para persistir dados do Prometheus
docker volume create constrsw-prometheus-data
```

## Acesso ao Prometheus

- **URL**: http://localhost:9090
- **Targets**: http://localhost:9090/targets
- **Graph**: http://localhost:9090/graph

## Métricas Coletadas

### Métricas de Aplicação (Spring Boot Actuator)

- `http_server_requests_seconds_count` - Contador de requisições HTTP
- `http_server_requests_seconds_sum` - Soma do tempo de resposta
- `http_server_requests_seconds_max` - Tempo máximo de resposta
- `jvm_memory_used_bytes` - Memória JVM utilizada
- `jvm_memory_max_bytes` - Memória JVM máxima
- `jvm_gc_collection_seconds_count` - Contador de garbage collection
- `jvm_gc_collection_seconds_sum` - Tempo total de garbage collection
- `process_cpu_usage` - Uso de CPU do processo
- `process_start_time_seconds` - Tempo de início do processo

### Métricas de Banco de Dados

- `hikaricp_connections_active` - Conexões ativas do HikariCP
- `hikaricp_connections_idle` - Conexões ociosas do HikariCP
- `hikaricp_connections_max` - Máximo de conexões do HikariCP
- `hikaricp_connections_min` - Mínimo de conexões do HikariCP

### Métricas Customizadas

Cada serviço pode expor métricas customizadas específicas do domínio:

- **Classes**: Métricas de classes criadas, turnos ativos
- **Courses**: Métricas de cursos, disciplinas
- **Lessons**: Métricas de aulas, frequência
- **Professors**: Métricas de professores, disponibilidades
- **Reservations**: Métricas de reservas, salas ocupadas
- **Resources**: Métricas de recursos, categorias
- **Rooms**: Métricas de salas, eventos
- **Students**: Métricas de estudantes, matrículas

## Configuração de Alertas

Para configurar alertas, adicione regras no arquivo `prometheus.yml`:

```yaml
rule_files:
  - "alerts.yml"
```

Exemplo de regras de alerta:

```yaml
groups:
  - name: constrsw_alerts
    rules:
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "Service {{ $labels.job }} has been down for more than 1 minute"

      - alert: HighResponseTime
        expr: http_server_requests_seconds_max > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time for {{ $labels.job }}"
          description: "Response time is above 2 seconds for {{ $labels.job }}"

      - alert: HighMemoryUsage
        expr: (jvm_memory_used_bytes / jvm_memory_max_bytes) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage for {{ $labels.job }}"
          description: "Memory usage is above 80% for {{ $labels.job }}"
```

## Integração com Grafana

Para visualização avançada das métricas, recomenda-se integrar com Grafana:

1. Adicionar serviço Grafana ao docker-compose.yml
2. Configurar datasource do Prometheus
3. Criar dashboards para monitoramento

## Troubleshooting

### Verificar Status dos Targets

```bash
# Acessar interface do Prometheus
curl http://localhost:9090/api/v1/targets
```

### Verificar Configuração

```bash
# Verificar se a configuração está correta
curl http://localhost:9090/api/v1/status/config
```

### Logs do Prometheus

```bash
# Ver logs do container
docker logs prometheus
```

### Problemas Comuns

1. **Targets Down**: Verificar se os serviços estão rodando e acessíveis
2. **Métricas não aparecem**: Verificar se os endpoints `/actuator/prometheus` estão funcionando
3. **Configuração não carrega**: Verificar sintaxe do `prometheus.yml`

## Comandos Úteis

```bash
# Criar volume do Prometheus
docker volume create constrsw-prometheus-data

# Rebuild do Prometheus
docker-compose build prometheus

# Restart do Prometheus
docker-compose restart prometheus

# Ver métricas de um serviço específico
curl http://localhost:8182/actuator/prometheus  # Classes
curl http://localhost:8183/actuator/prometheus  # Courses
curl http://localhost:8184/actuator/prometheus  # Lessons
``` 