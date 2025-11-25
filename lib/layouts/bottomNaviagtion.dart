import 'package:flutter/material.dart';
import 'package:mlco/screens/dashboard/accountdashboard.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/dashboard/purchasedashboard.dart';
import 'package:mlco/screens/reports/ledgerOutstandingReports/currentStock.dart';

import '../screens/dashboard/salesdashboard.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
        currentIndex: currentIndex,
        onTap: (currentindex) {
          onTap(currentindex);
          switch (currentindex) {
            case 0:
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainDashboardScreen()),
                );
              }
              break;
            case 1:
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SalesDashboardScreen()),
                );
              }
            case 2:
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PurchaseDashboardScreen()),
                );
              }
            case 3:
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CurrentStockReportListScreen()),
                );
              }
            case 4:
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountDashboardScreen()),
                );
              }
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Home.png',
              height: 24,
              width: 24.96,
            ),
            activeIcon: Image.asset(
              'assets/icons/Home.png',
              height: 24,
              width: 24.96,
              color: Color.fromRGBO(131, 196, 76, 1),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Chart.png',
              height: 24,
              width: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/Chart.png',
              height: 24,
              width: 24,
              color: Color.fromRGBO(131, 196, 76, 1),
            ),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Bag.png',
              height: 24,
              width: 24,
            ),
            label: 'Purchase',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Archive.png',
              height: 24,
              width: 24,
            ),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Briefcase.png',
              height: 24,
              width: 24,
            ),
            label: 'Account',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Color.fromRGBO(199, 199, 204, 1),
        showUnselectedLabels: true,
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
