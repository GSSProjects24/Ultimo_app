import 'package:flutter/material.dart';

import '../../../reusable/color.dart';
import '../../../reusable/text_style.dart';


class CarDetailsDialog extends StatelessWidget {
  final String mobileNo;
  final String parkingSlot;
  final String keyHolder;
  final String startTime;
  final String date;
  final Size size;
  const CarDetailsDialog({Key? key, required this.size, required this.mobileNo, required this.parkingSlot, required this.keyHolder, required this.startTime, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return     AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      actionsPadding: const EdgeInsets.only(bottom: 10),
      title: Column(
        children: [
          const Icon(Icons.local_parking, color: appPrimaryColor, size: 50),
          const SizedBox(height: 10),
          Text(
            "Parking Details",
            style: MyTextStyle.f16(appPrimaryColor, weight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Mobile Number:", mobileNo),
          _buildDetailRow("Parking Slot:", parkingSlot),
          _buildDetailRow("Key Holder:", keyHolder),
          _buildDetailRow("Start Time:", startTime),
          _buildDetailRow("Date:", date),
        ],
      ),

      actions: [
        Center(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: appPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: MyTextStyle.f14(Colors.white)),
          ),
        ),
      ],
    );
  }
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: MyTextStyle.f14(Colors.grey.shade700, weight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: MyTextStyle.f14(Colors.black, weight: FontWeight.w600)),
          const Divider(),
        ],
      ),
    );
  }
}
