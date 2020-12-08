import 'package:UberFlutter/main.dart';
import 'package:UberFlutter/screens/login/login_screen.dart';
import 'package:UberFlutter/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends StatefulWidget {
  static const String idScreen = "signup";

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp'),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: 35),
            Image(
              image: AssetImage('images/logo.png'),
              width: 390,
              height: 250,
              alignment: Alignment.center,
            ),
            SizedBox(height: 2),
            Text(
              'Signup as a Rider',
              style: TextStyle(fontSize: 24, fontFamily: 'Brand Bold'),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 2),
                  TextField(
                    keyboardType: TextInputType.name,
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                        fontSize: 16,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        gapPadding: 8,
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone",
                      labelStyle: TextStyle(
                        fontSize: 16,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        gapPadding: 8,
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        fontSize: 16,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        gapPadding: 8,
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        fontSize: 16,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        gapPadding: 8,
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  RaisedButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty ||
                          !emailController.text.contains("@") ||
                          nameController.text.length < 4 ||
                          passwordController.text.isEmpty) {
                        displayErrorMessage(
                            "Email, name and password are obrigatory", context);
                      } else {
                        await registerNewUser(context);
                      }
                    },
                    splashColor: Colors.amber,
                    shape: StadiumBorder(),
                    color: Colors.orange,
                    clipBehavior: Clip.antiAlias,
                    elevation: 10,
                    textColor: Colors.black,
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        'SignUp',
                        style:
                            TextStyle(fontSize: 18, fontFamily: 'Brand Bold'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: FlatButton(
                      splashColor: Colors.black.withAlpha(100),
                      onPressed: () {
                        Navigator.of(context).pushNamed(LoginScreen.idScreen);
                      },
                      child:
                          Text('Already have an account?  Login clicking here'),
                    ),
                  ),
                  Container(height: 350),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future<void> registerNewUser(BuildContext context) async {
    final User user = (await firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .catchError((onError) {
      displayErrorMessage("Error: ${onError.toString()}", context);
    }))
        .user;
    if (user != null) {
      Map userToMap = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text.trim(),
      };

      userRef.child(user.uid).set(userToMap);
      displayErrorMessage("Congratulations ${nameController.text}", context);
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      displayErrorMessage("Verify your connection", context);
    }
  }

  void displayErrorMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
