import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/voucherTypes.dart';
import 'package:mlco/services/invoiceService.dart';
import 'package:mlco/services/pdfPrintService.dart';
import 'package:mlco/services/permissionService.dart';
import 'package:mlco/services/sessionIdFetch.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InvoiceDialog extends StatefulWidget {
  final String? sessionId;
  final String id;
  final int? invType;
  final Map<String, dynamic>? invoice;
  final InvoiceType? invoiceType;
  final VoucherType? voucherType;

  InvoiceDialog(
      {this.sessionId,
      required this.id,
      this.invType,
      this.invoice,
      this.invoiceType,
      this.voucherType});

  @override
  State<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<InvoiceDialog> {
  final ButtonStyle btnStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.only(left: 10, right: 10),
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );

  final TextStyle btnText = TextStyle(color: Colors.white, fontSize: 10);

  final String url = 'https://print.baawanerp.com/api/Print/PrintInvoice';
  Uint8List? pdfBytes;
  bool isLoading = false;
  bool isPrintBtnLoading = false;
  String? mobileNumber;
  int? printCode;
  String? shortedUrl;
  List<Map<String, dynamic>>? ledgers = [];
  int? ledgerID;
  TextEditingController ledgerName = TextEditingController();
  TextEditingController ledgerPhone = TextEditingController();
  Map<String, dynamic> setupInfoData = {};
  String currentSessionId = '';
  List<dynamic>? printReports = [];
  List<dynamic>? printTemplates = [];
  String? selectedReportName;
  String? reportFileName;
  final PdfPrintService _pdfService = PdfPrintService();

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      ledgerID = widget.invoice!['ledger_ID'];
      print('widget.invoice${widget.invoice}');
      loadSessionId();
      getLedgers();

      getInvoiceDescription(widget.invoiceType);
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
        if (selectedReportName != null) {
          var responseData = await getInvoiceService({
            "id": widget.id,
            "invType": widget.invType,
            "sessionId": currentSessionId
          });
          var recordData = jsonDecode(responseData.body);
          final templateData =
              _pdfService.convertToTemplateData(recordData, reportFileName!);

          // Attempt to find a matching template from printTemplates in a Dart-compatible way.
          Map<String, dynamic>? template;
          if (printTemplates != null && printTemplates!.isNotEmpty) {
            try {
              template = printTemplates!.firstWhere(
                (t) =>
                    t is Map<String, dynamic> &&
                    t['name'] == selectedReportName,
                orElse: () => null,
              ) as Map<String, dynamic>?;
            } catch (e) {
              template = null;
            }
          }

          if (template != null) {
            final Map<String, dynamic> templateConfig =
                json.decode(template['templateJson']);

            // Generate PDF
            pdfBytes = await _pdfService.generatePdfFromTemplate(
              templateConfig,
              templateData,
            );
            setState(() {
              isLoading = false;
            });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return buildInvoice();
              },
            );

            // Save and open PDF
            //await _savePdfAndOpen(pdfBytes, recordData['bill_No'] ?? 'invoice');
          }
        }
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    if (sessionId != null) {
      setState(() {
        isLoading = true;
        currentSessionId = sessionId;
        getSetupInfoData();
        getPrintTemplate();
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
  }

  String getInvoiceDescription(InvoiceType? invoiceType) {
    return InvoiceVoucherTypesObjByte[invoiceType] ?? 'Unknown Invoice Type';
  }

  getPrintTemplate() async {
    try {
      var requestBody = {"type": "", "sessionId": currentSessionId};

      var response = await getPrintingTemplatesService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          printTemplates = decodedData['list'];
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  Future<void> _savePdfAndOpen(Uint8List pdfBytes, String fileName) async {
    try {
      // Get the directory for saving
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/$fileName.pdf';
      final File file = File(path);

      // Write PDF to file
      await file.writeAsBytes(pdfBytes);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to: $path'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(path),
          ),
        ),
      );

      // Automatically open the PDF
      await OpenFile.open(path);
    } catch (e) {
      print('Error saving PDF: $e');
    }
  }

  whatsappShare() async {
    bool? result = await showConfirmationDialog(context);
    if (result == true) {
      shareOnWhatsApp();
    } else {}
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
          mobileNumber = ledger['mobile'] ?? '';
          ledgerPhone.text = ledger['mobile'] ?? '';
          ledgerName.text = ledger['name'] ?? '';
        }
        print('ledger$ledger');
      });
      print('mobileNumber$mobileNumber');
    }

    // Trigger a rebuild to update the UI
  }

  Future<void> shareOnWhatsApp() async {
    String shortenedUrl = encodeData();
    final String phoneNumber = ledgerPhone.text;

    String invTypeText = getInvoiceDescription(widget.invoiceType);
    String name = widget.invoice!['partyName'];
    String billNumber = widget.invoice!['bill_No'];
    DateTime date = DateTime.parse(widget.invoice!['date']);
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    String amount = widget.invoice!['grandTotal'].toString();

    await shortUrl('http://104.211.141.224:5253/?print=$shortenedUrl');
    String documentLink = shortedUrl ?? '';

    String text = '''
$invTypeText
*$name*
Bill Number: $billNumber
Date: $formattedDate
Amount: $amount


'''
//Document Link: $documentLink
        ;

    try {
      // Save the PDF bytes to a file in the temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice.pdf');
      await file.writeAsBytes(pdfBytes!);

      // First, launch WhatsApp with a pre-filled message to the specific number
      String whatsappUrl =
          'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(text)}';
      await launchUrlString(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
      // if (await canLaunchUrlString(whatsappUrl)) {
      //   await launchUrlString(
      //     whatsappUrl,
      //     mode: LaunchMode.externalApplication,
      //   );

      //   // // After launching WhatsApp, let the user attach the file manually
      //   // await Future.delayed(
      //   //     Duration(seconds: 2)); // Give WhatsApp time to open

      //   // await Share.shareXFiles([XFile(file.path)], text: message);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text("WhatsApp is not installed"),
      //     ),
      //   );
      // }
    } catch (e) {
      print('Error sharing PDF via WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while sharing"),
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

  Future<bool?> showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
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
                Navigator.of(context).pop(true); // Return true
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
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

  Future<void> _shareOnWhatsApp() async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice.pdf');

      // Write PDF bytes to file
      await file.writeAsBytes(pdfBytes!);

      // Share PDF file
      await Share.shareXFiles([XFile(file.path)],
          text: 'Check out this invoice');
    } catch (e) {
      print('Error sharing PDF: $e');
    }
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return buildInvoice();
            },
          );
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

  Future<void> _downloadPdf() async {
    try {
      await requestStoragePermission();
      // Get the Downloads directory
      final Directory? downloadsDir =
          await Directory('/storage/emulated/0/Download');
      if (downloadsDir == null) {
        throw Exception('Unable to access Downloads directory');
      }

      // Generate timestamp
      final now = DateTime.now();
      final formatter =
          DateFormat('yyyyMMdd_HHmmss'); // Define your date format
      final timestamp = formatter.format(now);

      // Define the file path with timestamp and create the file
      final String downloadPath =
          path.join(downloadsDir.path, 'invoice_$timestamp.pdf');
      final File file = File(downloadPath);

      // Write PDF bytes to file
      await file.writeAsBytes(pdfBytes!);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Invoice downloaded successfully to $downloadPath')),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF')),
      );
    }
  }

  submitPrint() async {
    setState(() {
      isPrintBtnLoading = true;
    });
    await getInvoice();
    setState(() {
      isPrintBtnLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      backgroundColor: const Color.fromARGB(255, 192, 191, 191),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 649,
        child: Column(
          children: <Widget>[
            Center(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Text('No PDF available')),
          ],
        ),
      ),
    );
  }

  Widget buildInvoice() {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      backgroundColor: const Color.fromARGB(255, 192, 191, 191),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 649,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/icons/Close.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SfPdfViewerTheme(
                  data: SfPdfViewerThemeData(backgroundColor: Colors.white),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : pdfBytes != null
                          ? SfPdfViewer.memory(pdfBytes!)
                          : Center(child: Text('No PDF available'))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                        gradient: mlcoGradient,
                        borderRadius: BorderRadius.circular(5)),
                    child: ElevatedButton(
                      onPressed: () {
                        _downloadPdf();
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/DocumentDownload.png',
                            color: Colors.white,
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Download',
                            style: btnText,
                          )
                        ],
                      ),
                      style: btnStyle,
                    )),
                // Container(
                //     decoration: BoxDecoration(
                //         gradient: mlcoGradient,
                //         borderRadius: BorderRadius.circular(5)),
                //     child: ElevatedButton(
                //       onPressed: () {},
                //       child: Row(
                //         children: [
                //           Image.asset(
                //             'assets/icons/Printer.png',
                //             color: Colors.white,
                //             width: 24,
                //             height: 24,
                //           ),
                //           SizedBox(
                //             width: 8,
                //           ),
                //           Text(
                //             'Print Invoice',
                //             style: btnText,
                //           )
                //         ],
                //       ),
                //       style: btnStyle,
                //     )),
                const SizedBox(
                  width: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                      gradient: mlcoGradient,
                      borderRadius: BorderRadius.circular(5)),
                  child: ElevatedButton(
                    onPressed: whatsappShare,
                    style: btnStyle,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/whatsapp.png', // Add your WhatsApp icon here
                          color: Colors.white,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Share',
                          style: btnText,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
