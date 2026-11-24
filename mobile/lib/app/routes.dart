import '../features/auth/domain/entities/user_session.dart';

abstract final class Routes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const offline = '/offline';

  // — сотрудник на входе (EVENT_ADMIN), экраны A–C —
  static const events = '/events';
  static const scanner = '/scan';
  static const result = '/scan/result';
  static const search = '/search';
  static String attendee(String id) => '/search/attendee/${Uri.encodeComponent(id)}';
  static const settings = '/settings';
  static const stats = '/stats';

  // — участник (ATTENDEE), экраны W1–W9 —
  static const catalog = '/a';
  static String publicEvent(int id, {String? promo}) =>
      '/a/e/$id${promo == null ? '' : '?promo=${Uri.encodeQueryComponent(promo)}'}';
  static String seats(int eventId) => '/a/e/$eventId/seats';
  static const checkout = '/a/checkout';
  static String order(int id) => '/a/orders/$id';
  static const myTickets = '/a/tickets';
  static String ticket(int id) => '/a/tickets/$id';
  static const attendeeSupport = '/a/support';
  static const attendeeAccount = '/a/account';

  // — организатор (ORGANIZER), экраны O1–O10 —
  static const organizer = '/o';
  static const newEvent = '/o/new';
  static String manageEvent(int id) => '/o/e/$id';
  static String editEvent(int id) => '/o/e/$id/edit';
  static String ticketTypes(int id) => '/o/e/$id/tickets';
  static String seating(int id) => '/o/e/$id/seating';
  static String activation(int id) => '/o/e/$id/activate';
  static String eventAttendees(int id) => '/o/e/$id/attendees';
  static String eventOrder(int id, int orderId) => '/o/e/$id/orders/$orderId';
  static String analytics(int id) => '/o/e/$id/analytics';
  static String campaigns(int id) => '/o/e/$id/campaigns';
  static String history(int id) => '/o/e/$id/history';
  static String staff(int id) => '/o/e/$id/staff';
  static const organizerSupport = '/o/support';
  static const organizerProfile = '/o/profile';
  static const organizerAccount = '/o/account';
  static const organizerNotifications = '/o/notifications';

  // — админ платформы (PLATFORM_ADMIN), экраны P1–P2 —
  static const adminQueues = '/p';
  static const adminEvents = '/p/events';
  static String adminEvent(int id) => '/p/events/$id';
  static const adminUsers = '/p/users';
  static const adminOrders = '/p/orders';
  static const adminAccount = '/p/account';

  // — общие для нескольких ролей —
  static String supportCase(String base, int id) => '$base/$id';
  static String newSupportCase(String base) => '$base/new';
  static String notifications(String accountBase) => '$accountBase/notifications';

  /// Стартовый экран после входа.
  static String home(UserRole role) => switch (role) {
        UserRole.eventAdmin => events,
        UserRole.attendee => catalog,
        UserRole.organizer => organizer,
        UserRole.platformAdmin => adminQueues,
        UserRole.unknown => signIn,
      };

  /// Куда роли можно заходить. Всё остальное отправляет на её главную.
  static bool allowed(UserRole role, String location) {
    if (location == offline) return true;
    bool under(String p) => location == p || location.startsWith('$p/');
    return switch (role) {
      UserRole.eventAdmin => [events, scanner, search, settings, stats].any(under),
      UserRole.attendee => under(catalog),
      UserRole.organizer => under(organizer),
      UserRole.platformAdmin => under(adminQueues),
      UserRole.unknown => false,
    };
  }
}
