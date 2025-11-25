import 'package:flutter/material.dart';

class DealerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  DealerBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(31.0),
          topRight: Radius.circular(31.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => onTap(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/Home.png',
                  height: 24,
                  width: 24.96,
                  color: currentIndex == 0
                      ? Color.fromRGBO(131, 196, 76, 1)
                      : Color.fromRGBO(199, 199, 204, 1),
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    color: currentIndex == 0
                        ? Color.fromRGBO(131, 196, 76, 1)
                        : Color.fromRGBO(199, 199, 204, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
