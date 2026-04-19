# Documentação Técnica — ePA Management Forense

## 1) Estrutura de pastas

```text
lib/
  app/
  core/
    navigation/
    theme/
  data/
    db/
    mocks/
    repositories/
    services/
  domain/
    models/
  presentation/
    screens/
    widgets/
  providers/
```

## 2) Camadas
- **Presentation**: ecrãs, componentes visuais, shell e navegação.
- **Domain**: modelos orientados ao domínio jurídico-forense.
- **Data**: schema SQLite, serviços de ingestão e persistência local, mocks e contratos de repositório.
- **Core**: tema institucional, rotas e componentes transversais.

## 3) Rastreabilidade e cadeia probatória
- Documento original tratado como imutável.
- Hash SHA-256 gerado no evento de ingestão.
- Registo de ingestão com timestamp UTC e origem.
- Artefactos TXT versionáveis e ligados a `DOCUMENTO_ID`, `FONTE_ID`, `PROCESSO_ID`.
- Auditoria prevista com snapshots antes/depois de alterações.

## 4) Offline-first
- Operações centrais desenhadas para base local.
- Schema preparado para sincronização assíncrona posterior.
- IDs UUID estáveis para merge e resolução de conflitos.

## 5) Suporte legal-analítico
- Separação de campos para facto extraído, inferência analítica e conclusão jurídica.
- Tabelas para eventos processuais, entidades, relações, risco e conhecimento.
- Estruturas `TABELA_*` para camadas operacionais derivadas.

## 6) Dados de demonstração
Mocks realistas incluídos para processos, entidades e risco.
