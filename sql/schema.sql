create table if not exists processos (
  processo_id text primary key,
  numero_processo text not null unique,
  referencia_interna text,
  tribunal text,
  juizo text,
  fase_processual text,
  estado text,
  grau_sigilo text,
  score_risco real default 0,
  resumo_executivo text
);

create table if not exists fontes (
  fonte_id text primary key,
  processo_id text not null,
  tipo_fonte text not null,
  origem text,
  filepath text,
  filelink text,
  hash_sha256 text not null,
  data_entrada text not null,
  estado_validacao text,
  foreign key (processo_id) references processos (processo_id)
);

create table if not exists documentos (
  documento_id text primary key,
  processo_id text not null,
  fonte_id text,
  tipo_documento text,
  titulo text,
  data_documento text,
  referencia text,
  filepath_original text,
  filepath_txt text,
  hash_sha256 text not null,
  estado_leitura text,
  texto_integral_indexado text,
  foreign key (processo_id) references processos (processo_id),
  foreign key (fonte_id) references fontes (fonte_id)
);

create table if not exists txt_registo (
  txt_id text primary key,
  documento_id text not null,
  tipo_txt text not null,
  caminho_txt text not null,
  versao text not null,
  timestamp text not null,
  hash_txt text not null,
  motor_responsavel text,
  foreign key (documento_id) references documentos (documento_id)
);

create table if not exists intervenientes (
  interveniente_id text primary key,
  nome text not null,
  tipo text,
  nif_nipc text,
  categoria text,
  observacoes text
);

create table if not exists ligacoes (
  ligacao_id text primary key,
  processo_id text not null,
  interveniente_origem text,
  interveniente_destino text,
  tipo_relacao text,
  descricao text,
  fonte_id text,
  documento_id text,
  grau_confianca real,
  foreign key (processo_id) references processos (processo_id),
  foreign key (fonte_id) references fontes (fonte_id),
  foreign key (documento_id) references documentos (documento_id)
);

create table if not exists eventos (
  evento_id text primary key,
  processo_id text not null,
  data_evento text not null,
  tipo_evento text not null,
  descricao text,
  documento_id_origem text,
  impacto_risco text,
  foreign key (processo_id) references processos (processo_id),
  foreign key (documento_id_origem) references documentos (documento_id)
);

create table if not exists riscos (
  risco_id text primary key,
  processo_id text not null,
  interveniente_id text,
  tipo_risco text not null,
  probabilidade real not null,
  impacto real not null,
  score_final real not null,
  notacao text,
  fontes_suporte text,
  recomendacao text,
  foreign key (processo_id) references processos (processo_id),
  foreign key (interveniente_id) references intervenientes (interveniente_id)
);

create table if not exists logs_auditoria (
  log_id text primary key,
  utilizador text not null,
  acao text not null,
  objeto_tipo text not null,
  objeto_id text not null,
  timestamp text not null,
  detalhe text,
  hash_estado text not null
);

create index if not exists idx_documentos_hash on documentos(hash_sha256);
create index if not exists idx_fontes_hash on fontes(hash_sha256);
create index if not exists idx_txt_documento on txt_registo(documento_id);
create index if not exists idx_eventos_processo_data on eventos(processo_id, data_evento);
create index if not exists idx_riscos_processo on riscos(processo_id);
