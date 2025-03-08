import 'package:flutter/material.dart';

import '../../../reusable/color.dart';
import '../../../reusable/text_style.dart';

class TimeSelection extends StatelessWidget {
  final String bookingTime;
  final String checkoutTime;
  final String totalHours;

  TimeSelection({required this.bookingTime, required this.checkoutTime, required this.totalHours});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text("Arriving", style: MyTextStyle.f16(whiteColor, weight: FontWeight.bold)),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(bookingTime, style: MyTextStyle.f14(whiteColor)),
            ),
          ],
        ),
        //TimeCard(title: "Arriving", subtitle: bookingTime),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: appPrimaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text("$totalHours hrs", style: MyTextStyle.f14(whiteColor)),
        ),
        Column(
          children: [
            Text("Leaving", style: MyTextStyle.f16(whiteColor, weight: FontWeight.bold)),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(checkoutTime, style: MyTextStyle.f14(whiteColor)),
            ),
          ],
        )
        //TimeCard(title: "Leaving", subtitle: checkoutTime),
      ],
    );
  }
}