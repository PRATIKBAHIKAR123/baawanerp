import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBill extends StatelessWidget {
  final Function(String) onTextChanged;

  const SearchBill({required this.onTextChanged});

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
      color: Color.fromRGBO(160, 160, 160, 1),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return TextFormField(
      onChanged: onTextChanged,
      decoration: InputDecoration(
        constraints:
            BoxConstraints(minHeight: 48, maxHeight: 48, maxWidth: 348),
        prefixIcon: Padding(
          padding: EdgeInsets.all(15),
          child: Image.asset(
            'assets/icons/search.png',
            width: 18,
            height: 18,
          ),
        ),
        contentPadding: EdgeInsets.all(13),
        hintText: 'Search Bill No.',
        hintStyle: hintStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color.fromRGBO(211, 211, 211, 1)),
        ),
      ),
      maxLines: 1,
    );
  }
}
