# ePA v0.1.0 — Forensic Intelligence Core

Base inicial funcional para gestão forense **offline-first**, com foco em:
- hash SHA-256 e rastreabilidade;
- pipeline TXT versionado;
- SQLite local;
- dashboard e timeline por processo;
- seed de processo piloto `840/25.8KRPRT`.

## Stack atual (core API)
- FastAPI + Python
- SQLite (`/app/data/epa.db`)
- SQLAlchemy
- Docker Compose

> Nota: a arquitetura-alvo multiplataforma (Tauri v2 + React/TypeScript + Rust + PWA) permanece como evolução da próxima iteração.

## Subir ambiente

```bash
docker compose up --build
```

API em: `http://localhost:8090`

## Endpoints principais
- `GET /health`
- `POST /processos`
- `GET /processos`
- `POST /intervenientes`
- `POST /documentos/import` (multipart)
- `POST /riscos/{processo_id}`
- `GET /dashboard/{processo_id}`
- `GET /timeline/{processo_id}`
- `GET /demo/bootstrap` (cria o processo piloto e 7 documentos demo)

## Pipeline obrigatório implementado
Documento original → SHA-256 → TXT transcrição → TXT estrutura → TXT análise → TXT risco → TXT conhecimento → base de dados → indexação básica (campo textual) → dashboard.

## Regras forenses cobertas no core
1. Documento original preservado no `inbox`.
2. Importação cria sempre fonte (`fontes`).
3. Documento sem hash não é registado.
4. Risco com score e registo de suporte/recomendação.
5. Análise separada por facto/inferência/conclusão no TXT de análise.
6. Alterações com log em `logs_auditoria`.
7. TXT versionado em `txt_registo`.
8. Linha de prova por `documento_id`, hash e caminhos TXT.
9. Revisão humana via endpoints + artefactos TXT.
10. Funciona offline com SQLite local.

## Processo piloto
Ao chamar `GET /demo/bootstrap`, são gerados:
- Processo `840/25.8KRPRT`;
- Entidade: DIAP Regional do Porto – 1.ª Secção;
- Estado: Em investigação;
- Sigilo: Segredo de Justiça ativo;
- 7 documentos demo conforme instrução.
