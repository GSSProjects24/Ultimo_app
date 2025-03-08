import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../../../reusable/color.dart';
import '../../../reusable/text_style.dart';



class KeyHolderSection extends StatefulWidget {
  final String? selectedHotel;
  final String? selectedKeyHolder; // Added this parameter
  final ValueChanged<String?> onKeyHolderSelected;

  const KeyHolderSection({
    super.key,
    required this.selectedHotel,
    required this.onKeyHolderSelected,
    this.selectedKeyHolder, // Accept selected key holder
  });

  @override
  _KeyHolderSectionState createState() => _KeyHolderSectionState();
}

class _KeyHolderSectionState extends State<KeyHolderSection> {
  String? selectedBay;
  List<String> bayNumbers = [];

  @override
  void initState() {
    super.initState();
    selectedBay = widget.selectedKeyHolder; // Set initial value
    fetchKeyHolders();
  }

  @override
  void didUpdateWidget(covariant KeyHolderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedHotel != widget.selectedHotel) {
      fetchKeyHolders();
    }
  }

  Future<void> fetchKeyHolders() async {
    if (widget.selectedHotel == null) return;

    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
      await FirebaseFirestore.instance.collection('key_holders').doc(widget.selectedHotel).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        List<dynamic> holders = docSnapshot.data()?['holders'] ?? [];

        List<String> availableBays = holders
            .where((holder) => holder['available'] == true)
            .map<String>((holder) => holder['name'].toString())
            .toList();

        setState(() {
          bayNumbers = availableBays;
          if (!bayNumbers.contains(selectedBay)) {
            selectedBay = widget.selectedKeyHolder; // Reassign if it's a valid selection
          }
        });
      } else {
        setState(() {
          bayNumbers = [];
          selectedBay = null;
        });
      }
    } catch (e) {
      print("Error fetching key holders: $e");
      setState(() {
        bayNumbers = [];
        selectedBay = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose Key Holder", style: MyTextStyle.f18(whiteColor, weight: FontWeight.bold)),
          Container(
            height: 2,
            width: 50,
            color: appPrimaryColor,
            margin: const EdgeInsets.only(top: 4, bottom: 10),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: appSecondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
            ),
            child: DropdownButton<String>(
              dropdownColor: appSecondaryColor,
              value: bayNumbers.contains(selectedBay) ? selectedBay : null,
              icon: const Icon(Icons.arrow_drop_down_circle, color: whiteColor, size: 24),
              style: const TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
              isExpanded: true,
              hint: bayNumbers.isEmpty
                  ? const Text("No Available Key Holder", style: TextStyle(color: whiteColor))
                  : const Text("Choose Your Key Holder", style: TextStyle(color: whiteColor)),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedBay = newValue;
                  });
                  widget.onKeyHolderSelected(newValue);
                }
              },
              items: bayNumbers.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.key, color: Colors.white.withOpacity(0.8), size: 18),
                      const SizedBox(width: 10),
                      Text(value, style: MyTextStyle.f16(whiteColor)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}





