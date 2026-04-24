# ePA – Management Forense (Flutter)

Aplicação multiplataforma (iPhone, Android, Windows e macOS) para inteligência documental, probatória e jurídica.

## Princípios nucleares
- Documento original imutável.
- Rastreabilidade integral da lógica analítica.
- Documento como fonte primária.
- Separação entre facto extraído, inferência e conclusão jurídica.
- TXT como camada operacional central.
- Conclusões sempre referenciadas à fonte e aos artefactos derivados.

## Arquitetura
- **Clean/modular** por camadas (`presentation`, `domain`, `data`, `core`).
- **Gestão de estado**: Riverpod.
- **Navegação**: GoRouter com shell institucional.
- **Persistência local**: SQLite (estrutura pronta para evolução Drift).
- **Offline-first / sync-ready**: serviços locais desacoplados e modelos com IDs estáveis.

## Módulos implementados (base)
1. Dashboard
2. Documentos
3. Fontes
4. Processos
5. Entidades
6. Eventos processuais
7. Segmentos documentais
8. Análise
9. Risco
10. Conhecimento
11. Auditoria
12. Pesquisa
13. Exportações
14. Configurações

> Na UI inicial estão disponíveis os ecrãs principais pedidos (Dashboard, Documentos, Processo, Entidades, Relações, Risco, Conhecimento, Auditoria e Configurações).

## Estruturas de dados
- Modelos de domínio para: `User`, `Role`, `Source`, `Document`, `DocumentVersion`, `DocumentSegment`, `TxtArtifact`, `Process`, `Court`, `Event`, `Entity`, `EntityRelation`, `Fact`, `Vehicle`, `Transfer`, `RiskRecord`, `KnowledgeItem`, `AuditLog`, `ValidationRecord`, `Tag`, `Attachment`.
- Schema SQLite com tabelas nucleares e estruturas de apoio `TABELA_*`.

## Ingestão documental
Formatos previstos:
- PDF
- DOCX
- XLSX/XLS
- TXT
- RTF
- imagens/scans
- emails exportados

Ao importar, o serviço base gera:
- `source_id`
- `documento_id`
- `hash_sha256`
- `timestamp_ingestao`
- `tipo_fonte`
- `caminho_origem`
- `processo_associado`
- `estado_extracao`

Artefactos TXT preparados por documento:
- TRANSCRICAO
- ESTRUTURA
- ANALISE
- RISCO
- CONHECIMENTO

Campos de cada TXT:
- `TXT_ID`, `TIPO_TXT`, `DOCUMENTO_ID`, `PROCESSO_ID`, `FONTE_ID`, `HASH_DOCUMENTAL`, `TIMESTAMP_GERACAO`, `VERSAO`, `MOTOR_RESPONSAVEL`, `ESTADO`, `CONTEUDO`, `METADADOS`, `LOG_TECNICO`.

## Perfis
- administrador
- partner
- advogado
- analista forense
- gestor documental
- auditor interno
- operador de digitalização
- consulta

## UI
Tema **dark institutional premium** com paleta:
- grafite profundo
- cinza-ardósia
- turquesa técnico
- branco neutro
- dourado discreto
- vermelho para criticidade

## Arranque
> Requer Flutter SDK 3.22+ (ou compatível com Dart 3.3+).

```bash
flutter pub get
flutter run -d windows   # ou macos / ios / android
```

## Build
```bash
flutter build windows
flutter build macos
flutter build apk
flutter build ios
```

## Próximos passos recomendados
- Integrar Drift com migrations e DAOs.
- Pipeline OCR/transcrição (tesseract/serviço dedicado).
- Indexação full-text e motor de pesquisa jurídica.
- Sync engine cifrado por eventos.
