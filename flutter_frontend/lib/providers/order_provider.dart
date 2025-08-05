import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadOrders(String token) async {
    _setLoading(true);
    
    try {
      final response = await ApiService.getOrders(token);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _orders = data.map((json) => Order.fromJson(json)).toList();
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      print('Orders loaded: ${_orders.length}');
  notifyListeners();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }

  Future<bool> createOrder(String token, Map<String, dynamic> orderData) async {
  print('[DEBUG] OrderProvider.createOrder called with token: \\${token.substring(0, 8)}... and orderData: \\${orderData}');
    try {
      print('[DEBUG] Calling ApiService.createOrder...');
    final response = await ApiService.createOrder(token, orderData);
    print('[DEBUG] ApiService.createOrder response: status=\\${response.statusCode}, body=\\${response.body}');
      
      if (response.statusCode == 201) {
        await loadOrders(token);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
}