import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlco/common-widgets/searchStats.dart';
import 'package:mlco/global/gradientText.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/layouts/bottomNaviagtion.dart';
import 'package:mlco/layouts/mlcoappbar.dart';
import 'package:mlco/layouts/mlcodrawer.dart';

import 'package:mlco/screens/dashboard/announcements.dart/announcements.dart';
import 'package:mlco/screens/sales/salesEnquiry.dart';
import 'package:mlco/screens/sales/salesInvoice.dart';
import 'package:mlco/screens/sales/salesOrder.dart';
import 'package:mlco/screens/sales/salesQuatation.dart';
import 'package:mlco/services/announcementService.dart';
import 'package:mlco/services/sessionCheckService.dart';

class MainDashboardScreen extends StatefulWidget {
  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final List<Map<String, dynamic>> quickLinks = [
    {'id': '1', 'name': 'Sales Invoice'},
    {'id': '2', 'name': 'Sales Quotation'},
    {'id': '3', 'name': 'Sales Order'},
    {'id': '4', 'name': 'Sales Enquiry'},
  ];

  int _selectedIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Map<dynamic, dynamic>>> _dataFuture;
  late Future<List<Map<dynamic, dynamic>>> announcemnents;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    announcemnents = Future.value([]);
    getAnnouncementData();
    checkSessionService();
  }

  void getAnnouncementData() async {
    // Fetch the data from Firebase
    List<Map<dynamic, dynamic>> fetchedData =
        await _firebaseService.getData('/announcements');
    //_dataFuture = _firebaseService.getData('/announcements');
    // Filter announcements based on toDate
    DateTime today = DateTime.now();
    List<Map<dynamic, dynamic>> filteredAnnouncements =
        fetchedData.where((announcement) {
      DateTime toDate = DateFormat('yyyy-MM-dd').parse(announcement['toDate']);
      return toDate.isAfter(today) || toDate.isAtSameMomentAs(today);
    }).toList();

    // Assign filtered data to the Future variable
    setState(() {
      announcemnents = Future.value(filteredAnnouncements);
    });
  }

  void _onQuickLinkTapped(String id) {
    print(id);
    switch (id) {
      case '1':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SalesInvoiceScreen(
                      invoiceType: InvoiceType.salesInvoice,
                    )),
          );
        }
        break;
      case '2':
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SalesQuotationScreen()),
          );
        }
      case '3':
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SalesOrderScreen()),
          );
        }
      case '4':
        {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SalesEnquiryScreen()),
          );
        }
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
              Container(
                child: SearchStat(),
              ),
              SizedBox(height: 20),
              Text(
                'Quick Links',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: quickLinks.map((link) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                          onTap: () => {_onQuickLinkTapped(link['id'])},
                          child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: 133,
                              decoration: BoxDecoration(
                                  gradient: link['id'] == '1'
                                      ? mlcoGradient2
                                      : inactivelinksgradient,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24))),
                              child: Container(
                                alignment: Alignment.center,
                                height: 30,
                                width: 123,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24))),
                                child: Text(
                                  link['name'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    color: link['id'] == '1'
                                        ? Colors.black
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ))),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Announcements',
              //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => AnnouncementScreen()),
              //         );
              //       },
              //       child: GradientText(
              //         'View All',
              //         style: mlco_gradient_text,
              //         gradient: LinearGradient(
              //             colors: [baawan_blue, baawan_green, baawan_yellow]),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 20),
              // FutureBuilder<List<Map<dynamic, dynamic>>>(
              //   future: announcemnents,
              //   builder: (BuildContext context,
              //       AsyncSnapshot<List<Map<dynamic, dynamic>>> snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return Center(
              //           child:
              //               CircularProgressIndicator()); // Loading indicator
              //     } else if (snapshot.hasError) {
              //       return Center(
              //           child:
              //               Text('Error: ${snapshot.error}')); // Error message
              //     } else if (snapshot.hasData) {
              //       final announcements = snapshot.data!;

              //       if (announcements.isNotEmpty) {
              //         // Show the first announcement if the list is not empty
              //         return AnnouncementsPageView(
              //             announcements: announcements);
              //         // Column(
              //         //       children: announcements.map((announcement) {
              //         //         return Container(
              //         //           width: MediaQuery.of(context).size.width,
              //         //           padding: EdgeInsets.all(10),
              //         //           margin: EdgeInsets.only(bottom: 10),
              //         //           decoration: BoxDecoration(
              //         //               gradient: announcementGradient,
              //         //               borderRadius: BorderRadius.circular(18)),
              //         //           child: Text(
              //         //             announcement['announcement'],
              //         //             style: announcementtextStyle,
              //         //           ),
              //         //         );
              //         //       }).toList(),
              //         //     );
              //       } else {
              //         // Show "No Announcements" if the list is empty
              //         return Center(child: Text('No Announcements'));
              //       }
              //     } else {
              //       return Center(
              //           child: Text(
              //               'No Announcements')); // Fallback No data message
              //     }
              //   },
              // ),
              // // Container(
              // //   padding: EdgeInsets.all(10),
              // //   decoration: BoxDecoration(
              // //       gradient: announcementGradient,
              // //       borderRadius: BorderRadius.circular(18)),
              // //   child: Text(
              // //     'There is shortage of ALD-CHR-573, please take confirmation from Jigar Sir/Anup Sir, before confirming stock or supply to any dealer.',
              // //     style: announcementtextStyle,
              // //   ),
              // // ),
              // SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales & Purchase Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GradientText(
                    'View All',
                    style: mlco_gradient_text,
                    gradient:
                        LinearGradient(colors: [baawan_blue, baawan_green]),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Container(
                height:
                    300, // Set a fixed height or use Expanded for flexible height
                child: LineChartWidget(),
              ),
              SizedBox(height: 5),
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Sales :'),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          height: 10,
                          width: 10,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('80%'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Purchase :'),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          height: 10,
                          width: 10,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('90%'),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Quick Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(110, 110, 110, 0.1),
                          blurRadius: 4,
                          offset: Offset(4, 8), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          '      Monthly Earning',
                          style: plus_jakarta13_w600,
                        ),
                        Text(
                          '      11,235',
                          style: plus_jakarta19_w600,
                        ),
                        Container(
                          height: 200,
                          width:
                              160, // Set a fixed height or use Expanded for flexible height
                          child: statChartWidget(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(110, 110, 110, 0.1),
                          blurRadius: 4,
                          offset: Offset(4, 8), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          '      Weekly Earning',
                          style: plus_jakarta13_w600,
                        ),
                        Text(
                          '      2,523',
                          style: plus_jakarta19_w600,
                        ),
                        Container(
                          height: 200,
                          width:
                              160, // Set a fixed height or use Expanded for flexible height
                          child: weeklystatChartWidget(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AnnouncementsPageView extends StatefulWidget {
  final List<Map<dynamic, dynamic>> announcements;

  AnnouncementsPageView({required this.announcements});

  @override
  _AnnouncementsPageViewState createState() => _AnnouncementsPageViewState();
}

class _AnnouncementsPageViewState extends State<AnnouncementsPageView> {
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= widget.announcements.length) {
          nextPage = 0; // Loop back to the first page
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // Adjust height as needed
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.announcements.length,
        itemBuilder: (context, index) {
          final announcement = widget.announcements[index];
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: announcementGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                announcement['announcement'] ?? 'No content available',
                style: announcementtextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                return Container();
              }

              return LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Color(0xff68737d),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = Text('Jan', style: style);
                              break;
                            case 1:
                              text = Text('Feb', style: style);
                              break;
                            case 2:
                              text = Text('Mar', style: style);
                              break;
                            case 3:
                              text = Text('Apr', style: style);
                              break;
                            case 4:
                              text = Text('May', style: style);
                              break;
                            case 5:
                              text = Text('Jun', style: style);
                              break;
                            case 6:
                              text = Text('Jul', style: style);
                              break;
                            case 7:
                              text = Text('Aug', style: style);
                              break;
                            case 8:
                              text = Text('Sep', style: style);
                              break;
                            case 9:
                              text = Text('Oct', style: style);
                              break;
                            case 10:
                              text = Text('Nov', style: style);
                              break;
                            case 11:
                              text = Text('Dec', style: style);
                              break;
                            default:
                              text = Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: text,
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: false,
                    verticalInterval: 1, // Adjust as needed
                  ),
                  borderData: FlBorderData(
                    show: false,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minX: 0,
                  maxX: 08,
                  minY: 0,
                  maxY: 40,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getValidSpots([
                        FlSpot(0, 10),
                        FlSpot(1, 32),
                        FlSpot(2, 20),
                        FlSpot(3, 15),
                        FlSpot(4, 25),
                        FlSpot(5, 17),
                        FlSpot(6, 30),
                        FlSpot(7, 12),
                        FlSpot(8, 20),
                        FlSpot(9, 22),
                        FlSpot(10, 27),
                        FlSpot(11, 15),
                      ]),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: _getValidSpots([
                        FlSpot(0, 20),
                        FlSpot(1, 10),
                        FlSpot(2, 30),
                        FlSpot(3, 12),
                        FlSpot(4, 22),
                        FlSpot(5, 18),
                        FlSpot(6, 27),
                        FlSpot(7, 10),
                        FlSpot(8, 25),
                        FlSpot(9, 15),
                        FlSpot(10, 20),
                        FlSpot(11, 30),
                      ]),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  List<FlSpot> _getValidSpots(List<FlSpot> spots) {
    return spots
        .where((spot) =>
            spot.x != null &&
            spot.y != null &&
            spot.x.isFinite &&
            spot.y.isFinite)
        .toList();
  }
}

class statChartWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                return Container();
              }

              return LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    show: false, // Hide all titles
                  ),
                  gridData: FlGridData(
                    show: false, // Hide all grid lines
                  ),
                  borderData: FlBorderData(
                    show: false, // Hide chart border
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 40,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getValidSpots([
                        FlSpot(0, 10),
                        FlSpot(1, 32),
                        FlSpot(2, 20),
                        FlSpot(3, 15),
                        FlSpot(4, 25),
                        FlSpot(5, 17),
                        FlSpot(6, 15),
                      ]),
                      isCurved: true,
                      color:
                          Colors.green, // Set color with opacity for the fill
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false), // Hide dots
                    ),
                    LineChartBarData(
                      spots: _getValidSpots([
                        FlSpot(0, 09),
                        FlSpot(1, 30),
                        FlSpot(2, 30),
                        FlSpot(3, 12),
                        FlSpot(4, 22),
                        FlSpot(5, 18),
                        FlSpot(6, 27),
                      ]),
                      isCurved: true,
                      color: Colors.green.withOpacity(
                          0.5), // Set color with opacity for the fill
                      barWidth: 0,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false), // Hide dots
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(
                            0.3), // Set color with opacity for the fill below
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  List<FlSpot> _getValidSpots(List<FlSpot> spots) {
    return spots
        .where((spot) =>
            spot.x != null &&
            spot.y != null &&
            spot.x.isFinite &&
            spot.y.isFinite)
        .toList();
  }
}

class weeklystatChartWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                return Container();
              }

              return LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    show: false, // Hide all titles
                  ),
                  gridData: FlGridData(
                    show: false, // Hide all grid lines
                  ),
                  borderData: FlBorderData(
                    show: false, // Hide chart border
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 40,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getValidSpots([
                        FlSpot(0, 10),
                        FlSpot(1, 32),
                        FlSpot(2, 20),
                        FlSpot(3, 15),
                        FlSpot(4, 25),
                        FlSpot(5, 17),
                        FlSpot(6, 15),
                      ]),
                      isCurved: true,
                      color:
                          Colors.green, // Set color with opacity for the fill
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false), // Hide dots
                    ),
                    LineChartBarData(
                      spots: _getValidSpots([
                        FlSpot(0, 09),
                        FlSpot(1, 30),
                        FlSpot(2, 30),
                        FlSpot(3, 12),
                        FlSpot(4, 22),
                        FlSpot(5, 18),
                        FlSpot(6, 27),
                      ]),
                      isCurved: true,
                      color: Colors.green.withOpacity(
                          0.5), // Set color with opacity for the fill
                      barWidth: 0,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false), // Hide dots
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(
                            0.3), // Set color with opacity for the fill below
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  List<FlSpot> _getValidSpots(List<FlSpot> spots) {
    return spots
        .where((spot) =>
            spot.x != null &&
            spot.y != null &&
            spot.x.isFinite &&
            spot.y.isFinite)
        .toList();
  }
}
