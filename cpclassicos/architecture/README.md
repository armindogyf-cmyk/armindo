# CP Clássicos — Architecture Baseline v1.0

Este diretório transforma o desenho funcional CP em contratos técnicos versionáveis.

## Artefactos
- `ERD.sql` — modelo PostgreSQL de referência e integridade relacional.
- `schema.prisma` — modelo ORM para implementação TypeScript/Node.
- `openapi.yaml` — contrato REST OpenAPI 3.1.
- `flows.md` — arquitetura, ERD e workflows Mermaid.
- `../schemas/FORMS.schema.json` — contratos JSON Schema para formulários da aplicação.
- `../schemas/MANUAL_TEMPLATE.schema.json` — contrato canónico para manuais executáveis.

## Princípios obrigatórios
1. PostgreSQL é o system of record.
2. Entidade, evidência, afirmação factual e fonte são objetos diferentes.
3. `SourceAssertion` mantém provenance, confiança, revisão e supersession.
4. Uma fonte D não fecha uma conclusão técnica crítica.
5. Part fitment não passa a `CONFIRMED` por simples importação, marketplace ou decisão administrativa.
6. Dados externos entram por staging/quarantine.
7. Original fotográfico/documental é imutável; anotações e derivados são separados.
8. Diagnóstico é grafo tipado, não campo de texto livre.
9. Work Order é o evento operacional central da oficina.
10. Manual é dado estruturado executável; PDF/PPT/HTML são renderizações.
11. Fecho de OS deve respeitar os requisitos de QA/evidência definidos pelo procedimento.
12. Pesquisa é identifier-first: PN, CP ID, VIN, DTC antes de full text/semântica.
13. Alterações críticas geram `AuditEvent` e usam optimistic concurrency no serviço/API.
14. Segregação de funções: Admin não recebe autoridade de engenharia por defeito.

## Rastreabilidade
`Fault_ID -> OS_ID -> Part_ID / Manual_ID -> Evidence -> Source_ID / SourceAssertion -> AuditEvent`

## Estados de conhecimento
`QUARANTINE -> CANDIDATE -> CONFIRMED`, com `REJECTED` e `SUPERSEDED` preservados para auditoria.

## Gates que o backend deve implementar
- `CONFIRMED fitment`: configuração do veículo suficientemente confirmada + SourceAssertion aceite + Technical Review.
- `PUBLISHED procedure`: revisão técnica + cobertura de fontes + validação estrutural do JSON Schema.
- `CLOSED work order`: passos obrigatórios + checks + evidência + QA concluídos.
- alteração de original: proibida; criar derivative/annotation.
- import externo: nunca escrever diretamente master truth.

## Próxima camada de engenharia
1. migrations SQL numeradas;
2. seed do Hyundai Coupé RD atual com estados reais (incluindo campos ainda `PENDING`);
3. serviço de domínio para state machines;
4. RBAC/ABAC + RLS após decisão IAM;
5. testes de contrato OpenAPI e JSON Schema;
6. testes automóveis negativos (fitment sem fonte A/B, OS sem QA, original imutável);
7. object-storage adapter e verificação SHA-256;
8. UI gerada/validada a partir dos schemas de formulários;
9. renderer de manual CP para modo oficina, web e PDF.
