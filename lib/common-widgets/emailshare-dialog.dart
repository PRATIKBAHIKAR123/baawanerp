import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/services/companyFetch.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EMailPopup extends StatefulWidget {
// Define callback function
  final String id;
  final Map<String, dynamic>? invoice;
  final InvoiceType? invoiceType;
  final int? invType;
  EMailPopup({required this.id, this.invoice, this.invType, this.invoiceType});

  @override
  _EMailPopupState createState() => _EMailPopupState();
}

class _EMailPopupState extends State<EMailPopup> {
  TextEditingController userMail = TextEditingController();
  TextEditingController ledgerName = TextEditingController();
  TextEditingController ledgerMail = TextEditingController();
  TextEditingController salespersonMail = TextEditingController();
  TextEditingController subject = TextEditingController();
  TextEditingController msg = TextEditingController();

  String currentSessionId = '';
  List<dynamic>? printReports = [];
  String? selectedReportName;
  String? reportFileName;
  Map<String, dynamic>? currentCompany;

  Uint8List? pdfBytes;

  List<Map<String, dynamic>> selectedFiles = [];

  bool isLoading = true;
  List<Map<String, dynamic>>? ledgers = [];
  int? ledgerID;
  bool isPrintBtnLoading = false;
  String? mobileNumber;
  int? printCode;

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

      getInvoiceDescription(widget.invoiceType);
    }
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();
    currentCompany = await CompanyDataUtil.getCompanyFromLocalStorage();
    Map<String, dynamic>? userData = await UserDataUtil.getUserData();
    DateTime date = DateTime.parse(widget.invoice!['date']);
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    userMail.text = userData!['email_ID'] ?? '';
    subject.text = currentCompany!['compName'] +
        ' ' +
        widget.invoice!['bill_No'] +
        formattedDate;
    await getSetupInfoData();
    prepareMsg();
    if (sessionId != null) {
      setState(() {
        currentSessionId = sessionId;

        getPrintCode();
        getLedgers();
        getPdf();
      });
      print('Loaded currentSessionId: $currentSessionId');
    } else {
      print('Session ID not found');
    }
  }

  getSetupInfoData() async {
    try {
      var requestBody = {
        "invtype": widget.invType,
        "fromInvoice": true,
        "sessionId": UserDataUtil.getSessionId()
      };

      var response = await getSetupInfoService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          printReports = decodedData['printReports'];

          selectedReportName = printReports!.firstWhere(
              (report) => report['isDefault'] == true)['reportName'];
          reportFileName = printReports!
              .firstWhere((report) =>
                  report['reportName'] == 'With Header And Footer')['fileName']
              .replaceFirst(RegExp(r'^\\+'), '');
          if (reportFileName == null) {
            reportFileName = printReports!
                .firstWhere((report) => report['isDefault'] == true)['fileName']
                .replaceFirst(RegExp(r'^\\+'), '');
          }
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
          ledgerMail.text = ledger['email'] ?? '';
        }
        print('ledger$ledger');
      });
      print('mobileNumber$mobileNumber');
    }
  }

  prepareMsg() {
    String billNumber = widget.invoice!['bill_No'];
    msg.text = '''
  Dear Sir/Madam,
  
  Kindly find the ${billNumber} attached.
  Thank you for your business.
  
  Regards,
  ${currentCompany!['compName']}
''';
  }

  void sendEmail() async {
    try {
      // Create FormData object
      FormData formData = FormData();
      // Add text fields
      formData.fields.add(MapEntry("from", userMail.text));
      formData.fields.add(MapEntry("cc", userMail.text));
      formData.fields.add(MapEntry("to", ledgerMail.text));
      formData.fields.add(MapEntry("sessionId", currentSessionId));
      formData.fields.add(MapEntry("subject", subject.text));
      formData.fields
          .add(MapEntry("message", msg.text)); // Add the message if needed

      // Add files
      for (final file in selectedFiles) {
        String filename =
            file['name']; // Assuming you have the name in the file map
        Uint8List fileBytes =
            file['file']; // Get the Uint8List from your selected files

        // Add the file to FormData
        formData.files.add(MapEntry(
          'files', // This should match the key used in Angular
          dio.MultipartFile.fromBytes(
            fileBytes,
            filename: filename,
            contentType: MediaType(
                'application', 'pdf'), // Change based on the file type
          ),
        ));
      }

      // Add headers to the request
      // var options = Options(
      //   headers: {
      //     'X-Session-ID': currentSessionId.toString(),
      //   },
      // );

      // Replace with your API endpoint
      var response = await Dio().post(
          'https://api.baawanerp.com/api/Invoice/SendEmail',
          data: formData);

      if (response.statusCode == 200) {
        // Handle successful response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email Sent Successfully"),
          ),
        );
      } else {
        // Handle error response
        print('Error: ${response.data}');
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

  getPdf() async {
    try {
      var requestBody = {
        "id": int.tryParse(widget.id),
        "invType": widget.invType,
        "reportName": reportFileName,
        "sessionId": currentSessionId
      };

      var response = await getInvoicePdfService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          pdfBytes = response.bodyBytes;

          isLoading = false;
        });

        // Get the bytes of the file
        Uint8List fileBytes = response.bodyBytes;

        // You can create a File from bytes if needed (this requires the path_provider and other packages)
        // final file = File('${(await getTemporaryDirectory()).path}/$filename');
        // await file.writeAsBytes(fileBytes);

        // Store the file or handle it as needed
        selectedFiles = [];
        selectedFiles.add({
          'name': widget
              .invoice!['bill_No'], // Use the filename extracted or default
          'file': dio.MultipartFile.fromBytes(
            fileBytes,
            filename: widget.invoice!['bill_No'],
            contentType: MediaType(
                'application', 'pdf'), // Change based on the file type
          ),
        });
        print('selectedFiles$selectedFiles');
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

  String encodeData(int? printCode, int companyId) {
    String dataToEncrypt = 'printCode=$printCode&companyId=$companyId';

    // Step 2: Base64 encode the data string
    String base64Encoded = base64Encode(utf8.encode(dataToEncrypt));

    // Step 3: Remove any non-alphanumeric characters (including padding '=')
    String result = base64Encoded.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return result;
  }

  // getSalesPersonMail(salesPersonId) async {
  //   try {
  //     var requestBody = {"id": salesPersonId, "sessionId": currentSessionId};

  //     var response = await getSalesPersonService(requestBody);

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         var decodedData = jsonDecode(response.body);
  //         salespersonMail.text = decodedData['email_ID'];
  //       });
  //     } else {
  //       print('Error: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Something Went Wrong"),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Email', style: TextStyle(fontSize: 20)),
      content: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height, // Set a specific height
        child: Column(
          children: [
            TextFormField(
              controller: userMail,
              decoration: InputDecoration(
                hintText: 'From',
                label: Text('From'),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: ledgerMail,
              decoration: InputDecoration(
                hintText: 'To',
                label: Text('To'),
              ),
            ),
            SizedBox(height: 10),
            // TextFormField(
            //   controller: salespersonMail,
            //   decoration: InputDecoration(
            //     hintText: 'CC',
            //     label: Text('CC'),
            //   ),
            // ),
            // SizedBox(height: 10),
            TextFormField(
              controller: subject,
              decoration: InputDecoration(
                hintText: 'Subject',
                label: Text('Subject'),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: msg,
              decoration: InputDecoration(
                hintText: 'Message',
                label: Text('Message'),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 5),
            SizedBox(
              child: Text('Attached Files'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];
                  return ListTile(
                    title: Text('${file['name']}.PDF' ?? 'Unnamed file'),
                    subtitle: Text(
                        'Size: ${file['file'].length} bytes'), // Length of MultipartFile
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (true) {
              sendEmail();
            } // Return true
            Navigator.of(context).pop(true);
          },
          child: Text('Send'),
        ),
      ],
    );
  }
}
