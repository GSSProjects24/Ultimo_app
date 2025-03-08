import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/imin_style.dart';

import '../../screens/printer/print_home.dart';

class TransactionPrintPage extends StatefulWidget {
  const TransactionPrintPage({super.key});

  @override
  State<TransactionPrintPage> createState() => _TransactionPrintPageState();
}

class _TransactionPrintPageState extends State<TransactionPrintPage> {
  final iminPrinter = IminPrinter();

  @override
  void dispose() {
    iminPrinter.exitPrinterBuffer(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Print Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await printTicket1();
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
    Uint8List byte =
        await readFileBytes('images/touchNGo.jpeg');
    await iminPrinter.printSingleBitmap(byte,
        pictureStyle: IminPictureStyle(
          alignment: IminPrintAlign.center,
          width: 50,
          height: 20,
        ));
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
