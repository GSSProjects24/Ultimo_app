import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';

import '../../Routes/route.dart';
import '../../reusable/color.dart';



class SwipeToSignInScreen extends StatefulWidget {
  const SwipeToSignInScreen({super.key});

  @override
  _SwipeToSignInScreenState createState() => _SwipeToSignInScreenState();
}

class _SwipeToSignInScreenState extends State<SwipeToSignInScreen> {
  bool isSwipeComplete = false;

  Future<void> _onSwipeCompleted(BuildContext context) async {
    setState(() {
      isSwipeComplete = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacementNamed(context,ValetParkingRoutes.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor:appPrimaryColor,
      body: Center(
        child: Column(

          children: [
            verticalSpace(height:size.height*0.2 ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45,),
              child: Hero(
                tag: "logo",
                  child: Image.asset('images/logo_black.png')),
            ),
            verticalSpace(height:size.height*0.15 ),

            Container(
              width: size.width*0.7,
              height: size.height*0.07,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [appPrimaryColor,appSecondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: SwipeButton(
                thumb: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isSwipeComplete ?appPrimaryColor : whiteColor,
                    shape: BoxShape.circle,
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: isSwipeComplete
                          ? const Icon(Icons.check, size: 28, color: Colors.white, key: ValueKey("tick")) // ✅ Tick Icon with white color
                          : const Icon(Icons.arrow_forward_ios, size: 24, color: Colors.black, key: ValueKey("slide")), // ➡ Slide Icon with black color
                    ),
                  ),
                ),
                height: 60.0,
                width: 286.0,
                onSwipe: () => _onSwipeCompleted(context),
                activeTrackColor: Colors.transparent,
                borderRadius: BorderRadius.circular(30.0),
                child: Center(
                  child: Text(
                    "Swipe to Sign In",
                    style: MyTextStyle.f18(whiteColor,weight: FontWeight.w700,),

                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}