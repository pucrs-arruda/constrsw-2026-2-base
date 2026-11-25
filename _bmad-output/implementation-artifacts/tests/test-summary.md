# Test Automation Summary

**Date:** 2026-11-25  
**Skill:** `bmad-qa-generate-e2e-tests`  
**Stack:** Playwright 1.65 · Chromium · frontend Compose `:4200`

## Generated Tests

### E2E Tests (`frontend/e2e/`)

- [x] `specs/login.spec.ts` — UX-LOGIN (401/identity banner + happy path + Sair)
- [x] `specs/shell-nav.spec.ts` — Home + 9 placeholders de domínio (smoke)
- [x] `specs/employees.spec.ts` — UX-EMPLOYEES (lista/busca/Abrir/Novo, criar, detalhe, dependentes CRUD)
- [x] Helpers: seed/purge `E2E-*`, Keycloak role `funcionario`, bridge BFF→employees

### API Tests

- [x] Cobertos indiretamente via helpers de seed (`POST/DELETE /api/v1/employees` + dependents no domínio `8184`)
- [ ] Suite API isolada no BFF — adiada (BFF ainda sem proxy employees)

## Coverage

| Superfície | Status |
|---|---|
| UX-LOGIN | Exercitada (recusa + sucesso + logout) |
| UX-HOME / shell | Exercitada |
| Placeholders (9 rotas) | Smoke de navegação |
| UX-EMPLOYEES lista/detalhe/criar | Exercitada (controles + dialogs) |
| Domínios futuros | Só placeholder |

**Resultado da última execução:** **16/16 passed** (~40s)

## Massa / idempotência

- Prefixo `E2E-` em matrícula/nome
- `global-setup` + `afterAll` fazem purge (DELETE lógico no domínio)
- Role `funcionario` garantida no usuário lab (`admin@pucrs.br`)

## Gap conhecido

O BFF não proxia `/api/v1/employees*`; a lista trata 404 como vazio. O harness usa `page.route` → `employees:8184` até existir proxy no BFF.

## How to run

```bash
# stack mínima
docker compose up -d --build postgresql keycloak oauth employees bff frontend

cd frontend && npm run e2e
```

Ver `frontend/e2e/README.md`.

## Next Steps

- Remover bridge quando o BFF proxiar employees
- Incluir `npm run e2e` no CI do frontend
- Ampliar E2E conforme novas superfícies saírem do placeholder
