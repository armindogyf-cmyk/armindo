-- CP Clássicos — ERD / PostgreSQL baseline
-- Version: 1.0.0
-- Principle: entity != evidence != assertion != source
-- Traceability: Fault -> WorkOrder -> Part/Procedure -> Evidence -> Source

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TYPE record_status AS ENUM ('DRAFT','QUARANTINE','CANDIDATE','CONFIRMED','REJECTED','SUPERSEDED','ARCHIVED');
CREATE TYPE source_grade AS ENUM ('A','B','C','D');
CREATE TYPE work_order_status AS ENUM ('DRAFT','TECHNICAL_REVIEW','APPROVED','IN_PROGRESS','QA','CLOSED','BLOCKED','CANCELLED');
CREATE TYPE severity_level AS ENUM ('LOW','MEDIUM','HIGH','CRITICAL');
CREATE TYPE diagnostic_node_type AS ENUM ('SYMPTOM','HYPOTHESIS','TEST','OBSERVATION','CONCLUSION','CORRECTIVE_ACTION');
CREATE TYPE diagnostic_edge_type AS ENUM ('SUPPORTS','CONTRADICTS','TESTS','NEXT_IF_TRUE','NEXT_IF_FALSE','RESOLVED_BY');
CREATE TYPE assertion_status AS ENUM ('QUARANTINE','CANDIDATE','CONFIRMED','REJECTED','SUPERSEDED');
CREATE TYPE evidence_kind AS ENUM ('PHOTO','DOCUMENT','SCAN','MEASUREMENT','SCREENSHOT','VIDEO','AUDIO','OTHER');
CREATE TYPE line_type AS ENUM ('LABOR','PART','TOOL','CONSUMABLE','OTHER');

CREATE TABLE projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  owner_name text,
  status record_status NOT NULL DEFAULT 'DRAFT',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  cp_vehicle_code text NOT NULL UNIQUE,
  vin text,
  registration text,
  manufacturer text NOT NULL,
  model text NOT NULL,
  generation text,
  model_year integer,
  market text,
  type_approval text,
  status record_status NOT NULL DEFAULT 'DRAFT',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_vehicle_vin ON vehicles(vin);
CREATE INDEX idx_vehicle_registration ON vehicles(registration);

CREATE TABLE vehicle_configurations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  engine_code text,
  engine_family text,
  displacement_cc integer,
  fuel_type text,
  gearbox_code text,
  gearbox_type text,
  abs_variant text,
  emissions_variant text,
  ecu_hw text,
  ecu_sw text,
  valid_from date,
  valid_to date,
  status record_status NOT NULL DEFAULT 'QUARANTINE',
  confidence numeric(5,2) CHECK (confidence BETWEEN 0 AND 100),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE systems (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  parent_id uuid REFERENCES systems(id) ON DELETE SET NULL,
  sort_order integer NOT NULL DEFAULT 0
);

CREATE TABLE parts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cp_part_id text NOT NULL UNIQUE,
  system_id uuid NOT NULL REFERENCES systems(id),
  subsystem text,
  component_name text NOT NULL,
  position text,
  nature text,
  safety_class text,
  criticality severity_level,
  theoretical_qty numeric(10,2),
  unit text,
  status record_status NOT NULL DEFAULT 'QUARANTINE',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_parts_component ON parts USING gin (to_tsvector('simple', component_name));

CREATE TABLE part_identifiers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  part_id uuid NOT NULL REFERENCES parts(id) ON DELETE CASCADE,
  brand text NOT NULL,
  part_number citext NOT NULL,
  identifier_type text NOT NULL CHECK (identifier_type IN ('OEM','IAM','SUPPLIER','INTERNAL')),
  market text,
  catalogue text,
  catalogue_version text,
  status record_status NOT NULL DEFAULT 'QUARANTINE',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (brand, part_number, market)
);
CREATE INDEX idx_part_number ON part_identifiers(part_number);

CREATE TABLE sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_code text NOT NULL UNIQUE,
  issuer text NOT NULL,
  name text NOT NULL,
  grade source_grade NOT NULL,
  kind text,
  uri text,
  licence text,
  permitted_use text,
  reviewed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE source_assertions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id uuid NOT NULL REFERENCES sources(id),
  subject_type text NOT NULL,
  subject_id uuid NOT NULL,
  predicate text NOT NULL,
  value_json jsonb NOT NULL,
  confidence numeric(5,2) CHECK (confidence BETWEEN 0 AND 100),
  status assertion_status NOT NULL DEFAULT 'QUARANTINE',
  checked_by text,
  checked_at timestamptz,
  supersedes_id uuid REFERENCES source_assertions(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_assertion_subject ON source_assertions(subject_type, subject_id);
CREATE INDEX idx_assertion_predicate ON source_assertions(predicate);

CREATE TABLE part_fitments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  part_id uuid NOT NULL REFERENCES parts(id),
  part_identifier_id uuid REFERENCES part_identifiers(id),
  vehicle_configuration_id uuid NOT NULL REFERENCES vehicle_configurations(id),
  fitment_status assertion_status NOT NULL DEFAULT 'QUARANTINE',
  confidence numeric(5,2) CHECK (confidence BETWEEN 0 AND 100),
  market text,
  notes text,
  source_assertion_id uuid REFERENCES source_assertions(id),
  reviewed_by text,
  reviewed_at timestamptz,
  UNIQUE(part_id, vehicle_configuration_id, part_identifier_id)
);

CREATE TABLE suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  country_code char(2),
  contact_email citext,
  contact_phone text,
  rating numeric(3,2),
  status record_status NOT NULL DEFAULT 'CANDIDATE'
);

CREATE TABLE offers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id uuid NOT NULL REFERENCES suppliers(id),
  part_identifier_id uuid NOT NULL REFERENCES part_identifiers(id),
  price numeric(12,2),
  currency char(3),
  availability text,
  lead_time_days integer,
  quoted_at timestamptz,
  expires_at timestamptz,
  source_uri text
);

CREATE TABLE faults (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid NOT NULL REFERENCES vehicles(id),
  fault_code text NOT NULL UNIQUE,
  symptom text NOT NULL,
  description text,
  severity severity_level NOT NULL,
  status record_status NOT NULL DEFAULT 'DRAFT',
  opened_at timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz
);

CREATE TABLE diagnostic_cases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fault_id uuid NOT NULL REFERENCES faults(id) ON DELETE CASCADE,
  version integer NOT NULL DEFAULT 1,
  status record_status NOT NULL DEFAULT 'DRAFT',
  root_cause text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(fault_id, version)
);

CREATE TABLE diagnostic_nodes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  diagnostic_case_id uuid NOT NULL REFERENCES diagnostic_cases(id) ON DELETE CASCADE,
  node_type diagnostic_node_type NOT NULL,
  title text NOT NULL,
  body text,
  expected_value jsonb,
  actual_value jsonb,
  unit text,
  sequence integer,
  status record_status NOT NULL DEFAULT 'DRAFT'
);

CREATE TABLE diagnostic_edges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  diagnostic_case_id uuid NOT NULL REFERENCES diagnostic_cases(id) ON DELETE CASCADE,
  from_node_id uuid NOT NULL REFERENCES diagnostic_nodes(id) ON DELETE CASCADE,
  to_node_id uuid NOT NULL REFERENCES diagnostic_nodes(id) ON DELETE CASCADE,
  edge_type diagnostic_edge_type NOT NULL,
  label text,
  UNIQUE(from_node_id, to_node_id, edge_type)
);

CREATE TABLE procedures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  procedure_code text NOT NULL,
  title text NOT NULL,
  system_id uuid REFERENCES systems(id),
  version text NOT NULL,
  objective text,
  applicability jsonb,
  risk_level severity_level,
  status record_status NOT NULL DEFAULT 'DRAFT',
  author text,
  reviewer text,
  published_at timestamptz,
  UNIQUE(procedure_code, version)
);

CREATE TABLE procedure_steps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  procedure_id uuid NOT NULL REFERENCES procedures(id) ON DELETE CASCADE,
  sequence integer NOT NULL,
  phase text,
  title text NOT NULL,
  objective text,
  instruction text NOT NULL,
  warning text,
  acceptance_criteria text,
  next_step_id uuid REFERENCES procedure_steps(id),
  UNIQUE(procedure_id, sequence)
);

CREATE TABLE tools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_code text NOT NULL UNIQUE,
  name text NOT NULL,
  serial_number text,
  calibration_due date,
  software_version text,
  status record_status NOT NULL DEFAULT 'CONFIRMED'
);

CREATE TABLE procedure_step_tools (
  step_id uuid NOT NULL REFERENCES procedure_steps(id) ON DELETE CASCADE,
  tool_id uuid NOT NULL REFERENCES tools(id),
  required boolean NOT NULL DEFAULT true,
  quantity numeric(10,2) NOT NULL DEFAULT 1,
  note text,
  PRIMARY KEY(step_id, tool_id)
);

CREATE TABLE procedure_step_parts (
  step_id uuid NOT NULL REFERENCES procedure_steps(id) ON DELETE CASCADE,
  part_id uuid NOT NULL REFERENCES parts(id),
  required_status assertion_status NOT NULL DEFAULT 'CONFIRMED',
  quantity numeric(10,2) NOT NULL DEFAULT 1,
  note text,
  PRIMARY KEY(step_id, part_id)
);

CREATE TABLE procedure_step_checks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  step_id uuid NOT NULL REFERENCES procedure_steps(id) ON DELETE CASCADE,
  prompt text NOT NULL,
  response_type text NOT NULL CHECK(response_type IN ('BOOLEAN','TEXT','NUMBER','CHOICE','PHOTO','MEASUREMENT')),
  required boolean NOT NULL DEFAULT true,
  expected_value jsonb
);

CREATE TABLE evidence_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES projects(id),
  vehicle_id uuid REFERENCES vehicles(id),
  kind evidence_kind NOT NULL,
  original_filename text NOT NULL,
  mime_type text NOT NULL,
  sha256 char(64) NOT NULL UNIQUE,
  object_uri text NOT NULL,
  captured_at timestamptz,
  uploaded_at timestamptz NOT NULL DEFAULT now(),
  width integer,
  height integer,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  immutable boolean NOT NULL DEFAULT true
);

CREATE TABLE annotations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id uuid NOT NULL REFERENCES evidence_assets(id) ON DELETE CASCADE,
  geometry_type text NOT NULL CHECK(geometry_type IN ('POINT','BOX','POLYGON')),
  geometry jsonb NOT NULL,
  label text NOT NULL,
  part_id uuid REFERENCES parts(id),
  confidence numeric(5,2) CHECK(confidence BETWEEN 0 AND 100),
  created_by text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE evidence_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id uuid NOT NULL REFERENCES evidence_assets(id) ON DELETE CASCADE,
  subject_type text NOT NULL,
  subject_id uuid NOT NULL,
  relation text NOT NULL,
  note text,
  UNIQUE(asset_id, subject_type, subject_id, relation)
);

CREATE TABLE procedure_evidence_requirements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  step_id uuid NOT NULL REFERENCES procedure_steps(id) ON DELETE CASCADE,
  evidence_kind evidence_kind NOT NULL,
  required boolean NOT NULL DEFAULT true,
  description text NOT NULL
);

CREATE TABLE work_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_code text NOT NULL UNIQUE,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id),
  fault_id uuid REFERENCES faults(id),
  procedure_id uuid REFERENCES procedures(id),
  status work_order_status NOT NULL DEFAULT 'DRAFT',
  odometer_km integer,
  responsible text,
  workshop text,
  opened_at timestamptz NOT NULL DEFAULT now(),
  approved_at timestamptz,
  closed_at timestamptz,
  total_cost numeric(12,2) NOT NULL DEFAULT 0,
  qa_result text
);

CREATE TABLE work_order_lines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_id uuid NOT NULL REFERENCES work_orders(id) ON DELETE CASCADE,
  line_type line_type NOT NULL,
  part_id uuid REFERENCES parts(id),
  tool_id uuid REFERENCES tools(id),
  description text NOT NULL,
  quantity numeric(10,2) NOT NULL DEFAULT 1,
  unit_cost numeric(12,2),
  total_cost numeric(12,2) GENERATED ALWAYS AS (quantity * COALESCE(unit_cost,0)) STORED
);

CREATE TABLE work_order_step_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_id uuid NOT NULL REFERENCES work_orders(id) ON DELETE CASCADE,
  step_id uuid NOT NULL REFERENCES procedure_steps(id),
  completed boolean NOT NULL DEFAULT false,
  result_json jsonb,
  completed_by text,
  completed_at timestamptz,
  UNIQUE(work_order_id, step_id)
);

CREATE TABLE recall_campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_ref text NOT NULL,
  manufacturer text NOT NULL,
  title text,
  risk text,
  source_id uuid NOT NULL REFERENCES sources(id),
  status record_status NOT NULL DEFAULT 'CANDIDATE',
  UNIQUE(manufacturer, campaign_ref)
);

CREATE TABLE vehicle_recall_status (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid NOT NULL REFERENCES vehicles(id),
  campaign_id uuid REFERENCES recall_campaigns(id),
  checked_at timestamptz NOT NULL,
  result text NOT NULL,
  evidence_asset_id uuid REFERENCES evidence_assets(id),
  checked_by text
);

CREATE TABLE audit_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  action text NOT NULL,
  before_hash text,
  after_hash text,
  correlation_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX idx_audit_entity ON audit_events(entity_type, entity_id, created_at DESC);

-- Guard rail: no automatic engineering truth from low-grade sources.
-- Application service MUST prevent part_fitments.fitment_status='CONFIRMED'
-- unless at least one accepted SourceAssertion of adequate grade exists.
-- Database policy/RLS implementation belongs in migrations/security after IAM design is finalised.
