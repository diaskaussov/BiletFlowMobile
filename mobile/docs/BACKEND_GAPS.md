# What the mobile app needs from the backend

Checked on 22 Nov 2026 against the running backend (Swagger `/v3/api-docs`, 70 endpoints)
while building every role of the mobile app: attendee (W1–W9), organizer (O1–O10),
event admin scanner (A–C) and platform admin (P1–P2).

Everything below has a fallback in the app: the screen either hides the part or says
plainly that it is not available. Nothing is faked.

## 🔴 Critical

### 1. Password hashes and tokens leak in responses
`GET /api/admin/users` and `GET /api/organizer/profile` (inside `user`) return
`password` (bcrypt hash), `verificationToken`, `resetPasswordToken`, `resetPasswordExpiry`.
Return a DTO without these fields. The app ignores them, but any client can read them.

### 2. Staff can only be assigned by user ID (O10)
`POST /api/staff/assign { eventId, userId }` — an organizer has no way to find a user's ID.
Needed: `POST /api/staff/assign { eventId, email }` (preferred) or
`GET /api/users/lookup?email=` for organizers. The app currently asks for a numeric ID.

### 3. No password reset (SRS §4.1)
The `User` model already has `resetPasswordToken` and `resetPasswordExpiry`. Needed:
`POST /api/auth/forgot-password { email }` and `POST /api/auth/reset-password { token, password }`.

### 4. Platform admin queues are mostly missing (SRS §4.12, P1)
| Needed | Why |
|---|---|
| Event reports: `POST /api/events/{id}/report { reason }` for attendees, `GET /api/admin/reports` | "Reported events" queue and P2 report list |
| `GET /api/admin/activations`, `POST /api/admin/activations/{id}/approve` | "Activation reviews" queue |
| `GET /api/admin/support/cases`, assign + reply | Organizer → platform cases are created but nobody can see them |
| `POST /api/admin/events/{id}/unsuspend` | Suspension cannot be undone |
| A `suspended` flag on events | After suspend the event looks unchanged (status stays as it was) |
| `POST /api/admin/events/{id}/refund-all` | P2 "Suspend event and refund all" |
| Admin read access to `GET /api/analytics/events/{id}/timeline` | Returns 400 for PLATFORM_ADMIN; SRS §4.16 says admins may read it |
| Reports export, activation fee settings | P1 sidebar |
| A reason body on suspend endpoints | Reason is required by the UI but cannot be stored |

## 🟡 Screens are reduced without these

5. **Analytics double-counts refunds.** After refunding an 8 000 ₸ order the event shows
   `grossRevenue 0, totalRefunds 8000, netRevenue -8000`. Either gross should still include
   the sale or refunds should not be subtracted again.
6. **Campaigns (O8, W3):** `GET /api/promo/campaigns/event/{id}` does not return the promo
   `code` or the `campaignLink` — only the create response does. The app remembers codes of
   campaigns created on the same device. Also missing: applicable ticket types, editing.
7. **Staff (O10):** no gate, no "reverse permission" flag, no per-staff stats, no invitations.
8. **Orders (W5):** no processing charge, no per-ticket attendee names, no phone.
   Attendees can only `cancel`; there is no refund request.
9. **O5:** no "resend tickets".
10. **O2:** no image upload — only an `imageUrl` field.
11. **W1:** `/api/events/public` has no search, filters or minimum price; the app filters on the
    phone and loads ticket types per event to show "from" prices.
12. **Duplicated events lose their dates** (`eventDate` etc. become `null`) — fine for a draft,
    but worth confirming it is intended.

## 🟢 Small

13. **Timestamps without a zone.** `createdAt`, `checkedInAt`, `heldUntil` are UTC but sent as
    `2026-11-22T11:11:58` with no `Z`. The app treats them as UTC; event dates are treated as
    venue-local. Sending ISO-8601 with an offset removes the guesswork.
14. `POST /api/orders/{id}/cancel` response is not documented in Swagger.
15. `API_GUIDE.md` is out of date: it does not mention `verdict` in the scan response,
    attendee search, manual check-in by ticket ID, or the undo `reason` body.
