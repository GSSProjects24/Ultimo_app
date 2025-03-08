
import 'package:flutter/material.dart';
import 'package:imin_printer_example/Routes/route.dart';

import '../pages/v2/home.dart';
import '../pages/v2/transaction_print.dart';
import '../screens/bay_select/bay_select.dart';
import '../screens/booking/booking_form.dart';
import '../screens/checkout/checkout.dart';
import '../screens/home/home.dart';
import '../screens/key_holder/key_holder.dart';
import '../screens/login/login.dart';
import '../screens/qr/qr.dart';
import '../screens/report/report.dart';
import '../screens/splash_screen/splash_screen.dart';
import '../screens/user_profile_select/user_profile_select.dart';



class InstantPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  InstantPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ValetParkingRoutes.splashRoute:
        return InstantPageRoute(page:  const SwipeToSignInScreen());
      case ValetParkingRoutes.loginRoute:
        return InstantPageRoute(page:  LoginScreen());
      case ValetParkingRoutes.homeRoute:
        return InstantPageRoute(page:  const HomeScreen());
      case ValetParkingRoutes.bookingFormRoute:
        return InstantPageRoute(page:  BookingFormScreen());
      case ValetParkingRoutes.baySelectRoute:
        final args = settings.arguments as Map<String, dynamic>;
        final locationName = args['locationName'] as String;
        final pageType = args['pageType'] as String;
        final carNo = args['carNo'] as String;
        return InstantPageRoute(page:  ParkingBayScreen(locationName: locationName,pageType: pageType,carNo: carNo,));
      case ValetParkingRoutes.checkoutRoute:
        final args = settings.arguments as Map<String, dynamic>;
        final carNo = args['carNo'] as String;
        final mobileNo = args['mobileNo'] as String;
        final parkingSlot = args['parkingSlot'] as String;
        final keyHolder = args['keyHolder'] as String;
        final bookingTime = args['bookingTime'] as String;
        final bookingDate = args['bookingDate'] as String;
        final checkoutTime = args['checkoutTime'] as String;
        final checkoutDate = args['checkoutDate'] as String;
        final amount = args['amount'] as String;
        final chargeBay = args['chargeBay'] as String;
        final location = args['location'] as String;

        return InstantPageRoute(page:  CheckoutScreen(carNumber: carNo,mobileNumber: mobileNo,
        parkingSlot: parkingSlot,
          keyHolder: keyHolder,
          bookingTime: bookingTime,
          bookingDate: bookingDate,
          checkoutTime: checkoutTime,
          checkoutDate: checkoutDate,
          amount: amount,
          chargeBay: chargeBay,
          location: location,
        ));

      case ValetParkingRoutes.reportRoute:
        return InstantPageRoute(page:  ValetParkingReportPage());

      case ValetParkingRoutes.userListRoute:
        final args = settings.arguments as Map<String, dynamic>;
        final pageType = args['pageType'] as String;
        final carNo = args['carNo'] as String;
        final location = args['location'] as String;
        return InstantPageRoute(page:  UserListScreen(carNo: carNo,pageType: pageType,location: location,));

      case ValetParkingRoutes.qrRoute:
        return InstantPageRoute(page:  QRScreen());

        case ValetParkingRoutes.keyHolderRoute:
          final args = settings.arguments as Map<String, dynamic>;
          final locationName = args['locationName'] as String;
          final carNo = args['carNo'] as String;
        return InstantPageRoute(page:   KeyHolderPage(carNo: carNo,locationName: locationName,));

      case ValetParkingRoutes.printHomeRoute:
        return InstantPageRoute(page:  const NewHome());

      case ValetParkingRoutes.transactionPrintRoute:
        return InstantPageRoute(page:  const TransactionPrintPage());
        default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Unknown Route')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
