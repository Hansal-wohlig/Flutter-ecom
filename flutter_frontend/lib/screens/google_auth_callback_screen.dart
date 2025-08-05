import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class GoogleAuthCallbackScreen extends StatefulWidget {
  @override
  _GoogleAuthCallbackScreenState createState() => _GoogleAuthCallbackScreenState();
}

class _GoogleAuthCallbackScreenState extends State<GoogleAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the token processing for after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSignIn();
    });
  }

  Future<void> _handleSignIn() async {
    // Get the full URL from the browser
    final uri = Uri.base;

    // Check if the path is the one we expect and if a token exists
    if (uri.path == '/google/success' && uri.queryParameters.containsKey('token')) {
      final token = uri.queryParameters['token']!;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Use the token to sign in the user
      final success = await authProvider.handleGoogleSignIn(token);

      if (success) {
        // On success, navigate to the home screen
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // On failure, return to the authentication screen
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    } else {
        // If the URL is invalid, go back to the auth screen
        Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while processing the sign-in
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}