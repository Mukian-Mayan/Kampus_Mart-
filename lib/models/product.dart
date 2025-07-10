class Product {
  final String name;
  final String description;
  final String ownerId;
  final String priceAndDiscount;
  final double rating;
  final String imageUrl;
  final bool bestOffer;

  Product({
    required this.name,
    required this.description,
    required this.ownerId,
    required this.priceAndDiscount,
    required this.rating,
    required this.imageUrl,
    this.bestOffer = false,
  });
} 