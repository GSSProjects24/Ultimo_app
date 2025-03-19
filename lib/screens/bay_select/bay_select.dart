import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/text_style.dart';


class ParkingBayScreen extends StatefulWidget {
  final String locationName;
  final String pageType;
  final String documentId;
  const ParkingBayScreen({super.key, required this.locationName, required this.pageType, required this.documentId});

  @override
  _ParkingBayScreenState createState() => _ParkingBayScreenState();
}

class _ParkingBayScreenState extends State<ParkingBayScreen> {
  int? selectedSlot;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: appSecondaryColor,
        title: Text("Select Bay", style: MyTextStyle.f22(whiteColor)),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('slots')
            .doc(widget.locationName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: appPrimaryColor));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 300,),
                  const Text(
                    "No Available Bay",
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
                          onTap: () =>   Navigator.pushNamed(context, ValetParkingRoutes.userListRoute,arguments: {"carNo":widget.documentId,"pageType":"primary","location":widget.locationName}),
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

          List<Map<String, dynamic>> availableSlots = [];
          List<String> bookedSlots = [];
          var data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey("slots") && data["slots"] is List) {
            List<dynamic> slotList = data["slots"];
            for (var slot in slotList) {
              if (slot is Map<String, dynamic> && slot.containsKey("name")) {
                availableSlots.add(slot);
                if (slot["available"] == false) {
                  bookedSlots.add(slot["name"]);
                }
              }
            }
          }

          return availableSlots.isEmpty || availableSlots.length == bookedSlots.length
              ?  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 300,),
                const Text(
                  "No Available Bay",
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
                        onTap: () =>   Navigator.pushNamed(context, ValetParkingRoutes.userListRoute,arguments: {"carNo":widget.documentId,"pageType":"primary","location":widget.locationName}),
                        child: Text(
                          "Skip <<<",
                          style: MyTextStyle.f16(appPrimaryColor, weight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ): Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: availableSlots.length,
                  itemBuilder: (context, index) {
                    String slotName = availableSlots[index]["name"];
                    bool isBooked = bookedSlots.contains(slotName);
                    bool isSelected = selectedSlot == index;

                    return GestureDetector(
                      onTap: isBooked
                          ? null
                          : () {
                        setState(() {
                          selectedSlot = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: appCardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: Colors.teal, width: 2) : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isBooked)
                              Positioned(
                                top: 10,
                                child: Image.asset(
                                  "images/car.png",
                                  width: 150,
                                  height: 100,
                                ),
                              )
                            else
                              const Positioned(
                                top: 10,
                                child: Icon(Icons.directions_car, color: appPrimaryColor, size: 40),
                              ),
                            Positioned(
                              bottom: 10,
                              child: Text(
                                slotName,
                                style: MyTextStyle.f18(isSelected ? appPrimaryColor : whiteColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: selectedSlot != null
                          ? () async {
                        String selectedBay = availableSlots[selectedSlot!]["name"];
                        setState(() { isLoading = true; });
                        try {
                          // Step 1: Update the booking document where carNumber matches
                          DocumentReference bookingDocRef = FirebaseFirestore.instance
                              .collection("bookings")
                              .doc(widget.documentId);

                          DocumentSnapshot bookingSnapshot = await bookingDocRef.get();

                          if (bookingSnapshot.exists) {
                            await bookingDocRef.update({"slot": selectedBay});
                            print("Slot updated successfully for documentId ${widget.documentId}");
                          } else {
                            print("No booking found for documentId ${widget.documentId}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("No booking found for this booking")),
                            );
                            return;
                          }


                          // Step 2: Update the available status of the selected slot
                          DocumentReference slotDocRef = FirebaseFirestore.instance
                              .collection("slots")
                              .doc(widget.locationName);

                          DocumentSnapshot slotDocSnapshot = await slotDocRef.get();

                          if (slotDocSnapshot.exists) {
                            Map<String, dynamic> slotData =
                            slotDocSnapshot.data() as Map<String, dynamic>;

                            if (slotData.containsKey("slots") && slotData["slots"] is List) {
                              List<dynamic> slotsList = slotData["slots"];

                              // Find the slot index that matches the selected slot name
                              int slotIndex = slotsList.indexWhere(
                                      (slot) => slot["name"] == selectedBay);

                              if (slotIndex != -1) {

                                slotsList[slotIndex]["available"] = false;

                                await slotDocRef.update({"slots": slotsList});

                                print("Slot availability updated in Firestore.");
                              }
                            }
                          }
                          if( widget.pageType == "primary")
                            Navigator.pushNamed(context, ValetParkingRoutes.userListRoute,arguments: {"documentId":widget.documentId,"pageType":"primary","location":widget.locationName});
                          else{
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          print("Error updating slot: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to update slot")),
                          );
                        }
                        finally {
                          setState(() { isLoading = false; });
                        }
                      }
                          : null,


                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child:  isLoading
                            ? const CircularProgressIndicator(color: whiteColor)
                            : Text(
                          selectedSlot != null
                              ? "Park at bay ${availableSlots[selectedSlot!]["name"]}"
                              : "Select a bay",
                          style: MyTextStyle.f16(blackColor, weight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if( widget.pageType == "primary")
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, ValetParkingRoutes.userListRoute,arguments: {"documentId":widget.documentId,"pageType":"primary","location":widget.locationName});
                        },
                        child: Text(
                          'Skip <<<',
                          style: MyTextStyle.f16(appPrimaryColor, weight: FontWeight.bold),
                        ),
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
}
