import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/support.dart';

class NewCase {
  const NewCase({
    required this.category,
    required this.subject,
    required this.message,
    this.eventId,
    this.orderId,
  });

  final CaseCategory category;
  final String subject;
  final String message;
  final int? eventId;
  final int? orderId;
}

/// Событие, к которому участник может привязать обращение.
class CaseContext {
  const CaseContext({required this.eventId, required this.eventTitle, this.orderId});

  final int eventId;
  final String eventTitle;
  final int? orderId;
}

abstract interface class SupportRepository {
  /// Обращения, которые открыл текущий пользователь.
  Future<Result<List<SupportCaseInfo>>> myCases();

  /// Обращения по событию — для организатора (§4.13).
  Future<Result<List<SupportCaseInfo>>> eventCases(int eventId);

  Future<Result<List<SupportMessageInfo>>> messages(int caseId);

  Future<Result<SupportCaseInfo>> open(NewCase request);

  Future<Result<SupportMessageInfo>> reply(int caseId, String text);

  Future<Result<void>> setStatus(int caseId, CaseStatus status);
}

List<SupportCaseInfo> _newestFirst(List<SupportCaseInfo> list) => [...list]
  ..sort((a, b) => (b.updatedAt ?? b.createdAt ?? DateTime(0)).compareTo(a.updatedAt ?? a.createdAt ?? DateTime(0)));

class GetMyCases {
  const GetMyCases(this._repo);

  final SupportRepository _repo;

  Future<Result<List<SupportCaseInfo>>> call() async {
    final r = await _repo.myCases();
    return switch (r) {
      Ok(:final value) => Ok(_newestFirst(value)),
      Err(:final failure) => Err(failure),
    };
  }
}

/// Входящие организатора: обращения участников по всем его событиям и
/// его собственные обращения к платформе.
class GetOrganizerInbox {
  const GetOrganizerInbox(this._repo, this._myEventIds);

  final SupportRepository _repo;
  final Future<Result<List<int>>> Function() _myEventIds;

  Future<Result<List<SupportCaseInfo>>> call() async {
    final ids = await _myEventIds();
    if (ids case Err(:final failure)) return Err(failure);
    final results = await Future.wait([
      _repo.myCases(),
      for (final id in ids.valueOrNull!) _repo.eventCases(id),
    ]);
    final all = <int, SupportCaseInfo>{};
    for (final r in results) {
      if (r case Err(:final failure)) return Err(failure);
      for (final c in r.valueOrNull!) {
        all[c.id] = c;
      }
    }
    return Ok(_newestFirst(all.values.toList()));
  }
}

class GetCaseMessages {
  const GetCaseMessages(this._repo);

  final SupportRepository _repo;

  Future<Result<List<SupportMessageInfo>>> call(int caseId) async {
    final r = await _repo.messages(caseId);
    return switch (r) {
      Ok(:final value) => Ok([...value]..sort((a, b) =>
          (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)))),
      Err(:final failure) => Err(failure),
    };
  }
}

/// UC9: обращение с категорией и контекстом события или заказа.
///
/// [requireContext] — для участника: обращение без события не видит ни один
/// организатор (API отдаёт организатору только обращения по его событиям),
/// а SRS §4.13 открывает обращение участника со страницы события или заказа.
class OpenCase {
  const OpenCase(this._repo);

  final SupportRepository _repo;

  Future<Result<SupportCaseInfo>> call(NewCase request, {bool requireContext = false}) async {
    if (requireContext && request.eventId == null && request.orderId == null) {
      return const Err(ValidationFailure('Choose the event this is about, so its organizer gets the case.', code: 'caseEvent'));
    }
    if (request.subject.trim().length < 3) {
      return const Err(ValidationFailure('Describe the problem in a few words.', code: 'caseSubject'));
    }
    if (request.message.trim().isEmpty) {
      return const Err(ValidationFailure('Write a message for support.', code: 'caseMessage'));
    }
    return _repo.open(NewCase(
      category: request.category,
      subject: request.subject.trim(),
      message: request.message.trim(),
      eventId: request.eventId,
      orderId: request.orderId,
    ));
  }
}

/// События из билетов участника — варианты для привязки обращения.
class GetCaseContexts {
  const GetCaseContexts(this._load);

  final Future<Result<List<CaseContext>>> Function() _load;

  Future<Result<List<CaseContext>>> call() async {
    final r = await _load();
    return switch (r) {
      Ok(:final value) => Ok({for (final c in value) c.eventId: c}.values.toList()),
      Err(:final failure) => Err(failure),
    };
  }
}

class ReplyToCase {
  const ReplyToCase(this._repo);

  final SupportRepository _repo;

  Future<Result<SupportMessageInfo>> call(int caseId, String text) async {
    if (text.trim().isEmpty) return const Err(ValidationFailure('Write a reply first.', code: 'replyEmpty'));
    return _repo.reply(caseId, text.trim());
  }
}

class ChangeCaseStatus {
  const ChangeCaseStatus(this._repo);

  final SupportRepository _repo;

  Future<Result<void>> call(int caseId, CaseStatus status) => _repo.setStatus(caseId, status);
}
