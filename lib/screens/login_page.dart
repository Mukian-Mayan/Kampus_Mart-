import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/register_page.dart';
import 'package:kampusmart2/widgets/layout1.dart';
import 'package:kampusmart2/widgets/my_button1.dart';
import 'package:kampusmart2/widgets/my_square_tile.dart';
import 'package:kampusmart2/widgets/my_textfield.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController pwController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final obscureText = true;

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.tertiaryOrange,
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Kampus Mart',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 58, fontFamily: 'Keania One'),
            ),
          ),

          Layout1(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyTextField(
                    maxLength: null,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: emailController,
                    hintText: 'enter your email',
                    obscureText: false,
                  ),
                  MyTextField(
                    maxLength: 16,
                    focusedColor: AppTheme.deepOrange,
                    enabledColor: AppTheme.taleBlack,
                    controller: pwController,
                    hintText: 'enter your password',
                    obscureText: true,
                  ),

                  MyButton1(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.7,
                    fontSize: 20,
                    text: 'Login',
                    onTap: () {},
                    pad: 25,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'not a member, ',
                        style: TextStyle(
                          color: AppTheme.paleWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                        child: Text(
                          'Register Now ',
                          style: TextStyle(
                            color: AppTheme.lightGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),

                  //const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: AppTheme.deepOrange,
                          ),
                        ),

                        Text(
                          '\t or continue with \t',
                          style: TextStyle(
                            color: AppTheme.paleWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),

                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: AppTheme.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MySquareTile(
                        onTap: () {}, // NOT YET FILLED
                        imagePath: 'lib/images/Icon-google.png',
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                      MySquareTile(
                        onTap: () {}, // NOT YET FILLED
                        imagePath: 'lib/images/apple_icon.png',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
