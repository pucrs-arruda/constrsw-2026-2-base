# Agentes abertos no Orca

Worktree: `identity:wt2:local:d3906c04-270c-46b9-9689-8392ccd45aa0` (branch base `claude/rooms-frontend-bff-dfae7e`).

| Agente | Ferramenta | Endereço para `orca.exe orchestration send --to` | Onda |
| --- | --- | --- | --- |
| REV | Claude (chat) | `orca_session_id:6d0097d6-de60-4510-b863-f60b60314732` | todas |
| AG-01 | Antigravity (chat) | `orca_session_id:d894baea-f812-45c1-bd51-672c93fe0dc2` | 1 |
| AG-02 | Antigravity (chat) | `orca_session_id:221b2244-c5e4-428b-9d21-5288d9a9ee2d` | 1 |
| AG-04 | Antigravity (chat) | `orca_session_id:b64971a7-4458-4020-bc49-06030e289cdb` | 1 |

Atenção para as próximas ondas: todos os agentes usam o mesmo checkout. Dois agentes no mesmo submódulo ao mesmo tempo (AG-05 e AG-06 no `frontend`; AG-07 e AG-08) brigariam pela branch ativa. Rode esses pares um depois do outro, ou crie um `git worktree` do submódulo para o segundo.
