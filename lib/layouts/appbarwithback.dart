import 'package:flutter/material.dart';
import 'package:mlco/global/styles.dart';

class mlcoAppBarWithBack extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Map<dynamic, dynamic> invoiceDetails;

  mlcoAppBarWithBack({required this.title, required this.invoiceDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: mlcoGradient),
      child: AppBar(
        // Transparent AppBar to display gradient
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoiceDetails['ledger'],
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoiceDetails['billno'],
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  invoiceDetails['salesperson'] != ''
                      ? 'Sales Person-' + invoiceDetails['salesperson']
                      : '',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ],
        ),
        elevation: 0, // Remove shadow
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
