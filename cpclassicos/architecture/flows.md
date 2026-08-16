# CP Clássicos — Fluxogramas de arquitetura e domínio

## 1. Arquitetura lógica
```mermaid
flowchart LR
 U[Utilizador oficina / engenharia] --> PWA[CP Clássicos PWA]
 PWA --> IAM[OIDC / MFA / RBAC-ABAC]
 PWA --> API[CP Core API]
 API --> DB[(PostgreSQL System of Record)]
 API --> OBJ[(S3 Object Storage)]
 API --> SEARCH[Identifier-first Search]
 API --> JOBS[Async Jobs / Import / OCR]
 DB --> AUDIT[Audit + SourceAssertion]
 OBJ --> EVID[Evidence + Derivatives + Annotations]
```

## 2. Relações principais
```mermaid
erDiagram
 PROJECT ||--o{ VEHICLE : contains
 VEHICLE ||--o{ VEHICLE_CONFIGURATION : has
 SYSTEM ||--o{ PART : groups
 PART ||--o{ PART_IDENTIFIER : identifies
 PART ||--o{ PART_FITMENT : fits
 VEHICLE_CONFIGURATION ||--o{ PART_FITMENT : applies
 VEHICLE ||--o{ FAULT : reports
 FAULT ||--o{ DIAGNOSTIC_CASE : investigates
 DIAGNOSTIC_CASE ||--o{ DIAGNOSTIC_NODE : contains
 DIAGNOSTIC_NODE ||--o{ DIAGNOSTIC_EDGE : connects
 VEHICLE ||--o{ WORK_ORDER : serviced_by
 FAULT o|--o{ WORK_ORDER : motivates
 PROCEDURE o|--o{ WORK_ORDER : executes
 PROCEDURE ||--o{ PROCEDURE_STEP : consists_of
 WORK_ORDER ||--o{ WORK_ORDER_LINE : contains
 EVIDENCE_ASSET ||--o{ ANNOTATION : annotated_by
 SOURCE ||--o{ SOURCE_ASSERTION : supports
 SOURCE_ASSERTION o|--o{ PART_FITMENT : validates
```

## 3. Provenance / verdade técnica
```mermaid
flowchart LR
 N[Novo dado / evidência] --> Q[Quarantine]
 Q --> V[Validação estrutural]
 V --> S[Source grade + licence check]
 S --> T[Technical review]
 T -->|Rejeitado| R[Rejected - histórico preservado]
 T -->|Candidato| C[Candidate]
 C --> A[Fonte adicional / teste físico]
 A -->|Confirmado| F[Confirmed]
 F --> P[Published CP truth]
 P --> X[Periodic review / supersession]
```

## 4. Diagnóstico dirigido
```mermaid
flowchart TD
 S[Symptom] --> H[Hypothesis]
 H --> T[Test]
 T --> O[Observation]
 O -->|suporta| C[Conclusion]
 O -->|contradiz| H2[Next hypothesis]
 C --> A[Corrective Action]
 A --> QA[Verification / road test]
 QA -->|OK| DONE[Resolved]
 QA -->|NOK| H2
```

## 5. Ordem de Serviço
```mermaid
stateDiagram-v2
 [*] --> DRAFT
 DRAFT --> TECHNICAL_REVIEW
 TECHNICAL_REVIEW --> APPROVED
 TECHNICAL_REVIEW --> BLOCKED
 APPROVED --> IN_PROGRESS
 IN_PROGRESS --> QA
 IN_PROGRESS --> BLOCKED
 QA --> CLOSED: evidence + checks complete
 QA --> IN_PROGRESS: QA failed
 BLOCKED --> TECHNICAL_REVIEW
 DRAFT --> CANCELLED
 APPROVED --> CANCELLED
 CLOSED --> [*]
 CANCELLED --> [*]
```

## 6. Criação e publicação de manual
```mermaid
flowchart TD
 A[Novo Manual] --> B[Sistema / tipo]
 B --> C[Aplicabilidade]
 C --> D[Riscos e pré-requisitos]
 D --> E[Ferramentas]
 E --> F[Peças / consumíveis]
 F --> G[Etapas]
 G --> H[Checks e critérios]
 H --> I[Evidência obrigatória]
 I --> J[Fontes / assertions]
 J --> K[Technical Review]
 K -->|falha| G
 K -->|aprovado| L[Published Procedure]
 L --> M[Executável numa OS]
```

## 7. Execução de um passo de manual
```mermaid
flowchart LR
 OPEN[Abrir passo] --> READ[Visual + ação + risco]
 READ --> PRE[Confirmar pré-condições]
 PRE --> ACT[Executar ação]
 ACT --> CHECK[Check / medição]
 CHECK -->|NOK| STOP[STOP / diagnóstico]
 CHECK -->|OK| EV[Capturar evidência exigida]
 EV --> SAVE[Guardar resultado]
 SAVE --> NEXT[Próximo passo]
```

## 8. Rastreabilidade CP
```mermaid
flowchart LR
 F[Fault_ID] --> OS[OS_ID]
 OS --> P[Part_ID]
 OS --> M[Manual_ID / Procedure]
 P --> E[Evidence]
 M --> E
 E --> S[Source_ID / SourceAssertion]
 S --> A[AuditEvent]
```

## 9. Upload de evidência imutável
```mermaid
sequenceDiagram
 participant UI as CP App
 participant API as Core API
 participant OBJ as Object Storage
 participant DB as PostgreSQL
 UI->>API: initiate-upload(filename, mime, sha256)
 API->>DB: verify duplicate hash
 API-->>UI: signed upload target
 UI->>OBJ: upload original bytes
 UI->>API: complete upload
 API->>OBJ: verify object/hash
 API->>DB: create EvidenceAsset immutable=true
 API-->>UI: asset_id
 Note over OBJ,DB: Original never overwritten; derivatives are separate assets
```

## 10. Gate de confirmação de fitment
```mermaid
flowchart TD
 F[Candidate fitment] --> SA{SourceAssertion exists?}
 SA -->|não| Q[Remain Candidate / Quarantine]
 SA -->|sim| G{Source grade}
 G -->|D| Q
 G -->|C| REVIEW[Technical review + corroboration]
 G -->|A/B| REVIEW
 REVIEW --> E{Configuration confirmed?}
 E -->|não| Q
 E -->|sim| DEC{Engineer decision}
 DEC -->|rejeita| R[Rejected]
 DEC -->|confirma| C[Confirmed]
```
