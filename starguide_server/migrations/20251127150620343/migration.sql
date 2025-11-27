BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "rag_document_vector";
ALTER TABLE "rag_document" DROP COLUMN "embedding";

--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20251127150620343', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251127150620343', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20250825102336032-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250825102336032-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20250825102351908-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250825102351908-v3-0-0', "timestamp" = now();


COMMIT;
