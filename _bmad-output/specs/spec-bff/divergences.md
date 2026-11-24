# Divergências registradas

Nenhuma linha abaixo foi apagada. A coluna **Decisão** é o que esta SPEC executa.

| Tema | Fonte A | Fonte B | Decisão |
| --- | --- | --- | --- |
| Prefixo público | Spine AD-6 / rooms código: `/v1/...` | `docs/open-api/bff.yaml`, students/courses: `/api/v1/...` | **`/api/v1`**. Grupo 08 alinha rooms legado (OQ-ROOMS-PATH fechada). |
| FR-29 | Spine AD-6: `modules/ocupacao/` | closed-cras CAP-10 + `bff.yaml`: `GET /api/v1/reservations/ocupacao` | **Proxy reservations/ocupacao**. Sem módulo `ocupacao/`. |
| FR-19 | Spine AD-6: read-model BFF em `lessons` | closed-cras CAP-6/CAP-10: composição **cliente** sobre proxy | **Cliente**. Sem endpoint BFF dedicado. |
| FR-31 | Spine AD-6: read-model BFF em `classes` | closed-cras: UX-PROFESSOR-VIEW composição cliente | **Cliente**. Sem endpoint BFF dedicado. |
| Login browser | Spine AD-1/AD-6: BFF faz login/cookie | UX 2026-11: login no `oauth`; BFF extrai token do cookie | **OAuth** faz login; BFF **encaminha** token (cookie e/ou Bearer). |
| Envelope 503 composição | students: `BFF-DEPENDENCY` | courses: `CO-503` do domínio | **Por contexto** conforme `bff.yaml` (OQ-503-ENVELOPE fechada; sem unificar). |
| Lista / envelope | Spine Consistency: `items` | OpenAPIs de domínio + BFF: array JSON | **Array JSON** (como os writers). |
| Display name Employee×Professor | closed-cras default BFF | OpenAPI professors sem nome/e-mail | **Composição BFF** (`employeeName` / `employeeEmail`); OpenAPI professors intacto (OQ-ARCH-2 fechada). |
| Dono BFF | — | Equidade ConstrSW / closed-cras | **Sem dono exclusivo**; contribuição por módulo. |

## Wrapper-only (não preservado no kernel)

Cerimônia de planos internos do submódulo (`docs/superpowers/plans/*`), histórico de branches `grupo05`/`grupo08`, e detalhes de merge de commits — úteis para quem implementa courses, não bendem CAP desta SPEC além do que já está em `brownfield.md` / `stack.md`.
