import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:samdriya/SplashScreen.dart';
import 'package:samdriya/UserLogin.dart';
import 'package:samdriya/constant.dart';
import 'package:http/http.dart' as http;
import 'package:samdriya/screen/vehicleCheckIn.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

var total = 00.00;

class Summary extends StatefulWidget {
  @override
  State<Summary> createState() => _SummaryState();
}

Map summaryData = Map();
Map summaryList = Map();

var _key;

class _SummaryState extends State<Summary> {
  double? result;
  var one, two, three;

  Future SummaryAPI() async {
    try {
      var headers = {
        'x-access-token': '$globalusertoken',
        'Cookie': 'ci_session=9db02f6e17c5ac8b5ff9545bedba8d3edee3d163'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://smalljbp.dpmstech.in/v1/account/get_vehicle_summary'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var data = await response.stream.bytesToString();
      print("api called");
      setState(() {
        summaryData = jsonDecode(data);

        print(summaryData);
      });

      if (response.statusCode == 200) {
        print('object: ${summaryData['data']['res_car']['total_amount']}');
        setState(() {
          summaryList = summaryData['data'];
          print(summaryList);
          print('total amt is -');
          var one = double.parse(
              summaryData['data']['res_bike']['total_amount'] ?? '00.00');
          print('total amt is -');
          var second = double.parse(
              summaryData['data']['res_car']['total_amount'] ?? '00.00');
          print('total amt is -');
          var three = double.parse(
              summaryData['data']['res_vip_car']['total_amount'] ?? '00.00');

          print('total amt is -');
          total = one + second + three;
          print(total);
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
  }

  void _deletetoken() async {
    print('running');
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.remove('token');
    setState(() {
      _key = key;
    });
    print('YOUR KEY - "$key"');
    print('key deleted');
  }

  @override
  void initState() {
    setState(() {
      SummaryAPI();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: BackButton(
          color: Colors.black,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 20, bottom: 5),
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
          appBarButton(
            buttonText: "Back",
            context: context,
            function: CheckINOut(),
          ),
        ],
      ),
      body: summaryData.isEmpty
          ? Center(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                Container(
                  margin:
                      EdgeInsets.only(right: 20, left: 20, top: 30, bottom: 10),
                  // ignore: unnecessary_null_comparison
                  child: summaryList != null
                      ? Table(
                          border: TableBorder.all(color: Colors.black12),
                          columnWidths: const <int, TableColumnWidth>{
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                            2: IntrinsicColumnWidth(),
                            3: IntrinsicColumnWidth(),
                            4: IntrinsicColumnWidth(),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            TableRow(
                              children: <Widget>[
                                TableHeading("S.No."),
                                TableHeading("Vehicle Type"),
                                TableHeading("Total"),
                                TableHeading("Amount"),
                                TableHeading("Total Amount"),
                              ],
                            ),
                            TableRow(
                              children: <Widget>[
                                TableData("1"),
                                TableData("Bike"),
                                TableData(summaryData['data']['res_bike']
                                            ['total_vehicle'] ==
                                        null
                                    ? '0'
                                    : summaryData['data']['res_bike']
                                        ['total_vehicle']),
                                TableData(summaryData['data']['res_bike']
                                            ['amount'] ==
                                        null
                                    ? '0'
                                    : summaryData['data']['res_bike']
                                        ['amount']),
                                TableData(
                                  summaryData['data']['res_bike']
                                              ['total_amount'] ==
                                          null
                                      ? '0'
                                      : summaryData['data']['res_bike']
                                          ['total_amount'],
                                )
                              ],
                            ),
                            TableRow(
                              children: <Widget>[
                                TableData("2"),
                                TableData("Car"),
                                TableData(summaryData['data']['res_car']
                                            ['total_vehicle'] ==
                                        null
                                    ? '0'
                                    : summaryData['data']['res_car']
                                        ['total_vehicle']),
                                TableData(summaryData['data']['res_car']
                                            ['amount'] ==
                                        null
                                    ? '0'
                                    : summaryData['data']['res_car']['amount']),
                                TableData(
                                  summaryData['data']['res_car']
                                              ['total_amount'] ==
                                          null
                                      ? '0'
                                      : summaryData['data']['res_car']
                                          ['total_amount'],
                                )
                              ],
                            ),
                            TableRow(
                              children: <Widget>[
                                TableData("3"),
                                TableData("VIP Car"),
                                TableData(summaryData['data']['res_vip_car']
                                            ['total_vehicle'] ==
                                        null
                                    ? '0'
                                    : summaryData['data']['res_vip_car']
                                        ['total_vehicle']),
                                TableData(summaryData['data']['res_vip_car']
                                            ['amount'] ==
                                        null
                                    ? '0'
                                    : summaryData['data']['res_vip_car']
                                        ['amount']),
                                TableData(
                                  summaryData['data']['res_vip_car']
                                              ['total_amount'] ==
                                          null
                                      ? '0'
                                      : summaryData['data']['res_vip_car']
                                          ['total_amount'],
                                )
                              ],
                            ),
                            TableRow(
                              children: <Widget>[
                                TableData(""),
                                TableData(""),
                                TableData(''),
                                TableData('Total Amount'),
                                TableData('${total}')
                              ],
                            ),
                          ],
                        )
                      : Text('data not found'),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColorGreen),
                    onPressed: () {
                      _generatePdf(total);
                    },
                    child: Text(
                      'Print',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
    );
  }

  Padding TableData(text) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.black87),
      ),
    );
  }

  Center TableHeading(text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }

  buttons(String s, Summary summary) {}
}

_generatePdf(total) async {
  final globletotal = total;
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final font = await PdfGoogleFonts.nunitoExtraLight();
  final headingTextStyle = await pw.TextStyle(
      color: PdfColors.black, fontWeight: pw.FontWeight.bold, fontSize: 36);
  final dataTextStyle = await pw.TextStyle(
      color: PdfColors.black, fontWeight: pw.FontWeight.bold, fontSize: 36);
  final image = await imageFromAssetBundle('assets/logo.png');
  final headingPadding = pw.EdgeInsets.symmetric(horizontal: 5, vertical: 8);
  final DataPadding = pw.EdgeInsets.symmetric(horizontal: 5, vertical: 8);

  pdf.addPage(
    pw.Page(
      pageTheme: pw.PageTheme(
        orientation: pw.PageOrientation.landscape,
      ),
      build: (context) {
        return pw.Container(
            margin: pw.EdgeInsets.only(right: 35),
            height: double.infinity,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: PdfColors.grey,
                    style: pw.BorderStyle.solid,
                    width: 1)),
            child: pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),
              children: <pw.TableRow>[
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.top,
                  children: <pw.Widget>[
                    pw.Center(
                      child: pw.Padding(
                        padding: headingPadding,
                        child: pw.Text("Vehicle Type", style: headingTextStyle),
                      ),
                    ),
                    pw.Center(
                      child: pw.Padding(
                        padding: headingPadding,
                        child: pw.Text("Total", style: headingTextStyle),
                      ),
                    ),
                    pw.Center(
                      child: pw.Padding(
                        padding: headingPadding,
                        child: pw.Text("Amount", style: headingTextStyle),
                      ),
                    ),
                    pw.Center(
                      child: pw.Padding(
                        padding: headingPadding,
                        child: pw.Text("Total Amount", style: headingTextStyle),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.top,
                  children: <pw.Widget>[
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                        "Bike",
                        style: dataTextStyle,
                      ),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                        summaryData['data']['res_bike']['total_vehicle'] == null
                            ? '0'
                            : summaryData['data']['res_bike']['total_vehicle'],
                        style: dataTextStyle,
                      ),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                        summaryData['data']['res_car']['amount'] == null
                            ? '0'
                            : summaryData['data']['res_car']['amount'],
                        style: dataTextStyle,
                      ),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                        summaryData['data']['res_bike']['total_amount'] == null
                            ? '0'
                            : summaryData['data']['res_bike']['total_amount'],
                        style: dataTextStyle,
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.top,
                  children: <pw.Widget>[
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text("Car", style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                          summaryData['data']['res_car']['total_vehicle'] ==
                                  null
                              ? '0'
                              : summaryData['data']['res_car']['total_vehicle'],
                          style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                          summaryData['data']['res_car']['amount'] == null
                              ? '0'
                              : summaryData['data']['res_car']['amount'],
                          style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                          summaryData['data']['res_car']['total_amount'] == null
                              ? '0'
                              : summaryData['data']['res_car']['total_amount'],
                          style: dataTextStyle),
                    ),
                  ],
                ),
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.top,
                  children: <pw.Widget>[
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text("VIP Car", style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                          summaryData['data']['res_vip_car']['total_vehicle'] ==
                                  null
                              ? '0'
                              : summaryData['data']['res_vip_car']
                                  ['total_vehicle'],
                          style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                          summaryData['data']['res_vip_car']['amount'] == null
                              ? '0'
                              : summaryData['data']['res_vip_car']['amount'],
                          style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text(
                          summaryData['data']['res_vip_car']['total_amount'] ==
                                  null
                              ? '0'
                              : summaryData['data']['res_vip_car']
                                  ['total_amount'],
                          style: dataTextStyle),
                    ),
                  ],
                ),
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.top,
                  children: <pw.Widget>[
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text("", style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text('', style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text('Total Amount', style: dataTextStyle),
                    ),
                    pw.Padding(
                      padding: DataPadding,
                      child: pw.Text('$globletotal', style: dataTextStyle),
                    ),
                  ],
                ),
              ],
            ));
      },
    ),
  );
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}
