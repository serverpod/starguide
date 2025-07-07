BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "chat_session" ADD COLUMN "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP;

--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20250707154315916', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250707154315916', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
