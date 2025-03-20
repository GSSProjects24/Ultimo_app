import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';
import '../../reusable/widget/text_field.dart';
import '../key_holder/widget/key_holder_design.dart';


enum BookingType { dayWise, hourWise }

class BookingFormScreen extends StatefulWidget {
  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  TextEditingController carNo = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController countryCode = TextEditingController();


  List<QueryDocumentSnapshot<Map<String, dynamic>>> locations = [];
  bool isLoading = false;
  String? selectedKeyHolder;
  String? selectedLocation;
  List<String>? selectedChargeBay;
  String? amount;
  String? selectedChargeBayOption;
  BookingType? selectedBookingType;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }


  Future<void> fetchLocations() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('locations').get();
      setState(() {
        locations = snapshot.docs;
        if (locations.isNotEmpty) {
          selectedLocation = locations.first.data()['name'];

          // Extract the chargeBay data
          var chargeBayData = locations.first.data()['chargeBay'];
          if (chargeBayData != null && chargeBayData is Map) {
            selectedChargeBay = List<String>.from(chargeBayData.keys); // Extracting keys properly
          }

          // Set amount based on the chargeBay (default to Day)
          amount = chargeBayData["Day"]?.toString() ?? "0";  // Default value if not found
          updateBookingType(selectedChargeBay!.first); // Update the booking type based on the first chargeBay
        }
      });
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }


  void updateBookingType(String? chargeBay) {
    if (chargeBay != null) {
      var selectedLocationData = locations.firstWhere((loc) => loc["name"] == selectedLocation);
      var chargeBayData = selectedLocationData["chargeBay"];

      if (chargeBay.toLowerCase() == "day") {
        amount = chargeBayData["Day"]?.toString(); // Set amount for Day (e.g., "50")
        selectedBookingType = BookingType.dayWise;
      } else if (chargeBay.toLowerCase() == "hour") {
        // If Hour is selected, set amount based on "Two hours" and "Subsequent"
        var twoHours = chargeBayData["Hour"]?["Two hours"]?.toString() ?? "0";
        var subsequent = chargeBayData["Hour"]?["Subsequent"]?.toString() ?? "0";

        amount = "$twoHours / $subsequent"; // Concatenate the two values
        selectedBookingType = BookingType.hourWise;
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: appSecondaryColor,
      appBar: AppBar(
        backgroundColor: appSecondaryColor,
        title: Text("Parking Details", style: MyTextStyle.f22(whiteColor)),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: appCardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Location", style: MyTextStyle.f18(whiteColor)),
                    verticalSpace(height: 10),
                    locations.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: appPrimaryColor,))
                        :DropdownButton<String>(
                      value: selectedLocation,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      dropdownColor: appCardColor,
                      style: MyTextStyle.f16(appPrimaryColor),
                      items: locations.map((doc) {
                        String hotelName = doc.data()['name'] ?? "";
                        return DropdownMenuItem<String>(
                          value: hotelName,
                          child: Text(hotelName, textAlign: TextAlign.center),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value!;
                          var selectedLocationData = locations.firstWhere((loc) => loc["name"] == value);
                          selectedChargeBay = List<String>.from(selectedLocationData["chargeBay"].keys); // Extracting keys properly
                          selectedBookingType = null;
                        });
                      },
                    )
                    ,
                  ],
                ),
              ),
              verticalSpace(height: size.height * 0.025),
              CustomTextField(hintText: "Car Number", controller: carNo,textCapitalization: TextCapitalization.characters,),
              verticalSpace(height: size.height * 0.025),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      readOnly: true,
                      hintText: "+60",
                      controller: countryCode,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: CustomTextField(
                      hintText: "Mobile Number",
                      controller: mobileNo,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              verticalSpace(height: size.height * 0.02),
              KeyHolderSection(
                key: ValueKey(selectedLocation),
                selectedHotel: selectedLocation,
                onKeyHolderSelected: (String? keyHolder) {
                  setState(() {
                    selectedKeyHolder =  keyHolder;
                  });
                },
              ),

              verticalSpace(height: size.height * 0.03),
              Text("Bay Charge", style: MyTextStyle.f18(whiteColor)),
              verticalSpace(height: size.height * 0.03),
              if (selectedChargeBay != null) ...[
                Column(
                  children: selectedChargeBay!.map((chargeBay) {
                    return RadioListTile<String>(
                      title: Text(chargeBay, style: const TextStyle(color: Colors.white)),
                      value: chargeBay,
                      groupValue: selectedChargeBayOption,
                      onChanged: (value) {
                        setState(() {
                          selectedChargeBayOption = value;
                          updateBookingType(value); // Update amount based on selected chargeBay
                        });
                      },
                      activeColor: appPrimaryColor,
                    );
                  }).toList(),
                )
              ],
              verticalSpace(height: size.height * 0.05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A896),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (carNo.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your Car Number"))
                    );
                    return;
                  }

                  if (mobileNo.text.isEmpty ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your Mobile Number"))
                    );
                    return;
                  }

                  if (selectedChargeBayOption == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a charge bay"))
                    );
                    return;
                  }

                  if (selectedLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a location"))
                    );
                    return;
                  }

                  debugPrint('key value : ${selectedKeyHolder == "No Available Holder" ? "No Available Holder" : selectedKeyHolder}');
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    //  Check if the car is already parked
                    QuerySnapshot existingBookings = await FirebaseFirestore.instance
                        .collection("bookings")
                        .where("carNumber", isEqualTo: carNo.text)
                        .where("checkout", isEqualTo: "")
                        .get();

                    if (existingBookings.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("This car is already parked!"))
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? username = prefs.getString('perfs');
                    Map<String, dynamic> bookingData = {
                      "location": selectedLocation,
                      "carNumber": carNo.text,
                      "mobileNumber": "+60${mobileNo.text}",
                      "keyHolder": selectedKeyHolder == "No Available Holder" ? "" : selectedKeyHolder,
                      "chargeBay": selectedChargeBayOption,
                      "checkIn": FieldValue.serverTimestamp(),
                      "amount": amount, // This will dynamically update the amount based on selection
                      "slot": "",
                      "userProfile": username,
                      "jockey": "",
                      "checkout": "",
                      "totalHours": "",
                      "totalAmount": "",
                      "paymentStatus": "",
                      "paymentMethodName": ""
                    };

                    // Save Booking Data
                    DocumentReference bookingRef = await FirebaseFirestore.instance.collection("bookings").add(bookingData);
                    String documentId = bookingRef.id;
                    print("Booking saved successfully");

                    //  Update Key Holder Availability in Firestore
                    DocumentReference keyHolderDocRef = FirebaseFirestore.instance
                        .collection("key_holders")
                        .doc(selectedLocation);

                    DocumentSnapshot keyHolderSnapshot = await keyHolderDocRef.get();

                    if (keyHolderSnapshot.exists) {
                      Map<String, dynamic> keyHolderData =
                      keyHolderSnapshot.data() as Map<String, dynamic>;

                      if (keyHolderData.containsKey("holders") && keyHolderData["holders"] is List) {
                        List<dynamic> holdersList = keyHolderData["holders"];

                        if (selectedKeyHolder != null && selectedKeyHolder != "No Available Holder" && selectedKeyHolder!.isNotEmpty) {
                          int holderIndex = holdersList.indexWhere((holder) => holder["name"] == selectedKeyHolder);

                          if (holderIndex != -1) {
                            holdersList[holderIndex]["available"] = false;
                          }
                        } else {
                          for (var holder in holdersList) {
                            holder["available"] = true;
                          }
                        }
                        // Update Firestore document
                        await keyHolderDocRef.update({"holders": holdersList});
                        print("Key holder availability updated successfully.");
                      }
                    }

                    Navigator.pushNamed(
                      context,
                      ValetParkingRoutes.baySelectRoute,
                      arguments: {
                        "locationName": selectedLocation,
                        "pageType": "primary",
                        "documentId": documentId
                      },
                    );
                  } catch (e) {
                    print("Error saving booking: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to save booking"))
                    );
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )

              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF00A896),
              //     minimumSize: const Size(double.infinity, 50),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   onPressed: () async {
              //     if (carNo.text.isEmpty) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(content: Text("Please enter your Car Number"))
              //       );
              //       return;
              //     }
              //
              //     if (mobileNo.text.isEmpty ) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(content: Text("Please enter your Mobile Number"))
              //       );
              //       return;
              //     }
              //     if (selectedChargeBayOption== null ) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(content: Text("Please select a charge bay"))
              //       );
              //       return;
              //     }
              //     if (selectedLocation == null) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(content: Text("Please select a location"))
              //       );
              //       return;
              //     }
              //
              //     debugPrint('key value : ${selectedKeyHolder == "No Available Holder" ? "No Available Holder" : selectedKeyHolder}');
              //     setState(() {
              //       isLoading = true;
              //     });
              //
              //     try {
              //       //  Check if the car is already parked
              //       QuerySnapshot existingBookings = await FirebaseFirestore.instance
              //           .collection("bookings")
              //           .where("carNumber", isEqualTo: carNo.text)
              //           .where("checkout", isEqualTo: "")
              //           .get();
              //
              //       if (existingBookings.docs.isNotEmpty) {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //             const SnackBar(content: Text("This car is already parked!"))
              //         );
              //         setState(() {
              //           isLoading = false;
              //         });
              //         return;
              //       }
              //       SharedPreferences prefs = await SharedPreferences.getInstance();
              //       String? username = prefs.getString('perfs');
              //       Map<String, dynamic> bookingData = {
              //         "location": selectedLocation,
              //         "carNumber": carNo.text,
              //         "mobileNumber": "+60${mobileNo.text}",
              //         "keyHolder": selectedKeyHolder == "No Available Holder" ? "" : selectedKeyHolder,
              //         "chargeBay": selectedChargeBayOption,
              //         "checkIn": FieldValue.serverTimestamp(),
              //         "amount": amount,
              //         "slot": "",
              //         "userProfile": username,
              //         "jockey":"",
              //         "checkout": "",
              //         "totalHours": "",
              //         "totalAmount": "",
              //         "paymentStatus":"",
              //         "paymentMethodName":""
              //       };
              //
              //       // Save Booking Data
              //       DocumentReference bookingRef = await FirebaseFirestore.instance.collection("bookings").add(bookingData);
              //       String documentId = bookingRef.id;
              //       print("Booking saved successfully");
              //
              //       //  Update Key Holder Availability in Firestore
              //       DocumentReference keyHolderDocRef = FirebaseFirestore.instance
              //           .collection("key_holders")
              //           .doc(selectedLocation);
              //
              //       DocumentSnapshot keyHolderSnapshot = await keyHolderDocRef.get();
              //
              //       if (keyHolderSnapshot.exists) {
              //         Map<String, dynamic> keyHolderData =
              //         keyHolderSnapshot.data() as Map<String, dynamic>;
              //
              //         if (keyHolderData.containsKey("holders") && keyHolderData["holders"] is List) {
              //           List<dynamic> holdersList = keyHolderData["holders"];
              //
              //           if (selectedKeyHolder != null && selectedKeyHolder != "No Available Holder" && selectedKeyHolder!.isNotEmpty) {
              //             int holderIndex = holdersList.indexWhere((holder) => holder["name"] == selectedKeyHolder);
              //
              //             if (holderIndex != -1) {
              //               holdersList[holderIndex]["available"] = false;
              //             }
              //           } else {
              //             for (var holder in holdersList) {
              //               holder["available"] = true;
              //             }
              //           }
              //           // Update Firestore document
              //           await keyHolderDocRef.update({"holders": holdersList});
              //           print("Key holder availability updated successfully.");
              //         }
              //       }
              //
              //
              //       Navigator.pushNamed(
              //         context,
              //         ValetParkingRoutes.baySelectRoute,
              //         arguments: {
              //           "locationName": selectedLocation,
              //           "pageType": "primary",
              //           "documentId": documentId
              //         },
              //       );
              //     } catch (e) {
              //       print("Error saving booking: $e");
              //       ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(content: Text("Failed to save booking"))
              //       );
              //     }
              //     setState(() {
              //       isLoading = false;
              //     });
              //   },
              //
              //
              //   child: isLoading
              //       ? const CircularProgressIndicator(color: Colors.white)
              //       : const Text(
              //     "Next",
              //     style: TextStyle(fontSize: 18, color: Colors.white),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
