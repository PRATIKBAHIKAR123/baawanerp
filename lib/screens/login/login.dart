import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/global/styles.dart';
import 'package:mlco/global/utils.dart';
import 'package:mlco/screens/dashboard/maindashboard.dart';
import 'package:mlco/screens/dealer/dashboard/dealerdashboard.dart';
import 'package:mlco/services/loginService.dart';
import 'package:mlco/services/syncService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../../common-widgets/pwaInstall.dart';
import 'package:mlco/services/permission_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController companyCode = TextEditingController();

  bool _obscureText = true;
  bool isLoading = false;
  bool _userSuggestionsVisible = false;
  late FocusNode _nameFocusNode = FocusNode();
  late FocusNode codeFocusNode = FocusNode();
  List<Map<String, dynamic>> _userList = [];
  OverlayEntry? _overlayEntry;
  bool loginasDealer = false;

  @override
  void initState() {
    super.initState();
    _loadUserList();
    WidgetsBinding.instance.addObserver(this);
    // Show PWA install prompt on login screen if running on web
    // if (kIsWeb) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     showPwaInstallPrompt();
    //   });
    // }
    // _nameFocusNode.addListener(() {
    //   if (_nameFocusNode.hasFocus) {
    //     Future.delayed(Duration(seconds: 10), _showOverlay());
    //   } else {
    //     _hideOverlay();
    //   }
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideOverlay(); // Ensure overlay is removed when disposing
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;

    if (bottomInset > 0 && _overlayEntry == null) {
      // Keyboard is visible, show overlay
      _showOverlay();
    } else if (bottomInset == 0) {
      // Keyboard is hidden, remove overlay
      _hideOverlay();
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (loginasDealer) {
        dealerLogin(context);
      } else {
        login(context);
      }
    }
  }

  dealerLogin(context) async {
    setState(() {
      isLoading = true;
    });

    try {
      var requestBody = {
        'userName': _name.text,
        'password': _password.text,
      };

      var response = await dealerLoginService(requestBody);

      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', data);
        await prefs.setBool('isDealer', true);
        String? userId = decodedData['user']['user_ID']?.toString();
        if (decodedData != null) {
          userList(decodedData);
          ledgerSync();
          itemSync();
          groupSync();
          WidgetsBinding.instance.removeObserver(this);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Success"),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DealerDashboardScreen()),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Login"),
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Login"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Failed"),
        ),
      );
    }
  }

  login(context) async {
    setState(() {
      isLoading = true;
    });

    try {
      var requestBody = {
        'userName': _name.text,
        'password': _password.text,
        'shortcode': companyCode.text,
      };

      var response = await loginService(requestBody);

      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        //decodedData['company']['baseCurrency'] = 2;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', data);
        String? userId = decodedData['user']['user_ID']?.toString();
        await prefs.setBool('isDealer', false);
        if (decodedData != null) {
          print('DEBUG: Data Keys: ${decodedData.keys.toList()}'); // Debug keys

          if (decodedData['tokenInfo'] != null) {
            print('DEBUG: Found tokenInfo, saving permissions...');
            await PermissionManager().savePermissions(decodedData['tokenInfo']);
          } else if (decodedData['rights'] != null) {
            print(
                'DEBUG: tokenInfo is missing but found root-level "rights". Saving root data as permissions source.');
            await PermissionManager().savePermissions(decodedData);
          } else {
            print(
                'DEBUG: CRITICAL - No "tokenInfo" OR "rights" found in login response!');
          }

          userList(decodedData);
          ledgerSync();
          itemSync();
          currencySync();

          groupSync();
          WidgetsBinding.instance.removeObserver(this);
          await CurrencyFormatter.init();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Success"),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainDashboardScreen()),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Login"),
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Login"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Failed"),
        ),
      );
    }
  }

  Future<void> userList(userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userList = prefs.getStringList('userList') ?? [];

    var newUser = {
      'userName': _name.text,
      'password': _password.text,
      'user_ID': userData['user']['user_ID']?.toString(),
      'first_Name': userData['user']['first_Name']?.toString(),
      'lastname': userData['user']['lastname']?.toString(),
      'company_name': userData['company']['compName']?.toString(),
      'shortCode': userData['company']['shortCode']?.toString()
    };

    String newUserJson = jsonEncode(newUser);

    bool isDuplicate = userList.any((userJson) {
      var user = jsonDecode(userJson);
      return user['userName'] == newUser['userName'] ||
          user['user_ID'] == newUser['user_ID'];
    });

    if (!isDuplicate) {
      userList.add(newUserJson);
      await prefs.setStringList('userList', userList);
      userList = prefs.getStringList('userList')!;
      print('Updated userList: $userList');
    }
  }

  Future<void> _loadUserList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userListString = prefs.getStringList('userList') ?? [];
    setState(() {
      _userList = userListString
          .map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>)
          .toList();
    });
  }

  void _selectUserSuggestion(
      String username, String password, String? shortCode) {
    _name.text = username;
    _password.text = password;
    companyCode.text = shortCode ?? '';
    _nameFocusNode.unfocus();
    codeFocusNode.unfocus();
  }

  void _onNameFieldFocusChanged() {
    setState(() {
      _userSuggestionsVisible = false;
    });

    if (_nameFocusNode.hasFocus) {
      setState(() {
        _userSuggestionsVisible = true;
      });
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return; // Prevent multiple overlays

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    Future.delayed(Duration(milliseconds: 240), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 240,
        left: 180,
        right: 50,
        child: Material(
          elevation: 8.0,
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: _userList
                  .map((suggestion) => GestureDetector(
                      onTapDown: (TapDownDetails) {
                        _selectUserSuggestion(
                          suggestion['userName'],
                          suggestion['password'],
                          suggestion['shortCode'],
                        );
                      },
                      onTapUp: (TapUpDetails) {
                        _selectUserSuggestion(
                          suggestion['userName'],
                          suggestion['password'],
                          suggestion['shortCode'],
                        );
                      },
                      onTap: () {
                        _selectUserSuggestion(
                          suggestion['userName'],
                          suggestion['password'],
                          suggestion['shortCode'],
                        );
                      },
                      child: ListTile(
                        title: Text(suggestion['userName']),
                      )))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents UI from shifting up
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient:
                    mlcoGradient2, // Assuming you have a gradient defined in your styles
              ),
              child: Column(
                children: [
                  SizedBox(height: 75),
                  Container(
                    height: 141,
                    width: 335,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Image.asset(
                            'assets/images/baawan-Logo.png',
                            width: 166,
                            height: 42,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Welcome Back',
                            style: plus_jakarta24_w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomSheet(
              constraints: BoxConstraints(maxHeight: 550),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              builder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Login to Your Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Make sure that you already have an account.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Comapny Code'),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: companyCode,
                          focusNode: codeFocusNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter company code.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: inputBorderStyle,
                            enabledBorder: inputBorderStyle,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('User Name'),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _name,
                          focusNode: _nameFocusNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter user name.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: inputBorderStyle,
                            enabledBorder: inputBorderStyle,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Password'),
                        SizedBox(height: 10),
                        TextFormField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _hideOverlay();
                            } else {
                              _showOverlay();
                            }
                          },
                          controller: _password,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter password.';
                            }
                            return null;
                          },
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            border: inputBorderStyle,
                            enabledBorder: inputBorderStyle,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color.fromRGBO(131, 145, 161, 1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     // Row(
                        //     //   children: [
                        //     //     Checkbox(
                        //     //       value: loginasDealer,
                        //     //       onChanged: (value) {
                        //     //         setState(() {
                        //     //           loginasDealer = value!;
                        //     //         });
                        //     //       },
                        //     //     ),
                        //     //     Text('Login as Dealer'),
                        //     //   ],
                        //     // ),
                        //     // TextButton(
                        //     //   onPressed: () {},
                        //     //   child: Text(
                        //     //     'Forgot Password?',
                        //     //     style: TextStyle(color: Colors.green),
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                        SizedBox(height: 40),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: mlcoGradient,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _submitForm(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 100,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Color.fromRGBO(232, 236, 244, 1),
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: SpaceGrotesk14_w700,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'A Product by',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            SizedBox(width: 2),
                            GestureDetector(
                                onTap: () async {
                                  var uri = "http://baawan.com/";
                                  if (await launch(uri)) {
                                    await launch(uri);
                                  } else {
                                    // can't launch url
                                  }
                                },
                                child: Text(
                                  'Baawan',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              onClosing: () {},
            ),
          ),
        ],
      ),
    );
  }
}
