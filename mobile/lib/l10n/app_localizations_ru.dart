// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get errNetwork => 'Нет связи с сервером.';

  @override
  String get errSessionExpired => 'Сессия истекла. Войдите снова.';

  @override
  String get errForbidden => 'Недостаточно прав для этого действия.';

  @override
  String get errUnexpectedResponse => 'Неожиданный ответ сервера.';

  @override
  String get errEmailInvalid => 'Введите корректный email.';

  @override
  String get errPasswordEmpty => 'Введите пароль.';

  @override
  String get errAccountUnsupported =>
      'Этот тип аккаунта не поддерживается приложением.';

  @override
  String get errWrongCredentials => 'Неверный email или пароль';

  @override
  String get errNameRequired => 'Укажите имя и фамилию.';

  @override
  String get errPasswordShort => 'Пароль должен быть не короче 6 символов.';

  @override
  String get errRoleRequired => 'Выберите: участник или организатор.';

  @override
  String get errPromoEmpty => 'Введите промокод.';

  @override
  String get errPromoOtherEvent => 'Этот код для другого события.';

  @override
  String get errReversalReason => 'Укажите причину отмены входа.';

  @override
  String get errNoTicketId =>
      'Сервер не вернул ID билета, поэтому отменить вход отсюда нельзя.';

  @override
  String get errPickTicket => 'Выберите хотя бы один билет.';

  @override
  String get errTicketNotInOrder => 'Этого билета нет в заказе.';

  @override
  String errTicketAlreadyIn(String label) {
    return 'Билет $label уже отмечен.';
  }

  @override
  String errTicketRefundedNoEntry(String label) {
    return 'Билет $label возвращён и недействителен.';
  }

  @override
  String errTicketCancelledNoEntry(String label) {
    return 'Билет $label отменён и недействителен.';
  }

  @override
  String errSeatsForType(int count, String type) {
    return 'Выберите мест для «$type»: $count.';
  }

  @override
  String get errBuyerName => 'Укажите имя и фамилию участника.';

  @override
  String get errBuyerEmail => 'Укажите email для отправки билетов.';

  @override
  String get errSeatsFirst => 'Сначала выберите места.';

  @override
  String get errHoldExpired => 'Бронь мест истекла. Выберите места заново.';

  @override
  String get errEventTitle => 'Укажите название события.';

  @override
  String get errEventVenue => 'Укажите площадку проведения.';

  @override
  String get errEventCity => 'Укажите город.';

  @override
  String get errEventStart => 'Укажите дату и время начала.';

  @override
  String get errEventEndOrder => 'Окончание должно быть позже начала.';

  @override
  String get errRegCloseOrder =>
      'Регистрация должна закрываться позже, чем открывается.';

  @override
  String get errRegCloseBeforeEnd =>
      'Регистрация должна закрыться до окончания события.';

  @override
  String get errCapacityMin => 'Вместимость должна быть не меньше 1.';

  @override
  String get errTypeName => 'Укажите название типа билета.';

  @override
  String get errPriceNegative => 'Цена не может быть отрицательной.';

  @override
  String get errQuantityMin => 'Количество должно быть не меньше 1.';

  @override
  String errQuantityBelowSold(int count) {
    return 'Нельзя сделать меньше уже проданных: $count.';
  }

  @override
  String get errPerOrderMin => 'Лимит на заказ должен быть не меньше 1.';

  @override
  String get errSalesEndOrder =>
      'Продажи должны заканчиваться позже, чем начинаются.';

  @override
  String get errPublishNeedsType =>
      'Перед публикацией добавьте хотя бы один тип билета.';

  @override
  String get errEventAlreadyCancelled => 'Событие уже отменено.';

  @override
  String get errSectionsEmpty => 'Добавьте хотя бы одну секцию.';

  @override
  String get errSectionName => 'У каждой секции должно быть название.';

  @override
  String errSectionTwice(String name) {
    return 'Секция «$name» указана дважды.';
  }

  @override
  String get errRowsMin => 'Рядов и мест в ряду должно быть не меньше 1.';

  @override
  String get errTermsRequired => 'Сначала примите условия платных событий.';

  @override
  String get errSalesAlreadyActive => 'Платные продажи уже активированы.';

  @override
  String get errNeedPaidType => 'Сначала добавьте платный тип билета.';

  @override
  String get errNeedPayout => 'Сначала укажите реквизиты для выплат.';

  @override
  String get errOrgName => 'Укажите название организации.';

  @override
  String get errContactEmail => 'Некорректный контактный email.';

  @override
  String get errCampaignName => 'Укажите название кампании.';

  @override
  String get errDiscountPositive => 'Скидка должна быть больше нуля.';

  @override
  String get errPercentMax => 'Скидка в процентах не может быть больше 100%.';

  @override
  String get errRedemptionsMin => 'Разрешите хотя бы одно использование.';

  @override
  String get errCampaignEndOrder =>
      'Кампания должна заканчиваться позже, чем начинается.';

  @override
  String get errOrderAlreadyRefunded => 'Заказ уже возвращён.';

  @override
  String get errOrderWasCancelled => 'Заказ был отменён.';

  @override
  String get errRefundReason => 'Укажите причину возврата.';

  @override
  String get errCampaignDisabled => 'Кампания уже отключена.';

  @override
  String get errUserIdInvalid => 'Введите числовой ID пользователя.';

  @override
  String get errAlreadyOnTeam => 'Этот человек уже в команде.';

  @override
  String get errGateEmpty => 'Название входа не может быть пустым.';

  @override
  String get errGateLong => 'Слишком длинное название входа.';

  @override
  String get errCaseEvent =>
      'Выберите событие — обращение получит его организатор.';

  @override
  String get errCaseSubject => 'Опишите проблему в нескольких словах.';

  @override
  String get errCaseMessage => 'Напишите сообщение для поддержки.';

  @override
  String get errReplyEmpty => 'Сначала напишите ответ.';

  @override
  String get errOrderAlreadyCancelled => 'Заказ уже отменён.';

  @override
  String get errTicketUsedInOrder =>
      'Один из билетов заказа уже использован на входе.';

  @override
  String get errSelfSuspend => 'Нельзя заблокировать собственный аккаунт.';

  @override
  String get errAdminSuspend =>
      'Администраторов платформы здесь заблокировать нельзя.';

  @override
  String get errUserAlreadySuspended => 'Пользователь уже заблокирован.';

  @override
  String get errUserNotSuspended => 'Пользователь не заблокирован.';

  @override
  String get errSuspendReason => 'Укажите причину блокировки.';

  @override
  String get errEventNotFound => 'Событие не найдено.';

  @override
  String get errTicketNotFound => 'Билет не найден.';

  @override
  String get errAttendeeNotFound => 'Гость не найден.';

  @override
  String get errCheckInRefused => 'Сервер отклонил отметку входа.';

  @override
  String get errPromoInvalid => 'Код недействителен.';

  @override
  String get appName => 'BiletFlow';

  @override
  String get today => 'Сегодня';

  @override
  String get agoJustNow => 'только что';

  @override
  String agoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '$count минуту назад',
    );
    return '$_temp0';
  }

  @override
  String agoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '$count час назад',
    );
    return '$_temp0';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String get free => 'Бесплатно';

  @override
  String get millionShort => 'млн';

  @override
  String get appearance => 'Оформление';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';
}
