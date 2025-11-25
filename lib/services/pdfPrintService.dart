// pdf_print_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

class PdfPrintService {
  int precision = 2;
  Map<String, dynamic>? currentCompany;

  PdfPrintService({this.currentCompany, this.precision = 2});

  // Format number with precision
  String formatNumVal(dynamic value) {
    if (value == null) return '0.00';
    double num =
        value is double ? value : double.tryParse(value.toString()) ?? 0;
    return num.toStringAsFixed(precision);
  }

  String formatQtyVal(dynamic value) {
    if (value == null) return '0.00';
    double num =
        value is double ? value : double.tryParse(value.toString()) ?? 0;
    return num.toStringAsFixed(2);
  }

  String formatDate(String? dateValue) {
    if (dateValue == null || dateValue.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateValue);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  String formatCurrency(dynamic value) {
    if (value == null) return '0.00';
    double num =
        value is double ? value : double.tryParse(value.toString()) ?? 0;
    return num.toStringAsFixed(2);
  }

  // Load image from assets
  Future<Uint8List> loadImageFromAssets(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Error loading image: $e');
      rethrow;
    }
  }

  // Convert number to words (simplified version)
  String numberToWords(double number) {
    if (number == 0) return 'Zero';

    final units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    int intPart = number.floor();
    int decimalPart = ((number - intPart) * 100).round();

    String result = '';

    if (intPart >= 1000000) {
      int millions = intPart ~/ 1000000;
      result += '${units[millions]} Million ';
      intPart %= 1000000;
    }

    if (intPart >= 1000) {
      int thousands = intPart ~/ 1000;
      if (thousands >= 100) {
        result += '${units[thousands ~/ 100]} Hundred ';
        thousands %= 100;
      }
      if (thousands >= 20) {
        result += '${tens[thousands ~/ 10]} ';
        thousands %= 10;
      }
      if (thousands >= 10) {
        result += '${teens[thousands - 10]} ';
        thousands = 0;
      }
      if (thousands > 0) {
        result += '${units[thousands]} ';
      }
      result += 'Thousand ';
      intPart %= 1000;
    }

    if (intPart >= 100) {
      result += '${units[intPart ~/ 100]} Hundred ';
      intPart %= 100;
    }

    if (intPart >= 20) {
      result += '${tens[intPart ~/ 10]} ';
      intPart %= 10;
    }

    if (intPart >= 10) {
      result += '${teens[intPart - 10]} ';
      intPart = 0;
    }

    if (intPart > 0) {
      result += '${units[intPart]} ';
    }

    if (decimalPart > 0) {
      result += 'and ${decimalPart}/100';
    }

    return result.trim();
  }

  // Main PDF generation method
  Future<Uint8List> generatePdfFromTemplate(
    Map<String, dynamic> templateConfig,
    Map<String, dynamic> data,
  ) async {
    final pdf = pw.Document();

    // Load company logo if specified
    pw.ImageProvider? companyLogo;
    if (templateConfig['header']?['sections'] != null) {
      for (var section in templateConfig['header']['sections']) {
        if (section['type'] == 'image' && section['source'] != null) {
          try {
            final imageBytes =
                await loadImageFromAssets('assets/images/${section['source']}');
            companyLogo = pw.MemoryImage(imageBytes);
          } catch (e) {
            print('Error loading logo: $e');
          }
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) {
          List<pw.Widget> content = [];

          // 1. Build Header
          if (templateConfig['header'] != null) {
            content
                .add(_buildHeader(templateConfig['header'], data, companyLogo));
          }

          // 2. Build Invoice Meta Section
          if (templateConfig['invoiceMeta'] != null) {
            content.add(_buildInvoiceMeta(templateConfig['invoiceMeta'], data));
          }

          // 3. Build Customer Section
          if (templateConfig['customerSection'] != null) {
            content.add(
                _buildCustomerSection(templateConfig['customerSection'], data));
          }

          // 4. Build Items Table
          if (templateConfig['itemsTable'] != null && data['items'] != null) {
            content.add(_buildItemsTable(templateConfig['itemsTable'], data));
          }

          // 5. Build Totals Section
          // if (templateConfig['totalsSection'] != null) {
          //   content.add(
          //       _buildTotalsSection(templateConfig['totalsSection'], data));
          // }

          // // 6. Build Grand Total Section
          // if (templateConfig['grandTotalSection'] != null) {
          //   content.add(_buildGrandTotalSection(
          //       templateConfig['grandTotalSection'], data));
          // }

          // content.add(pw.SizedBox(height: 10));

          // // 7. Build Footer Section
          // if (templateConfig['footerSection'] != null) {
          //   content.add(
          //       _buildFooterSection(templateConfig['footerSection'], data));
          // }

          // // 8. Add Page Footer
          // if (templateConfig['pageFooter'] != null) {
          //   content.add(
          //     pw.Align(
          //       alignment: pw.Alignment.centerRight,
          //       child: pw.Text(
          //         templateConfig['pageFooter']['text'] ?? '',
          //         style: pw.TextStyle(fontSize: 8),
          //       ),
          //     ),
          //   );
          // }

          return content;
        },
      ),
    );

    return pdf.save();
  }

  // Build Header
  pw.Widget _buildHeader(
    Map<String, dynamic> headerConfig,
    Map<String, dynamic> data,
    pw.ImageProvider? logo,
  ) {
    List<pw.Widget> headerCells = [];
    List<dynamic> sections = headerConfig['sections'] ?? [];

    for (var section in sections) {
      if (section['type'] == 'image' && logo != null) {
        headerCells.add(
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Image(logo, width: 150, height: 100),
          ),
        );
      } else if (section['type'] == 'stack') {
        List<pw.Widget> stackItems = [];
        for (var item in section['items'] ?? []) {
          String text = item['field'] != null
              ? (data[item['field']] ?? '')
              : (item['text'] ?? '');
          stackItems.add(
            pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: item['fontSize']?.toDouble() ?? 10,
                fontWeight: item['bold'] == true
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          );
        }
        headerCells.add(pw.Column(children: stackItems));
      } else if (section['type'] == 'text') {
        headerCells.add(
          pw.Container(
            margin: pw.EdgeInsets.only(top: 50),
            child: pw.Text(
              section['text'] ?? '',
              style: pw.TextStyle(
                fontSize: section['fontSize']?.toDouble() ?? 18,
                fontWeight: section['bold'] == true
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
              textAlign: _getAlignment(section['alignment']),
            ),
          ),
        );
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(children: headerCells),
      ],
    );
  }

  // Build Invoice Meta
  pw.Widget _buildInvoiceMeta(
    Map<String, dynamic> metaConfig,
    Map<String, dynamic> data,
  ) {
    List<pw.Widget> metaCells = [];
    List<dynamic> sections = metaConfig['sections'] ?? [];

    for (var section in sections) {
      List<pw.Widget> stackItems = [];
      for (var item in section['items'] ?? []) {
        String text = '';
        if (item['label'] != null && item['field'] != null) {
          text = '${item['label']} ${data[item['field']] ?? ''}';
        } else if (item['label'] != null) {
          text = item['label'];
        } else {
          text = item['text'] ?? '';
        }

        stackItems.add(
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: item['fontSize']?.toDouble() ?? 9,
                fontWeight: item['bold'] == true
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        );
      }
      metaCells.add(pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: stackItems));
    }

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Table(
        border: pw.TableBorder.all(),
        children: [
          pw.TableRow(children: metaCells),
        ],
      ),
    );
  }

  // Build Customer Section
  pw.Widget _buildCustomerSection(
    Map<String, dynamic> customerConfig,
    Map<String, dynamic> data,
  ) {
    List<pw.TableRow> rows = [];

    // Headers
    List<pw.Widget> headerCells = [];
    for (var header in customerConfig['headers'] ?? []) {
      headerCells.add(
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            header,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    }
    rows.add(pw.TableRow(children: headerCells));

    // Customer details
    List<pw.Widget> detailCells = [];
    for (var field in customerConfig['fields'] ?? []) {
      String name = data[field['field']] ?? '-';
      String address = data[field['address']] ?? '--';
      detailCells.add(
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text('$name\n$address'),
        ),
      );
    }
    rows.add(pw.TableRow(children: detailCells));

    // TRN
    List<pw.Widget> trnCells = [];
    for (var field in customerConfig['trn']['fields'] ?? []) {
      trnCells.add(
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            '${customerConfig['trn']['label']} ${data[field] ?? ''}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
      );
    }
    rows.add(pw.TableRow(children: trnCells));

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Table(
        border: pw.TableBorder.all(),
        children: rows,
      ),
    );
  }

  // Build Items Table
  pw.Widget _buildItemsTable(
    Map<String, dynamic> itemsConfig,
    Map<String, dynamic> data,
  ) {
    List<pw.TableRow> rows = [];

    // Headers
    List<pw.Widget> headerCells = [];
    for (var header in itemsConfig['headers'] ?? []) {
      headerCells.add(
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            header,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    }
    rows.add(pw.TableRow(children: headerCells));

    // Items
    List<dynamic> items = data['items'] ?? [];
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      List<pw.Widget> rowCells = [];

      for (var col in itemsConfig['columns'] ?? []) {
        dynamic value;

        if (col['type'] == 'index') {
          value = (i + 1).toString();
        } else if (col['calculate'] != null) {
          // Handle calculated fields
          double taxAmount = (item['amount'] * item['vatPer']) / 100;

          if (col['calculate'] == '(amount * vatPer) / 100') {
            value = taxAmount;
          } else if (col['calculate'] == 'amount + taxAmount') {
            value = item['amount'] + taxAmount;
          } else if (col['calculate'] == 'std_Rate + (taxAmount / std_Qty)') {
            value = item['std_Rate'] + (taxAmount / item['std_Qty']);
          }

          if (col['format'] == 'currency') {
            value = formatCurrency(value);
          }
        } else {
          value = item[col['field']] ?? '';
          if (col['format'] == 'currency') {
            value = formatCurrency(value);
          }
        }

        rowCells.add(
          pw.Container(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(
              value.toString(),
              style: pw.TextStyle(fontSize: 8),
              textAlign: _getAlignment(col['alignment']),
            ),
          ),
        );
      }

      rows.add(pw.TableRow(children: rowCells));
    }

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Table(
        border: pw.TableBorder.all(),
        children: rows,
      ),
    );
  }

  // Build Totals Section
  pw.Widget _buildTotalsSection(
    Map<String, dynamic> totalsConfig,
    Map<String, dynamic> data,
  ) {
    List<pw.TableRow> rows = [];

    for (var row in totalsConfig['rows'] ?? []) {
      String value = '';
      if (row['field'] != null && data[row['field']] != null) {
        value = row['format'] == 'currency'
            ? formatCurrency(data[row['field']])
            : data[row['field']].toString();
      }

      rows.add(
        pw.TableRow(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text(row['note'] ?? ''),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text(
                row['label'] ?? '',
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text(
                value,
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Table(
        border: pw.TableBorder.all(),
        children: rows,
      ),
    );
  }

  // Build Grand Total Section
  pw.Widget _buildGrandTotalSection(
    Map<String, dynamic> gtConfig,
    Map<String, dynamic> data,
  ) {
    double finalAmount = data[gtConfig['total']['field']]?.toDouble() ?? 0.0;

    if (gtConfig['total']['adjustField'] != null) {
      double adjustment =
          data[gtConfig['total']['adjustField']]?.toDouble() ?? 0.0;
      finalAmount = gtConfig['total']['operation'] == 'subtract'
          ? finalAmount - adjustment
          : finalAmount + adjustment;
    }

    String amountInWords = numberToWords(finalAmount);

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Table(
        border: pw.TableBorder.all(),
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(
                  '${gtConfig['amountInWords']['label']} $amountInWords',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(
                  gtConfig['total']['label'] ?? '',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(
                  formatCurrency(finalAmount),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Footer Section
  pw.Widget _buildFooterSection(
    Map<String, dynamic> footerConfig,
    Map<String, dynamic> data,
  ) {
    List<pw.TableRow> rows = [];

    // Row 1
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(
              footerConfig['disclaimer']?['text'] ?? '',
              style: pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(
              footerConfig['signature']?['company'] ?? '',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );

    // Row 2
    List<pw.Widget> bankDetailsStack = [];
    bankDetailsStack.add(
      pw.Text(
        footerConfig['bankDetails']?['header'] ?? '',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      ),
    );

    for (var detail in footerConfig['bankDetails']?['details'] ?? []) {
      bankDetailsStack.add(
        pw.Text(detail, style: pw.TextStyle(fontSize: 8)),
      );
    }

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: bankDetailsStack,
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.only(top: 30, right: 5, bottom: 5),
            child: pw.Text(
              footerConfig['signature']?['authorized'] ?? '',
              style: pw.TextStyle(fontSize: 8),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(),
      children: rows,
    );
  }

  // Helper to get text alignment
  pw.TextAlign _getAlignment(String? alignment) {
    switch (alignment) {
      case 'center':
        return pw.TextAlign.center;
      case 'right':
        return pw.TextAlign.right;
      case 'left':
      default:
        return pw.TextAlign.left;
    }
  }

  // Convert invoice data to template format
  Map<String, dynamic> convertToTemplateData(
    Map<String, dynamic> data,
    String templateType,
  ) {
    return {
      'templateType': templateType,
      'companyName': 'Commhawk Trading LLC',
      'companyAddress1':
          'Shop No. 3, Al Mehri Building, Satellite Market ,Naif',
      'companyAddress2': 'Dubai,U.A.E',
      'companyPhone': 'T : +971 4 2561415 , M : +971 58 5929352',
      'companyEmail': 'info@commhawkglobal.com www.commhawkglobal.com',
      'companyTRN': 'TRN : 104489107300001',
      'poNo': data['poNo'] ?? '',
      'poDate': formatDate(data['poDate']),
      'dcNo': data['dcNo'] ?? '',
      'dcDate': formatDate(data['dcDate']),
      'salesBy': data['salesBy'] ?? '',
      'invoiceNo': data['bill_No'],
      'invoiceDate': formatDate(data['date']),
      'billToName': data['ledger']?['name'] ?? '',
      'billToAddress': data['ledger']?['address'] ?? '',
      'billToTRN': data['ledger']?['gstNo'] ?? '',
      'shipToName': data['shipToName'] ?? '',
      'shipToAddress':
          data['shipToAddress'] ?? data['ledger']?['address'] ?? '',
      'shipToTRN': data['ledger']?['gstNo'] ?? '',
      'items': data['invoiceItemDetail'] ?? [],
      'item_SubTotal': data['item_SubTotal'],
      'extra_SubTotal': data['extra_SubTotal'],
      'grandTotal': data['grandTotal'],
      'roundOff': data['roundOff'] ?? 0,
    };
  }
}
