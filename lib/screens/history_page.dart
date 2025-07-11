import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/cart_container.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      bottomNavigationBar: BottomNavBar(selectedIndex: 0,),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ CartContainer(imagePath: 'lib/images/laptop.jpg',)],
      ),
    );
  }
}
