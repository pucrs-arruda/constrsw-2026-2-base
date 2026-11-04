# Grafana local

O Grafana usado no laboratório está em **http://localhost:3030** (container
existente fora do `docker-compose.yml` deste repositório).

- Usuário admin: `admin` / `a12345678`
- Acesso anônimo: habilitado como Viewer
- Datasource provisionado no container: `Prometheus` → `http://prometheus:9090`

## Dashboards de Resources

### Técnico — `ConstrSW Resources`

- URL: http://localhost:3030/d/resources-overview/constrsw-resources
- UID: `resources-overview`
- JSON: [`dashboards/resources-overview.json`](dashboards/resources-overview.json)

Painéis:

1. `up{job="resources"}` — target do Prometheus.
2. `probe_success{job="health-checks", instance=~".*resources.*"}` — readiness.
3. Requests/s total.
4. Requests/s por rota (`uri`) e status.
5. Latência p95 por rota.
6. Respostas por status.
7. Requests/s por método.
8. Taxa de erros 4xx/5xx por status.

### Negócio — `ConstrSW Resources — Negócio`

- URL: http://localhost:3030/d/resources-business/constrsw-resources-e28094-negocio
- UID: `resources-business`
- JSON: [`dashboards/resources-business.json`](dashboards/resources-business.json)

Painéis:

1. Resources ativos (`active=true` e `enabled=true`).
2. Resources inativos (`active=false` e `enabled=true`).
3. Resources excluídos logicamente (`enabled=false`).
4. Resources habilitados no total.
5. Occurrences abertas, resolvidas e excluídas.
6. Resources com pelo menos uma ocorrência aberta.
7. Pizza de resources e occurrences por estado.
8. Barras de resources e occurrences por tipo e estado.
9. Histórico dos contadores por estado.

As métricas vêm do próprio `/metrics` do serviço
(`resources_current`, `resources_by_type_current`, `occurrences_current`,
`occurrences_by_type_current`, `resources_with_open_occurrences_current`), que
consulta o PostgreSQL a cada scrape. O dashboard usa o datasource `prometheus`
e o job `resources`.

Para movimentar os painéis, rode o script de carga do módulo:

```bash
cd backend/resources
python3 scripts/metrics-load-test.py --iterations 40 --concurrency 8
# pico mais longo:
python3 scripts/metrics-load-test.py --iterations 200 --concurrency 20 --delay 0.1
```

## Reimportar

Se o container for recriado e o dashboard sumir:

1. Abra http://localhost:3030.
2. **Dashboards → New → Import**.
3. Envie `dashboards/resources-overview.json` e `dashboards/resources-business.json`.
4. Selecione o datasource `Prometheus` e confirme.

Via API:

```bash
for file in dashboards/resources-overview.json dashboards/resources-business.json; do
  curl -u admin:a12345678 -X POST http://localhost:3030/api/dashboards/db \
    -H 'Content-Type: application/json' \
    -d "{\"dashboard\": $(cat "$file"), \"overwrite\": true}"
done
```

O datasource precisa existir com UID `prometheus`. Se for recriado, cadastre em
**Connections → Data sources → Prometheus** com a URL `http://prometheus:9090`.
