import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../ml/services/enhanced_product_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 3;
  String _search = '';

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'John Doe',
      'lastMessage': 'Hi, is this still available?',
      'time': '12:00 pm',
      'unread': 3,
      'avatar': null,
    },
    {
      'name': 'Jane Smith',
      'lastMessage': 'Thank you!',
      'time': '12:00 pm',
      'unread': 3,
      'avatar': null,
    },
    {
      'name': 'Alex Brown',
      'lastMessage': 'Can you ship tomorrow?',
      'time': '12:00 pm',
      'unread': 3,
      'avatar': null,
    },
    {
      'name': 'Chris Lee',
      'lastMessage': 'Order received.',
      'time': '12:00 pm',
      'unread': 3,
      'avatar': null,
    },
    {
      'name': 'Sam Green',
      'lastMessage': 'Sent payment.',
      'time': '12:00 pm',
      'unread': 3,
      'avatar': null,
    },
    {
      'name': 'Pat White',
      'lastMessage': 'Thanks!',
      'time': '12:00 pm',
      'unread': 3,
      'avatar': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color yellow = Color(0xFFFFECB3);
    const Color darkBlue = Color(0xFF183A4A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Wave header
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              children: [
                // Yellow and wave background
                Positioned.fill(
                  child: CustomPaint(painter: _DoubleWavePainter()),
                ),
                // Header content
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: (val) =>
                                        setState(() => _search = val),
                                    decoration: const InputDecoration(
                                      hintText: 'search to add more to cart',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chat list
          Positioned.fill(
            top: 180,
            bottom: 80,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              itemCount: _chats
                  .where(
                    (c) =>
                        c['name'].toLowerCase().contains(_search.toLowerCase()),
                  )
                  .length,
              itemBuilder: (context, i) {
                final filtered = _chats
                    .where(
                      (c) => c['name'].toLowerCase().contains(
                        _search.toLowerCase(),
                      ),
                    )
                    .toList();
                final chat = filtered[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 22,
                        child: chat['avatar'] == null
                            ? Icon(
                                Icons.person,
                                color: Colors.grey[500],
                                size: 28,
                              )
                            : null,
                      ),
                      title: Text(
                        chat['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        chat['lastMessage'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              chat['time'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: darkBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              chat['unread'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _selectedIndex,
      //   onTap: (index) {
      //     setState(() => _selectedIndex = index);
      //     // TODO: handle navigation
      //   },
      // ),
    );
  }
}

class _DoubleWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 🌕 Yellow wave background
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFECB3)
      ..style = PaintingStyle.fill;

    final yellowPath = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.75,
        size.width * 0.5,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.45,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(yellowPath, yellowPaint);

    // ⚪ White wave stroke
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    final whitePath = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.85,
        size.width * 0.5,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.65,
        size.width,
        size.height * 0.85,
      );

    canvas.drawPath(whitePath, whitePaint);

    // 🔵 Blue wave stroke
    final bluePaint = Paint()
      ..color = const Color(0xFF183A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final bluePath = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.85,
        size.width * 0.5,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.65,
        size.width,
        size.height * 0.85,
      );

    canvas.drawPath(bluePath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
