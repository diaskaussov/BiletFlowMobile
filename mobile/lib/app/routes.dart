abstract final class Routes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const events = '/events';
  static String eventSummary(int id) => '/events/$id';
  static const scanner = '/scan';
  static const result = '/scan/result';
  static const search = '/search';
  static String attendee(String id) => '/search/attendee/${Uri.encodeComponent(id)}';
  static const settings = '/settings';
  static const offline = '/offline';
}
