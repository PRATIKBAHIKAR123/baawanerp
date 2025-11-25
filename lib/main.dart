import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/dealer/dashboard/dealerdashboard.dart';
import 'package:mlco/screens/infoInit/insightsStartupScreen.dart';
import 'package:mlco/screens/login/login.dart';
import 'package:mlco/services/navigationservice.dart';
import 'package:mlco/services/sessionCheckService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CurrencyFormatter.init();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      databaseURL: 'https://mlco-erp-default-rtdb.firebaseio.com',
      apiKey: "AIzaSyC6AT5amsTaX_ymnPtobA7E9MuDzHj2y38",
      appId: "1:571163137186:android:cdc33da62bb0dfa86a73fb",
      messagingSenderId: "Messaging sender id here",
      projectId: "mlco-erp",
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<NavigationService>.value(value: navigationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => MainDashboardScreen(),
      },
      title: 'Baawan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: baawan_green, primary: baawan_green),
          scaffoldBackgroundColor: Colors.white,
          popupMenuTheme: PopupMenuThemeData(
            color: Colors.white, // Replace with your desired background color
          ),
          useMaterial3: true,
          canvasColor: Colors.white,
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStatePropertyAll(baawan_green))),
      home: FutureBuilder<Map<String, dynamic>>(
        future: _initializeApp(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Image.asset(
                  'assets/icons/baawan-icon.png',
                  height: 200,
                  width: 200,
                ), // Adjust path as per your project structure
              ),
            ); // Or a splash screen
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            print('Session check result: ${snapshot.data}');
            final data = snapshot.data!;
            if (data['isSessionValid'] == true) {
              return data['isDealer'] == true
                  ? DealerDashboardScreen()
                  : MainDashboardScreen();
            } else {
              return LoginScreen();
            }
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _initializeApp() async {
    bool isSessionValid = await checkSessionService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDealer = prefs.getBool('isDealer');
    print('isDealer: $isDealer');
    // Return a map containing the session validity and dealer status
    return {
      'isSessionValid': isSessionValid,
      'isDealer': isDealer ?? false,
    };
  }
}
