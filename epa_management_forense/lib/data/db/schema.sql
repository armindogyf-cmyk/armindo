CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role_id TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS roles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  permissions_json TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sources (
  id TEXT PRIMARY KEY,
  source_type TEXT NOT NULL,
  source_path TEXT NOT NULL,
  source_hash TEXT,
  ingested_at TEXT NOT NULL,
  process_id TEXT,
  extraction_state TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS documents (
  id TEXT PRIMARY KEY,
  source_id TEXT NOT NULL,
  filepath TEXT,
  filelink TEXT,
  hash_sha256 TEXT NOT NULL,
  indexed_text TEXT,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS document_versions (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL,
  version INTEGER NOT NULL,
  immutable_copy_path TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS document_segments (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL,
  segment_type TEXT NOT NULL,
  segment_text TEXT NOT NULL,
  start_offset INTEGER,
  end_offset INTEGER
);

CREATE TABLE IF NOT EXISTS txt_artifacts (
  txt_id TEXT PRIMARY KEY,
  tipo_txt TEXT NOT NULL,
  documento_id TEXT NOT NULL,
  processo_id TEXT,
  fonte_id TEXT NOT NULL,
  hash_documental TEXT NOT NULL,
  timestamp_geracao TEXT NOT NULL,
  versao INTEGER NOT NULL,
  motor_responsavel TEXT NOT NULL,
  estado TEXT NOT NULL,
  conteudo TEXT NOT NULL,
  metadados_json TEXT,
  log_tecnico TEXT
);

CREATE TABLE IF NOT EXISTS processes (
  id TEXT PRIMARY KEY,
  court_id TEXT,
  juizo TEXT,
  fase_processual TEXT,
  process_type TEXT,
  state TEXT,
  secrecy_level TEXT,
  score REAL NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS courts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  district TEXT,
  judge_seat TEXT
);

CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  process_id TEXT NOT NULL,
  event_date TEXT NOT NULL,
  event_type TEXT NOT NULL,
  description TEXT,
  source_document_id TEXT,
  impact TEXT
);

CREATE TABLE IF NOT EXISTS entities (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  nif_nipc TEXT,
  category TEXT,
  subcategory TEXT,
  role_processual TEXT
);

CREATE TABLE IF NOT EXISTS entity_relations (
  id TEXT PRIMARY KEY,
  source_entity_id TEXT NOT NULL,
  target_entity_id TEXT NOT NULL,
  relation_type TEXT NOT NULL,
  confidence REAL
);

CREATE TABLE IF NOT EXISTS facts (
  id TEXT PRIMARY KEY,
  process_id TEXT,
  source_document_id TEXT NOT NULL,
  extracted_fact TEXT NOT NULL,
  analytical_inference TEXT,
  legal_conclusion TEXT,
  provenance_json TEXT
);

CREATE TABLE IF NOT EXISTS vehicles (
  id TEXT PRIMARY KEY,
  plate TEXT NOT NULL,
  model TEXT,
  owner_entity_id TEXT
);

CREATE TABLE IF NOT EXISTS transfers (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL,
  from_entity_id TEXT,
  to_entity_id TEXT,
  transfer_date TEXT,
  source_document_id TEXT
);

CREATE TABLE IF NOT EXISTS risk_records (
  id TEXT PRIMARY KEY,
  process_id TEXT NOT NULL,
  probability REAL NOT NULL,
  impact REAL NOT NULL,
  criticality TEXT NOT NULL,
  score REAL NOT NULL,
  notation TEXT,
  aggravating_factors TEXT,
  mitigating_factors TEXT,
  source_refs_json TEXT
);

CREATE TABLE IF NOT EXISTS knowledge_items (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  structured_content TEXT,
  sources_json TEXT,
  confidence REAL
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  action TEXT NOT NULL,
  object_type TEXT NOT NULL,
  object_id TEXT,
  action_date TEXT NOT NULL,
  version_before TEXT,
  version_after TEXT
);

CREATE TABLE IF NOT EXISTS validation_records (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL,
  validator_id TEXT,
  status TEXT NOT NULL,
  notes TEXT,
  validated_at TEXT
);

CREATE TABLE IF NOT EXISTS tags (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  color_hex TEXT
);

CREATE TABLE IF NOT EXISTS attachments (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL,
  filename TEXT NOT NULL,
  filepath TEXT NOT NULL,
  mime_type TEXT
);

CREATE TABLE IF NOT EXISTS tabela_entidades AS SELECT * FROM entities WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_processos AS SELECT * FROM processes WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_factos AS SELECT * FROM facts WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_veiculos AS SELECT * FROM vehicles WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_transferencias AS SELECT * FROM transfers WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_documentos AS SELECT * FROM documents WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_eventos_processuais AS SELECT * FROM events WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_risco AS SELECT * FROM risk_records WHERE 0;
CREATE TABLE IF NOT EXISTS tabela_conhecimento AS SELECT * FROM knowledge_items WHERE 0;
