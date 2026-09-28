# Scrape contract

Professor file: `infrastructure/dev.local/services/prometheus/prometheus.yml`. Edit only the two spots below. Leave every other job, `docker-compose.yml`, and `.env` unchanged.

## NestJS scrape job

Replace the job that targets `auth:9464`:

```yaml
  # oauth (NestJS — OpenTelemetry Prometheus exporter)
  - job_name: 'oauth'
    static_configs:
      - targets: ['oauth:9464']
    metrics_path: '/metrics'
    scrape_interval: 10s
```

Keep `metrics_path: '/metrics'` and `scrape_interval: 10s`. The job name and the target host both become `oauth`.

## Blackbox health URL

In job `health-checks`, replace `http://auth:3001/health` with `http://oauth:3001/health`. Do not change the other URLs in that list.

## What up means

Prometheus can scrape `oauth:9464` only after the oauth container is on network `constrsw` and the metrics port is listening. From the host, the same text is on `OAUTH_EXTERNAL_METRICS_PORT` (8381 in the professor `.env`). The in-network target stays port 9464.

Create the external volume before compose up: `docker volume create constrsw-prometheus-data`.
