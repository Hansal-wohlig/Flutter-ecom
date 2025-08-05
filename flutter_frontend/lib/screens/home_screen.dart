import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool paymentSuccess = false;
      // Only check for query param on web
      if (kIsWeb) {
        try {
          final url = html.window.location.href;
          final uri = Uri.parse(url);
          if (uri.queryParameters['payment'] == 'success') {
            paymentSuccess = true;
          }
        } catch (_) {}
      }
      _loadData(triggerPostPayment: paymentSuccess);
    });
  }

  void _loadData({bool triggerPostPayment = false}) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    productProvider.loadProducts();
    if (authProvider.token != null) {
      cartProvider.loadCart(authProvider.token!);
      if (triggerPostPayment) {
        _handlePostPayment(authProvider.token!, cartProvider, context);
      }
    }
  }

  void _handlePostPayment(String token, CartProvider cartProvider, BuildContext context) async {
  print('[DEBUG] Post-payment handler triggered');
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    // Create order from cart (empty map will use cart on backend)
    print('[DEBUG] Attempting to place order in post-payment handler');
  bool orderSuccess = await orderProvider.createOrder(token, {});
  print('[DEBUG] Order placed: \\${orderSuccess}');
    if (orderSuccess) {
      await cartProvider.loadCart(token);
      await orderProvider.loadOrders(token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
    print('[DEBUG] Order placement failed in post-payment handler');
      await orderProvider.loadOrders(token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to E-Commerce',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Discover amazing products at great prices',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  authProvider.user?.name ?? 'User',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  authProvider.user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Featured Products Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Consumer<ProductProvider>(
                      builder: (context, productProvider, _) {
                        if (productProvider.isLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (productProvider.products.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No products available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Show first 8 products on home screen
                        final featuredProducts = productProvider.products.take(8).toList();

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width < 800 ? 2 : 4,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: featuredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: featuredProducts[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
