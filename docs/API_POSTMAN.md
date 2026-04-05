# Backend API — Postman collection

Use the **KaamSathi_web** Postman collection as the live reference for request shapes, auth headers, and edge cases when updating this Flutter client.

## Collection file

| Location | Path |
|----------|------|
| Same parent folder as this repo (typical monorepo layout) | `../KaamSathi_web/postman/KaamSathi_API.postman_collection.json` |
| Absolute (example) | `/Users/sahsantoshh/Documents/Projects/kaam_sathi/KaamSathi_web/postman/KaamSathi_API.postman_collection.json` |

Import the JSON file into Postman (or another HTTP client that supports the format).

## Workers & org context

- **Create or link:** `POST /api/v1/workers` with `Authorization` (JWT) and **`X-Organization-Id`** set to the target organization.
- **Who can call:** **Admin** or **manager** memberships (the API’s `require_manager!` path treats admin like manager).
- **Behavior:** Creates a **Worker** and an **Engagement** for that org (default engagement status is typically **onboarding** unless you send an `engagement` object in the body). Linking an existing worker uses root `worker_id` per the collection.
- **Hire lookup:** `GET /api/v1/workers/search` returns **`matches`:** `[{ user_id, email, data }]` (`data` = worker JSON or `null`). You may send **`phone_e164`**, **`email`**, or **both** (union of users). See Postman: **Search by phone + email (union)**.

See the **Workers** folder in the collection for: nested `user` / contractee-style linking, search (**phone**, **email**, or both), multipart `worker[user][avatar]`, optional root **`engagement`** on **PATCH**, **DELETE** only when engagement has no org history, **422** `worker_has_org_history`, and work assignments / terminate / re-hire notes.

## Flutter-oriented doc

Higher-level app behavior (headers, pagination, route mapping) is described in:

`KaamSathi_web/docs/flutter_app.md`
