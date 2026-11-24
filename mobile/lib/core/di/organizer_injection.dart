import '../../features/organizer/presentation/managed_event_controller.dart';
import 'package:get_it/get_it.dart';

import '../../features/organizer/data/organizer_repositories_impl.dart';
import '../../features/organizer/domain/organizer_events_domain.dart';
import '../../features/organizer/domain/organizer_operations_domain.dart';
import '../../features/support/domain/support_domain.dart';

/// Организатор (O1–O10).
void configureOrganizerDependencies(GetIt sl) {
  sl
    ..registerLazySingleton(() => CampaignCodeStore(sl()))
    ..registerLazySingleton<OrganizerEventsRepository>(() => OrganizerEventsRepositoryImpl(sl()))
    ..registerLazySingleton<OrganizerOperationsRepository>(() => OrganizerOperationsRepositoryImpl(sl(), sl()));

  sl
    ..registerLazySingleton(() => GetOrganizerDashboard(sl()))
    ..registerLazySingleton(() => GetManagedEvent(sl()))
    ..registerLazySingleton(() => SaveEvent(sl()))
    ..registerLazySingleton(() => ChangeEventState(sl()))
    ..registerLazySingleton(() => ManageTicketTypes(sl()))
    ..registerLazySingleton(() => ManageSeatMap(sl()))
    ..registerLazySingleton(() => PaidSalesActivation(sl()))
    ..registerLazySingleton(() => ManageOrganizerProfile(sl()))
    ..registerLazySingleton(() => GetEventAttendees(sl()))
    ..registerLazySingleton(() => RefundOrder(sl()))
    ..registerLazySingleton(() => GetTimeline(sl()))
    ..registerLazySingleton(() => GetCheckInOverview(sl()))
    ..registerLazySingleton(() => GetSalesOverTime(sl()))
    ..registerLazySingleton(() => ManageCampaigns(sl()))
    ..registerLazySingleton(() => ManageStaff(sl()))
    ..registerLazySingleton(() => GetOrganizerInbox(sl(), sl<GetManagedEvent>().ids))
    ..registerLazySingleton(() => ManagedEventController(get: sl(), change: sl()));
}
