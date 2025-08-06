import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  static Future<http.Response> googleLogin(String idToken) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/users/google-login'),
      headers: _getHeaders(),
      body: jsonEncode({ 'token': idToken }),
    );
    return response;
  }

  static const String baseUrl = AppConfig.apiBaseUrl;
  
  static Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Auth endpoints
  static Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  static Future<http.Response> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  static Future<http.Response> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: _getHeaders(token: token),
    );
    return response;
  }

  // Product endpoints
  static Future<http.Response> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: _getHeaders(),
    );
    return response;
  }

  static Future<http.Response> getProduct(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: _getHeaders(),
    );
    return response;
  }

  // Cart endpoints
  static Future<http.Response> getCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: _getHeaders(token: token),
    );
    return response;
  }

  static Future<http.Response> addToCart(String token, String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'product': productId,
        'quantity': quantity,
      }),
    );
    return response;
  }

  static Future<http.Response> updateCartItem(String token, String productId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/update'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'product': productId,
        'quantity': quantity,
      }),
    );
    return response;
  }

  static Future<http.Response> removeFromCart(String token, String productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$productId'),
      headers: _getHeaders(token: token),
    );
    return response;
  }

  static Future<http.Response> clearCart(String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/clear'),
      headers: _getHeaders(token: token),
    );
    return response;
  }

  // Order endpoints
  static Future<http.Response> getOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/myorders'),
      headers: _getHeaders(token: token),
    );
    return response;
  }

  static Future<http.Response> createOrder(String token, Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _getHeaders(token: token),
      body: jsonEncode(orderData),
    );
    return response;
  }

  static Future<http.Response> getOrder(String token, String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: _getHeaders(token: token),
    );
    return response;
  }
}
