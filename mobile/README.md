# BiletFlow (mobile)

One Flutter app for every BiletFlow role. After sign-in the router opens the section
for the account's role:

| Role | Screens | Source design |
|---|---|---|
| Attendee | W1–W9: events, event page, promo codes and Campaign QR, seat map, checkout (sandbox), tickets with QR / PDF / print / calendar, orders, support | design system of `TicketTon.pen` |
| Organizer | M-B1–M-B8: my events, event screen with section chips (overview, tickets, seat map, orders with refund sheet, promo, staff, sales activation, history, check-in), notifications, support inbox | `TicketTon.pen` |
| Event admin | A1–A9: sign in, my events, scanner, full-screen results, guests, guest record, reversal, statistics, offline, settings | `TicketTon.pen` |
| Platform admin | queues, events and moderation, users (M-B13), orders | `TicketTon.pen` |

Design: Inter, primary `#6D4AFF`, Lucide icons, rounded cards and a floating tab bar;
light and dark themes (system by default). Colors live in `AppPalette`
(`context.colors`), never in widgets. Attendees and organizers can register in the app;
event staff are assigned by organizers.

## Languages

Russian (default), Kazakh and English — strings in `lib/l10n/app_{ru,kk,en}.arb`,
generated with `flutter gen-l10n`. Language and theme are switched in Profile / Settings
and remembered on the device. Domain errors carry a `code`; `failureText()` turns it into
the current language.

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
  app/        root widget, router with role guard, per-role routes and tabs
  core/       config, DI (get_it, one file per role), errors (Failure / Result),
              network (Dio + request log), Loadable view-model base, theme, widgets
  shared/     entities and JSON models used by several roles (events, orders,
              tickets, seats, campaigns, support, analytics)
  features/<feature>/
    domain/        entities, repository interfaces, use cases — pure Dart
    data/          JSON models, data sources, repository implementations
    presentation/  ViewModels (ChangeNotifier + provider), pages, widgets
```

Features:

- all roles — `auth` (sign-in, registration), `account`, `notifications`, `support`
- attendee — `catalog` (W1–W3), `checkout` (W4–W5), `tickets` (W6–W8)
- organizer — `organizer` (O1–O10)
- event admin — `events` (A2–A4), `connection` (A5), `settings` (A6),
  `checkin` (B1–B10, C4), `attendees` (C1–C3)
- platform admin — `admin` (P1–P2)

Dependencies point inward only: presentation → use case → repository interface,
and `core/di/*_injection.dart` is the only place where a data implementation is
bound to its interface.

Key rules live in use cases and are unit-tested:

- `VerifyTicket` — campaign QR codes and foreign codes are refused on the phone
  and never sent as tickets (§4.14); the same valid code within 10 s is a repeat (B6),
  not a second check-in; with no connection verification is blocked, not queued (A5).
- `SignIn` / `Register` — any known role signs in; only attendees and organizers
  can register themselves.
- `UndoCheckIn` — a reason is required.
- `PlaceOrder` — tickets are issued only after the sandbox confirms payment; an
  expired seat hold blocks the order.
- `HoldSeats` — exactly one seat per ticket in the cart, per ticket type.
- `ChangeEventState` — an event cannot be published without a ticket type.
- `RefundOrder`, `ModerationActions` — reasons are required; admins cannot suspend
  themselves or other admins.

## Backend

Everything is checked against the running backend; its Swagger (`/v3/api-docs`) is richer
than `API_GUIDE.md`. What is still missing — and how each screen degrades — is in
[`docs/BACKEND_GAPS.md`](docs/BACKEND_GAPS.md).

Server timestamps (`createdAt`, `checkedInAt`, `heldUntil`) come in UTC without a zone and
are converted to local time; event dates are venue-local and are shown as is.

## Tests

```bash
flutter test                                   # unit and widget tests
flutter test integration_test/all_screens_test.dart -d <simulator-id>
```

The integration test signs in as each demo account, opens every screen of every role with
live data and fails on any exception or layout overflow. It needs the backend running with
the demo data used during development.

## Not done yet

- Kazakh texts were written without a native-speaker review.
- Deep links for Campaign QR (`https://biletflow.kz/events/{id}?promo=`) — attendees scan
  campaign codes from the Events tab instead.
- Gate name is stored on the device (Settings → Assigned gate); the API has no gates.
- A4 breakdown by ticket type, rejected and reversed counts come from this
  device's shift log, because `/checkin/stats` only returns three totals.
- Campaign links (`https://…?promo=`) are refused on the phone; a bare promo code
  is sent to the server, which answers `PROMO_CODE` with the campaign details.
