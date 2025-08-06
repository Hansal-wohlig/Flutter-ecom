class AppConfig {
  /// Base URL for your API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://flutter-ecom-iuo7.onrender.com/api',
  );

  /// Google OAuth endpoint
  static const String googleAuthUrl = String.fromEnvironment(
    'GOOGLE_AUTH_URL',
    defaultValue: 'https://flutter-ecom-iuo7.onrender.com/auth/google',
  );

  /// Stripe Checkout Session endpoint
  static const String stripeCheckoutUrl = String.fromEnvironment(
    'STRIPE_CHECKOUT_URL',
    defaultValue: 'https://flutter-ecom-iuo7.onrender.com/api/payments/create-checkout-session',
  );
}