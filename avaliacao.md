# Avaliação — exclusão lógica (`enabled`)

Revisão do código dos microsserviços de backend em 10/11/2026. O critério verificado é o DELETE com exclusão lógica: toda classe de domínio tem `enabled` (`true` ou `false`); o DELETE grava `false`; com `enabled = false` o objeto some dos GET e não aceita PUT, PATCH nem outro DELETE.

A coluna **Nota T2** desta tabela registra somente o desconto deste critério. Notas integrais de T1, T3 e T4 não foram atribuídas nesta revisão. Não há frontend versionado neste repositório.

| Grupo | Microsserviço de backend | Frontend | Nota T1 | Observações T1 | Nota T2 | Observações T2 | Nota T3 | Observações T3 | Nota T4 | Observações T4 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 01 | classes | — | — | — | — | Class e Review já excluem com `enabled=false` e omitem o registro dos GET e das escritas seguintes. Sem desconto neste critério. | — | — | — | — |
| 02 | lessons | — | — | — | −0,5 | Lesson e LessonTopic faziam DELETE físico (`DELETE FROM`). Ajustado para `enabled=false`. | — | — | — | — |
| 03 | reservations | — | — | — | −0,5 | Reservation só mudava `status` para `CANCELLED` e continuava nos GET. Detail era apagado do banco. Ajustado para `enabled=false`. | — | — | — | — |
| 04 | students | — | — | — | — | Student e AcademicEnrollment já excluem com `enabled=false`. Sem desconto neste critério. | — | — | — | — |
| 05 | courses | — | — | — | — | Course e BibliographicReference já excluem com `enabled=false`. Sem desconto neste critério. | — | — | — | — |
| 06 | resources | — | — | — | — | Resource e Occurrence já excluem com `enabled=false`. Sem desconto neste critério. | — | — | — | — |
| 07 | professors | — | — | — | — | Professor e AcademicDegree já excluem com `enabled=false`. Sem desconto neste critério. | — | — | — | — |
| 08 | rooms | — | — | — | −0,5 | Room e AccessibilityFeature faziam DELETE físico e a resposta não tinha `enabled`. Ajustado para exclusão lógica. | — | — | — | — |
