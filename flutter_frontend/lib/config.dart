// lib/config.dart

class AppConfig {
  /// Base URL for your API (e.g., https://your-backend.com/api)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  /// Google OAuth endpoint (e.g., https://your-backend.com/auth/google)
  static const String googleAuthUrl = String.fromEnvironment(
    'GOOGLE_AUTH_URL',
    defaultValue: 'http://localhost:5000/auth/google',
  );

  /// Stripe Checkout Session endpoint (e.g., https://your-backend.com/api/payments/create-checkout-session)
  static const String stripeCheckoutUrl = String.fromEnvironment(
    'STRIPE_CHECKOUT_URL',
    defaultValue: 'http://localhost:5000/api/payments/create-checkout-session',
  );
}