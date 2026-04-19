create extension if not exists pgcrypto;

create table if not exists runs (
  id uuid primary key,
  process_ref text not null,
  started_at timestamptz not null,
  status text not null
);

create table if not exists documents (
  id uuid primary key,
  process_ref text not null,
  file_name text not null,
  file_path text not null,
  sha256 text not null,
  size_bytes bigint not null,
  created_at timestamptz not null
);

create index if not exists idx_documents_sha256 on documents(sha256);

create table if not exists import_events (
  id uuid primary key,
  run_id uuid not null references runs(id),
  file_name text not null,
  status text not null,
  reason text,
  created_at timestamptz not null
);
