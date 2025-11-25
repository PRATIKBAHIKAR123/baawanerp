// import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:mlco/global/styles.dart';
import 'package:mlco/screens/login/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InfoScreen extends StatefulWidget {
  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

int _current = 0;
List<Map<String, dynamic>> carouselItems = [
  {
    'text': 'Get Instant Insight',
    'subtext': 'Make sure that you already have an account.'
  },
  {
    'text': 'Get Instant Insight',
    'subtext': 'Make sure that you already have an account.'
  },
  {
    'text': 'Get Instant Insight',
    'subtext': 'Make sure that you already have an account.'
  },
  {
    'text': 'Get Instant Insight',
    'subtext': 'Make sure that you already have an account.'
  }
];
//final CarouselController _controller = CarouselController();

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 66),
            Image.asset(
              'assets/images/mlco-logo.png',
              width: 166,
              height: 42,
            ),
            SizedBox(height: 10),
            Image.asset(
              'assets/images/info.png',
              width: 306,
              height: 662,
            ),
          ],
        ),
      ),
      // bottomSheet: BottomSheet(
      //   onClosing: () {},
      //   builder: (context) => Container(
      //       height: 175,
      //       decoration: BoxDecoration(
      //           gradient: mlcoGradient,
      //           borderRadius: BorderRadius.only(
      //               topLeft: Radius.circular(40),
      //               topRight: Radius.circular(40))),
      //       child: Column(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             CarouselSlider(
      //               carouselController: _controller,
      //               options: CarouselOptions(
      //                 height: 120,
      //                 enlargeCenterPage: true,
      //                 aspectRatio: 2.0,
      //                 viewportFraction: 10,
      //                 onPageChanged: (index, reason) {
      //                   setState(() {
      //                     _current = index;
      //                   });
      //                 },
      //               ),
      //               items: carouselItems.map((i) {
      //                 return Builder(
      //                   builder: (BuildContext context) {
      //                     return Container(
      //                       margin: EdgeInsets.symmetric(vertical: 10),
      //                       decoration:
      //                           BoxDecoration(color: Colors.transparent),
      //                       child: Column(
      //                           crossAxisAlignment: CrossAxisAlignment.center,
      //                           mainAxisAlignment: MainAxisAlignment.center,
      //                           children: [
      //                             Text(
      //                               i['text'],
      //                               style: plus_jakarta18_w500,
      //                             ),
      //                             Text(
      //                               i['subtext'],
      //                               style: plus_jakarta14_w400,
      //                             )
      //                           ]),
      //                     );
      //                   },
      //                 );
      //               }).toList(),
      //             ),
      //             //SizedBox(height: 10),
      //             Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   SizedBox(
      //                     width: 70,
      //                   ),
      //                   AnimatedSmoothIndicator(
      //                     activeIndex: _current,
      //                     count: 5,
      //                     effect: ExpandingDotsEffect(
      //                       activeDotColor: Colors.white,
      //                       dotHeight: 8.0,
      //                       dotWidth: 8.0,
      //                       expansionFactor: 2.0,
      //                       spacing: 5.0,
      //                     ),
      //                     onDotClicked: (index) {
      //                       _controller.animateToPage(index);
      //                     },
      //                   ),
      //                   TextButton(
      //                     onPressed: () {
      //                       // Define skip button functionality here
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(
      //                             builder: (context) => LoginScreen()),
      //                       );
      //                     },
      //                     child: Row(children: [
      //                       Text(
      //                         'Skip',
      //                         style: TextStyle(
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                       Image.asset(
      //                         'assets/icons/Right 2.png',
      //                         height: 24,
      //                         width: 24,
      //                       )
      //                     ]),
      //                   ),
      //                 ]),
      //           ])),
      // ),
    );
  }
}
