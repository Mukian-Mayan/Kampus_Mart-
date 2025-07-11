import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/about_us_page.dart';
import 'package:kampusmart2/screens/help_&_support_page.dart';
import 'package:kampusmart2/screens/payment_transactions.dart';
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';
import 'package:kampusmart2/widgets/detail_container.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/profile_pic_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

   void logoutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25, left: 25),
          child: Text(
            'Settings',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(top: 22, left: 25),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.deepBlue),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 3,navBarColor: AppTheme.tertiaryOrange),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center( child: ProfilePicWidget(radius: 100, height: 200, width: 200),),
                  const SizedBox(height: 40),
                  Layout1(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*DetailContainer(
                            onTap: () {},
                            iconData: Icons.person,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'User name',
                            //containerHeight: MediaQuery.of(context).size.height * 0.0001,
                            //containerHeight: 20,MediaQuery.of(context).size.height * 0.065,
                            containerHeight: MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.5,
                          ),*/
              
                 
                          DetailContainer(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentTransactions())),
                            iconData: Icons.credit_card_rounded,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Payment Method',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),
                          DetailContainer(
                            onTap: () {},
                            iconData: Icons.light_mode,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'mode',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),
                          DetailContainer(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpAndSupportPage())),
                            iconData: Icons.support_agent,
                            fontColor: AppTheme.paleWhite,
                            fontSize: 20,
                            text: 'Help And Support',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),
                           DetailContainer(
                            fontColor: AppTheme.selectedBlue,
                            fontSize: 20,
                            text: 'About Us',
                            containerHeight: 40,
                            containerWidth: MediaQuery.of(context).size.width * 0.8,
                            iconData: Icons.group_sharp,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage())),
                          ),
                          DetailContainer(
                            onTap: logoutUser,
                            iconData: Icons.logout_rounded,
                            fontColor: AppTheme.red,
                            fontSize: 20,
                            text: 'Logout',
                            containerHeight:
                                MediaQuery.of(context).size.height * 0.065,
                            containerWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /*Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width/ 2 - 100,
            child: ProfilePicWidget(radius: 100, height: 200, width: 200),
          ),*/
        ],
      ),
    );
  }
}
