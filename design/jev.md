# Answering with Jev

## Goal

Today `ask()` in `starguide_endpoint.dart` runs two searches in parallel and
hands everything they find to Gemini for the final answer:

1. `searchDocumentation()` asks Gemini to return the five URLs from the table
   of contents most likely to answer the question. It is the slowest step and
   Gemini sometimes returns URLs that do not exist.
2. `searchByEmbedding()` rewrites the question with Gemini, embeds it, and
   loads the five closest discussions and blog posts from the vector database.
   That is two more Gemini calls on every question.

We replace the first step with Jev, TypeSafe's System One model, through the
`jev_dart` package, and let Jev decide whether the second step is needed at
all. After the answer is generated, Jev also judges whether the question was
answered, which is stored on the chat session and shown in the admin console.

Jev only answers typed questions (`choice`, `score`, `noul`) with calibrated
probabilities, so the table of contents must be handed to it as choice
options, not as prose.

## What Jev can do (from docs.typesafe.ai and the jev_dart source)

- `TypeSafeClient.systemOne(state:, questions:)` sends one `state` (a string,
  JSON object or array) and a map of named questions, and returns an answer
  per question. All questions in one request are evaluated in parallel.
- A `choice` question takes `criteria`, a map of option label to description
  (or `null`), and returns the single best `choice`, a `probabilities` map
  over every option that sums to 1, and a `confidence` in 0–1. It accepts
  **at most 255 options**. The docs recommend a `none of the above` option.
- A `noul` question returns one probability in 0–1 for a yes/no statement,
  optionally with descriptions of the true and false cases.
- Errors are typed (`ApiException`, `RateLimitException`,
  `ApiTimeoutException`, ...). The client retries 408/429/5xx twice with a
  10 s timeout per attempt and keeps a pooled HTTP/2 connection, so one
  client instance is reused for the life of the server and concurrent
  requests share the connection.
- The API key is read from the `typesafeAPIKey` password (already in
  `config/passwords.yaml`; on Serverpod Cloud it is set with
  `scloud password set typesafeAPIKey`).

## Sizing the table of contents

Counted from the sources configured in `setup_data_fetcher.dart`:

| Source | Type | Pages |
|---|---|---|
| Serverpod docs 4.0.0 | documentation | ~208 |
| Serverpod Cloud docs | documentation | ~76 |
| Relic docs | documentation | ~14 |
| serverpod.dev feature / for / compare | site | ~20 |
| **Total** | | **~320** |

The full list exceeds the 255-option cap, and it will grow, so the index is
split into groups. Grouping by data source (`domain` + `type`) is natural:
every group is well under the cap, and a group is the unit the admin console
already reports on. A group that ever passes 255 entries is split into
numbered chunks automatically.

## The new `ask()` flow

```
question
  │
  ├─ 1. pick pages ─────────── parallel Jev requests, one per index group,
  │                            plus one for the domain question
  │
  ├─ 2. load picked pages ──── one database query by id
  │
  ├─ 3. answer gate ────────── one Jev noul: do these pages answer it?
  │        │
  │        └─ no ───────────── searchByEmbedding() as today
  │                            (Gemini rewrite + embedding + vector query)
  │
  ├─ 4. generate answer ────── Gemini, streamed to the client, as today
  │
  └─ 5. answered? ──────────── one Jev choice: answered / not answered /
                               unsure, stored on the chat session
```

Steps 1 to 3 replace the two parallel searches. In the common case, when the
documentation covers the question, the two Gemini calls of the embedding
search are skipped. Step 5 runs after the last chunk has been streamed, so
it adds no latency for the user.

### Step 1: picking pages

One `systemOne` request per index group, and one for the domain question,
all sent at once with `Future.wait` over the shared HTTP/2 connection. Each
request is small, so this is faster than one request carrying the whole
index, and a slow or failed group does not hold back the others.

```
state (same for every request): {
  'conversation': [ {role, message}, ... previous turns ... ],
  'question': '<the new question>',
}

domain request:
  'domain': choice('Which product is the question about?', {
      'Serverpod framework': 'The open source Dart backend framework ...',
      'Serverpod Cloud':     'Hosting for Serverpod servers ...',
      'Relic':               'Low-level web server for Dart ...',
      'Serverpod website':   'Feature overviews and comparisons ...',
      'none':                'Not about any of these',
  })

one request per group, e.g. 'Serverpod framework':
  'page': choice('Which page most likely answers the question?', {
      'concepts/database/relations': 'Relations between models ...',
      ...
      'none': 'No page in this list answers the question',
  })
```

Ranking: a page's score is `P(domain) × P(page | domain)`, taken from the
probability maps. Pages are sorted by score across all groups and the top 5
(the current count) are loaded from the database by document id with one
`inSet` query, keeping Jev's order. `none` options are never loaded. A group
whose request fails is logged and skipped; if every request fails, the
embedding search runs unconditionally, as it does today.

Option labels are the source URL path relative to the source's reference URL
(for example `concepts/database/relations`), which is short, unique within a
group and readable by the model. The description is `title: shortDescription`.
The index keeps a map from group and label back to the document id.

Alternative kept in reserve: one `noul` question per page ("this page answers
the question"), which gives absolute scores that are directly comparable
across groups and has no 255 cap, at the cost of a larger payload. We try it
only if the choice-based ranking picks poorly.

### Step 3: the answer gate

After the picked pages are loaded:

```
state: {
  'conversation': [...],
  'question': '...',
  'pages': [ {title, url, content}, ... the picked pages ... ],
}

'answerable': noul('The pages contain the information needed to answer the question', {
  'true':  'A page states the answer or the steps to take',
  'false': 'The pages are only on a related topic, or the question is about '
           'a bug, an error message, or a case the documentation does not cover',
})
```

If the probability is at or above a threshold (start at 0.7, tune later),
the embedding search is skipped. Otherwise `searchByEmbedding()` runs and its
discussions and blog posts are appended after the picked pages. The
probability and the decision are logged with the timings, so the threshold
can be tuned from the logs.

Page content is sent in full but capped per page (start at 12 000
characters, roughly 3 000 tokens) so a handful of very long pages cannot
blow up the request. Whether the summaries alone are enough for the gate is
one of the things step 6 of the plan checks.

### Step 5: was the question answered?

After the answer has been streamed and the messages stored:

```
state: {
  'conversation': [...],
  'question': '...',
  'answer': '<the generated answer>',
}

'outcome': choice('Did the answer resolve the question?', {
  'answered':    'The answer directly addresses the question with concrete information',
  'notAnswered': 'The answer says the information is not available, asks the user '
                 'to look elsewhere, or does not address what was asked',
  'unsure':      'The answer is partial, hedged, or may be wrong',
})
```

The choice and its confidence are stored on the chat session. As with the
vote, the session holds the result of the latest turn, so a follow-up that
gets answered clears an earlier `notAnswered`. A failure in this step is
logged and leaves the fields null; it never fails the request.

## Cached document index

`DocsTableOfContents` currently caches one pre-formatted string
(`TableOfContents.contents`). It is replaced by a structured, serializable
model so the same cache serves Jev and the admin console.

New models in `lib/src/models/` (no database tables):

```yaml
### The table of contents handed to Jev, grouped into choice questions.
class: DocumentIndex
fields:
  generatedAt: DateTime
  groups: List<DocumentIndexGroup>

### One choice question: the pages of one data source.
class: DocumentIndexGroup
fields:
  ### Question name and label of the domain option, e.g. "Serverpod Cloud".
  ### Suffixed with a chunk number if a source exceeds the option cap.
  name: String
  domain: String
  type: RAGDocumentType
  entries: List<DocumentIndexEntry>
  ### UTF-8 bytes of the criteria map as sent to Jev.
  sizeInBytes: int

### One choice option.
class: DocumentIndexEntry
fields:
  documentId: int
  ### The option label, the URL path relative to the source.
  label: String
  title: String
  description: String
  sourceUrl: Uri
  sizeInBytes: int
```

`DocsTableOfContents` becomes `DocumentIndexCache` in
`lib/src/business/document_index.dart`:

- `get(session)` returns the cached `DocumentIndex`, building it on a miss
  from all `RAGDocument` rows of the included types, in batches as today.
  Same one-hour lifetime and the same invalidation from `DataFetcher` when a
  document of an included type is saved.
- `build(session)` groups documents by `(domain, type)`, derives labels,
  splits groups over 255 entries, and computes sizes with
  `utf8.encode(jsonEncode(criteria)).length`.
- `toQuestions(index)` turns the groups into the choice questions above, plus
  the domain question. This is the only place that knows the Jev format, so
  it is unit-testable without the network.
- `invalidate(session)` as today.

The generated `TableOfContents` model and `docs_table_of_contents.dart` are
removed.

## Chat session changes

`chat_session.spy.yaml` gets two nullable fields, which need a migration:

```yaml
### Jev's judgement of whether the latest answer resolved the question.
answerOutcome: AnswerOutcome?
### Jev's confidence in that judgement, 0–1.
answerOutcomeConfidence: double?
```

with a new enum `AnswerOutcome { answered, notAnswered, unsure }` and an
index on `answerOutcome` for the admin listing.

## Jev client

New `lib/src/generative_ai/jev.dart`:

- `Jev` wraps a single lazily created `TypeSafeClient` with the API key from
  `Serverpod.instance.getPassword('typesafeAPIKey')`, and a log adapter that
  forwards to `session.log` at debug level.
- `pickDocuments(session, index, conversation, question, {count = 5})` runs
  the parallel requests of step 1 and returns the ordered document ids with
  their scores.
- `canAnswer(session, conversation, question, documents)` runs the gate of
  step 3 and returns the probability.
- `judgeAnswer(session, conversation, question, answer)` runs step 5 and
  returns the outcome and confidence.
- Each method logs token usage and timing. Errors are wrapped in
  `GenerativeAiException` like the Gemini calls, and the callers decide what
  to do: skip a group, run the embedding search, or leave the outcome null.

If the `typesafeAPIKey` password is missing, the server logs a warning at
startup, `pickDocuments` returns nothing, the embedding search always runs,
and the outcome stays null. So the server still answers, just as it does
without the documentation search.

`searchDocumentation()` and `searchByEmbedding()` stay as the two building
blocks in `search.dart`, and `ask()` orchestrates them with the gate in
between. The Gemini `generateUrlList()` and the `search_toc.txt` prompt are
removed. The MCP endpoint's `ask-docs` calls `searchDocumentation()` only and
keeps doing so; it gets the Jev page picking without the gate or the outcome.

## Admin console

### Document Index

New sidebar entry **Document Index** under *Data*, backed by two endpoint
methods on `AdminEndpoint`:

- `getDocumentIndex()` returns the cached `DocumentIndex` wrapped in
  `AdminDocumentIndex` with `cachedSince`, `expiresAt`, `groupCount`,
  `entryCount`, `totalSizeInBytes`, and `estimatedTokens` (bytes / 4, as a
  rough guide). Reading through the cache means the admin sees exactly what
  Jev is sent.
- `rebuildDocumentIndex()` invalidates the cache and returns the fresh index.

The view (`starguide_flutter/lib/admin/views/admin_document_index_view.dart`,
built with the existing `AdminStatCard`, `AdminTableCard`, `AdminViewHeader`
and `DocumentTypeBadge` widgets):

1. Stat cards: entries, groups, total size, estimated tokens, generated at,
   with a *Rebuild* button next to *Refresh*.
2. Groups table: name, domain, type, entries, size, and a warning badge if a
   source needed splitting.
3. Selecting a group opens a sheet listing its entries: label, title,
   description and size, with a search field, and a link to the source URL.
   Each entry also links to the existing document sheet by id.
4. A *Preview payload* tab in the sheet shows the criteria JSON of that group
   as sent to Jev, in a monospace scroll view.

Sizes are formatted with a new `formatBytes()` in `admin_format.dart`.

### Unanswered questions

New sidebar entry **Unanswered** under *Insights*, next to *Poor Answers*.
It lists the chat sessions whose latest outcome is `notAnswered`, with a
toggle to include `unsure`, newest first, and opens the same conversation
sheet as *Poor Answers*.

- `listChatSessions()` gets an `AnswerOutcome? outcome` filter and
  `AdminChatSessionSummary` gets the `answerOutcome` and
  `answerOutcomeConfidence` fields, so the *Poor Answers* list can show an
  outcome badge too and the two views share the table.
- `AdminOverview` and `VoteStats` get `notAnsweredCount` and `unsureCount`
  for the last week and month, shown as two extra stat cards on the
  overview. `DailyStats` is left alone for now.

## Steps

1. Add the `DocumentIndex` models, run `serverpod generate`, and write
   `document_index.dart` with the builder, cache and `toQuestions()`.
   Unit tests: grouping, label derivation, uniqueness of labels within a
   group, splitting at 255, size computation, `none` option present.
2. Add `jev.dart` with the three methods and switch `searchDocumentation()`
   to `pickDocuments`. Delete the Gemini URL list code and prompt. Integration
   test with `withServerpod`, a few seeded documents and a fake HTTP client
   for `TypeSafeClient` (it accepts an `httpClient`), asserting that the
   returned documents follow the probabilities and that a failed group is
   skipped.
3. Restructure `ask()` around the gate, and add the outcome judgement after
   the answer. Add the chat session fields and enum, create and apply the
   migration.
4. Add the admin endpoint methods and models for the document index and the
   outcome filter, run `serverpod generate`, and build the two Flutter views
   and the overview cards.
5. Update `README.md`: the `typesafeAPIKey` password in the passwords
   example and the Serverpod Cloud instruction, a line on Jev in the
   introduction, and the new admin sections.
6. Run the server locally, ask a handful of questions from past chat sessions
   in the *Poor Answers* list, and compare the picked pages, the gate
   decisions, the outcomes and the `ask()` timings in the logs against the
   current version. Tune the gate threshold and the content cap from that.

## Open points

- The `analyzer` override in the workspace `pubspec.yaml` is needed because
  `jev_dart` depends on `crimson`, which pins an old analyzer. It stays until
  crimson is updated.
- The exact page scoring, `P(domain) × P(page | domain)` versus a per-page
  noul, is decided by the comparison in step 6. Both are cheap to swap
  because `toQuestions()` and the ranking live in one file.
- The gate sends page content to Jev, which is the largest Jev payload in the
  flow. The TypeSafe docs give no size limit for `state`. If the cost or
  latency is too high, the gate can be run on the page summaries instead.
- The gate serialises what used to run in parallel: the embedding search now
  starts only after the page picking and the gate. When the gate says no, a
  question is slower than today by the time of steps 1 to 3. That should be
  well under the time of the Gemini URL call it replaces, but step 6 checks.
- The 5-page limit, the gate threshold and the content cap are constants in
  `jev.dart` to tune after step 6.

## Results of step 6 (2026-09-21)

Measured on the local server with the index freshly built (248 pages in 4
groups). The first question includes building the index and opening the
HTTP/2 connection.

| Question | Pick pages | Gate | Embedding search | Total |
|---|---|---|---|---|
| Google sign-in setup | 1.7 s | 0.6 s, 97% yes | skipped | 13.7 s |
| Deploy to Serverpod Cloud | 0.8 s | 0.3 s, 98% yes | skipped | 7.9 s |
| Middleware in Relic | 0.5 s | 0.8 s, 93% yes | skipped | 9.0 s |
| Crash with error 42P01 after upgrade | 0.5 s | 0.4 s, 36% no | 4.3 s | 15.4 s |

- Jev picked the right domain with 94–100% confidence every time, and the
  top page was the obvious one (the Google setup page, the Cloud launch
  guide, the Relic middleware reference, the migrations page).
- The gate skipped the embedding search for the three documentation
  questions, which saves the two Gemini calls of the question rewrite and
  the embedding, 4.3 s in the fourth question.
- The outcome judgement takes 0.3–0.5 s after the answer has been streamed.
- Generating the answer with Gemini is now by far the largest part of the
  time.
- The token count of the picking requests grows with the conversation,
  because the whole conversation is sent in every group request: 17k input
  tokens for the first question of a session, 43k for the fourth. If cost
  matters, send only the latest turns, or only the user's questions, as the
  state of the picking requests.
- The Gemini URL picking it replaces was not measured side by side; it was
  the slowest step of `ask()` before, so no baseline is recorded here.
