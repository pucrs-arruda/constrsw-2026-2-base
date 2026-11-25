# Deferred work

- source_spec: `_bmad-output/implementation-artifacts/spec-0-1-scaffold-angular-22-material-tema-design.md`
  summary: Compose `frontend` still `depends_on` healthy oauth + bff even though Story 0.1 serves a static blank SPA
  evidence: Pre-existing compose envelope; scaffold image is nginx-only and does not call oauth/BFF, but changing depends_on was out of the minimal wire for port/health
