import 'package:flutter/material.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_style.dart';
import 'package:imin_printer/column_maker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
class TransactionPrintPage extends StatefulWidget {
  const TransactionPrintPage({super.key});

  @override
  State<TransactionPrintPage> createState() => _TransactionPrintPageState();
}

class _TransactionPrintPageState extends State<TransactionPrintPage> {
  final iminPrinter = IminPrinter();

  @override
  void dispose() {
    print("--1");
    iminPrinter.exitPrinterBuffer(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Printss Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
             //   await printTicket1();
              },
              child: const Text('Print Ticket 1'),
            ),
            ElevatedButton(
              onPressed: () async {
                await printTicket2();
              },
              child: const Text('Print Ticket 2'),
            ),
            ElevatedButton(
              onPressed: () async {
                await printTicket3();
              },
              child: const Text('Print Ticket 3'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> printTicket1() async {

    await iminPrinter.printSingleBitmap(
        'https://oss-sg.imin.sg/web/iMinPartner2/images/logo.png',
        pictureStyle: IminPictureStyle(
          width: 250,
          height: 50,
        )
    );
    await iminPrinter.sendRAWDataHexStr("0A");
    await iminPrinter.printAndFeedPaper(100);
    await iminPrinter.sendRAWDataHexStr("0A");
  }

  Future<void> printTicket2() async {
    await iminPrinter.printText("***** Ticket 2 *****\n");
    await iminPrinter.printText("Event: Concert Night\n");
    await iminPrinter.printText("Date: 12th March 2025\n");
    await iminPrinter.printText("Seat: VIP A12\n");
    await iminPrinter.printText("----------------------\n");
    await iminPrinter.printText("Enjoy the event!\n");
    await iminPrinter.printText("\n\n\n"); // Advances the paper
  }

  Future<void> printTicket3() async {
    await iminPrinter.printText("***** Ticket 3 *****\n");
    await iminPrinter.printText("Movie: The Matrix\n");
    await iminPrinter.printText("Time: 7:30 PM\n");
    await iminPrinter.printText("Seat: C5\n");
    await iminPrinter.printText("----------------------\n");
    await iminPrinter.printText("Enjoy your movie!\n");
    await iminPrinter.printText("\n\n\n"); // Advances the paper
  }
}



// Future<Uint8List> readFileBytes(String path) async {
//   ByteData fileData = await rootBundle.load(path);
//   Uint8List fileUnit8List = fileData.buffer
//       .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
//   return fileUnit8List;
// }

// Future<Uint8List> _getImageFromAsset(String iconPath) async {
//   return await readFileBytes(iconPath);
// }
