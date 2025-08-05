import 'product_model.dart';

class OrderItem {
  final String productId;
  final Product product;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.product,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
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
    return OrderItem(
      productId: id,
      product: prod,
      quantity: json['quantity'] ?? 1,
    );
  }

  // Optionally include full product object in toJson
  Map<String, dynamic> toJson({bool includeFullProduct = false}) {
    return {
      'product': includeFullProduct ? product.toJson() : productId,
      'quantity': quantity,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> orderItems;
  final double totalPrice;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.orderItems,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Cash on Delivery',
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Serializes all fields, including orderItems. Optionally includes full product objects.
  Map<String, dynamic> toJson({bool includeFullProduct = false}) {
    return {
      '_id': id,
      'user': userId,
      'orderItems': orderItems.map((item) => item.toJson(includeFullProduct: includeFullProduct)).toList(),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
