import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/screens/reports/groupsummaryreport.dart';

class totalBottomBar extends StatelessWidget {
  final TextStyle inter14_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  final TextStyle inter13_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );
  final double total;
  final String rows;

  totalBottomBar({required this.total, required this.rows});

  @override
  Widget build(BuildContext context) {
    // Format the total amount with commas
    final formattedTotal = CurrencyFormatter.format(total);
    return Container(
      padding: EdgeInsets.all(16),
      height: 156,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(gradient: mlcoGradient2),
      child: BottomSheet(
        backgroundColor: Colors.transparent,
        onClosing: () {},
        builder: (BuildContext context) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Grand Amount :',
                    style: inter14_w600,
                  ),
                  Text(
                    ' ${formattedTotal}',
                    style: inter14_w600,
                  )
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  Text(
                    'Total Rows :',
                    style: inter13_w600,
                  ),
                  Text(
                    ' $rows',
                    style: inter13_w600,
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
