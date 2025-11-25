import 'package:flutter/material.dart';
import 'package:mlco/screens/reports/trialBalreports/accordian.dart';

class AccordionList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final bool showOpeningBalance;
  final bool showDebit;
  final bool showCredit;
  final Function(Map<String, dynamic>) onItemSelected;

  const AccordionList({
    Key? key,
    required this.items,
    required this.showOpeningBalance,
    required this.showDebit,
    required this.showCredit,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _AccordionListState createState() => _AccordionListState();
}

class _AccordionListState extends State<AccordionList> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 240,
        child: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return ExpandableItem(
              item: widget.items[index],
              showOpeningBalance: widget.showOpeningBalance,
              showDebit: widget.showDebit,
              showCredit: widget.showCredit,
              onItemSelected: widget.onItemSelected,
            );
          },
        ));
  }
}
