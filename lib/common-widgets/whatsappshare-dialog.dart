import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

class WhatsAppPopup extends StatefulWidget {
// Define callback function
  final String id;
  final Map<String, dynamic>? invoice;
  final InvoiceType? invoiceType;
  final int? invType;
  WhatsAppPopup(
      {required this.id, this.invoice, this.invType, this.invoiceType});

  @override
  _WhatsAppPopupState createState() => _WhatsAppPopupState();
}

class _WhatsAppPopupState extends State<WhatsAppPopup> {
  TextEditingController ledgerName = TextEditingController();
  TextEditingController ledgerPhone = TextEditingController();

  String currentSessionId = '';
  List<dynamic>? printReports = [];
  String? selectedReportName;
  String? reportFileName;

  Uint8List? pdfBytes;

  bool isLoading = true;
  List<Map<String, dynamic>>? ledgers = [];
  int? ledgerID;
  bool isPrintBtnLoading = false;
  String? mobileNumber;
  int? printCode;
  String? shortedUrl;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    loadSessionId();
    if (widget.invoice != null) {
      loadSessionId();
      ledgerID = widget.invoice!['ledger_ID'];
      print('widget.invoice${widget.invoice}');
      getInvoice();
      getLedgers();
      getInvoiceDescription(widget.invoiceType);
    }
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    if (sessionId != null) {
      setState(() async {
        currentSessionId = sessionId;
        await getSetupInfoData();
        getPrintCode();
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
  }

  getSetupInfoData() async {
    try {
      var requestBody = {
        "invtype": widget.invType,
        "fromInvoice": true,
        "sessionId": currentSessionId
      };

      var response = await getSetupInfoService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          printReports = decodedData['printReports'];

          selectedReportName = printReports!.firstWhere(
              (report) => report['isDefault'] == true)['reportName'];
          reportFileName = printReports!
              .firstWhere((report) => report['isDefault'] == true)['fileName']
              .replaceFirst(RegExp(r'^\\+'), '');
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  String getInvoiceDescription(InvoiceType? invoiceType) {
    return InvoiceVoucherTypesObjByte[invoiceType] ?? 'Unknown Invoice Type';
  }

  getLedgers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      setState(() {
        ledgers = ledgerList
            .map((item) => jsonDecode(item) as Map<String, dynamic>)
            .toList();
        Map<String, dynamic>? ledger = ledgers?.firstWhere(
          (ledger) => ledger['id'] == ledgerID,
          orElse: () => {},
        );

        if (ledger != null) {
          mobileNumber = ledger['mobile'];
          ledgerPhone.text = ledger['mobile'] ?? '';
          ledgerName.text = ledger['name'] ?? '';
        }
        print('ledger$ledger');
      });
      print('mobileNumber$mobileNumber');
    }
  }

  Future<void> shareOnWhatsApp() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/invoice_$mobileNumber.pdf');
    await file.writeAsBytes(pdfBytes!);
    String shortenedUrl = encodeData();
    final String phoneNumber = ledgerPhone.text;

    String invTypeText = getInvoiceDescription(widget.invoiceType);
    String name = widget.invoice!['partyName'];
    String billNumber = widget.invoice!['bill_No'];
    DateTime date = DateTime.parse(widget.invoice!['date']);
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    String amount = CurrencyFormatter.format(widget.invoice!['grandTotal']);

    // await shortUrl('http://104.211.141.224:5253/?print=$shortenedUrl');
    String documentLink = shortedUrl ?? '';
    print('shortenedUrl$shortedUrl');

    String text = '''
$invTypeText
*$name*
Bill Number: $billNumber
Date: $formattedDate
Amount: $amount

Document Link: $documentLink
'''
//Document Link: $documentLink
        ;

    try {
      // Save the PDF bytes to a file in the temporary directory
      // final tempDir = await getTemporaryDirectory();
      // final file = File('${tempDir.path}/invoice.pdf');
      // await file.writeAsBytes(pdfBytes!);

      // First, launch WhatsApp with a pre-filled message to the specific number
      String whatsappUrl =
          'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(text)}';
      await launchUrlString(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice for $mobileNumber',
      );
    } catch (e) {
      print('Error sharing PDF via WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while sharing"),
        ),
      );
    }
  }

  getPrintCode() async {
    try {
      var requestBody = {
        "invCode": widget.invoice!['invCode'],
        "sessionId": currentSessionId
      };

      var response = await getInvoicePrintCode(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          printCode = decodedData['printCode'];
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  shortUrl(String url) async {
    try {
      var requestBody = {
        "url": url,
      };

      var response = await shortenUrlString(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          shortedUrl = jsonDecode(response.body);
        });
        print('shortenUrlError: ${response}');
      } else {
        print('shortenUrlError: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  String encodeData() {
    var invCode = widget.id;
    var invType = widget.invType;
    String dataToEncrypt = 'id=$invCode&invType=$invType';

    // Step 2: Base64 encode the data string
    String base64Encoded = base64Encode(utf8.encode(dataToEncrypt));

    // Step 3: Remove any non-alphanumeric characters (including padding '=')
    String result = base64Encoded.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return result;
  }

  getInvoice() async {
    setState(() {
      isLoading = true;
    });
    final Map<String, dynamic> jsonBody = {
      "id": widget.id,
      "invType": widget.invType,
      "reportName": reportFileName,
      "sessionId": currentSessionId
    };
    var client = http.Client();
    try {
      http.Response response = await client
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 50));

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          pdfBytes = response.bodyBytes;
          isLoading = false;
        });
      } else {
        print('Error: ${response.body}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something Went Wrong"),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Whatsapp', style: TextStyle(fontSize: 20)),
      content: Container(
          height: 140,
          child: Column(
            children: [
              TextFormField(
                controller: ledgerName,
                decoration: InputDecoration(
                  hintText: 'Recepient',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: ledgerPhone,
                decoration: InputDecoration(
                  hintText: 'Phone',
                ),
              ),
            ],
          )),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            if (true) {
              shareOnWhatsApp();
            } // Return true
          },
          child: Text('Send'),
        ),
      ],
    );
  }
}
