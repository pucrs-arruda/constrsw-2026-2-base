# Version review — oauth Prometheus pull spine

Verdict: pass. Pins match the 2026-09-21 npm check the parent recorded. No stale unnamed library.

## Checked

- `@opentelemetry/api` 1.9.1 exists (published 2026-03-25).
- `@opentelemetry/sdk-node` 0.221.0 is a real release. 0.222.0 is newer (2026-08-31). The spine records that and pins 0.221.0 so it matches the exporter line. That is a conscious pin, not an unverified latest.
- `@opentelemetry/exporter-prometheus` 0.221.0 exists. CVE-2026-44902 is fixed at 0.217.0 and above. The pin clears that floor. Default port 9464 and path `/metrics` match the professor scrape.
- `@opentelemetry/instrumentation-http` 0.221.0 exists on the same experimental line.
- Node 22 and NestJS 11 match `backend/oauth` (Dockerfile `node:22-alpine`, package.json Nest 11).
- Prometheus pull via `PrometheusExporter` is the documented Node SDK metric reader. It fits the professor comment on job `auth`.

## Findings

1. Low. Experimental packages can break across minors. The spine already forbids drifting sdk-node to 0.222.0 without the exporter. No change required.
2. Info. The exact HTTP series name is deferred on purpose because semantic-convention names moved across 0.220 and 0.221. Leaving the family (`http_server_request_duration` or `http_server_duration`) as the test oracle is consistent with that uncertainty.
