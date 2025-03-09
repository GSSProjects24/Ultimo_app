import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Routes/route.dart';
import '../../reusable/color.dart';
import '../../reusable/space.dart';
import '../../reusable/text_style.dart';
import '../../reusable/widget/text_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      String enteredEmail = email.text.trim();
      String enteredPassword = password.text.trim();

      var userDoc = await FirebaseFirestore.instance
          .collection('userprofile')
          .where('email', isEqualTo: enteredEmail)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        var userData = userDoc.docs.first.data();

        if (userData['password'] == enteredPassword) {

          String userName = userData['name'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('perfs', userName);
          Navigator.pushReplacementNamed(context, ValetParkingRoutes.homeRoute);
        } else {
          showSnackbar("Invalid Password!");
        }
      } else {
        showSnackbar("User not found!");
      }
    } catch (e) {
      showSnackbar("Error: ${e.toString()}");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
        .hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: appSecondaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "logo",
                  child: Image.asset('images/logo.png', height: 170),
                ),
                verticalSpace(height: size.height * 0.025),
                Text(
                  "Welcome Back",
                  style: MyTextStyle.f24(whiteColor, weight: FontWeight.bold),
                ),
                verticalSpace(height: size.height * 0.04),
                CustomTextField(
                    hintText: "Email",
                    controller: email,
                    validator: emailValidator,
                    keyboardType: TextInputType.emailAddress
                ),
                verticalSpace(height: size.height * 0.025),
                CustomTextField(
                  hintText: "Password",
                  isPassword: true,
                  controller: password,
                  validator: passwordValidator,
                ),
                verticalSpace(height: size.height * 0.035),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : loginUser,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Login", style: MyTextStyle.f18(whiteColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
