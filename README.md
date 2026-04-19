# ePA Import App (Teste)

App mínima para importação de documentos com deduplicação por SHA-256 e quarentena.

## Subir ambiente

```bash
docker compose up --build
```

## Usar

- UI: http://localhost:8090
- Health: http://localhost:8090/health
- Runs: http://localhost:8090/import/runs

## Fluxo

1. Enviar `process_ref` + ficheiros.
2. Sistema calcula hash SHA-256.
3. Ficheiros vazios ou duplicados vão para `data/quarantine`.
4. Ficheiros válidos vão para `data/inbox/<process_ref>` e são registados em PostgreSQL.
