// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/screens/cart_buttons.dart';
import 'package:kampusmart2/widgets/my_button1.dart';

class CartContainer extends StatelessWidget {
  final String imagePath;
  const CartContainer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        color: AppTheme.tertiaryOrange,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit
                          .contain, // or BoxFit.cover, if you want it to fill the shape
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.69,
              decoration: BoxDecoration(
                color: AppTheme.borderGrey.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      CartButtons(
                        fontColor: AppTheme.paleWhite,
                        fontSize: 12,
                        text: 'Product Name',
                        containerHeight: 25,
                        containerWidth: 50,
                        onTap: () {},
                      ),
                      const SizedBox(height: 4,),
                      CartButtons(
                        fontColor: AppTheme.paleWhite,
                        fontSize: 12,
                        text: 'Price and Discount',
                        containerHeight: 25,
                        containerWidth: 50,
                        onTap: () {},
                      ),
                      Container(
                        height: 50,
                        color: Colors.blueAccent,
                        child: Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.remove_circle),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.add_circle),
                              ),
                              MyButton1(
                                height: 30,
                                width: 50,
                                fontSize: 15,
                                text: 'rating',
                                onTap: () {},
                                pad: 5,
                              ),
                              CartButtons(
                                fontColor: AppTheme.paleWhite,
                                fontSize: 12,
                                text: 'Details',
                                containerHeight: 25,
                                containerWidth: 60, // adjust this to a reasonable value
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      )
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
