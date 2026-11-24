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
}
