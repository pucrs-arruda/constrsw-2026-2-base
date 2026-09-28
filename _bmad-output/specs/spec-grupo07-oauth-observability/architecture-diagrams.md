# Telemetry map

Prometheus scrapes the oauth metrics port. The API port stays the T1 HTTP server. The collector is not on the success path.

```mermaid
flowchart LR
  prometheus[Prometheus] -->|GET /metrics| metricsServer[OauthMetrics_9464]
  client[Caller] -->|T1 HTTP| apiServer[OauthApi_3001]
  apiServer --> httpInstrumentation[HttpInstrumentation]
  httpInstrumentation --> meterProvider[MeterProvider]
  meterProvider --> metricsServer
  otelCollector[OtelCollector] -.->|not the success path| apiServer
```

```mermaid
flowchart LR
  hostMetrics["Host port 8381"] --> metricsServer[Container_9464]
  hostApi["Host port 8181"] --> apiServer[Container_3001]
  prometheus[Prometheus] --> metricsServer
  blackbox[Blackbox] -->|GET /health| apiServer
```

Invariants AD-1 through AD-7 live in the adopted spine `ARCHITECTURE-SPINE.md`.
