class Product {
  final String? id;
  final String name;
  final String description;
  final String ownerId;
  final String priceAndDiscount;
  final double rating;
  final String imageUrl;
  final List<String>? imageUrls;
  final String originalPrice;
  final String condition;
  final String location;
  final bool bestOffer;
  final String? category;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
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
  });

  // Factory constructor to create Product from Firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['sellerId'] ?? data['ownerId'] ?? '',
      priceAndDiscount: data['priceAndDiscount'] ?? '',
      originalPrice: data['originalPrice'] ?? '',
      condition: data['condition'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls']) 
          : null,
      bestOffer: data['bestOffer'] ?? false,
      category: data['category'],
      price: data['price']?.toDouble(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert Product to Map for Firestore
  Map<String, dynamic> toFirestore() {
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
    };
  }

  // Create a copy of Product with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? priceAndDiscount,
    double? rating,
    String? imageUrl,
    List<String>? imageUrls,
    String? originalPrice,
    String? condition,
    String? location,
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