import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  int get itemCount => _cart?.totalItems ?? 0;
  double get totalPrice => _cart?.totalPrice ?? 0.0;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadCart(String token) async {
    _setLoading(true);
    
    try {
      final response = await ApiService.getCart(token);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle empty cart (backend may return { message: 'Cart is empty', items: [] })
        if ((data is Map && data.containsKey('items') && (data['items'] as List).isEmpty) ||
            (data is Map && data.containsKey('message') && data['message'].toString().toLowerCase().contains('empty'))) {
          _cart = null;
        } else {
          _cart = Cart.fromJson(data);
        }
        notifyListeners();
      }
      print('Cart loaded: ${_cart?.totalItems} items');
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }

  Future<bool> addToCart(String token, String productId, int quantity) async {
    try {
      final response = await ApiService.addToCart(token, productId, quantity);
      
      if (response.statusCode == 200) {
        await loadCart(token);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> updateCartItem(String token, String productId, int quantity) async {
    try {
      final response = await ApiService.updateCartItem(token, productId, quantity);
      
      if (response.statusCode == 200) {
        await loadCart(token);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> removeFromCart(String token, String productId) async {
    try {
      final response = await ApiService.removeFromCart(token, productId);
      
      if (response.statusCode == 200) {
        await loadCart(token);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> clearCart(String token) async {
    try {
      final response = await ApiService.clearCart(token);
      
      if (response.statusCode == 200) {
        _cart = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  int getItemQuantity(String productId) {
    if (_cart == null) return 0;
    
    try {
      final item = _cart!.items.firstWhere((item) => item.productId == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}
