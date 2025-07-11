import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/about_us.dart';
import 'package:kampusmart2/screens/help_&_support_page.dart';
import 'package:kampusmart2/screens/history_page.dart';
import 'package:kampusmart2/screens/login_or_register_page.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/custom_detail_container.dart';
import 'package:kampusmart2/widgets/detail_container.dart';
import 'package:kampusmart2/widgets/layout2.dart';
import 'package:kampusmart2/widgets/profile_pic_widget.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
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
      bottomNavigationBar: BottomNavBar(selectedIndex: 4),
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
                /*DetailContainer(
                  fontColor: AppTheme.deepBlue,
                  fontSize: 20,
                  text: 'UserName',
                  containerHeight: MediaQuery.of(context).size.height * 0.065,
                  containerWidth: MediaQuery.of(context).size.width * 0.7,
                  iconData: Icons.short_text_outlined,
                  onTap: () {},
                ),*/

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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage(),),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
