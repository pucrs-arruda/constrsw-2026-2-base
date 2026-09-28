# Análise das Configurações do Prometheus

## Resumo Executivo

Este documento analisa as configurações do Prometheus para consumo de informações de health checking e coleta de métricas dos serviços da aplicação ConstrSW.

## Configuração Atual

### Arquivo: `prometheus.yml`

**Configurações Globais:**
- `scrape_interval`: 15s (intervalo padrão de coleta)
- `evaluation_interval`: 15s (intervalo de avaliação de regras)

**Arquivos de Regras:**
- `alerts.yml`: Alertas configurados
- `recording_rules.yml`: Regras de gravação (vazio)

### Jobs Configurados

#### 1. Prometheus Próprio
- **Target**: `localhost:9090`
- **Status**: ✅ Configurado corretamente

#### 2. OpenTelemetry Collector
- **Target**: `otel-collector:8889`
- **Path**: `/metrics`
- **Interval**: 10s
- **Status**: ✅ Configurado corretamente

#### 3. Serviços de Aplicação

**Problema Identificado**: Todos os serviços estão configurados para coletar métricas na porta **9091**, mas a implementação real varia:

| Serviço | Framework | Porta Configurada | Porta Real | Endpoint | Status |
|---------|-----------|-------------------|------------|----------|--------|
| oauth | FastAPI | 9091 | 8000 | `/metrics` | ❌ **INCORRETO** |
| courses | FastAPI | 9091 | 8080 | `/metrics` | ❌ **INCORRETO** |
| professors | FastAPI | 9091 | 8082 | `/metrics` | ❌ **INCORRETO** |
| lessons | NestJS | 9091 | 9091 | `/metrics` | ✅ **CORRETO** |
| reservations | NestJS | 9091 | 9091 | `/metrics` | ✅ **CORRETO** |
| resources | NestJS | 9091 | 9091 | `/metrics` | ✅ **CORRETO** |
| rooms | NestJS | 9091 | 9091 | `/metrics` | ✅ **CORRETO** |
| students | .NET | 9091 | 8080 | `/metrics` | ❌ **INCORRETO** |
| employees | Spring Boot | 9091 | 9091? | `/metrics` | ⚠️ **VERIFICAR** |
| classes | .NET | 9091 | 8080 | `/metrics` | ❌ **INCORRETO** |

#### 4. Infraestrutura

- **Keycloak**: `keycloak:8080/metrics` (30s)
- **PostgreSQL**: `postgresql-exporter:9187/metrics` (30s)
- **MongoDB**: `mongodb-exporter:9216/metrics` (30s)

## Problemas Identificados

### 1. Inconsistência nas Portas de Métricas

**Serviços FastAPI (oauth, courses, professors):**
- **Configuração Prometheus**: Espera métricas na porta `9091`
- **Realidade**: Métricas expostas na porta principal via endpoint `/metrics`
  - `oauth`: Porta `8000`
  - `courses`: Porta `8080`
  - `professors`: Porta `8082`

**Serviços .NET (classes, students):**
- **Configuração Prometheus**: Espera métricas na porta `9091`
- **Realidade**: Métricas expostas na porta principal via `UseOpenTelemetryPrometheusScrapingEndpoint()`
  - `classes`: Porta `8080`
  - `students`: Porta `8080`

**Serviço Spring Boot (employees):**
- **Configuração Prometheus**: Espera métricas na porta `9091`
- **Realidade**: Precisa verificar se o OpenTelemetry está expondo na porta 9091 ou se está usando Actuator na porta principal

### 2. Health Check Monitoring

**Problema**: O Prometheus **não está configurado** para monitorar endpoints de health check diretamente.

**Solução Recomendada**: 
- Usar **Blackbox Exporter** para monitorar endpoints de health check
- Ou criar métricas customizadas baseadas nos endpoints `/health`

### 3. Alertas de Health Check

**Status**: Os alertas em `alerts.yml` monitoram apenas a métrica `up`, que indica se o Prometheus consegue coletar métricas do serviço, mas não monitora especificamente o status de health check.

## Recomendações

### 1. Corrigir Configurações de Scraping

**Opção A: Padronizar para porta principal (Recomendado)**
- Atualizar `prometheus.yml` para coletar métricas dos serviços FastAPI e .NET na porta principal
- Manter serviços NestJS na porta 9091 (já está correto)

**Opção B: Padronizar para porta 9091**
- Modificar serviços FastAPI e .NET para expor métricas na porta 9091
- Mais complexo, requer mudanças em múltiplos serviços

### 2. Adicionar Blackbox Exporter para Health Checks

```yaml
# Adicionar ao docker-compose.yml
blackbox-exporter:
  image: prom/blackbox-exporter:latest
  ports:
    - "9115:9115"
  volumes:
    - ./blackbox.yml:/etc/blackbox_exporter/config.yml

# Adicionar ao prometheus.yml
scrape_configs:
  - job_name: 'health-checks'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://oauth:8000/health
        - http://courses:8080/health
        - http://professors:8082/health
        - http://lessons:9091/health
        - http://reservations:9091/health
        - http://resources:9091/health
        - http://rooms:9091/health
        - http://students:8080/health
        - http://employees:8080/api/v1/health
        - http://classes:8080/health
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115
```

### 3. Criar Métricas Customizadas de Health Check

Adicionar métricas customizadas que exponham o status de health check de cada serviço, permitindo alertas baseados no status real do serviço.

## Próximos Passos

1. ✅ Verificar se o serviço `employees` está expondo métricas na porta 9091
2. ⚠️ Corrigir configurações de scraping para serviços FastAPI e .NET
3. ⚠️ Adicionar monitoramento de health checks via Blackbox Exporter
4. ⚠️ Atualizar alertas para incluir monitoramento de health checks
5. ⚠️ Testar todas as configurações após correções

## Referências

- [Prometheus Configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter)
- [OpenTelemetry Prometheus Exporter](https://opentelemetry.io/docs/instrumentation/js/exporters/prometheus/)


