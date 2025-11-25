import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/global/styles.dart';

class toDateFilterPopup extends StatefulWidget {
  final Function(String, String) onSubmit; // Define callback function

  toDateFilterPopup({required this.onSubmit});

  @override
  _toDateFilterPopupState createState() => _toDateFilterPopupState();
}

class _toDateFilterPopupState extends State<toDateFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController agegroup = TextEditingController();
  TextEditingController toDate = TextEditingController();
  String _toDate = '';

  @override
  void dispose() {
    agegroup.dispose();
    toDate.dispose();
    super.dispose();
  }

  onTapFunction({required BuildContext context}) async {}

  onTapToDateFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (pickedDate == null) return;

    DateTime currentTime = DateTime.now();
    DateTime pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      currentTime.hour,
      currentTime.minute,
      currentTime.second,
    );

    setState(() {
      toDate.text = DateFormat('yyyy-MM-dd').format(pickedDateTime);
      _toDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedDateTime);
    });
  }

  void submitDate() {
    String selectedagegroup = agegroup.text;
    String formattedToDate = toDate.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy 23:59:59')
            .format(DateTime.parse(toDate.text + ' 23:59:59'))
        : '';

    widget.onSubmit(selectedagegroup, formattedToDate);
    Navigator.of(context).pop();

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
                // Add spacing between the text fields
                Expanded(
                  child: TextFormField(
                    controller: toDate,
                    decoration: InputDecoration(
                        hintText: 'To Date', border: borderStyle),
                    onTap: () => onTapToDateFunction(context: context),
                  ),
                ),
                SizedBox(width: 16),
                // Expanded(
                //   child: DropdownButtonFormField<String>(
                //     decoration: InputDecoration(
                //         labelText: 'Age Type',
                //         border: borderStyle,
                //         enabledBorder: borderStyle,
                //         focusedBorder: borderStyle),
                //     items: ['Weekly', 'Monthly', 'Quarterly']
                //         .map((label) => DropdownMenuItem(
                //               child: Text(label.toString()),
                //               value: label,
                //             ))
                //         .toList(),
                //     onChanged: (value) {
                //       setState(() {});
                //     },
                //   ),
                // ),
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

enum AgeType { weekly, monthly, quarterly }
