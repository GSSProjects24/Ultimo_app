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
  final GlobalKey _globalKey = GlobalKey();

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

  Future<Uint8List?> captureTicketAsImage(
      Map<String, dynamic> booking, int index, BuildContext context) async {
    try {
      Widget ticketWidget = buildTicketWidget(booking, index);
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


      Overlay.of(context).insert(overlayEntry);
      await Future.delayed(const Duration(milliseconds: 500));
      RenderRepaintBoundary? boundary =
      _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print("Error: Boundary is null");
        overlayEntry.remove();
        return null;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      overlayEntry.remove();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing ticket image: $e");
      return null;
    }
  }


  Widget buildTicketWidget(Map<String, dynamic> booking, int index) {
    return Container(
        padding: const EdgeInsets.all(10),
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
            const SizedBox(height: 10),
            const Text("ULTIMO PARKING & VALET SERVICE",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            const Text("SDN. BHD. (Malaysia)", style: TextStyle(fontSize: 25)),

            // Ticket Details in Row with spaceBetween
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Ticket No:", style: TextStyle(fontSize: 23)),
                      Text("$index", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Car Number:", style: TextStyle(fontSize: 23)),
                      Text("${booking['carNumber'] ?? 'N/A'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Key Holder:", style: TextStyle(fontSize: 23)),
                      Text("${booking['keyHolder'] ?? 'N/A'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Location:", style: TextStyle(fontSize: 23)),
                      Text("${booking['location'] ?? 'N/A'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jockey:", style: TextStyle(fontSize: 23)),
                      Text("${booking['jockey'] ?? 'N/A'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amount:", style: TextStyle(fontSize: 23)),
                      Text("RM${booking['amount'] ?? '0.00'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Check-in:", style: TextStyle(fontSize: 23)),
                      Text("${booking['checkIn'] ?? 'N/A'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Check-out:", style: TextStyle(fontSize: 23)),
                      Text("${booking['checkout'] ?? 'Pending'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Payment Method:", style: TextStyle(fontSize: 23)),
                      Text("${booking['paymentMethodName'] ?? 'N/A'}", style: const TextStyle(fontSize: 23)),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Thank you for using our service!", style: TextStyle(fontSize: 20)),

                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("   ", style: TextStyle(fontSize: 20)),

                    ],
                  ),const SizedBox(height: 10,),
                ],
              ),
            ),




          ],
        )
    );
  }

}
