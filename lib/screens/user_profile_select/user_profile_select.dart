import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:imin_printer_example/screens/user_profile_select/widget/success_dialogue.dart';

import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/text_style.dart';

class UserListScreen extends StatefulWidget {
  final String carNo;
  final String pageType;
  final String location;

  const UserListScreen({super.key, required this.carNo, required this.pageType, required this.location});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  int? _selectedIndex;

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
            return const Center(
              child: Text("No Jockey Profiles Found", style: TextStyle(color: whiteColor, fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          var users = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

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
                            child: ClipOval( // ✅ Ensures the image stays within the circle
                              child: ImageNetwork(
                                image: users[index]["image"] ?? "",
                                height: 84, // Adjusted to fit inside the CircleAvatar
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
                        onTap: () => Navigator.pushNamedAndRemoveUntil(context, ValetParkingRoutes.homeRoute, (route) => false),
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
    String selectedUserProfile = FirebaseFirestore.instance.collection('userprofile').doc().id;

    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection("bookings")
        .where("carNumber", isEqualTo: widget.carNo)
        .get();

    if (bookingSnapshot.docs.isNotEmpty) {
      String bookingId = bookingSnapshot.docs.first.id;
      await FirebaseFirestore.instance.collection("bookings").doc(bookingId).update({"jockey": selectedUserProfile});
      if (widget.pageType == "primary") {
        _showBookingSuccessDialog(MediaQuery.of(context).size);
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No matching booking found."), backgroundColor: Colors.red),
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
