// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get errNetwork => 'Сервермен байланыс жоқ.';

  @override
  String get errSessionExpired => 'Сессия мерзімі өтті. Қайта кіріңіз.';

  @override
  String get errForbidden => 'Бұл әрекетке рұқсатыңыз жоқ.';

  @override
  String get errUnexpectedResponse => 'Сервердің күтпеген жауабы.';

  @override
  String get errEmailInvalid => 'Дұрыс email енгізіңіз.';

  @override
  String get errPasswordEmpty => 'Құпиясөзді енгізіңіз.';

  @override
  String get errAccountUnsupported =>
      'Бұл аккаунт түріне қолданба қолдау көрсетпейді.';

  @override
  String get errWrongCredentials => 'Email немесе құпиясөз қате';

  @override
  String get errNameRequired => 'Аты-жөніңізді енгізіңіз.';

  @override
  String get errPasswordShort => 'Құпиясөз кемінде 6 таңбадан тұруы керек.';

  @override
  String get errRoleRequired => 'Қатысушы немесе ұйымдастырушыны таңдаңыз.';

  @override
  String get errPromoEmpty => 'Промокодты енгізіңіз.';

  @override
  String get errPromoOtherEvent => 'Бұл код басқа іс-шараға арналған.';

  @override
  String get errReversalReason => 'Кіруді болдырмау себебін көрсетіңіз.';

  @override
  String get errNoTicketId =>
      'Сервер билет ID-ін қайтармады, сондықтан кіруді осы жерден болдырмау мүмкін емес.';

  @override
  String get errPickTicket => 'Кемінде бір билет таңдаңыз.';

  @override
  String get errTicketNotInOrder => 'Бұл билет тапсырыста жоқ.';

  @override
  String errTicketAlreadyIn(String label) {
    return '$label билеті белгіленіп қойған.';
  }

  @override
  String errTicketRefundedNoEntry(String label) {
    return '$label билеті қайтарылған, жарамсыз.';
  }

  @override
  String errTicketCancelledNoEntry(String label) {
    return '$label билетінің күші жойылған, жарамсыз.';
  }

  @override
  String errSeatsForType(int count, String type) {
    return '«$type» үшін $count орын таңдаңыз.';
  }

  @override
  String get errBuyerName => 'Қатысушының аты-жөнін енгізіңіз.';

  @override
  String get errBuyerEmail => 'Билеттер жіберілетін email-ді көрсетіңіз.';

  @override
  String get errSeatsFirst => 'Алдымен орындарды таңдаңыз.';

  @override
  String get errHoldExpired => 'Орындарды брондау уақыты өтті. Қайта таңдаңыз.';

  @override
  String get errEventTitle => 'Іс-шара атауын енгізіңіз.';

  @override
  String get errEventVenue => 'Өтетін орнын көрсетіңіз.';

  @override
  String get errEventCity => 'Қаланы көрсетіңіз.';

  @override
  String get errEventStart => 'Басталу күні мен уақытын көрсетіңіз.';

  @override
  String get errEventEndOrder => 'Аяқталуы басталуынан кейін болуы керек.';

  @override
  String get errRegCloseOrder => 'Тіркеу ашылғаннан кейін жабылуы керек.';

  @override
  String get errRegCloseBeforeEnd =>
      'Тіркеу іс-шара аяқталғанға дейін жабылуы керек.';

  @override
  String get errCapacityMin => 'Сыйымдылық кемінде 1 болуы керек.';

  @override
  String get errTypeName => 'Билет түрінің атауын енгізіңіз.';

  @override
  String get errPriceNegative => 'Баға теріс бола алмайды.';

  @override
  String get errQuantityMin => 'Саны кемінде 1 болуы керек.';

  @override
  String errQuantityBelowSold(int count) {
    return 'Сатылғаннан ($count) аз болуы мүмкін емес.';
  }

  @override
  String get errPerOrderMin => 'Бір тапсырысқа шектеу кемінде 1 болуы керек.';

  @override
  String get errSalesEndOrder => 'Сату басталғаннан кейін аяқталуы керек.';

  @override
  String get errPublishNeedsType =>
      'Жарияламас бұрын кемінде бір билет түрін қосыңыз.';

  @override
  String get errEventAlreadyCancelled => 'Іс-шара бұрыннан жойылған.';

  @override
  String get errSectionsEmpty => 'Кемінде бір секция қосыңыз.';

  @override
  String get errSectionName => 'Әр секцияның атауы болуы керек.';

  @override
  String errSectionTwice(String name) {
    return '«$name» секциясы екі рет көрсетілген.';
  }

  @override
  String get errRowsMin =>
      'Қатар мен қатардағы орын саны кемінде 1 болуы керек.';

  @override
  String get errTermsRequired => 'Алдымен ақылы іс-шара шарттарын қабылдаңыз.';

  @override
  String get errSalesAlreadyActive => 'Ақылы сату бұрыннан белсенді.';

  @override
  String get errNeedPaidType => 'Алдымен ақылы билет түрін қосыңыз.';

  @override
  String get errNeedPayout => 'Алдымен төлем деректемелерін көрсетіңіз.';

  @override
  String get errOrgName => 'Ұйым атауын енгізіңіз.';

  @override
  String get errContactEmail => 'Байланыс email-і қате.';

  @override
  String get errCampaignName => 'Науқан атауын енгізіңіз.';

  @override
  String get errDiscountPositive => 'Жеңілдік нөлден үлкен болуы керек.';

  @override
  String get errPercentMax => 'Пайыздық жеңілдік 100%-дан аспауы керек.';

  @override
  String get errRedemptionsMin => 'Кемінде бір рет пайдалануға рұқсат етіңіз.';

  @override
  String get errCampaignEndOrder => 'Науқан басталғаннан кейін аяқталуы керек.';

  @override
  String get errOrderAlreadyRefunded => 'Тапсырыс бұрыннан қайтарылған.';

  @override
  String get errOrderWasCancelled => 'Тапсырыс жойылған.';

  @override
  String get errRefundReason => 'Қайтару себебін көрсетіңіз.';

  @override
  String get errCampaignDisabled => 'Науқан бұрыннан өшірілген.';

  @override
  String get errUserIdInvalid => 'Пайдаланушының сандық ID-ін енгізіңіз.';

  @override
  String get errAlreadyOnTeam => 'Бұл адам командада бар.';

  @override
  String get errGateEmpty => 'Кіреберіс атауы бос болмауы керек.';

  @override
  String get errGateLong => 'Кіреберіс атауы тым ұзын.';

  @override
  String get errCaseEvent =>
      'Іс-шараны таңдаңыз — өтінішті оның ұйымдастырушысы алады.';

  @override
  String get errCaseSubject => 'Мәселені бірнеше сөзбен сипаттаңыз.';

  @override
  String get errCaseMessage => 'Қолдау қызметіне хабарлама жазыңыз.';

  @override
  String get errReplyEmpty => 'Алдымен жауап жазыңыз.';

  @override
  String get errOrderAlreadyCancelled => 'Тапсырыс бұрыннан жойылған.';

  @override
  String get errTicketUsedInOrder =>
      'Тапсырыстағы бір билет кіреберісте пайдаланылған.';

  @override
  String get errSelfSuspend => 'Өз аккаунтыңызды бұғаттай алмайсыз.';

  @override
  String get errAdminSuspend =>
      'Платформа әкімшілерін мұнда бұғаттау мүмкін емес.';

  @override
  String get errUserAlreadySuspended => 'Пайдаланушы бұрыннан бұғатталған.';

  @override
  String get errUserNotSuspended => 'Пайдаланушы бұғатталмаған.';

  @override
  String get errSuspendReason => 'Бұғаттау себебін көрсетіңіз.';

  @override
  String get errEventNotFound => 'Іс-шара табылмады.';

  @override
  String get errTicketNotFound => 'Билет табылмады.';

  @override
  String get errAttendeeNotFound => 'Қонақ табылмады.';

  @override
  String get errCheckInRefused => 'Сервер кіруді белгілеуден бас тартты.';

  @override
  String get errPromoInvalid => 'Код жарамсыз.';

  @override
  String get appName => 'BiletFlow';

  @override
  String get today => 'Бүгін';

  @override
  String get agoJustNow => 'жаңа ғана';

  @override
  String agoMinutes(int count) {
    return '$count минут бұрын';
  }

  @override
  String agoHours(int count) {
    return '$count сағат бұрын';
  }

  @override
  String agoDays(int count) {
    return '$count күн бұрын';
  }

  @override
  String get free => 'Тегін';

  @override
  String get millionShort => 'млн';

  @override
  String get appearance => 'Безендіру';

  @override
  String get language => 'Тіл';

  @override
  String get theme => 'Тақырып';

  @override
  String get themeSystem => 'Жүйедегідей';

  @override
  String get themeLight => 'Ашық';

  @override
  String get themeDark => 'Қараңғы';
}
