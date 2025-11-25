import 'package:flutter/material.dart';
import 'package:mlco/global/styles.dart';

class MLCOAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/images/baawan-Logo.png',
        width: 166,
        height: 42,
      ),
      backgroundColor: Colors.white,
      actions: [
        Container(
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.only(right: 20),
          height: 37,
          width: 37,
          decoration: BoxDecoration(
              gradient: mlcoGradient, borderRadius: BorderRadius.circular(4)),
          child: IconButton(
            padding: EdgeInsets.all(2),
            icon: Image.asset(
              'assets/icons/menu.png',
              width: 24,
              height: 24,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    ));
  }
}
