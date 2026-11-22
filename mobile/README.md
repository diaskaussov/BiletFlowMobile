# BiletFlow Scanner (mobile)

Flutter app for event admins: sign in, pick an assigned event, scan ticket QR codes,
check attendees in by name and reverse check-ins (SRS §4.8, UC4).
Screens A1–A6, B1–B10 and C1–C4 follow `BiletFlow Mobile Screens.html` and
`BiletFlow Mobile Spec.dc.html` in the repository root. D1–D2 are the organizer's
mobile web view and belong to the web app (SRS §8 excludes native organizer apps).

## Run

```bash
flutter pub get
flutter run                      # iOS simulator: backend at http://localhost:8080
```

On a real phone the app must reach the computer running the backend over Wi-Fi:

```bash
flutter run --dart-define=API_BASE_URL=http://$(ipconfig getifaddr en0):8080
```

When the app is started from Xcode (no `--dart-define`), tap **Server → CHANGE**
at the bottom of the sign-in screen and enter the computer's IP, e.g.
`10.70.62.248` — the port defaults to 8080 and the address is remembered.
iOS asks for Local Network access on the first request: allow it.

Backend: `docker compose up --build` in the backend repo, then sign in as
`eventadmin@biletflow.kz` / `123`. Only `EVENT_ADMIN` accounts can use the scanner.

Every request is logged to the console in debug builds:

```
[API] GET /api/staff/my-events Request sent → http://10.70.62.248:8080
[API] GET /api/staff/my-events Request SUCCESS httpCode(200)
[API] POST /api/checkin/scan Request FAILED httpCode(500)
[API] POST /api/auth/login Request FAILED no response (connectionError)
```

```bash
flutter analyze
flutter test
```

## Architecture

Clean Architecture, feature-first:

```
lib/
  app/        root widget, routes (go_router), bottom tabs
  core/       config, DI (get_it), errors (Failure / Result), network (Dio),
              theme tokens, shared widgets
  features/<feature>/
    domain/        entities, repository interfaces, use cases — pure Dart
    data/          JSON models, data sources, repository implementations
    presentation/  ViewModels (ChangeNotifier + provider), pages, widgets
```

Features: `auth` (A1), `events` (A2–A4), `connection` (A5), `settings` (A6),
`checkin` (B1–B10, C4), `attendees` (C1–C3).

Dependencies point inward only: presentation → use case → repository interface,
and `core/di/injection.dart` is the single place where a data implementation is
bound to its interface.

Key rules live in use cases and are unit-tested:

- `VerifyTicket` — campaign QR codes and foreign codes are refused on the phone
  and never sent as tickets (§4.14); the same valid code within 10 s is a repeat (B6),
  not a second check-in; with no connection verification is blocked, not queued (A5).
- `SignIn` — only `EVENT_ADMIN` may sign in.
- `UndoCheckIn` — a reason is required.

## Backend contract used

Checked against the running backend (Swagger at `/swagger-ui.html`), which is richer
than `API_GUIDE.md`:

| Screen | Endpoint |
|---|---|
| A1 | `POST /api/auth/login` |
| A2–A3 | `GET /api/staff/my-events` → `[{ id, event: {...}, user }]` |
| A4, scanner header | `GET /api/checkin/stats/{eventId}` |
| B4–B10 | `POST /api/checkin/scan { ticketCode, eventId }` → `verdict` = `OK / ALREADY_USED / CANCELLED / REFUNDED / WRONG_EVENT / NOT_FOUND / PROMO_CODE` |
| C1–C3 | `GET /api/checkin/events/{eventId}/attendees?q=`, `POST /api/checkin/tickets/{ticketId}` |
| C4 | `POST /api/checkin/undo/{ticketId} { reason }` |

Server timestamps (`checkedInAt`) come in UTC without a zone and are converted to
local time; event dates are venue-local and are shown as is.

Still missing: password reset ("Forgot password" tells staff to ask the organizer)
and order history for C3 (the History block is hidden when empty).

## Not done yet

- Russian and Kazakh localization (planned last).
- Gate name is stored on the device (Settings → Assigned gate); the API has no gates.
- A4 breakdown by ticket type, rejected and reversed counts come from this
  device's shift log, because `/checkin/stats` only returns three totals.
- Campaign links (`https://…?promo=`) are refused on the phone; a bare promo code
  is sent to the server, which answers `PROMO_CODE` with the campaign details.
