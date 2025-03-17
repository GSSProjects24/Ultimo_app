import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';
import '../../Routes/route.dart';
import '../checkout/widget/booking_details.dart';
import '../printer/Bookingdetail_print.dart';

class QRScreen extends StatefulWidget {
  final BookingDetailsModel bookingDetail;
  const QRScreen({Key? key, required this.bookingDetail}) : super(key: key);
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String selectedQR = "images/qr.png";
  List<Map<String, String>> paymentMethods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPaymentMethods();

  }

  Future<void> fetchPaymentMethods() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('qrCode')
          .where('location', isEqualTo: widget.bookingDetail.location)
          .get();

      List<Map<String, String>> fetchedMethods = querySnapshot.docs.map((doc) {
        return {
          "name": doc["name"]?.toString() ?? "",
          "image": doc["image"]?.toString() ?? ""
        };
      }).toList();

      setState(() {
        paymentMethods = fetchedMethods;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching payment methods: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: appSecondaryColor,
        title: Text("Scan QR Code", style: MyTextStyle.f22(whiteColor)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Text(
                    selectedQR == "images/qr.png"
                        ? "Select Payment Method"
                        : "Please scan the QR code",
                    style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpace(height: size.height * 0.015),
                  selectedQR.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: size.height * 0.58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            selectedQR,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                    color: appPrimaryColor),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Image.asset(
                                  "images/qr.png",
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                      : verticalSpace(height: size.height * 0.1),
                  verticalSpace(height: size.height * 0.02),

                  isLoading
                      ? const CircularProgressIndicator(color: whiteColor)
                      : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: paymentMethods.map((method) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedQR =
                                method["image"] ?? "images/qr.png";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: checkoutColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(method["name"] ?? "Unknown",
                            style: MyTextStyle.f16(whiteColor)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom Button Row (Always at the Bottom)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: blackColor, // Match your page background
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        ValetParkingRoutes.homeRoute,
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appCardColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("CANCEL", style: MyTextStyle.f16(whiteColor)),
                  ),
                ),
                horizontalSpace(width: size.width * 0.05),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _printBookingdetail(widget.bookingDetail, context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        ValetParkingRoutes.homeRoute,
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("PRINT", style: MyTextStyle.f16(whiteColor)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // late final BookingDetails bookingDetail; // Ensure this is passed in constructor

  final bookingdetailtPrinter = TicketPrinter();
  void _printBookingdetail(BookingDetailsModel bookingDetail,
      BuildContext context) async {

    await bookingdetailtPrinter.printBookingTicket(bookingDetail,context);

  }
}
