//testing login page for future use if needed
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final emailController = TextEditingController();
  final passwordController =  TextEditingController();

  String user_name = "";
  String password = "";

  bool _passwordVisible = true;



  @override
  void initState() {
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Welcome to Cone!"),
              backgroundColor: Colors.orange,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "CONE",
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  child: Form(
                      child: Column(
                        children: [
                          TextFormField(

                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: 'Enter Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  user_name = value;
                                });
                              },
                              validator: (value) {
                                return value!.isEmpty ? 'Please Enter Email' : null;
                              }),
                          SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                              keyboardType: TextInputType.text,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: 'Enter Password',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25)
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              onChanged: (String value) {},
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please Enter password'
                                    : null;
                              }),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              minWidth: double.infinity,
                              onPressed: () {},
                              child: Text(
                                "Login",
                              ),
                              color: Colors.orange,
                              textColor: Colors.white,

                            ),
                          ),
                          Text(
                            "or",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                )
              ],
            )));
  }
}
