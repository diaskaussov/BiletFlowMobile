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

  @override
  String get actionRetry => 'Қайталау';

  @override
  String get actionNext => 'Келесі';

  @override
  String get actionCancel => 'Бас тарту';

  @override
  String get actionSave => 'Сақтау';

  @override
  String get actionClose => 'Жабу';

  @override
  String get actionSend => 'Жіберу';

  @override
  String get actionChange => 'Өзгерту';

  @override
  String get actionReset => 'Қалпына келтіру';

  @override
  String get actionUndo => 'Болдырмау';

  @override
  String get actionKeep => 'Қалдыру';

  @override
  String get actionOk => 'Түсінікті';

  @override
  String get signOut => 'Шығу';

  @override
  String get tryAgain => 'Қайта көру';

  @override
  String get noConnectionTitle => 'Байланыс жоқ';

  @override
  String get loadFailedTitle => 'Жүктеу мүмкін болмады';

  @override
  String get navScanner => 'Сканер';

  @override
  String get navGuests => 'Қонақтар';

  @override
  String get navStats => 'Статистика';

  @override
  String get navEvents => 'Іс-шаралар';

  @override
  String get navTickets => 'Билеттер';

  @override
  String get navSupport => 'Қолдау';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navAlerts => 'Хабарламалар';

  @override
  String get navQueues => 'Кезектер';

  @override
  String get navUsers => 'Пайдаланушылар';

  @override
  String get navOrders => 'Тапсырыстар';

  @override
  String get settings => 'Баптаулар';

  @override
  String get you => 'сіз';

  @override
  String get copied => 'Көшірілді';

  @override
  String get signInTitle => 'BiletFlow-ға кіру';

  @override
  String get signInSubtitle =>
      'Сатып алушылар, ұйымдастырушылар, бақылаушылар және әкімшілер';

  @override
  String get email => 'Email';

  @override
  String get password => 'Құпиясөз';

  @override
  String get signInButton => 'Кіру';

  @override
  String get forgotPassword => 'Құпиясөзді ұмыттыңыз ба?';

  @override
  String get forgotPasswordTitle => 'Құпиясөзді қалпына келтіру';

  @override
  String get forgotPasswordBody =>
      'Бұл нұсқада құпиясөзді қалпына келтіру қолжетімсіз. Бақылаушыларға ұйымдастырушы көмектеседі, басқаларға — support@biletflow.kz.';

  @override
  String get createAccount => 'Аккаунт ашу';

  @override
  String get showPassword => 'Құпиясөзді көрсету';

  @override
  String get hidePassword => 'Құпиясөзді жасыру';

  @override
  String serverLabel(String address) {
    return 'Сервер: $address';
  }

  @override
  String get serverTitle => 'Сервер мекенжайы';

  @override
  String get serverHint =>
      'Телефонда localhost емес, компьютердің Wi‑Fi IP мекенжайын көрсетіңіз.';

  @override
  String get serverInvalid =>
      'http://192.168.1.10:8080 түріндегі мекенжайды енгізіңіз';

  @override
  String get onlineOnlyNote =>
      'Билеттерді тексеру тек интернетке қосылғанда жұмыс істейді.';

  @override
  String get registerTitle => 'Тіркелу';

  @override
  String get registerIWant => 'Мен қалаймын';

  @override
  String get roleAttend => 'Қатысу';

  @override
  String get roleAttendHint =>
      'Іс-шаралар табу, билет сатып алу, кіреберісте QR көрсету';

  @override
  String get roleOrganize => 'Ұйымдастыру';

  @override
  String get roleOrganizeHint =>
      'Іс-шаралар құру, билет сату, бақылаушыларды тағайындау';

  @override
  String get firstName => 'Аты';

  @override
  String get lastName => 'Тегі';

  @override
  String get phoneOptional => 'Телефон (міндетті емес)';

  @override
  String get passwordMin => 'Құпиясөз · кемінде 6 таңба';

  @override
  String get registerButton => 'Аккаунт ашу';

  @override
  String get registerOrganizerButton => 'Ұйымдастырушы аккаунтын ашу';

  @override
  String get registerNote =>
      'Растау сілтемесін email-ге жібереміз. Бақылаушы аккаунттарын ұйымдастырушылар ашады.';

  @override
  String get myEvents => 'Менің іс-шараларым';

  @override
  String get noAssignedEvents => 'Сізді әлі ешбір іс-шараға тағайындаған жоқ';

  @override
  String get noAssignedEventsHint =>
      'Ұйымдастырушы сізді бақылаушы ретінде қосуы керек. Оған кірген email-іңізді айтыңыз.';

  @override
  String get checkAgain => 'Қайта тексеру';

  @override
  String get pastEvents => 'Өткен';

  @override
  String get upcomingEvents => 'Алдағы';

  @override
  String signedInAs(String email) {
    return 'Сіз $email ретінде кірдіңіз';
  }

  @override
  String enteredOf(int checkedIn, int registered) {
    return '$registered ішінен $checkedIn кірді';
  }

  @override
  String get pointAtQr => 'Билеттің QR-кодына бағыттаңыз';

  @override
  String get torch => 'Шам';

  @override
  String get enterCode => 'Кодты енгізу';

  @override
  String get checking => 'Билетті тексеріп жатырмыз…';

  @override
  String get lowLightTorchOn => 'Қараңғы — шам қосулы';

  @override
  String get scanPaused => 'Байланыс жоқ: сканерлеу қолжетімсіз';

  @override
  String get enterCodeTitle => 'Билет коды';

  @override
  String get enterCodeHint => 'QR-код астындағы немесе хаттағы код';

  @override
  String get checkCode => 'Тексеру';

  @override
  String get cameraOffTitle => 'Камераға рұқсат өшірулі';

  @override
  String get cameraOffBody =>
      'QR-кодтарды оқу үшін камера қажет. Баптаулар → BiletFlow → Камера бөлімінде қосыңыз.';

  @override
  String get openSettings => 'Баптауларды ашу';

  @override
  String get findGuestInstead => 'Қонақты қолмен табу';

  @override
  String get cameraUnavailable => 'Камера қолжетімсіз';

  @override
  String get chooseEventFirst => 'Алдымен іс-шараны таңдаңыз';

  @override
  String get chooseEvent => 'Іс-шараны таңдаңыз';

  @override
  String get vValid => 'Өтіңіз';

  @override
  String get vAlreadyUsed => 'Билет пайдаланылған';

  @override
  String get vRepeat => 'Бұл билет жаңа ғана өтті';

  @override
  String get vRefunded => 'Билет қайтарылған';

  @override
  String get vCancelled => 'Билеттің күші жойылған';

  @override
  String get vUnknown => 'Билет табылмады';

  @override
  String get vWrongEvent => 'Билет басқа іс-шараға';

  @override
  String get vPromo => 'Бұл билет емес, промокод';

  @override
  String closesIn(int seconds) {
    return '$seconds с кейін жабылады';
  }

  @override
  String get undoEntry => 'Кіруді болдырмау';

  @override
  String entryMarkedAt(String time) {
    return 'Кіру $time белгіленді';
  }

  @override
  String scannedBy(String name) {
    return 'Сканерлеген: $name';
  }

  @override
  String get orderCancelledByOrganizer => 'Тапсырысты ұйымдастырушы жойды';

  @override
  String refundedOn(String date) {
    return 'Ақша $date қайтарылды';
  }

  @override
  String get refundedNoEntry => 'Ақша қайтарылды — билетпен өтуге болмайды';

  @override
  String get checkCodeOrFind =>
      'Кодты тексеріңіз немесе қонақты қолмен табыңыз';

  @override
  String get findGuest => 'Қонақты табу';

  @override
  String get ticketIsFor => 'Бұл билет:';

  @override
  String get anotherEvent => 'Басқа іс-шара';

  @override
  String get switchToEvent => 'Осы іс-шараға өту';

  @override
  String campaignLabel(String name) {
    return '$name науқаны';
  }

  @override
  String get promoNotTicket =>
      'Промокод сайтта жеңілдік береді, бірақ кіруге рұқсат бермейді';

  @override
  String repeatBody(int seconds) {
    return '$seconds с бұрын сканерленді — бұл сол кіру, қайта ештеңе жазылған жоқ';
  }

  @override
  String get copyTicketId => 'Билет ID-ін көшіру';

  @override
  String get reversedTitle => 'Кіру болдырылмады';

  @override
  String get reversedBody => 'Билет қайтадан жарамды';

  @override
  String get admission => '1 кіру';

  @override
  String reverseTitle(String name) {
    return '$name үшін кіруді болдырмау керек пе?';
  }

  @override
  String get reverseBody =>
      'Билет қайтадан жарамды болады. Болдырмау сіздің атыңызбен жазылады және өшірілмейді.';

  @override
  String get checkedInLabel => 'Кіру';

  @override
  String get recordedBy => 'Белгілеген';

  @override
  String get ticketLabel => 'Билет';

  @override
  String get reasonRequired => 'Себебі (міндетті)';

  @override
  String get reasonHint => 'Мысалы: басқа адамды сканерлеп қойды';

  @override
  String get guestSearchHint => 'Аты, email, билет коды немесе тапсырыс нөмірі';

  @override
  String get statusValid => 'Жарамды';

  @override
  String get statusUsed => 'Пайдаланылған';

  @override
  String get statusRefunded => 'Қайтарылған';

  @override
  String get statusCancelled => 'Жойылған';

  @override
  String get markEntry => 'Кіруді белгілеу';

  @override
  String get guestSearchStart => 'Атын енгізе бастаңыз — кемінде 2 таңба';

  @override
  String guestNoMatches(String query) {
    return '«$query» бойынша ешкім табылмады';
  }

  @override
  String get guestNoMatchesHint =>
      'Жазылуын тексеріңіз немесе билет коды бойынша іздеңіз';

  @override
  String filterAll(int count) {
    return 'Барлығы $count';
  }

  @override
  String filterNotArrived(int count) {
    return 'Келмегендер $count';
  }

  @override
  String get checkedInToast => 'Кіру белгіленді';

  @override
  String ticketsCount(int count) {
    return '$count билет';
  }

  @override
  String get guest => 'Қонақ';

  @override
  String get ticketsInOrder => 'Тапсырыстағы билеттер';

  @override
  String checkInAll(int count) {
    return 'Барлық билетті белгілеу ($count)';
  }

  @override
  String get history => 'Тарих';

  @override
  String get manualNote =>
      'Қолмен белгілеу сіздің атыңызбен жазылады және ұйымдастырушыға көрінеді.';

  @override
  String notArrivedCount(int count) {
    return 'Келмегендер: $count';
  }

  @override
  String get allUsedOrVoid => 'Барлық билеттер пайдаланылған немесе жарамсыз';

  @override
  String get recordUnavailable => 'Жазба қолжетімсіз';

  @override
  String get entered => 'Кірді';

  @override
  String stillToCome(int count) {
    return 'Қалған қонақтар: $count';
  }

  @override
  String get registered => 'Тіркелген';

  @override
  String get notArrived => 'Келмегендер';

  @override
  String get cancelledStat => 'Жойылған';

  @override
  String get refundedStat => 'Қайтарылған';

  @override
  String get reversals => 'Кіруден бас тарту';

  @override
  String get byTicketType => 'Билет түрлері бойынша';

  @override
  String get recentEntries => 'Соңғы кірулер';

  @override
  String get noEntriesYet => 'Әзірге кіру жоқ';

  @override
  String get statsUnavailable => 'Статистика қолжетімсіз';

  @override
  String get offlineBody => 'Интернетті тексеріп, қайталап көріңіз';

  @override
  String get connectionRestored => 'Байланыс қалпына келді';

  @override
  String get stillOffline => 'Сервермен әлі байланыс жоқ';

  @override
  String lastSync(String time) {
    return 'Соңғы синхрондау: $time';
  }

  @override
  String get offlineNote =>
      'Билеттер серверде тексеріледі, сондықтан байланыссыз сканерлеу тоқтатылады. Телефонда ештеңе сақталмайды.';

  @override
  String get scanningSection => 'Сканерлеу';

  @override
  String get torchDefault => 'Шам әдепкі бойынша қосулы';

  @override
  String get soundOnResult => 'Нәтиже кезіндегі дыбыс';

  @override
  String get vibrateOnReject => 'Бас тарту кезіндегі діріл';

  @override
  String get gateSection => 'Кіреберіс';

  @override
  String get assignedGate => 'Менің кіреберісім';

  @override
  String get roleEventAdmin => 'Бақылаушы';

  @override
  String get roleAttendee => 'Сатып алушы';

  @override
  String get roleOrganizer => 'Ұйымдастырушы';

  @override
  String get rolePlatformAdmin => 'Әкімші';

  @override
  String eventsCount(int count) {
    return 'Іс-шаралар: $count';
  }

  @override
  String get server => 'Сервер';

  @override
  String get demoBuild =>
      'Демо-нұсқа: барлық төлемдер шынайы емес, ақша алынбайды.';

  @override
  String get account => 'Аккаунт';

  @override
  String get notifications => 'Хабарламалар';

  @override
  String get organizerProfile => 'Ұйымдастырушы профилі және төлемдер';

  @override
  String get evDraft => 'Жоба';

  @override
  String get evPublished => 'Жарияланған';

  @override
  String get evCancelled => 'Тоқтатылған';

  @override
  String get evCompleted => 'Аяқталған';

  @override
  String get evLive => 'Қазір өтуде';

  @override
  String get visPublic => 'Ашық';

  @override
  String get visUnlisted => 'Сілтеме арқылы';

  @override
  String get visPrivate => 'Жабық';

  @override
  String get orderPending => 'Төлем күтілуде';

  @override
  String get orderPaid => 'Төленген';

  @override
  String get orderCancelled => 'Тоқтатылған';

  @override
  String get orderRefunded => 'Қайтарылған';

  @override
  String get caseOpen => 'Ашық';

  @override
  String get caseInProgress => 'Жұмыста';

  @override
  String get caseWaiting => 'Жауап күтілуде';

  @override
  String get caseResolved => 'Шешілді';

  @override
  String get catTicketDelivery => 'Билетті жеткізу';

  @override
  String get catPayment => 'Төлем';

  @override
  String get catRefund => 'Қайтару';

  @override
  String get catSeating => 'Орындар';

  @override
  String get catEventInfo => 'Іс-шара туралы ақпарат';

  @override
  String get catCheckIn => 'Кіру';

  @override
  String get catAccount => 'Аккаунт';

  @override
  String get catActivation => 'Сатуды іске қосу';

  @override
  String get catTechnical => 'Техникалық мәселе';

  @override
  String get auditEventChanges => 'Іс-шара өзгерістері';

  @override
  String get auditRefunds => 'Қайтарулар';

  @override
  String get auditCampaigns => 'Промо';

  @override
  String get auditCheckIns => 'Кірулер';

  @override
  String get auditSupport => 'Қолдау';

  @override
  String seatLabel(String section, String row, String number) {
    return '$section сектор · $row қатар · $number орын';
  }

  @override
  String get secOverview => 'Шолу';

  @override
  String get secTickets => 'Билеттер';

  @override
  String get secSeating => 'Зал схемасы';

  @override
  String get secOrders => 'Тапсырыстар';

  @override
  String get secPromo => 'Промо';

  @override
  String get secStaff => 'Қызметкерлер';

  @override
  String get secSales => 'Сату';

  @override
  String get secHistory => 'Тарих';

  @override
  String get secCheckIn => 'Кіру';

  @override
  String get eventActions => 'Іс-шара әрекеттері';

  @override
  String get actEdit => 'Өңдеу';

  @override
  String get actDuplicate => 'Көшірме жасау';

  @override
  String get actPublish => 'Жариялау';

  @override
  String get actUnpublish => 'Жариялаудан алу';

  @override
  String get actCancelEvent => 'Іс-шараны тоқтату';

  @override
  String get cancelEventTitle => 'Іс-шараны тоқтату керек пе?';

  @override
  String get cancelEventBody =>
      'Сату тоқтайды, барлық билеттер жарамсыз болады, қатысушыларға хабарлама жіберіледі. Жазбалар тарихта қалады.';

  @override
  String get publishedToast => 'Жарияланды — тіркеу ашық.';

  @override
  String get unpublishedToast => 'Жариялаудан алынды — қайтадан жоба.';

  @override
  String get cancelledToast => 'Іс-шара тоқтатылды.';

  @override
  String get duplicatedToast =>
      'Тапсырыссыз, билетсіз және кірусіз көшірме-жоба жасалды.';

  @override
  String get salesNotActive =>
      'Ақылы сату іске қосылмаған — сатып алушылар ақылы билет ала алмайды';

  @override
  String get actActivate => 'Іске қосу';

  @override
  String get kpiSold => 'Сатылды';

  @override
  String get kpiGross => 'Жалпы түсім';

  @override
  String get kpiNet => 'Таза түсім';

  @override
  String get kpiAttendance => 'Келу';

  @override
  String get kpiOrders => 'Тапсырыстар';

  @override
  String get kpiDiscounts => 'Жеңілдіктер';

  @override
  String get kpiRefunds => 'Қайтарулар';

  @override
  String get kpiRemaining => 'Қалды';

  @override
  String get salesByType => 'Билет түрлері бойынша сату';

  @override
  String get promoEffect => 'Промокодтар тиімділігі';

  @override
  String redeemedOf(String used, String max) {
    return '$max ішінен $used';
  }

  @override
  String redeemed(int count) {
    return '$count рет';
  }

  @override
  String get salesOverTime => 'Күндер бойынша сату';

  @override
  String get noOrdersYet => 'Әзірге тапсырыс жоқ.';

  @override
  String get eventFallback => 'Іс-шара';

  @override
  String get createEvent => 'Іс-шара құру';

  @override
  String get firstEventTitle => 'Алғашқы іс-шараңызды құрыңыз';

  @override
  String get firstEventBody =>
      'Іс-шара құру және тегін билеттер тегін. Ақылы сату әр іс-шара үшін бөлек іске қосылады.';

  @override
  String filterAllN(int count) {
    return 'Барлығы $count';
  }

  @override
  String filterDraftsN(int count) {
    return 'Жобалар $count';
  }

  @override
  String filterPublishedN(int count) {
    return 'Жарияланғандар $count';
  }

  @override
  String filterLiveN(int count) {
    return 'Өтуде $count';
  }

  @override
  String filterPastN(int count) {
    return 'Өткендер $count';
  }

  @override
  String filterCancelledN(int count) {
    return 'Тоқтатылғандар $count';
  }

  @override
  String get searchByTitle => 'Атауы бойынша іздеу';

  @override
  String soldOf(String sold, String total) {
    return 'Сатылды $sold / $total';
  }

  @override
  String get nothingFound => 'Ештеңе табылмады';

  @override
  String get noNotifications => 'Әзірге хабарлама жоқ';

  @override
  String get noNotificationsHint =>
      'Мұнда тапсырыстар, қайтарулар және қолдау жауаптары көрсетіледі.';

  @override
  String get demoPayments =>
      'Демо нұсқа: төлем сынақ жүйесі арқылы өтеді, ақша алынбайды, карта сақталмайды.';

  @override
  String get ordersSearchHint => 'Сатып алушы немесе тапсырыс №';

  @override
  String get filtersTitle => 'Сүзгі';

  @override
  String get attAll => 'Барлығы';

  @override
  String get attCheckedIn => 'Кірді';

  @override
  String get attNotArrived => 'Келмеді';

  @override
  String get attRefunded => 'Қайтарулар мен бас тартулар';

  @override
  String get attCampaign => 'Промокодпен';

  @override
  String get exportCsv => 'CSV жүктеу';

  @override
  String orderNo(String id) {
    return '№$id';
  }

  @override
  String get noOrder => 'Тапсырыссыз';

  @override
  String get refundMoney => 'Ақшаны қайтару';

  @override
  String refundTitle(String id) {
    return '№$id тапсырыс бойынша қайтару';
  }

  @override
  String get buyer => 'Сатып алушы';

  @override
  String get positions => 'Позициялар';

  @override
  String get toRefund => 'Қайтарылатын сома';

  @override
  String get reasonStar => 'Себебі *';

  @override
  String get refundReasonHint => 'Мысалы: сатып алушы іс-шараға келе алмайды';

  @override
  String refundConfirm(String amount) {
    return '$amount қайтару';
  }

  @override
  String get refundedToast => 'Ақша қайтарылды. Сатып алушыға хат жіберіледі.';

  @override
  String refundUsedWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count билет кіруден өтті',
    );
    return '$_temp0. Қайтару кіруді болдырмайды.';
  }

  @override
  String get refundNote =>
      'Билеттер бірден жарамсыз болады, орындар сатылымға қайтады.';

  @override
  String get orderTitle => 'Тапсырыс';

  @override
  String get statusLabel => 'Күйі';

  @override
  String discountCode(String code) {
    return '$code жеңілдігі';
  }

  @override
  String get paidLabel => 'Төленді';

  @override
  String get placedLabel => 'Рәсімделді';

  @override
  String usedOfTotal(String used, String total) {
    return '$total ішінен $used';
  }

  @override
  String get noOrdersMatch => 'Сұраныс бойынша тапсырыс жоқ';

  @override
  String get orderNotFound => 'Тапсырыс табылмады';

  @override
  String get errOrderNotFound => 'Тапсырыс табылмады.';

  @override
  String get errOrderNoEvent => 'Тапсырыстың іс-шарасы жоқ.';

  @override
  String get errRowInvalid =>
      'Әр қатардың белгісі және кемінде бір орны болуы керек.';

  @override
  String errSeatsOverTickets(String name, int seats, int quantity) {
    return 'Схемада «$name» үшін $seats орын, ал билет саны $quantity — санын көбейтіңіз';
  }

  @override
  String seatPreview(int count) {
    return 'Алдын ала көру · $count орын';
  }

  @override
  String get fullScreen => 'Толық экран';

  @override
  String get stage => 'САХНА';

  @override
  String get sectionsTitle => 'Секциялар';

  @override
  String rowsCount(int count) {
    return '$count қатар';
  }

  @override
  String seatsCount(int count) {
    return '$count орын';
  }

  @override
  String get modeQuick => 'Жылдам';

  @override
  String get modeManual => 'Қолмен';

  @override
  String get sectionName => 'Секция атауы';

  @override
  String get rowsLabel => 'Қатар саны';

  @override
  String get seatsPerRowLabel => 'Қатардағы орын';

  @override
  String get rowLabel => 'Қатар';

  @override
  String get seatsLabel => 'Орын';

  @override
  String get addRow => 'Қатар қосу';

  @override
  String get addSection => 'Секция қосу';

  @override
  String get saveMap => 'Схеманы сақтау';

  @override
  String get deleteMap => 'Схеманы жою';

  @override
  String get deleteMapTitle => 'Зал схемасын жою керек пе?';

  @override
  String get deleteMapBody =>
      'Орындар жойылады, сатып алушылар оларды таңдай алмайды.';

  @override
  String get mapSaved => 'Схема сақталды.';

  @override
  String get mapDeleted => 'Схема жойылды.';

  @override
  String get mapSoldLocked =>
      'Орындар сатылып кеткен — схеманы жоюға болмайды.';

  @override
  String get noSeatMapYet =>
      'Схема әлі жоқ. Секция қосыңыз — әрқайсысы өз билет түрінің бағасымен сатылады.';

  @override
  String get needTicketTypeFirst =>
      'Алдымен билет түрін қосыңыз — секциялар соның бағасымен сатылады.';

  @override
  String get ticketTypeLabel => 'Билет түрі';

  @override
  String get removeSection => 'Секцияны жою';

  @override
  String sectionDefault(String name) {
    return '$name секторы';
  }

  @override
  String get actionDelete => 'Жою';

  @override
  String get activationTitle => 'Ақылы сатуды іске қосу';

  @override
  String activationProgress(int done, int total) {
    return '$total шарттың $done орындалды. Сату іске қосылғанша тек тегін билеттер қолжетімді.';
  }

  @override
  String get chkPaidType => 'Ақылы билет түрі бар';

  @override
  String get chkPaidTypeMissing => 'Бағасы нөлден жоғары билет түрін қосыңыз';

  @override
  String get chkIdentity => 'Жеке басы расталды';

  @override
  String get chkIdentityMissing => 'Ұйымдастырушы профиліндегі сынақ тексеруі';

  @override
  String get chkPayout => 'Төлем деректемелері расталды';

  @override
  String get chkPayoutMissing => 'Банк пен шот нөмірін көрсетіңіз';

  @override
  String get chkFee => 'Комиссия төленді';

  @override
  String get chkFeeMissing =>
      'Осы іс-шара үшін бір реттік комиссия — іске қосқанда алынады (сынақ)';

  @override
  String get doneLabel => 'Дайын';

  @override
  String get fixLink => 'Түзету →';

  @override
  String get termsAccept =>
      'Ақылы сату шарттарын қабылдаймын: қайтарулар, чарджбэктер, төлем мерзімдері';

  @override
  String get activateButton => 'Ақылы сатуды іске қосу';

  @override
  String get activatedTitle => 'Сату іске қосылды';

  @override
  String get activatedBody => 'Сатып алушылар ақылы билеттер ала алады';

  @override
  String get activatedToast => 'Ақылы сату іске қосылды (сынақ).';

  @override
  String get demoActivation =>
      'Жеке басты тексеру, комиссия, төлемдер мен төлемақылар сынақ жүйесі арқылы өтеді. Ақша алынбайды.';

  @override
  String get orgProfileTitle => 'Ұйымдастырушы профилі';

  @override
  String get orgProfileSub => 'Байланыс және төлемдер';

  @override
  String get identityOk => 'Жеке басы расталды';

  @override
  String get identityNo => 'Жеке басы расталмаған';

  @override
  String get payoutOk => 'Төлемдер расталды';

  @override
  String get payoutNo => 'Төлемдер расталмаған';

  @override
  String get organization => 'Ұйым';

  @override
  String get orgName => 'Ұйым атауы';

  @override
  String get descriptionLabel => 'Сипаттама';

  @override
  String get contactEmail => 'Байланыс email';

  @override
  String get contactPhone => 'Байланыс телефоны';

  @override
  String get website => 'Сайт';

  @override
  String get payoutSection => 'Төлем шоты · сынақ';

  @override
  String get bank => 'Банк';

  @override
  String get accountNumber => 'Шот нөмірі';

  @override
  String get accountHolder => 'Шот иесі';

  @override
  String get demoPayout =>
      'Деректемелер тек сынақ төлемі үшін қолданылады. Нақты аударым жоқ.';

  @override
  String get saveProfile => 'Профильді сақтау';

  @override
  String get profileSaved => 'Профиль сақталды.';

  @override
  String get issued => 'Берілді';

  @override
  String get available => 'Қолжетімді';

  @override
  String get refundedVoid => 'Қайтару / жойылған';

  @override
  String get noTicketTypes => 'Билет түрлері әлі жоқ';

  @override
  String get noTicketTypesHint =>
      'Жарияламас бұрын кемінде бір тегін не ақылы түр қосыңыз.';

  @override
  String get ttHidden => 'Жасырын';

  @override
  String get ttSoldOut => 'Сатылып кетті';

  @override
  String get ttOnSale => 'Сатылымда';

  @override
  String get ttNotOnSale => 'Сатылмайды';

  @override
  String get priceLabel => 'Бағасы';

  @override
  String get maxPerOrder => 'Тапсырыстағы ең көп';

  @override
  String get salesWindow => 'Сату';

  @override
  String get salesNow => 'қазір';

  @override
  String get salesUntilEvent => 'іс-шараға дейін';

  @override
  String get actHide => 'Жасыру';

  @override
  String get hiddenToast => 'Түр сатылымнан алынды. Сатылған билеттер жарамды.';

  @override
  String get ttAdded => 'Билет түрі қосылды.';

  @override
  String get savedToast => 'Сақталды.';

  @override
  String get addTicketType => 'Билет түрін қосу';

  @override
  String get newTicketType => 'Жаңа билет түрі';

  @override
  String get editTicketType => 'Билет түрін өзгерту';

  @override
  String get nameLabel => 'Атауы';

  @override
  String get freeTicket => 'Тегін билет';

  @override
  String get priceKzt => 'Бағасы, ₸';

  @override
  String get quantityLabel => 'Саны';

  @override
  String get salesStartOpt => 'Сату басталуы (міндетті емес)';

  @override
  String get salesEndOpt => 'Сату аяқталуы (міндетті емес)';

  @override
  String get paidNeedsActivation =>
      'Ақылы билеттер осы іс-шара үшін сату іске қосылғаннан кейін ғана сатылады.';

  @override
  String get pickDateTime => 'Күн мен уақытты таңдаңыз';

  @override
  String get campaignQrTitle => 'Науқан QR — бұл билет емес';

  @override
  String get codeLabel => 'Код';

  @override
  String get linkLabel => 'Сілтеме';

  @override
  String campaignQrNote(String code) {
    return 'Іс-шара бетін $code қолданылған күйде ашады. Сілтемеде тек код бар, баға жоқ — оны сервер тексереді. Кіреберістегі сканер мұндай QR-ды қабылдамайды.';
  }

  @override
  String get shareLink => 'Сілтемемен бөлісу';

  @override
  String get copyCode => 'Кодты көшіру';

  @override
  String get codeCopied => 'Код көшірілді.';

  @override
  String get noCampaigns => 'Науқандар әлі жоқ';

  @override
  String get noCampaignsHint =>
      'Науқан промокод пен бақыланатын QR арқылы жеңілдік береді.';

  @override
  String get campLive => 'Белсенді';

  @override
  String get campNotLive => 'Белсенді емес';

  @override
  String get campDisabled => 'Өшірілген';

  @override
  String get codeHidden => 'Сервер кодты қайтармады';

  @override
  String get discountLabel => 'Жеңілдік';

  @override
  String percentOff(String value) {
    return '−$value%';
  }

  @override
  String amountOff(String value) {
    return '−$value';
  }

  @override
  String get usedLabel => 'Қолданылды';

  @override
  String get validLabel => 'Жарамды';

  @override
  String get validOpen => 'мерзімсіз';

  @override
  String get qrAndLink => 'QR және сілтеме';

  @override
  String get actDisable => 'Өшіру';

  @override
  String get campaignDisabled => 'Науқан өшірілді.';

  @override
  String get campaignsNote =>
      'Қолдану шегін сервер тексереді. Басқа құрылғыда жасалған науқан кодтарын API қайтармайды.';

  @override
  String get createCampaign => 'Науқан құру';

  @override
  String get newCampaign => 'Жаңа науқан';

  @override
  String get discPercent => 'Пайыз';

  @override
  String get discFixed => 'Сома ₸';

  @override
  String get discountPct => 'Жеңілдік, %';

  @override
  String get discountKzt => 'Жеңілдік, ₸';

  @override
  String get maxRedemptions => 'Қолдану шегі';

  @override
  String get validFrom => 'Басталуы';

  @override
  String get validTo => 'Аяқталуы';

  @override
  String get createAndQr => 'Құру және QR алу';

  @override
  String get staffIntro =>
      'Қосылған бақылаушылар сканер қолданбасына кіріп, тек осы іс-шараны көреді — түсімсіз, тапсырыссыз.';

  @override
  String get nobodyAssigned => 'Әзірге ешкім тағайындалмаған.';

  @override
  String userNo(String id) {
    return 'қолд. №$id';
  }

  @override
  String get actRemove => 'Алып тастау';

  @override
  String get staffRemoved => 'Осы іс-шарадан алынды.';

  @override
  String get addEventAdmin => 'Бақылаушы қосу';

  @override
  String get userId => 'Қолданушы ID';

  @override
  String get actAdd => 'Қосу';

  @override
  String get staffAdded => 'Қосылды. Сканерге кіруге болады.';

  @override
  String get staffIdNote =>
      'API қызметкерді тек қолданушы ID бойынша тағайындайды. EVENT_ADMIN аккаунты қажет.';

  @override
  String get gateActivity => 'Кіреберістегі белсенділік';

  @override
  String get auditTrailNote =>
      'Жазбаларды өзгертуге не жоюға болмайды. Платформа әкімшілері де осы журналды көреді.';

  @override
  String get noHistory => 'Әзірге жазба жоқ.';

  @override
  String allN(int count) {
    return 'Барлығы · $count';
  }

  @override
  String get absentHolders => 'Келмегендер';

  @override
  String get ofCapacity => 'сыйымдылықтан';

  @override
  String get createEventTitle => 'Жаңа іс-шара';

  @override
  String get editEventTitle => 'Өңдеу';

  @override
  String get draftHint => 'Жоба — жарияланғанша ешкім көрмейді';

  @override
  String get basics => 'Негізгі';

  @override
  String get eventTitleLabel => 'Іс-шара атауы';

  @override
  String get categoryLabel => 'Санат';

  @override
  String get categoryHint => 'Музыка, IT, Спорт, Театр';

  @override
  String get visibilityLabel => 'Көрінуі';

  @override
  String get venueSection => 'Алаң';

  @override
  String get venueLabel => 'Өтетін орны';

  @override
  String get addressLabel => 'Мекенжай';

  @override
  String get cityLabel => 'Қала';

  @override
  String get dateSection => 'Күні және тіркеу';

  @override
  String get startsLabel => 'Басталуы';

  @override
  String get endsLabel => 'Аяқталуы';

  @override
  String get regOpens => 'Тіркеу ашылады';

  @override
  String get regCloses => 'Тіркеу жабылады';

  @override
  String get capacityLabel => 'Сыйымдылық';

  @override
  String get seatingImage => 'Орындар және мұқаба';

  @override
  String get assignedSeating => 'Зал схемасы бойынша орындар';

  @override
  String get assignedSeatingHint =>
      'Сатып алушылар рәсімдеу кезінде схемадан орын таңдайды.';

  @override
  String get coverUrl => 'Мұқаба сілтемесі (міндетті емес)';

  @override
  String get coverNote =>
      'Бұл нұсқада сурет жүктеу жоқ — сурет сілтемесін қойыңыз.';

  @override
  String get saveAndContinue => 'Сақтау және жалғастыру';

  @override
  String get saveChanges => 'Өзгерістерді сақтау';

  @override
  String get draftSaved => 'Жоба сақталды. Билет түрлерін қосыңыз.';

  @override
  String get changesSaved => 'Өзгерістер сақталды.';
}
