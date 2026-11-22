# BiletFlow Scanner (mobile)

Flutter app for event admins: sign in, pick an assigned event, scan ticket QR codes,
check attendees in by name and reverse check-ins (SRS §4.8, UC4).
Screens A1–A6, B1–B10 and C1–C4 follow `BiletFlow Mobile Screens.html` and
`BiletFlow Mobile Spec.dc.html` in the repository root. D1–D2 are the organizer's
mobile web view and belong to the web app (SRS §8 excludes native organizer apps).

## Run

```bash
flutter pub get

# iOS simulator: the backend on this Mac is reachable as localhost
flutter run

# Android emulator: the default is http://10.0.2.2:8080
flutter run

# Real phone: point to the Mac's LAN address
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Backend: `docker compose up --build` in the backend repo, then sign in as
`eventadmin@biletflow.kz` / `123`. Only `EVENT_ADMIN` accounts can use the scanner.

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

## What the backend still needs to provide

The app reads these fields when they appear; until then the matching UI degrades
gracefully.

1. **`POST /api/checkin/scan` response.** Needed: `ticketId` (without it a check-in
   cannot be reversed from the app, §4.8), `status`
   (`VALID / USED / REFUNDED / CANCELLED`), `checkedInAt`, `checkedInBy`, `seat`,
   `orderNumber`, and `event { id, title, eventDate, venueName }` for the wrong-event
   screen. Right now verdicts are inferred from the `message` text. The request
   also sends `eventId` so the server can reject tickets for another event.
2. **Attendee search for `EVENT_ADMIN`** (§4.8 "Search for attendees manually"),
   for example `GET /api/checkin/events/{eventId}/attendees?q=` returning orders
   with tickets, plus manual check-in by ticket id. **C1–C3 run on mock data**
   (`AttendeesMockRepository`) until this exists.
3. **Reversal reason.** `POST /api/checkin/undo/{ticketId}` takes no body; the
   app requires a reason but cannot send it yet.
4. **Response shape of `GET /api/staff/my-events`** is undocumented; the app accepts
   a plain event, `{ id, event: {...} }` or `{ eventId, eventTitle }`.
5. **Password reset** has no endpoint; "Forgot password" tells staff to ask the organizer.

## Not done yet

- Russian and Kazakh localization (planned last).
- Gate name is stored on the device (Settings → Assigned gate); the API has no gates.
- A4 breakdown by ticket type, rejected and reversed counts come from this
  device's shift log, because `/checkin/stats` only returns three totals.
