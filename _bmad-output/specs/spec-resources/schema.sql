-- ============================================================================
-- Closed CRAS — resources context
-- Database: cras_resources
-- PostgreSQL: 18.6
--
-- Model only: this file is the DDL contract, not a provisioning step.
-- It targets database cras_resources when the environment already provides it.
-- Validate or apply against an existing database:
--   psql -v ON_ERROR_STOP=1 -d cras_resources -f schema.sql
--
-- Tag model: resource_tags (1NF). The API still exchanges tags as a set.
-- No inventory_items table is created: InventoryItem is replaced by Occurrence.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Enums
--
-- These blocks build a fresh database. Against an existing database, a new
-- value is added with ALTER TYPE <name> ADD VALUE '<VALUE>' (PostgreSQL 12+).
-- The transaction must commit before the new value is used; the API enum and
-- the OpenAPI contract are updated in the same release.
-- ----------------------------------------------------------------------------

CREATE TYPE resource_type AS ENUM (
  'PROJECTOR',
  'HEALTH_KIT',
  'COMPUTER',
  'NOTEBOOK',
  'CAMERA',
  'MICROPHONE',
  'DISPLAY',
  'CABLE',
  'ADAPTER'
);

CREATE TYPE occurrence_type AS ENUM (
  'MALFUNCTION',
  'DAMAGE',
  'MISSING',
  'OTHER'
);

CREATE TYPE occurrence_status AS ENUM ('OPEN', 'RESOLVED');

CREATE TYPE occurrence_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- ----------------------------------------------------------------------------
-- Tag guard
--
-- At most 10 tags per resource. Uniqueness comes from the primary key
-- (resource_id, tag); this trigger carries the per-resource cardinality rule.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION enforce_resource_tags_max()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT count(*) FROM resource_tags WHERE resource_id = NEW.resource_id) >= 10 THEN
    RAISE EXCEPTION 'a resource may have at most 10 tags';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- resources
-- ----------------------------------------------------------------------------

CREATE TABLE resources (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code        VARCHAR(32) NOT NULL,
  name        VARCHAR(120) NOT NULL,
  type        resource_type NOT NULL,
  active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT resources_code_unique UNIQUE (code),
  CONSTRAINT resources_code_upper CHECK (code = upper(code)),
  CONSTRAINT resources_code_format CHECK (code ~ '^[A-Z0-9]+(-[A-Z0-9]+)*$'),
  CONSTRAINT resources_code_length CHECK (char_length(code) BETWEEN 3 AND 32),
  CONSTRAINT resources_name_not_blank CHECK (btrim(name) <> '')
);

-- ----------------------------------------------------------------------------
-- resource_tags
--
-- 1NF model for the multivalued tag attribute. 0-10 rows per resource.
-- Dependent data: deleting a resource removes its tags (never done by the API;
-- occurrences keep ON DELETE RESTRICT).
-- ----------------------------------------------------------------------------

CREATE TABLE resource_tags (
  resource_id UUID NOT NULL REFERENCES resources(id) ON DELETE CASCADE,
  tag         VARCHAR(30) NOT NULL,

  PRIMARY KEY (resource_id, tag),
  CONSTRAINT resource_tags_tag_not_blank CHECK (btrim(tag) <> ''),
  CONSTRAINT resource_tags_tag_lower CHECK (tag = lower(tag)),
  CONSTRAINT resource_tags_tag_format CHECK (tag ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  CONSTRAINT resource_tags_tag_length CHECK (char_length(tag) BETWEEN 1 AND 30)
);

CREATE TRIGGER trg_resource_tags_max
BEFORE INSERT ON resource_tags
FOR EACH ROW EXECUTE FUNCTION enforce_resource_tags_max();

-- ----------------------------------------------------------------------------
-- occurrences
-- ----------------------------------------------------------------------------

CREATE TABLE occurrences (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id  UUID NOT NULL,
  description  TEXT NOT NULL,
  type         occurrence_type NOT NULL,
  priority     occurrence_priority NOT NULL DEFAULT 'MEDIUM',
  status       occurrence_status NOT NULL DEFAULT 'OPEN',
  resolution   TEXT,
  reported_by  UUID NOT NULL,
  resolved_by  UUID,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at  TIMESTAMPTZ,
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT occurrences_resource_fk FOREIGN KEY (resource_id)
    REFERENCES resources(id) ON DELETE RESTRICT,
  CONSTRAINT occurrences_description_not_blank CHECK (btrim(description) <> ''),
  CONSTRAINT occurrences_resolved_at_consistent CHECK (
    (status = 'RESOLVED' AND resolved_at IS NOT NULL)
    OR (status <> 'RESOLVED' AND resolved_at IS NULL)
  ),
  CONSTRAINT occurrences_resolution_matches_status CHECK (
    (status = 'RESOLVED' AND resolution IS NOT NULL AND btrim(resolution) <> '')
    OR (status <> 'RESOLVED' AND resolution IS NULL)
  ),
  CONSTRAINT occurrences_resolved_by_matches_status CHECK (
    (status = 'RESOLVED' AND resolved_by IS NOT NULL)
    OR (status <> 'RESOLVED' AND resolved_by IS NULL)
  ),
  CONSTRAINT occurrences_resolved_after_created CHECK (
    resolved_at IS NULL OR resolved_at >= created_at
  )
);

-- ----------------------------------------------------------------------------
-- Indexes
-- ----------------------------------------------------------------------------

CREATE INDEX idx_resources_active_type ON resources (active, type);
CREATE INDEX idx_resource_tags_tag ON resource_tags (tag);
CREATE INDEX idx_occurrences_resource_status ON occurrences (resource_id, status);
CREATE INDEX idx_occurrences_resource_created_at ON occurrences (resource_id, created_at DESC);
CREATE INDEX idx_occurrences_status_priority ON occurrences (status, priority);

-- ----------------------------------------------------------------------------
-- updated_at triggers
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_resources_updated_at
BEFORE UPDATE ON resources
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_occurrences_updated_at
BEFORE UPDATE ON occurrences
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ----------------------------------------------------------------------------
-- Resource.code immutability
--
-- The API never accepts code on PATCH; this trigger is the database backstop.
-- SQLSTATE P0001 (raise_exception).
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_resource_code_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.code IS DISTINCT FROM OLD.code THEN
    RAISE EXCEPTION 'resources.code is immutable';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_resources_code_immutable
BEFORE UPDATE OF code ON resources
FOR EACH ROW EXECUTE FUNCTION prevent_resource_code_change();

-- ----------------------------------------------------------------------------
-- Occurrence lifecycle
--
-- Legal transition: OPEN -> RESOLVED only. RESOLVED is terminal: no reopen,
-- no edit-after-resolve, no intermediate state.
--
-- Two triggers cooperate:
--   trg_occurrences_terminal_state refuses any UPDATE of a RESOLVED row;
--   trg_occurrences_transitions refuses any illegal status change.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_resolved_occurrence_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status = 'RESOLVED' THEN
    RAISE EXCEPTION 'resolved occurrences are immutable';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_occurrences_terminal_state
BEFORE UPDATE ON occurrences
FOR EACH ROW
WHEN (OLD.status = 'RESOLVED')
EXECUTE FUNCTION prevent_resolved_occurrence_change();

CREATE OR REPLACE FUNCTION prevent_illegal_occurrence_transition()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status = 'OPEN' AND NEW.status = 'RESOLVED' THEN
    RETURN NEW;
  END IF;
  RAISE EXCEPTION 'illegal occurrence transition % -> %', OLD.status, NEW.status;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_occurrences_transitions
BEFORE UPDATE OF status ON occurrences
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION prevent_illegal_occurrence_transition();

-- ----------------------------------------------------------------------------
-- Occurrence identity immutability
--
-- resource_id and reported_by are set at create and never change. reported_by
-- is the audit actor taken from the JWT employeeId claim; the API never accepts
-- it in a request body. SQLSTATE P0001 (raise_exception).
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_occurrence_identity_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.resource_id IS DISTINCT FROM OLD.resource_id THEN
    RAISE EXCEPTION 'occurrences.resource_id is immutable';
  END IF;
  IF NEW.reported_by IS DISTINCT FROM OLD.reported_by THEN
    RAISE EXCEPTION 'occurrences.reported_by is immutable';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_occurrences_identity_immutable
BEFORE UPDATE OF resource_id, reported_by ON occurrences
FOR EACH ROW EXECUTE FUNCTION prevent_occurrence_identity_change();

-- ----------------------------------------------------------------------------
-- Deletion policy
--
-- No API deletes resources or occurrences. The FK above is RESTRICT, so a
-- database-level delete of a resource with occurrences is refused. active=false
-- is the retirement path; history stays in occurrences.
-- ----------------------------------------------------------------------------

COMMIT;
