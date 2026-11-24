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
  String get enterCodeHint => 'The code under the QR or from the email';

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
}
