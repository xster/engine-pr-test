# engine_pr_test

Queries the flutter/engine GitHub repo via v4 GraphQL APIs to check how many
PRs have tests (by rudimentary regex).

Run via `dart lib/query.dart` which will update the result files in `data`.
