import 'package:flutter/material.dart';

import '../../../Routes/route.dart';
import '../../../reusable/color.dart';
import '../../../reusable/space.dart';
import '../../../reusable/text_style.dart';
import 'car_details_alertbox.dart';

class CardDesign extends StatefulWidget {
  final String carNo;
  final String mobileNo;
  final String parkingSlot;
  final String keyHolder;
  final String startTime;
  final String date;
  final String jockey;
  final VoidCallback onCheckout;
  final Size size;
  final String locationName;


  const CardDesign({
    super.key,
    required this.carNo,
    required this.mobileNo,
    required this.parkingSlot,
    required this.keyHolder,
    required this.startTime,
    required this.date,
    required this.onCheckout,
    required this.size, required this.locationName, required this.jockey,
  });

  @override
  State<CardDesign> createState() => _CardDesignState();
}

class _CardDesignState extends State<CardDesign> {

  @override
  Widget build(BuildContext context) {
    var size =MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CarDetailsDialog(
              mobileNo: widget.mobileNo,
              parkingSlot: widget.parkingSlot,
              keyHolder: widget.keyHolder,
              startTime: widget.startTime,
              date: widget.date,
              size: widget.size,
            );
          },
        );
      },
      child: Card(
        elevation: 5,
        color: appCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Car Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'images/car.png',
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              verticalSpace(height: widget.size.height * 0.01),
              Text(
                widget.carNo,
                style: MyTextStyle.f16(whiteColor, weight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              verticalSpace(height: widget.size.height * 0.01),
              if( widget.keyHolder.isEmpty && widget.parkingSlot.isEmpty && widget.jockey.isEmpty)
                verticalSpace(height: size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if( widget.keyHolder=="N/A")
                    _iconButton(
                      icon: Icons.vpn_key,
                      label: "Keys",
                      onTap: () {
                        Navigator.pushNamed(context, ValetParkingRoutes.keyHolderRoute,arguments: {"carNo":widget.carNo,"locationName":widget.locationName});
                      },
                    ),
                  if( widget.parkingSlot.isEmpty)
                    _iconButton(
                      icon: Icons.local_parking,
                      label: "Bay",
                      onTap: () {
                        Navigator.pushNamed(context, ValetParkingRoutes.baySelectRoute,arguments: {"carNo":widget.carNo,"locationName":widget.locationName,"pageType":"secondary"});
                      },
                    ),
                  if( widget.jockey.isEmpty)
                    _iconButton(
                      icon: Icons.person,
                      label: "User",
                      onTap: () {
                        Navigator.pushNamed(context, ValetParkingRoutes.userListRoute,arguments: {"carNo":widget.carNo,"pageType":"secondary","location":widget.locationName});
                      },
                    ),
                ],
              ),
              verticalSpace(height: widget.size.height * 0.01),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: checkoutColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Checkout',
                    style: MyTextStyle.f14(whiteColor, weight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: appPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: whiteColor, size: 18),
          ),
          verticalSpace(height: 5),
        ],
      ),
    );
  }
}