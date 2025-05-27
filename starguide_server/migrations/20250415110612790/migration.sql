BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_message" (
    "id" bigserial PRIMARY KEY,
    "chatSessionId" bigint NOT NULL,
    "message" text NOT NULL,
    "type" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_session" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint,
    "keyToken" text NOT NULL
);


--
-- MIGRATION VERSION FOR starguide
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('starguide', '20250415110612790', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250415110612790', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
