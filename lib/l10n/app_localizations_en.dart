// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OpenSpace';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get splashTagline => 'Connecting Communities';

  @override
  String get termsPrivacyTitle => 'Terms & Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsContent => 'Welcome to OpenSpace, a platform dedicated to enhancing community engagement through reporting issues and booking public spaces. By using OpenSpace, you agree to the following terms ...';

  @override
  String get privacyContent => 'At OpenSpace, we prioritize your privacy and adhere to Tanzania’s Personal Data Protection Act, 2022...';

  @override
  String get effectiveDate => 'Effective Date: 30 July 2025';

  @override
  String get copyrightNotice => '© 2025 OpenSpace Tanzania';

  @override
  String get acceptAndReturn => 'Accept and Return';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Please enter your credentials to sign in';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '********';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signInButton => 'Sign in';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Create account';

  @override
  String get loginSuccess => 'Successfully Logged In!';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get signUpSubtitle => 'Please enter your details to sign up';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get wardLabel => 'Select Ward';

  @override
  String get passwordConfirmLabel => 'Confirm Password';

  @override
  String get agreeTerms => 'I agree with Terms and Privacy';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get signUpSuccess => 'Registered successfully! Please sign in.';

  @override
  String get signUpErrorAgree => 'You must agree to the Terms and Privacy';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get wardRequired => 'Ward is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordConfirmRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get myProfile => 'My Profile';

  @override
  String get helpFaqs => 'Help & FAQs';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get privacyPolicyMenu => 'Privacy Policy';

  @override
  String get rateApp => 'Rate This App';

  @override
  String get about => 'About';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign Out';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get reportIssueSubtitle => 'Submit concerns about open spaces';

  @override
  String get viewReports => 'View Reports';

  @override
  String get viewReportsSubtitle => 'Check status of reported issues';

  @override
  String get bookSpace => 'Book Space';

  @override
  String get bookSpaceSubtitle => 'Reserve an open space';

  @override
  String get trackProgress => 'Track Progress';

  @override
  String get trackProgressSubtitle => 'Monitor community improvements';

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get openSpaces => 'Open Spaces';

  @override
  String get activeReports => 'Active Reports';

  @override
  String get bookings => 'Bookings';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get newReportSubmitted => 'New report submitted';

  @override
  String get spaceBooked => 'Space booked';

  @override
  String get issueResolved => 'Issue resolved';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get police => 'Police';

  @override
  String get fire => 'Fire';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get close => 'Close';

  @override
  String get heroTitle1 => 'Dar es Salaam Open Spaces';

  @override
  String get heroTitle2 => 'Community Gardens';

  @override
  String get heroTitle3 => 'Public Parks & Recreation';

  @override
  String get heroTitle4 => 'Urban Green Spaces';

  @override
  String get heroSubtitle1 => 'Building stronger communities together';

  @override
  String get heroSubtitle2 => 'Growing together as one community';

  @override
  String get heroSubtitle3 => 'Fun for families and friends';

  @override
  String get heroSubtitle4 => 'Nature in the heart of the city';

  @override
  String get mapScreenAppBar => 'Open Spaces Map';

  @override
  String get searchHint => 'Search public open space';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String get openSpaceDetails => 'Open Space Details';

  @override
  String get amenitiesLabel => 'Amenities';

  @override
  String get getDirectionsButton => 'Get Directions';

  @override
  String get bookNowButton => 'Book Now';

  @override
  String get reportButton => 'Report';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get unknownArea => 'Unknown Area';

  @override
  String get noSpaceSelected => 'No space selected for booking.';

  @override
  String get spaceNotAvailable => 'This space is currently not available for booking.';

  @override
  String get pinpointedNotPublic => 'Pinpointed area is not a Public open space';

  @override
  String get unableFetchLocation => 'Unable to fetch location.';

  @override
  String get locationError => 'Location error';

  @override
  String get directionsError => 'Unable to fetch your current location.';

  @override
  String distanceInfo(Object area, Object distance) {
    return 'Directions to $area:\nStraight-line distance: $distance km.\n(Implement a directions API for detailed navigation.)';
  }

  @override
  String get reportPageTitle => 'OpenSpace Report';

  @override
  String get reportHeader => 'Report unused or underutilized public spaces in your community';

  @override
  String get locationDetailsTitle => 'Location Details';

  @override
  String get spaceNameLabel => 'Space Name';

  @override
  String get districtLabel => 'District';

  @override
  String get coordinatesLabel => 'Coordinates';

  @override
  String get yourInfoTitle => 'Your Information';

  @override
  String get phoneLabel => 'Phone Number (Optional)';

  @override
  String get issueDescriptionTitle => 'Issue Description';

  @override
  String get issueDescriptionHint => 'Please provide a clear description of the issue you\'ve observed...';

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get attachmentsHint => 'Add photos or documents to support your report (max 5 files)';

  @override
  String get addPhotosButton => 'Add Photos';

  @override
  String get addDocumentsButton => 'Add Documents';

  @override
  String get reportGuidelinesTitle => 'Reporting Guidelines';

  @override
  String get guideline1 => 'Provide accurate details to assist government officials.';

  @override
  String get guideline2 => 'Avoid duplicate reports; check existing submissions.';

  @override
  String get guideline3 => 'Submit issues that benefit the public (e.g., infrastructure, safety).';

  @override
  String get guideline4 => 'Attach clear evidence (photos, documents) if available.';

  @override
  String get submitReportButton => 'Submit Report';

  @override
  String get submittingLabel => 'Submitting...';

  @override
  String get reportSubmittedMessage => 'Report submitted successfully!';

  @override
  String get bookingPageTitle => 'Book Community Space';

  @override
  String get bookingHeader => 'Booking Details';

  @override
  String get fullNameLabel => 'Full Name *';

  @override
  String get phoneBookingLabel => 'Phone Number *';

  @override
  String get emailBookingLabel => 'Email Address (Optional)';

  @override
  String get spaceDistrictLabel => 'Space Name / District *';

  @override
  String get startDateLabel => 'Start Date *';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get startTimeLabel => 'Start Time *';

  @override
  String get endTimeLabel => 'End Time *';

  @override
  String get activitiesLabel => 'Activities Planned *';

  @override
  String get submitBookingButton => 'Submit Booking Request';

  @override
  String get bookingTermsTitle => 'Booking Terms';

  @override
  String get bookingTerm1 => 'Bookings are subject to availability';

  @override
  String get bookingTerm2 => 'Please arrive on time for your scheduled slot';

  @override
  String get bookingTerm3 => 'Cancellations must be made at least 24 hours in advance';

  @override
  String get bookingTerm4 => 'Keep the space clean and follow all facility rules';

  @override
  String get reportedIssuesTitle => 'Reported Issues';

  @override
  String get noIssuesMessage => 'No issues reported yet.';

  @override
  String get viewMapLabel => 'View Map';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoLogin => 'Please log in to view your profile.';

  @override
  String get profileFailedLoad => 'Failed to load profile';

  @override
  String get profileNoData => 'No profile data available.';

  @override
  String get fetchProfile => 'Fetch Profile';

  @override
  String get sessionExpired => 'Session expired or invalid. Please log in again.';

  @override
  String get generalSection => 'GENERAL';

  @override
  String get activitySection => 'ACTIVITY';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get profileSettingsSubtitle => 'Update and modify your profile';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySubtitle => 'Change your password';

  @override
  String get privacyPopupTitle => 'Privacy Settings';

  @override
  String get privacyPopupMessage => 'Password change feature coming soon!';

  @override
  String get privacyPopupButton => 'Got it!';

  @override
  String get myReports => 'My Reports';

  @override
  String get myReportsSubtitle => 'View and manage your reports';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get myBookingsSubtitle => 'View and manage your bookings';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get tapChangePhoto => 'Tap to change profile photo';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get emailInput => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get passwordInput => 'Password';

  @override
  String get enterPassword => 'Enter new password';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get theme => 'Theme';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordInstruction => 'Enter your new password below.';

  @override
  String get resetPasswordNewPassword => 'New Password';

  @override
  String get resetPasswordConfirmPassword => 'Confirm New Password';

  @override
  String get resetPasswordSubmitButton => 'Set New Password';

  @override
  String resetPasswordSuccessMessage(Object message) {
    return '$message You can now log in with your new password.';
  }

  @override
  String get resetPasswordErrorMessageEmptyPassword => 'Please enter a new password';

  @override
  String get resetPasswordErrorMessageShortPassword => 'Password must be at least 8 characters long';

  @override
  String get resetPasswordErrorMessageConfirmEmpty => 'Please confirm your new password';

  @override
  String get resetPasswordErrorMessageMismatch => 'Passwords do not match';

  @override
  String get themeTitle => 'Choose Theme';

  @override
  String get themeLightMode => 'Light Mode';

  @override
  String get themeDarkMode => 'Dark Mode';

  @override
  String get languageTitle => 'Select Language';

  @override
  String get english => 'English   ';

  @override
  String get kiswahili => 'Kiswahili';

  @override
  String get userTypeTitle => 'Join OpenSpace';

  @override
  String get userTypeDescription => 'Sign in to track your reports and bookings, or continue anonymously to explore open spaces.';

  @override
  String get signInRegisteredButton => 'Sign In as Registered User';

  @override
  String get continueAnonymousButton => 'Continue as Anonymous';

  @override
  String get termsPrivacyButton => 'Terms & Privacy Policy';

  @override
  String get onboardingTitle1 => 'Report Issues';

  @override
  String get onboardingDescription1 => 'Easily report unusual activities in open spaces to keep your community safe.';

  @override
  String get onboardingTitle2 => 'Book Spaces';

  @override
  String get onboardingDescription2 => 'Reserve open spaces for community events or personal use with a few taps.';

  @override
  String get skipButton => 'Skip';

  @override
  String get backButton => 'Back';

  @override
  String get nextButton => 'Next';

  @override
  String get search => 'Search';

  @override
  String get enterReferenceId => 'Enter Reference ID';

  @override
  String get enterReferenceIdHint => 'Enter Reference ID...';

  @override
  String get enterReferenceIdPrompt => 'Enter a Reference ID and click Search to view report details.';

  @override
  String get enterReferenceIdError => 'Please enter a Reference ID';

  @override
  String noReportFound(Object refId) {
    return 'No report found for Reference ID: $refId';
  }

  @override
  String get notAvailable => 'N/A';

  @override
  String get anonymousUser => 'Anonymous User';

  @override
  String get attachmentViewNotImplemented => 'Attachment viewing not yet implemented';

  @override
  String get description => 'Description';

  @override
  String get attachments => 'Attachments';

  @override
  String get noAttachments => 'No attachments provided.';

  @override
  String get location => 'Location';

  @override
  String get reportId => 'Report ID';

  @override
  String get activeBookings => 'Active Bookings';

  @override
  String get pastBookings => 'Past Bookings';

  @override
  String get pendingBookings => 'Pending Bookings';

  @override
  String get noBookingsMessage => 'No bookings found.';

  @override
  String get status => 'Status';

  @override
  String get contact => 'Contact';

  @override
  String get purpose => 'Purpose';

  @override
  String get district => 'District';

  @override
  String get error => 'Error';

  @override
  String get okButton => 'OK';

  @override
  String get onlineMode => 'Online';

  @override
  String get offlineMode => 'Offline';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get connectionTimeout => 'Connection timed out. Please check your internet and try again.';

  @override
  String get offlineNoCachedToken => 'No offline login available. Please connect to the internet.';

  @override
  String get offlineLoginSuccess => 'Successfully logged in offline';

  @override
  String get offlineLoginHint => 'You are offline. Tap below to continue with your saved session';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get adminNotAllowed => 'Administrators are not allowed to login here.';

  @override
  String get streetLabel => 'Street';

  @override
  String get offlineBanner => 'You are offline';

  @override
  String get connectingBanner => 'Connecting...';

  @override
  String get retryButton => 'RETRY';

  @override
  String get syncSuccess => 'Success!';

  @override
  String syncReportsSubmitted(Object count) {
    return '$count reports submitted';
  }

  @override
  String syncBookingsSubmitted(Object count) {
    return '$count bookings submitted';
  }

  @override
  String syncReportNumber(Object reportId) {
    return 'Report #: $reportId';
  }

  @override
  String get errorNoInternet => 'No internet connection. Please check your network.';

  @override
  String get errorServerIssue => 'Server error. Please try again later.';

  @override
  String get errorTimeout => 'Request timed out. Network is slow, please try again.';

  @override
  String get errorAuth => 'Please sign in again to your account.';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get errorOfflineSaved => 'You are offline. Data has been saved and will be synced when connection is restored.';

  @override
  String get routeSearching => 'Finding route...';

  @override
  String get searchLocation => 'Search location';

  @override
  String get closeButton => 'CLOSE';
}
