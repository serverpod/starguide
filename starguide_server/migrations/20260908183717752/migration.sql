BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "daily_stats" (
    "id" bigserial PRIMARY KEY,
    "day" timestamp without time zone NOT NULL,
    "sessionCount" bigint NOT NULL,
    "goodAnswerCount" bigint NOT NULL,
    "poorAnswerCount" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "daily_stats_day" ON "daily_stats" USING btree ("day");


--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20260908183717752', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260908183717752', "timestamp" = now();

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
    VALUES ('serverpod_auth_idp', '20260824182405944', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182405944', "timestamp" = now();


COMMIT;
