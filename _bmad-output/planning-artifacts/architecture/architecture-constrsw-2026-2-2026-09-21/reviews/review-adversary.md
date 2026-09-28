# Adversary review — oauth Prometheus pull spine

Verdict: fail. Two implementers can obey the current rules and still disagree on the scrape job name and on who owns port 9464.

## Pairs

1. High. Implementer A follows AD-5 literally and only replaces `auth:9464` and the blackbox URL. Implementer B follows the conventions table and also renames `job_name` from `auth` to `oauth`. Both obey a written rule. Prometheus then either keeps a job called `auth` that targets `oauth`, or a job called `oauth`. Dashboards and the success signal "oauth target" diverge.
2. Medium. Implementer A lets `PrometheusExporter` bind 9464. Implementer B adds a Nest controller on `OAUTH_INTERNAL_METRICS_PORT` that also writes Prometheus text. AD-2 requires that port and path. AD-3 requires one SDK. Neither sentence forbids a second socket. The process fails to listen, or the scrape hits whichever server won the bind.
3. Low. Implementer A sets resource `service.name` to `oauth`. Implementer B sets it to `auth` because the old job was `auth`. Conventions say `oauth` but no AD rule does. Series labels diverge. One process means one winner at runtime, so this is weaker than the first two pairs.

No second owner of login state or of the OA error body showed up. AD-6 and AD-7 hold if the implementers share one process.
