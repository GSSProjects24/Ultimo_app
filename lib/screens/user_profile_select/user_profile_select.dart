import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:imin_printer_example/screens/checkout/widget/booking_details.dart';
import 'package:imin_printer_example/screens/printer/Bookingdetail_print.dart';
import 'package:imin_printer_example/screens/printer/acknowledgement_customer_print.dart';
import 'package:imin_printer_example/screens/printer/report_print.dart';
import 'package:imin_printer_example/screens/user_profile_select/widget/success_dialogue.dart';
import 'package:intl/intl.dart';

import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/text_style.dart';

class UserListScreen extends StatefulWidget {
  final String documentId;
  final String pageType;
  final String location;

  const UserListScreen({super.key, required this.documentId, required this.pageType, required this.location});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  int? _selectedIndex;
  List<Map<String, dynamic>> users = [];
  final acknowledgementCustomerPrinter = AcknowledgementCustomerPrinter();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: appSecondaryColor,
        title: Text("Select Your Profile", style: MyTextStyle.f22(whiteColor)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userprofile')
            .where('role', isEqualTo: 'Jockey')
            .where('location', isEqualTo: widget.location)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: appPrimaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 300,),
                  const Text(
                    "No Jockey Profiles Found",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.pageType == "primary")
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                        child: InkWell(
                          onTap: () {
                            _skipUserProfile();
                          },
                          child: Text(
                            "Skip <<<",
                            style: MyTextStyle.f16(appPrimaryColor, weight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }


          users = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isSelected ? appPrimaryColor : appCardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 42,
                                child: ClipOval(
                                  child: ImageNetwork(
                                    image: users[index]["image"] ?? "",
                                    height: 84,
                                    width: 84,
                                    curve: Curves.easeIn,
                                    fitWeb: BoxFitWeb.cover,
                                    fitAndroidIos: BoxFit.cover,
                                    onError: const Icon(Icons.person, color: blackColor, size: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                users[index]["name"] ?? "Unknown",
                                style: MyTextStyle.f18(isSelected ? blackColor : whiteColor, weight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _selectedIndex == null ? () => _showSuccessMessage(context) : _updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                      ),
                      child: Text("SUBMIT", style: MyTextStyle.f18(blackColor, weight: FontWeight.bold)),
                    ),
                    if (widget.pageType == "primary")
                      InkWell(
                        onTap: () {
                          _skipUserProfile();
                        },
                        child: Text("Skip <<<", style: MyTextStyle.f16(appPrimaryColor, weight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUserProfile() async {
    String selectedJockeyName = users[_selectedIndex!]["name"] ?? "Unknown";
    DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
        .collection("bookings")
        .doc(widget.documentId)
        .get();

    if (bookingDoc.exists) {
      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(widget.documentId)
          .update({"jockey": selectedJockeyName});
      Map<String, dynamic> bookingData = bookingDoc.data() as Map<String, dynamic>;
      BookingDetailsModel bookingDetail = BookingDetailsModel(
        carNumber: bookingData['carNumber'] ?? '',
        mobileNumber: bookingData['mobileNumber'] ?? '',
        parkingSlot: bookingData['parkingSlot'] ?? '',
        keyHolder: bookingData['keyHolder'] ?? '',
        bookingDate: bookingData['bookingDate'] ?? '',
        checkoutDate: bookingData['checkoutDate'] ?? '',
        amount: bookingData['amount'] ?? '0.0',
        totalAmount: bookingData['totalAmount'] ?? '0.0',
        location: bookingData['location'] ?? '',
        bookingTime: bookingData['bookingTime'] ?? '',
        checkOutTime: bookingData['checkOutTime'] ?? '',
        paymentMethodName: bookingData['paymentMethodName'] ?? '',
      );
      await acknowledgementCustomerPrinter.printBookingTicket(bookingDetail, context);

      if (widget.pageType == "primary") {
        _showBookingSuccessDialog(MediaQuery.of(context).size);
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No matching booking found."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _skipUserProfile() async {
    DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
        .collection("bookings")
        .doc(widget.documentId)
        .get();

    if (bookingDoc.exists) {
      Map<String, dynamic> bookingData = bookingDoc.data() as Map<String, dynamic>;
      BookingDetailsModel bookingDetail = BookingDetailsModel(
        carNumber: bookingData['carNumber'] ?? '',
        mobileNumber: bookingData['mobileNumber'] ?? '',
        parkingSlot: bookingData['parkingSlot'] ?? '',
        keyHolder: bookingData['keyHolder'] ?? '',
        bookingDate: bookingData['bookingDate'] ?? '',
        checkoutDate: bookingData['checkoutDate'] ?? '',
        amount: bookingData['amount'] ?? '0.0',
        totalAmount: bookingData['totalAmount'] ?? '0.0',
        location: bookingData['location'] ?? '',
        bookingTime: DateFormat('HH:mm a').format(bookingData['checkIn'].toDate()),
        checkOutTime: bookingData['checkOutTime'] ?? '',
        paymentMethodName: bookingData['paymentMethodName'] ?? '',
      );
      debugPrint('fff${bookingData['checkIn'] ?? ''}');
      await acknowledgementCustomerPrinter.printBookingTicket(bookingDetail, context);

      if (widget.pageType == "primary") {
        _showBookingSuccessDialog(MediaQuery.of(context).size);
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No matching booking found."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookingSuccessDialog(Size size) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingSuccessDialog(size: size),
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(" Please select your profile", style: MyTextStyle.f16(whiteColor)),
        backgroundColor: appPrimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
