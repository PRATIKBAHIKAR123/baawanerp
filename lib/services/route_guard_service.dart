import 'package:flutter/material.dart';
import 'package:mlco/services/permission_manager.dart';
import 'package:mlco/config/app_permissions.dart';

class RouteGuardService {
  // Define route-permission mappings here
  // Note: While keys are strings (route names), values can be int (from AppPermissions).
  // We use dynamic values in the map to accommodate this.
  static final Map<String, dynamic> _routePermissions = {
    // Sales
    'SalesInvoiceScreen': AppPermissions.can_view_sales_invoice,
    'SalesQuotationScreen': AppPermissions.can_view_sales_quotation,
    'SalesOrderScreen': AppPermissions.can_view_sales_order,
    'SalesEnquiryScreen': AppPermissions.can_view_sales_enquiry,
    'SalesReturnScreen': AppPermissions.can_view_sales_return,
    'ProformaInvoice': AppPermissions.can_view_msg_proforma_invoice,
    'DispatchNote': AppPermissions.can_view_dispatch_note,

    // Purchase
    'PurchaseOrder': AppPermissions.can_view_purchase_order,
    'GoodsReceipt': AppPermissions.can_view_goods_receipt,
    'PurchaseInvoice': AppPermissions.can_view_purchase_invoice,
    'PurchaseReturn': AppPermissions.can_view_purchase_return,
    'Costing': AppPermissions.can_view_costing,

    // Stock
    'OpenStock': AppPermissions.can_view_open_stock,
    'StockIn': AppPermissions.can_view_stock_in,
    'StockOut': AppPermissions.can_view_stock_out,
    'MaterialReqSlip': AppPermissions.can_view_material_req_slip,

    // Accounts
    'SalesVoucher': AppPermissions.can_view_sales_voucher,
    'CreditNote': AppPermissions.can_view_credit_note,
    'PurchaseVoucher': AppPermissions.can_view_purchase_voucher,
    'DebitNote': AppPermissions.can_view_debit_note,
    'PaymentVoucher': AppPermissions.can_view_payment_voucher,
    'ReceiptVoucher': AppPermissions.can_view_receipt_voucher,
    'JournalVoucher': AppPermissions.can_view_journal_voucher,
    'ContraVoucher': AppPermissions.can_view_contra_voucher,

    // Reports
    'CurrentStockReport': AppPermissions.can_view_current_stock,
    'LedgerOutstanding': AppPermissions.can_view_ledger_outstanding,
    'LedgerRegister': AppPermissions.can_view_ledger_register,
    // Add more mappings as needed matching your named routes if you implement them
  };

  /// Checks if the current user has access to the given route name.
  static bool canNavigateToString(String routeName) {
    if (_routePermissions.containsKey(routeName)) {
      var requiredPermission = _routePermissions[routeName]!;
      return PermissionManager().isGranted(requiredPermission);
    }
    return true; // No restriction defined
  }

  /// Navigates to a named route if permitted, otherwise shows an alert.
  static void pushNamed(BuildContext context, String routeName,
      {Object? arguments}) {
    if (canNavigateToString(routeName)) {
      Navigator.pushNamed(context, routeName, arguments: arguments);
    } else {
      _showUnauthorizedDialog(context);
    }
  }

  /// Helper to check permission before pushing a MaterialPageRoute
  static void push(BuildContext context, MaterialPageRoute route,
      dynamic requiredPermission) {
    if (requiredPermission == null ||
        PermissionManager().isGranted(requiredPermission)) {
      Navigator.push(context, route);
    } else {
      _showUnauthorizedDialog(context);
    }
  }

  static void _showUnauthorizedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unauthorized'),
        content: Text('You do not have permission to access this screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
