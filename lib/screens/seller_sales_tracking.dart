import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Theme/app_theme.dart';
import '../models/sales_data.dart';
import '../services/sales_service.dart';

class SellerSalesTrackingScreen extends StatefulWidget {
  static const String routeName = '/SalesTrackingScreen';

  const SellerSalesTrackingScreen({super.key});

  @override
  State<SellerSalesTrackingScreen> createState() =>
      _SellerSalesTrackingScreenState();
}

class _SellerSalesTrackingScreenState extends State<SellerSalesTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String selectedPeriod = '3rd Trimester';
  int selectedTab = 0;
  bool isLoading = true;

  // Sales data
  List<WeeklySales> weeklySalesData = [];
  List<DailySales> dailySalesData = [];
  List<PriceData> priceData = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadSalesData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Get real sales data from SaleService
      final stats = await SaleService.getSellerDashboardStats(currentUser.uid);
      final orderStats = stats['orderStats'] ?? {};
      final recentOrders = orderStats['recentOrders'] as List<dynamic>? ?? [];

      // Convert real order data to chart data
      weeklySalesData = _generateWeeklySalesFromOrders(recentOrders);
      dailySalesData = _generateDailySalesFromOrders(recentOrders);
      priceData = _generatePriceDataFromOrders(recentOrders);

      setState(() {
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      print('Error loading sales data: $e');
      // Fall back to mock data if there's an error
      weeklySalesData = SalesService.generateWeeklySales();
      dailySalesData = SalesService.generateDailySales();
      priceData = SalesService.generatePriceData();

      setState(() {
        isLoading = false;
      });

      _animationController.forward();
    }
  }

  List<WeeklySales> _generateWeeklySalesFromOrders(List<dynamic> orders) {
    // Group orders by week and calculate totals
    Map<int, double> weeklySales = {};
    final now = DateTime.now();

    // Initialize all weeks with 0
    for (int i = 0; i < 9; i++) {
      weeklySales[i] = 0.0;
    }

    for (var order in orders) {
      try {
        final orderData = order as Map<String, dynamic>;

        // Handle both Timestamp and String formats for createdAt
        DateTime createdAt;
        final createdAtValue = orderData['createdAt'];
        if (createdAtValue is Timestamp) {
          createdAt = createdAtValue.toDate();
        } else if (createdAtValue is String) {
          createdAt = DateTime.tryParse(createdAtValue) ?? now;
        } else {
          createdAt = now;
        }

        final totalAmount =
            (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0;

        // Calculate weeks ago (0 = current week, 1 = last week, etc.)
        final daysDifference = now.difference(createdAt).inDays;
        final weeksAgo = (daysDifference / 7).floor().clamp(0, 8);

        weeklySales[weeksAgo] = weeklySales[weeksAgo]! + totalAmount;
        print(
          'Order amount: $totalAmount, Days ago: $daysDifference, Week: $weeksAgo',
        );
      } catch (e) {
        print('Error processing order for weekly sales: $e');
      }
    }

    // If no real data, add some test data to see the chart
    if (weeklySales.values.every((value) => value == 0)) {
      weeklySales[0] = 280000; // Current week
      weeklySales[1] = 150000; // Last week
      weeklySales[2] = 200000; // 2 weeks ago
      weeklySales[4] = 100000; // 4 weeks ago
    }

    // Convert to WeeklySales objects (reverse order for chart display)
    List<WeeklySales> result = [];
    for (int i = 8; i >= 0; i--) {
      final sales = weeklySales[i] ?? 0.0;
      final weekLabel = i == 0 ? 'Now' : '${i * 4}W';
      result.add(
        WeeklySales(
          period: weekLabel,
          sales: sales,
          isHighlight: sales > 0, // Highlight weeks with actual sales
        ),
      );
    }

    print(
      'Weekly sales data: ${result.map((w) => '${w.period}: ${w.sales}').join(', ')}',
    );
    return result;
  }

  List<DailySales> _generateDailySalesFromOrders(List<dynamic> orders) {
    // Group orders by day for the last 7 days
    Map<String, double> dailySales = {};
    final now = DateTime.now();

    // Initialize last 7 days with 0 sales
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailySales[dayKey] = 0.0;
    }

    for (var order in orders) {
      try {
        final orderData = order as Map<String, dynamic>;

        // Handle both Timestamp and String formats for createdAt
        DateTime createdAt;
        final createdAtValue = orderData['createdAt'];
        if (createdAtValue is Timestamp) {
          createdAt = createdAtValue.toDate();
        } else if (createdAtValue is String) {
          createdAt = DateTime.tryParse(createdAtValue) ?? now;
        } else {
          createdAt = now;
        }

        final totalAmount =
            (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0;

        // Only include orders from the last 7 days
        if (now.difference(createdAt).inDays <= 7) {
          final dayKey =
              '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
          if (dailySales.containsKey(dayKey)) {
            dailySales[dayKey] = dailySales[dayKey]! + totalAmount;
          }
        }
      } catch (e) {
        print('Error processing order for daily sales: $e');
      }
    }

    // If no real data, add some test data to see the chart
    if (dailySales.values.every((value) => value == 0)) {
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final yesterdayKey =
          '${now.subtract(Duration(days: 1)).year}-${now.subtract(Duration(days: 1)).month.toString().padLeft(2, '0')}-${now.subtract(Duration(days: 1)).day.toString().padLeft(2, '0')}';
      final twoDaysAgoKey =
          '${now.subtract(Duration(days: 2)).year}-${now.subtract(Duration(days: 2)).month.toString().padLeft(2, '0')}-${now.subtract(Duration(days: 2)).day.toString().padLeft(2, '0')}';

      dailySales[todayKey] = 280000; // Today
      dailySales[yesterdayKey] = 150000; // Yesterday
      dailySales[twoDaysAgoKey] = 100000; // 2 days ago
    }

    // Convert to DailySales objects for the last 7 days
    List<DailySales> result = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final sales = dailySales[dayKey] ?? 0.0;
      result.add(
        DailySales(
          day: date.day,
          amount: sales,
          isHighlight: sales > 0, // Highlight days with actual sales
        ),
      );
    }

    print(
      'Daily sales data: ${result.map((d) => 'Day ${d.day}: ${d.amount}').join(', ')}',
    );
    return result;
  }

  List<PriceData> _generatePriceDataFromOrders(List<dynamic> orders) {
    // Generate price trend data based on order amounts over the last 7 days
    Map<int, List<double>> dailyAmounts = {};
    final now = DateTime.now();

    // Initialize last 7 days
    for (int i = 6; i >= 0; i--) {
      dailyAmounts[i] = [];
    }

    for (var order in orders) {
      try {
        final orderData = order as Map<String, dynamic>;

        // Handle both Timestamp and String formats for createdAt
        DateTime createdAt;
        final createdAtValue = orderData['createdAt'];
        if (createdAtValue is Timestamp) {
          createdAt = createdAtValue.toDate();
        } else if (createdAtValue is String) {
          createdAt = DateTime.tryParse(createdAtValue) ?? now;
        } else {
          createdAt = now;
        }

        final totalAmount =
            (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0;

        // Only include orders from the last 7 days
        final daysDifference = now.difference(createdAt).inDays;
        if (daysDifference <= 6 && totalAmount > 0) {
          dailyAmounts[daysDifference]?.add(totalAmount);
        }
      } catch (e) {
        print('Error processing order for price data: $e');
      }
    }

    // Calculate average prices for each day and create trend data
    List<PriceData> result = [];
    for (int i = 6; i >= 0; i--) {
      final amounts = dailyAmounts[i] ?? [];
      double avgAmount = 0.0;

      if (amounts.isNotEmpty) {
        avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;
      }

      result.add(
        PriceData(
          x: (6 - i).toDouble(), // 0 to 6 for x-axis
          y: avgAmount, // Keep in UGX, don't scale down
        ),
      );
    }

    // If no data, create sample UGX data
    if (result.every((data) => data.y == 0)) {
      result = [
        PriceData(x: 0, y: 50000), // UGX 50,000
        PriceData(x: 1, y: 80000), // UGX 80,000
        PriceData(x: 2, y: 45000), // UGX 45,000
        PriceData(x: 3, y: 120000), // UGX 120,000
        PriceData(x: 4, y: 90000), // UGX 90,000
        PriceData(x: 5, y: 150000), // UGX 150,000
        PriceData(x: 6, y: 280000), // UGX 280,000
      ];
    }

    print(
      'Price data: ${result.map((p) => 'Day ${p.x}: UGX ${p.y}').join(', ')}',
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6A8), // Warm yellow background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6A8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            //const LogoWidget(),
            const SizedBox(width: 8),
            const Text(
              'Sales Analytics',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: _loadSalesData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryOrange,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Detecting Sales Data...',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedPeriod,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: AppTheme.selectedBlue,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Weekly Sales Chart
                    _buildWeeklySalesChart(),
                    const SizedBox(height: 30),

                    // Trends Section
                    _buildTrendsSection(),
                    const SizedBox(height: 30),

                    // Daily Sales Chart
                    _buildDailySalesChart(),
                    const SizedBox(height: 20),

                    // Sales Summary Cards
                    _buildSalesSummaryCards(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWeeklySalesChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1000000, // Set to 1M UGX to accommodate the data
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppTheme.selectedBlue,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${weeklySalesData[groupIndex].period}\n${rod.toY.round()} sales',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < weeklySalesData.length) {
                            return Text(
                              weeklySalesData[value.toInt()].period,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklySalesData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.sales,
                          color: entry.value.isHighlight
                              ? AppTheme.selectedBlue
                              : Colors.white.withOpacity(0.7),
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Price',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                maxY: 300000, // UGX 300K max
                minY: 0,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        if (value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0');
                        if (value % 50000 == 0) {
                          int displayValue = (value / 1000).round();
                          return Text(
                            '${displayValue}K',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: priceData
                        .map((data) => FlSpot(data.x, data.y))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.selectedBlue,
                    barWidth: 4,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.selectedBlue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.selectedBlue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySalesChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'sales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 500000, // Set to 1M UGX to accommodate the data
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppTheme.selectedBlue,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Day ${dailySalesData[groupIndex].day}\nUGX ${rod.toY.round()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dailySalesData.length) {
                            return Text(
                              dailySalesData[value.toInt()].day.toString(),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('0');
                          if (value % 50000 == 0) {
                            int displayValue = (value / 1000).round();
                            return Text(
                              '${displayValue}K',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: dailySalesData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.amount,
                          color: entry.value.isHighlight
                              ? AppTheme.selectedBlue
                              : Colors.white.withOpacity(0.6),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Sales',
            'UGX ${_calculateTotalSales()}',
            Icons.trending_up,
            AppTheme.lightGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Best Day',
            'Day ${_getBestSalesDay()}',
            Icons.star,
            AppTheme.primaryOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Growth',
            '${_calculateGrowth()}%',
            Icons.arrow_upward,
            AppTheme.selectedBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  String _calculateTotalSales() {
    double total = dailySalesData.fold(0, (sum, data) => sum + data.amount);
    return (total / 1000).toStringAsFixed(0) + 'K';
  }

  int _getBestSalesDay() {
    if (dailySalesData.isEmpty) return 0;
    return dailySalesData.reduce((a, b) => a.amount > b.amount ? a : b).day;
  }

  String _calculateGrowth() {
    if (dailySalesData.length < 2) return '0';
    double lastWeek = dailySalesData
        .take(3)
        .fold(0, (sum, data) => sum + data.amount);
    double thisWeek = dailySalesData
        .skip(3)
        .fold(0, (sum, data) => sum + data.amount);
    if (lastWeek == 0) return '0';
    double growth = ((thisWeek - lastWeek) / lastWeek) * 100;
    return growth.toStringAsFixed(1);
  }
}
