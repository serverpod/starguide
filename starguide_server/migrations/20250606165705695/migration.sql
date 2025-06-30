BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "rag_docuement_sourceUrl";
CREATE UNIQUE INDEX "rag_document_sourceUrl" ON "rag_document" USING btree ("sourceUrl");

--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20250606165705695', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250606165705695', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
