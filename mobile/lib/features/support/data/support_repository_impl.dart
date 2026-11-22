import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/request_guard.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/data/models.dart';
import '../../../shared/domain/entities/support.dart';
import '../domain/support_domain.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<SupportCaseInfo>>> myCases() =>
      guard(() async => jsonList(await _api.get('/api/support/cases/my')).map(Models.supportCase).toList());

  @override
  Future<Result<List<SupportCaseInfo>>> eventCases(int eventId) => guard(() async =>
      jsonList(await _api.get('/api/support/cases/event/$eventId')).map(Models.supportCase).toList());

  @override
  Future<Result<List<SupportMessageInfo>>> messages(int caseId) => guard(() async =>
      jsonList(await _api.get('/api/support/cases/$caseId/messages')).map(Models.supportMessage).toList());

  @override
  Future<Result<SupportCaseInfo>> open(NewCase r) => guard(() async {
        final j = jsonObject(await _api.post('/api/support/cases', body: {
          'category': r.category.wire,
          'subject': r.subject,
          'message': r.message,
          'eventId': ?r.eventId,
          'orderId': ?r.orderId,
        }));
        return Models.supportCase(j);
      });

  @override
  Future<Result<SupportMessageInfo>> reply(int caseId, String text) => guard(() async =>
      Models.supportMessage(jsonObject(await _api.post('/api/support/cases/$caseId/messages', body: {'message': text}))));

  @override
  Future<Result<void>> setStatus(int caseId, CaseStatus status) =>
      guard(() => _api.patch('/api/support/cases/$caseId/status', body: {'status': status.wire}));
}
