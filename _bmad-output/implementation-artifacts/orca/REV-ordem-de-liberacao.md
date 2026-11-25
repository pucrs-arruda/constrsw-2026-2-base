# REV: ordem de liberação dos agentes (instrução do coordenador)

Os agentes AG-03, AG-05, AG-06, AG-07, AG-08 e AG-09 já estão abertos e **parados**, esperando uma mensagem sua com o assunto exato `LIBERADO AG-0X`. Você é quem libera cada um, nesta ordem:

| Liberar | Quando | Endereço |
| --- | --- | --- |
| AG-03 | AG-02 **aprovado e mergeado** em `grupo08-bff` | `orca_session_id:5a88c94b-2fd3-4081-b004-19c0d1794a91` |
| AG-05 | AG-04 **aprovado e mergeado** em `grupo08-frontend` | `orca_session_id:dd379f1c-982a-4b61-9e09-b9860de657f9` |
| AG-06 | AG-05 **aprovado e mergeado** (não em paralelo: os dois usam o mesmo checkout do `frontend`) | `orca_session_id:bb02bcf5-3b04-48c2-9880-19f2ed5fa6f9` |
| AG-07 | AG-06 **aprovado e mergeado** | `orca_session_id:3788d551-4ef7-46e8-a4d1-5b757b7cbecb` |
| AG-08 | AG-07 **aprovado e mergeado** | `orca_session_id:69f6099b-59a9-43e6-a42f-233decd9d062` |
| AG-09 | AG-01, AG-03 e AG-08 **aprovados e mergeados** | `orca_session_id:9d4e6660-3be0-456b-82fc-b87d7bb572ec` |

Como liberar (assunto exato, tipo `dispatch`):

```
C:\Users\Lucas\AppData\Local\Programs\orca\resources\bin\orca.exe orchestration send --to <endereço> --type dispatch --subject "LIBERADO AG-0X" --body "Pode começar. A principal do grupo já contém o trabalho aprovado de que você depende." --json
```

Antes de liberar, confirme no submódulo que o merge está na principal (`git log --oneline --merges origin/<principal>`). Os frontends rodam em série (AG-05 → AG-06 → AG-07 → AG-08) porque todos compartilham o mesmo checkout de `frontend`. Avise o Lucas no chat a cada liberação.
