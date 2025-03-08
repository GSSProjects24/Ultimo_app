import 'package:flutter/material.dart';

import '../../../Routes/route.dart';
import '../../../reusable/color.dart';
import '../../../reusable/space.dart';
import '../../../reusable/text_style.dart';

class BookingSuccessDialog extends StatelessWidget {
  final Size size;
  const BookingSuccessDialog({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog( // Use AlertDialog to properly display it in an alert box
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: appPrimaryColor, size: 80),
          verticalSpace(height: size.height * 0.03),
          Text(
            "Booking Successful!",
            style: MyTextStyle.f20(blackColor, weight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          verticalSpace(height: size.height * 0.05),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                ValetParkingRoutes.homeRoute,
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text("OK", style: MyTextStyle.f16(whiteColor)),
          ),
        ],
      ),
    );
  }
}
