BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "rag_document" DROP COLUMN "type";

--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20250716130218016', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250716130218016', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
