import 'package:flutter/material.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/services/announcementService.dart';

class AnnouncementScreen extends StatefulWidget {
  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late Future<List<Map<dynamic, dynamic>>> _dataFuture;
  final FirebaseService _firebaseService = FirebaseService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _dataFuture = _firebaseService.getData('/announcements');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainDashboardScreen()),
        );
        break;
      case 1:
        Navigator.pushNamed(context, '/sales');
        break;
      case 2:
        Navigator.pushNamed(context, '/purchase');
        break;
      case 3:
        Navigator.pushNamed(context, '/stock');
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MLCOAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'All Announcements',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<List<Map<dynamic, dynamic>>>(
                      future: _dataFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Map<dynamic, dynamic>>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child:
                                  CircularProgressIndicator()); // Show loading spinner
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error: ${snapshot.error}')); // Show error message
                        } else if (snapshot.hasData) {
                          // Build your list of announcements
                          final announcements = snapshot.data!;
                          return Column(
                            children: announcements.map((announcement) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    gradient: announcementGradient,
                                    borderRadius: BorderRadius.circular(18)),
                                child: Text(
                                  announcement['announcement'],
                                  style: announcementtextStyle,
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return Center(
                              child: Text(
                                  'No Announcements')); // Show message when no data is available
                        }
                      },
                    ),
                  ]))),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

const announcementTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.white,
);
