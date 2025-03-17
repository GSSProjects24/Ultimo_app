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
  final String checkInTime;
  final String checkOutTime;
  final String chargeBay;

  BookingDetails({
    required this.carNumber,
    required this.mobileNumber,
    required this.parkingSlot,
    required this.keyHolder,
    required this.bookingDate,
    required this.checkoutDate,
    required this.amount, required this.totalAmount, required this.location, required this.checkInTime, required this.checkOutTime, required this.chargeBay,
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
          DetailRow(icon: Icons.local_parking, title: "Parking Bay:", value: "$parkingSlot"),
          DetailRow(icon: Icons.vpn_key, title: "Key Holder:", value: keyHolder),
          DetailRow(icon: Icons.location_on, title: "Location:", value: location),
          if(chargeBay =="Day")
          DetailRow(icon: Icons.savings, title: "Booking Time:", value: checkInTime),
          DetailRow(icon: Icons.date_range, title: "Booking Date:", value: bookingDate),
          if(chargeBay =="Day")
          DetailRow(icon: Icons.savings, title: "Checkout Time:", value: checkOutTime),
          DetailRow(icon: Icons.calendar_today, title: "Checkout Date:", value: checkoutDate),
          DetailRow(icon: Icons.savings, title: "Amount:", value: amount),
          const Divider(color: Colors.white38, thickness: 1, height: 20),
          TotalAmountContainer(amount: totalAmount),
        ],
      ),
    );
  }
}
class BookingDetailsModel {
  final String carNumber;
  final String mobileNumber;
  final String parkingSlot;
  final String keyHolder;
  final String bookingDate;
  final String checkoutDate;
  final String amount;
  final String totalAmount;
  final String location;
  final String bookingTime;
  final String checkOutTime;

  BookingDetailsModel( {
    required this.carNumber,
    required this.mobileNumber,
    required this.parkingSlot,
    required this.keyHolder,
    required this.bookingDate,
    required this.checkoutDate,
    required this.amount,
    required this.totalAmount,
    required this.location,
    required this.bookingTime,
    required this.checkOutTime,
  });

  // Convert JSON to BookingDetails
  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailsModel(
      carNumber: json['carNumber'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      parkingSlot: json['parkingSlot'] ?? '',
      keyHolder: json['keyHolder'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      checkoutDate: json['checkoutDate'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      bookingTime :json['bookingTime'] ?? '',
      checkOutTime:json['checkOutTime'] ?? '',

    );
  }

  // Convert BookingDetails to JSON
  Map<String, dynamic> toJson() {
    return {
      'carNumber': carNumber,
      'mobileNumber': mobileNumber,
      'parkingSlot': parkingSlot,
      'keyHolder': keyHolder,
      'bookingDate': bookingDate,
      'checkoutDate': checkoutDate,
      'amount': amount,
      'totalAmount': totalAmount,
      'location': location,
      'bookingTime':bookingTime,
      'checkOutTime':checkOutTime
    };
  }
}
