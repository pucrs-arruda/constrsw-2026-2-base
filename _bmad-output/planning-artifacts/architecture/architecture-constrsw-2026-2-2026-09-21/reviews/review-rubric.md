# Rubric review — oauth Prometheus pull spine

Verdict: fail until AD-5 matches the naming convention.

## Checklist

- Divergence points for one oauth process are mostly fixed: pull versus push, metrics port versus API port, bootstrap order, HTTP-only instrumentation, secret attributes, T1 contracts.
- AD-1 through AD-4, AD-6, and AD-7 have enforceable rules.
- Deferred items (OTLP, Grafana, buckets, other services, exact series name) do not let two oauth implementers ship incompatible listeners.
- Stack pins are specific and dated.
- Brownfield fit: does not move the API listen off `OAUTH_INTERNAL_API_PORT`.
- CAP-1 through CAP-4 appear in the capability map.
- Deployment, the external Prometheus volume, and the existing port publish are stated. The operational envelope is not silent.

## Findings

1. High. AD-5 says change no other line in `prometheus.yml`, while Consistency Conventions require the Prometheus job name to be `oauth`. One implementer renames `job_name`; another leaves `auth`. Those scrapes are not the same contract.
2. Medium. AD-2 does not say the Prometheus exporter is the only socket on the metrics port. A Nest listener plus the exporter can both claim 9464.
3. Low. `service.name` is only in the conventions table, not in an AD rule. Two bootstraps can label the resource `auth` and `oauth`.
