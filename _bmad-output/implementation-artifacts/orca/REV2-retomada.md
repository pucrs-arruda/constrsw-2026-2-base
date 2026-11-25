# REV-2 — retomada em 24/11/2026

## Estado recuperado

- Revisor atual: `orca_session_id:a5f10384-2c90-4728-9af4-74baf3161dc1`.
- Escopo exclusivo: AG-04 a AG-08, frontend. Nenhuma alteração de código de produção pelo revisor.
- Base: `grupo08-base-feat/orquestracao`; frontend: `grupo08-frontend-feat/base`.
- Na inspeção inicial, HEAD e `grupo08-frontend` estavam em `c1d00e9`; README modificado e arquivos Angular não rastreados. Nenhum merge frontend aprovado encontrado.
- Não havia relatório AG-04 nem parecer REV2 no diretório de artefatos. Mensagens antigas de entregas para outra sessão/workspace não comprovam entrega neste checkout.
- Achado anterior recuperado da caixa de mensagens (`msg_ea8a13a761bb`): `nginx.conf` usa `proxy_pass` com variável e URI literal `/`, podendo perder caminho/query. Encaminhado ao AG-04 retomado para correção e evidência.
- Tentativa de comunicação com o endereço antigo do AG-04 recusada (`session_caller_not_live`, pedido `a79b0665-a968-4316-8e00-2c21d388e045`); nenhuma mensagem foi enviada por essa tentativa.

## Sessões atuais observadas em `orca agent list --json`

| Papel | Endereço |
| --- | --- |
| REV-1 | `orca_session_id:134202bd-6a12-4790-a4da-332ac88e7530` |
| REV-2 | `orca_session_id:a5f10384-2c90-4728-9af4-74baf3161dc1` |
| AG-04 | `orca_session_id:b4866e74-7cb5-40fb-aec2-2910602e0ed0` |
| AG-05 | `orca_session_id:a7682aa1-f036-4038-9726-02b20fc3eb76` |
| AG-06 | `orca_session_id:5cbbdc30-54f8-4bcb-9868-e90cb55e212c` |
| AG-07 | `orca_session_id:1aadfb6b-5253-4515-8852-aba2ca6cd050` |
| AG-08 | `orca_session_id:8ed01ea6-576f-4f62-87ba-0a4b62bec580` |

## Próxima ação

Aguardar entrega do AG-04 na sessão atual, revisar o hash e os critérios da seção 9, registrar `REV2-AG-04-parecer.md` e responder à mensagem de entrega. AG-05, AG-06, AG-07 e AG-08 continuam bloqueados, em série. Cada liberação exige aprovação e merge do anterior em `grupo08-frontend`, confirmados no Git. Nenhuma ação em `main`.

Ao concluir AG-08, avisar REV-1 com assunto `Frontend concluído`. Registrar aqui mudanças de estado relevantes para outra retomada.

**Atualização após os commits do AG-04:** `agentes.md` já contém as sessões novas. O parecer `REV2-AG-04-parecer.md` registra a reprovação de `c7a9e70`, com achados reproduzidos no nginx e no navegador. O Orca aceitou o envio integral do parecer para o AG-04 (`msg_30270c1a613d`). Aguardar novo hash e relatório 8.0. AG-05 segue aguardando.

**Mudança de principal:** despacho `msg_b1062f810e40`, confirmado na seção 3.1 e no remoto. A principal válida passou a `frontend/grupo08` e as branches de desenvolvimento a `frontend/grupo08-feat/<slug>`. As menções anteriores a `grupo08-frontend` registram o estado histórico. A ordem serial e os critérios de aprovação e merge continuam os mesmos.

**Substituição do REV-1:** o coordenador designou o REV-1b (`msg_988361fba7ec`). O aviso final `Frontend concluído` deverá ir para o endereço do substituto em `agentes.md`, atualmente `orca_session_id:bee6341a-1a00-4720-83e0-16ea50fd6efc`.
