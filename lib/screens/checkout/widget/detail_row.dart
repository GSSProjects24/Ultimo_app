import 'package:flutter/material.dart';

import '../../../reusable/color.dart';
import '../../../reusable/text_style.dart';

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  DetailRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: appPrimaryColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(title, style: MyTextStyle.f16(whiteColor)),
          ),
          Text(value, style: MyTextStyle.f16(appPrimaryColor, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}