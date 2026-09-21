BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "chat_session" ADD COLUMN "answerOutcome" text;
ALTER TABLE "chat_session" ADD COLUMN "answerOutcomeConfidence" double precision;
CREATE INDEX "chat_session_answer_outcome" ON "chat_session" USING btree ("answerOutcome");

--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20260921194039239', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260921194039239', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();


COMMIT;
