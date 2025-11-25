import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/common-widgets/searchStats.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/sales/salesEnquiry.dart';
import 'package:mlco/screens/sales/salesInvoice.dart';
import 'package:mlco/screens/sales/salesOrder.dart';
import 'package:mlco/screens/sales/salesProformaInvoice.dart';
import 'package:mlco/screens/sales/salesQuatation.dart';
import 'package:mlco/screens/sales/salesReturn.dart';

class SalesDashboardScreen extends StatefulWidget {
  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  int _selectedIndex = 1;
  String activeLink = '1';
  final List<Map<String, dynamic>> quickLinks = [
    {
      'id': '1',
      'name': 'Sales Invoice',
      'icon': 'assets/icons/file-invoice.png',
      'screen': SalesInvoiceScreen(invoiceType: InvoiceType.salesInvoice)
    },
    {
      'id': '2',
      'name': 'Sales Quotation',
      'icon': 'assets/icons/sales quotation.png',
      'screen': SalesQuotationScreen()
    },
    {
      'id': '3',
      'name': 'Sales Order',
      'icon': 'assets/icons/sales order (1).png',
      'screen': SalesOrderScreen()
    },
    {
      'id': '4',
      'name': 'Sales Enquiry',
      'icon': 'assets/icons/sales enquiry.png',
      'screen': SalesEnquiryScreen()
    },
    {
      'id': '5',
      'name': 'Sales Return',
      'icon': 'assets/icons/sales return.png',
      'screen': SalesReturnScreen()
    },
    {
      'id': '6',
      'name': 'Proforma Invoice',
      'icon': 'assets/icons/Proforma Invoice.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.performaInvoice)
    },
    {
      'id': '7',
      'name': 'Dispatch Note',
      'icon': 'assets/icons/dispatch note.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.salesChalan)
    },
    {
      'id': '8',
      'name': 'Dispatch Note Return',
      'icon': 'assets/icons/dispatch note return.png',
      'screen':
          ProformaInvoiceScreen(invoiceType: InvoiceType.salesChallanReturn)
    },
    {
      'id': '9',
      'name': 'Cancel Document',
      'icon': 'assets/icons/cancel document.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.cancelDocument)
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onQuickLinkTapped(Map<String, dynamic> link) {
    setState(() {
      activeLink = link['id'];
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => link['screen']),
    );
  }

  Widget createSubmenuItem({
    required String text,
    required VoidCallback onTap,
    required String icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            horizontal: 8.0, vertical: 4.0), // Optional padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 20),
            SizedBox(width: 5),
            // Use Flexible to allow the text to wrap
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                softWrap: true, // Allow wrapping of the text
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: SearchStat(),
              ),
              SizedBox(height: 20),
              Text(
                'Quick Links',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 500, // Set a fixed height
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: quickLinks.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of items per row
                      mainAxisSpacing: 10.0, // Spacing between rows
                      crossAxisSpacing: 10.0, // Spacing between columns
                      childAspectRatio:
                          1, // Adjust this ratio to control the height of grid items
                      mainAxisExtent: 50),
                  itemBuilder: (context, index) {
                    final link = quickLinks[index];
                    return GestureDetector(
                      onTap: () => _onQuickLinkTapped(link),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: link['id'] == activeLink
                              ? mlcoGradient2
                              : inactivelinksgradient,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: createSubmenuItem(
                          text: link['name'],
                          onTap: () => _onQuickLinkTapped(link),
                          icon: link['icon'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
