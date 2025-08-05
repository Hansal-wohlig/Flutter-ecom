import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/product_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/google_auth_callback_screen.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  if (!kIsWeb) {
    // Only set Stripe key on mobile
    Stripe.publishableKey = 'pk_test_51RpkOIH8cHotDVAkQfCHKpcfQeHIutyF8prpMmC24MYMo3AeGbBb5XVO20JV4a2gKaXtktOiNHmKmcrbK3f0hczQ00WPb5kb0s';
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'E-Commerce Web App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: GoogleFonts.robotoTextTheme(),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
              ),
            ),
            // The 'home' property correctly handles the initial screen decision
            home: authProvider.isAuthenticated
                ? MainScreen()
                : AuthScreen(),
            // --- THIS SECTION IS REPLACED ---
            // The 'routes' map is removed and replaced with onGenerateRoute
            onGenerateRoute: (settings) {
              // Parse the requested route, including any query parameters
              final Uri uri = Uri.parse(settings.name ?? '/');
              if (uri.path == '/' && uri.queryParameters['payment'] == 'success') {
                return MaterialPageRoute(builder: (context) => MainScreen());
              }

              // Handle routes based on the path, ignoring query parameters
              switch (uri.path) {
                case '/home':
                  return MaterialPageRoute(builder: (context) => MainScreen());
                case '/products':
                  return MaterialPageRoute(builder: (context) => ProductsScreen());
                case '/payment/success':
                  return MaterialPageRoute(builder: (context) => OrdersScreen());
                case '/cart':
                  return MaterialPageRoute(builder: (context) => CartScreen());
                case '/orders':
                  return MaterialPageRoute(builder: (context) => OrdersScreen());
                case '/profile':
                  return MaterialPageRoute(builder: (context) => ProfileScreen());
                case '/google/success':
                  return MaterialPageRoute(builder: (context) => GoogleAuthCallbackScreen());
                case '/auth':

                default:
                  return MaterialPageRoute(builder: (context) => AuthScreen());
              }
            },
          );
        },
      ),
    );
  }
}


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    ProductsScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            color: Colors.grey[100],
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.white, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'E-Commerce',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(Icons.home, 'Home', 0),
                      _buildNavItem(Icons.inventory, 'Products', 1),
                      _buildNavItem(Icons.shopping_cart, 'Cart', 2),
                      _buildNavItem(Icons.receipt, 'Orders', 3),
                      _buildNavItem(Icons.person, 'Profile', 4),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Provider.of<AuthProvider>(context, listen: false).logout();
                      if (mounted) {
                        setState(() {
                          _selectedIndex = 0;
                        });
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => AuthScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
