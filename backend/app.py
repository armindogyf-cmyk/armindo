import hashlib
import os
import uuid
from datetime import datetime, timezone
from pathlib import Path

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from sqlalchemy import create_engine, text

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite+pysqlite:////app/data/epa.db")
BASE_DATA_DIR = Path(os.getenv("BASE_DATA_DIR", "/app/data"))
UPLOAD_DIR = BASE_DATA_DIR / "inbox"
TXT_DIR = BASE_DATA_DIR / "txt"
QUARANTINE_DIR = BASE_DATA_DIR / "quarantine"

for p in (BASE_DATA_DIR, UPLOAD_DIR, TXT_DIR, QUARANTINE_DIR):
    p.mkdir(parents=True, exist_ok=True)

engine = create_engine(DATABASE_URL, future=True)
app = FastAPI(title="ePA – Management Forense", version="0.1.0")


class ProcessoIn(BaseModel):
    numero_processo: str
    referencia_interna: str | None = None
    tribunal: str | None = None
    juizo: str | None = None
    fase_processual: str | None = None
    estado: str | None = None
    grau_sigilo: str | None = None
    resumo_executivo: str | None = None


class IntervenienteIn(BaseModel):
    nome: str
    tipo: str | None = None
    nif_nipc: str | None = None
    categoria: str | None = None
    observacoes: str | None = None


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def iso_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def compute_risk(probabilidade: float, impacto: float, peso_dimensao: float, fiabilidade_fonte: float) -> float:
    score = probabilidade * impacto * peso_dimensao * fiabilidade_fonte
    return max(0, min(100, round(score, 2)))


def risk_notation(score: float) -> str:
    if score <= 20:
        return "muito baixo"
    if score <= 40:
        return "baixo"
    if score <= 60:
        return "moderado"
    if score <= 80:
        return "elevado"
    return "crítico"


def append_audit(utilizador: str, acao: str, objeto_tipo: str, objeto_id: str, detalhe: str) -> None:
    state_hash = sha256_bytes(f"{utilizador}|{acao}|{objeto_tipo}|{objeto_id}|{detalhe}|{iso_now()}".encode())
    with engine.begin() as conn:
        conn.execute(
            text(
                """
                insert into logs_auditoria(log_id, utilizador, acao, objeto_tipo, objeto_id, timestamp, detalhe, hash_estado)
                values (:log_id, :utilizador, :acao, :objeto_tipo, :objeto_id, :timestamp, :detalhe, :hash_estado)
                """
            ),
            {
                "log_id": str(uuid.uuid4()),
                "utilizador": utilizador,
                "acao": acao,
                "objeto_tipo": objeto_tipo,
                "objeto_id": objeto_id,
                "timestamp": iso_now(),
                "detalhe": detalhe,
                "hash_estado": state_hash,
            },
        )


def emit_txt_variants(documento_id: str, txt_base: str, base_name: str) -> list[dict]:
    variants = [
        ("transcricao", txt_base),
        ("estrutura", f"## Estrutura\n\n{txt_base[:1000]}"),
        ("analise", "## Facto\n- ...\n\n## Inferência\n- ...\n\n## Conclusão\n- ..."),
        ("risco", "## Risco\n- probabilidade: 0.6\n- impacto: 0.7"),
        ("conhecimento", "## Conhecimento\n- entidades\n- relações\n- eventos"),
    ]
    created = []
    for idx, (tipo, content) in enumerate(variants, start=1):
        out_path = TXT_DIR / f"{base_name}.{tipo}.txt"
        out_path.write_text(content, encoding="utf-8")
        h = sha256_bytes(content.encode("utf-8"))
        txt_id = str(uuid.uuid4())
        with engine.begin() as conn:
            conn.execute(
                text(
                    """
                    insert into txt_registo(txt_id, documento_id, tipo_txt, caminho_txt, versao, timestamp, hash_txt, motor_responsavel)
                    values (:txt_id,:documento_id,:tipo_txt,:caminho_txt,:versao,:timestamp,:hash_txt,:motor_responsavel)
                    """
                ),
                {
                    "txt_id": txt_id,
                    "documento_id": documento_id,
                    "tipo_txt": tipo,
                    "caminho_txt": str(out_path),
                    "versao": f"v1.{idx}",
                    "timestamp": iso_now(),
                    "hash_txt": h,
                    "motor_responsavel": "epa-core-0.1",
                },
            )
        created.append({"tipo": tipo, "path": str(out_path), "hash": h})
    return created


@app.get("/health")
def health():
    with engine.connect() as conn:
        conn.execute(text("select 1"))
    return {"status": "ok", "time": iso_now(), "version": "ePA v0.1.0"}


@app.get("/", response_class=HTMLResponse)
def home():
    return """
    <html><body style='background:#06111F;color:#F4F1EC;font-family:sans-serif'>
    <h2>ePA – Management Forense</h2>
    <p>Core API forense offline-first (v0.1.0).</p>
    <ul>
      <li>POST /processos</li>
      <li>POST /intervenientes</li>
      <li>POST /documentos/import</li>
      <li>GET /dashboard/{processo_id}</li>
      <li>GET /timeline/{processo_id}</li>
    </ul>
    </body></html>
    """


@app.post("/processos")
def create_processo(payload: ProcessoIn):
    processo_id = str(uuid.uuid4())
    with engine.begin() as conn:
        conn.execute(
            text(
                """
                insert into processos(
                    processo_id, numero_processo, referencia_interna, tribunal, juizo,
                    fase_processual, estado, grau_sigilo, score_risco, resumo_executivo
                ) values (
                    :processo_id, :numero_processo, :referencia_interna, :tribunal, :juizo,
                    :fase_processual, :estado, :grau_sigilo, :score_risco, :resumo_executivo
                )
                """
            ),
            {
                "processo_id": processo_id,
                "numero_processo": payload.numero_processo,
                "referencia_interna": payload.referencia_interna,
                "tribunal": payload.tribunal,
                "juizo": payload.juizo,
                "fase_processual": payload.fase_processual,
                "estado": payload.estado,
                "grau_sigilo": payload.grau_sigilo,
                "score_risco": 0,
                "resumo_executivo": payload.resumo_executivo,
            },
        )
    append_audit("system", "CREATE", "processo", processo_id, payload.numero_processo)
    return {"processo_id": processo_id}


@app.get("/processos")
def list_processos():
    with engine.connect() as conn:
        rows = conn.execute(text("select * from processos order by numero_processo")).mappings().all()
    return rows


@app.post("/intervenientes")
def create_interveniente(payload: IntervenienteIn):
    interveniente_id = str(uuid.uuid4())
    with engine.begin() as conn:
        conn.execute(
            text(
                """
                insert into intervenientes(interveniente_id, nome, tipo, nif_nipc, categoria, observacoes)
                values (:interveniente_id,:nome,:tipo,:nif_nipc,:categoria,:observacoes)
                """
            ),
            {"interveniente_id": interveniente_id, **payload.model_dump()},
        )
    append_audit("system", "CREATE", "interveniente", interveniente_id, payload.nome)
    return {"interveniente_id": interveniente_id}


@app.post("/documentos/import")
async def import_document(
    processo_id: str = Form(...),
    tipo_documento: str = Form(...),
    titulo: str = Form(...),
    utilizador: str = Form("system"),
    file: UploadFile = File(...),
):
    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Ficheiro vazio.")

    with engine.connect() as conn:
        processo = conn.execute(
            text("select processo_id from processos where processo_id=:pid"), {"pid": processo_id}
        ).fetchone()
    if not processo:
        raise HTTPException(status_code=404, detail="Processo não encontrado.")

    file_hash = sha256_bytes(content)
    with engine.connect() as conn:
        existing = conn.execute(
            text("select documento_id from documentos where hash_sha256=:h limit 1"), {"h": file_hash}
        ).fetchone()
    if existing:
        q_path = QUARANTINE_DIR / file.filename
        q_path.write_bytes(content)
        append_audit(utilizador, "QUARANTINE", "documento", str(existing[0]), f"duplicate:{file.filename}")
        return {"status": "quarantine", "reason": "duplicate_hash", "hash": file_hash}

    fonte_id = str(uuid.uuid4())
    documento_id = str(uuid.uuid4())
    target_dir = UPLOAD_DIR / processo_id
    target_dir.mkdir(parents=True, exist_ok=True)
    src_path = target_dir / file.filename
    src_path.write_bytes(content)

    txt_path = TXT_DIR / f"{documento_id}.transcricao.txt"
    txt_content = content.decode("utf-8", errors="replace")
    txt_path.write_text(txt_content, encoding="utf-8")

    with engine.begin() as conn:
        conn.execute(
            text(
                """
                insert into fontes(fonte_id, processo_id, tipo_fonte, origem, filepath, filelink, hash_sha256, data_entrada, estado_validacao)
                values (:fonte_id,:processo_id,:tipo_fonte,:origem,:filepath,:filelink,:hash_sha256,:data_entrada,:estado_validacao)
                """
            ),
            {
                "fonte_id": fonte_id,
                "processo_id": processo_id,
                "tipo_fonte": "upload",
                "origem": "local",
                "filepath": str(src_path),
                "filelink": None,
                "hash_sha256": file_hash,
                "data_entrada": iso_now(),
                "estado_validacao": "validado",
            },
        )
        conn.execute(
            text(
                """
                insert into documentos(
                    documento_id, processo_id, fonte_id, tipo_documento, titulo, data_documento,
                    referencia, filepath_original, filepath_txt, hash_sha256, estado_leitura, texto_integral_indexado
                ) values (
                    :documento_id,:processo_id,:fonte_id,:tipo_documento,:titulo,:data_documento,
                    :referencia,:filepath_original,:filepath_txt,:hash_sha256,:estado_leitura,:texto_integral_indexado
                )
                """
            ),
            {
                "documento_id": documento_id,
                "processo_id": processo_id,
                "fonte_id": fonte_id,
                "tipo_documento": tipo_documento,
                "titulo": titulo,
                "data_documento": iso_now(),
                "referencia": file.filename,
                "filepath_original": str(src_path),
                "filepath_txt": str(txt_path),
                "hash_sha256": file_hash,
                "estado_leitura": "txt_gerado",
                "texto_integral_indexado": txt_content[:50000],
            },
        )

    txts = emit_txt_variants(documento_id, txt_content, documento_id)
    append_audit(utilizador, "IMPORT", "documento", documento_id, f"{file.filename}|{file_hash}")
    return {"status": "accepted", "documento_id": documento_id, "hash": file_hash, "txt": txts}


@app.post("/riscos/{processo_id}")
def create_risco(
    processo_id: str,
    tipo_risco: str = Form(...),
    probabilidade: float = Form(...),
    impacto: float = Form(...),
    peso_dimensao: float = Form(1.0),
    fiabilidade_fonte: float = Form(1.0),
    recomendacao: str = Form(""),
):
    score = compute_risk(probabilidade, impacto, peso_dimensao, fiabilidade_fonte)
    risco_id = str(uuid.uuid4())
    with engine.begin() as conn:
        conn.execute(
            text(
                """
                insert into riscos(
                    risco_id, processo_id, interveniente_id, tipo_risco, probabilidade,
                    impacto, score_final, notacao, fontes_suporte, recomendacao
                ) values (
                    :risco_id,:processo_id,:interveniente_id,:tipo_risco,:probabilidade,
                    :impacto,:score_final,:notacao,:fontes_suporte,:recomendacao
                )
                """
            ),
            {
                "risco_id": risco_id,
                "processo_id": processo_id,
                "interveniente_id": None,
                "tipo_risco": tipo_risco,
                "probabilidade": probabilidade,
                "impacto": impacto,
                "score_final": score,
                "notacao": risk_notation(score),
                "fontes_suporte": "pending_source_review",
                "recomendacao": recomendacao,
            },
        )
        conn.execute(
            text("update processos set score_risco=:score where processo_id=:processo_id"),
            {"score": score, "processo_id": processo_id},
        )
    append_audit("system", "RISK", "processo", processo_id, f"{tipo_risco}:{score}")
    return {"risco_id": risco_id, "score": score, "notacao": risk_notation(score)}


@app.get("/dashboard/{processo_id}")
def dashboard(processo_id: str):
    with engine.connect() as conn:
        processo = conn.execute(
            text("select * from processos where processo_id=:id"), {"id": processo_id}
        ).mappings().fetchone()
        if not processo:
            raise HTTPException(status_code=404, detail="Processo não encontrado")

        counts = {
            "documentos": conn.execute(
                text("select count(*) from documentos where processo_id=:id"), {"id": processo_id}
            ).scalar_one(),
            "transcricoes": conn.execute(
                text(
                    """
                    select count(*) from txt_registo t
                    join documentos d on d.documento_id = t.documento_id
                    where d.processo_id=:id
                    """
                ),
                {"id": processo_id},
            ).scalar_one(),
            "riscos": conn.execute(
                text("select count(*) from riscos where processo_id=:id"), {"id": processo_id}
            ).scalar_one(),
            "intervenientes": conn.execute(text("select count(*) from intervenientes")).scalar_one(),
        }

        top_risks = conn.execute(
            text(
                "select tipo_risco, score_final, notacao from riscos where processo_id=:id order by score_final desc limit 5"
            ),
            {"id": processo_id},
        ).mappings().all()

    return {"processo": dict(processo), "metricas": counts, "principais_riscos": top_risks}


@app.get("/timeline/{processo_id}")
def timeline(processo_id: str):
    with engine.connect() as conn:
        eventos = conn.execute(
            text(
                "select data_evento, tipo_evento, descricao, impacto_risco from eventos where processo_id=:id order by data_evento"
            ),
            {"id": processo_id},
        ).mappings().all()
    return eventos


@app.get("/demo/bootstrap")
def bootstrap_demo_data():
    processo_id = str(uuid.uuid4())
    now = iso_now()
    docs = [
        "Termo de apensação",
        "Ato de Magistrado",
        "Promoção para buscas",
        "Autorização de buscas",
        "Auto de interrogatório",
        "Despacho medidas de coação",
        "Recurso",
    ]
    with engine.begin() as conn:
        conn.execute(
            text(
                """
                insert into processos(
                    processo_id, numero_processo, referencia_interna, tribunal, juizo, fase_processual,
                    estado, grau_sigilo, score_risco, resumo_executivo
                ) values (
                    :processo_id, :numero_processo, :referencia_interna, :tribunal, :juizo, :fase_processual,
                    :estado, :grau_sigilo, :score_risco, :resumo_executivo
                )
                """
            ),
            {
                "processo_id": processo_id,
                "numero_processo": "840/25.8KRPRT",
                "referencia_interna": "EPA-PILOTO-001",
                "tribunal": "DIAP Regional do Porto",
                "juizo": "1.ª Secção",
                "fase_processual": "Inquérito",
                "estado": "Em investigação",
                "grau_sigilo": "Segredo de Justiça ativo",
                "score_risco": 0,
                "resumo_executivo": "Processo piloto forense inicial.",
            },
        )

        for i, title in enumerate(docs):
            doc_id = str(uuid.uuid4())
            fonte_id = str(uuid.uuid4())
            fake_content = f"{title}\nFacto {i+1}: conteúdo demonstrativo.".encode()
            h = sha256_bytes(fake_content)
            src_path = UPLOAD_DIR / processo_id / f"doc_{i+1}.txt"
            src_path.parent.mkdir(parents=True, exist_ok=True)
            src_path.write_bytes(fake_content)
            txt_path = TXT_DIR / f"{doc_id}.transcricao.txt"
            txt_path.write_text(fake_content.decode(), encoding="utf-8")

            conn.execute(
                text(
                    """
                    insert into fontes(fonte_id, processo_id, tipo_fonte, origem, filepath, filelink, hash_sha256, data_entrada, estado_validacao)
                    values (:fonte_id,:processo_id,:tipo_fonte,:origem,:filepath,:filelink,:hash_sha256,:data_entrada,:estado_validacao)
                    """
                ),
                {
                    "fonte_id": fonte_id,
                    "processo_id": processo_id,
                    "tipo_fonte": "demo",
                    "origem": "bootstrap",
                    "filepath": str(src_path),
                    "filelink": None,
                    "hash_sha256": h,
                    "data_entrada": now,
                    "estado_validacao": "validado",
                },
            )
            conn.execute(
                text(
                    """
                    insert into documentos(documento_id, processo_id, fonte_id, tipo_documento, titulo, data_documento, referencia, filepath_original, filepath_txt, hash_sha256, estado_leitura, texto_integral_indexado)
                    values (:documento_id,:processo_id,:fonte_id,:tipo_documento,:titulo,:data_documento,:referencia,:filepath_original,:filepath_txt,:hash_sha256,:estado_leitura,:texto_integral_indexado)
                    """
                ),
                {
                    "documento_id": doc_id,
                    "processo_id": processo_id,
                    "fonte_id": fonte_id,
                    "tipo_documento": "ato_processual",
                    "titulo": title,
                    "data_documento": now,
                    "referencia": f"DOC-{i+1:03}",
                    "filepath_original": str(src_path),
                    "filepath_txt": str(txt_path),
                    "hash_sha256": h,
                    "estado_leitura": "txt_gerado",
                    "texto_integral_indexado": fake_content.decode(),
                },
            )
            emit_txt_variants(doc_id, fake_content.decode(), doc_id)

            conn.execute(
                text(
                    "insert into eventos(evento_id, processo_id, data_evento, tipo_evento, descricao, documento_id_origem, impacto_risco) values (:evento_id,:processo_id,:data_evento,:tipo_evento,:descricao,:documento_id_origem,:impacto_risco)"
                ),
                {
                    "evento_id": str(uuid.uuid4()),
                    "processo_id": processo_id,
                    "data_evento": now,
                    "tipo_evento": title,
                    "descricao": f"Evento registado: {title}",
                    "documento_id_origem": doc_id,
                    "impacto_risco": "moderado",
                },
            )

    append_audit("system", "BOOTSTRAP", "processo", processo_id, "demo_seed")
    return {"processo_id": processo_id, "documentos_demo": len(docs)}
