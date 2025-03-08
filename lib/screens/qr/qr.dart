import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';
import '../../Routes/route.dart';

class QRScreen extends StatefulWidget {
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String selectedQR = "images/qr.png"; // Default QR Code
  List<Map<String, String>> paymentMethods = []; // List to store payment data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchPaymentMethods(); // Fetch payment methods on screen load
  }

  Future<void> fetchPaymentMethods() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('qrCode').get();

      List<Map<String, String>> fetchedMethods = querySnapshot.docs.map((doc) {
        return {
          "name": doc["name"]?.toString() ?? "",  // Ensure value is a string
          "image": doc["image"]?.toString() ?? "" // Ensure value is a string
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
          const Spacer(),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
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
                  borderRadius:
                  BorderRadius.circular(12),
                  child: Image.network(
                    selectedQR,
                    width: double.infinity,
                    height: size.height * 0.3,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: appPrimaryColor,));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "images/qr.png",
                        width: double.infinity,
                        height: size.height * 0.3,
                        fit: BoxFit.contain,
                      );
                    },
                  )

                ),
              ),
            ),
          )
              : verticalSpace(height: size.height * 0.1),
          verticalSpace(height: size.height * 0.02),

          /// **Dynamic Payment Buttons**
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
                    selectedQR = method["image"] ?? "images/qr.png";
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

          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, ValetParkingRoutes.homeRoute, (route) => false);
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
                      Navigator.pushNamedAndRemoveUntil(
                          context, ValetParkingRoutes.homeRoute, (route) => false);
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
}
