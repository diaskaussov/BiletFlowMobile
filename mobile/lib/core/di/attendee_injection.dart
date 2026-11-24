import 'package:get_it/get_it.dart';

import '../error/result.dart';

import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/catalog/data/catalog_repository_impl.dart';
import '../../features/catalog/domain/catalog_domain.dart';
import '../../features/checkout/data/checkout_repository_impl.dart';
import '../../features/checkout/domain/checkout_domain.dart';
import '../../features/notifications/data/notifications_repository_impl.dart';
import '../../features/notifications/domain/notifications_domain.dart';
import '../../features/support/data/support_repository_impl.dart';
import '../../features/support/domain/support_domain.dart';
import '../../features/tickets/data/tickets_repository_impl.dart';
import '../../features/tickets/domain/tickets_domain.dart';

/// Участник (W1–W9) и общие для ролей фичи: поддержка, уведомления.
void configureAttendeeDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(sl()))
    ..registerLazySingleton<CheckoutRepository>(() => CheckoutRepositoryImpl(sl()))
    ..registerLazySingleton<TicketsRepository>(() => TicketsRepositoryImpl(sl()))
    ..registerLazySingleton<SupportRepository>(() => SupportRepositoryImpl(sl()))
    ..registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(sl()));

  sl
    ..registerLazySingleton(() => Register(sl()))
    ..registerLazySingleton(() => BrowseEvents(sl()))
    ..registerLazySingleton(() => GetEventPage(sl()))
    ..registerLazySingleton(() => GetEvent(sl()))
    ..registerLazySingleton(() => ApplyPromo(sl()))
    ..registerLazySingleton(() => LoadSeatMap(sl()))
    ..registerLazySingleton(() => HoldSeats(sl()))
    ..registerLazySingleton(() => ReleaseSeats(sl()))
    ..registerLazySingleton(() => PlaceOrder(sl()))
    ..registerLazySingleton(() => GetMyTickets(sl()))
    ..registerLazySingleton(() => GetOrderDetails(sl()))
    ..registerLazySingleton(() => GetTicket(sl()))
    ..registerLazySingleton(() => GetTicketFile(sl()))
    ..registerLazySingleton(() => CancelOrder(sl()))
    ..registerLazySingleton(() => GetMyCases(sl()))
    ..registerLazySingleton(() => GetCaseMessages(sl()))
    ..registerLazySingleton(() => OpenCase(sl()))
    ..registerLazySingleton(() => ReplyToCase(sl()))
    ..registerLazySingleton(() => GetCaseContexts(() async {
          final r = await sl<TicketsRepository>().myTickets();
          return switch (r) {
            Ok(:final value) => Ok([
                for (final t in value)
                  if (t.eventId != null) CaseContext(eventId: t.eventId!, eventTitle: t.eventTitle ?? 'Event #${t.eventId}', orderId: t.orderId),
              ]),
            Err(:final failure) => Err(failure),
          };
        }))
    ..registerLazySingleton(() => ChangeCaseStatus(sl()))
    ..registerLazySingleton(() => GetNotifications(sl()))
    ..registerLazySingleton(() => MarkNotificationRead(sl()));
}
