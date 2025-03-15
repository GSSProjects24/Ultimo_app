import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/imin_style.dart';

import '../checkout/widget/booking_details.dart';

class TicketPrinter {
  final GlobalKey _globalKey = GlobalKey();
  final IminPrinter iminPrinter = IminPrinter();

  Future<void> initPrinter() async {
    await iminPrinter.initPrinter();

  }

  Future<void> printBookingTicket(BookingDetailsModel bookingDetailsModel,
      BuildContext context) async {
    try {
      Uint8List? imageBytes = await captureBookingTicketAsImage(
          bookingDetailsModel,context);

      if (imageBytes != null) {
        await iminPrinter.printSingleBitmap(
          imageBytes,
          pictureStyle: IminPictureStyle(
            alignment: IminPrintAlign.center,
            width: 384, // Adjust width for better visibility (max width for 80mm printer)
          ),
        );
        print("Ticket printed successfully!");
        print("try-------${bookingDetailsModel.bookingDate}");
        print("try-------${bookingDetailsModel.parkingSlot}");
      } else {
        print("Failed to capture ticket image.");
        print("else-------${bookingDetailsModel.bookingDate}");
      }
    } catch (e) {
      print("Error printing ticket: $e");
      print("catch-------${bookingDetailsModel.bookingDate}");
    }
  }

  // Captures the ticket UI as an image
  Future<Uint8List?> captureBookingTicketAsImage(BookingDetailsModel bookingDetail,
      BuildContext context) async {
    try {
      Widget ticketWidget = buildTicketWidget(bookingDetail);

      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) =>
            Material(
              color: Colors.transparent,
              child: Center(
                child: RepaintBoundary(
                  key: _globalKey,
                  child: ticketWidget,
                ),
              ),
            ),
      );

      Overlay.of(context)?.insert(overlayEntry);
      await Future.delayed(Duration(seconds: 3));

      RenderRepaintBoundary? boundary =
      _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print("Error: Boundary is null");
        overlayEntry.remove();
        return null;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png);

      overlayEntry.remove();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing ticket image: $e");
      return null;
    }
  }

  // Widget to display the ticket
  Widget buildTicketWidget(BookingDetailsModel bookingDetail) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/printlogo.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 10),
            Text("ULTIMO PARKING & VALET SERVICE",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            Text("SDN. BHD. (Malaysia)", textAlign: TextAlign.center, style: TextStyle(fontSize: 25)),
        
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
        
                  rowText("Car Number:", bookingDetail.carNumber),
                  rowText("Mobile Number:", bookingDetail.mobileNumber),
                  // rowText("Parking Slot:", bookingDetail.parkingSlot),
                  rowText("Key Holder:", bookingDetail.keyHolder),
                  rowText("Amount:", "RM${bookingDetail.amount}"),
                  rowText("Check-in:", "${bookingDetail.bookingDate}${bookingDetail.bookingTime}"),
                  rowText("Check-out:", "${bookingDetail.checkoutDate}${bookingDetail.checkOutTime}"),
                  rowText("Location:", bookingDetail.location),
                  rowText("Total Amount:", "RM${bookingDetail.totalAmount}"),
                  SizedBox(height: 10,),
                  rowTexttq("Thank you for using our service!", ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
        

          ],
        ),
      ),
    );
  }
  Widget rowTexttq(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 20)),

      ],
    );
  }
  Widget rowText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 23)),
        Text(value, style: TextStyle(fontSize: 23)),
      ],
    );
  }

  Future<void> printAllTickets(List<BookingDetailsModel> bookings,
      BuildContext context) async {
    for (int i = 0; i < bookings.length; i++) {
      await printBookingTicket(bookings[i], context);
      await Future.delayed(Duration(seconds: 10)); // Short delay between prints
    }
  }

}
