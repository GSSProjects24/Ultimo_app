import 'package:flutter/material.dart';


import '../../../reusable/color.dart';
import '../../../reusable/text_style.dart';

class TotalAmountContainer extends StatelessWidget {
  final String amount;

  TotalAmountContainer({required this.amount});

  @override
  Widget build(BuildContext context) {
    return
        Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: appPrimaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: appPrimaryColor.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Total Amount:",
                style: MyTextStyle.f22(whiteColor, weight: FontWeight.bold),
               // overflow: TextOverflow.ellipsis,
              ),
            ),
           // SizedBox(width: 10), // Adds spacing
            Expanded(
              child: Text(
                "RM$amount",
                style: MyTextStyle.f24(whiteColor, weight: FontWeight.bold),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),


        );


      // Container(
      //   width: double.infinity,
      //   padding: EdgeInsets.all(16),
      //   decoration: BoxDecoration(
      //     color: checkoutColor,
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Text("Total Amount:", style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold)),
      //       Text("$amount", style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold)),
      //     ],
      //   ),
      // );
  }
}