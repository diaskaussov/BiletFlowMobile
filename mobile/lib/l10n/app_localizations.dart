import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @errNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером.'**
  String get errNetwork;

  /// No description provided for @errSessionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сессия истекла. Войдите снова.'**
  String get errSessionExpired;

  /// No description provided for @errForbidden.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно прав для этого действия.'**
  String get errForbidden;

  /// No description provided for @errUnexpectedResponse.
  ///
  /// In ru, this message translates to:
  /// **'Неожиданный ответ сервера.'**
  String get errUnexpectedResponse;

  /// No description provided for @errEmailInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный email.'**
  String get errEmailInvalid;

  /// No description provided for @errPasswordEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль.'**
  String get errPasswordEmpty;

  /// No description provided for @errAccountUnsupported.
  ///
  /// In ru, this message translates to:
  /// **'Этот тип аккаунта не поддерживается приложением.'**
  String get errAccountUnsupported;

  /// No description provided for @errWrongCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get errWrongCredentials;

  /// No description provided for @errNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите имя и фамилию.'**
  String get errNameRequired;

  /// No description provided for @errPasswordShort.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть не короче 6 символов.'**
  String get errPasswordShort;

  /// No description provided for @errRoleRequired.
  ///
  /// In ru, this message translates to:
  /// **'Выберите: участник или организатор.'**
  String get errRoleRequired;

  /// No description provided for @errPromoEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Введите промокод.'**
  String get errPromoEmpty;

  /// No description provided for @errPromoOtherEvent.
  ///
  /// In ru, this message translates to:
  /// **'Этот код для другого события.'**
  String get errPromoOtherEvent;

  /// No description provided for @errReversalReason.
  ///
  /// In ru, this message translates to:
  /// **'Укажите причину отмены входа.'**
  String get errReversalReason;

  /// No description provided for @errNoTicketId.
  ///
  /// In ru, this message translates to:
  /// **'Сервер не вернул ID билета, поэтому отменить вход отсюда нельзя.'**
  String get errNoTicketId;

  /// No description provided for @errPickTicket.
  ///
  /// In ru, this message translates to:
  /// **'Выберите хотя бы один билет.'**
  String get errPickTicket;

  /// No description provided for @errTicketNotInOrder.
  ///
  /// In ru, this message translates to:
  /// **'Этого билета нет в заказе.'**
  String get errTicketNotInOrder;

  /// No description provided for @errTicketAlreadyIn.
  ///
  /// In ru, this message translates to:
  /// **'Билет {label} уже отмечен.'**
  String errTicketAlreadyIn(String label);

  /// No description provided for @errTicketRefundedNoEntry.
  ///
  /// In ru, this message translates to:
  /// **'Билет {label} возвращён и недействителен.'**
  String errTicketRefundedNoEntry(String label);

  /// No description provided for @errTicketCancelledNoEntry.
  ///
  /// In ru, this message translates to:
  /// **'Билет {label} отменён и недействителен.'**
  String errTicketCancelledNoEntry(String label);

  /// No description provided for @errSeatsForType.
  ///
  /// In ru, this message translates to:
  /// **'Выберите мест для «{type}»: {count}.'**
  String errSeatsForType(int count, String type);

  /// No description provided for @errBuyerName.
  ///
  /// In ru, this message translates to:
  /// **'Укажите имя и фамилию участника.'**
  String get errBuyerName;

  /// No description provided for @errBuyerEmail.
  ///
  /// In ru, this message translates to:
  /// **'Укажите email для отправки билетов.'**
  String get errBuyerEmail;

  /// No description provided for @errSeatsFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала выберите места.'**
  String get errSeatsFirst;

  /// No description provided for @errHoldExpired.
  ///
  /// In ru, this message translates to:
  /// **'Бронь мест истекла. Выберите места заново.'**
  String get errHoldExpired;

  /// No description provided for @errEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Укажите название события.'**
  String get errEventTitle;

  /// No description provided for @errEventVenue.
  ///
  /// In ru, this message translates to:
  /// **'Укажите площадку проведения.'**
  String get errEventVenue;

  /// No description provided for @errEventCity.
  ///
  /// In ru, this message translates to:
  /// **'Укажите город.'**
  String get errEventCity;

  /// No description provided for @errEventStart.
  ///
  /// In ru, this message translates to:
  /// **'Укажите дату и время начала.'**
  String get errEventStart;

  /// No description provided for @errEventEndOrder.
  ///
  /// In ru, this message translates to:
  /// **'Окончание должно быть позже начала.'**
  String get errEventEndOrder;

  /// No description provided for @errRegCloseOrder.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация должна закрываться позже, чем открывается.'**
  String get errRegCloseOrder;

  /// No description provided for @errRegCloseBeforeEnd.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация должна закрыться до окончания события.'**
  String get errRegCloseBeforeEnd;

  /// No description provided for @errCapacityMin.
  ///
  /// In ru, this message translates to:
  /// **'Вместимость должна быть не меньше 1.'**
  String get errCapacityMin;

  /// No description provided for @errTypeName.
  ///
  /// In ru, this message translates to:
  /// **'Укажите название типа билета.'**
  String get errTypeName;

  /// No description provided for @errPriceNegative.
  ///
  /// In ru, this message translates to:
  /// **'Цена не может быть отрицательной.'**
  String get errPriceNegative;

  /// No description provided for @errQuantityMin.
  ///
  /// In ru, this message translates to:
  /// **'Количество должно быть не меньше 1.'**
  String get errQuantityMin;

  /// No description provided for @errQuantityBelowSold.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя сделать меньше уже проданных: {count}.'**
  String errQuantityBelowSold(int count);

  /// No description provided for @errPerOrderMin.
  ///
  /// In ru, this message translates to:
  /// **'Лимит на заказ должен быть не меньше 1.'**
  String get errPerOrderMin;

  /// No description provided for @errSalesEndOrder.
  ///
  /// In ru, this message translates to:
  /// **'Продажи должны заканчиваться позже, чем начинаются.'**
  String get errSalesEndOrder;

  /// No description provided for @errPublishNeedsType.
  ///
  /// In ru, this message translates to:
  /// **'Перед публикацией добавьте хотя бы один тип билета.'**
  String get errPublishNeedsType;

  /// No description provided for @errEventAlreadyCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Событие уже отменено.'**
  String get errEventAlreadyCancelled;

  /// No description provided for @errSectionsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы одну секцию.'**
  String get errSectionsEmpty;

  /// No description provided for @errSectionName.
  ///
  /// In ru, this message translates to:
  /// **'У каждой секции должно быть название.'**
  String get errSectionName;

  /// No description provided for @errSectionTwice.
  ///
  /// In ru, this message translates to:
  /// **'Секция «{name}» указана дважды.'**
  String errSectionTwice(String name);

  /// No description provided for @errRowsMin.
  ///
  /// In ru, this message translates to:
  /// **'Рядов и мест в ряду должно быть не меньше 1.'**
  String get errRowsMin;

  /// No description provided for @errTermsRequired.
  ///
  /// In ru, this message translates to:
  /// **'Сначала примите условия платных событий.'**
  String get errTermsRequired;

  /// No description provided for @errSalesAlreadyActive.
  ///
  /// In ru, this message translates to:
  /// **'Платные продажи уже активированы.'**
  String get errSalesAlreadyActive;

  /// No description provided for @errNeedPaidType.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте платный тип билета.'**
  String get errNeedPaidType;

  /// No description provided for @errNeedPayout.
  ///
  /// In ru, this message translates to:
  /// **'Сначала укажите реквизиты для выплат.'**
  String get errNeedPayout;

  /// No description provided for @errOrgName.
  ///
  /// In ru, this message translates to:
  /// **'Укажите название организации.'**
  String get errOrgName;

  /// No description provided for @errContactEmail.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный контактный email.'**
  String get errContactEmail;

  /// No description provided for @errCampaignName.
  ///
  /// In ru, this message translates to:
  /// **'Укажите название кампании.'**
  String get errCampaignName;

  /// No description provided for @errDiscountPositive.
  ///
  /// In ru, this message translates to:
  /// **'Скидка должна быть больше нуля.'**
  String get errDiscountPositive;

  /// No description provided for @errPercentMax.
  ///
  /// In ru, this message translates to:
  /// **'Скидка в процентах не может быть больше 100%.'**
  String get errPercentMax;

  /// No description provided for @errRedemptionsMin.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите хотя бы одно использование.'**
  String get errRedemptionsMin;

  /// No description provided for @errCampaignEndOrder.
  ///
  /// In ru, this message translates to:
  /// **'Кампания должна заканчиваться позже, чем начинается.'**
  String get errCampaignEndOrder;

  /// No description provided for @errOrderAlreadyRefunded.
  ///
  /// In ru, this message translates to:
  /// **'Заказ уже возвращён.'**
  String get errOrderAlreadyRefunded;

  /// No description provided for @errOrderWasCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Заказ был отменён.'**
  String get errOrderWasCancelled;

  /// No description provided for @errRefundReason.
  ///
  /// In ru, this message translates to:
  /// **'Укажите причину возврата.'**
  String get errRefundReason;

  /// No description provided for @errCampaignDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Кампания уже отключена.'**
  String get errCampaignDisabled;

  /// No description provided for @errUserIdInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите числовой ID пользователя.'**
  String get errUserIdInvalid;

  /// No description provided for @errAlreadyOnTeam.
  ///
  /// In ru, this message translates to:
  /// **'Этот человек уже в команде.'**
  String get errAlreadyOnTeam;

  /// No description provided for @errGateEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Название входа не может быть пустым.'**
  String get errGateEmpty;

  /// No description provided for @errGateLong.
  ///
  /// In ru, this message translates to:
  /// **'Слишком длинное название входа.'**
  String get errGateLong;

  /// No description provided for @errCaseEvent.
  ///
  /// In ru, this message translates to:
  /// **'Выберите событие — обращение получит его организатор.'**
  String get errCaseEvent;

  /// No description provided for @errCaseSubject.
  ///
  /// In ru, this message translates to:
  /// **'Опишите проблему в нескольких словах.'**
  String get errCaseSubject;

  /// No description provided for @errCaseMessage.
  ///
  /// In ru, this message translates to:
  /// **'Напишите сообщение для поддержки.'**
  String get errCaseMessage;

  /// No description provided for @errReplyEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сначала напишите ответ.'**
  String get errReplyEmpty;

  /// No description provided for @errOrderAlreadyCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Заказ уже отменён.'**
  String get errOrderAlreadyCancelled;

  /// No description provided for @errTicketUsedInOrder.
  ///
  /// In ru, this message translates to:
  /// **'Один из билетов заказа уже использован на входе.'**
  String get errTicketUsedInOrder;

  /// No description provided for @errSelfSuspend.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя заблокировать собственный аккаунт.'**
  String get errSelfSuspend;

  /// No description provided for @errAdminSuspend.
  ///
  /// In ru, this message translates to:
  /// **'Администраторов платформы здесь заблокировать нельзя.'**
  String get errAdminSuspend;

  /// No description provided for @errUserAlreadySuspended.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь уже заблокирован.'**
  String get errUserAlreadySuspended;

  /// No description provided for @errUserNotSuspended.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь не заблокирован.'**
  String get errUserNotSuspended;

  /// No description provided for @errSuspendReason.
  ///
  /// In ru, this message translates to:
  /// **'Укажите причину блокировки.'**
  String get errSuspendReason;

  /// No description provided for @errEventNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Событие не найдено.'**
  String get errEventNotFound;

  /// No description provided for @errTicketNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Билет не найден.'**
  String get errTicketNotFound;

  /// No description provided for @errAttendeeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Гость не найден.'**
  String get errAttendeeNotFound;

  /// No description provided for @errCheckInRefused.
  ///
  /// In ru, this message translates to:
  /// **'Сервер отклонил отметку входа.'**
  String get errCheckInRefused;

  /// No description provided for @errPromoInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Код недействителен.'**
  String get errPromoInvalid;

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'BiletFlow'**
  String get appName;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @agoJustNow.
  ///
  /// In ru, this message translates to:
  /// **'только что'**
  String get agoJustNow;

  /// No description provided for @agoMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} минуту назад} few{{count} минуты назад} many{{count} минут назад} other{{count} минуты назад}}'**
  String agoMinutes(int count);

  /// No description provided for @agoHours.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} час назад} few{{count} часа назад} many{{count} часов назад} other{{count} часа назад}}'**
  String agoHours(int count);

  /// No description provided for @agoDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день назад} few{{count} дня назад} many{{count} дней назад} other{{count} дня назад}}'**
  String agoDays(int count);

  /// No description provided for @free.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатно'**
  String get free;

  /// No description provided for @millionShort.
  ///
  /// In ru, this message translates to:
  /// **'млн'**
  String get millionShort;

  /// No description provided for @appearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @actionRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get actionRetry;

  /// No description provided for @actionNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующий'**
  String get actionNext;

  /// No description provided for @actionCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get actionSave;

  /// No description provided for @actionClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get actionClose;

  /// No description provided for @actionSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get actionSend;

  /// No description provided for @actionChange.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get actionChange;

  /// No description provided for @actionReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get actionReset;

  /// No description provided for @actionUndo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get actionUndo;

  /// No description provided for @actionKeep.
  ///
  /// In ru, this message translates to:
  /// **'Оставить'**
  String get actionKeep;

  /// No description provided for @actionOk.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get actionOk;

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @tryAgain.
  ///
  /// In ru, this message translates to:
  /// **'Попробовать снова'**
  String get tryAgain;

  /// No description provided for @noConnectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения'**
  String get noConnectionTitle;

  /// No description provided for @loadFailedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить'**
  String get loadFailedTitle;

  /// No description provided for @navScanner.
  ///
  /// In ru, this message translates to:
  /// **'Сканер'**
  String get navScanner;

  /// No description provided for @navGuests.
  ///
  /// In ru, this message translates to:
  /// **'Гости'**
  String get navGuests;

  /// No description provided for @navStats.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get navStats;

  /// No description provided for @navEvents.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get navEvents;

  /// No description provided for @navTickets.
  ///
  /// In ru, this message translates to:
  /// **'Билеты'**
  String get navTickets;

  /// No description provided for @navSupport.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get navSupport;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @navAlerts.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get navAlerts;

  /// No description provided for @navQueues.
  ///
  /// In ru, this message translates to:
  /// **'Очереди'**
  String get navQueues;

  /// No description provided for @navUsers.
  ///
  /// In ru, this message translates to:
  /// **'Пользователи'**
  String get navUsers;

  /// No description provided for @navOrders.
  ///
  /// In ru, this message translates to:
  /// **'Заказы'**
  String get navOrders;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @you.
  ///
  /// In ru, this message translates to:
  /// **'вы'**
  String get you;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @signInTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход в BiletFlow'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Покупатели, организаторы, контролёры и администраторы'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @signInButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signInButton;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление пароля'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In ru, this message translates to:
  /// **'В этой версии восстановление пароля недоступно. Контролёрам поможет организатор, остальным — support@biletflow.kz.'**
  String get forgotPasswordBody;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @showPassword.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get hidePassword;

  /// No description provided for @serverLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сервер: {address}'**
  String serverLabel(String address);

  /// No description provided for @serverTitle.
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера'**
  String get serverTitle;

  /// No description provided for @serverHint.
  ///
  /// In ru, this message translates to:
  /// **'На телефоне укажите IP компьютера в Wi‑Fi, а не localhost.'**
  String get serverHint;

  /// No description provided for @serverInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите адрес вида http://192.168.1.10:8080'**
  String get serverInvalid;

  /// No description provided for @onlineOnlyNote.
  ///
  /// In ru, this message translates to:
  /// **'Проверка билетов работает только при подключении к интернету.'**
  String get onlineOnlyNote;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registerTitle;

  /// No description provided for @registerIWant.
  ///
  /// In ru, this message translates to:
  /// **'Я хочу'**
  String get registerIWant;

  /// No description provided for @roleAttend.
  ///
  /// In ru, this message translates to:
  /// **'Посещать'**
  String get roleAttend;

  /// No description provided for @roleAttendHint.
  ///
  /// In ru, this message translates to:
  /// **'Находить события, покупать билеты, показывать QR на входе'**
  String get roleAttendHint;

  /// No description provided for @roleOrganize.
  ///
  /// In ru, this message translates to:
  /// **'Организовывать'**
  String get roleOrganize;

  /// No description provided for @roleOrganizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Создавать события, продавать билеты, назначать контролёров'**
  String get roleOrganizeHint;

  /// No description provided for @firstName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get lastName;

  /// No description provided for @phoneOptional.
  ///
  /// In ru, this message translates to:
  /// **'Телефон (необязательно)'**
  String get phoneOptional;

  /// No description provided for @passwordMin.
  ///
  /// In ru, this message translates to:
  /// **'Пароль · не менее 6 символов'**
  String get passwordMin;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get registerButton;

  /// No description provided for @registerOrganizerButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт организатора'**
  String get registerOrganizerButton;

  /// No description provided for @registerNote.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправим ссылку для подтверждения на email. Аккаунты контролёров создают организаторы.'**
  String get registerNote;

  /// No description provided for @myEvents.
  ///
  /// In ru, this message translates to:
  /// **'Мои события'**
  String get myEvents;

  /// No description provided for @noAssignedEvents.
  ///
  /// In ru, this message translates to:
  /// **'Вас пока не назначили ни на одно событие'**
  String get noAssignedEvents;

  /// No description provided for @noAssignedEventsHint.
  ///
  /// In ru, this message translates to:
  /// **'Организатор должен добавить вас как контролёра. Сообщите ему email, с которым вы вошли.'**
  String get noAssignedEventsHint;

  /// No description provided for @checkAgain.
  ///
  /// In ru, this message translates to:
  /// **'Проверить снова'**
  String get checkAgain;

  /// No description provided for @pastEvents.
  ///
  /// In ru, this message translates to:
  /// **'Прошедшие'**
  String get pastEvents;

  /// No description provided for @upcomingEvents.
  ///
  /// In ru, this message translates to:
  /// **'Предстоящие'**
  String get upcomingEvents;

  /// No description provided for @signedInAs.
  ///
  /// In ru, this message translates to:
  /// **'Вы вошли как {email}'**
  String signedInAs(String email);

  /// No description provided for @enteredOf.
  ///
  /// In ru, this message translates to:
  /// **'Вошло {checkedIn} из {registered}'**
  String enteredOf(int checkedIn, int registered);

  /// No description provided for @pointAtQr.
  ///
  /// In ru, this message translates to:
  /// **'Наведите на QR-код билета'**
  String get pointAtQr;

  /// No description provided for @torch.
  ///
  /// In ru, this message translates to:
  /// **'Фонарик'**
  String get torch;

  /// No description provided for @enterCode.
  ///
  /// In ru, this message translates to:
  /// **'Ввести код'**
  String get enterCode;

  /// No description provided for @checking.
  ///
  /// In ru, this message translates to:
  /// **'Проверяем билет…'**
  String get checking;

  /// No description provided for @lowLightTorchOn.
  ///
  /// In ru, this message translates to:
  /// **'Темно — фонарик включён'**
  String get lowLightTorchOn;

  /// No description provided for @scanPaused.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения: сканирование недоступно'**
  String get scanPaused;

  /// No description provided for @enterCodeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Код билета'**
  String get enterCodeTitle;

  /// No description provided for @enterCodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Код под QR-кодом или из письма'**
  String get enterCodeHint;

  /// No description provided for @checkCode.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get checkCode;

  /// No description provided for @cameraOffTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доступ к камере выключен'**
  String get cameraOffTitle;

  /// No description provided for @cameraOffBody.
  ///
  /// In ru, this message translates to:
  /// **'Камера нужна, чтобы читать QR-коды билетов. Включите её в Настройках → BiletFlow → Камера.'**
  String get cameraOffBody;

  /// No description provided for @openSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get openSettings;

  /// No description provided for @findGuestInstead.
  ///
  /// In ru, this message translates to:
  /// **'Найти гостя вручную'**
  String get findGuestInstead;

  /// No description provided for @cameraUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна'**
  String get cameraUnavailable;

  /// No description provided for @chooseEventFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала выберите событие'**
  String get chooseEventFirst;

  /// No description provided for @chooseEvent.
  ///
  /// In ru, this message translates to:
  /// **'Выберите событие'**
  String get chooseEvent;

  /// No description provided for @vValid.
  ///
  /// In ru, this message translates to:
  /// **'Проходите'**
  String get vValid;

  /// No description provided for @vAlreadyUsed.
  ///
  /// In ru, this message translates to:
  /// **'Билет уже использован'**
  String get vAlreadyUsed;

  /// No description provided for @vRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Этот билет только что прошёл'**
  String get vRepeat;

  /// No description provided for @vRefunded.
  ///
  /// In ru, this message translates to:
  /// **'Билет возвращён'**
  String get vRefunded;

  /// No description provided for @vCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Билет отменён'**
  String get vCancelled;

  /// No description provided for @vUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Билет не найден'**
  String get vUnknown;

  /// No description provided for @vWrongEvent.
  ///
  /// In ru, this message translates to:
  /// **'Билет на другое событие'**
  String get vWrongEvent;

  /// No description provided for @vPromo.
  ///
  /// In ru, this message translates to:
  /// **'Это промокод, а не билет'**
  String get vPromo;

  /// No description provided for @closesIn.
  ///
  /// In ru, this message translates to:
  /// **'Закроется через {seconds} с'**
  String closesIn(int seconds);

  /// No description provided for @undoEntry.
  ///
  /// In ru, this message translates to:
  /// **'Отменить вход'**
  String get undoEntry;

  /// No description provided for @entryMarkedAt.
  ///
  /// In ru, this message translates to:
  /// **'Вход отмечен в {time}'**
  String entryMarkedAt(String time);

  /// No description provided for @scannedBy.
  ///
  /// In ru, this message translates to:
  /// **'Отсканировал: {name}'**
  String scannedBy(String name);

  /// No description provided for @orderCancelledByOrganizer.
  ///
  /// In ru, this message translates to:
  /// **'Заказ отменён организатором'**
  String get orderCancelledByOrganizer;

  /// No description provided for @refundedOn.
  ///
  /// In ru, this message translates to:
  /// **'Деньги возвращены {date}'**
  String refundedOn(String date);

  /// No description provided for @refundedNoEntry.
  ///
  /// In ru, this message translates to:
  /// **'Деньги возвращены — по билету нельзя пройти'**
  String get refundedNoEntry;

  /// No description provided for @checkCodeOrFind.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте код или найдите гостя вручную'**
  String get checkCodeOrFind;

  /// No description provided for @findGuest.
  ///
  /// In ru, this message translates to:
  /// **'Найти гостя'**
  String get findGuest;

  /// No description provided for @ticketIsFor.
  ///
  /// In ru, this message translates to:
  /// **'Этот билет на:'**
  String get ticketIsFor;

  /// No description provided for @anotherEvent.
  ///
  /// In ru, this message translates to:
  /// **'Другое событие'**
  String get anotherEvent;

  /// No description provided for @switchToEvent.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к этому событию'**
  String get switchToEvent;

  /// No description provided for @campaignLabel.
  ///
  /// In ru, this message translates to:
  /// **'Кампания {name}'**
  String campaignLabel(String name);

  /// No description provided for @promoNotTicket.
  ///
  /// In ru, this message translates to:
  /// **'Промокод даёт скидку на сайте, но не пропускает на вход'**
  String get promoNotTicket;

  /// No description provided for @repeatBody.
  ///
  /// In ru, this message translates to:
  /// **'Отсканирован {seconds} с назад — это тот же вход, повторно ничего не записано'**
  String repeatBody(int seconds);

  /// No description provided for @copyTicketId.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать ID билета'**
  String get copyTicketId;

  /// No description provided for @reversedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход отменён'**
  String get reversedTitle;

  /// No description provided for @reversedBody.
  ///
  /// In ru, this message translates to:
  /// **'Билет снова действителен'**
  String get reversedBody;

  /// No description provided for @admission.
  ///
  /// In ru, this message translates to:
  /// **'1 вход'**
  String get admission;

  /// No description provided for @reverseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отменить вход для {name}?'**
  String reverseTitle(String name);

  /// No description provided for @reverseBody.
  ///
  /// In ru, this message translates to:
  /// **'Билет снова станет действительным. Отмена записывается с вашим именем и не удаляется.'**
  String get reverseBody;

  /// No description provided for @checkedInLabel.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get checkedInLabel;

  /// No description provided for @recordedBy.
  ///
  /// In ru, this message translates to:
  /// **'Отметил'**
  String get recordedBy;

  /// No description provided for @ticketLabel.
  ///
  /// In ru, this message translates to:
  /// **'Билет'**
  String get ticketLabel;

  /// No description provided for @reasonRequired.
  ///
  /// In ru, this message translates to:
  /// **'Причина (обязательно)'**
  String get reasonRequired;

  /// No description provided for @reasonHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: отсканировали не того человека'**
  String get reasonHint;

  /// No description provided for @guestSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя, email, код билета или номер заказа'**
  String get guestSearchHint;

  /// No description provided for @statusValid.
  ///
  /// In ru, this message translates to:
  /// **'Действителен'**
  String get statusValid;

  /// No description provided for @statusUsed.
  ///
  /// In ru, this message translates to:
  /// **'Использован'**
  String get statusUsed;

  /// No description provided for @statusRefunded.
  ///
  /// In ru, this message translates to:
  /// **'Возвращён'**
  String get statusRefunded;

  /// No description provided for @statusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменён'**
  String get statusCancelled;

  /// No description provided for @markEntry.
  ///
  /// In ru, this message translates to:
  /// **'Отметить вход'**
  String get markEntry;

  /// No description provided for @guestSearchStart.
  ///
  /// In ru, this message translates to:
  /// **'Начните вводить имя — минимум 2 символа'**
  String get guestSearchStart;

  /// No description provided for @guestNoMatches.
  ///
  /// In ru, this message translates to:
  /// **'Никого не найдено по «{query}»'**
  String guestNoMatches(String query);

  /// No description provided for @guestNoMatchesHint.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте написание или ищите по коду билета'**
  String get guestNoMatchesHint;

  /// No description provided for @filterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все {count}'**
  String filterAll(int count);

  /// No description provided for @filterNotArrived.
  ///
  /// In ru, this message translates to:
  /// **'Не пришли {count}'**
  String filterNotArrived(int count);

  /// No description provided for @checkedInToast.
  ///
  /// In ru, this message translates to:
  /// **'Вход отмечен'**
  String get checkedInToast;

  /// No description provided for @ticketsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} билет} few{{count} билета} many{{count} билетов} other{{count} билета}}'**
  String ticketsCount(int count);

  /// No description provided for @guest.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get guest;

  /// No description provided for @ticketsInOrder.
  ///
  /// In ru, this message translates to:
  /// **'Билеты в заказе'**
  String get ticketsInOrder;

  /// No description provided for @checkInAll.
  ///
  /// In ru, this message translates to:
  /// **'Отметить все билеты ({count})'**
  String checkInAll(int count);

  /// No description provided for @history.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get history;

  /// No description provided for @manualNote.
  ///
  /// In ru, this message translates to:
  /// **'Ручная отметка записывается на ваше имя и видна организатору.'**
  String get manualNote;

  /// No description provided for @notArrivedCount.
  ///
  /// In ru, this message translates to:
  /// **'Не пришли: {count}'**
  String notArrivedCount(int count);

  /// No description provided for @allUsedOrVoid.
  ///
  /// In ru, this message translates to:
  /// **'Все билеты использованы или недействительны'**
  String get allUsedOrVoid;

  /// No description provided for @recordUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Запись недоступна'**
  String get recordUnavailable;

  /// No description provided for @entered.
  ///
  /// In ru, this message translates to:
  /// **'Вошло'**
  String get entered;

  /// No description provided for @stillToCome.
  ///
  /// In ru, this message translates to:
  /// **'Осталось гостей: {count}'**
  String stillToCome(int count);

  /// No description provided for @registered.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрировано'**
  String get registered;

  /// No description provided for @notArrived.
  ///
  /// In ru, this message translates to:
  /// **'Не пришли'**
  String get notArrived;

  /// No description provided for @cancelledStat.
  ///
  /// In ru, this message translates to:
  /// **'Отменено'**
  String get cancelledStat;

  /// No description provided for @refundedStat.
  ///
  /// In ru, this message translates to:
  /// **'Возвращено'**
  String get refundedStat;

  /// No description provided for @reversals.
  ///
  /// In ru, this message translates to:
  /// **'Отмен входа'**
  String get reversals;

  /// No description provided for @byTicketType.
  ///
  /// In ru, this message translates to:
  /// **'По типам билетов'**
  String get byTicketType;

  /// No description provided for @recentEntries.
  ///
  /// In ru, this message translates to:
  /// **'Последние входы'**
  String get recentEntries;

  /// No description provided for @noEntriesYet.
  ///
  /// In ru, this message translates to:
  /// **'Входов пока нет'**
  String get noEntriesYet;

  /// No description provided for @statsUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Статистика недоступна'**
  String get statsUnavailable;

  /// No description provided for @offlineBody.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте интернет и попробуйте снова'**
  String get offlineBody;

  /// No description provided for @connectionRestored.
  ///
  /// In ru, this message translates to:
  /// **'Связь восстановлена'**
  String get connectionRestored;

  /// No description provided for @stillOffline.
  ///
  /// In ru, this message translates to:
  /// **'Связи с сервером всё ещё нет'**
  String get stillOffline;

  /// No description provided for @lastSync.
  ///
  /// In ru, this message translates to:
  /// **'Последняя синхронизация: {time}'**
  String lastSync(String time);

  /// No description provided for @offlineNote.
  ///
  /// In ru, this message translates to:
  /// **'Билеты проверяются на сервере, поэтому без связи сканирование приостановлено. На телефоне ничего не сохраняется.'**
  String get offlineNote;

  /// No description provided for @scanningSection.
  ///
  /// In ru, this message translates to:
  /// **'Сканирование'**
  String get scanningSection;

  /// No description provided for @torchDefault.
  ///
  /// In ru, this message translates to:
  /// **'Фонарик включён по умолчанию'**
  String get torchDefault;

  /// No description provided for @soundOnResult.
  ///
  /// In ru, this message translates to:
  /// **'Звук при результате'**
  String get soundOnResult;

  /// No description provided for @vibrateOnReject.
  ///
  /// In ru, this message translates to:
  /// **'Вибрация при отказе'**
  String get vibrateOnReject;

  /// No description provided for @gateSection.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get gateSection;

  /// No description provided for @assignedGate.
  ///
  /// In ru, this message translates to:
  /// **'Мой вход'**
  String get assignedGate;

  /// No description provided for @roleEventAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Контролёр'**
  String get roleEventAdmin;

  /// No description provided for @roleAttendee.
  ///
  /// In ru, this message translates to:
  /// **'Покупатель'**
  String get roleAttendee;

  /// No description provided for @roleOrganizer.
  ///
  /// In ru, this message translates to:
  /// **'Организатор'**
  String get roleOrganizer;

  /// No description provided for @rolePlatformAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Администратор'**
  String get rolePlatformAdmin;

  /// No description provided for @eventsCount.
  ///
  /// In ru, this message translates to:
  /// **'Событий: {count}'**
  String eventsCount(int count);

  /// No description provided for @server.
  ///
  /// In ru, this message translates to:
  /// **'Сервер'**
  String get server;

  /// No description provided for @demoBuild.
  ///
  /// In ru, this message translates to:
  /// **'Демо-версия: все платежи ненастоящие, деньги не списываются.'**
  String get demoBuild;

  /// No description provided for @account.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @organizerProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль организатора и выплаты'**
  String get organizerProfile;

  /// No description provided for @evDraft.
  ///
  /// In ru, this message translates to:
  /// **'Черновик'**
  String get evDraft;

  /// No description provided for @evPublished.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовано'**
  String get evPublished;

  /// No description provided for @evCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменено'**
  String get evCancelled;

  /// No description provided for @evCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Завершено'**
  String get evCompleted;

  /// No description provided for @evLive.
  ///
  /// In ru, this message translates to:
  /// **'Идёт сейчас'**
  String get evLive;

  /// No description provided for @visPublic.
  ///
  /// In ru, this message translates to:
  /// **'Публичное'**
  String get visPublic;

  /// No description provided for @visUnlisted.
  ///
  /// In ru, this message translates to:
  /// **'По ссылке'**
  String get visUnlisted;

  /// No description provided for @visPrivate.
  ///
  /// In ru, this message translates to:
  /// **'Приватное'**
  String get visPrivate;

  /// No description provided for @orderPending.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает оплаты'**
  String get orderPending;

  /// No description provided for @orderPaid.
  ///
  /// In ru, this message translates to:
  /// **'Оплачен'**
  String get orderPaid;

  /// No description provided for @orderCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменён'**
  String get orderCancelled;

  /// No description provided for @orderRefunded.
  ///
  /// In ru, this message translates to:
  /// **'Возвращён'**
  String get orderRefunded;

  /// No description provided for @caseOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыто'**
  String get caseOpen;

  /// No description provided for @caseInProgress.
  ///
  /// In ru, this message translates to:
  /// **'В работе'**
  String get caseInProgress;

  /// No description provided for @caseWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Ждём ответа'**
  String get caseWaiting;

  /// No description provided for @caseResolved.
  ///
  /// In ru, this message translates to:
  /// **'Решено'**
  String get caseResolved;

  /// No description provided for @catTicketDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка билета'**
  String get catTicketDelivery;

  /// No description provided for @catPayment.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get catPayment;

  /// No description provided for @catRefund.
  ///
  /// In ru, this message translates to:
  /// **'Возврат'**
  String get catRefund;

  /// No description provided for @catSeating.
  ///
  /// In ru, this message translates to:
  /// **'Места'**
  String get catSeating;

  /// No description provided for @catEventInfo.
  ///
  /// In ru, this message translates to:
  /// **'Информация о событии'**
  String get catEventInfo;

  /// No description provided for @catCheckIn.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get catCheckIn;

  /// No description provided for @catAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get catAccount;

  /// No description provided for @catActivation.
  ///
  /// In ru, this message translates to:
  /// **'Активация продаж'**
  String get catActivation;

  /// No description provided for @catTechnical.
  ///
  /// In ru, this message translates to:
  /// **'Техническая проблема'**
  String get catTechnical;

  /// No description provided for @auditEventChanges.
  ///
  /// In ru, this message translates to:
  /// **'Изменения события'**
  String get auditEventChanges;

  /// No description provided for @auditRefunds.
  ///
  /// In ru, this message translates to:
  /// **'Возвраты'**
  String get auditRefunds;

  /// No description provided for @auditCampaigns.
  ///
  /// In ru, this message translates to:
  /// **'Промо'**
  String get auditCampaigns;

  /// No description provided for @auditCheckIns.
  ///
  /// In ru, this message translates to:
  /// **'Входы'**
  String get auditCheckIns;

  /// No description provided for @auditSupport.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get auditSupport;

  /// No description provided for @seatLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сектор {section} · ряд {row} · место {number}'**
  String seatLabel(String section, String row, String number);

  /// No description provided for @secOverview.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get secOverview;

  /// No description provided for @secTickets.
  ///
  /// In ru, this message translates to:
  /// **'Билеты'**
  String get secTickets;

  /// No description provided for @secSeating.
  ///
  /// In ru, this message translates to:
  /// **'Схема зала'**
  String get secSeating;

  /// No description provided for @secOrders.
  ///
  /// In ru, this message translates to:
  /// **'Заказы'**
  String get secOrders;

  /// No description provided for @secPromo.
  ///
  /// In ru, this message translates to:
  /// **'Промо'**
  String get secPromo;

  /// No description provided for @secStaff.
  ///
  /// In ru, this message translates to:
  /// **'Персонал'**
  String get secStaff;

  /// No description provided for @secSales.
  ///
  /// In ru, this message translates to:
  /// **'Продажи'**
  String get secSales;

  /// No description provided for @secHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get secHistory;

  /// No description provided for @secCheckIn.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get secCheckIn;

  /// No description provided for @eventActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия с событием'**
  String get eventActions;

  /// No description provided for @actEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get actEdit;

  /// No description provided for @actDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'Дублировать'**
  String get actDuplicate;

  /// No description provided for @actPublish.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовать'**
  String get actPublish;

  /// No description provided for @actUnpublish.
  ///
  /// In ru, this message translates to:
  /// **'Снять с публикации'**
  String get actUnpublish;

  /// No description provided for @actCancelEvent.
  ///
  /// In ru, this message translates to:
  /// **'Отменить событие'**
  String get actCancelEvent;

  /// No description provided for @cancelEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отменить событие?'**
  String get cancelEventTitle;

  /// No description provided for @cancelEventBody.
  ///
  /// In ru, this message translates to:
  /// **'Продажи остановятся, все билеты станут недействительными, участники получат уведомление. Записи останутся в истории.'**
  String get cancelEventBody;

  /// No description provided for @publishedToast.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовано — регистрация открыта.'**
  String get publishedToast;

  /// No description provided for @unpublishedToast.
  ///
  /// In ru, this message translates to:
  /// **'Снято с публикации — снова черновик.'**
  String get unpublishedToast;

  /// No description provided for @cancelledToast.
  ///
  /// In ru, this message translates to:
  /// **'Событие отменено.'**
  String get cancelledToast;

  /// No description provided for @duplicatedToast.
  ///
  /// In ru, this message translates to:
  /// **'Создан черновик-копия без заказов, билетов и входов.'**
  String get duplicatedToast;

  /// No description provided for @salesNotActive.
  ///
  /// In ru, this message translates to:
  /// **'Платные продажи не активированы — покупатели не могут купить платные билеты'**
  String get salesNotActive;

  /// No description provided for @actActivate.
  ///
  /// In ru, this message translates to:
  /// **'Активировать'**
  String get actActivate;

  /// No description provided for @kpiSold.
  ///
  /// In ru, this message translates to:
  /// **'Продано'**
  String get kpiSold;

  /// No description provided for @kpiGross.
  ///
  /// In ru, this message translates to:
  /// **'Валовая выручка'**
  String get kpiGross;

  /// No description provided for @kpiNet.
  ///
  /// In ru, this message translates to:
  /// **'Чистая выручка'**
  String get kpiNet;

  /// No description provided for @kpiAttendance.
  ///
  /// In ru, this message translates to:
  /// **'Явка'**
  String get kpiAttendance;

  /// No description provided for @kpiOrders.
  ///
  /// In ru, this message translates to:
  /// **'Заказов'**
  String get kpiOrders;

  /// No description provided for @kpiDiscounts.
  ///
  /// In ru, this message translates to:
  /// **'Скидки'**
  String get kpiDiscounts;

  /// No description provided for @kpiRefunds.
  ///
  /// In ru, this message translates to:
  /// **'Возвраты'**
  String get kpiRefunds;

  /// No description provided for @kpiRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось'**
  String get kpiRemaining;

  /// No description provided for @salesByType.
  ///
  /// In ru, this message translates to:
  /// **'Продажи по типам билетов'**
  String get salesByType;

  /// No description provided for @promoEffect.
  ///
  /// In ru, this message translates to:
  /// **'Эффективность промокодов'**
  String get promoEffect;

  /// No description provided for @redeemedOf.
  ///
  /// In ru, this message translates to:
  /// **'{used} из {max}'**
  String redeemedOf(String used, String max);

  /// No description provided for @redeemed.
  ///
  /// In ru, this message translates to:
  /// **'{count} исп.'**
  String redeemed(int count);

  /// No description provided for @salesOverTime.
  ///
  /// In ru, this message translates to:
  /// **'Продажи по дням'**
  String get salesOverTime;

  /// No description provided for @noOrdersYet.
  ///
  /// In ru, this message translates to:
  /// **'Заказов пока нет.'**
  String get noOrdersYet;

  /// No description provided for @eventFallback.
  ///
  /// In ru, this message translates to:
  /// **'Событие'**
  String get eventFallback;

  /// No description provided for @createEvent.
  ///
  /// In ru, this message translates to:
  /// **'Создать событие'**
  String get createEvent;

  /// No description provided for @firstEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте первое событие'**
  String get firstEventTitle;

  /// No description provided for @firstEventBody.
  ///
  /// In ru, this message translates to:
  /// **'Создание событий и бесплатные билеты ничего не стоят. Платные продажи активируются для каждого события отдельно.'**
  String get firstEventBody;

  /// No description provided for @filterAllN.
  ///
  /// In ru, this message translates to:
  /// **'Все {count}'**
  String filterAllN(int count);

  /// No description provided for @filterDraftsN.
  ///
  /// In ru, this message translates to:
  /// **'Черновики {count}'**
  String filterDraftsN(int count);

  /// No description provided for @filterPublishedN.
  ///
  /// In ru, this message translates to:
  /// **'Опубликованные {count}'**
  String filterPublishedN(int count);

  /// No description provided for @filterLiveN.
  ///
  /// In ru, this message translates to:
  /// **'Идут {count}'**
  String filterLiveN(int count);

  /// No description provided for @filterPastN.
  ///
  /// In ru, this message translates to:
  /// **'Прошедшие {count}'**
  String filterPastN(int count);

  /// No description provided for @filterCancelledN.
  ///
  /// In ru, this message translates to:
  /// **'Отменённые {count}'**
  String filterCancelledN(int count);

  /// No description provided for @searchByTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по названию'**
  String get searchByTitle;

  /// No description provided for @soldOf.
  ///
  /// In ru, this message translates to:
  /// **'Продано {sold} / {total}'**
  String soldOf(String sold, String total);

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @noNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомлений пока нет'**
  String get noNotifications;

  /// No description provided for @noNotificationsHint.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся заказы, возвраты и ответы поддержки.'**
  String get noNotificationsHint;

  /// No description provided for @demoPayments.
  ///
  /// In ru, this message translates to:
  /// **'Демо-версия: оплата идёт через тестовую систему, деньги не списываются, карты не сохраняются.'**
  String get demoPayments;

  /// No description provided for @ordersSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Покупатель или № заказа'**
  String get ordersSearchHint;

  /// No description provided for @filtersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filtersTitle;

  /// No description provided for @attAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get attAll;

  /// No description provided for @attCheckedIn.
  ///
  /// In ru, this message translates to:
  /// **'Вошли'**
  String get attCheckedIn;

  /// No description provided for @attNotArrived.
  ///
  /// In ru, this message translates to:
  /// **'Не пришли'**
  String get attNotArrived;

  /// No description provided for @attRefunded.
  ///
  /// In ru, this message translates to:
  /// **'Возвраты и отмены'**
  String get attRefunded;

  /// No description provided for @attCampaign.
  ///
  /// In ru, this message translates to:
  /// **'С промокодом'**
  String get attCampaign;

  /// No description provided for @exportCsv.
  ///
  /// In ru, this message translates to:
  /// **'Выгрузить CSV'**
  String get exportCsv;

  /// No description provided for @orderNo.
  ///
  /// In ru, this message translates to:
  /// **'№{id}'**
  String orderNo(String id);

  /// No description provided for @noOrder.
  ///
  /// In ru, this message translates to:
  /// **'Без заказа'**
  String get noOrder;

  /// No description provided for @refundMoney.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть деньги'**
  String get refundMoney;

  /// No description provided for @refundTitle.
  ///
  /// In ru, this message translates to:
  /// **'Возврат по заказу №{id}'**
  String refundTitle(String id);

  /// No description provided for @buyer.
  ///
  /// In ru, this message translates to:
  /// **'Покупатель'**
  String get buyer;

  /// No description provided for @positions.
  ///
  /// In ru, this message translates to:
  /// **'Позиции'**
  String get positions;

  /// No description provided for @toRefund.
  ///
  /// In ru, this message translates to:
  /// **'К возврату'**
  String get toRefund;

  /// No description provided for @reasonStar.
  ///
  /// In ru, this message translates to:
  /// **'Причина *'**
  String get reasonStar;

  /// No description provided for @refundReasonHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: покупатель не сможет посетить событие'**
  String get refundReasonHint;

  /// No description provided for @refundConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть {amount}'**
  String refundConfirm(String amount);

  /// No description provided for @refundedToast.
  ///
  /// In ru, this message translates to:
  /// **'Деньги возвращены. Покупатель получит письмо.'**
  String get refundedToast;

  /// No description provided for @refundUsedWarning.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} билет уже прошёл вход} few{{count} билета уже прошли вход} many{{count} билетов уже прошли вход} other{{count} билета уже прошли вход}}. Возврат не отменяет вход.'**
  String refundUsedWarning(int count);

  /// No description provided for @refundNote.
  ///
  /// In ru, this message translates to:
  /// **'Билеты сразу станут недействительными, места вернутся в продажу.'**
  String get refundNote;

  /// No description provided for @orderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ'**
  String get orderTitle;

  /// No description provided for @statusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusLabel;

  /// No description provided for @discountCode.
  ///
  /// In ru, this message translates to:
  /// **'Скидка {code}'**
  String discountCode(String code);

  /// No description provided for @paidLabel.
  ///
  /// In ru, this message translates to:
  /// **'Оплачено'**
  String get paidLabel;

  /// No description provided for @placedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Оформлен'**
  String get placedLabel;

  /// No description provided for @usedOfTotal.
  ///
  /// In ru, this message translates to:
  /// **'{used} из {total}'**
  String usedOfTotal(String used, String total);

  /// No description provided for @noOrdersMatch.
  ///
  /// In ru, this message translates to:
  /// **'Нет заказов по запросу'**
  String get noOrdersMatch;

  /// No description provided for @orderNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Заказ не найден'**
  String get orderNotFound;

  /// No description provided for @errOrderNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Заказ не найден.'**
  String get errOrderNotFound;

  /// No description provided for @errOrderNoEvent.
  ///
  /// In ru, this message translates to:
  /// **'У заказа нет события.'**
  String get errOrderNoEvent;

  /// No description provided for @errRowInvalid.
  ///
  /// In ru, this message translates to:
  /// **'У каждого ряда должна быть подпись и хотя бы одно место.'**
  String get errRowInvalid;

  /// No description provided for @errSeatsOverTickets.
  ///
  /// In ru, this message translates to:
  /// **'В схеме {seats} мест «{name}», а доступно {quantity} билетов — увеличьте количество'**
  String errSeatsOverTickets(String name, int seats, int quantity);

  /// No description provided for @seatPreview.
  ///
  /// In ru, this message translates to:
  /// **'Превью · {count, plural, one{{count} место} few{{count} места} many{{count} мест} other{{count} места}}'**
  String seatPreview(int count);

  /// No description provided for @fullScreen.
  ///
  /// In ru, this message translates to:
  /// **'На весь экран'**
  String get fullScreen;

  /// No description provided for @stage.
  ///
  /// In ru, this message translates to:
  /// **'СЦЕНА'**
  String get stage;

  /// No description provided for @sectionsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Секции'**
  String get sectionsTitle;

  /// No description provided for @rowsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} ряд} few{{count} ряда} many{{count} рядов} other{{count} ряда}}'**
  String rowsCount(int count);

  /// No description provided for @seatsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} место} few{{count} места} many{{count} мест} other{{count} места}}'**
  String seatsCount(int count);

  /// No description provided for @modeQuick.
  ///
  /// In ru, this message translates to:
  /// **'Быстро'**
  String get modeQuick;

  /// No description provided for @modeManual.
  ///
  /// In ru, this message translates to:
  /// **'Вручную'**
  String get modeManual;

  /// No description provided for @sectionName.
  ///
  /// In ru, this message translates to:
  /// **'Название секции'**
  String get sectionName;

  /// No description provided for @rowsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Рядов'**
  String get rowsLabel;

  /// No description provided for @seatsPerRowLabel.
  ///
  /// In ru, this message translates to:
  /// **'Мест в ряду'**
  String get seatsPerRowLabel;

  /// No description provided for @rowLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ряд'**
  String get rowLabel;

  /// No description provided for @seatsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Мест'**
  String get seatsLabel;

  /// No description provided for @addRow.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ряд'**
  String get addRow;

  /// No description provided for @addSection.
  ///
  /// In ru, this message translates to:
  /// **'Добавить секцию'**
  String get addSection;

  /// No description provided for @saveMap.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить схему'**
  String get saveMap;

  /// No description provided for @deleteMap.
  ///
  /// In ru, this message translates to:
  /// **'Удалить схему'**
  String get deleteMap;

  /// No description provided for @deleteMapTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить схему зала?'**
  String get deleteMapTitle;

  /// No description provided for @deleteMapBody.
  ///
  /// In ru, this message translates to:
  /// **'Места пропадут, и покупатели не смогут их выбирать.'**
  String get deleteMapBody;

  /// No description provided for @mapSaved.
  ///
  /// In ru, this message translates to:
  /// **'Схема сохранена.'**
  String get mapSaved;

  /// No description provided for @mapDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Схема удалена.'**
  String get mapDeleted;

  /// No description provided for @mapSoldLocked.
  ///
  /// In ru, this message translates to:
  /// **'Места уже проданы — схему нельзя удалить.'**
  String get mapSoldLocked;

  /// No description provided for @noSeatMapYet.
  ///
  /// In ru, this message translates to:
  /// **'Схемы пока нет. Добавьте секцию — каждая продаётся по цене своего типа билета.'**
  String get noSeatMapYet;

  /// No description provided for @needTicketTypeFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала добавьте тип билета — секции продаются по его цене.'**
  String get needTicketTypeFirst;

  /// No description provided for @ticketTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип билета'**
  String get ticketTypeLabel;

  /// No description provided for @removeSection.
  ///
  /// In ru, this message translates to:
  /// **'Удалить секцию'**
  String get removeSection;

  /// No description provided for @sectionDefault.
  ///
  /// In ru, this message translates to:
  /// **'Сектор {name}'**
  String sectionDefault(String name);

  /// No description provided for @actionDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get actionDelete;

  /// No description provided for @activationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Активация платных продаж'**
  String get activationTitle;

  /// No description provided for @activationProgress.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено {done} из {total} условий. Пока продажи не активированы, доступны только бесплатные билеты.'**
  String activationProgress(int done, int total);

  /// No description provided for @chkPaidType.
  ///
  /// In ru, this message translates to:
  /// **'Есть платный тип билета'**
  String get chkPaidType;

  /// No description provided for @chkPaidTypeMissing.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте тип билета с ценой больше нуля'**
  String get chkPaidTypeMissing;

  /// No description provided for @chkIdentity.
  ///
  /// In ru, this message translates to:
  /// **'Личность подтверждена'**
  String get chkIdentity;

  /// No description provided for @chkIdentityMissing.
  ///
  /// In ru, this message translates to:
  /// **'Тестовая проверка в профиле организатора'**
  String get chkIdentityMissing;

  /// No description provided for @chkPayout.
  ///
  /// In ru, this message translates to:
  /// **'Реквизиты для выплат подтверждены'**
  String get chkPayout;

  /// No description provided for @chkPayoutMissing.
  ///
  /// In ru, this message translates to:
  /// **'Укажите банк и номер счёта'**
  String get chkPayoutMissing;

  /// No description provided for @chkFee.
  ///
  /// In ru, this message translates to:
  /// **'Комиссия оплачена'**
  String get chkFee;

  /// No description provided for @chkFeeMissing.
  ///
  /// In ru, this message translates to:
  /// **'Разовая комиссия за это событие — спишется при активации (тест)'**
  String get chkFeeMissing;

  /// No description provided for @doneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get doneLabel;

  /// No description provided for @fixLink.
  ///
  /// In ru, this message translates to:
  /// **'Исправить →'**
  String get fixLink;

  /// No description provided for @termsAccept.
  ///
  /// In ru, this message translates to:
  /// **'Принимаю условия платных продаж: возвраты, чарджбэки, сроки выплат'**
  String get termsAccept;

  /// No description provided for @activateButton.
  ///
  /// In ru, this message translates to:
  /// **'Активировать платные продажи'**
  String get activateButton;

  /// No description provided for @activatedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Продажи активированы'**
  String get activatedTitle;

  /// No description provided for @activatedBody.
  ///
  /// In ru, this message translates to:
  /// **'Покупатели могут приобретать платные билеты'**
  String get activatedBody;

  /// No description provided for @activatedToast.
  ///
  /// In ru, this message translates to:
  /// **'Платные продажи активированы (тест).'**
  String get activatedToast;

  /// No description provided for @demoActivation.
  ///
  /// In ru, this message translates to:
  /// **'Проверка личности, комиссия, оплаты и выплаты идут через тестовую систему. Деньги не списываются.'**
  String get demoActivation;

  /// No description provided for @orgProfileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль организатора'**
  String get orgProfileTitle;

  /// No description provided for @orgProfileSub.
  ///
  /// In ru, this message translates to:
  /// **'Контакты и выплаты'**
  String get orgProfileSub;

  /// No description provided for @identityOk.
  ///
  /// In ru, this message translates to:
  /// **'Личность подтверждена'**
  String get identityOk;

  /// No description provided for @identityNo.
  ///
  /// In ru, this message translates to:
  /// **'Личность не подтверждена'**
  String get identityNo;

  /// No description provided for @payoutOk.
  ///
  /// In ru, this message translates to:
  /// **'Выплаты подтверждены'**
  String get payoutOk;

  /// No description provided for @payoutNo.
  ///
  /// In ru, this message translates to:
  /// **'Выплаты не подтверждены'**
  String get payoutNo;

  /// No description provided for @organization.
  ///
  /// In ru, this message translates to:
  /// **'Организация'**
  String get organization;

  /// No description provided for @orgName.
  ///
  /// In ru, this message translates to:
  /// **'Название организации'**
  String get orgName;

  /// No description provided for @descriptionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get descriptionLabel;

  /// No description provided for @contactEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email для связи'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон для связи'**
  String get contactPhone;

  /// No description provided for @website.
  ///
  /// In ru, this message translates to:
  /// **'Сайт'**
  String get website;

  /// No description provided for @payoutSection.
  ///
  /// In ru, this message translates to:
  /// **'Счёт для выплат · тест'**
  String get payoutSection;

  /// No description provided for @bank.
  ///
  /// In ru, this message translates to:
  /// **'Банк'**
  String get bank;

  /// No description provided for @accountNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер счёта'**
  String get accountNumber;

  /// No description provided for @accountHolder.
  ///
  /// In ru, this message translates to:
  /// **'Владелец счёта'**
  String get accountHolder;

  /// No description provided for @demoPayout.
  ///
  /// In ru, this message translates to:
  /// **'Реквизиты используются только для тестовой выплаты. Реальных переводов нет.'**
  String get demoPayout;

  /// No description provided for @saveProfile.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить профиль'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In ru, this message translates to:
  /// **'Профиль сохранён.'**
  String get profileSaved;

  /// No description provided for @issued.
  ///
  /// In ru, this message translates to:
  /// **'Выдано'**
  String get issued;

  /// No description provided for @available.
  ///
  /// In ru, this message translates to:
  /// **'Доступно'**
  String get available;

  /// No description provided for @refundedVoid.
  ///
  /// In ru, this message translates to:
  /// **'Возвраты / аннул.'**
  String get refundedVoid;

  /// No description provided for @noTicketTypes.
  ///
  /// In ru, this message translates to:
  /// **'Типов билетов пока нет'**
  String get noTicketTypes;

  /// No description provided for @noTicketTypesHint.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы один бесплатный или платный тип перед публикацией.'**
  String get noTicketTypesHint;

  /// No description provided for @ttHidden.
  ///
  /// In ru, this message translates to:
  /// **'Скрыт'**
  String get ttHidden;

  /// No description provided for @ttSoldOut.
  ///
  /// In ru, this message translates to:
  /// **'Распродан'**
  String get ttSoldOut;

  /// No description provided for @ttOnSale.
  ///
  /// In ru, this message translates to:
  /// **'В продаже'**
  String get ttOnSale;

  /// No description provided for @ttNotOnSale.
  ///
  /// In ru, this message translates to:
  /// **'Не продаётся'**
  String get ttNotOnSale;

  /// No description provided for @priceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get priceLabel;

  /// No description provided for @maxPerOrder.
  ///
  /// In ru, this message translates to:
  /// **'Макс. в заказе'**
  String get maxPerOrder;

  /// No description provided for @salesWindow.
  ///
  /// In ru, this message translates to:
  /// **'Продажи'**
  String get salesWindow;

  /// No description provided for @salesNow.
  ///
  /// In ru, this message translates to:
  /// **'сейчас'**
  String get salesNow;

  /// No description provided for @salesUntilEvent.
  ///
  /// In ru, this message translates to:
  /// **'до события'**
  String get salesUntilEvent;

  /// No description provided for @actHide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get actHide;

  /// No description provided for @hiddenToast.
  ///
  /// In ru, this message translates to:
  /// **'Тип снят с продажи. Проданные билеты действуют.'**
  String get hiddenToast;

  /// No description provided for @ttAdded.
  ///
  /// In ru, this message translates to:
  /// **'Тип билета добавлен.'**
  String get ttAdded;

  /// No description provided for @savedToast.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено.'**
  String get savedToast;

  /// No description provided for @addTicketType.
  ///
  /// In ru, this message translates to:
  /// **'Добавить тип билета'**
  String get addTicketType;

  /// No description provided for @newTicketType.
  ///
  /// In ru, this message translates to:
  /// **'Новый тип билета'**
  String get newTicketType;

  /// No description provided for @editTicketType.
  ///
  /// In ru, this message translates to:
  /// **'Изменить тип билета'**
  String get editTicketType;

  /// No description provided for @nameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get nameLabel;

  /// No description provided for @freeTicket.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатный билет'**
  String get freeTicket;

  /// No description provided for @priceKzt.
  ///
  /// In ru, this message translates to:
  /// **'Цена, ₸'**
  String get priceKzt;

  /// No description provided for @quantityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get quantityLabel;

  /// No description provided for @salesStartOpt.
  ///
  /// In ru, this message translates to:
  /// **'Начало продаж (необязательно)'**
  String get salesStartOpt;

  /// No description provided for @salesEndOpt.
  ///
  /// In ru, this message translates to:
  /// **'Конец продаж (необязательно)'**
  String get salesEndOpt;

  /// No description provided for @paidNeedsActivation.
  ///
  /// In ru, this message translates to:
  /// **'Платные билеты продаются только после активации продаж для этого события.'**
  String get paidNeedsActivation;

  /// No description provided for @pickDateTime.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату и время'**
  String get pickDateTime;

  /// No description provided for @campaignQrTitle.
  ///
  /// In ru, this message translates to:
  /// **'QR кампании — это не билет'**
  String get campaignQrTitle;

  /// No description provided for @codeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код'**
  String get codeLabel;

  /// No description provided for @linkLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка'**
  String get linkLabel;

  /// No description provided for @campaignQrNote.
  ///
  /// In ru, this message translates to:
  /// **'Открывает страницу события с уже применённым {code}. В ссылке только код, без цены — его проверяет сервер. Сканер на входе такой QR не принимает.'**
  String campaignQrNote(String code);

  /// No description provided for @shareLink.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться ссылкой'**
  String get shareLink;

  /// No description provided for @copyCode.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать код'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In ru, this message translates to:
  /// **'Код скопирован.'**
  String get codeCopied;

  /// No description provided for @noCampaigns.
  ///
  /// In ru, this message translates to:
  /// **'Кампаний пока нет'**
  String get noCampaigns;

  /// No description provided for @noCampaignsHint.
  ///
  /// In ru, this message translates to:
  /// **'Кампания даёт скидку по промокоду и отслеживаемому QR.'**
  String get noCampaignsHint;

  /// No description provided for @campLive.
  ///
  /// In ru, this message translates to:
  /// **'Активна'**
  String get campLive;

  /// No description provided for @campNotLive.
  ///
  /// In ru, this message translates to:
  /// **'Не активна'**
  String get campNotLive;

  /// No description provided for @campDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Отключена'**
  String get campDisabled;

  /// No description provided for @codeHidden.
  ///
  /// In ru, this message translates to:
  /// **'Сервер не вернул код'**
  String get codeHidden;

  /// No description provided for @discountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Скидка'**
  String get discountLabel;

  /// No description provided for @percentOff.
  ///
  /// In ru, this message translates to:
  /// **'−{value}%'**
  String percentOff(String value);

  /// No description provided for @amountOff.
  ///
  /// In ru, this message translates to:
  /// **'−{value}'**
  String amountOff(String value);

  /// No description provided for @usedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Использовано'**
  String get usedLabel;

  /// No description provided for @validLabel.
  ///
  /// In ru, this message translates to:
  /// **'Действует'**
  String get validLabel;

  /// No description provided for @validOpen.
  ///
  /// In ru, this message translates to:
  /// **'без срока'**
  String get validOpen;

  /// No description provided for @qrAndLink.
  ///
  /// In ru, this message translates to:
  /// **'QR и ссылка'**
  String get qrAndLink;

  /// No description provided for @actDisable.
  ///
  /// In ru, this message translates to:
  /// **'Отключить'**
  String get actDisable;

  /// No description provided for @campaignDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Кампания отключена.'**
  String get campaignDisabled;

  /// No description provided for @campaignsNote.
  ///
  /// In ru, this message translates to:
  /// **'Лимит использований проверяет сервер. Коды кампаний, созданных на других устройствах, API не возвращает.'**
  String get campaignsNote;

  /// No description provided for @createCampaign.
  ///
  /// In ru, this message translates to:
  /// **'Создать кампанию'**
  String get createCampaign;

  /// No description provided for @newCampaign.
  ///
  /// In ru, this message translates to:
  /// **'Новая кампания'**
  String get newCampaign;

  /// No description provided for @discPercent.
  ///
  /// In ru, this message translates to:
  /// **'Процент'**
  String get discPercent;

  /// No description provided for @discFixed.
  ///
  /// In ru, this message translates to:
  /// **'Сумма ₸'**
  String get discFixed;

  /// No description provided for @discountPct.
  ///
  /// In ru, this message translates to:
  /// **'Скидка, %'**
  String get discountPct;

  /// No description provided for @discountKzt.
  ///
  /// In ru, this message translates to:
  /// **'Скидка, ₸'**
  String get discountKzt;

  /// No description provided for @maxRedemptions.
  ///
  /// In ru, this message translates to:
  /// **'Лимит использований'**
  String get maxRedemptions;

  /// No description provided for @validFrom.
  ///
  /// In ru, this message translates to:
  /// **'Действует с'**
  String get validFrom;

  /// No description provided for @validTo.
  ///
  /// In ru, this message translates to:
  /// **'Действует до'**
  String get validTo;

  /// No description provided for @createAndQr.
  ///
  /// In ru, this message translates to:
  /// **'Создать и получить QR'**
  String get createAndQr;

  /// No description provided for @staffIntro.
  ///
  /// In ru, this message translates to:
  /// **'Добавленные контролёры входят в приложение-сканер и видят только это событие — без выручки, заказов и других событий.'**
  String get staffIntro;

  /// No description provided for @nobodyAssigned.
  ///
  /// In ru, this message translates to:
  /// **'Пока никто не назначен.'**
  String get nobodyAssigned;

  /// No description provided for @userNo.
  ///
  /// In ru, this message translates to:
  /// **'польз. №{id}'**
  String userNo(String id);

  /// No description provided for @actRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать'**
  String get actRemove;

  /// No description provided for @staffRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Убран из этого события.'**
  String get staffRemoved;

  /// No description provided for @addEventAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Добавить контролёра'**
  String get addEventAdmin;

  /// No description provided for @userId.
  ///
  /// In ru, this message translates to:
  /// **'ID пользователя'**
  String get userId;

  /// No description provided for @actAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get actAdd;

  /// No description provided for @staffAdded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлен. Можно входить в сканер.'**
  String get staffAdded;

  /// No description provided for @staffIdNote.
  ///
  /// In ru, this message translates to:
  /// **'API назначает персонал только по ID пользователя, по email — пока нет. Нужен аккаунт EVENT_ADMIN.'**
  String get staffIdNote;

  /// No description provided for @gateActivity.
  ///
  /// In ru, this message translates to:
  /// **'Активность на входе'**
  String get gateActivity;

  /// No description provided for @auditTrailNote.
  ///
  /// In ru, this message translates to:
  /// **'Записи нельзя изменить или удалить. Администраторы платформы видят тот же журнал.'**
  String get auditTrailNote;

  /// No description provided for @noHistory.
  ///
  /// In ru, this message translates to:
  /// **'Записей пока нет.'**
  String get noHistory;

  /// No description provided for @allN.
  ///
  /// In ru, this message translates to:
  /// **'Все · {count}'**
  String allN(int count);

  /// No description provided for @absentHolders.
  ///
  /// In ru, this message translates to:
  /// **'Не пришли'**
  String get absentHolders;

  /// No description provided for @ofCapacity.
  ///
  /// In ru, this message translates to:
  /// **'от вместимости'**
  String get ofCapacity;

  /// No description provided for @createEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое событие'**
  String get createEventTitle;

  /// No description provided for @editEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование'**
  String get editEventTitle;

  /// No description provided for @draftHint.
  ///
  /// In ru, this message translates to:
  /// **'Черновик — ничего не видно публично до публикации'**
  String get draftHint;

  /// No description provided for @basics.
  ///
  /// In ru, this message translates to:
  /// **'Основное'**
  String get basics;

  /// No description provided for @eventTitleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название события'**
  String get eventTitleLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get categoryLabel;

  /// No description provided for @categoryHint.
  ///
  /// In ru, this message translates to:
  /// **'Музыка, IT, Спорт, Театр'**
  String get categoryHint;

  /// No description provided for @visibilityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Видимость'**
  String get visibilityLabel;

  /// No description provided for @venueSection.
  ///
  /// In ru, this message translates to:
  /// **'Площадка'**
  String get venueSection;

  /// No description provided for @venueLabel.
  ///
  /// In ru, this message translates to:
  /// **'Место проведения'**
  String get venueLabel;

  /// No description provided for @addressLabel.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get addressLabel;

  /// No description provided for @cityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get cityLabel;

  /// No description provided for @dateSection.
  ///
  /// In ru, this message translates to:
  /// **'Дата и регистрация'**
  String get dateSection;

  /// No description provided for @startsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get startsLabel;

  /// No description provided for @endsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Окончание'**
  String get endsLabel;

  /// No description provided for @regOpens.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация открывается'**
  String get regOpens;

  /// No description provided for @regCloses.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация закрывается'**
  String get regCloses;

  /// No description provided for @capacityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Вместимость'**
  String get capacityLabel;

  /// No description provided for @seatingImage.
  ///
  /// In ru, this message translates to:
  /// **'Места и обложка'**
  String get seatingImage;

  /// No description provided for @assignedSeating.
  ///
  /// In ru, this message translates to:
  /// **'Места по схеме зала'**
  String get assignedSeating;

  /// No description provided for @assignedSeatingHint.
  ///
  /// In ru, this message translates to:
  /// **'Покупатели выбирают места на схеме при оформлении.'**
  String get assignedSeatingHint;

  /// No description provided for @coverUrl.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на обложку (необязательно)'**
  String get coverUrl;

  /// No description provided for @coverNote.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка картинок в этой версии недоступна — вставьте ссылку на изображение.'**
  String get coverNote;

  /// No description provided for @saveAndContinue.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить и продолжить'**
  String get saveAndContinue;

  /// No description provided for @saveChanges.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить изменения'**
  String get saveChanges;

  /// No description provided for @draftSaved.
  ///
  /// In ru, this message translates to:
  /// **'Черновик сохранён. Добавьте типы билетов.'**
  String get draftSaved;

  /// No description provided for @changesSaved.
  ///
  /// In ru, this message translates to:
  /// **'Изменения сохранены.'**
  String get changesSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
