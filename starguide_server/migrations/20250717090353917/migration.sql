BEGIN;

--
-- ACTION ALTER TABLE
--
CREATE INDEX "rag_document_type" ON "rag_document" USING btree ("type");

--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20250717090353917', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250717090353917', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
