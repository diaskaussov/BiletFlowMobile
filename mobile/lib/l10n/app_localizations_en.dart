// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errNetwork => 'No connection to the server.';

  @override
  String get errSessionExpired => 'Session expired. Sign in again.';

  @override
  String get errForbidden => 'You do not have permission for this action.';

  @override
  String get errUnexpectedResponse => 'Unexpected server response.';

  @override
  String get errEmailInvalid => 'Enter a valid email address.';

  @override
  String get errPasswordEmpty => 'Enter your password.';

  @override
  String get errAccountUnsupported =>
      'This account type is not supported by the app.';

  @override
  String get errWrongCredentials => 'Incorrect email or password.';

  @override
  String get errNameRequired => 'Enter your first and last name.';

  @override
  String get errPasswordShort => 'Password must be at least 6 characters.';

  @override
  String get errRoleRequired => 'Choose attendee or organizer.';

  @override
  String get errPromoEmpty => 'Enter a promo code.';

  @override
  String get errPromoOtherEvent => 'This code is for a different event.';

  @override
  String get errReversalReason => 'Give a reason for the reversal.';

  @override
  String get errNoTicketId =>
      'The server did not return a ticket ID for this scan, so the check-in cannot be reversed from here.';

  @override
  String get errPickTicket => 'Choose at least one ticket.';

  @override
  String get errTicketNotInOrder => 'Ticket is not in this order.';

  @override
  String errTicketAlreadyIn(String label) {
    return 'Ticket $label is already checked in.';
  }

  @override
  String errTicketRefundedNoEntry(String label) {
    return 'Ticket $label was refunded and cannot admit anyone.';
  }

  @override
  String errTicketCancelledNoEntry(String label) {
    return 'Ticket $label was cancelled and cannot admit anyone.';
  }

  @override
  String errSeatsForType(int count, String type) {
    return 'Choose $count seats for $type.';
  }

  @override
  String get errBuyerName => 'Enter the attendee\'s first and last name.';

  @override
  String get errBuyerEmail => 'Enter the email tickets should be sent to.';

  @override
  String get errSeatsFirst => 'Choose seats first.';

  @override
  String get errHoldExpired => 'Your seat hold expired. Choose seats again.';

  @override
  String get errEventTitle => 'Give the event a title.';

  @override
  String get errEventVenue => 'Add the venue — events are physical (§4.2).';

  @override
  String get errEventCity => 'Add the city.';

  @override
  String get errEventStart => 'Choose when the event starts.';

  @override
  String get errEventEndOrder => 'The event must end after it starts.';

  @override
  String get errRegCloseOrder => 'Registration must close after it opens.';

  @override
  String get errRegCloseBeforeEnd =>
      'Registration must close before the event ends.';

  @override
  String get errCapacityMin => 'Set a capacity of at least 1.';

  @override
  String get errTypeName => 'Name the ticket type.';

  @override
  String get errPriceNegative => 'Price cannot be negative.';

  @override
  String get errQuantityMin => 'Quantity must be at least 1.';

  @override
  String errQuantityBelowSold(int count) {
    return 'Quantity cannot go below the $count already sold.';
  }

  @override
  String get errPerOrderMin => 'Limit per order must be at least 1.';

  @override
  String get errSalesEndOrder => 'Sales must end after they start.';

  @override
  String get errPublishNeedsType =>
      'Add at least one ticket type before publishing.';

  @override
  String get errEventAlreadyCancelled => 'This event is already cancelled.';

  @override
  String get errSectionsEmpty => 'Add at least one section.';

  @override
  String get errSectionName => 'Every section needs a name.';

  @override
  String errSectionTwice(String name) {
    return 'Section \"$name\" is listed twice.';
  }

  @override
  String get errRowsMin => 'Rows and seats per row must be at least 1.';

  @override
  String get errTermsRequired => 'Accept the paid-event terms first.';

  @override
  String get errSalesAlreadyActive => 'Paid sales are already active.';

  @override
  String get errNeedPaidType => 'Add a paid ticket type first.';

  @override
  String get errNeedPayout => 'Connect a payout account first.';

  @override
  String get errOrgName => 'Enter the organization name.';

  @override
  String get errContactEmail => 'Contact email is not valid.';

  @override
  String get errCampaignName => 'Name the campaign.';

  @override
  String get errDiscountPositive => 'The discount must be above zero.';

  @override
  String get errPercentMax => 'A percentage discount cannot exceed 100%.';

  @override
  String get errRedemptionsMin => 'Allow at least one redemption.';

  @override
  String get errCampaignEndOrder => 'The campaign must end after it starts.';

  @override
  String get errOrderAlreadyRefunded => 'This order is already refunded.';

  @override
  String get errOrderWasCancelled => 'This order was cancelled.';

  @override
  String get errRefundReason => 'Record a reason for the refund.';

  @override
  String get errCampaignDisabled => 'This campaign is already disabled.';

  @override
  String get errUserIdInvalid => 'Enter the user\'s numeric ID.';

  @override
  String get errAlreadyOnTeam => 'This person is already on the team.';

  @override
  String get errGateEmpty => 'Gate name cannot be empty.';

  @override
  String get errGateLong => 'Gate name is too long.';

  @override
  String get errCaseEvent =>
      'Choose the event this is about, so its organizer gets the case.';

  @override
  String get errCaseSubject => 'Describe the problem in a few words.';

  @override
  String get errCaseMessage => 'Write a message for support.';

  @override
  String get errReplyEmpty => 'Write a reply first.';

  @override
  String get errOrderAlreadyCancelled => 'This order is already cancelled.';

  @override
  String get errTicketUsedInOrder =>
      'A ticket in this order was already used at the door.';

  @override
  String get errSelfSuspend => 'You cannot suspend your own account.';

  @override
  String get errAdminSuspend => 'Platform admins cannot be suspended here.';

  @override
  String get errUserAlreadySuspended => 'This user is already suspended.';

  @override
  String get errUserNotSuspended => 'This user is not suspended.';

  @override
  String get errSuspendReason => 'Record the reason for suspending.';

  @override
  String get errEventNotFound => 'Event not found.';

  @override
  String get errTicketNotFound => 'Ticket not found.';

  @override
  String get errAttendeeNotFound => 'Attendee not found.';

  @override
  String get errCheckInRefused => 'Check-in was refused.';

  @override
  String get errPromoInvalid => 'This code is not valid.';

  @override
  String get appName => 'BiletFlow';

  @override
  String get today => 'Today';

  @override
  String get agoJustNow => 'just now';

  @override
  String agoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '$count min ago',
    );
    return '$_temp0';
  }

  @override
  String agoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '$count h ago',
    );
    return '$_temp0';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String get free => 'Free';

  @override
  String get millionShort => 'M';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionNext => 'Next';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSend => 'Send';

  @override
  String get actionChange => 'Change';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionKeep => 'Keep';

  @override
  String get actionOk => 'OK';

  @override
  String get signOut => 'Sign out';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noConnectionTitle => 'No connection';

  @override
  String get loadFailedTitle => 'Could not load';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navGuests => 'Guests';

  @override
  String get navStats => 'Stats';

  @override
  String get navEvents => 'Events';

  @override
  String get navTickets => 'Tickets';

  @override
  String get navSupport => 'Support';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navQueues => 'Queues';

  @override
  String get navUsers => 'Users';

  @override
  String get navOrders => 'Orders';

  @override
  String get settings => 'Settings';

  @override
  String get you => 'you';

  @override
  String get copied => 'Copied';

  @override
  String get signInTitle => 'Sign in to BiletFlow';

  @override
  String get signInSubtitle => 'Attendees, organizers, gate staff and admins';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordBody =>
      'Password reset is not available in this build yet. Gate staff can ask their organizer; everyone else can write to support@biletflow.kz.';

  @override
  String get createAccount => 'Create an account';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String serverLabel(String address) {
    return 'Server: $address';
  }

  @override
  String get serverTitle => 'Server address';

  @override
  String get serverHint =>
      'On a real phone use the computer\'s Wi‑Fi IP, not localhost.';

  @override
  String get serverInvalid => 'Enter an address like http://192.168.1.10:8080';

  @override
  String get onlineOnlyNote => 'Ticket checks need an internet connection.';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerIWant => 'I want to';

  @override
  String get roleAttend => 'Attend';

  @override
  String get roleAttendHint =>
      'Find events, buy tickets, show the QR at the door';

  @override
  String get roleOrganize => 'Organize';

  @override
  String get roleOrganizeHint =>
      'Create events, sell tickets, assign gate staff';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get passwordMin => 'Password · at least 6 characters';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerOrganizerButton => 'Create organizer account';

  @override
  String get registerNote =>
      'We send a confirmation link to your email. Gate staff accounts are created by organizers.';

  @override
  String get myEvents => 'My events';

  @override
  String get noAssignedEvents => 'You are not assigned to any event yet';

  @override
  String get noAssignedEventsHint =>
      'An organizer has to add you as gate staff. Give them the email you signed in with.';

  @override
  String get checkAgain => 'Check again';

  @override
  String get pastEvents => 'Past';

  @override
  String get upcomingEvents => 'Upcoming';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String enteredOf(int checkedIn, int registered) {
    return '$checkedIn of $registered in';
  }

  @override
  String get pointAtQr => 'Point at the ticket QR code';

  @override
  String get torch => 'Torch';

  @override
  String get enterCode => 'Enter code';

  @override
  String get checking => 'Checking ticket…';

  @override
  String get lowLightTorchOn => 'Low light — torch on';

  @override
  String get scanPaused => 'No connection: scanning unavailable';

  @override
  String get enterCodeTitle => 'Ticket code';

  @override
  String get enterCodeHint => 'Enter a code';

  @override
  String get checkCode => 'Check';

  @override
  String get cameraOffTitle => 'Camera access is off';

  @override
  String get cameraOffBody =>
      'The camera is needed to read ticket QR codes. Turn it on in Settings → BiletFlow → Camera.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get findGuestInstead => 'Find guest manually';

  @override
  String get cameraUnavailable => 'Camera is unavailable';

  @override
  String get chooseEventFirst => 'Choose an event first';

  @override
  String get chooseEvent => 'Choose event';

  @override
  String get vValid => 'Come in';

  @override
  String get vAlreadyUsed => 'Ticket already used';

  @override
  String get vRepeat => 'This ticket just went through';

  @override
  String get vRefunded => 'Ticket refunded';

  @override
  String get vCancelled => 'Ticket cancelled';

  @override
  String get vUnknown => 'Ticket not found';

  @override
  String get vWrongEvent => 'Ticket for another event';

  @override
  String get vPromo => 'This is a promo code, not a ticket';

  @override
  String closesIn(int seconds) {
    return 'Closes in $seconds s';
  }

  @override
  String get undoEntry => 'Undo check-in';

  @override
  String entryMarkedAt(String time) {
    return 'Checked in at $time';
  }

  @override
  String scannedBy(String name) {
    return 'Scanned by $name';
  }

  @override
  String get orderCancelledByOrganizer => 'The organizer cancelled the order';

  @override
  String refundedOn(String date) {
    return 'Refunded on $date';
  }

  @override
  String get refundedNoEntry => 'Refunded — this ticket cannot be used';

  @override
  String get checkCodeOrFind => 'Check the code or find the guest manually';

  @override
  String get findGuest => 'Find guest';

  @override
  String get ticketIsFor => 'This ticket is for:';

  @override
  String get anotherEvent => 'Another event';

  @override
  String get switchToEvent => 'Switch to that event';

  @override
  String campaignLabel(String name) {
    return 'Campaign $name';
  }

  @override
  String get promoNotTicket =>
      'A promo code gives a discount online but never admits anyone';

  @override
  String repeatBody(int seconds) {
    return 'Scanned $seconds s ago — the same entry, nothing recorded again';
  }

  @override
  String get copyTicketId => 'Copy ticket ID';

  @override
  String get reversedTitle => 'Check-in reversed';

  @override
  String get reversedBody => 'The ticket is valid again';

  @override
  String get admission => '1 admission';

  @override
  String reverseTitle(String name) {
    return 'Undo the check-in for $name?';
  }

  @override
  String get reverseBody =>
      'The ticket becomes valid again. The reversal is logged with your name and cannot be deleted.';

  @override
  String get checkedInLabel => 'Checked in';

  @override
  String get recordedBy => 'Recorded by';

  @override
  String get ticketLabel => 'Ticket';

  @override
  String get reasonRequired => 'Reason (required)';

  @override
  String get reasonHint => 'e.g. scanned the wrong person';

  @override
  String get guestSearchHint => 'Name, email, ticket code or order number';

  @override
  String get statusValid => 'Valid';

  @override
  String get statusUsed => 'Used';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get markEntry => 'Check in';

  @override
  String get guestSearchStart => 'Start typing a name — at least 2 characters';

  @override
  String guestNoMatches(String query) {
    return 'Nobody matches “$query”';
  }

  @override
  String get guestNoMatchesHint =>
      'Check the spelling or search by ticket code';

  @override
  String filterAll(int count) {
    return 'All $count';
  }

  @override
  String filterNotArrived(int count) {
    return 'Not arrived $count';
  }

  @override
  String get checkedInToast => 'Checked in';

  @override
  String ticketsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '$count ticket',
    );
    return '$_temp0';
  }

  @override
  String get guest => 'Guest';

  @override
  String get ticketsInOrder => 'Tickets in this order';

  @override
  String checkInAll(int count) {
    return 'Check in all $count tickets';
  }

  @override
  String get history => 'History';

  @override
  String get manualNote =>
      'Manual check-ins are recorded under your name and visible to the organizer.';

  @override
  String notArrivedCount(int count) {
    return 'Not arrived: $count';
  }

  @override
  String get allUsedOrVoid => 'All tickets used or void';

  @override
  String get recordUnavailable => 'This record is not available';

  @override
  String get entered => 'Checked in';

  @override
  String stillToCome(int count) {
    return '$count still to come';
  }

  @override
  String get registered => 'Registered';

  @override
  String get notArrived => 'Not arrived';

  @override
  String get cancelledStat => 'Cancelled';

  @override
  String get refundedStat => 'Refunded';

  @override
  String get reversals => 'Reversals';

  @override
  String get byTicketType => 'By ticket type';

  @override
  String get recentEntries => 'Recent check-ins';

  @override
  String get noEntriesYet => 'No check-ins yet';

  @override
  String get statsUnavailable => 'Stats are unavailable';

  @override
  String get offlineBody => 'Check the internet and try again';

  @override
  String get connectionRestored => 'Connection restored';

  @override
  String get stillOffline => 'Still no connection to the server';

  @override
  String lastSync(String time) {
    return 'Last sync: $time';
  }

  @override
  String get offlineNote =>
      'Tickets are checked on the server, so scanning pauses without a connection. Nothing is stored on the phone.';

  @override
  String get scanningSection => 'Scanning';

  @override
  String get torchDefault => 'Torch on by default';

  @override
  String get soundOnResult => 'Sound on result';

  @override
  String get vibrateOnReject => 'Vibrate on reject';

  @override
  String get gateSection => 'Gate';

  @override
  String get assignedGate => 'My gate';

  @override
  String get roleEventAdmin => 'Gate staff';

  @override
  String get roleAttendee => 'Attendee';

  @override
  String get roleOrganizer => 'Organizer';

  @override
  String get rolePlatformAdmin => 'Platform admin';

  @override
  String eventsCount(int count) {
    return 'Events: $count';
  }

  @override
  String get server => 'Server';

  @override
  String get demoBuild =>
      'Demo build: all payments are simulated, no money moves.';

  @override
  String get account => 'Account';

  @override
  String get notifications => 'Notifications';

  @override
  String get organizerProfile => 'Organizer profile & payout';

  @override
  String get evDraft => 'Draft';

  @override
  String get evPublished => 'Published';

  @override
  String get evCancelled => 'Cancelled';

  @override
  String get evCompleted => 'Completed';

  @override
  String get evLive => 'Live now';

  @override
  String get visPublic => 'Public';

  @override
  String get visUnlisted => 'Unlisted';

  @override
  String get visPrivate => 'Private';

  @override
  String get orderPending => 'Awaiting payment';

  @override
  String get orderPaid => 'Paid';

  @override
  String get orderCancelled => 'Cancelled';

  @override
  String get orderRefunded => 'Refunded';

  @override
  String get caseOpen => 'Open';

  @override
  String get caseInProgress => 'In progress';

  @override
  String get caseWaiting => 'Waiting for customer';

  @override
  String get caseResolved => 'Resolved';

  @override
  String get catTicketDelivery => 'Ticket delivery';

  @override
  String get catPayment => 'Payment';

  @override
  String get catRefund => 'Refund';

  @override
  String get catSeating => 'Seating';

  @override
  String get catEventInfo => 'Event information';

  @override
  String get catCheckIn => 'Check-in';

  @override
  String get catAccount => 'Account';

  @override
  String get catActivation => 'Paid sales activation';

  @override
  String get catTechnical => 'Technical problem';

  @override
  String get auditEventChanges => 'Event changes';

  @override
  String get auditRefunds => 'Refunds';

  @override
  String get auditCampaigns => 'Campaigns';

  @override
  String get auditCheckIns => 'Check-ins';

  @override
  String get auditSupport => 'Support';

  @override
  String seatLabel(String section, String row, String number) {
    return 'Sec $section · Row $row · Seat $number';
  }

  @override
  String get secOverview => 'Overview';

  @override
  String get secTickets => 'Tickets';

  @override
  String get secSeating => 'Seat map';

  @override
  String get secOrders => 'Orders';

  @override
  String get secPromo => 'Promo';

  @override
  String get secStaff => 'Staff';

  @override
  String get secSales => 'Sales';

  @override
  String get secHistory => 'History';

  @override
  String get secCheckIn => 'Check-in';

  @override
  String get eventActions => 'Event actions';

  @override
  String get actEdit => 'Edit';

  @override
  String get actDuplicate => 'Duplicate';

  @override
  String get actPublish => 'Publish';

  @override
  String get actUnpublish => 'Unpublish';

  @override
  String get actCancelEvent => 'Cancel event';

  @override
  String get cancelEventTitle => 'Cancel this event?';

  @override
  String get cancelEventBody =>
      'Sales stop and every ticket becomes invalid. Attendees are notified. Records stay in the event history.';

  @override
  String get publishedToast => 'Published. Attendees can register now.';

  @override
  String get unpublishedToast => 'Unpublished. The event is a draft again.';

  @override
  String get cancelledToast => 'Event cancelled.';

  @override
  String get duplicatedToast =>
      'Copied into a new draft without orders, tickets or check-ins.';

  @override
  String get salesNotActive =>
      'Paid sales are not activated — buyers cannot purchase paid tickets';

  @override
  String get actActivate => 'Activate';

  @override
  String get kpiSold => 'Sold';

  @override
  String get kpiGross => 'Gross revenue';

  @override
  String get kpiNet => 'Net revenue';

  @override
  String get kpiAttendance => 'Attendance';

  @override
  String get kpiOrders => 'Orders';

  @override
  String get kpiDiscounts => 'Discounts';

  @override
  String get kpiRefunds => 'Refunds';

  @override
  String get kpiRemaining => 'Remaining';

  @override
  String get salesByType => 'Sales by ticket type';

  @override
  String get promoEffect => 'Promo code performance';

  @override
  String redeemedOf(String used, String max) {
    return '$used of $max';
  }

  @override
  String redeemed(int count) {
    return '$count used';
  }

  @override
  String get salesOverTime => 'Sales over time';

  @override
  String get noOrdersYet => 'No orders yet.';

  @override
  String get eventFallback => 'Event';

  @override
  String get createEvent => 'Create an event';

  @override
  String get firstEventTitle => 'Create your first event';

  @override
  String get firstEventBody =>
      'Creating events and issuing free tickets costs nothing. Paid sales are activated per event when you need them.';

  @override
  String filterAllN(int count) {
    return 'All $count';
  }

  @override
  String filterDraftsN(int count) {
    return 'Drafts $count';
  }

  @override
  String filterPublishedN(int count) {
    return 'Published $count';
  }

  @override
  String filterLiveN(int count) {
    return 'Live $count';
  }

  @override
  String filterPastN(int count) {
    return 'Past $count';
  }

  @override
  String filterCancelledN(int count) {
    return 'Cancelled $count';
  }

  @override
  String get searchByTitle => 'Search by title';

  @override
  String soldOf(String sold, String total) {
    return 'Sold $sold / $total';
  }

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get noNotificationsHint =>
      'Orders, refunds and support replies will appear here.';

  @override
  String get demoPayments =>
      'Demonstration build: payments run in a sandbox. No money moves and no card is stored.';

  @override
  String get ordersSearchHint => 'Buyer or order number';

  @override
  String get filtersTitle => 'Filter';

  @override
  String get attAll => 'All';

  @override
  String get attCheckedIn => 'Checked in';

  @override
  String get attNotArrived => 'Not arrived';

  @override
  String get attRefunded => 'Refunded or cancelled';

  @override
  String get attCampaign => 'With promo code';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String orderNo(String id) {
    return '#$id';
  }

  @override
  String get noOrder => 'No order';

  @override
  String get refundMoney => 'Refund';

  @override
  String refundTitle(String id) {
    return 'Refund order #$id';
  }

  @override
  String get buyer => 'Buyer';

  @override
  String get positions => 'Items';

  @override
  String get toRefund => 'To refund';

  @override
  String get reasonStar => 'Reason *';

  @override
  String get refundReasonHint => 'e.g. the buyer can no longer attend';

  @override
  String refundConfirm(String amount) {
    return 'Refund $amount';
  }

  @override
  String get refundedToast => 'Order refunded. The buyer is emailed.';

  @override
  String refundUsedWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets were',
      one: '$count ticket was',
    );
    return '$_temp0 already checked in. Refunding does not undo admission.';
  }

  @override
  String get refundNote =>
      'Tickets become invalid immediately and seats return to sale.';

  @override
  String get orderTitle => 'Order';

  @override
  String get statusLabel => 'Status';

  @override
  String discountCode(String code) {
    return 'Discount $code';
  }

  @override
  String get paidLabel => 'Paid';

  @override
  String get placedLabel => 'Placed';

  @override
  String usedOfTotal(String used, String total) {
    return '$used of $total';
  }

  @override
  String get noOrdersMatch => 'No orders match';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get errOrderNotFound => 'Order not found.';

  @override
  String get errOrderNoEvent => 'This order has no event.';

  @override
  String get errRowInvalid => 'Every row needs a label and at least one seat.';

  @override
  String errSeatsOverTickets(String name, int seats, int quantity) {
    return 'The map has $seats “$name” seats but only $quantity tickets — increase the quantity';
  }

  @override
  String seatPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '$count seat',
    );
    return 'Preview · $_temp0';
  }

  @override
  String get fullScreen => 'Full screen';

  @override
  String get stage => 'STAGE';

  @override
  String get sectionsTitle => 'Sections';

  @override
  String rowsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '$count row',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '$count seat',
    );
    return '$_temp0';
  }

  @override
  String get modeQuick => 'Quick';

  @override
  String get modeManual => 'Manual';

  @override
  String get sectionName => 'Section name';

  @override
  String get rowsLabel => 'Rows';

  @override
  String get seatsPerRowLabel => 'Seats per row';

  @override
  String get rowLabel => 'Row';

  @override
  String get seatsLabel => 'Seats';

  @override
  String get addRow => 'Add row';

  @override
  String get addSection => 'Add section';

  @override
  String get saveMap => 'Save seat map';

  @override
  String get deleteMap => 'Delete seat map';

  @override
  String get deleteMapTitle => 'Delete the seat map?';

  @override
  String get deleteMapBody =>
      'Seats disappear and buyers can no longer pick them.';

  @override
  String get mapSaved => 'Seat map saved.';

  @override
  String get mapDeleted => 'Seat map deleted.';

  @override
  String get mapSoldLocked =>
      'Seats are already sold, so the map cannot be deleted.';

  @override
  String get noSeatMapYet =>
      'No seat map yet. Add a section — each one sells at its ticket type\'s price.';

  @override
  String get needTicketTypeFirst =>
      'Add a ticket type first — sections are priced by ticket type.';

  @override
  String get ticketTypeLabel => 'Ticket type';

  @override
  String get removeSection => 'Remove section';

  @override
  String sectionDefault(String name) {
    return 'Section $name';
  }

  @override
  String get actionDelete => 'Delete';

  @override
  String get activationTitle => 'Paid sales activation';

  @override
  String activationProgress(int done, int total) {
    return '$done of $total requirements met. Until paid sales are activated, only free tickets are available.';
  }

  @override
  String get chkPaidType => 'A paid ticket type exists';

  @override
  String get chkPaidTypeMissing => 'Add a ticket type with a price above zero';

  @override
  String get chkIdentity => 'Identity verified';

  @override
  String get chkIdentityMissing => 'Sandbox check of the organizer profile';

  @override
  String get chkPayout => 'Payout details verified';

  @override
  String get chkPayoutMissing => 'Add your bank and account number';

  @override
  String get chkFee => 'Activation fee paid';

  @override
  String get chkFeeMissing =>
      'One-time fee for this event — charged on activation (sandbox)';

  @override
  String get doneLabel => 'Done';

  @override
  String get fixLink => 'Fix →';

  @override
  String get termsAccept =>
      'I accept the paid-event terms: refunds, chargebacks, payout timing';

  @override
  String get activateButton => 'Activate paid sales';

  @override
  String get activatedTitle => 'Paid sales active';

  @override
  String get activatedBody => 'Buyers can purchase paid tickets';

  @override
  String get activatedToast => 'Paid sales activated (sandbox).';

  @override
  String get demoActivation =>
      'Identity checks, the fee, ticket payments and payouts run in a sandbox. No money moves.';

  @override
  String get orgProfileTitle => 'Organizer profile';

  @override
  String get orgProfileSub => 'Contact & payout';

  @override
  String get identityOk => 'Identity verified';

  @override
  String get identityNo => 'Identity not verified';

  @override
  String get payoutOk => 'Payout verified';

  @override
  String get payoutNo => 'Payout not verified';

  @override
  String get organization => 'Organization';

  @override
  String get orgName => 'Organization name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get contactEmail => 'Contact email';

  @override
  String get contactPhone => 'Contact phone';

  @override
  String get website => 'Website';

  @override
  String get payoutSection => 'Payout account · sandbox';

  @override
  String get bank => 'Bank';

  @override
  String get accountNumber => 'Account number';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get demoPayout =>
      'Payout details are used for a simulated payout only. No real transfers.';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get issued => 'Issued';

  @override
  String get available => 'Available';

  @override
  String get refundedVoid => 'Refunded / void';

  @override
  String get noTicketTypes => 'No ticket types yet';

  @override
  String get noTicketTypesHint =>
      'Add at least one free or paid ticket type before publishing.';

  @override
  String get ttHidden => 'Hidden';

  @override
  String get ttSoldOut => 'Sold out';

  @override
  String get ttOnSale => 'On sale';

  @override
  String get ttNotOnSale => 'Not on sale';

  @override
  String get priceLabel => 'Price';

  @override
  String get maxPerOrder => 'Max per order';

  @override
  String get salesWindow => 'Sales';

  @override
  String get salesNow => 'now';

  @override
  String get salesUntilEvent => 'event';

  @override
  String get actHide => 'Hide';

  @override
  String get hiddenToast => 'Hidden from sale. Sold tickets stay valid.';

  @override
  String get ttAdded => 'Ticket type added.';

  @override
  String get savedToast => 'Saved.';

  @override
  String get addTicketType => 'Add a ticket type';

  @override
  String get newTicketType => 'New ticket type';

  @override
  String get editTicketType => 'Edit ticket type';

  @override
  String get nameLabel => 'Name';

  @override
  String get freeTicket => 'Free ticket';

  @override
  String get priceKzt => 'Price, ₸';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get salesStartOpt => 'Sales start (optional)';

  @override
  String get salesEndOpt => 'Sales end (optional)';

  @override
  String get paidNeedsActivation =>
      'Paid tickets can be sold only after paid sales are activated for this event.';

  @override
  String get pickDateTime => 'Pick date and time';

  @override
  String get campaignQrTitle => 'Campaign QR — not a ticket';

  @override
  String get codeLabel => 'Code';

  @override
  String get linkLabel => 'Link';

  @override
  String campaignQrNote(String code) {
    return 'Opens the event page with $code pre-applied. The link carries the code, never a price — the server validates it. The scanner refuses it at the gate.';
  }

  @override
  String get shareLink => 'Share link';

  @override
  String get copyCode => 'Copy code';

  @override
  String get codeCopied => 'Code copied.';

  @override
  String get noCampaigns => 'No campaigns yet';

  @override
  String get noCampaignsHint =>
      'A campaign gives a discount through a promo code and a trackable Campaign QR.';

  @override
  String get campLive => 'Live';

  @override
  String get campNotLive => 'Not live';

  @override
  String get campDisabled => 'Disabled';

  @override
  String get codeHidden => 'Not returned by the server';

  @override
  String get discountLabel => 'Discount';

  @override
  String percentOff(String value) {
    return '$value% off';
  }

  @override
  String amountOff(String value) {
    return '$value off';
  }

  @override
  String get usedLabel => 'Used';

  @override
  String get validLabel => 'Valid';

  @override
  String get validOpen => 'open';

  @override
  String get qrAndLink => 'QR & link';

  @override
  String get actDisable => 'Disable';

  @override
  String get campaignDisabled => 'Campaign disabled.';

  @override
  String get campaignsNote =>
      'Redemption limits are enforced on the server. Codes of campaigns created on other devices are not returned by the API.';

  @override
  String get createCampaign => 'Create campaign';

  @override
  String get newCampaign => 'New campaign';

  @override
  String get discPercent => 'Percentage';

  @override
  String get discFixed => 'Fixed ₸';

  @override
  String get discountPct => 'Discount, %';

  @override
  String get discountKzt => 'Discount, ₸';

  @override
  String get maxRedemptions => 'Max redemptions';

  @override
  String get validFrom => 'Valid from';

  @override
  String get validTo => 'Valid to';

  @override
  String get createAndQr => 'Create and get QR';

  @override
  String get staffIntro =>
      'People you add can sign into the scanner app and see this event only. They never see revenue, orders or your other events.';

  @override
  String get nobodyAssigned => 'Nobody is assigned yet.';

  @override
  String userNo(String id) {
    return 'user #$id';
  }

  @override
  String get actRemove => 'Remove';

  @override
  String get staffRemoved => 'Removed from this event.';

  @override
  String get addEventAdmin => 'Add an event admin';

  @override
  String get userId => 'User ID';

  @override
  String get actAdd => 'Add';

  @override
  String get staffAdded => 'Added. They can sign into the scanner now.';

  @override
  String get staffIdNote =>
      'The API assigns staff by user ID only — adding by email is not available yet. The person needs an EVENT_ADMIN account.';

  @override
  String get gateActivity => 'Live gate activity';

  @override
  String get auditTrailNote =>
      'Entries cannot be edited or deleted. Platform admins can read the same trail.';

  @override
  String get noHistory => 'No entries yet.';

  @override
  String allN(int count) {
    return 'All · $count';
  }

  @override
  String get absentHolders => 'Absent holders';

  @override
  String get ofCapacity => 'of capacity';

  @override
  String get createEventTitle => 'Create event';

  @override
  String get editEventTitle => 'Edit event';

  @override
  String get draftHint => 'Draft — nothing is public until you publish';

  @override
  String get basics => 'Basics';

  @override
  String get eventTitleLabel => 'Event title';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryHint => 'Music, Tech, Sport, Theatre';

  @override
  String get visibilityLabel => 'Visibility';

  @override
  String get venueSection => 'Venue';

  @override
  String get venueLabel => 'Venue';

  @override
  String get addressLabel => 'Address';

  @override
  String get cityLabel => 'City';

  @override
  String get dateSection => 'Date & registration';

  @override
  String get startsLabel => 'Starts';

  @override
  String get endsLabel => 'Ends';

  @override
  String get regOpens => 'Registration opens';

  @override
  String get regCloses => 'Registration closes';

  @override
  String get capacityLabel => 'Capacity';

  @override
  String get seatingImage => 'Seating & image';

  @override
  String get assignedSeating => 'Assigned seating';

  @override
  String get assignedSeatingHint =>
      'Attendees pick seats on a map at checkout.';

  @override
  String get coverUrl => 'Cover image URL (optional)';

  @override
  String get coverNote =>
      'Image upload is not available in this build — paste a link to a hosted image.';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get draftSaved => 'Draft saved. Add ticket types next.';

  @override
  String get changesSaved => 'Changes saved.';

  @override
  String get adminBanner => 'Platform admin · internal staff only';

  @override
  String get roleUnknown => 'Unknown';

  @override
  String get roleBuyer => 'Buyer';

  @override
  String get roleGate => 'Gate staff';

  @override
  String get roleAdminShort => 'Admin';

  @override
  String get allRoles => 'All roles';

  @override
  String get workQueues => 'Work queues';

  @override
  String get unpaidOrders => 'Unpaid orders';

  @override
  String get paidSalesEvents => 'Paid-sales events';

  @override
  String get suspendedUsers => 'Suspended users';

  @override
  String get refundsQueue => 'Refunds';

  @override
  String platformTotals(int users, int events, int orders) {
    return '$users users · $events events · $orders orders on the platform';
  }

  @override
  String get unpaidOrdersHint =>
      'Unpaid orders · payment failures and abandoned checkouts';

  @override
  String get noTicketsIssued => 'No tickets issued';

  @override
  String get paidSalesRecords => 'Paid sales active';

  @override
  String get allOrdersPayments => 'All orders & payments';

  @override
  String get notInBuild => 'Not available in this build';

  @override
  String get notInBuildBody =>
      'Reported events, activation reviews, escalated support cases, report exports and activation fee settings need backend endpoints that do not exist yet.';

  @override
  String get nothingHere => 'Nothing here.';

  @override
  String get adminEventsSearch => 'Event, organizer or city';

  @override
  String get noDate => 'No date';

  @override
  String get paidSalesTag => 'Paid sales';

  @override
  String get suspendEventTitle => 'Suspend this event?';

  @override
  String get suspendEventBody =>
      'New checkouts stop immediately. Issued tickets stay valid until voided.';

  @override
  String get actSuspend => 'Suspend';

  @override
  String get eventSuspendedToast => 'Event suspended and sales stopped.';

  @override
  String get moderation => 'Moderation';

  @override
  String get suspendedTag => 'Suspended';

  @override
  String get paidSalesActive => 'Paid sales active';

  @override
  String moderationSummary(String organizer, String sold, String collected) {
    return '$organizer · $sold tickets sold · $collected collected';
  }

  @override
  String get organizerFallback => 'Organizer';

  @override
  String get whenLabel => 'When';

  @override
  String get organizerRecord => 'Organizer record';

  @override
  String get accountLabel => 'Account';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ordersOnEvent => 'Orders on this event';

  @override
  String get suspendingWill => 'Suspending will';

  @override
  String get suspendWill1 => 'Stop new checkouts for this event immediately.';

  @override
  String get suspendWill2 => 'Leave issued tickets valid until you void them.';

  @override
  String get suspendWill3 => 'Hold any payout to the organizer.';

  @override
  String get suspendWill4 => 'Write an entry into the event audit trail.';

  @override
  String get suspendReason => 'Reason recorded and sent to the organizer';

  @override
  String get suspendReasonNote =>
      'The current API does not store the reason yet; keep it for your records.';

  @override
  String get suspendEventButton => 'Suspend event & sales';

  @override
  String get nameOrEmail => 'Name or email';

  @override
  String get userActive => 'Active';

  @override
  String get userBlocked => 'Blocked';

  @override
  String get actBlock => 'Block';

  @override
  String get actUnblock => 'Unblock';

  @override
  String blockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String unblockTitle(String name) {
    return 'Unblock $name?';
  }

  @override
  String get blockBody => 'They will not be able to sign in until unblocked.';

  @override
  String get unblockBody => 'They can sign in and use BiletFlow again.';

  @override
  String get userBlockedToast => 'User blocked.';

  @override
  String get userUnblockedToast => 'User unblocked.';

  @override
  String get staffTag => 'Staff';

  @override
  String get noCardData =>
      'No card data is stored or shown. All payments are sandbox.';

  @override
  String get noUsersMatch => 'No users match';

  @override
  String get generalSection => 'General';

  @override
  String get demoFootnote =>
      'All payments in this build are demonstration only — no money moves.';

  @override
  String get supportInbox => 'Support inbox';

  @override
  String get newCase => 'New case';

  @override
  String openN(int count) {
    return 'Open $count';
  }

  @override
  String resolvedN(int count) {
    return 'Resolved $count';
  }

  @override
  String get noOpenCases => 'No open cases';

  @override
  String get noResolvedCases => 'Nothing resolved yet';

  @override
  String get supportEmptyOrganizer =>
      'Questions from attendees of your events and your own requests to the platform appear here.';

  @override
  String get supportEmptyAttendee =>
      'Open a case from an event, an order or with the + button. Replies arrive here and by email.';

  @override
  String get eventLabel => 'Event';

  @override
  String get noCaseContext =>
      'Support cases go to the organizer of an event. Register for or buy a ticket first, then open the case from that event or order.';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get subjectHint => 'Second ticket did not arrive';

  @override
  String get messageLabel => 'Message';

  @override
  String get orderAttached =>
      'The order is attached automatically, so support sees the context.';

  @override
  String get eventAttached =>
      'The event is attached automatically, so support sees the context.';

  @override
  String caseOpened(String number) {
    return 'Case $number opened.';
  }

  @override
  String get caseFallback => 'Case';

  @override
  String get openedBy => 'Opened by';

  @override
  String get assignedLabel => 'Assigned';

  @override
  String get openedLabel => 'Opened';

  @override
  String get noMessages => 'No messages yet.';

  @override
  String get repliesNote =>
      'Replies arrive by email and in your account — nobody has to be online.';

  @override
  String get markResolved => 'Mark as resolved';

  @override
  String get replyHint => 'Write a reply…';

  @override
  String get scanCampaignQr => 'Scan a campaign QR';

  @override
  String upcomingN(int count) {
    return '$count upcoming';
  }

  @override
  String get catalogSearch => 'Search events, venues, organizers';

  @override
  String filtersN(int count) {
    return 'Filters · $count';
  }

  @override
  String get filters => 'Filters';

  @override
  String get noUpcoming => 'No upcoming events';

  @override
  String get noUpcomingHint =>
      'Published public events appear here as soon as organizers open registration.';

  @override
  String get nothingMatches => 'Nothing matches';

  @override
  String get nothingMatchesHint => 'Try another city, date or price.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get soldOut => 'Sold out';

  @override
  String fromPrice(String price) {
    return 'from $price';
  }

  @override
  String get seatedTag => 'Seated';

  @override
  String get registrationTag => 'Registration';

  @override
  String get cityFilter => 'City';

  @override
  String get anyOption => 'Any';

  @override
  String get whenFilter => 'When';

  @override
  String get anyTime => 'Any time';

  @override
  String get thisWeekend => 'This weekend';

  @override
  String get next30 => 'Next 30 days';

  @override
  String get priceFilter => 'Price';

  @override
  String get anyPrice => 'Any price';

  @override
  String get freeOnly => 'Free only';

  @override
  String get under5000 => 'Under 5 000 ₸';

  @override
  String get showEvents => 'Show events';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get downloadIcs => 'Download .ics';

  @override
  String get calendarNote =>
      'Includes venue address and time. If the organizer changes the time, the updated file replaces your entry.';

  @override
  String promoApplied(String code, String discount) {
    return '$code applied: $discount';
  }

  @override
  String get promoVerified =>
      'Verified on the server. You will see the final total before paying.';

  @override
  String get dateLabel => 'Date';

  @override
  String get regClosesLabel => 'Registration closes';

  @override
  String get registrationClosed => 'Registration is closed for this event.';

  @override
  String get noTicketsOnSale => 'No tickets are on sale yet.';

  @override
  String get promoCodeLabel => 'Promo code';

  @override
  String get actApply => 'Apply';

  @override
  String get contactSupportEvent => 'Contact support';

  @override
  String maxPerOrderN(int count) {
    return 'max $count per order';
  }

  @override
  String leftN(String count) {
    return '$count left';
  }

  @override
  String get chooseSeats => 'Choose seats';

  @override
  String get continueCheckout => 'Continue to checkout';

  @override
  String get seatsHeldNote => 'Seats are held for 10 minutes at checkout.';

  @override
  String get notCampaignQr => 'This QR is not a BiletFlow campaign link.';

  @override
  String get cameraOffCampaign =>
      'Camera access is off. Turn it on in Settings to scan campaign codes.';

  @override
  String get campaignScanHint =>
      'Point at a poster or flyer QR. The event opens with its discount applied after the server checks the code.';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get stepsSeats => 'Seats › Details & payment › Tickets';

  @override
  String get stepsNoSeats => 'Details & payment › Tickets';

  @override
  String get holdExpired => 'Seat hold expired — go back and choose again';

  @override
  String holdExpiresIn(String time) {
    return 'Hold expires in $time';
  }

  @override
  String get yourDetails => 'Your details';

  @override
  String get emailTickets => 'Email — tickets are sent here';

  @override
  String get paymentSection => 'Payment';

  @override
  String get payCard => 'Card · sandbox';

  @override
  String get payKaspi => 'Kaspi transfer · sandbox';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get totalKzt => 'Total';

  @override
  String get serverRecalcs =>
      'The server recalculates the discount; the charged total may differ slightly.';

  @override
  String get getFreeTickets => 'Get free tickets';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get freeConfirmedNote =>
      'Free orders are confirmed immediately and tickets are issued at once.';

  @override
  String get paidConfirmedNote =>
      'Tickets are issued only after the sandbox confirms payment.';

  @override
  String get chooseYourSeats => 'Choose your seats';

  @override
  String get noSeatMapBuyer => 'No seat map yet';

  @override
  String get noSeatMapBuyerHint =>
      'The organizer has not published a seating layout for this event.';

  @override
  String get seatAvailable => 'Available';

  @override
  String get seatSelected => 'Selected';

  @override
  String get seatHeld => 'Held';

  @override
  String get seatSold => 'Sold';

  @override
  String get seatUnavailable => 'Unavailable';

  @override
  String pickedOf(int picked, int needed) {
    return '$picked of $needed seats';
  }

  @override
  String get seatsHeldContinue =>
      'Seats are held for you for 10 minutes once you continue.';

  @override
  String get myTickets => 'My tickets';

  @override
  String tabUpcomingN(int count) {
    return 'Upcoming $count';
  }

  @override
  String tabPastN(int count) {
    return 'Past $count';
  }

  @override
  String tabRefundedN(int count) {
    return 'Refunded $count';
  }

  @override
  String get noUpcomingTickets => 'No upcoming tickets';

  @override
  String get noUpcomingTicketsHint =>
      'Tickets you buy or register for appear here with their QR codes.';

  @override
  String get pastTicketsHint =>
      'Tickets show up here after the event or after a refund.';

  @override
  String get browseEvents => 'Browse events';

  @override
  String get dateTba => 'Date TBA';

  @override
  String get viewTicket => 'View ticket';

  @override
  String get viewTickets => 'View tickets';

  @override
  String get admissionTicket => 'Admission ticket';

  @override
  String get admitsOne => 'Admits 1';

  @override
  String get attendeeLabel => 'Attendee';

  @override
  String get seatLabelShort => 'Seat';

  @override
  String get ticketIdLabel => 'Ticket ID';

  @override
  String get issuedLabel => 'Issued';

  @override
  String get qrKeepNote =>
      'Keep the QR clean and unfolded. This ticket admits one person once; digital and printed copies share one identifier.';

  @override
  String get print => 'Print';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get cancelOrderTitle => 'Cancel this order?';

  @override
  String get cancelOrderBody =>
      'All tickets in the order become invalid and will be refused at the gate. Refunds follow the organizer\'s policy.';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get orderCancelledToast => 'Order cancelled.';

  @override
  String get ticketReady => 'Your ticket is ready';

  @override
  String ticketsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets are yours',
      one: '$count ticket is yours',
    );
    return '$_temp0';
  }

  @override
  String confirmationSent(String email) {
    return 'Confirmation sent to $email';
  }

  @override
  String get yourTickets => 'Your tickets';

  @override
  String get ticketsAfterPayment =>
      'Tickets are issued after payment is confirmed.';

  @override
  String get typeLabel => 'Type';

  @override
  String get showQr => 'Show QR';

  @override
  String get showQrNote =>
      'Show the QR on your phone or on paper. Each ticket admits one person once.';

  @override
  String get totalLabel => 'Total';

  @override
  String get methodLabel => 'Method';

  @override
  String get sandboxPayment => 'Sandbox payment';

  @override
  String get helpWithOrder => 'Get help with this order';
}
