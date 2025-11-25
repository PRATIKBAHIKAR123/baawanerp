import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget noRecordsFound() {
  return Align(
    heightFactor: 20,
    alignment: Alignment.center,
    child: Center(
      child: Text('No Records found'),
    ),
  );
}
