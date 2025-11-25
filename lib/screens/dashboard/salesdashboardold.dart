import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlco/common-widgets/searchStats.dart';
import 'package:mlco/global/styles.dart';

class SalesDashboardScreen extends StatefulWidget {
  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  final List<String> quickLinks = [
    'Sales Invoice',
    'Purchase Invoice',
    'Receipt Voucher',
    'Payment Voucher'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 133,
                          decoration: BoxDecoration(
                              gradient: link == 'Sales Invoice'
                                  ? mlcoGradient2
                                  : inactivelinksgradient,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Text(
                            link,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: link == 'Sales Invoice'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          )),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Announcements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'View All',
                    style: mlco_gradient_text,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: announcementGradient,
                    borderRadius: BorderRadius.circular(18)),
                child: Text(
                  'There is shortage of ALD-CHR-573, please take confirmation from Jigar Sir/Anup Sir, before confirming stock or supply to any dealer.',
                  style: announcementtextStyle,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales & Purchase Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'View All',
                    style: mlco_gradient_text,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height:
                    300, // Set a fixed height or use Expanded for flexible height
                child: LineChartWidget(),
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
