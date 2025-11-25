import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/common-widgets/searchStats.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDashboardScreen extends StatefulWidget {
  @override
  State<AccountDashboardScreen> createState() => _AccountDashboardScreenState();
}

class _AccountDashboardScreenState extends State<AccountDashboardScreen> {
  int _selectedIndex = 4;
  String activeLink = '1';
  String fyStartDate = '';
  String fyendsDate = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        String fy_startDate = userData['company']['currentFYStarts'];
        String fy_endDate = userData['company']['currentFYEnds'];
        String first_name = userData['user']['first_Name'];
        String last_name = userData['user']['lastname'];
        username = first_name + ' ' + last_name;
        if (fy_startDate != null) {
          setState(() {
            this.fyStartDate = formatDate(fy_startDate);
            fyendsDate = formatDate(fy_endDate);
          });
          print('Loaded fyStartDate: $fyStartDate');
        } else {
          print('fyStartDate is null or not found in userData');
        }
      } catch (e) {
        print('Error parsing userData JSON: $e');
      }
    } else {
      print('No userData found in SharedPreferences');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                // Set a fixed height
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 241, 231),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.person,
                        size: 40,
                      ),
                    ),
                    Text(
                      '$username',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    Text(
                      '$fyStartDate - $fyendsDate',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
