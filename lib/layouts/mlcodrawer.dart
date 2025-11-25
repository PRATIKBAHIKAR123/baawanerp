import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/global/voucherTypes.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/login/login.dart';
import 'package:mlco/screens/masters/ledgers/items.dart';
import 'package:mlco/screens/masters/ledgers/ledgers.dart';
import 'package:mlco/screens/reports/Valuation.dart';
import 'package:mlco/screens/reports/balsheetreports/ledgerChildOutstanding.dart';
import 'package:mlco/screens/reports/dealerAnalysisReport.dart';
import 'package:mlco/screens/reports/groupsummaryreport.dart';
import 'package:mlco/screens/reports/itemRegisterReports/itemRegister.dart';
import 'package:mlco/screens/reports/ledgerChildOutstandingReports/ledgerChildOutstanding.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/currentStock.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/outstanding.dart';
import 'package:mlco/screens/reports/ledgerRegisterReports/ledgerRegister.dart';
import 'package:mlco/screens/reports/profitandLossReports/ledgerChildOutstanding.dart';
import 'package:mlco/screens/reports/salesPersonReports%20copy/salesPersonReport.dart';
import 'package:mlco/screens/reports/targetreport.dart';
import 'package:mlco/screens/reports/trialBalreports/ledgerChildOutstanding.dart';
import 'package:mlco/screens/sales/salesEnquiry.dart';
import 'package:mlco/screens/sales/salesInvoice.dart';
import 'package:mlco/screens/sales/salesOrder.dart';
import 'package:mlco/screens/sales/salesProformaInvoice.dart';
import 'package:mlco/screens/sales/salesQuatation.dart';
import 'package:mlco/screens/sales/salesReturn.dart';
import 'package:mlco/screens/vaoucher/creditnotevoucher.dart';
import 'package:mlco/screens/vaoucher/voucher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final TextStyle drawerTextStyle = GoogleFonts.inter(
    fontSize: 16,
    color: const Color.fromRGBO(0, 0, 0, 1),
    fontWeight: FontWeight.w500,
  );

  final TextStyle logoutTextStyle = GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: const Color.fromRGBO(208, 0, 0, 1),
  );

  int? _currentExpandedValue;

  String fyStartDate = '';
  String fyendsDate = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        String fy_startDate = userData['company']['currentFYStarts'];
        String fy_endDate = userData['company']['currentFYEnds'];

        if (fy_startDate != null) {
          setState(() {
            this.fyStartDate = formatDate(fy_startDate);
            fyendsDate = formatDate(fy_endDate);
          });
          print('Loaded fyStartDate: $fyStartDate');
        } else {
          print('fyStartDate is null or not found in userData');
        }
      } catch (e) {
        print('Error parsing userData JSON: $e');
      }
    } else {
      print('No userData found in SharedPreferences');
    }
  }

  logOut(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/baawan-icon.png',
                  height: 80,
                  width: 154,
                ),
                const SizedBox(height: 8),
                Text(
                  "Baawan.com",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Text(
                //   "Since 1944",
                //   style: GoogleFonts.inter(
                //     fontSize: 14,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                createDrawerItem(
                  icon: 'assets/icons/homedrawer.png',
                  text: 'Home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainDashboardScreen()),
                    );
                  },
                ),
                // createDrawerItem(
                //   icon: 'assets/icons/invoice.png',
                //   text: 'Invoice',
                //   onTap: () {},
                // ),
                createExpandableDrawerItem(
                  panelValue: 1,
                  icon: 'assets/icons/sales.png',
                  text: 'Masters',
                  children: [
                    createSubmenuItem(
                        text: 'Ledgers',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LedgersListScreen()),
                          );
                        },
                        icon: 'assets/icons/file-invoice.png'),
                    createSubmenuItem(
                        text: 'Items',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemsListScreen()),
                          );
                        },
                        icon: 'assets/icons/file-invoice.png'),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                createExpandableDrawerItem(
                  panelValue: 1,
                  icon: 'assets/icons/sales.png',
                  text: 'Sales',
                  children: [
                    createSubmenuItem(
                        text: 'Sales Invoice',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalesInvoiceScreen(
                                      invoiceType: InvoiceType.salesInvoice,
                                    )),
                          );
                        },
                        icon: 'assets/icons/file-invoice.png'),
                    createSubmenuItem(
                        text: 'Sales Return',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalesReturnScreen()),
                          );
                        },
                        icon: 'assets/icons/sales return.png'),
                    createSubmenuItem(
                        text: 'Sales Quotation',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalesQuotationScreen()),
                          );
                        },
                        icon: 'assets/icons/sales quotation.png'),
                    createSubmenuItem(
                        text: 'Sales Order',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalesOrderScreen()),
                          );
                        },
                        icon: 'assets/icons/sales order (1).png'),
                    createSubmenuItem(
                        text: 'Proforma Invoice',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProformaInvoiceScreen(
                                      invoiceType: InvoiceType.performaInvoice,
                                    )),
                          );
                        },
                        icon: 'assets/icons/Proforma Invoice.png'),
                    createSubmenuItem(
                        text: 'Dispatch Note',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProformaInvoiceScreen(
                                      invoiceType: InvoiceType.salesChalan,
                                    )),
                          );
                        },
                        icon: 'assets/icons/dispatch note.png'),
                    createSubmenuItem(
                        text: 'Sales Enquiry',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalesEnquiryScreen()),
                          );
                        },
                        icon: 'assets/icons/sales enquiry.png'),
                    createSubmenuItem(
                        text: 'Dispatch Note Return',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProformaInvoiceScreen(
                                      invoiceType:
                                          InvoiceType.salesChallanReturn,
                                    )),
                          );
                        },
                        icon: 'assets/icons/dispatch note return.png'),
                    createSubmenuItem(
                        text: 'Cancel Document',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProformaInvoiceScreen(
                                      invoiceType: InvoiceType.cancelDocument,
                                    )),
                          );
                        },
                        icon: 'assets/icons/cancel document.png'),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                createExpandableDrawerItem(
                  panelValue: 2,
                  icon: 'assets/icons/purchase.png',
                  text: 'Purchase',
                  children: [
                    createSubmenuItem(
                      text: 'Purchase Order',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.purchaseOrder,
                                  )),
                        );
                      },
                      icon: 'assets/icons/purchase order.png',
                    ),
                    createSubmenuItem(
                      text: 'Goods Receipt',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.purchaseChallan,
                                  )),
                        );
                      },
                      icon: 'assets/icons/goods receipt.png',
                    ),
                    createSubmenuItem(
                      text: 'Purchase Invoice',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.purchaseInvoice,
                                  )),
                        );
                      },
                      icon: 'assets/icons/purchase invoice.png',
                    ),
                    createSubmenuItem(
                      text: 'Purchase Return',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.purchaseReturn,
                                  )),
                        );
                      },
                      icon: 'assets/icons/purchase return.png',
                    ),
                    createSubmenuItem(
                      text: 'Costing',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.costing,
                                  )),
                        );
                      },
                      icon: 'assets/icons/costing.png',
                    ),
                    createSubmenuItem(
                      text: 'Goods Receipt Return',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType:
                                        InvoiceType.purchaseChallanReturn,
                                  )),
                        );
                      },
                      icon: 'assets/icons/goods receipt return.png',
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),

                createExpandableDrawerItem(
                  panelValue: 3,
                  icon: 'assets/icons/stock.png',
                  text: 'Stock',
                  children: [
                    createSubmenuItem(
                      text: 'Open Stock Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.openingStock,
                                  )),
                        );
                      },
                      icon: 'assets/icons/stock.png',
                    ),
                    createSubmenuItem(
                      text: 'Stock In Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.transferedInStock,
                                  )),
                        );
                      },
                      icon: 'assets/icons/stock in.png',
                    ),
                    createSubmenuItem(
                      text: 'Stock Out Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.transferedOutStock,
                                  )),
                        );
                      },
                      icon: 'assets/icons/stock out.png',
                    ),
                    createSubmenuItem(
                      text: 'Material Request Slip',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.materialSlip,
                                  )),
                        );
                      },
                      icon: 'assets/icons/material req slip.png',
                    ),
                    createSubmenuItem(
                      text: 'Material In',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.materialIn,
                                  )),
                        );
                      },
                      icon: 'assets/icons/Material in.png',
                    ),
                    createSubmenuItem(
                      text: 'Material Out',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.materialOut,
                                  )),
                        );
                      },
                      icon: 'assets/icons/material out.png',
                    ),
                    createSubmenuItem(
                      text: 'Stock Adjustment',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProformaInvoiceScreen(
                                    invoiceType: InvoiceType.stockAdjustment,
                                  )),
                        );
                      },
                      icon: 'assets/icons/stock adjustment.png',
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),

                createExpandableDrawerItem(
                  panelValue: 4,
                  icon: 'assets/icons/accounts.png',
                  text: 'Accounts',
                  children: [
                    createSubmenuItem(
                      text: 'Sales Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VoucherScreen(
                                    voucherType: VoucherType.salesVoucher,
                                  )),
                        );
                      },
                      icon: 'assets/icons/credit note vocuher.png',
                    ),
                    createSubmenuItem(
                      text: 'Credit Note Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreditNoteVoucherScreen(
                                    voucherType: VoucherType.creditNoteVoucher,
                                  )),
                        );
                      },
                      icon: 'assets/icons/credit note vocuher.png',
                    ),
                    createSubmenuItem(
                      text: 'Purchase Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VoucherScreen(
                                    voucherType: VoucherType.purchaseVoucher,
                                  )),
                        );
                      },
                      icon: 'assets/icons/purchase voucher.png',
                    ),
                    createSubmenuItem(
                      text: 'Debit Note Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VoucherScreen(
                                    voucherType: VoucherType.debitNoteVoucher,
                                  )),
                        );
                      },
                      icon: 'assets/icons/debit note voucher.png',
                    ),
                    createSubmenuItem(
                      text: 'Payment Voucher',
                      icon: 'assets/icons/payment voucher.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VoucherScreen(
                                    voucherType: VoucherType.paymentVoucher,
                                  )),
                        );
                      },
                    ),
                    createSubmenuItem(
                      text: 'Receipt Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VoucherScreen(
                                    voucherType: VoucherType.receiptVoucher,
                                  )),
                        );
                      },
                      icon: 'assets/icons/receipt voucher.png',
                    ),
                    createSubmenuItem(
                      text: 'Journal Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VoucherScreen(
                                    voucherType: VoucherType.journalVoucher,
                                  )),
                        );
                      },
                      icon: 'assets/icons/journal voucher.png',
                    ),
                    createSubmenuItem(
                      text: 'Contra Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VoucherScreen(
                                    voucherType: VoucherType.contraVoucher,
                                  )),
                        );
                      },
                      icon: 'assets/icons/contra.png',
                    ),
                  ],
                ),

                SizedBox(
                  height: 5,
                ),
                createExpandableDrawerItem(
                  panelValue: 5,
                  icon: 'assets/icons/reports.png',
                  text: 'Reports',
                  children: [
                    createSubmenuItem(
                      text: 'Current Stock',
                      icon: 'assets/icons/current stock.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CurrentStockReportListScreen()),
                        );
                      },
                    ),
                    createSubmenuItem(
                      icon: 'assets/icons/ledger outstadning.png',
                      text: 'Ledger Outstanding',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OutstandingReportListScreen()),
                        );
                      },
                    ),
                    createSubmenuItem(
                      icon: 'assets/icons/ledger child outstandig.png',
                      text: 'Ledger Child Outstanding',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LedgerChildOutstandingReportScreen()),
                        );
                      },
                    ),
                    createSubmenuItem(
                      icon: 'assets/icons/ledger register.png',
                      text: 'Ledger Register',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LedgerRegisterReportScreen()),
                        );
                      },
                    ),
                    createSubmenuItem(
                      text: 'Item Register',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ItemRegisterReportScreen()),
                        );
                      },
                      icon: 'assets/icons/ledger register.png',
                    ),
                    createSubmenuItem(
                      text: 'Sales Person',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SalesPersonReportScreen()),
                        );
                      },
                      icon: 'assets/icons/sales person.png',
                    ),
                    createSubmenuItem(
                      text: 'Stock Valuation',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  StockValuationReportListScreen()),
                        );
                      },
                      icon: 'assets/icons/stock valuation.png',
                    ),
                    createSubmenuItem(
                        text: 'Ledger Target',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LedgerTargetReportScreen()),
                          );
                        },
                        icon: 'assets/icons/stock valuation.png'),
                    createSubmenuItem(
                        text: 'Group Summary',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GroupSummaryReportScreen()),
                          );
                        },
                        icon: 'assets/icons/stock valuation.png'),
                    createSubmenuItem(
                        text: 'Dealer Analysis',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DealerAnalysisReportScreen()),
                          );
                        },
                        icon: 'assets/icons/stock valuation.png'),
                    createSubmenuItem(
                        text: 'Trial Balance',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrialBalReportScreen()),
                          );
                        },
                        icon: 'assets/icons/stock valuation.png'),
                    createSubmenuItem(
                        text: 'Profit And Loss',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfitLossReportScreen()),
                          );
                        },
                        icon: 'assets/icons/stock valuation.png'),
                    createSubmenuItem(
                        text: 'Balance Sheet',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BalSheetReportScreen()),
                          );
                        },
                        icon: 'assets/icons/stock valuation.png'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$fyStartDate - $fyendsDate',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  bool? result = await showConfirmationDialog(context);
                  if (result == true) {
                    // User confirmed
                    logOut(context);
                  } else {
                    // User canceled
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.exit_to_app,
                        color: Color.fromRGBO(208, 0, 0, 1)),
                    Text(
                      'Log Out',
                      style: logoutTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget createDrawerItem(
      {required String icon, required String text, GestureTapCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 1),
          // borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(220, 220, 220, 1),
              gradient: announcementGradient,
            ),
            child: Center(
              child: Image.asset(
                icon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          title: Text(
            text,
            style: drawerTextStyle,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget createSubmenuItem(
      {required String text, GestureTapCallback? onTap, icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 1),
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: ListTile(
          leading: icon != null
              ? Image.asset(
                  icon ?? '',
                  height: 24,
                )
              : null,
          title: Text(
            text,
            style: drawerTextStyle.copyWith(fontSize: 14),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  ExpansionPanelRadio _buildExpansionPanel({
    required int value,
    required String title,
    required String leadingIcon,
    required List<Widget> children,
  }) {
    return ExpansionPanelRadio(
      backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
      value: value!,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
          tileColor: const Color.fromRGBO(246, 246, 246, 1),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(220, 220, 220, 1),
              gradient: announcementGradient,
            ),
            child: Center(
              child: Image.asset(
                leadingIcon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          title: Text(
            title,
            style: drawerTextStyle,
          ),
        );
      },
      body: Column(
        children: children,
      ),
      canTapOnHeader: true,
    );
  }

  Widget createExpandableDrawerItem({
    int? panelValue,
    required String icon,
    required String text,
    required List<Widget> children,
  }) {
    return ExpansionPanelList.radio(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.all(0),
      //initialOpenPanelValue: _currentExpandedValue,
      children: [
        ExpansionPanelRadio(
          backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
          value: panelValue!,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
              tileColor: const Color.fromRGBO(246, 246, 246, 1),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(220, 220, 220, 1),
                  gradient: announcementGradient,
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: Text(
                text,
                style: drawerTextStyle,
              ),
            );
          },
          body: Column(
            children: children,
          ),
          canTapOnHeader: true,
        ),
      ],
      expansionCallback: (index, isExpanded) {
        if (isExpanded) {
          _currentExpandedValue = panelValue; // Set the expanded panel value
        } else {
          _currentExpandedValue = null; // Collapse the panel
        }
      },
    );
  }
}

Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Log out', style: TextStyle(fontSize: 20)),
        content: Text(
          'Are you sure you want to Log Out?',
          style: TextStyle(fontWeight: FontWeight.bold),
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
              Navigator.of(context).pop(true); // Return true
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}
