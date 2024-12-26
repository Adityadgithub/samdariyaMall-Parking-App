import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samdriya/screen/vehicleCheckIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SplashScreen.dart';
import 'constant.dart';

class UserLogin extends StatefulWidget {
  @override
  State<UserLogin> createState() => _UserLoginState();
}

String? onlynumber;
String? newusername;
String? newuserPassword;
String? newuserEmail;

class _UserLoginState extends State<UserLogin> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String? phoneNumber;
  String? nameerror;
  String? emailerror;
  String? passworderror;

  bool validator() {
    if (formkey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  var loginpressed;
  var _error;

  var countryselected = '91';

// MOBILE NUMBER VERIFY LOGICS
  Duration? duration;
  String? formattedTime;
  bool numberverified = false;
  bool OTPrequested = false;
  String? numbererror;

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  String email = 'fredrik.eilertsen@gail.com';

  //COOLDOWN
  bool cooldown = false;
  var maxseconds = 120;
  bool num_already_stored = false;
  bool verifyingfailed = false;

  Map datalist = Map();

  void _setKey(String key) async {
    setState(() {
      globalusertoken = key;
    });

    print('new globalusertoken is this -');
    print('$globalusertoken');
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', key);
    print('set key');
  }

  Future Login(login, password) async {
    try {
      var headers = {
        'x-access-token': '$globalusertoken',
        'Cookie': 'ci_session=f1c53e209a734c2472ebf565bb0834c8b8894dc7'
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://smalljbp.dpmstech.in/v1/account/login'));
      request.fields.addAll({'username': login, 'password': password});

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('api called');

      var data = await response.stream.bytesToString();
      datalist = jsonDecode(data);
      if (response.statusCode == 200) {
        if (datalist['status'] == 1) {
          print(datalist);
          _setKey(datalist['data']['token']);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CheckINOut(),
              ));
        } else {
          setState(() {
            _error = datalist['message'];
          });
        }

        print(datalist);
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    newusername = null;
    newuserPassword = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('your number -');
    print(onlynumber);
    // print(newuserEmail);
    // print(newuserPassword);
    // print(newusername);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.only(top: 80, right: 40, left: 40),
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  showAlert(),
                  Center(
                    child: Image(
                      image: AssetImage(
                        "assets/logo.png",
                      ),
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      "Username",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                      height: 40,
                      margin: EdgeInsets.only(
                        bottom: 15,
                        top: 8,
                      ),
                      child: TextFormField(
                          initialValue: newusername,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value!.isEmpty) {
                              setState(() {
                                nameerror = "Name can't be empty";
                              });
                            } else if (value!.length < 3) {
                              setState(() {
                                nameerror = "Too short name";
                              });
                            }
                            else{
                              setState(() {
                              nameerror= null;
                              });
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              nameerror = null;
                              newusername = value;
                            });
                          },
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                left: 12,
                              ),
                              hintText: "Enter Username",
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              prefix: SizedBox(
                                height: 20,
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black))))),
                  if (nameerror != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3, bottom: 10.0),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(0),
                            child: Row(
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    child: Text(
                                      "$nameerror",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 13),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                      height: 40,
                      child: TextFormField(
                        initialValue: newuserPassword,
                        validator: (value) {
                          if (value == null || value!.isEmpty) {
                            setState(() {
                              passworderror = "Password can't be empty";
                            });
                          } else if (value!.length < 3) {
                            setState(() {
                              nameerror = "Too short name";
                            });
                          }
                        },
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            newuserPassword = value;
                            passworderror = null;
                          });
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 12,
                            ),
                            hintText: 'Enter Password',
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            prefix: SizedBox(
                              height: 20,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                      )),
                  if (passworderror != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3, bottom: 10.0),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(0),
                            child: Row(
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    child: Text(
                                      "$passworderror",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 13),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(32),
                          backgroundColor: ThemeColorBlue,
                          padding: EdgeInsets.symmetric(vertical: 5)),
                      onPressed: () {
                        if (formkey.currentState!.validate()) {}
                        if (nameerror == null && passworderror == null) {
                          print(newusername.toString());
                          print(newuserPassword.toString());

                          Login(newusername.toString(),
                              newuserPassword.toString());
                        }
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget showAlert() {
    if (_error != null && emailerror == null && passworderror == null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.error_outline_outlined, color: Colors.red),
            ),
            Expanded(
                child: Text(
              "$_error",
              style: TextStyle(color: Colors.red),
            )),
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }
}

//   Padding InputBox(BuildContext context) {
//     return
//   }
// }

//Error Showing Widget
//   Widget showAlert() {
//     if (_error != null) {
//       return Container(
//         width: MediaQuery.of(context).size.width,
//         padding: EdgeInsets.all(8),
//         child: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Icon(Icons.error_outline_outlined, color: Colors.red),
//             ),
//             Container(
//                 width: MediaQuery.of(context).size.width - 100,
//                 child: Text(
//                   "$_error",
//                   style: TextStyle(color: Colors.red),
//                 )),
//           ],
//         ),
//       );
//     }
//     return SizedBox(
//       height: 0,
//     );
//   }
