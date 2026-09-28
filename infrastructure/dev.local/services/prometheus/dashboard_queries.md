# Queries para Gráficos de Tempo de Resposta - Prometheus

## 1. Tempo de Resposta Médio por Serviço
```
rate(http_server_requests_seconds_sum[5m]) / rate(http_server_requests_seconds_count[5m])
```

## 2. Tempo de Resposta Máximo por Serviço
```
max_over_time(http_server_requests_seconds_max[5m])
```

## 3. Tempo de Resposta Percentil 95 por Serviço
```
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))
```

## 4. Tempo de Resposta Percentil 99 por Serviço
```
histogram_quantile(0.99, rate(http_server_requests_seconds_bucket[5m]))
```

## 5. Taxa de Requisições por Segundo
```
rate(http_server_requests_seconds_count[5m])
```

## 6. Taxa de Erros por Segundo (4xx e 5xx)
```
rate(http_server_requests_seconds_count{status=~"4..|5.."}[5m])
```

## 7. Taxa de Sucesso por Segundo (2xx e 3xx)
```
rate(http_server_requests_seconds_count{status=~"2..|3.."}[5m])
```

## 8. Percentual de Erros
```
(rate(http_server_requests_seconds_count{status=~"4..|5.."}[5m]) / rate(http_server_requests_seconds_count[5m])) * 100
```

## 9. Tempo de Resposta por Endpoint Específico
```
rate(http_server_requests_seconds_sum[5m]) by (job, uri) / rate(http_server_requests_seconds_count[5m]) by (job, uri)
```

## 10. Tempo de Resposta para Health Checks
```
rate(http_server_requests_seconds_sum{uri="/actuator/health"}[5m]) / rate(http_server_requests_seconds_count{uri="/actuator/health"}[5m])
```

## 11. Tempo de Resposta para Endpoints de Métricas
```
rate(http_server_requests_seconds_sum{uri="/actuator/prometheus"}[5m]) / rate(http_server_requests_seconds_count{uri="/actuator/prometheus"}[5m])
```

## 12. Tempo de Resposta para APIs (excluindo health e metrics)
```
rate(http_server_requests_seconds_sum{uri!="/actuator/health",uri!="/actuator/prometheus",uri!="/api-docs",uri!="/swagger-ui"}[5m]) / rate(http_server_requests_seconds_count{uri!="/actuator/health",uri!="/actuator/prometheus",uri!="/api-docs",uri!="/swagger-ui"}[5m])
```

## 13. Throughput (Requisições por Minuto)
```
rate(http_server_requests_seconds_count[1m]) * 60
```

## 14. Tempo de Resposta por Método HTTP
```
rate(http_server_requests_seconds_sum[5m]) by (job, method) / rate(http_server_requests_seconds_count[5m]) by (job, method)
```

## 15. Tempo de Resposta por Status HTTP
```
rate(http_server_requests_seconds_sum[5m]) by (job, status) / rate(http_server_requests_seconds_count[5m]) by (job, status)
```

## 16. Tempo de Resposta Médio Geral (todos os serviços)
```
avg(rate(http_server_requests_seconds_sum[5m])) by (job) / avg(rate(http_server_requests_seconds_count[5m])) by (job)
```

## 17. Comparação de Tempo de Resposta entre Serviços
```
rate(http_server_requests_seconds_sum[5m]) by (job) / rate(http_server_requests_seconds_count[5m]) by (job)
```

## 18. Tempo de Resposta por Período (última hora)
```
rate(http_server_requests_seconds_sum[1h]) / rate(http_server_requests_seconds_count[1h])
```

## 19. Tempo de Resposta por Período (último dia)
```
rate(http_server_requests_seconds_sum[1d]) / rate(http_server_requests_seconds_count[1d])
```

## 20. Anomalias de Tempo de Resposta (desvio padrão)
```
stddev(rate(http_server_requests_seconds_sum[5m]) / rate(http_server_requests_seconds_count[5m])) by (job)
```

---

## Como usar no Prometheus:

1. Acesse o Prometheus (http://localhost:9090)
2. Vá em "Graph"
3. Cole uma das queries acima
4. Clique em "Execute"
5. Para gráficos de linha, clique em "Graph"
6. Para tabelas, clique em "Table"

## Dicas para Dashboards:

- Use queries 1-4 para gráficos de linha mostrando evolução temporal
- Use queries 5-8 para métricas de throughput e erros
- Use queries 9-12 para análise específica de endpoints
- Use queries 13-15 para análise por método/status HTTP
- Use queries 16-20 para análises comparativas e de tendências 