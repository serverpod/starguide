BEGIN;

--
-- CREATE VECTOR EXTENSION IF AVAILABLE
--
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'vector') THEN
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS vector';
  ELSE
    RAISE EXCEPTION 'Required extension "vector" is not available on this instance. Please install pgvector. For instructions, see https://docs.serverpod.dev/upgrading/upgrade-to-pgvector.';
  END IF;
END
$$;

--
-- ACTION DROP TABLE
--
DROP TABLE "rag_document" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "rag_document" (
    "id" bigserial PRIMARY KEY,
    "embedding" vector(1536) NOT NULL,
    "fetchTime" timestamp without time zone NOT NULL,
    "sourceUrl" text NOT NULL,
    "content" text NOT NULL,
    "summary" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "rag_docuement_sourceUrl" ON "rag_document" USING btree ("sourceUrl");
CREATE INDEX "rag_document_vector" ON "rag_document" USING hnsw ("embedding" vector_cosine_ops);


--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20250527125831912', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250527125831912', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
