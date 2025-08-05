import 'dart:html' as html;

void redirectToStripeCheckout(String url) {
  html.window.open(url, '_self');
}
