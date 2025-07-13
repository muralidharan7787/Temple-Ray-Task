import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_front/NavMain.dart';
import 'package:task_front/home/HomePage.dart';
import 'package:task_front/utils/bottomSnackBar.dart';
import 'package:http/http.dart' as http;
import 'global/Common.dart';

class SignInAndUp extends StatefulWidget {
  const SignInAndUp({super.key});

  @override
  State<SignInAndUp> createState() => _SignInAndUpState();
}

class _SignInAndUpState extends State<SignInAndUp> {
  bool _isLogin = true; // 🔁 Tracks current mode
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  final List<String> validDomains = ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com'];


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
  }

  void _handleAuth() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final domain = email.split('@').last;

    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      getSnackBar(context, 'Please fill all required fields.', Colors.orange, 1);
      return;
    }

    if (!_isLogin && password != confirmPassword) {
      getSnackBar(context, 'Passwords do not match.', Colors.orange, 1);
      return;
    }

    if (!validDomains.contains(domain)) {
      getSnackBar(context, 'Enter a valid email', Colors.orange, 1);
      return;
    }

    setState(() => _isLoading = true);

    final url = _isLogin
        ? Uri.parse(Common.baseUrl+'auth/login')
        : Uri.parse(Common.baseUrl+'auth/register');

    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final responseData = jsonDecode(response.body);
      debugPrint("🔄 Auth Response: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        if (_isLogin) {
          // LOGIN SUCCESS
          final token = responseData['token'];
          await prefs.setString('token', token);
          await prefs.setString('email', email);
          getSnackBar(context, 'Logged in successfully!', Colors.green, 0);
        } else {
          // REGISTER SUCCESS
          getSnackBar(context, responseData['message'] ?? 'Registered successfully!', Colors.green, 0);
        }

        // Navigate to home
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavMain()));
      } else {
        final message = responseData['message']?.toLowerCase() ?? '';

        if (_isLogin && message.contains('not found')) {
          getSnackBar(context, 'You don’t have an account. Kindly sign up.', Colors.red, 2);
        } else if (!_isLogin && message.contains('already')) {
          getSnackBar(context, 'Email is already taken.', Colors.red, 2);
        } else {
          getSnackBar(context, 'Check your credentials and try again.', Colors.red, 1);
        }
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      getSnackBar(context, 'Check your Internet Connection', Colors.orange, 2);
    } finally {
      setState(() => _isLoading = false);
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Common.secondary,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Common.background,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // ✅ Dismisses keyboard
        },
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Common.background
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(_isLogin ? 'Log in to your account' : 'Create a new account', style: TextStyle(fontFamily: 'bold', fontSize: 20, fontWeight: Common.weight),),
                          SizedBox(height: 20,),
                          Container(
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: TextField(
                                  controller: _emailController,
                                  cursorColor: Common.secondary,
                                  style: TextStyle(
                                    fontFamily: 'bold',
                                    fontSize: Common.h2,
                                    fontWeight: Common.weight2,
                                    color: Common.secondary,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,         // removes underline
                                    enabledBorder: InputBorder.none,  // removes underline when enabled
                                    focusedBorder: InputBorder.none,  // removes underline when focused
                                    hintText: _isLogin?  'Email address' : 'Enter your email address',
                                    hintStyle: TextStyle(             // ✅ corrected
                                      fontFamily: 'bold',
                                      fontSize: Common.h2,
                                      fontWeight: Common.weight2,
                                      color: Colors.grey,
                                    ), // no hint text
                                    contentPadding: EdgeInsets.zero,  // remove extra padding
                                    isCollapsed: true, // make it tighter
                                  ),
                                ),
                              ),
                            )
                          ),

                          SizedBox(height: 10,),
                          Container(
                              height: 45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10,),
                                        child: TextField(
                                          obscureText: _obscurePassword,
                                          controller: _passwordController,
                                          cursorColor: Common.secondary,
                                          style: TextStyle(
                                            fontFamily: 'bold',
                                            fontSize: Common.h2,
                                            fontWeight: Common.weight2,
                                            color: Common.secondary,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,         // removes underline
                                            enabledBorder: InputBorder.none,  // removes underline when enabled
                                            focusedBorder: InputBorder.none,  // removes underline when focused
                                            hintText: _isLogin? 'Password' : 'Create a password',
                                            hintStyle: TextStyle(             // ✅ corrected
                                              fontFamily: 'bold',
                                              fontSize: Common.h2,
                                              fontWeight: Common.weight2,
                                              color: Colors.grey,
                                            ), // no hint text
                                            contentPadding: EdgeInsets.zero,  // remove extra padding
                                            isCollapsed: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                          ),
                          if(!_isLogin)...[
                            SizedBox(height: 10,),
                            Container(
                                height: 45,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10,),
                                          child: TextField(
                                            obscureText: _obscurePassword,
                                            controller: _confirmPasswordController,
                                            cursorColor: Common.secondary,
                                            style: TextStyle(
                                              fontFamily: 'bold',
                                              fontSize: Common.h2,
                                              fontWeight: Common.weight2,
                                              color: Common.secondary,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,         // removes underline
                                              enabledBorder: InputBorder.none,  // removes underline when enabled
                                              focusedBorder: InputBorder.none,  // removes underline when focused
                                              hintText: 'Confirm your password',
                                              hintStyle: TextStyle(             // ✅ corrected
                                                fontFamily: 'bold',
                                                fontSize: Common.h2,
                                                fontWeight: Common.weight2,
                                                color: Colors.grey,
                                              ), // no hint text
                                              contentPadding: EdgeInsets.zero,  // remove extra padding
                                              isCollapsed: true, // make it tighter
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ],
                          SizedBox(height: 20,),
                          InkWell(
                            // onTap: _handleGoogleSignIn,
                            onTap: _handleAuth,
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Common.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child:
                              _isLoading
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Common.primary),
                                    ),
                                  ),
                                ],
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin? 'Login' : 'Register',
                                    style: TextStyle(
                                      fontFamily: 'bold',
                                      fontSize: Common.h2,
                                      fontWeight: Common.weight2,
                                      color: Common.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Common.light,
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onDoubleTap: () async {
                                  final newUrl = await showDialog<String>(
                                    context: context,
                                    builder: (context) {
                                      final controller = TextEditingController(text: Common.baseUrl);
                                      return AlertDialog(
                                        title: Text("Change Base URL"),
                                        content: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(hintText: 'http://your-ip:port/'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                                            child: Text("Save"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (newUrl != null && newUrl.isNotEmpty) {
                                    setState(() {
                                      Common.baseUrl = newUrl; // ✅ changes for session only
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Base URL updated to: $newUrl")),
                                    );
                                  }
                                },
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontFamily: 'bold',
                                    fontSize: Common.h3,
                                    fontWeight: Common.weight2,
                                    color: Common.secondary,
                                  ),
                                ),
                              ),


                              SizedBox(width: 10,),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Common.light,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isLogin = !_isLogin; // 🔁 Toggle between SignIn/SignUp
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _isLogin ? 'Create a new account?' : 'Already have an account?', // 🔁 Toggle text
                                    style: TextStyle(
                                      fontFamily: 'bold',
                                      fontSize: Common.h2,
                                      fontWeight: Common.weight2,
                                      color: Common.light,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _isLogin ? ' Sign up' : ' Sign in', // 🔁 Toggle action
                                    style: TextStyle(
                                      fontFamily: 'bold',
                                      fontSize: Common.h2,
                                      fontWeight: Common.weight2,
                                      color: Common.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
