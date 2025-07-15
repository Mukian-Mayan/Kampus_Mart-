// Sales Service for Kmart E-commerce App

// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_base_service.dart';
import '../models/models.dart';

class SalesService extends FirebaseService {
  static const String _collection = 'sales';

  // Record a sale
  static Future<String> recordSale({
    required String orderId,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    double commissionRate = 0.1, // 10% commission
  }) async {
    try {
      if (!FirebaseService.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final saleId = FirebaseService.uuid.v4();
      final now = DateTime.now();
      final commission = totalAmount * commissionRate;
      final profit = totalAmount - commission;

      final saleRecord = SaleRecord(
        id: saleId,
        sellerId: FirebaseService.currentUserId!,
        orderId: orderId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        commission: commission,
        profit: profit,
        saleDate: now,
        period: 'daily',
        year: now.year,
        month: now.month,
        week: _getWeekOfYear(now),
        day: now.day,
      );

      await FirebaseService.firestore.collection(_collection).doc(saleId).set(saleRecord.toMap());

      return saleId;
    } catch (e) {
      throw Exception('Failed to record sale: $e');
    }
  }

  // Get sales data for analytics
  static Future<List<SaleRecord>> getSalesData({
    String? sellerId,
    String period = 'daily',
    int? year,
    int? month,
    int? week,
    int? day,
  }) async {
    try {
      final String targetSellerId = sellerId ?? FirebaseService.currentUserId!;
      
      Query query = FirebaseService.firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: targetSellerId)
          .where('period', isEqualTo: period);

      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }
      
      if (month != null) {
        query = query.where('month', isEqualTo: month);
      }
      
      if (week != null) {
        query = query.where('week', isEqualTo: week);
      }

      if (day != null) {
        query = query.where('day', isEqualTo: day);
      }

      final querySnapshot = await query
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SaleRecord.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sales data: $e');
    }
  }

  // Get sales by date range
  static Future<List<SaleRecord>> getSalesByDateRange({
    String? sellerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String targetSellerId = sellerId ?? FirebaseService.currentUserId!;
      
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: targetSellerId)
          .where('saleDate', isGreaterThanOrEqualTo: startDate)
          .where('saleDate', isLessThanOrEqualTo: endDate)
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SaleRecord.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sales by date range: $e');
    }
  }

  // Get sales analytics
  static Future<Map<String, dynamic>> getSalesAnalytics({String? sellerId}) async {
    try {
      final String targetSellerId = sellerId ?? FirebaseService.currentUserId!;
      final now = DateTime.now();
      
      // Get current month sales
      final monthlySales = await getSalesData(
        sellerId: targetSellerId,
        period: 'daily',
        year: now.year,
        month: now.month,
      );

      // Get current week sales
      final weeklySales = await getSalesData(
        sellerId: targetSellerId,
        period: 'daily',
        year: now.year,
        week: _getWeekOfYear(now),
      );

      // Get today's sales
      final todaySales = await getSalesData(
        sellerId: targetSellerId,
        period: 'daily',
        year: now.year,
        month: now.month,
        day: now.day,
      );

      // Calculate totals
      final totalSales = monthlySales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      final totalProfit = monthlySales.fold<double>(0, (sum, sale) => sum + sale.profit);
      final totalCommission = monthlySales.fold<double>(0, (sum, sale) => sum + sale.commission);
      final totalOrders = monthlySales.length;

      final weeklyTotal = weeklySales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      final todayTotal = todaySales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

      // Calculate growth
      final lastMonthSales = await getSalesData(
        sellerId: targetSellerId,
        period: 'daily',
        year: now.month == 1 ? now.year - 1 : now.year,
        month: now.month == 1 ? 12 : now.month - 1,
      );
      
      final lastMonthTotal = lastMonthSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      final growthRate = lastMonthTotal > 0 ? ((totalSales - lastMonthTotal) / lastMonthTotal) * 100 : 0;

      // Get top products
      final productSales = <String, Map<String, dynamic>>{};
      for (final sale in monthlySales) {
        if (productSales.containsKey(sale.productId)) {
          productSales[sale.productId]!['quantity'] += sale.quantity;
          productSales[sale.productId]!['revenue'] += sale.totalAmount;
        } else {
          productSales[sale.productId] = {
            'productId': sale.productId,
            'productName': sale.productName,
            'quantity': sale.quantity,
            'revenue': sale.totalAmount,
          };
        }
      }

      final topProducts = productSales.values.toList()
        ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

      return {
        'totalSales': totalSales,
        'totalProfit': totalProfit,
        'totalCommission': totalCommission,
        'totalOrders': totalOrders,
        'weeklyTotal': weeklyTotal,
        'todayTotal': todayTotal,
        'growthRate': growthRate,
        'topProducts': topProducts.take(5).toList(),
        'dailySales': monthlySales,
        'weeklySales': weeklySales,
        'todaySales': todaySales,
      };
    } catch (e) {
      throw Exception('Failed to fetch sales analytics: $e');
    }
  }

  // Get revenue trends
  static Future<List<Map<String, dynamic>>> getRevenueTrends({
    String? sellerId,
    required String period, // 'daily', 'weekly', 'monthly'
    int days = 30,
  }) async {
    try {
      final String targetSellerId = sellerId ?? FirebaseService.currentUserId!;
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final sales = await getSalesByDateRange(
        sellerId: targetSellerId,
        startDate: startDate,
        endDate: now,
      );

      final Map<String, double> trendData = {};

      for (final sale in sales) {
        String key;
        switch (period) {
          case 'daily':
            key = '${sale.saleDate.year}-${sale.saleDate.month.toString().padLeft(2, '0')}-${sale.saleDate.day.toString().padLeft(2, '0')}';
            break;
          case 'weekly':
            key = '${sale.year}-W${sale.week.toString().padLeft(2, '0')}';
            break;
          case 'monthly':
            key = '${sale.year}-${sale.month.toString().padLeft(2, '0')}';
            break;
          default:
            key = sale.saleDate.toIso8601String();
        }

        trendData[key] = (trendData[key] ?? 0) + sale.totalAmount;
      }

      return trendData.entries
          .map((entry) => {
                'period': entry.key,
                'revenue': entry.value,
              })
          .toList()
        ..sort((a, b) => (a['period'] as String).compareTo(b['period'] as String));
    } catch (e) {
      throw Exception('Failed to fetch revenue trends: $e');
    }
  }

  // Get sales by product
  static Future<List<Map<String, dynamic>>> getSalesByProduct({String? sellerId}) async {
    try {
      final String targetSellerId = sellerId ?? FirebaseService.currentUserId!;
      
      final querySnapshot = await FirebaseService.firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: targetSellerId)
          .get();

      final productSales = <String, Map<String, dynamic>>{};
      
      for (final doc in querySnapshot.docs) {
        final sale = SaleRecord.fromMap(doc.data() as Map<String, dynamic>);
        
        if (productSales.containsKey(sale.productId)) {
          productSales[sale.productId]!['totalQuantity'] += sale.quantity;
          productSales[sale.productId]!['totalRevenue'] += sale.totalAmount;
          productSales[sale.productId]!['totalProfit'] += sale.profit;
          productSales[sale.productId]!['orderCount'] += 1;
        } else {
          productSales[sale.productId] = {
            'productId': sale.productId,
            'productName': sale.productName,
            'totalQuantity': sale.quantity,
            'totalRevenue': sale.totalAmount,
            'totalProfit': sale.profit,
            'orderCount': 1,
          };
        }
      }

      return productSales.values.toList()
        ..sort((a, b) => (b['totalRevenue'] as double).compareTo(a['totalRevenue'] as double));
    } catch (e) {
      throw Exception('Failed to fetch sales by product: $e');
    }
  }

  // Helper method to get week of year
  static int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return (daysDifference / 7).ceil();
  }
}