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
}
