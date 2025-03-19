import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';
import '../booking/widget/key_holder.dart';

class KeyHolderPage extends StatefulWidget {
  final String documentId;
  final String locationName;

  const KeyHolderPage({super.key, required this.documentId, required this.locationName});

  @override
  State<KeyHolderPage> createState() => _KeyHolderPageState();
}

class _KeyHolderPageState extends State<KeyHolderPage> {
  String? selectedKeyHolder;
  String? documentId;
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchKeyHolder();
  }

  Future<void> _fetchKeyHolder() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.documentId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          documentId = docSnapshot.id;
          selectedKeyHolder = docSnapshot['keyHolder'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching keyHolder: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _updateKeyHolder() async {
    if (documentId != null && selectedKeyHolder != null) {
      setState(() {
        isUpdating = true;
      });
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(documentId).update({
          'keyHolder': selectedKeyHolder,
        });
        DocumentReference keyHolderDocRef = FirebaseFirestore.instance
            .collection("key_holders")
            .doc(widget.locationName);

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

            await keyHolderDocRef.update({"holders": holdersList});
            print("Key holder availability updated successfully.");
          }
        }

      } catch (e) {
        print("Error updating keyHolder: $e");
      } finally {
        setState(() {
          isUpdating = false;
        });
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: appSecondaryColor,
        title: Text("Select Key Holder", style: MyTextStyle.f22(whiteColor)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: appPrimaryColor))
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              verticalSpace(height: size.height * 0.1),
              KeyHolderSection(
                selectedHotel: widget.locationName,
                selectedKeyHolder: selectedKeyHolder,
                onKeyHolderSelected: (String? keyHolder) {
                  setState(() {
                    selectedKeyHolder = keyHolder;
                  });
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A896),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isUpdating ? null : _updateKeyHolder,
                  child: isUpdating
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
