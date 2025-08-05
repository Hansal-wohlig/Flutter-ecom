import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/cart_item_card.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: uri_does_not_exist
import 'cart_screen_web_helper.dart' if (dart.library.html) 'cart_screen_web_helper.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessing=false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<CartProvider>(context, listen: false)
            .loadCart(authProvider.token!);
      }
    });
  }

  Future<void> _checkout() async {
    if(_isProcessing){
      return;
    }
    setState(() {
      _isProcessing=true;
    });
  print('[DEBUG] Checkout initiated');
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);

  print('[DEBUG] CartProvider.cart: \\${cartProvider.cart}');
  if (cartProvider.cart == null || cartProvider.cart!.items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cart is empty')),
    );
    setState(() {
      _isProcessing=false;
    });
    return;
  }

  print('[DEBUG] kIsWeb: \\${kIsWeb}');
  if (kIsWeb) {
    // --- WEB: Use Stripe Checkout Session ---
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/payments/create-checkout-session'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.token}',
      },
      body: jsonEncode({
        'items': cartProvider.cart!.items.map((item) => {
          'product': item.productId,
          'quantity': item.quantity,
        }).toList(),
        // Dynamically get the current origin for redirect
        'successUrl': (kIsWeb ? (Uri.base.origin + '/?payment=success') : 'http://localhost:3000/?payment=success'),
        'cancelUrl': (kIsWeb ? (Uri.base.origin + '/?payment=cancel') : 'http://localhost:3000/?payment=cancel'),
        'currency': 'usd',
      }),
    );
    final body = jsonDecode(response.body);
    final url = body['url'];
    if (url != null) {
      redirectToStripeCheckout(url); // uses dart:html under the hood
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start payment: ${body['error'] ?? 'Unknown error'}'), backgroundColor: Colors.red),
      );
    }
    setState(() {
      _isProcessing=false;
    });
    return;
  }

  // --- MOBILE: Use PaymentSheet ---
  final response = await http.post(
    Uri.parse('http://localhost:5000/api/payments/create-payment-intent'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authProvider.token}',
    },
    body: jsonEncode({
      'amount': (cartProvider.totalPrice * 100).toInt(), // cents
      'currency': 'usd',
    }),
  );

  final body = jsonDecode(response.body);
  final clientSecret = body['clientSecret'];

  try {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Your Store Name',
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    final orderData = {
      'orderItems': cartProvider.cart!.items.map((item) => {
        'product': item.productId,
        'quantity': item.quantity,
      }).toList(),
      'totalPrice': cartProvider.totalPrice,
      'paymentMethod': 'Card',
    };

    final orderSuccess = await orderProvider.createOrder(authProvider.token!, orderData);

    if (orderSuccess) {
      await cartProvider.loadCart(authProvider.token!);
      print('Reloaded cart after checkout');
      await orderProvider.loadOrders(authProvider.token!);
      print('[DEBUG] Order placed: \\${orderSuccess}');
    print('Reloaded orders after checkout');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
  print('[DEBUG] Exception during checkout: \\${e}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment cancelled or failed'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Shopping Cart',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, _) {
                    return Text(
                      '${cartProvider.itemCount} items',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Cart Items
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                return RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (authProvider.token != null) {
                      await cartProvider.loadCart(authProvider.token!);
                    }
                  },
                  child: cartProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : (cartProvider.cart == null || cartProvider.cart!.items.isEmpty)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Your cart is empty',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to products
                                    },
                                    child: Text('Continue Shopping'),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(24),
                                    itemCount: cartProvider.cart!.items.length,
                                    itemBuilder: (context, index) {
                                      return CartItemCard(
                                        cartItem: cartProvider.cart!.items[index],
                                      );
                                    },
                                  ),
                                ),
                                // Checkout Section
                                Container(
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            Text(
                                              '${cartProvider.itemCount} items',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: _checkout,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: Text(
                                          'Checkout',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}