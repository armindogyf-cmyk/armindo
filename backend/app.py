import hashlib
import os
import uuid
from datetime import datetime, timezone
from pathlib import Path

from fastapi import FastAPI, File, Form, UploadFile
from fastapi.responses import HTMLResponse
from sqlalchemy import create_engine, text

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+psycopg://epa:epa@localhost:5432/epa")
UPLOAD_DIR = Path(os.getenv("UPLOAD_DIR", "/app/data/inbox"))
QUARANTINE_DIR = Path(os.getenv("QUARANTINE_DIR", "/app/data/quarantine"))
LOG_DIR = Path(os.getenv("LOG_DIR", "/app/data/logs"))

for p in (UPLOAD_DIR, QUARANTINE_DIR, LOG_DIR):
    p.mkdir(parents=True, exist_ok=True)

engine = create_engine(DATABASE_URL, future=True)
app = FastAPI(title="ePA Import App", version="1.0.0")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def iso_now() -> str:
    return datetime.now(timezone.utc).isoformat()


@app.get("/health")
def health():
    with engine.connect() as conn:
        conn.execute(text("select 1"))
    return {"status": "ok", "time": iso_now()}


@app.get("/", response_class=HTMLResponse)
def home():
    return """
    <html><body>
    <h2>ePA - App de Importação</h2>
    <form action='/import/upload' enctype='multipart/form-data' method='post'>
      <input name='process_ref' placeholder='PROCESSO_840-25.8KRPRT' required />
      <input type='file' name='files' multiple required />
      <button type='submit'>Upload</button>
    </form>
    <p>Use /import/runs para consultar execuções.</p>
    </body></html>
    """


@app.post("/import/upload")
async def import_upload(process_ref: str = Form(...), files: list[UploadFile] = File(...)):
    run_id = str(uuid.uuid4())
    accepted, quarantined = [], []
    total = 0

    target_dir = UPLOAD_DIR / process_ref
    target_dir.mkdir(parents=True, exist_ok=True)

    with engine.begin() as conn:
        conn.execute(
            text(
                "insert into runs(id, process_ref, started_at, status) values (:id, :process_ref, :started_at, :status)"
            ),
            {"id": run_id, "process_ref": process_ref, "started_at": iso_now(), "status": "DONE"},
        )

        for f in files:
            total += 1
            content = await f.read()
            h = sha256_bytes(content)

            existing = conn.execute(
                text("select id from documents where sha256=:sha256 limit 1"), {"sha256": h}
            ).fetchone()

            size = len(content)
            if size == 0 or existing:
                q_path = QUARANTINE_DIR / f.filename
                q_path.write_bytes(content)
                reason = "empty_file" if size == 0 else "duplicate_hash"
                quarantined.append({"name": f.filename, "reason": reason})
                conn.execute(
                    text(
                        "insert into import_events(id, run_id, file_name, status, reason, created_at) values (:id,:run_id,:file_name,:status,:reason,:created_at)"
                    ),
                    {
                        "id": str(uuid.uuid4()),
                        "run_id": run_id,
                        "file_name": f.filename,
                        "status": "QUARANTINE",
                        "reason": reason,
                        "created_at": iso_now(),
                    },
                )
                continue

            file_path = target_dir / f.filename
            file_path.write_bytes(content)
            doc_id = str(uuid.uuid4())
            conn.execute(
                text(
                    "insert into documents(id, process_ref, file_name, file_path, sha256, size_bytes, created_at) values (:id,:process_ref,:file_name,:file_path,:sha256,:size_bytes,:created_at)"
                ),
                {
                    "id": doc_id,
                    "process_ref": process_ref,
                    "file_name": f.filename,
                    "file_path": str(file_path),
                    "sha256": h,
                    "size_bytes": size,
                    "created_at": iso_now(),
                },
            )
            conn.execute(
                text(
                    "insert into import_events(id, run_id, file_name, status, reason, created_at) values (:id,:run_id,:file_name,:status,:reason,:created_at)"
                ),
                {
                    "id": str(uuid.uuid4()),
                    "run_id": run_id,
                    "file_name": f.filename,
                    "status": "ACCEPTED",
                    "reason": None,
                    "created_at": iso_now(),
                },
            )
            accepted.append({"name": f.filename, "sha256": h})

    return {
        "run_id": run_id,
        "process_ref": process_ref,
        "received": total,
        "accepted": accepted,
        "quarantined": quarantined,
    }


@app.get("/import/runs")
def list_runs():
    with engine.connect() as conn:
        rows = conn.execute(
            text("select id, process_ref, started_at, status from runs order by started_at desc limit 100")
        ).mappings().all()
    return rows
