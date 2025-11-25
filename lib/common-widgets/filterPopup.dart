import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/styles.dart';

class FilterPopup extends StatefulWidget {
  final Function(String, String) onSubmit; // Define callback function
  final String? initialFromDate;
  final String? initialToDate;
  FilterPopup(
      {required this.onSubmit, this.initialFromDate, this.initialToDate});

  @override
  _FilterPopupState createState() => _FilterPopupState();
}

class _FilterPopupState extends State<FilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  String _toDate = '';

  @override
  void dispose() {
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialFromDate != null) {
      fromDate.text = DateFormat('dd/MM/yyyy').format(
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialFromDate!));
    }
    if (widget.initialToDate != null) {
      toDate.text = DateFormat('dd/MM/yyyy').format(
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialToDate!));
    }
  }

  Future<void> onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2100),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    setState(() {
      fromDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  Future<void> onTapToDateFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (pickedDate == null) return;

    setState(() {
      toDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void submitDate() {
    String formattedFromDate =
        fromDate.text.isNotEmpty ? '${fromDate.text} 00:00:00' : '';
    String formattedToDate =
        toDate.text.isNotEmpty ? '${toDate.text} 23:59:59' : '';

    widget.onSubmit(formattedFromDate, formattedToDate);
    Navigator.of(context).pop();

    print('fromDate: $formattedFromDate');
    print('toDate: $formattedToDate');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Container(
        height: 144,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: fromDate,
                    decoration:
                        InputDecoration(hintText: 'From', border: borderStyle),
                    onTap: () => onTapFunction(context: context),
                  ),
                ),
                SizedBox(width: 16), // Add spacing between the text fields
                Expanded(
                  child: TextFormField(
                    controller: toDate,
                    decoration:
                        InputDecoration(hintText: 'To', border: borderStyle),
                    onTap: () => onTapToDateFunction(context: context),
                  ),
                ),
              ],
            ),
            Container(
              height: 42,
              width: 360,
              decoration: BoxDecoration(
                gradient: mlcoGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  submitDate();
                },
                child: Text(
                  "Apply Filter",
                  style: GoogleFonts.poppins(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
