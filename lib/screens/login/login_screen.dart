import 'package:UberFlutter/main.dart';
import 'package:UberFlutter/screens/main_screen.dart';
import 'package:UberFlutter/screens/signup/signup_screen.dart';
import 'package:UberFlutter/store/users/user_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  static const String idScreen = "login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final userStore = UserStore();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              const SizedBox(height: 35),
              Image(
                image: AssetImage('images/logo.png'),
                width: 390,
                height: 250,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 2),
              Text(
                'Login as a Rider',
                style: TextStyle(fontSize: 24, fontFamily: 'Brand Bold'),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 2),
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
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          gapPadding: 8,
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passController,
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
                    const SizedBox(height: 16),
                    Observer(builder: (_) {
                      if (!userStore.loading)
                        return RaisedButton(
                          onPressed: () {
                            if (emailController.text.isNotEmpty &&
                                passController.text.isNotEmpty)
                              loginUser(context);
                            else
                              displayErrorMessage(
                                  "Please tip email and password", context);
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
                              'Login',
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'Brand Bold'),
                            ),
                          ),
                        );
                      else
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: FlatButton(
                        splashColor: Colors.black.withAlpha(100),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(SignupScreen.idScreen);
                        },
                        child: Text(
                            'Don´t have an account?  Register clicking here'),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future<void> loginUser(BuildContext context) async {
    userStore.setLoading(true);
    final User firebaseUser = (await firebaseAuth
            .signInWithEmailAndPassword(
                email: emailController.text, password: passController.text)
            .catchError((onError) {
      displayErrorMessage("Erro ${onError.toString()}", context);
      Future.delayed(Duration(seconds: 2)).then(
        (_) => userStore.setLoading(false),
      );
    }))
        .user;

    if (firebaseUser != null) {
      userRef.child(firebaseUser.uid).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Navigator.of(context).pushNamed(MainScreen.idScreen);
          displayErrorMessage("Congrats ${firebaseUser.email}", context);
          userStore.setLoading(false);
        } else {
          firebaseAuth.signOut();
          displayErrorMessage("No records exists for this", context);
          userStore.setLoading(false);
        }
      });
    } else {
      displayErrorMessage("No user found", context);
      userStore.setLoading(false);
    }

    userStore.setLoading(false);
  }

  void displayErrorMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
