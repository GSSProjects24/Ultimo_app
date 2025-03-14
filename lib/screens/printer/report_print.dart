import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/imin_style.dart';

class ValetParkingPrinter {
  final IminPrinter iminPrinter = IminPrinter();
  final GlobalKey _globalKey = GlobalKey(); // Key for capturing the ticket UI

  Future<void> initPrinter() async {
    await iminPrinter.initPrinter();
  }

  Future<void> printTicket(Map<String, dynamic> booking, int index, BuildContext context) async {
    try {
      Uint8List? imageBytes = await captureTicketAsImage(booking, index, context);

      if (imageBytes != null) {
        await iminPrinter.printSingleBitmap(
          imageBytes,
          pictureStyle: IminPictureStyle(
            alignment: IminPrintAlign.center,
            width: 384, // Adjust width for better visibility (max width for 80mm printer)
          ),
        );
        print("Ticket printed successfully!");
      } else {
        print("Failed to capture ticket image.");
      }
    } catch (e) {
      print("Error printing ticket: $e");
    }
  }

  // Captures the ticket UI as an image
  Future<Uint8List?> captureTicketAsImage(
      Map<String, dynamic> booking, int index, BuildContext context) async {
    try {
      // Create a new widget with the ticket UI
      Widget ticketWidget = buildTicketWidget(booking, index);

      // Create an overlay to render the widget
      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Material(
          color: Colors.transparent,
          child: Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: ticketWidget,
            ),
          ),
        ),
      );

      // Insert overlay
      Overlay.of(context)?.insert(overlayEntry);

      // Wait for the UI to build
      await Future.delayed(Duration(milliseconds: 500));

      // Capture image
      RenderRepaintBoundary? boundary =
      _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print("Error: Boundary is null");
        overlayEntry.remove();
        return null;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // High-quality image
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      overlayEntry.remove(); // Remove overlay after capture
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing ticket image: $e");
      return null;
    }
  }

  // Ticket UI Widget
  Widget buildTicketWidget(Map<String, dynamic> booking, int index) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white, // Important for clear printing
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'images/printlogo.png', // Make sure the image is in your assets folder
            width: 200, // Adjust size as needed
            height: 200,
          ),
          SizedBox(height: 10),
          Text("ULTIMO PARKING & VALET SERVICE",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          Text("SDN. BHD. (Malaysia)", style: TextStyle(fontSize: 25)),

          // Ticket Details in Row with spaceBetween
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ticket No:", style: TextStyle(fontSize: 23)),
                    Text("$index", style: TextStyle(fontSize: 23)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Car Number:", style: TextStyle(fontSize: 23)),
                    Text("${booking['carNumber'] ?? 'N/A'}", style: TextStyle(fontSize: 23)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Key Holder:", style: TextStyle(fontSize: 23)),
                    Text("${booking['keyHolder'] ?? 'N/A'}", style: TextStyle(fontSize: 23)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Jockey:", style: TextStyle(fontSize: 23)),
                    Text("${booking['jockey'] ?? 'N/A'}", style: TextStyle(fontSize: 23)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Amount:", style: TextStyle(fontSize: 23)),
                    Text("RM${booking['amount'] ?? '0.00'}", style: TextStyle(fontSize: 23)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Check-in:", style: TextStyle(fontSize: 23)),
                    Text("${booking['checkIn'] ?? 'N/A'}", style: TextStyle(fontSize: 23)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Check-out:", style: TextStyle(fontSize: 23)),
                    Text("${booking['checkout'] ?? 'Pending'}", style: TextStyle(fontSize: 23)),
                  ],
                ),   SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Thank you for using our service!", style: TextStyle(fontSize: 20)),

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("   ", style: TextStyle(fontSize: 20)),

                  ],
                ),SizedBox(height: 10,),
              ],
            ),
          ),




        ],
      )
    );
  }

  Future<void> printAllTickets(List<Map<String, dynamic>> bookings, BuildContext context) async {
    for (int i = 0; i < bookings.length; i++) {
      await printTicket(bookings[i], i + 1, context);
    }
  }
}
