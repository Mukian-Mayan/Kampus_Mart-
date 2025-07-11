import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';

class HelpAndSupportPage extends StatelessWidget {
  //static const String routeName ='/HelpAndSupportPage';
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      bottomNavigationBar: BottomNavBar(selectedIndex: 0,navBarColor: AppTheme.tertiaryOrange),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Text('HelpAndSupportPage'))],
      ),
    );
  }
}
