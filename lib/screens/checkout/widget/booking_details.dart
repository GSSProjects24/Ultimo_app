import 'package:flutter/material.dart';
import 'package:imin_printer_example/screens/checkout/widget/total_amount_container.dart';

import 'detail_row.dart';
class BookingDetails extends StatelessWidget {
  final String carNumber;
  final String mobileNumber;
  final String parkingSlot;
  final String keyHolder;
  final String bookingDate;
  final String checkoutDate;
  final String amount;
  final String totalAmount;
  final String location;

  BookingDetails({
    required this.carNumber,
    required this.mobileNumber,
    required this.parkingSlot,
    required this.keyHolder,
    required this.bookingDate,
    required this.checkoutDate,
    required this.amount, required this.totalAmount, required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(icon: Icons.directions_car, title: "Car Number:", value: carNumber),
          DetailRow(icon: Icons.phone, title: "Mobile Number:", value: mobileNumber),
          DetailRow(icon: Icons.local_parking, title: "Parking Slot:", value: "Bay $parkingSlot"),
          DetailRow(icon: Icons.vpn_key, title: "Key Holder:", value: keyHolder),
          DetailRow(icon: Icons.location_on, title: "Location:", value: location),
          DetailRow(icon: Icons.date_range, title: "Booking Date:", value: bookingDate),
          DetailRow(icon: Icons.calendar_today, title: "Checkout Date:", value: checkoutDate),
          DetailRow(icon: Icons.savings, title: "Amount:", value: amount),
          const Divider(color: Colors.white38, thickness: 1, height: 20),
          TotalAmountContainer(amount: totalAmount),
        ],
      ),
    );
  }
}