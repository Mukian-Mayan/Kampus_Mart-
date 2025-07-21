// lib/models/product.dart
class Product {
  final String id; // Add this field - it's required for CRUD operations
  final String name;
  final String description;
  final String ownerId;
  final String priceAndDiscount;
  final String originalPrice;
  final String condition;
  final String location;
  final double rating;
  final String imageUrl;
  final List<String>? imageUrls;
  final bool bestOffer;
  final String? category;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? stock;

  Product({
    required this.id, // Add this to constructor
    required this.name,
    required this.description,
    required this.ownerId,
    required this.priceAndDiscount,
    required this.originalPrice,
    required this.condition,
    required this.location,
    required this.rating,
    required this.imageUrl,
    this.imageUrls,
    this.bestOffer = false,
    this.category,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.stock,
  });

  // Factory constructor to create Product from Firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId, // Set the document ID as the product ID
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? data['sellerId'] ?? '', // Handle both field names
      priceAndDiscount: data['priceAndDiscount'] ?? '',
      originalPrice: data['originalPrice'] ?? '',
      condition: data['condition'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls'] as List) 
          : null,
      bestOffer: data['bestOffer'] ?? false,
      category: data['category'],
      price: (data['price'] as num?)?.toDouble(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      stock: data['stock'] as  int?,
    );
  }

  // Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'priceAndDiscount': priceAndDiscount,
      'originalPrice': originalPrice,
      'condition': condition,
      'location': location,
      'rating': rating,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'bestOffer': bestOffer,
      'category': category,
      'price': price,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'stock': stock,
    };
  }

  // Convert Product to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'sellerId': ownerId, // Add sellerId for compatibility
      'priceAndDiscount': priceAndDiscount,
      'originalPrice': originalPrice,
      'condition': condition,
      'location': location,
      'rating': rating,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'bestOffer': bestOffer,
      'category': category,
      'price': price,
      // Note: createdAt and updatedAt will be set by Firestore timestamps
    };
  }

  // Copy method for creating updated instances
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? priceAndDiscount,
    String? originalPrice,
    String? condition,
    String? location,
    double? rating,
    String? imageUrl,
    List<String>? imageUrls,
    bool? bestOffer,
    String? category,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      priceAndDiscount: priceAndDiscount ?? this.priceAndDiscount,
      originalPrice: originalPrice ?? this.originalPrice,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      bestOffer: bestOffer ?? this.bestOffer,
      category: category ?? this.category,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}