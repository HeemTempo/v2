import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'OpenSpace'**
  String get appName;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting Communities'**
  String get splashTagline;

  /// No description provided for @termsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy Policy'**
  String get termsPrivacyTitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to OpenSpace, a platform dedicated to enhancing community engagement through reporting issues and booking public spaces. By using OpenSpace, you agree to the following terms ...'**
  String get termsContent;

  /// No description provided for @privacyContent.
  ///
  /// In en, this message translates to:
  /// **'At OpenSpace, we prioritize your privacy and adhere to Tanzania’s Personal Data Protection Act, 2022...'**
  String get privacyContent;

  /// No description provided for @effectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: 30 July 2025'**
  String get effectiveDate;

  /// No description provided for @copyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© 2025 OpenSpace Tanzania'**
  String get copyrightNotice;

  /// No description provided for @acceptAndReturn.
  ///
  /// In en, this message translates to:
  /// **'Accept and Return'**
  String get acceptAndReturn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your credentials to sign in'**
  String get signInSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'********'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create account'**
  String get dontHaveAccount;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully Logged In!'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your details to sign up'**
  String get signUpSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @wardLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Ward'**
  String get wardLabel;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get passwordConfirmLabel;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree with Terms and Privacy'**
  String get agreeTerms;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registered successfully! Please sign in.'**
  String get signUpSuccess;

  /// No description provided for @signUpErrorAgree.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Terms and Privacy'**
  String get signUpErrorAgree;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @wardRequired.
  ///
  /// In en, this message translates to:
  /// **'Ward is required'**
  String get wardRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get passwordConfirmRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @helpFaqs.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQs'**
  String get helpFaqs;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicyMenu.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyMenu;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate This App'**
  String get rateApp;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @reportIssueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit concerns about open spaces'**
  String get reportIssueSubtitle;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// No description provided for @viewReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check status of reported issues'**
  String get viewReportsSubtitle;

  /// No description provided for @bookSpace.
  ///
  /// In en, this message translates to:
  /// **'Book Space'**
  String get bookSpace;

  /// No description provided for @bookSpaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reserve an open space'**
  String get bookSpaceSubtitle;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get trackProgress;

  /// No description provided for @trackProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor community improvements'**
  String get trackProgressSubtitle;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @openSpaces.
  ///
  /// In en, this message translates to:
  /// **'Open Spaces'**
  String get openSpaces;

  /// No description provided for @activeReports.
  ///
  /// In en, this message translates to:
  /// **'Active Reports'**
  String get activeReports;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @newReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'New report submitted'**
  String get newReportSubmitted;

  /// No description provided for @spaceBooked.
  ///
  /// In en, this message translates to:
  /// **'Space booked'**
  String get spaceBooked;

  /// No description provided for @issueResolved.
  ///
  /// In en, this message translates to:
  /// **'Issue resolved'**
  String get issueResolved;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get police;

  /// No description provided for @fire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get fire;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @heroTitle1.
  ///
  /// In en, this message translates to:
  /// **'Dar es Salaam Open Spaces'**
  String get heroTitle1;

  /// No description provided for @heroTitle2.
  ///
  /// In en, this message translates to:
  /// **'Community Gardens'**
  String get heroTitle2;

  /// No description provided for @heroTitle3.
  ///
  /// In en, this message translates to:
  /// **'Public Parks & Recreation'**
  String get heroTitle3;

  /// No description provided for @heroTitle4.
  ///
  /// In en, this message translates to:
  /// **'Urban Green Spaces'**
  String get heroTitle4;

  /// No description provided for @heroSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Building stronger communities together'**
  String get heroSubtitle1;

  /// No description provided for @heroSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Growing together as one community'**
  String get heroSubtitle2;

  /// No description provided for @heroSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Fun for families and friends'**
  String get heroSubtitle3;

  /// No description provided for @heroSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Nature in the heart of the city'**
  String get heroSubtitle4;

  /// No description provided for @mapScreenAppBar.
  ///
  /// In en, this message translates to:
  /// **'Open Spaces Map'**
  String get mapScreenAppBar;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search public open space'**
  String get searchHint;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @openSpaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Open Space Details'**
  String get openSpaceDetails;

  /// No description provided for @amenitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenitiesLabel;

  /// No description provided for @getDirectionsButton.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirectionsButton;

  /// No description provided for @bookNowButton.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNowButton;

  /// No description provided for @reportButton.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @unknownArea.
  ///
  /// In en, this message translates to:
  /// **'Unknown Area'**
  String get unknownArea;

  /// No description provided for @noSpaceSelected.
  ///
  /// In en, this message translates to:
  /// **'No space selected for booking.'**
  String get noSpaceSelected;

  /// No description provided for @spaceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This space is currently not available for booking.'**
  String get spaceNotAvailable;

  /// No description provided for @pinpointedNotPublic.
  ///
  /// In en, this message translates to:
  /// **'Pinpointed area is not a Public open space'**
  String get pinpointedNotPublic;

  /// No description provided for @unableFetchLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch location.'**
  String get unableFetchLocation;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Location error'**
  String get locationError;

  /// No description provided for @directionsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch your current location.'**
  String get directionsError;

  /// No description provided for @distanceInfo.
  ///
  /// In en, this message translates to:
  /// **'Directions to {area}:\nStraight-line distance: {distance} km.\n(Implement a directions API for detailed navigation.)'**
  String distanceInfo(Object area, Object distance);

  /// No description provided for @reportPageTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenSpace Report'**
  String get reportPageTitle;

  /// No description provided for @reportHeader.
  ///
  /// In en, this message translates to:
  /// **'Report unused or underutilized public spaces in your community'**
  String get reportHeader;

  /// No description provided for @locationDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetailsTitle;

  /// No description provided for @spaceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Space Name'**
  String get spaceNameLabel;

  /// No description provided for @coordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinatesLabel;

  /// No description provided for @yourInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Information'**
  String get yourInfoTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get phoneLabel;

  /// No description provided for @issueDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Description'**
  String get issueDescriptionTitle;

  /// No description provided for @issueDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Please provide a clear description of the issue you\'ve observed...'**
  String get issueDescriptionHint;

  /// No description provided for @attachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsTitle;

  /// No description provided for @attachmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Add photos or documents to support your report (max 5 files)'**
  String get attachmentsHint;

  /// No description provided for @addPhotosButton.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotosButton;

  /// No description provided for @addDocumentsButton.
  ///
  /// In en, this message translates to:
  /// **'Add Documents'**
  String get addDocumentsButton;

  /// No description provided for @reportGuidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting Guidelines'**
  String get reportGuidelinesTitle;

  /// No description provided for @guideline1.
  ///
  /// In en, this message translates to:
  /// **'Provide accurate details to assist government officials.'**
  String get guideline1;

  /// No description provided for @guideline2.
  ///
  /// In en, this message translates to:
  /// **'Avoid duplicate reports; check existing submissions.'**
  String get guideline2;

  /// No description provided for @guideline3.
  ///
  /// In en, this message translates to:
  /// **'Submit issues that benefit the public (e.g., infrastructure, safety).'**
  String get guideline3;

  /// No description provided for @guideline4.
  ///
  /// In en, this message translates to:
  /// **'Attach clear evidence (photos, documents) if available.'**
  String get guideline4;

  /// No description provided for @submitReportButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReportButton;

  /// No description provided for @submittingLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submittingLabel;

  /// No description provided for @reportSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully!'**
  String get reportSubmittedMessage;

  /// No description provided for @bookingPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Community Space'**
  String get bookingPageTitle;

  /// No description provided for @bookingHeader.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingHeader;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullNameLabel;

  /// No description provided for @phoneBookingLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get phoneBookingLabel;

  /// No description provided for @emailBookingLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address (Optional)'**
  String get emailBookingLabel;

  /// No description provided for @spaceDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'Space Name / District *'**
  String get spaceDistrictLabel;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date *'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @startTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time *'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End Time *'**
  String get endTimeLabel;

  /// No description provided for @activitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Activities Planned *'**
  String get activitiesLabel;

  /// No description provided for @submitBookingButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Booking Request'**
  String get submitBookingButton;

  /// No description provided for @bookingTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Terms'**
  String get bookingTermsTitle;

  /// No description provided for @bookingTerm1.
  ///
  /// In en, this message translates to:
  /// **'Bookings are subject to availability'**
  String get bookingTerm1;

  /// No description provided for @bookingTerm2.
  ///
  /// In en, this message translates to:
  /// **'Please arrive on time for your scheduled slot'**
  String get bookingTerm2;

  /// No description provided for @bookingTerm3.
  ///
  /// In en, this message translates to:
  /// **'Cancellations must be made at least 24 hours in advance'**
  String get bookingTerm3;

  /// No description provided for @bookingTerm4.
  ///
  /// In en, this message translates to:
  /// **'Keep the space clean and follow all facility rules'**
  String get bookingTerm4;

  /// No description provided for @reportedIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reported Issues'**
  String get reportedIssuesTitle;

  /// No description provided for @noIssuesMessage.
  ///
  /// In en, this message translates to:
  /// **'No issues reported yet.'**
  String get noIssuesMessage;

  /// No description provided for @viewMapLabel.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMapLabel;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNoLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile.'**
  String get profileNoLogin;

  /// No description provided for @profileFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileFailedLoad;

  /// No description provided for @profileNoData.
  ///
  /// In en, this message translates to:
  /// **'No profile data available.'**
  String get profileNoData;

  /// No description provided for @fetchProfile.
  ///
  /// In en, this message translates to:
  /// **'Fetch Profile'**
  String get fetchProfile;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired or invalid. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get generalSection;

  /// No description provided for @activitySection.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get activitySection;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update and modify your profile'**
  String get profileSettingsSubtitle;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get privacySubtitle;

  /// No description provided for @privacyPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacyPopupTitle;

  /// No description provided for @privacyPopupMessage.
  ///
  /// In en, this message translates to:
  /// **'Password change feature coming soon!'**
  String get privacyPopupMessage;

  /// No description provided for @privacyPopupButton.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get privacyPopupButton;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @myReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage your reports'**
  String get myReportsSubtitle;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @myBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage your bookings'**
  String get myBookingsSubtitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @tapChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change profile photo'**
  String get tapChangePhoto;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @emailInput.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailInput;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @passwordInput.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordInput;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterPassword;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below.'**
  String get resetPasswordInstruction;

  /// No description provided for @resetPasswordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewPassword;

  /// No description provided for @resetPasswordConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get resetPasswordConfirmPassword;

  /// No description provided for @resetPasswordSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get resetPasswordSubmitButton;

  /// No description provided for @resetPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{message} You can now log in with your new password.'**
  String resetPasswordSuccessMessage(Object message);

  /// No description provided for @resetPasswordErrorMessageEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get resetPasswordErrorMessageEmptyPassword;

  /// No description provided for @resetPasswordErrorMessageShortPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get resetPasswordErrorMessageShortPassword;

  /// No description provided for @resetPasswordErrorMessageConfirmEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get resetPasswordErrorMessageConfirmEmpty;

  /// No description provided for @resetPasswordErrorMessageMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get resetPasswordErrorMessageMismatch;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get themeTitle;

  /// No description provided for @themeLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLightMode;

  /// No description provided for @themeDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDarkMode;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageTitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English   '**
  String get english;

  /// No description provided for @kiswahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get kiswahili;

  /// No description provided for @userTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Join OpenSpace'**
  String get userTypeTitle;

  /// No description provided for @userTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to track your reports and bookings, or continue anonymously to explore open spaces.'**
  String get userTypeDescription;

  /// No description provided for @signInRegisteredButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In as Registered User'**
  String get signInRegisteredButton;

  /// No description provided for @continueAnonymousButton.
  ///
  /// In en, this message translates to:
  /// **'Continue as Anonymous'**
  String get continueAnonymousButton;

  /// No description provided for @termsPrivacyButton.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy Policy'**
  String get termsPrivacyButton;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Report Issues'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Easily report unusual activities in open spaces to keep your community safe.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Book Spaces'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Reserve open spaces for community events or personal use with a few taps.'**
  String get onboardingDescription2;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @enterReferenceId.
  ///
  /// In en, this message translates to:
  /// **'Enter Reference ID'**
  String get enterReferenceId;

  /// No description provided for @enterReferenceIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Reference ID...'**
  String get enterReferenceIdHint;

  /// No description provided for @enterReferenceIdPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a Reference ID and click Search to view report details.'**
  String get enterReferenceIdPrompt;

  /// No description provided for @enterReferenceIdError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Reference ID'**
  String get enterReferenceIdError;

  /// Message when no report matches the entered Reference ID
  ///
  /// In en, this message translates to:
  /// **'No report found for Reference ID: {refId}'**
  String noReportFound(Object refId);

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous User'**
  String get anonymousUser;

  /// No description provided for @attachmentViewNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Attachment viewing not yet implemented'**
  String get attachmentViewNotImplemented;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments provided.'**
  String get noAttachments;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @reportId.
  ///
  /// In en, this message translates to:
  /// **'Report ID'**
  String get reportId;

  /// No description provided for @activeBookings.
  ///
  /// In en, this message translates to:
  /// **'Active Bookings'**
  String get activeBookings;

  /// No description provided for @pastBookings.
  ///
  /// In en, this message translates to:
  /// **'Past Bookings'**
  String get pastBookings;

  /// No description provided for @pendingBookings.
  ///
  /// In en, this message translates to:
  /// **'Pending Bookings'**
  String get pendingBookings;

  /// No description provided for @noBookingsMessage.
  ///
  /// In en, this message translates to:
  /// **'No bookings found.'**
  String get noBookingsMessage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your internet and try again.'**
  String get connectionTimeout;

  /// No description provided for @offlineNoCachedToken.
  ///
  /// In en, this message translates to:
  /// **'No offline login available. Please connect to the internet.'**
  String get offlineNoCachedToken;

  /// No description provided for @offlineLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged in offline'**
  String get offlineLoginSuccess;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sw': return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
