import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:imin_printer_example/screens/checkout/widget/booking_details.dart';
import 'package:imin_printer_example/screens/checkout/widget/time_selection.dart';
import 'package:intl/intl.dart';

import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/text_style.dart';

class CheckoutScreen extends StatefulWidget {
  final String carNumber;
  final String mobileNumber;
  final String parkingSlot;
  final String keyHolder;
  final String bookingTime;
  final String bookingDate;
  final String checkoutTime;
  final String checkoutDate;
  final String amount;
  final String chargeBay;
  final String location;

  CheckoutScreen({
    required this.carNumber,
    required this.mobileNumber,
    required this.parkingSlot,
    required this.keyHolder,
    required this.bookingTime,
    required this.bookingDate,
    required this.checkoutTime,
    required this.checkoutDate,
    required this.amount,
    required this.chargeBay, required this.location,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? documentId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBookingDocument();
  }

  /// Fetch the correct Firestore document where carNumber matches
  Future<void> fetchBookingDocument() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('carNumber', isEqualTo: widget.carNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          documentId = querySnapshot.docs.first.id;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking not found for this car number!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching booking: $e")),
      );
    }
  }

  /// Calculate total amount
  double calculateTotalAmount() {
    double rate = double.tryParse(widget.amount) ?? 0.0;

    if (widget.chargeBay == "Hour") {
      DateTime checkIn = DateFormat('HH:mm').parse(widget.bookingTime);
      DateTime checkOut = DateFormat('HH:mm').parse(widget.checkoutTime);
      Duration difference = checkOut.difference(checkIn);
      int hours = difference.inHours + (difference.inMinutes % 60 > 0 ? 1 : 0);
      return hours * rate;
    } else if (widget.chargeBay == "Day") {
      DateTime checkInDate = DateFormat('dd-MM-yyyy').parse(widget.bookingDate);
      DateTime checkOutDate = DateFormat('dd-MM-yyyy').parse(widget.checkoutDate);
      int days = checkOutDate.difference(checkInDate).inDays + 1;
      return days * rate;
    }

    return 0.0;
  }

  /// Calculate total hours or days
  String calculateTotalHours() {
    if (widget.chargeBay == "Hour") {
      DateTime checkIn = DateFormat('HH:mm').parse(widget.bookingTime);
      DateTime checkOut = DateFormat('HH:mm').parse(widget.checkoutTime);
      Duration difference = checkOut.difference(checkIn);
      int hours = difference.inHours + (difference.inMinutes % 60 > 0 ? 1 : 0);
      return hours.toString();
    } else if (widget.chargeBay == "Day") {
      DateTime checkInDate = DateFormat('dd-MM-yyyy').parse(widget.bookingDate);
      DateTime checkOutDate = DateFormat('dd-MM-yyyy').parse(widget.checkoutDate);
      int days = checkOutDate.difference(checkInDate).inDays + 1;
      return days.toString();
    }
    return "0";
  }

  /// Update Firestore only if documentId is found
  Future<void> updateBookingDetails(BuildContext context) async {
    if (documentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No booking found to update!")),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      double totalAmount = calculateTotalAmount();
      String totalHours = calculateTotalHours();

      await FirebaseFirestore.instance.collection('bookings').doc(documentId).update({
        'checkout': Timestamp.now(),
        'totalAmount': totalAmount.toStringAsFixed(2),
        'paymentStatus': 'Success',
        'totalHours': totalHours,
      });

      ///key holder Update
      DocumentReference keyHolderDocRef = FirebaseFirestore.instance
          .collection("key_holders")
          .doc(widget.location);

      DocumentSnapshot keyHolderSnapshot = await keyHolderDocRef.get();

      if (keyHolderSnapshot.exists) {
        Map<String, dynamic> keyHolderData =
        keyHolderSnapshot.data() as Map<String, dynamic>;

        if (keyHolderData.containsKey("holders") && keyHolderData["holders"] is List) {
          List<dynamic> holdersList = keyHolderData["holders"];

          if (widget.keyHolder != "No Available Holder" && widget.keyHolder.isNotEmpty) {
            int holderIndex = holdersList.indexWhere((holder) => holder["name"] == widget.keyHolder);

            if (holderIndex != -1) {
              holdersList[holderIndex]["available"] = true;
            }
          } else {
            for (var holder in holdersList) {
              holder["available"] = false;
            }
          }
          await keyHolderDocRef.update({"holders": holdersList});
          print("Key holder availability updated successfully.");
        }
      }

      ///Slot Update
      DocumentReference slotDocRef = FirebaseFirestore.instance
          .collection("slots")
          .doc(widget.location);
      DocumentSnapshot slotSnapshot = await slotDocRef.get();

      if (slotSnapshot.exists) {
        Map<String, dynamic> slotData =
        slotSnapshot.data() as Map<String, dynamic>;

        if (slotData.containsKey("slots") && slotData["slots"] is List) {
          List<dynamic> slotList = slotData["slots"];

          if (widget.parkingSlot != "No Available Holder" && widget.parkingSlot.isNotEmpty) {
            int slotIndex = slotList.indexWhere((slot) => slot["name"] == widget.parkingSlot);

            if (slotIndex != -1) {
              slotList[slotIndex]["available"] = true;
            }
          } else {
            for (var slot in slotList) {
              slot["available"] = false;
            }
          }
          await slotDocRef.update({"slots": slotList});
          print("Slot availability updated successfully.");
        }
      }
      Navigator.pushNamed(context, ValetParkingRoutes.qrRoute);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating booking: $e")),
      );
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = calculateTotalAmount();

    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: appSecondaryColor,
        title: Text("Booking Details", style: MyTextStyle.f22(whiteColor)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.chargeBay == "Hour")
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: TimeSelection(bookingTime: widget.bookingTime, checkoutTime: widget.checkoutTime,totalHours: calculateTotalHours(),),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: BookingDetails(
                carNumber: widget.carNumber,
                mobileNumber: widget.mobileNumber,
                parkingSlot: widget.parkingSlot,
                keyHolder: widget.keyHolder,
                bookingDate: widget.bookingDate,
                checkoutDate: widget.checkoutDate,
                amount: widget.amount,
                location:widget.location,
                totalAmount: totalAmount.toStringAsFixed(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: blackColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => updateBookingDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    :Text(
                  "Proceed to Payment",
                  style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
