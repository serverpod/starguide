# Starguide
Starguide is a full-stack application built with Serverpod, featuring a Dart server backend and a Flutter frontend. It allows you to ask any questions about Serverpod and uses AI to semantically search the documentation and GitHub discussions, which is stored in a vector database. Try it out here:

__[Starguide app](https://starguide.serverpod.space)__

The server connects to Gemini through [Dartantic](https://pub.dev/packages/dartantic_ai), which makes it easy to switch out models without modifying the code. It uses Serverpod's ORM to interact with the Postgres database (with the PgVector extension for storing the vectors/embeddings).

Quickstart
A few steps are required to get Starguide working on your local machine:

1. Create a GitHub personal access token, as Starguide will use it to load the documentation pages and discussions into the database. Sign in to GitHub and visit [this settings page](https://github.com/settings/personal-access-tokens). (Settings > Developer Settings > Personal access tokens > Fine-grained personal access tokens.) Create a new token. It doesn't need to have any specific permissions, as all the information Starguide is requesting is public. Save the token.
2. Get a Gemini key from [here](https://aistudio.google.com/app/apikey). The free tier should be fine, but it may work better on a paid plan, as the free tier is rate-limited.
3. Optionally, get a key for reCAPTCHA (this is only required if you deploy your server to production). You will need to do this in a new project on GCP. Find the setup page [here](https://console.cloud.google.com/security/recaptcha).

When you have the required tokens and API keys, you must add them to a new `starguide_server/config/passwords.yaml` file. This is what the passwords file should look like:

```yaml
# config/passwords.yaml

# Save passwords used across all configurations here.
shared:
  geminiAPIKey: '<Gemini API key>'
  githubToken: '<GitHub token>'
  recaptchaSecretKey: '<reCAPTCHA secret>' # Optional for local development

# These are passwords used when running the server locally in development mode
development:
  database: 'KG3uoH8yvl2TBJGZWYA6Pw5ToPV0FwRP'
  redis: 'cv62dn4dCyCL8NZEWjJYZNDjOKXQzQqH'

  # The service secret is used to communicate between servers and to access the
  # service protocol.
  serviceSecret: '-bqxtPOy79-V1xjYZBm3BX-UzgSFZBlo'

test:
  database: '9mPvLeV-d_p6P8DsoZDhiPB_l_BlvGeq'
  redis: 'xDbf-Z9dVvEZo2iMx2tDMLRbZDsq-Wdq'

# IMPORTANT! Replace the staging and production passwords if you deploy the
# server or share this file.

# Passwords used in your staging environment if you use one. The default setup
# use a password for Redis.
staging:
  database: 'icekXsg1yYju_XS6fa-y3lrzA0H4ULpu'
  serviceSecret: 'I4Todv2g1xj2r7HMq-t2DkSS45RtPi8r'

# Passwords used in production mode.
production:
  database: 'clrVprd2XfLN-KZDEzVa8XVX4mjcRDI8'
  serviceSecret: '71d7N3Zwfg7vVp3ac69uacSw0SYD8qG9'

```

With the passwords in place, you should be able to start the server by running:

```bash
cd starguide_server
docker compose up --detach
dart bin/main.dart --apply-migrations
```

When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop Postgres and Redis:

```bash
docker compose stop
```

Start the local Flutter app by running:

```bash
cd starguide_flutter
flutter run
```