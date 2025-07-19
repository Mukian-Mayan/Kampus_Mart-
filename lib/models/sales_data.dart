// ignore_for_file: avoid_types_as_parameter_names

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklySales {
  final String period;
  final double sales;
  final bool isHighlight;

  WeeklySales({
    required this.period,
    required this.sales,
    this.isHighlight = false,
  });
}

class DailySales {
  final int day;
  final double amount;
  final bool isHighlight;

  DailySales({
    required this.day,
    required this.amount,
    this.isHighlight = false,
  });
}

class PriceData {
  final double x;
  final double y;

  PriceData({required this.x, required this.y});
}

// services/sales_service.dart
class SalesService {
  static List<WeeklySales> generateWeeklySales() {
    return [
      WeeklySales(period: '0W', sales: 50, isHighlight: false),
      WeeklySales(period: '4W', sales: 100, isHighlight: false),
      WeeklySales(period: '8W', sales: 150, isHighlight: false),
      WeeklySales(period: '12W', sales: 200, isHighlight: false),
      WeeklySales(period: '16W', sales: 250, isHighlight: false),
      WeeklySales(period: '20W', sales: 280, isHighlight: false),
      WeeklySales(period: '24W', sales: 300, isHighlight: false),
      WeeklySales(period: '28W', sales: 320, isHighlight: true), // Highlighted
      WeeklySales(period: '32W', sales: 290, isHighlight: false),
    ];
  }

  static List<DailySales> generateDailySales() {
    return [
      DailySales(day: 18, amount: 200, isHighlight: false),
      DailySales(day: 19, amount: 250, isHighlight: false),
      DailySales(day: 20, amount: 180, isHighlight: false),
      DailySales(day: 21, amount: 420, isHighlight: true), // Highlighted
      DailySales(day: 22, amount: 300, isHighlight: false),
      DailySales(day: 23, amount: 150, isHighlight: false),
      DailySales(day: 24, amount: 100, isHighlight: false),
    ];
  }

  static List<PriceData> generatePriceData() {
    return [
      PriceData(x: 0, y: 20),
      PriceData(x: 1, y: 45),
      PriceData(x: 2, y: 35),
      PriceData(x: 3, y: 60),
      PriceData(x: 4, y: 40),
      PriceData(x: 5, y: 55),
      PriceData(x: 6, y: 50),
    ];
  }

  // Auto-detection methods
  static Future<Map<String, dynamic>> detectSalesChanges() async {
    // Simulate real-time sales detection
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'newSales': Random().nextInt(5) + 1,
      'revenueChange': Random().nextDouble() * 1000 + 500,
      'topProduct': 'Electronics',
      'timestamp': DateTime.now(),
    };
  }

  static Stream<Map<String, dynamic>> getSalesStream() {
    return Stream.periodic(
      const Duration(seconds: 30),
      (count) => detectSalesChanges(),
    ).asyncMap((future) => future);
  }
}

// Seller class moved to top-level
class Seller {
  final String id;
  final String name;
  final String businessName;
  final String businessDescription;
  final String number;
  final String profileImageUrl;
  final bool isVerified;
  final Map<String, dynamic> stats;
  final DateTime createdAt;
  final DateTime updatedAt;

  Seller({
    required this.id,
    required this.name,
    required this.businessName,
    required this.businessDescription,
    required this.number,
    required this.profileImageUrl,
    required this.isVerified,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create Seller from Firestore document
  factory Seller.fromFirestore(Map<String, dynamic> data) {
    return Seller(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      businessName: data['businessName'] ?? '',
      businessDescription: data['businessDescription'] ?? '',
      number: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      isVerified: data['isVerified'] ?? false,
      stats: data['stats'] ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Seller to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'phoneNumber': number,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'stats': stats,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}