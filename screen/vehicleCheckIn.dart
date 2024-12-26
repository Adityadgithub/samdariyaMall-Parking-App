import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:samdriya/SplashScreen.dart';
import 'package:samdriya/Summary.dart';
import 'package:samdriya/UserLogin.dart';
import 'package:samdriya/constant.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:samdriya/provider/VehicleCheckIn_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CheckINOut extends StatefulWidget {
  @override
  State<CheckINOut> createState() => _CheckINOutState();
}

Map checkInData = Map();
Map reciptData = Map();
var _timer;

class _CheckINOutState extends State<CheckINOut> {
  var _error;

  var nameerror;

  var valuerror;
  String? newusername;

  bool? isapicalled = false;

  var amount;
  String? vehicleType;
  String? numbererror;
  bool proceed = false;
  var newusernumber;

  bool showprogressindicator = false;

  var _VehicalTypeDataAPI;

  bool NetworkError = false;
  _DialogBox() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        proceed = false;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            alignment: Alignment.topCenter,
            scrollable: true,
            title: const Text("Vehicle Check In"),
            content: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Vehical Type : " + vehicleType!),
                  SizedBox(
                    height: 30,
                  ),
                  Text("Vehical Amount : " + amount),
                  Divider(),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  showprogressindicator == false
                      ? Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColorBlue),
                            child: const Text(
                              "Yes",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              if (proceed == false) {
                                setState(() {
                                  proceed = true;
                                  showprogressindicator = true;
                                });
                                print('working');
                                newusernumber == null
                                    ? CheckIN(newusername, _VehicalTypeDataAPI, '')
                                    : CheckIN(
                                        newusername, _VehicalTypeDataAPI, newusernumber);
                              } else {
                                print(proceed);
                                print('unable to proceed');
                              }
                            },
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, bottom: 10),
                          child: CircularProgressIndicator(),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future CheckIN(vehicle_number, vehicle_type, mobile_no) async {
    try {
      var headers = {
        'x-access-token': '$globalusertoken',
        'Cookie': 'ci_session=15e2ca751bd413d1ea2822611b865217982377f2'
      };
      print('globalusertoken');
      print(globalusertoken);
      var request = http.MultipartRequest('POST',
          Uri.parse('http://smalljbp.dpmstech.in/v1/account/vehicle_check_in'));
      request.fields.addAll({
        'vehicle_number': '$vehicle_number',
        'vehicle_type': '$vehicle_type',
        'mobile_no': '$mobile_no'
      });
      print('$vehicle_type,$vehicle_number,$mobile_no');

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      isapicalled = true;

      setState(() {
        showprogressindicator = false;
      });
      var data = await response.stream.bytesToString();
      checkInData = jsonDecode(data);
      print('data : $checkInData');
      if (response.statusCode == 200) {
        if (checkInData['status'] == 1) {
          setState(() {
            reciptAPI(checkInData['data']['check_in_id']);
          });
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
                content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 15),
                Text('Please wait'),
              ],
            )),
          );
        }
      } else {
        setState(() {
          _error = checkInData['message'];
        });
        print('_error');
      }
    } catch (e) {
      print('Api call catch error - $e');
      setState(() {
        NetworkError = true;
        showprogressindicator = false;
        proceed = false;
      });
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
            SizedBox(width: 15),
            Text('Network Error'),
          ],
        )),
      );
    }
  }

  Future reciptAPI(check_in_id) async {
    try {
      var headers = {
        'x-access-token': '$globalusertoken',
        'Cookie': 'ci_session=6ab94e5e9ed87b3fe01eaf7140c283c4e2992216'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://smalljbp.dpmstech.in/v1/account/get_vehicle_check_in_data'));
      request.fields.addAll({'check_in_id': '$check_in_id'});

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print(check_in_id);
      var data = await response.stream.bytesToString();
      reciptData = jsonDecode(data);
      if (response.statusCode == 200) {
        print(reciptData);
        if (reciptData['status'] == 1) {
          await _generatePdf();

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CheckINOut(),
              ));
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
  }

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  var _key;

  void _deletetoken() async {
    print('running');
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.remove('token');
      _key = key;
    
    print('YOUR KEY - "$key"');
    print('key deleted');
  }


  @override
  void dispose() {
    _VehicalTypeDataAPI = null;
    newusernumber = null;
    newusername = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countProvider = Provider.of<VehicleCheckIn_Controller>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 20, bottom: 5),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: ThemeColorRed),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Summary(),
                      ));
                },
                child: Text(
                  "Summary",
                  style: TextStyle(color: Colors.white),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              right: 30,
              bottom: 5,
            ),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: ThemeColorRed),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: new Text('Are you sure?'),
                      content: new Text('Do you want to Logout'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false), //<-- SEE HERE
                          child: new Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deletetoken();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        UserLogin()),
                                ModalRoute.withName('/'));
                          }, // <-- SEE HERE
                          child: new Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black12, width: 1, style: BorderStyle.solid)),
          margin: EdgeInsets.only(
            top: 15,
            right: 20,
            left: 15,
            bottom: 20,
          ),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Vehicle Check In/Out',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(
                          'Bike',
                          style: radioButtonText,
                        ),
                        leading: Consumer<VehicleCheckIn_Controller>(
                          builder:(context, value, child) =>  Radio<String>(
                            value: '1',
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: -4),
                            groupValue: countProvider.VehicalType,
                            onChanged: (Rvalue) {
                              setState(() {
                                value.VehicalType = Rvalue;
                                _VehicalTypeDataAPI = countProvider.VehicalType;
                                amount = '20';
                                vehicleType = 'Bike';
                              });
                            },
                          ),
                        ),
                      )),
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: Text(
                            'Car',
                            style: radioButtonText,
                          ),
                          leading: Radio<String>(
                            value: '2',
                            groupValue: countProvider.VehicalType,
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: -4),
                            onChanged: (value) {
                              setState(() {
                                countProvider.VehicalType = value!;
                                amount = '50';
                                vehicleType = 'Car';
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: Text(
                            'VIP Car',
                            style: radioButtonText,
                          ),
                          leading: Radio(
                            value: "3",
                            groupValue: countProvider.VehicalType,
                            onChanged: (value) {
                              setState(() {
                                countProvider.VehicalType = value;
                                
                              _VehicalTypeDataAPI = countProvider.VehicalType;
                                amount = '100';
                                vehicleType = 'VIP Car';
                              });
                              //debugPrint(_value!.name);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (countProvider.VehicalType == null && isapicalled == true)
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
                                    "Vehicle Type can't be empty",
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
                  padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
                  child: Text(
                    "Vehicle",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Container(
                    height: 40,
                    margin: EdgeInsets.only(
                      bottom: 15,
                      right: 20,
                      left: 20,
                      top: 8,
                    ),
                    child: TextFormField(
                        autofocus: false,
                        initialValue: newusername,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value!.isEmpty) {
                            setState(() {
                              nameerror = "Vehicle number can't be empty";
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
                            hintText: "Enter Vehicle Number",
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            prefix: SizedBox(
                              height: 20,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))))),
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
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Text(
                    "Mobile Number",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Container(
                    height: 40,
                    margin: EdgeInsets.only(
                      bottom: 15,
                      right: 20,
                      left: 20,
                      top: 8,
                    ),
                    child: TextFormField(
                        initialValue: newusername,
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                        validator: (value) {
                          setState(() {
                            if (value == null || value.isEmpty) {
                            } else if (value.length < 10) {
                              numbererror = "Please enter full 10 digit number";
                            }
                          });

                          if (value!.contains(',')) {
                            numbererror =
                                "Invalid input. Please enter numbers only";
                          }
                          if (value.contains('.')) {
                            numbererror =
                                "Invalid input. Please enter numbers only";
                          }
                          if (value.contains('-')) {
                            numbererror =
                                "Invalid input. Please enter numbers only";
                          }
                          if (value.contains(' ')) {
                            numbererror =
                                "Invalid input. Please enter numbers only without any spaces";
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            numbererror = null;
                            newusernumber = value;
                          });
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 12,
                            ),
                            hintText: "Enter Mobile Number",
                            hintStyle: TextStyle(
                              fontSize: 14,
                            ),
                            prefix: SizedBox(
                              height: 20,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))))),
                if (numbererror != null)
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
                                    "$numbererror",
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
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColorGreen,
                      ),
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {}
                        if (countProvider.VehicalType == null) {
                          isapicalled = true;
                        } else if (nameerror == null && numbererror == null) {
                          setState(() {
                            showprogressindicator = false;
                            proceed = false;
                            NetworkError = false;
                          });
                          await _DialogBox();
                        }
                      },

                      //_generatePdf();

                      child: Text(
                        "Check In",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

_generatePdf() async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final font = await PdfGoogleFonts.nunitoExtraLight();
  final image = await imageFromAssetBundle('assets/logo.png');

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Container(
            height: 550,
            padding: pw.EdgeInsets.only(left: 5, right: 5, top: 10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: PdfColors.grey,
                    style: pw.BorderStyle.solid,
                    width: 1)),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(image, height: 120),
                pw.Text(reciptData['data']['vehicle'],
                    style: pw.TextStyle(
                      fontSize: 48,
                    )),
                pw.SizedBox(height: 10),
                pw.Text(reciptData['data']['vehicle_no'],
                    style: pw.TextStyle(
                      fontSize: 48,
                    )),
                pw.SizedBox(height: 10),
                pw.Text(reciptData['data']['check_in_time'],
                    style: pw.TextStyle(fontSize: 48)),
                pw.SizedBox(height: 10),
                pw.Text(reciptData['data']['entry_charge'],
                    style: pw.TextStyle(fontSize: 48)),
                pw.SizedBox(height: 10),
                pw.Text(
                    reciptData['data']['mobileno'] == null
                        ? ''
                        : reciptData['data']['mobileno'],
                    style: pw.TextStyle(fontSize: 48)),
                pw.SizedBox(height: 25),
                pw.Align(
                    alignment: pw.Alignment.bottomCenter,
                    child: pw.Text("Thank you, visit again",
                        style: pw.TextStyle(fontSize: 28))),
                pw.Expanded(
                    child: pw.Align(
                  alignment: pw.Alignment.bottomCenter,
                  child: pw.Padding(
                      padding:
                          pw.EdgeInsets.only(left: 5, right: 5, bottom: 15),
                      child: pw.Text("PARKING AT OWNER'S RISK - ONLY SPACE CHARGE",textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold))
                      ),
                ))
              ],
            ));
      },
    ),
  );
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}

class appBarButton extends StatelessWidget {
  const appBarButton({
    required this.context,
    required this.buttonText,
    required this.function,
  });
  final String buttonText;
  final Widget function;

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 20, bottom: 5),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: ThemeColorRed),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => function,
                ));
          },
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white),
          )),
    );
  }
}
