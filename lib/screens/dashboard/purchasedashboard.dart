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

class PurchaseDashboardScreen extends StatefulWidget {
  @override
  State<PurchaseDashboardScreen> createState() =>
      _PurchaseDashboardScreenState();
}

class _PurchaseDashboardScreenState extends State<PurchaseDashboardScreen> {
  int _selectedIndex = 2;
  String activeLink = '1';
  final List<Map<String, dynamic>> quickLinks = [
    {
      'id': '1',
      'name': 'Purchase Order',
      'icon': 'assets/icons/purchase order.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.purchaseOrder)
    },
    {
      'id': '2',
      'name': 'Goods Receipt',
      'icon': 'assets/icons/goods receipt.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.purchaseChallan)
    },
    {
      'id': '3',
      'name': 'Purchase Invoice',
      'icon': 'assets/icons/purchase invoice.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.purchaseInvoice)
    },
    {
      'id': '4',
      'name': 'Purchase Return',
      'icon': 'assets/icons/purchase return.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.purchaseReturn)
    },
    {
      'id': '5',
      'name': 'Costing',
      'icon': 'assets/icons/costing.png',
      'screen': ProformaInvoiceScreen(invoiceType: InvoiceType.costing)
    },
    {
      'id': '6',
      'name': 'Goods Receipt Return',
      'icon': 'assets/icons/goods receipt return.png',
      'screen':
          ProformaInvoiceScreen(invoiceType: InvoiceType.purchaseChallanReturn)
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
