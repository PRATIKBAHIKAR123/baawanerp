import 'package:flutter/material.dart';
import 'package:mlco/global/styles.dart';

class MLCOAppBackButtonBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
          iconSize: 40,
          padding: EdgeInsets.all(0),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: mlco_green,
          )),
      title: Image.asset(
        'assets/images/baawan-Logo.png',
        width: 166,
        height: 42,
      ),
      backgroundColor: Colors.transparent,
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
