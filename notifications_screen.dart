import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification.dart' as app_notification;
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _showAboutUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutUsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE9A1),
      body: Stack(
        children: [
          // Blurred brown background (use a solid color for now, can add blur effect with BackdropFilter if needed)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD09B5A).withAlpha((0.7 * 255).round()),
            ),
          ),
          // Main content with rounded corners
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 16, left: 4, right: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No new notifications!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Notification placeholders
                  Expanded(
                    child: Consumer2<NotificationService, AuthService>(
                      builder: (context, notificationService, authService, _) {
                        final userId = authService.currentUser?.uid;
                        if (userId == null) {
                          return const Center(child: Text('Not logged in'));
                        }
                        return StreamBuilder<List<app_notification.AppNotification>>(
                          stream: notificationService.getUserNotifications(userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error loading notifications'));
                            }
                            final notifications = snapshot.data ?? [];
                            if (notifications.isEmpty) {
                              return const Center(child: Text('No notifications yet'));
                            }
                            return ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final n = notifications[index];
                                return ListTile(
                                  tileColor: n.isRead ? Colors.white.withAlpha((0.5 * 255).round()) : const Color(0xFFFFE9A1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: Text(
                                    n.title,
                                    style: TextStyle(
                                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    n.message,
                                    style: TextStyle(
                                      color: Colors.black.withAlpha((0.7 * 255).round()),
                                    ),
                                  ),
                                  trailing: Text(
                                    _formatTime(n.createdAt),
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                  onTap: () {
                                    notificationService.markNotificationAsRead(n.id);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  // About us button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () => _showAboutUs(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha((0.7 * 255).round()),
                          foregroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'About us',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _CustomBottomNavBar(),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFFFE9A1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, size: 32, color: Colors.black54),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, size: 32, color: Colors.black54),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.home, size: 32, color: Colors.black54),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 32, color: Colors.black54),
            onPressed: () => Navigator.pushNamed(context, '/chatList'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 32, color: Colors.black54),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: const Center(
        child: Text('This is the About Us page.'),
      ),
    );
  }
} 