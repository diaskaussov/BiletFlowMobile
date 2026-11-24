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
