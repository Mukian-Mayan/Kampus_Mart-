import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/about_us.dart';
import 'package:kampusmart2/screens/help_&_support_page.dart';
import 'package:kampusmart2/screens/history_page.dart';
import 'package:kampusmart2/screens/login_or_register_page.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar2.dart';
import 'package:kampusmart2/widgets/custom_detail_container.dart';
import 'package:kampusmart2/widgets/detail_container.dart';
import 'package:kampusmart2/widgets/layout2.dart';
import 'package:kampusmart2/widgets/profile_pic_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
   String? userRole;
  int selectedIndex = 4;

  void logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear session data
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
      (route) => false, // Remove all previous routes
    );
  }


  //link up setup 
  void _onTab(int index) {
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }
  }


  @override

    //initial link up
  void initState() {
    super.initState();
    _loadUserRole();
  }

   Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role');
    });
  }

  //till here guys
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.deepBlue,
        //leading: IconButton( icon:Icon(Icons.arrow_back_ios_new) ,onPressed: (){}, color: AppTheme.paleWhite,),
        title: Center(
          child: Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'League Spartan',
              color: AppTheme.paleWhite,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      bottomNavigationBar: (userRole == 'option2')
      ? BottomNavBar(selectedIndex: selectedIndex, navBarColor: AppTheme.tertiaryOrange)
      : (userRole == 'option1')
          ? BottomNavBar2(selectedIndex: selectedIndex, navBarColor: AppTheme.tertiaryOrange)
          : null,

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Layout2(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: ProfilePicWidget(radius: 60, height: 120, width: 120),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 15),

                CustomDetailContainer(
                  fontColor: AppTheme.deepBlue,
                  fontSize: 15,
                  initialText: 'User Name',
                  containerHeight: MediaQuery.of(context).size.height * 0.065,
                  containerWidth: MediaQuery.of(context).size.width * 0.7,
                  iconData: Icons.edit,
                ),
                CustomDetailContainer(
                  fontColor: AppTheme.deepBlue,
                  fontSize: 15,
                  initialText: 'hey there, Am using kmart and I trade smart',
                  containerHeight: MediaQuery.of(context).size.height * 0.065,
                  containerWidth: MediaQuery.of(context).size.width * 0.7,
                  iconData: Icons.edit,
                ),

                  DetailContainer(
                  fontColor: AppTheme.deepBlue,
                  fontSize: 20,
                  text: 'History',
                  containerHeight: MediaQuery.of(context).size.height * 0.065,
                  containerWidth: MediaQuery.of(context).size.width * 0.7,
                  iconData: Icons.history_sharp,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage(),),),
                ),
                  DetailContainer(
                  fontColor: AppTheme.deepBlue,
                  fontSize: 20,
                  text: 'Help & Support',
                  containerHeight: MediaQuery.of(context).size.height * 0.065,
                  containerWidth: MediaQuery.of(context).size.width * 0.7,
                  iconData: Icons.support_agent_outlined,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpAndSupportPage(),),),
                ),
                  DetailContainer(
                  fontColor: AppTheme.selectedBlue,
                  fontSize: 20,
                  text: 'About Us',
                  containerHeight: MediaQuery.of(context).size.height * 0.065,
                  containerWidth: MediaQuery.of(context).size.width * 0.7,
                  iconData: Icons.group_sharp,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage(),),),
                ),
                  DetailContainer(
                  fontColor: AppTheme.red,
                  fontSize: 20,
                  text: 'Logout',
                  containerHeight: MediaQuery.of(context).size.height * 0.065,
                  containerWidth: MediaQuery.of(context).size.width * 0.7,
                  iconData: Icons.logout_outlined,
                  onTap: logoutUser,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}