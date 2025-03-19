import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/imin_style.dart';

class ReportAllPrint {
  final IminPrinter iminPrinter = IminPrinter();
  final GlobalKey _globalKey = GlobalKey();

  Future<void> initPrinter() async {
    await iminPrinter.initPrinter();
  }

  Widget buildTicketWidgetForMultiple(List<Map<String, dynamic>> bookings) {

    Map<String, List<Map<String, dynamic>>> bookingsByLocation = {};

    for (var booking in bookings) {
      String location = booking['location'] ?? 'Unknown Location';
      if (!bookingsByLocation.containsKey(location)) {
        bookingsByLocation[location] = [];
      }
      bookingsByLocation[location]!.add(booking);
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/printlogo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 10),
            const Text(
              "ULTIMO PARKING & VALET SERVICE",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const Text(
              "SDN. BHD. (Malaysia)",
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 20),
            ...bookingsByLocation.entries.map((entry) {
              String location = entry.key;
              List<Map<String, dynamic>> locationBookings = entry.value;
              Map<String, int> paymentMethodCounts = {};
              for (var booking in locationBookings) {
                String paymentMethod = booking['paymentMethodName'] ?? 'Unknown';
                if (!paymentMethodCounts.containsKey(paymentMethod)) {
                  paymentMethodCounts[paymentMethod] = 0;
                }
                paymentMethodCounts[paymentMethod] = paymentMethodCounts[paymentMethod]! + 1;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Location: $location",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Car Number",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Check-in",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Check-out",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Amount",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 2),
                  ...locationBookings.map((booking) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              booking['carNumber'] ?? 'N/A',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              booking['checkIn'] ?? 'N/A',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              booking['checkout'] ?? 'Pending',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'RM${booking['amount'] ?? '0.00'}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Summary",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          mainAxisAlignment:MainAxisAlignment.end,
                          children: paymentMethodCounts.entries.map((pmEntry) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Text(
                                "${pmEntry.key}  :  ${pmEntry.value}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
      
            const Text(
              "Thank you for using our service!",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }




  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value,
            style: const TextStyle(fontSize: 23),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }


  Future<void> printAllBookingsTicket(List<Map<String, dynamic>> bookings, BuildContext context) async {
    try {
      Uint8List? imageBytes = await captureTicketAsImageForMultiple(bookings, context);

      if (imageBytes != null) {
        await iminPrinter.printSingleBitmap(
          imageBytes,
          pictureStyle: IminPictureStyle(
            alignment: IminPrintAlign.center,
            width: 384,
          ),
        );
        print("All bookings printed successfully!");
      } else {
        print("Failed to capture bookings image.");
      }
    } catch (e) {
      print("Error printing all bookings: $e");
    }
  }

  Future<Uint8List?> captureTicketAsImageForMultiple(List<Map<String, dynamic>> bookings, BuildContext context) async {
    try {
      Widget ticketWidget = buildTicketWidgetForMultiple(bookings);

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
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      overlayEntry.remove();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing all bookings image: $e");
      return null;
    }
  }

}
