import 'product_model.dart';

class CartItem {
  final String productId;
  final Product product;
  final int quantity;

  CartItem({
    required this.productId,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handles both cases: 'product' is a full object or just an ID
    final productField = json['product'];
    String id;
    Product prod;
    if (productField is Map<String, dynamic>) {
      id = productField['_id'] ?? '';
      prod = Product.fromJson(productField);
    } else if (productField is String) {
      id = productField;
      // Provide a dummy Product with only the ID (other fields default)
      prod = Product(
        id: id,
        name: '',
        description: '',
        stock: 0,
        category: '',
        price: 0.0,
        image: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      id = '';
      prod = Product(
        id: '',
        name: '',
        description: '',
        stock: 0,
        category: '',
        price: 0.0,
        image: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return CartItem(
      productId: id,
      product: prod,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson({bool includeFullProduct = false}) {
    // If includeFullProduct is true, send the full product object; else just the ID
    return {
      'product': includeFullProduct ? product.toJson() : productId,
      'quantity': quantity,
    };
  }
}

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}