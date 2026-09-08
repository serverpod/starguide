# Starguide

Starguide is a full-stack application built with Serverpod, featuring a Dart server backend and a Flutter frontend. It allows you to ask any questions about Serverpod and uses AI to semantically search the documentation and GitHub discussions, which is stored in a vector database. Try it out here:

__[Starguide app](https://starguide.serverpod.space)__

The server connects to Gemini through [Dartantic](https://pub.dev/packages/dartantic_ai), which makes it easy to switch out models without modifying the code. It uses Serverpod's ORM to interact with the Postgres database (with the PgVector extension for storing the vectors/embeddings).

Quickstart
A few steps are required to get Starguide working on your local machine:

1. Create a GitHub personal access token, as Starguide will use it to load the documentation pages and discussions into the database. Sign in to GitHub and visit [this settings page](https://github.com/settings/personal-access-tokens). (Settings > Developer Settings > Personal access tokens > Fine-grained personal access tokens.) Create a new token. It doesn't need to have any specific permissions, as all the information Starguide is requesting is public. Save the token.
2. Get a Gemini key from [here](https://aistudio.google.com/app/apikey). The free tier should be fine, but it may work better on a paid plan, as the free tier is rate-limited.
3. Optionally, get a key for reCAPTCHA (this is only required if you deploy your server to production). You will need to do this in a new project on GCP. Find the setup page [here](https://console.cloud.google.com/security/recaptcha).
4. Optionally, set up Google sign-in, which lets users who fail the reCAPTCHA check sign in instead. Create a web application OAuth client in the [Google Cloud console](https://console.cloud.google.com/auth/clients), add `<web app origin>/googlesignin` as an authorized redirect URI, download the client JSON, and save it as `starguide_server/config/google_client_secret.json`. Without this file, the server runs with Google sign-in disabled.

When you have the required tokens and API keys, you must add them to a new `starguide_server/config/passwords.yaml` file. This is what the passwords file should look like:

```yaml
# config/passwords.yaml

# Save passwords used across all configurations here.
shared:
  geminiAPIKey: '<Gemini API key>'
  githubToken: '<GitHub token>'
  recaptchaSecretKey: '<reCAPTCHA secret>' # Optional for local development

# These are passwords used when running the server locally in development mode.
# Use your own random strings for all of these. The database password is used
# by the embedded Postgres database.
development:
  database: '<random string>'
  redis: '<random string>'

  # The service secret is used to communicate between servers and to access the
  # service protocol.
  serviceSecret: '<random string>'

  # Secrets used by the JWT token manager of the auth module.
  jwtRefreshTokenHashPepper: '<random string>'
  jwtHmacSha512PrivateKey: '<random string of at least 64 bytes>'

test:
  database: '<random string>'
  redis: '<random string>'

  # Secrets used by the JWT token manager of the auth module.
  jwtRefreshTokenHashPepper: '<random string>'
  jwtHmacSha512PrivateKey: '<random string of at least 64 bytes>'

# Passwords used in your staging and production environments, if you deploy
# the server yourself. Serverpod Cloud manages these as secrets instead.
staging:
  database: '<random string>'
  serviceSecret: '<random string>'
  jwtRefreshTokenHashPepper: '<random string>'
  jwtHmacSha512PrivateKey: '<random string of at least 64 bytes>'

production:
  database: '<random string>'
  serviceSecret: '<random string>'
  jwtRefreshTokenHashPepper: '<random string>'
  jwtHmacSha512PrivateKey: '<random string of at least 64 bytes>'
```

Users who sign in with a Google account on the serverpod.dev domain are granted the admin scope. For them, an _Admin_ button appears next to _View Source_ in the app. It opens the admin interface, which shows an overview of the loaded sources and how answers are rated, lets you inspect every document used to answer questions, and lists the conversations where the answer was rated poor. Note that the scope is included in the token from the second sign-in on, as it is granted when the account is created.

With the passwords in place, you should be able to start the server, its embedded Postgres database, and the Flutter app by running:

```bash
cd starguide_server
serverpod start
```

Press `M` in the `serverpod start` terminal to create and apply database migrations. When you are finished, shut everything down with `Ctrl-C`.

The Flutter app reads the URL of the API server from `starguide_flutter/assets/config.json`, which points at the local server. When the app is served by the Serverpod web server, the server provides that file with the URL of its own API server instead. To build the web app and serve it from the server at [http://localhost:8082](http://localhost:8082), run:

```bash
cd starguide_server
serverpod run flutter_build
```
