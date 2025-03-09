import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Routes/route.dart';
import '../../../pages/v2/transaction_print.dart';
import '../../../reusable/color.dart';
import '../../../reusable/space.dart';
import '../../../reusable/text_style.dart';


class HeadSection extends StatefulWidget {
  final TextEditingController searchController;
  final String userName;
  final Function(String) onSearch;

  const HeadSection({Key? key, required this.searchController, required this.onSearch, required this.userName}) : super(key: key);

  @override
  State<HeadSection> createState() => _HeadSectionState();
}

class _HeadSectionState extends State<HeadSection> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(color: appPrimaryColor),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(height: size.height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('images/logo_black.png', height: 90),

                Row(
                  children: [
                    Card(
                      color: whiteColor,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ValetParkingRoutes.reportRoute);
                        },
                        icon: const Icon(Icons.insert_chart),
                      ),
                    ),
                    Card(
                      color: whiteColor,
                      child: IconButton(
                        onPressed: () {
                          logoutUser(context);
                        },
                        icon: const Icon(Icons.logout_sharp),
                      ),
                    )
                  ],
                ),

              ],
            ),
            verticalSpace(height: size.height * 0.01),
            Text('Welcome ${widget.userName}', style: MyTextStyle.f18(whiteColor)),
            verticalSpace(height: size.height * 0.025),
            Row(
              children: [
                Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: widget.searchController,
                        onChanged: (value) {
                          widget.onSearch(value);
                          setState(() {}); // Update UI to show/hide clear button
                        },
                        cursorColor: widget.searchController.text.isEmpty ? Colors.transparent : Colors.black, // Hide cursor when empty
                        decoration: InputDecoration(
                          hintText: 'Search for Car Number...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          suffixIcon: widget.searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              widget.searchController.clear();
                              widget.onSearch('');
                              setState(() {}); // Update UI
                            },
                          )
                              : null,
                        ),
                      )

                  ),
                ),
                horizontalSpace(width: size.height * 0.01),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => widget.onSearch(widget.searchController.text),
                    icon: const Icon(Icons.search, color: appPrimaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
    Navigator.pushReplacementNamed(context, ValetParkingRoutes.loginRoute);
  }
}

