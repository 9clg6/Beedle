/// Catalogue centralisé d'events analytics.
///
/// À ajouter ici pour toute nouvelle instrumentation (anti-freestyle naming).
abstract final class AnalyticsEvent {
  // Navigation / UI
  static const String screenViewed = 'screen_view';
  static const String buttonTapped = 'button_tap';

  // API calls (Dio interceptor)
  static const String apiCall = 'api_call';
  static const String apiError = 'api_error';

  // Onboarding
  static const String onboardingStepViewed = 'onboarding_step_viewed';
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  static const String onboardingStepBack = 'onboarding_step_back';
  static const String onboardingSkipped = 'onboarding_skipped';
  static const String onboardingCompleted = 'onboarding_completed';

  // Permissions
  static const String permissionPrimerShown = 'permission_primer_shown';
  static const String permissionGranted = 'permission_granted';
  static const String permissionDenied = 'permission_denied';

  // Capture
  static const String captureStarted = 'capture_started';
  static const String capturedViaImport = 'captured_via_import';
  static const String capturedViaShare = 'captured_via_share';
  static const String capturedViaAutoAndroid = 'captured_via_auto_android';
  static const String captureFailed = 'capture_failed';

  // Ingestion
  static const String cardGenerated = 'card_generated';
  static const String cardGenerationFailed = 'card_generation_failed';

  // Consommation
  static const String cardOpened = 'card_opened';
  static const String cardActionTapped = 'card_action_tapped';
  static const String cardMarkedTested = 'card_marked_tested';
  static const String cardDeleted = 'card_deleted';
  static const String searchRun = 'search_run';

  // Notifications
  static const String notificationScheduled = 'notification_scheduled';
  static const String notificationTapped = 'notification_tapped';

  // Paywall
  static const String paywallShown = 'paywall_shown';
  static const String paywallDismissed = 'paywall_dismissed';
  static const String paywallPlanSelected = 'paywall_plan_selected';
  static const String trialStarted = 'trial_started';
  static const String subscribed = 'subscribed';
  static const String subscriptionRestored = 'subscription_restored';
  static const String subscriptionFailed = 'subscription_failed';
  static const String freemiumCapReached = 'freemium_cap_reached';

  // Auth
  static const String authScreenViewed = 'auth_screen_viewed';
  static const String authSigninStarted = 'auth_signin_started';
  static const String authSigninSucceeded = 'auth_signin_succeeded';
  static const String authSigninFailed = 'auth_signin_failed';
  static const String authSigninSkipped = 'auth_signin_skipped';
  static const String authSignout = 'auth_signout';
}

/// Contrat de l'analytics service (impl via Firebase Analytics dans la couche data).
abstract interface class AnalyticsService {
  Future<void> init();

  Future<void> setConsent(bool consent);

  Future<void> identify({required Map<String, Object> properties});

  Future<void> track(String event, {Map<String, Object>? properties});

  Future<void> reset();
}
