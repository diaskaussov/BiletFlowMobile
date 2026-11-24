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
  String get enterCodeHint => 'Введите код';

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

  @override
  String get evDraft => 'Черновик';

  @override
  String get evPublished => 'Опубликовано';

  @override
  String get evCancelled => 'Отменено';

  @override
  String get evCompleted => 'Завершено';

  @override
  String get evLive => 'Идёт сейчас';

  @override
  String get visPublic => 'Публичное';

  @override
  String get visUnlisted => 'По ссылке';

  @override
  String get visPrivate => 'Приватное';

  @override
  String get orderPending => 'Ожидает оплаты';

  @override
  String get orderPaid => 'Оплачен';

  @override
  String get orderCancelled => 'Отменён';

  @override
  String get orderRefunded => 'Возвращён';

  @override
  String get caseOpen => 'Открыто';

  @override
  String get caseInProgress => 'В работе';

  @override
  String get caseWaiting => 'Ждём ответа';

  @override
  String get caseResolved => 'Решено';

  @override
  String get catTicketDelivery => 'Доставка билета';

  @override
  String get catPayment => 'Оплата';

  @override
  String get catRefund => 'Возврат';

  @override
  String get catSeating => 'Места';

  @override
  String get catEventInfo => 'Информация о событии';

  @override
  String get catCheckIn => 'Вход';

  @override
  String get catAccount => 'Аккаунт';

  @override
  String get catActivation => 'Активация продаж';

  @override
  String get catTechnical => 'Техническая проблема';

  @override
  String get auditEventChanges => 'Изменения события';

  @override
  String get auditRefunds => 'Возвраты';

  @override
  String get auditCampaigns => 'Промо';

  @override
  String get auditCheckIns => 'Входы';

  @override
  String get auditSupport => 'Поддержка';

  @override
  String seatLabel(String section, String row, String number) {
    return 'Сектор $section · ряд $row · место $number';
  }

  @override
  String get secOverview => 'Обзор';

  @override
  String get secTickets => 'Билеты';

  @override
  String get secSeating => 'Схема зала';

  @override
  String get secOrders => 'Заказы';

  @override
  String get secPromo => 'Промо';

  @override
  String get secStaff => 'Персонал';

  @override
  String get secSales => 'Продажи';

  @override
  String get secHistory => 'История';

  @override
  String get secCheckIn => 'Вход';

  @override
  String get eventActions => 'Действия с событием';

  @override
  String get actEdit => 'Редактировать';

  @override
  String get actDuplicate => 'Дублировать';

  @override
  String get actPublish => 'Опубликовать';

  @override
  String get actUnpublish => 'Снять с публикации';

  @override
  String get actCancelEvent => 'Отменить событие';

  @override
  String get cancelEventTitle => 'Отменить событие?';

  @override
  String get cancelEventBody =>
      'Продажи остановятся, все билеты станут недействительными, участники получат уведомление. Записи останутся в истории.';

  @override
  String get publishedToast => 'Опубликовано — регистрация открыта.';

  @override
  String get unpublishedToast => 'Снято с публикации — снова черновик.';

  @override
  String get cancelledToast => 'Событие отменено.';

  @override
  String get duplicatedToast =>
      'Создан черновик-копия без заказов, билетов и входов.';

  @override
  String get salesNotActive =>
      'Платные продажи не активированы — покупатели не могут купить платные билеты';

  @override
  String get actActivate => 'Активировать';

  @override
  String get kpiSold => 'Продано';

  @override
  String get kpiGross => 'Валовая выручка';

  @override
  String get kpiNet => 'Чистая выручка';

  @override
  String get kpiAttendance => 'Явка';

  @override
  String get kpiOrders => 'Заказов';

  @override
  String get kpiDiscounts => 'Скидки';

  @override
  String get kpiRefunds => 'Возвраты';

  @override
  String get kpiRemaining => 'Осталось';

  @override
  String get salesByType => 'Продажи по типам билетов';

  @override
  String get promoEffect => 'Эффективность промокодов';

  @override
  String redeemedOf(String used, String max) {
    return '$used из $max';
  }

  @override
  String redeemed(int count) {
    return '$count исп.';
  }

  @override
  String get salesOverTime => 'Продажи по дням';

  @override
  String get noOrdersYet => 'Заказов пока нет.';

  @override
  String get eventFallback => 'Событие';

  @override
  String get createEvent => 'Создать событие';

  @override
  String get firstEventTitle => 'Создайте первое событие';

  @override
  String get firstEventBody =>
      'Создание событий и бесплатные билеты ничего не стоят. Платные продажи активируются для каждого события отдельно.';

  @override
  String filterAllN(int count) {
    return 'Все $count';
  }

  @override
  String filterDraftsN(int count) {
    return 'Черновики $count';
  }

  @override
  String filterPublishedN(int count) {
    return 'Опубликованные $count';
  }

  @override
  String filterLiveN(int count) {
    return 'Идут $count';
  }

  @override
  String filterPastN(int count) {
    return 'Прошедшие $count';
  }

  @override
  String filterCancelledN(int count) {
    return 'Отменённые $count';
  }

  @override
  String get searchByTitle => 'Поиск по названию';

  @override
  String soldOf(String sold, String total) {
    return 'Продано $sold / $total';
  }

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get noNotifications => 'Уведомлений пока нет';

  @override
  String get noNotificationsHint =>
      'Здесь появятся заказы, возвраты и ответы поддержки.';

  @override
  String get demoPayments =>
      'Демо-версия: оплата идёт через тестовую систему, деньги не списываются, карты не сохраняются.';

  @override
  String get ordersSearchHint => 'Покупатель или № заказа';

  @override
  String get filtersTitle => 'Фильтр';

  @override
  String get attAll => 'Все';

  @override
  String get attCheckedIn => 'Вошли';

  @override
  String get attNotArrived => 'Не пришли';

  @override
  String get attRefunded => 'Возвраты и отмены';

  @override
  String get attCampaign => 'С промокодом';

  @override
  String get exportCsv => 'Выгрузить CSV';

  @override
  String orderNo(String id) {
    return '№$id';
  }

  @override
  String get noOrder => 'Без заказа';

  @override
  String get refundMoney => 'Вернуть деньги';

  @override
  String refundTitle(String id) {
    return 'Возврат по заказу №$id';
  }

  @override
  String get buyer => 'Покупатель';

  @override
  String get positions => 'Позиции';

  @override
  String get toRefund => 'К возврату';

  @override
  String get reasonStar => 'Причина *';

  @override
  String get refundReasonHint =>
      'Например: покупатель не сможет посетить событие';

  @override
  String refundConfirm(String amount) {
    return 'Вернуть $amount';
  }

  @override
  String get refundedToast => 'Деньги возвращены. Покупатель получит письмо.';

  @override
  String refundUsedWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count билета уже прошли вход',
      many: '$count билетов уже прошли вход',
      few: '$count билета уже прошли вход',
      one: '$count билет уже прошёл вход',
    );
    return '$_temp0. Возврат не отменяет вход.';
  }

  @override
  String get refundNote =>
      'Билеты сразу станут недействительными, места вернутся в продажу.';

  @override
  String get orderTitle => 'Заказ';

  @override
  String get statusLabel => 'Статус';

  @override
  String discountCode(String code) {
    return 'Скидка $code';
  }

  @override
  String get paidLabel => 'Оплачено';

  @override
  String get placedLabel => 'Оформлен';

  @override
  String usedOfTotal(String used, String total) {
    return '$used из $total';
  }

  @override
  String get noOrdersMatch => 'Нет заказов по запросу';

  @override
  String get orderNotFound => 'Заказ не найден';

  @override
  String get errOrderNotFound => 'Заказ не найден.';

  @override
  String get errOrderNoEvent => 'У заказа нет события.';

  @override
  String get errRowInvalid =>
      'У каждого ряда должна быть подпись и хотя бы одно место.';

  @override
  String errSeatsOverTickets(String name, int seats, int quantity) {
    return 'В схеме $seats мест «$name», а доступно $quantity билетов — увеличьте количество';
  }

  @override
  String seatPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count места',
      many: '$count мест',
      few: '$count места',
      one: '$count место',
    );
    return 'Превью · $_temp0';
  }

  @override
  String get fullScreen => 'На весь экран';

  @override
  String get stage => 'СЦЕНА';

  @override
  String get sectionsTitle => 'Секции';

  @override
  String rowsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ряда',
      many: '$count рядов',
      few: '$count ряда',
      one: '$count ряд',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count места',
      many: '$count мест',
      few: '$count места',
      one: '$count место',
    );
    return '$_temp0';
  }

  @override
  String get modeQuick => 'Быстро';

  @override
  String get modeManual => 'Вручную';

  @override
  String get sectionName => 'Название секции';

  @override
  String get rowsLabel => 'Рядов';

  @override
  String get seatsPerRowLabel => 'Мест в ряду';

  @override
  String get rowLabel => 'Ряд';

  @override
  String get seatsLabel => 'Мест';

  @override
  String get addRow => 'Добавить ряд';

  @override
  String get addSection => 'Добавить секцию';

  @override
  String get saveMap => 'Сохранить схему';

  @override
  String get deleteMap => 'Удалить схему';

  @override
  String get deleteMapTitle => 'Удалить схему зала?';

  @override
  String get deleteMapBody =>
      'Места пропадут, и покупатели не смогут их выбирать.';

  @override
  String get mapSaved => 'Схема сохранена.';

  @override
  String get mapDeleted => 'Схема удалена.';

  @override
  String get mapSoldLocked => 'Места уже проданы — схему нельзя удалить.';

  @override
  String get noSeatMapYet =>
      'Схемы пока нет. Добавьте секцию — каждая продаётся по цене своего типа билета.';

  @override
  String get needTicketTypeFirst =>
      'Сначала добавьте тип билета — секции продаются по его цене.';

  @override
  String get ticketTypeLabel => 'Тип билета';

  @override
  String get removeSection => 'Удалить секцию';

  @override
  String sectionDefault(String name) {
    return 'Сектор $name';
  }

  @override
  String get actionDelete => 'Удалить';

  @override
  String get activationTitle => 'Активация платных продаж';

  @override
  String activationProgress(int done, int total) {
    return 'Выполнено $done из $total условий. Пока продажи не активированы, доступны только бесплатные билеты.';
  }

  @override
  String get chkPaidType => 'Есть платный тип билета';

  @override
  String get chkPaidTypeMissing => 'Добавьте тип билета с ценой больше нуля';

  @override
  String get chkIdentity => 'Личность подтверждена';

  @override
  String get chkIdentityMissing => 'Тестовая проверка в профиле организатора';

  @override
  String get chkPayout => 'Реквизиты для выплат подтверждены';

  @override
  String get chkPayoutMissing => 'Укажите банк и номер счёта';

  @override
  String get chkFee => 'Комиссия оплачена';

  @override
  String get chkFeeMissing =>
      'Разовая комиссия за это событие — спишется при активации (тест)';

  @override
  String get doneLabel => 'Готово';

  @override
  String get fixLink => 'Исправить →';

  @override
  String get termsAccept =>
      'Принимаю условия платных продаж: возвраты, чарджбэки, сроки выплат';

  @override
  String get activateButton => 'Активировать платные продажи';

  @override
  String get activatedTitle => 'Продажи активированы';

  @override
  String get activatedBody => 'Покупатели могут приобретать платные билеты';

  @override
  String get activatedToast => 'Платные продажи активированы (тест).';

  @override
  String get demoActivation =>
      'Проверка личности, комиссия, оплаты и выплаты идут через тестовую систему. Деньги не списываются.';

  @override
  String get orgProfileTitle => 'Профиль организатора';

  @override
  String get orgProfileSub => 'Контакты и выплаты';

  @override
  String get identityOk => 'Личность подтверждена';

  @override
  String get identityNo => 'Личность не подтверждена';

  @override
  String get payoutOk => 'Выплаты подтверждены';

  @override
  String get payoutNo => 'Выплаты не подтверждены';

  @override
  String get organization => 'Организация';

  @override
  String get orgName => 'Название организации';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get contactEmail => 'Email для связи';

  @override
  String get contactPhone => 'Телефон для связи';

  @override
  String get website => 'Сайт';

  @override
  String get payoutSection => 'Счёт для выплат · тест';

  @override
  String get bank => 'Банк';

  @override
  String get accountNumber => 'Номер счёта';

  @override
  String get accountHolder => 'Владелец счёта';

  @override
  String get demoPayout =>
      'Реквизиты используются только для тестовой выплаты. Реальных переводов нет.';

  @override
  String get saveProfile => 'Сохранить профиль';

  @override
  String get profileSaved => 'Профиль сохранён.';

  @override
  String get issued => 'Выдано';

  @override
  String get available => 'Доступно';

  @override
  String get refundedVoid => 'Возвраты / аннул.';

  @override
  String get noTicketTypes => 'Типов билетов пока нет';

  @override
  String get noTicketTypesHint =>
      'Добавьте хотя бы один бесплатный или платный тип перед публикацией.';

  @override
  String get ttHidden => 'Скрыт';

  @override
  String get ttSoldOut => 'Распродан';

  @override
  String get ttOnSale => 'В продаже';

  @override
  String get ttNotOnSale => 'Не продаётся';

  @override
  String get priceLabel => 'Цена';

  @override
  String get maxPerOrder => 'Макс. в заказе';

  @override
  String get salesWindow => 'Продажи';

  @override
  String get salesNow => 'сейчас';

  @override
  String get salesUntilEvent => 'до события';

  @override
  String get actHide => 'Скрыть';

  @override
  String get hiddenToast => 'Тип снят с продажи. Проданные билеты действуют.';

  @override
  String get ttAdded => 'Тип билета добавлен.';

  @override
  String get savedToast => 'Сохранено.';

  @override
  String get addTicketType => 'Добавить тип билета';

  @override
  String get newTicketType => 'Новый тип билета';

  @override
  String get editTicketType => 'Изменить тип билета';

  @override
  String get nameLabel => 'Название';

  @override
  String get freeTicket => 'Бесплатный билет';

  @override
  String get priceKzt => 'Цена, ₸';

  @override
  String get quantityLabel => 'Количество';

  @override
  String get salesStartOpt => 'Начало продаж (необязательно)';

  @override
  String get salesEndOpt => 'Конец продаж (необязательно)';

  @override
  String get paidNeedsActivation =>
      'Платные билеты продаются только после активации продаж для этого события.';

  @override
  String get pickDateTime => 'Выберите дату и время';

  @override
  String get campaignQrTitle => 'QR кампании — это не билет';

  @override
  String get codeLabel => 'Код';

  @override
  String get linkLabel => 'Ссылка';

  @override
  String campaignQrNote(String code) {
    return 'Открывает страницу события с уже применённым $code. В ссылке только код, без цены — его проверяет сервер. Сканер на входе такой QR не принимает.';
  }

  @override
  String get shareLink => 'Поделиться ссылкой';

  @override
  String get copyCode => 'Скопировать код';

  @override
  String get codeCopied => 'Код скопирован.';

  @override
  String get noCampaigns => 'Кампаний пока нет';

  @override
  String get noCampaignsHint =>
      'Кампания даёт скидку по промокоду и отслеживаемому QR.';

  @override
  String get campLive => 'Активна';

  @override
  String get campNotLive => 'Не активна';

  @override
  String get campDisabled => 'Отключена';

  @override
  String get codeHidden => 'Сервер не вернул код';

  @override
  String get discountLabel => 'Скидка';

  @override
  String percentOff(String value) {
    return '−$value%';
  }

  @override
  String amountOff(String value) {
    return '−$value';
  }

  @override
  String get usedLabel => 'Использовано';

  @override
  String get validLabel => 'Действует';

  @override
  String get validOpen => 'без срока';

  @override
  String get qrAndLink => 'QR и ссылка';

  @override
  String get actDisable => 'Отключить';

  @override
  String get campaignDisabled => 'Кампания отключена.';

  @override
  String get campaignsNote =>
      'Лимит использований проверяет сервер. Коды кампаний, созданных на других устройствах, API не возвращает.';

  @override
  String get createCampaign => 'Создать кампанию';

  @override
  String get newCampaign => 'Новая кампания';

  @override
  String get discPercent => 'Процент';

  @override
  String get discFixed => 'Сумма ₸';

  @override
  String get discountPct => 'Скидка, %';

  @override
  String get discountKzt => 'Скидка, ₸';

  @override
  String get maxRedemptions => 'Лимит использований';

  @override
  String get validFrom => 'Действует с';

  @override
  String get validTo => 'Действует до';

  @override
  String get createAndQr => 'Создать и получить QR';

  @override
  String get staffIntro =>
      'Добавленные контролёры входят в приложение-сканер и видят только это событие — без выручки, заказов и других событий.';

  @override
  String get nobodyAssigned => 'Пока никто не назначен.';

  @override
  String userNo(String id) {
    return 'польз. №$id';
  }

  @override
  String get actRemove => 'Убрать';

  @override
  String get staffRemoved => 'Убран из этого события.';

  @override
  String get addEventAdmin => 'Добавить контролёра';

  @override
  String get userId => 'ID пользователя';

  @override
  String get actAdd => 'Добавить';

  @override
  String get staffAdded => 'Добавлен. Можно входить в сканер.';

  @override
  String get staffIdNote =>
      'API назначает персонал только по ID пользователя, по email — пока нет. Нужен аккаунт EVENT_ADMIN.';

  @override
  String get gateActivity => 'Активность на входе';

  @override
  String get auditTrailNote =>
      'Записи нельзя изменить или удалить. Администраторы платформы видят тот же журнал.';

  @override
  String get noHistory => 'Записей пока нет.';

  @override
  String allN(int count) {
    return 'Все · $count';
  }

  @override
  String get absentHolders => 'Не пришли';

  @override
  String get ofCapacity => 'от вместимости';

  @override
  String get createEventTitle => 'Новое событие';

  @override
  String get editEventTitle => 'Редактирование';

  @override
  String get draftHint => 'Черновик — ничего не видно публично до публикации';

  @override
  String get basics => 'Основное';

  @override
  String get eventTitleLabel => 'Название события';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get categoryHint => 'Музыка, IT, Спорт, Театр';

  @override
  String get visibilityLabel => 'Видимость';

  @override
  String get venueSection => 'Площадка';

  @override
  String get venueLabel => 'Место проведения';

  @override
  String get addressLabel => 'Адрес';

  @override
  String get cityLabel => 'Город';

  @override
  String get dateSection => 'Дата и регистрация';

  @override
  String get startsLabel => 'Начало';

  @override
  String get endsLabel => 'Окончание';

  @override
  String get regOpens => 'Регистрация открывается';

  @override
  String get regCloses => 'Регистрация закрывается';

  @override
  String get capacityLabel => 'Вместимость';

  @override
  String get seatingImage => 'Места и обложка';

  @override
  String get assignedSeating => 'Места по схеме зала';

  @override
  String get assignedSeatingHint =>
      'Покупатели выбирают места на схеме при оформлении.';

  @override
  String get coverUrl => 'Ссылка на обложку (необязательно)';

  @override
  String get coverNote =>
      'Загрузка картинок в этой версии недоступна — вставьте ссылку на изображение.';

  @override
  String get saveAndContinue => 'Сохранить и продолжить';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get draftSaved => 'Черновик сохранён. Добавьте типы билетов.';

  @override
  String get changesSaved => 'Изменения сохранены.';

  @override
  String get adminBanner => 'Админ платформы · только для персонала';

  @override
  String get roleUnknown => 'Неизвестно';

  @override
  String get roleBuyer => 'Покупатель';

  @override
  String get roleGate => 'Контролёр';

  @override
  String get roleAdminShort => 'Админ';

  @override
  String get allRoles => 'Все роли';

  @override
  String get workQueues => 'Очереди';

  @override
  String get unpaidOrders => 'Неоплаченные заказы';

  @override
  String get paidSalesEvents => 'События с продажами';

  @override
  String get suspendedUsers => 'Заблокированные';

  @override
  String get refundsQueue => 'Возвраты';

  @override
  String platformTotals(int users, int events, int orders) {
    return 'На платформе: пользователей $users, событий $events, заказов $orders';
  }

  @override
  String get unpaidOrdersHint =>
      'Неоплаченные заказы · ошибки оплаты и брошенные корзины';

  @override
  String get noTicketsIssued => 'Билеты не выданы';

  @override
  String get paidSalesRecords => 'Активные платные продажи';

  @override
  String get allOrdersPayments => 'Все заказы и платежи';

  @override
  String get notInBuild => 'Пока недоступно';

  @override
  String get notInBuildBody =>
      'Жалобы на события, проверка активаций, эскалации поддержки, выгрузка отчётов и настройка комиссии требуют эндпоинтов, которых в бэкенде пока нет.';

  @override
  String get nothingHere => 'Пусто.';

  @override
  String get adminEventsSearch => 'Событие, организатор или город';

  @override
  String get noDate => 'Без даты';

  @override
  String get paidSalesTag => 'Платные продажи';

  @override
  String get suspendEventTitle => 'Приостановить событие?';

  @override
  String get suspendEventBody =>
      'Новые покупки сразу остановятся. Выданные билеты действуют, пока их не аннулируют.';

  @override
  String get actSuspend => 'Приостановить';

  @override
  String get eventSuspendedToast =>
      'Событие приостановлено, продажи остановлены.';

  @override
  String get moderation => 'Модерация';

  @override
  String get suspendedTag => 'Приостановлено';

  @override
  String get paidSalesActive => 'Платные продажи активны';

  @override
  String moderationSummary(String organizer, String sold, String collected) {
    return '$organizer · продано $sold · собрано $collected';
  }

  @override
  String get organizerFallback => 'Организатор';

  @override
  String get whenLabel => 'Когда';

  @override
  String get organizerRecord => 'Организатор';

  @override
  String get accountLabel => 'Аккаунт';

  @override
  String get emailVerified => 'Email подтверждён';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get ordersOnEvent => 'Заказов на событии';

  @override
  String get suspendingWill => 'Приостановка';

  @override
  String get suspendWill1 => 'Сразу остановит новые покупки на событие.';

  @override
  String get suspendWill2 =>
      'Оставит выданные билеты действительными, пока вы их не аннулируете.';

  @override
  String get suspendWill3 => 'Задержит выплату организатору.';

  @override
  String get suspendWill4 => 'Запишет действие в журнал события.';

  @override
  String get suspendReason => 'Причина — для организатора';

  @override
  String get suspendReasonNote =>
      'Текущий API причину пока не сохраняет — оставьте её себе.';

  @override
  String get suspendEventButton => 'Приостановить событие и продажи';

  @override
  String get nameOrEmail => 'Имя или email';

  @override
  String get userActive => 'Активен';

  @override
  String get userBlocked => 'Заблокирован';

  @override
  String get actBlock => 'Заблокировать';

  @override
  String get actUnblock => 'Разблокировать';

  @override
  String blockTitle(String name) {
    return 'Заблокировать $name?';
  }

  @override
  String unblockTitle(String name) {
    return 'Разблокировать $name?';
  }

  @override
  String get blockBody =>
      'Пользователь не сможет войти, пока его не разблокируют.';

  @override
  String get unblockBody =>
      'Пользователь снова сможет входить и пользоваться BiletFlow.';

  @override
  String get userBlockedToast => 'Пользователь заблокирован.';

  @override
  String get userUnblockedToast => 'Пользователь разблокирован.';

  @override
  String get staffTag => 'Персонал';

  @override
  String get noCardData =>
      'Данные карт не хранятся и не показываются. Все платежи — тестовые.';

  @override
  String get noUsersMatch => 'Никого не нашли';

  @override
  String get generalSection => 'Общее';

  @override
  String get demoFootnote =>
      'Все платежи в этой версии — демонстрационные, деньги не списываются.';

  @override
  String get supportInbox => 'Поддержка';

  @override
  String get newCase => 'Новое обращение';

  @override
  String openN(int count) {
    return 'Открытые $count';
  }

  @override
  String resolvedN(int count) {
    return 'Решённые $count';
  }

  @override
  String get noOpenCases => 'Открытых обращений нет';

  @override
  String get noResolvedCases => 'Решённых пока нет';

  @override
  String get supportEmptyOrganizer =>
      'Здесь появятся вопросы участников ваших событий и ваши обращения к платформе.';

  @override
  String get supportEmptyAttendee =>
      'Создайте обращение из события, заказа или кнопкой +. Ответы придут сюда и на почту.';

  @override
  String get eventLabel => 'Событие';

  @override
  String get noCaseContext =>
      'Обращения уходят организатору события. Сначала зарегистрируйтесь или купите билет, затем напишите из события или заказа.';

  @override
  String get subjectLabel => 'Тема';

  @override
  String get subjectHint => 'Не пришёл второй билет';

  @override
  String get messageLabel => 'Сообщение';

  @override
  String get orderAttached =>
      'Заказ прикреплён автоматически — поддержка увидит контекст.';

  @override
  String get eventAttached =>
      'Событие прикреплено автоматически — поддержка увидит контекст.';

  @override
  String caseOpened(String number) {
    return 'Обращение $number создано.';
  }

  @override
  String get caseFallback => 'Обращение';

  @override
  String get openedBy => 'Автор';

  @override
  String get assignedLabel => 'Ответственный';

  @override
  String get openedLabel => 'Создано';

  @override
  String get noMessages => 'Сообщений пока нет.';

  @override
  String get repliesNote =>
      'Ответы приходят на почту и в аккаунт — быть онлайн не обязательно.';

  @override
  String get markResolved => 'Отметить решённым';

  @override
  String get replyHint => 'Написать ответ…';

  @override
  String get scanCampaignQr => 'Сканировать QR кампании';

  @override
  String upcomingN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count события впереди',
      many: '$count событий впереди',
      few: '$count события впереди',
      one: '$count событие впереди',
    );
    return '$_temp0';
  }

  @override
  String get catalogSearch => 'События, площадки, организаторы';

  @override
  String filtersN(int count) {
    return 'Фильтры · $count';
  }

  @override
  String get filters => 'Фильтры';

  @override
  String get noUpcoming => 'Пока нет событий';

  @override
  String get noUpcomingHint =>
      'Опубликованные события появятся здесь, как только организаторы откроют регистрацию.';

  @override
  String get nothingMatches => 'Ничего не подошло';

  @override
  String get nothingMatchesHint => 'Попробуйте другой город, дату или цену.';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String get soldOut => 'Распродано';

  @override
  String fromPrice(String price) {
    return 'от $price';
  }

  @override
  String get seatedTag => 'С местами';

  @override
  String get registrationTag => 'Регистрация';

  @override
  String get cityFilter => 'Город';

  @override
  String get anyOption => 'Любой';

  @override
  String get whenFilter => 'Когда';

  @override
  String get anyTime => 'Любое время';

  @override
  String get thisWeekend => 'В выходные';

  @override
  String get next30 => '30 дней';

  @override
  String get priceFilter => 'Цена';

  @override
  String get anyPrice => 'Любая цена';

  @override
  String get freeOnly => 'Только бесплатные';

  @override
  String get under5000 => 'До 5 000 ₸';

  @override
  String get showEvents => 'Показать события';

  @override
  String get addToCalendar => 'Добавить в календарь';

  @override
  String get downloadIcs => 'Скачать .ics';

  @override
  String get calendarNote =>
      'Включает адрес площадки и время. Если организатор изменит время, обновлённый файл заменит запись.';

  @override
  String promoApplied(String code, String discount) {
    return 'Промокод $code: $discount';
  }

  @override
  String get promoVerified =>
      'Проверен сервером. Итоговую сумму увидите перед оплатой.';

  @override
  String get dateLabel => 'Дата';

  @override
  String get regClosesLabel => 'Регистрация до';

  @override
  String get registrationClosed => 'Регистрация на событие закрыта.';

  @override
  String get noTicketsOnSale => 'Билеты пока не продаются.';

  @override
  String get promoCodeLabel => 'Промокод';

  @override
  String get actApply => 'Применить';

  @override
  String get contactSupportEvent => 'Написать в поддержку';

  @override
  String maxPerOrderN(int count) {
    return 'не больше $count в заказе';
  }

  @override
  String leftN(String count) {
    return 'осталось $count';
  }

  @override
  String get chooseSeats => 'Выбрать места';

  @override
  String get continueCheckout => 'Перейти к оформлению';

  @override
  String get seatsHeldNote => 'Места держатся 10 минут при оформлении.';

  @override
  String get notCampaignQr => 'Это не QR кампании BiletFlow.';

  @override
  String get cameraOffCampaign =>
      'Доступ к камере выключен. Включите его в настройках, чтобы сканировать коды.';

  @override
  String get campaignScanHint =>
      'Наведите на QR с афиши или флаера. Событие откроется со скидкой после проверки кода сервером.';

  @override
  String get checkoutTitle => 'Оформление';

  @override
  String get stepsSeats => 'Места › Данные и оплата › Билеты';

  @override
  String get stepsNoSeats => 'Данные и оплата › Билеты';

  @override
  String get holdExpired => 'Бронь мест истекла — вернитесь и выберите снова';

  @override
  String holdExpiresIn(String time) {
    return 'Места держатся ещё $time';
  }

  @override
  String get yourDetails => 'Ваши данные';

  @override
  String get emailTickets => 'Email — сюда придут билеты';

  @override
  String get paymentSection => 'Оплата';

  @override
  String get payCard => 'Карта · тест';

  @override
  String get payKaspi => 'Kaspi перевод · тест';

  @override
  String get orderSummary => 'Ваш заказ';

  @override
  String get totalKzt => 'Итого';

  @override
  String get serverRecalcs =>
      'Сервер пересчитает скидку — итог может немного отличаться.';

  @override
  String get getFreeTickets => 'Получить бесплатные билеты';

  @override
  String payAmount(String amount) {
    return 'Оплатить $amount';
  }

  @override
  String get freeConfirmedNote =>
      'Бесплатные заказы подтверждаются сразу, билеты выдаются мгновенно.';

  @override
  String get paidConfirmedNote =>
      'Билеты выдаются только после подтверждения оплаты тестовой системой.';

  @override
  String get chooseYourSeats => 'Выбор мест';

  @override
  String get noSeatMapBuyer => 'Схемы зала пока нет';

  @override
  String get noSeatMapBuyerHint =>
      'Организатор ещё не опубликовал схему мест для этого события.';

  @override
  String get seatAvailable => 'Свободно';

  @override
  String get seatSelected => 'Выбрано';

  @override
  String get seatHeld => 'Бронь';

  @override
  String get seatSold => 'Продано';

  @override
  String get seatUnavailable => 'Недоступно';

  @override
  String pickedOf(int picked, int needed) {
    return 'Выбрано $picked из $needed';
  }

  @override
  String get seatsHeldContinue =>
      'После продолжения места держатся за вами 10 минут.';

  @override
  String get myTickets => 'Мои билеты';

  @override
  String tabUpcomingN(int count) {
    return 'Предстоящие $count';
  }

  @override
  String tabPastN(int count) {
    return 'Прошедшие $count';
  }

  @override
  String tabRefundedN(int count) {
    return 'Возвраты $count';
  }

  @override
  String get noUpcomingTickets => 'Предстоящих билетов нет';

  @override
  String get noUpcomingTicketsHint =>
      'Купленные билеты и регистрации появятся здесь с QR-кодами.';

  @override
  String get pastTicketsHint =>
      'Билеты попадают сюда после события или возврата.';

  @override
  String get browseEvents => 'Смотреть события';

  @override
  String get dateTba => 'Дата уточняется';

  @override
  String get viewTicket => 'Открыть билет';

  @override
  String get viewTickets => 'Открыть билеты';

  @override
  String get admissionTicket => 'Входной билет';

  @override
  String get admitsOne => 'Проход для 1 человека';

  @override
  String get attendeeLabel => 'Участник';

  @override
  String get seatLabelShort => 'Место';

  @override
  String get ticketIdLabel => 'ID билета';

  @override
  String get issuedLabel => 'Выдан';

  @override
  String get qrKeepNote =>
      'Не мните и не загораживайте QR. Билет пропускает одного человека один раз — бумажная и электронная копии — один и тот же билет.';

  @override
  String get print => 'Печать';

  @override
  String get downloadPdf => 'Скачать PDF';

  @override
  String get cancelOrderTitle => 'Отменить заказ?';

  @override
  String get cancelOrderBody =>
      'Все билеты заказа станут недействительными, на входе их не пропустят. Возврат — по правилам организатора.';

  @override
  String get cancelOrder => 'Отменить заказ';

  @override
  String get orderCancelledToast => 'Заказ отменён.';

  @override
  String get ticketReady => 'Билет готов';

  @override
  String ticketsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count билета ваши',
      many: '$count билетов ваши',
      few: '$count билета ваши',
      one: '$count билет ваш',
    );
    return '$_temp0';
  }

  @override
  String confirmationSent(String email) {
    return 'Подтверждение отправлено на $email';
  }

  @override
  String get yourTickets => 'Ваши билеты';

  @override
  String get ticketsAfterPayment =>
      'Билеты выдаются после подтверждения оплаты.';

  @override
  String get typeLabel => 'Тип';

  @override
  String get showQr => 'Показать QR';

  @override
  String get showQrNote =>
      'Покажите QR с телефона или на бумаге. Каждый билет пропускает одного человека один раз.';

  @override
  String get totalLabel => 'Итого';

  @override
  String get methodLabel => 'Способ';

  @override
  String get sandboxPayment => 'Тестовая оплата';

  @override
  String get helpWithOrder => 'Помощь с заказом';
}
