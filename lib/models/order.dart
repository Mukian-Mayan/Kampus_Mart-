// models/order_model.dart
enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  delivered,
  cancelled, completedOrders, completed, processing,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class Order {
  final String id;
  final String buyerId;
  final String name;
  final String email;
  final String phone;
  final String sellerId;
  final String sellerName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final DeliveryAddress deliveryAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.buyerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.deliveryAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.deliveredAt,
    this.cancellationReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': buyerId,
      'customerName': name,
      'customerEmail': email,
      'customerPhone': phone,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress.toJson(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      buyerId: json['buyerId'],
      name: json['customerName'],
      email: json['customerEmail'],
      phone: json['customerPhone'],
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'],
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      acceptedAt: json['acceptedAt'] != null 
          ? DateTime.parse(json['acceptedAt']) 
          : null,
      deliveredAt: json['deliveredAt'] != null 
          ? DateTime.parse(json['deliveredAt']) 
          : null,
      cancellationReason: json['cancellationReason'],
    );
  }

  Order copyWith({
    String? id,
    String? buyerId,
    String? name,
    String? email,
    String? phone,
    String? sellerId,
    String? sellerName,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    DeliveryAddress? deliveryAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? deliveredAt,
    String? cancellationReason,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double subtotal;
  final String? notes;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'notes': notes,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }
}

class DeliveryAddress {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? landmark;

  DeliveryAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.landmark,
  });

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      landmark: json['landmark'],
    );
  }

  String get fullAddress => '$street, $city, $state $postalCode, $country';
}