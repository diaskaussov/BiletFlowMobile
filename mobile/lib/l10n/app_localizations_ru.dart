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

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionNext => 'Следующий';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionSend => 'Отправить';

  @override
  String get actionChange => 'Изменить';

  @override
  String get actionReset => 'Сбросить';

  @override
  String get actionUndo => 'Отменить';

  @override
  String get actionKeep => 'Оставить';

  @override
  String get actionOk => 'Понятно';

  @override
  String get signOut => 'Выйти';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get noConnectionTitle => 'Нет подключения';

  @override
  String get loadFailedTitle => 'Не удалось загрузить';

  @override
  String get navScanner => 'Сканер';

  @override
  String get navGuests => 'Гости';

  @override
  String get navStats => 'Статистика';

  @override
  String get navEvents => 'События';

  @override
  String get navTickets => 'Билеты';

  @override
  String get navSupport => 'Поддержка';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navAlerts => 'Уведомления';

  @override
  String get navQueues => 'Очереди';

  @override
  String get navUsers => 'Пользователи';

  @override
  String get navOrders => 'Заказы';

  @override
  String get settings => 'Настройки';

  @override
  String get you => 'вы';

  @override
  String get copied => 'Скопировано';

  @override
  String get signInTitle => 'Вход в BiletFlow';

  @override
  String get signInSubtitle =>
      'Покупатели, организаторы, контролёры и администраторы';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get signInButton => 'Войти';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get forgotPasswordTitle => 'Восстановление пароля';

  @override
  String get forgotPasswordBody =>
      'В этой версии восстановление пароля недоступно. Контролёрам поможет организатор, остальным — support@biletflow.kz.';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String serverLabel(String address) {
    return 'Сервер: $address';
  }

  @override
  String get serverTitle => 'Адрес сервера';

  @override
  String get serverHint =>
      'На телефоне укажите IP компьютера в Wi‑Fi, а не localhost.';

  @override
  String get serverInvalid => 'Введите адрес вида http://192.168.1.10:8080';

  @override
  String get onlineOnlyNote =>
      'Проверка билетов работает только при подключении к интернету.';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerIWant => 'Я хочу';

  @override
  String get roleAttend => 'Посещать';

  @override
  String get roleAttendHint =>
      'Находить события, покупать билеты, показывать QR на входе';

  @override
  String get roleOrganize => 'Организовывать';

  @override
  String get roleOrganizeHint =>
      'Создавать события, продавать билеты, назначать контролёров';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get phoneOptional => 'Телефон (необязательно)';

  @override
  String get passwordMin => 'Пароль · не менее 6 символов';

  @override
  String get registerButton => 'Создать аккаунт';

  @override
  String get registerOrganizerButton => 'Создать аккаунт организатора';

  @override
  String get registerNote =>
      'Мы отправим ссылку для подтверждения на email. Аккаунты контролёров создают организаторы.';

  @override
  String get myEvents => 'Мои события';

  @override
  String get noAssignedEvents => 'Вас пока не назначили ни на одно событие';

  @override
  String get noAssignedEventsHint =>
      'Организатор должен добавить вас как контролёра. Сообщите ему email, с которым вы вошли.';

  @override
  String get checkAgain => 'Проверить снова';

  @override
  String get pastEvents => 'Прошедшие';

  @override
  String get upcomingEvents => 'Предстоящие';

  @override
  String signedInAs(String email) {
    return 'Вы вошли как $email';
  }

  @override
  String enteredOf(int checkedIn, int registered) {
    return 'Вошло $checkedIn из $registered';
  }

  @override
  String get pointAtQr => 'Наведите на QR-код билета';

  @override
  String get torch => 'Фонарик';

  @override
  String get enterCode => 'Ввести код';

  @override
  String get checking => 'Проверяем билет…';

  @override
  String get lowLightTorchOn => 'Темно — фонарик включён';

  @override
  String get scanPaused => 'Нет подключения: сканирование недоступно';

  @override
  String get enterCodeTitle => 'Код билета';

  @override
  String get enterCodeHint => 'Код под QR-кодом или из письма';

  @override
  String get checkCode => 'Проверить';

  @override
  String get cameraOffTitle => 'Доступ к камере выключен';

  @override
  String get cameraOffBody =>
      'Камера нужна, чтобы читать QR-коды билетов. Включите её в Настройках → BiletFlow → Камера.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get findGuestInstead => 'Найти гостя вручную';

  @override
  String get cameraUnavailable => 'Камера недоступна';

  @override
  String get chooseEventFirst => 'Сначала выберите событие';

  @override
  String get chooseEvent => 'Выберите событие';

  @override
  String get vValid => 'Проходите';

  @override
  String get vAlreadyUsed => 'Билет уже использован';

  @override
  String get vRepeat => 'Этот билет только что прошёл';

  @override
  String get vRefunded => 'Билет возвращён';

  @override
  String get vCancelled => 'Билет отменён';

  @override
  String get vUnknown => 'Билет не найден';

  @override
  String get vWrongEvent => 'Билет на другое событие';

  @override
  String get vPromo => 'Это промокод, а не билет';

  @override
  String closesIn(int seconds) {
    return 'Закроется через $seconds с';
  }

  @override
  String get undoEntry => 'Отменить вход';

  @override
  String entryMarkedAt(String time) {
    return 'Вход отмечен в $time';
  }

  @override
  String scannedBy(String name) {
    return 'Отсканировал: $name';
  }

  @override
  String get orderCancelledByOrganizer => 'Заказ отменён организатором';

  @override
  String refundedOn(String date) {
    return 'Деньги возвращены $date';
  }

  @override
  String get refundedNoEntry => 'Деньги возвращены — по билету нельзя пройти';

  @override
  String get checkCodeOrFind => 'Проверьте код или найдите гостя вручную';

  @override
  String get findGuest => 'Найти гостя';

  @override
  String get ticketIsFor => 'Этот билет на:';

  @override
  String get anotherEvent => 'Другое событие';

  @override
  String get switchToEvent => 'Перейти к этому событию';

  @override
  String campaignLabel(String name) {
    return 'Кампания $name';
  }

  @override
  String get promoNotTicket =>
      'Промокод даёт скидку на сайте, но не пропускает на вход';

  @override
  String repeatBody(int seconds) {
    return 'Отсканирован $seconds с назад — это тот же вход, повторно ничего не записано';
  }

  @override
  String get copyTicketId => 'Скопировать ID билета';

  @override
  String get reversedTitle => 'Вход отменён';

  @override
  String get reversedBody => 'Билет снова действителен';

  @override
  String get admission => '1 вход';

  @override
  String reverseTitle(String name) {
    return 'Отменить вход для $name?';
  }

  @override
  String get reverseBody =>
      'Билет снова станет действительным. Отмена записывается с вашим именем и не удаляется.';

  @override
  String get checkedInLabel => 'Вход';

  @override
  String get recordedBy => 'Отметил';

  @override
  String get ticketLabel => 'Билет';

  @override
  String get reasonRequired => 'Причина (обязательно)';

  @override
  String get reasonHint => 'Например: отсканировали не того человека';

  @override
  String get guestSearchHint => 'Имя, email, код билета или номер заказа';

  @override
  String get statusValid => 'Действителен';

  @override
  String get statusUsed => 'Использован';

  @override
  String get statusRefunded => 'Возвращён';

  @override
  String get statusCancelled => 'Отменён';

  @override
  String get markEntry => 'Отметить вход';

  @override
  String get guestSearchStart => 'Начните вводить имя — минимум 2 символа';

  @override
  String guestNoMatches(String query) {
    return 'Никого не найдено по «$query»';
  }

  @override
  String get guestNoMatchesHint =>
      'Проверьте написание или ищите по коду билета';

  @override
  String filterAll(int count) {
    return 'Все $count';
  }

  @override
  String filterNotArrived(int count) {
    return 'Не пришли $count';
  }

  @override
  String get checkedInToast => 'Вход отмечен';

  @override
  String ticketsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count билета',
      many: '$count билетов',
      few: '$count билета',
      one: '$count билет',
    );
    return '$_temp0';
  }

  @override
  String get guest => 'Гость';

  @override
  String get ticketsInOrder => 'Билеты в заказе';

  @override
  String checkInAll(int count) {
    return 'Отметить все билеты ($count)';
  }

  @override
  String get history => 'История';

  @override
  String get manualNote =>
      'Ручная отметка записывается на ваше имя и видна организатору.';

  @override
  String notArrivedCount(int count) {
    return 'Не пришли: $count';
  }

  @override
  String get allUsedOrVoid => 'Все билеты использованы или недействительны';

  @override
  String get recordUnavailable => 'Запись недоступна';

  @override
  String get entered => 'Вошло';

  @override
  String stillToCome(int count) {
    return 'Осталось гостей: $count';
  }

  @override
  String get registered => 'Зарегистрировано';

  @override
  String get notArrived => 'Не пришли';

  @override
  String get cancelledStat => 'Отменено';

  @override
  String get refundedStat => 'Возвращено';

  @override
  String get reversals => 'Отмен входа';

  @override
  String get byTicketType => 'По типам билетов';

  @override
  String get recentEntries => 'Последние входы';

  @override
  String get noEntriesYet => 'Входов пока нет';

  @override
  String get statsUnavailable => 'Статистика недоступна';

  @override
  String get offlineBody => 'Проверьте интернет и попробуйте снова';

  @override
  String get connectionRestored => 'Связь восстановлена';

  @override
  String get stillOffline => 'Связи с сервером всё ещё нет';

  @override
  String lastSync(String time) {
    return 'Последняя синхронизация: $time';
  }

  @override
  String get offlineNote =>
      'Билеты проверяются на сервере, поэтому без связи сканирование приостановлено. На телефоне ничего не сохраняется.';

  @override
  String get scanningSection => 'Сканирование';

  @override
  String get torchDefault => 'Фонарик включён по умолчанию';

  @override
  String get soundOnResult => 'Звук при результате';

  @override
  String get vibrateOnReject => 'Вибрация при отказе';

  @override
  String get gateSection => 'Вход';

  @override
  String get assignedGate => 'Мой вход';

  @override
  String get roleEventAdmin => 'Контролёр';

  @override
  String get roleAttendee => 'Покупатель';

  @override
  String get roleOrganizer => 'Организатор';

  @override
  String get rolePlatformAdmin => 'Администратор';

  @override
  String eventsCount(int count) {
    return 'Событий: $count';
  }

  @override
  String get server => 'Сервер';

  @override
  String get demoBuild =>
      'Демо-версия: все платежи ненастоящие, деньги не списываются.';

  @override
  String get account => 'Аккаунт';

  @override
  String get notifications => 'Уведомления';

  @override
  String get organizerProfile => 'Профиль организатора и выплаты';
}
