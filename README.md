# kaamsathi

A comprehensive digital solution that bridges the gap between daily wage workers and organizations, enabling transparent wage tracking, attendance management, and streamlined payment processing

## Backend API reference

Request examples and the **Workers** API (create/link, hire **search** with **`matches`**, PATCH engagement, DELETE rules) stay in sync with the backend repo’s Postman export:

- [docs/API_POSTMAN.md](docs/API_POSTMAN.md) — path to `KaamSathi_API.postman_collection.json` and short notes.

### Documentation workflow

When you change a **Rails** API used by this app:

1. Update **`KaamSathi_web/postman/KaamSathi_API.postman_collection.json`** (request URLs, bodies, and folder descriptions).
2. Update **`KaamSathi_web/docs/flutter_app.md`** — especially **§8** (endpoint table) and **§17** (suggested Flutter routes).
3. Update Flutter **DTOs / repositories** and UI, then run **`flutter analyze`** (and `flutter gen-l10n` if strings changed).

The in-app **`/search`** screen filters orgs, sites, and roster workers **client-side**; manager **hire** uses **`GET /workers/search`** (see Postman **Workers** folder).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
