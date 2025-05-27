BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "rag_document" (
    "id" bigserial PRIMARY KEY,
    "fetchTime" timestamp without time zone NOT NULL,
    "sourceUrl" text NOT NULL,
    "content" text NOT NULL,
    "summary" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "rag_docuement_sourceUrl" ON "rag_document" USING btree ("sourceUrl");


--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20250527090941392', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250527090941392', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
