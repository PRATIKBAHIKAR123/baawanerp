import 'package:flutter/material.dart';
import 'package:mlco/global/styles.dart';

Widget exportButton(BuildContext context, onTap) {
  return Container(
    padding: EdgeInsets.all(10),
    height: 40,
    width: 35,
    decoration: BoxDecoration(
        gradient: mlcoGradient,
        boxShadow: [],
        borderRadius: BorderRadius.circular(6.0)),
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            //fixedSize: Size(95, 20),
            backgroundColor: Colors.transparent,
            elevation: 0),
        onPressed: () {
          onTap();
        },
        child: GestureDetector(
          child: Icon(
            size: 15,
            Icons.file_copy,
            color: Colors.white,
          ),
          onTap: () {
            onTap();
          },
        )),
  );
}
