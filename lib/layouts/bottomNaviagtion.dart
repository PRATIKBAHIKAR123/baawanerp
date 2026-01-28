import 'package:flutter/material.dart';
import 'package:mlco/screens/dashboard/accountdashboard.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/dashboard/purchasedashboard.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/currentStock.dart';
import 'package:mlco/config/app_permissions.dart';
import 'package:mlco/services/permission_manager.dart';

import '../screens/dashboard/salesdashboard.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Define all possible items with their permissions and original index
    final allItems = [
      {
        'index': 0,
        'label': 'Dashboard',
        'icon': 'assets/icons/Home.png',
        'permissions': null, // Always visible
      },
      {
        'index': 1,
        'label': 'Sales',
        'icon': 'assets/icons/Chart.png',
        'permissions': [
          AppPermissions.can_view_sales_invoice,
          AppPermissions.can_view_sales_quotation,
          AppPermissions.can_view_sales_order,
          AppPermissions.can_view_sales_enquiry,
          AppPermissions.can_view_sales_return
        ],
      },
      {
        'index': 2,
        'label': 'Purchase',
        'icon': 'assets/icons/Bag.png',
        'permissions': [
          AppPermissions.can_view_purchase_order,
          AppPermissions.can_view_purchase_invoice,
          AppPermissions.can_view_purchase_return
        ],
      },
      {
        'index': 3,
        'label': 'Stock',
        'icon': 'assets/icons/Archive.png',
        'permissions': [
          AppPermissions.can_view_open_stock,
          AppPermissions.can_view_stock_in,
          AppPermissions.can_view_stock_out
        ],
      },
      {
        'index': 4,
        'label': 'Account',
        'icon': 'assets/icons/Briefcase.png',
        'permissions': [
          AppPermissions.can_view_payment_voucher,
          AppPermissions.can_view_receipt_voucher,
          AppPermissions.can_view_journal_voucher
        ],
      },
    ];

    // Filter items based on permissions
    final visibleItems = allItems.where((item) {
      if (item['permissions'] == null) return true;
      return PermissionManager().hasAny(item['permissions'] as List<int>);
    }).toList();

    if (visibleItems.length < 2) {
      return SizedBox.shrink();
    }

    // Map correct currently selected index
    // If the original currentIndex is not in visibleItems (permission revoked?), default to 0
    int displayIndex =
        visibleItems.indexWhere((item) => item['index'] == currentIndex);
    // If the active dashboard isn't in the visible items (e.g. user manually navigated there or lost permission)
    // we should ideally probably navigate them away, but for the navbar display we just need a valid index or to hide selection.
    // However, BottomNavigationBar requires a valid currentIndex within 0..items.length-1.
    if (displayIndex == -1) displayIndex = 0;

    return Container(
      height: 88,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(31.0),
          topRight: Radius.circular(31.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: displayIndex,
        onTap: (newIndex) {
          // Map back to original index for navigation logic
          int originalIndex = visibleItems[newIndex]['index'] as int;
          onTap(originalIndex);

          // Navigation Logic
          switch (originalIndex) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainDashboardScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SalesDashboardScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PurchaseDashboardScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CurrentStockReportListScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AccountDashboardScreen()),
              );
              break;
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        items: visibleItems.map((item) {
          return BottomNavigationBarItem(
            icon: Image.asset(
              item['icon'] as String,
              height: 24,
              width: 24,
            ),
            activeIcon: Image.asset(
              item['icon'] as String,
              height: 24,
              width: 24,
              color: Color.fromRGBO(131, 196, 76, 1),
            ),
            label: item['label'] as String,
          );
        }).toList(),
        selectedItemColor: Colors.green,
        unselectedItemColor: Color.fromRGBO(199, 199, 204, 1),
        showUnselectedLabels: true,
        type: BottomNavigationBarType
            .fixed, // Ensure layout works even with fewer items
      ),
    );
  }
}

class GradientBottomNavBarItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final Function onTap;

  GradientBottomNavBarItem({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
              color:
                  isSelected ? Colors.green : Color.fromRGBO(199, 199, 204, 1),
            ),
            isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.green, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors
                            .white, // This color will be masked by the gradient
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: Color.fromRGBO(199, 199, 204, 1),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
