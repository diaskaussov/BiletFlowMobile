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
