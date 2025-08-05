import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _loadFromStorage();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    
    if (_token != null && userJson != null) {
      try {
        _user = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      } catch (e) {
        // Clear invalid data
        await _clearStorage();
      }
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null && _user != null) {
      await prefs.setString('token', _token!);
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    }
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
    _user = null;
    notifyListeners();
  }

  // --- NEW METHOD FOR GOOGLE OAUTH ---
  // This method is called after the server redirects back to the app.
  // It uses the token from the URL to fetch the user profile and complete the login.
  Future<bool> handleGoogleSignIn(String token) async {
    _setLoading(true);
    _token = token;

    try {
      // Use the token to fetch the user profile from our backend
      final response = await ApiService.getUserProfile(_token!);
      print('--- Profile Fetch ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data); // Create user from profile data

        await _saveToStorage();
        _setLoading(false);
        return true;
      } else {
        // If getting the profile fails, the token is invalid. Clear it.
        await _clearStorage();
        _setLoading(false);
        return false;
      }
    } catch (e) {
      await _clearStorage();
      _setLoading(false);
      return false;
    }
  }
  // --- END OF NEW METHOD ---


  // --- EXISTING FUNCTIONALITY (UNCHANGED) ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    
    try {
      final response = await ApiService.login(email, password);
      print(response.body);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = User.fromJson(data);
        
        await _saveToStorage();
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    
    try {
      final response = await ApiService.register(name, email, password);
      print(response.body);
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = User.fromJson(data);
        
        await _saveToStorage();
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _clearStorage();
  }

  Future<void> loadUserProfile() async {
    if (_token == null) return;
    
    try {
      final response = await ApiService.getUserProfile(_token!);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        await _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }
}