import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:imin_printer_example/screens/home/widget/card_design.dart';
import 'package:imin_printer_example/screens/home/widget/head_section.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String? username;
  List<Map<String, dynamic>> parkingList = [];
  String? selectedSlot;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchBookings();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('perfs');
    });
  }

  Future<void> _fetchBookings() async {
    try {
      if (username == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        username = prefs.getString('perfs');
      }

      if (username == null || username!.isEmpty) {
        setState(() {
          isLoading = false;
          parkingList = [];
        });
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('checkout', isEqualTo: "")
          .where('userProfile', isEqualTo: username)
          .get();

      List<Map<String, dynamic>> fetchedData = snapshot.docs.map((doc) {
        return {
          'carNo': doc['carNumber'] ?? 'Unknown',
          'mobileNo': doc['mobileNumber'] ?? 'N/A',
          'parkingSlot': doc['slot'] ?? 'N/A',
          'keyHolder': doc['keyHolder']?.toString() ?? 'N/A',
          'startTime': (doc['checkIn'] as Timestamp).toDate().toUtc().toString(),
          'date': doc['checkIn'].toDate().toLocal().toString().split(' ')[0],
          'amount': doc['amount'] ?? 'RM0',
          'location': doc['location'] ?? '',
          'jockey': doc['jockey'] ?? '',
          'chargeBay': doc['chargeBay'] ?? '',
          'paymentMethodName':doc['paymentMethodName'] ?? '',

        };
      }).toList();

      setState(() {
        parkingList = fetchedData;
        isLoading = false;
      });
      debugPrint('data : $parkingList');
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredList {
    List<Map<String, dynamic>> list = parkingList;

    if (searchQuery.isNotEmpty) {
      list = list
          .where((car) =>
          car['carNo'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (selectedSlot != null && selectedSlot!.isNotEmpty) {
      list = list.where((car) => car['parkingSlot'] == selectedSlot).toList();
    }

    return list;
  }

  Future<Stream<QuerySnapshot<Object?>>> _getBookingsStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('perfs');
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('checkout', isEqualTo: "")
        .where('userProfile', isEqualTo: username)
        .snapshots();
  }



  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: appSecondaryColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: appPrimaryColor,
        onPressed: () {
          Navigator.pushNamed(context, ValetParkingRoutes.bookingFormRoute);
        },
        child: const Icon(Icons.add, color: whiteColor, size: 28),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.33,
            child: HeadSection(
              userName: username ?? "",
              searchController: searchController,
              onSearch: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Positioned(
            top: size.height * 0.3,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  verticalSpace(height: size.height * 0.02),
                  Text(
                    'User Parking Details',
                    style: MyTextStyle.f22(whiteColor, weight: FontWeight.w700),
                  ),
                  verticalSpace(height: size.height * 0.01),
                  Expanded(
                    child: FutureBuilder<Stream<QuerySnapshot>>(
                      future: _getBookingsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: appPrimaryColor),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No results found", style: MyTextStyle.f16(whiteColor)),
                          );
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: snapshot.data,
                          builder: (context, streamSnapshot) {
                            if (streamSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(color: appPrimaryColor),
                              );
                            }

                            if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text("No results found", style: MyTextStyle.f16(whiteColor)),
                              );
                            }


                            List<Map<String, dynamic>> filteredList = streamSnapshot.data!.docs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              DateTime checkInDate = data['checkIn'].toDate().toLocal();
                              String formattedDate = DateFormat('dd-MM-yyyy').format(checkInDate);

                              return {
                                'carNo': data['carNumber'] ?? 'Unknown',
                                'mobileNo': data['mobileNumber'] ?? 'N/A',
                                'parkingSlot': data['slot'] ?? 'N/A',
                                'keyHolder': data['keyHolder']?.toString() ?? 'N/A',
                                'startTime': DateFormat('HH:mm a').format(data['checkIn'].toDate()),
                                'date': formattedDate,
                                'amount': data['amount'] ?? 'RM0',
                                'location': data['location'] ?? '',
                                'jockey': data['jockey'] ?? '',
                                'chargeBay': data['chargeBay'] ?? '',
                                'paymentMethodName':data['paymentMethodName'] ?? '',
                              };
                            }).toList();

                            filteredList = filteredList.where((car) {
                              return car['carNo'].toLowerCase().contains(searchQuery.toLowerCase());
                            }).toList();
                            debugPrint('data:$filteredList');
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.63,
                              ),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                var car = filteredList[index];
                                return CardDesign(
                                  documentId: streamSnapshot.data!.docs[index].id,
                                  carNo: car['carNo'],
                                  mobileNo: car['mobileNo'],
                                  parkingSlot: car['parkingSlot'],
                                  keyHolder: car['keyHolder'],
                                  startTime: car['startTime'],
                                  jockey: car['jockey'],
                                  locationName: car['location'] ?? "",
                                  date: car['date'],
                                  onCheckout: () {
                                    DateTime now = DateTime.now();
                                    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
                                    String formattedTime = DateFormat('HH:mm a').format(now);
                                    debugPrint('documentId:${streamSnapshot.data!.docs[index].id}');
                                    debugPrint("documentId': $streamSnapshot.data!.docs[index].id,'carNo': ${car['carNo']},'mobileNo': car['mobileNo'],'parkingSlot': ${car['parkingSlot']},'keyHolder': ${car['keyHolder']},'bookingTime': ${car['startTime']},'bookingDate': ${car['date']},'checkoutTime': ${formattedTime},'checkoutDate': $formattedDate,'amount':${ car['amount']},'chargeBay': ${car['chargeBay']} ?? "",'location': ${car['location']} ?? "",'paymentMethodName':${car['paymentMethodName']} ?? "",");
                                    Navigator.pushNamed(
                                      context,
                                      ValetParkingRoutes.checkoutRoute,
                                      arguments: {
                                        'documentId': streamSnapshot.data!.docs[index].id,
                                        'carNo': car['carNo'],
                                        'mobileNo': car['mobileNo'],
                                        'parkingSlot': car['parkingSlot'],
                                        'keyHolder': car['keyHolder'],
                                        'bookingTime': car['startTime'],
                                        'bookingDate': car['date'],
                                        'checkoutTime': formattedTime,
                                        'checkoutDate': formattedDate,
                                        'amount': car['amount'],
                                        'chargeBay': car['chargeBay'] ?? "",
                                        'location': car['location'] ?? "",
                                        'paymentMethodName':car['paymentMethodName'] ?? "",
                                      },
                                    );
                                  },
                                  size: MediaQuery.of(context).size,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
