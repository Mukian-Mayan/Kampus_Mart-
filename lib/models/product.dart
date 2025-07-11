class Product {
  final String name;
  final String description;
  final String ownerId;
  final String priceAndDiscount;
  final double rating;
  final String imageUrl;
  final String originalPrice;
  final String condition;
  final String location;
  final bool bestOffer;

  Product({
    required this.name,
    required this.description,
    required this.ownerId,
    required this.priceAndDiscount,
    required this.originalPrice,
    required this.condition,
    required this.location,
    required this.rating,
    required this.imageUrl,
    this.bestOffer = false,
  });
} 