import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/imin_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';
import '../printer/report_print.dart';

class ValetParkingReportPage extends StatefulWidget {
  @override
  _ValetParkingReportPageState createState() => _ValetParkingReportPageState();
}

class _ValetParkingReportPageState extends State<ValetParkingReportPage> {
  DateTime selectedDate = DateTime.now();
  String? userProfile;
  List<Map<String, dynamic>> bookings = [];
  double totalAmount = 0.0;
  final iminPrinter = IminPrinter();
  final valetPrinter = ValetParkingPrinter();
  bool isLoading = false;
  TimeOfDay selectedStartTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();
    _getUserProfile();
    getSdkVersion();
    //  getMediaFilePermission();
    if (!mounted) return;
  }
  @override
  void dispose() {
    iminPrinter.exitPrinterBuffer(true);
    super.dispose();
  }
  Future<void> getSdkVersion() async {
    await iminPrinter.getSdkVersion(); // Version fetching, but no effect on UI
  }

  Future<void> _getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('perfs');

    if (username != null && username.isNotEmpty) {
      setState(() {
        userProfile = username;
      });
      _fetchBookings();
    }
  }

  Future<void> _fetchBookings() async {
    if (userProfile == null) return;
    setState(() {
      isLoading = true;
    });

    // Convert selectedDate with selectedStartTime and selectedEndTime
    DateTime startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );

    DateTime endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedEndTime.hour,
      selectedEndTime.minute,
    );

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userProfile', isEqualTo: userProfile)
          .where("checkIn", isGreaterThanOrEqualTo: Timestamp.fromDate(startDateTime))
          .where("checkIn", isLessThanOrEqualTo: Timestamp.fromDate(endDateTime))
          .get();

      double total = 0.0;
      List<Map<String, dynamic>> tempBookings = snapshot.docs.map((doc) {
        Timestamp? checkInTimestamp = doc['checkIn'] is Timestamp ? doc['checkIn'] : null;
        Timestamp? checkoutTimestamp = doc['checkout'] is Timestamp ? doc['checkout'] : null;

        double amount = double.tryParse(doc['amount']?.toString() ?? '0') ?? 0;
        total += amount;

        return {
          'carNumber': doc['carNumber'] ?? 'N/A',
          'keyHolder': doc['keyHolder'] ?? 'N/A',
          'jockey': doc['jockey'] ?? 'N/A',
          'amount': amount.toStringAsFixed(2),
          'checkIn': checkInTimestamp != null
              ? DateFormat('dd-MM-yyyy hh:mm a').format(checkInTimestamp.toDate())
              : 'N/A',
          'checkout': checkoutTimestamp != null
              ? DateFormat('dd-MM-yyyy hh:mm a').format(checkoutTimestamp.toDate())
              : 'Pending',
        };
      }).toList();

      setState(() {
        bookings = tempBookings;
        totalAmount = total;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  void _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? selectedStartTime : selectedEndTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          selectedStartTime = picked;
        } else {
          selectedEndTime = picked;
        }
      });
      _fetchBookings(); // Re-fetch bookings after selecting time
    }
  }

  // Future<void> _fetchBookings() async {
  //   if (userProfile == null) return;
  //   setState(() {
  //     isLoading = true;
  //   });
  //   DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  //   DateTime endOfDay = startOfDay.add(const Duration(days: 1));
  //
  //   try {
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('bookings')
  //         .where('userProfile', isEqualTo: userProfile)
  //         .where("checkIn", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
  //         .where("checkIn", isLessThan: Timestamp.fromDate(endOfDay))
  //         .get();
  //
  //     double total = 0.0;
  //     List<Map<String, dynamic>> tempBookings = snapshot.docs.map((doc) {
  //       Timestamp? checkInTimestamp = doc['checkIn'] is Timestamp ? doc['checkIn'] : null;
  //       Timestamp? checkoutTimestamp = doc['checkout'] is Timestamp ? doc['checkout'] : null;
  //
  //       double amount = double.tryParse(doc['amount']?.toString() ?? '0') ?? 0;
  //       total += amount;
  //
  //       return {
  //         'carNumber': doc['carNumber'] ?? 'N/A',
  //         'keyHolder': doc['keyHolder'] ?? 'N/A',
  //         'jockey': doc['jockey'] ?? 'N/A',
  //         'amount': amount.toStringAsFixed(2),
  //         'checkIn': checkInTimestamp != null
  //             ? DateFormat('dd-MM-yyyy hh:mm a').format(checkInTimestamp.toDate())
  //             : 'N/A',
  //         'checkout': checkoutTimestamp != null
  //             ? DateFormat('dd-MM-yyyy hh:mm a').format(checkoutTimestamp.toDate())
  //             : 'Pending',
  //       };
  //     }).toList();
  //
  //     setState(() {
  //       bookings = tempBookings;
  //       totalAmount = total;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print("Error fetching bookings: $e");
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: appPrimaryColor,
              onPrimary: whiteColor,
              surface: appSecondaryColor,
              onSurface: whiteColor,
            ),
            dialogBackgroundColor: appSecondaryColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchBookings();
    }
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    int totalCars = bookings.length;
    int pendingCount = bookings.where((booking) => booking['checkout'] == 'Pending').length;
    int completedCount = totalCars - pendingCount;

    return Scaffold(
      backgroundColor: appSecondaryColor,
      appBar: AppBar(
        backgroundColor: appSecondaryColor,
        title: Text("Report", style: MyTextStyle.f22(whiteColor)),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  style: MyTextStyle.f16(whiteColor, weight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today, size: 18, color: whiteColor),
                  label: Text("Select Date", style: MyTextStyle.f14(whiteColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                  ),
                ),
              ],
            ),
            verticalSpace(height: size.height * 0.03),
            Text(
              "Select Time ",
              style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold),
            ),
            verticalSpace(height: size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectTime(context, true),
                  icon: const Icon(Icons.access_time, size: 18, color: whiteColor),
                  label: Text("Start: ${selectedStartTime.format(context)}",
                      style: MyTextStyle.f14(whiteColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectTime(context, false),
                  icon: const Icon(Icons.access_time, size: 18, color: whiteColor),
                  label: Text("End: ${selectedEndTime.format(context)}",
                      style: MyTextStyle.f14(whiteColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                  ),
                ),
              ],
            ),

            verticalSpace(height: size.height * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard("Total Cars", totalCars.toString(), appPrimaryColor, size),
                _summaryCard("Pending", pendingCount.toString(), Colors.orange, size),
                _summaryCard("Completed", completedCount.toString(), Colors.green, size),
                _summaryCard("Total Sales", "100", Colors.green, size),
              ],
            ),
            verticalSpace(height: size.height * 0.04),
            Text(
              "Parking Records",
              style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold),
            ),

            verticalSpace(height: size.height * 0.02),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: appPrimaryColor))
                  : bookings.isEmpty
                  ? Center(
                child: Text(
                  "No records found",
                  style: MyTextStyle.f16(whiteColor),
                ),
              )
                  : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return _reportItem(bookings[index], index + 1);
                },
              ),
            ),
            Container(
              padding:  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appCardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Amount", style: MyTextStyle.f16(whiteColor, weight: FontWeight.bold)),
                  Text("RM${totalAmount.toStringAsFixed(2)}", // Use dynamic value
                      style: MyTextStyle.f18(appPrimaryColor, weight: FontWeight.bold)),
                ],
              ),
            ),
            verticalSpace(height: size.height * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async{
                  //await iminPrinter.initPrinter();
                  await valetPrinter.printAllTickets(bookings, context);

                  //Navigator.pushNamed(context, ValetParkingRoutes.printHomeRoute);
                },
                icon: const Icon(Icons.print, color: whiteColor),
                label: Text("PRINT REPORT", style: MyTextStyle.f16(whiteColor)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _summaryCard(String title, String count, Color color, Size size) {
    return Container(
      width: size.width * 0.2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appCardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: MyTextStyle.f10(whiteColor, weight: FontWeight.bold)),
          verticalSpace(height: size.height * 0.01),
          Text(count, style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold)),
        ],
      ),
    );
  }
  Widget _reportItem(Map<String, dynamic> booking, int index) {
    return Card(
      color: appSecondaryColor.withOpacity(0.8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: appPrimaryColor,
          child: Text(
            "$index",
            style: MyTextStyle.f16(whiteColor, weight: FontWeight.bold),
          ),
        ),
        title: Text("Car No: ${booking['carNumber']}", style: MyTextStyle.f16(whiteColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Key Holder: ${booking['keyHolder']}", style: MyTextStyle.f14(whiteColor)),
            Text("Jockey : ${booking['jockey']}", style: MyTextStyle.f14(whiteColor)),
            Text("Amount : RM${booking['amount']}", style: MyTextStyle.f14(whiteColor)),
            Text("Check-in: ${booking['checkIn']}", style: MyTextStyle.f14(whiteColor)),
            Text("Check-out: ${booking['checkout']}", style: MyTextStyle.f14(whiteColor)),
            SizedBox(height: 8), // Space between text and button
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () => _printBooking(booking,index), // Call print function
                icon: Icon(Icons.print, color: Colors.white),
                label: Text("Print", style: MyTextStyle.f14(whiteColor)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: whiteColor.withOpacity(0.7)),
      ),
    );
  }

  void _printBooking(Map<String, dynamic> booking, int index) async {

    await valetPrinter.printTicket(booking, index, context);

  }



}

