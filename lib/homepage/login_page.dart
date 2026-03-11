// Written by Tim Hudson - Last Updated 4/1/2025
// Written with the assistance of Openstack, Google Codelabs and ChatGPT

// This code is responsible for the login feature to allow users full functiuonality from the app
// This code has allows the user to sign in with an email and a password. It also allows the user to reset their password oif they have forgotten it

// This page is accessed through the account tab

// Import the needed packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_parking/homepage/signup_page.dart';
import 'package:smart_parking/main.dart';
import 'package:smart_parking/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_parking/homepage/home_page.dart';

// Import your HomePage or starting page

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscured = true; // Password visibility state

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth < 400 ? 12.0 : (screenWidth < 600 ? 24.0 : 48.0);
    final double verticalSpacing = screenWidth < 400 ? 8.0 : 12.0;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(69, 0, 132, 1),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -120,
              bottom: -140,
              child: _meshOrb(
                size: 320,
                colors: const [
                  Color.fromRGBO(0, 0, 0, 0.75),
                  Color.fromRGBO(32, 0, 64, 0.15),
                ],
              ),
            ),
            Positioned(
              right: -90,
              top: -120,
              child: _meshOrb(
                size: 340,
                colors: const [
                  Color.fromRGBO(90, 28, 148, 0.6),
                  Color.fromRGBO(69, 0, 132, 0.0),
                ],
              ),
            ),
            Positioned(
              left: 40,
              top: 180,
              child: _meshOrb(
                size: 220,
                colors: const [
                  Color.fromRGBO(120, 56, 178, 0.28),
                  Color.fromRGBO(69, 0, 132, 0.0),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalSpacing,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      child: _buildImage(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      child: Text(
                        'Smart Parking Assistant',
                        style: GoogleFonts.montserrat(
                          color: const Color.fromRGBO(230, 230, 235, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      child: _emailAddress(horizontalPadding, dense: true),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      child: _password(horizontalPadding, dense: true),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      child: _forgotPasswordButton(context, horizontalPadding, dense: true),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      child: _signin(context, dense: true),
                    ),
                    _signup(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meshOrb({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }

  Widget _emailAddress(double horizontalPadding, {bool dense = false}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Address',
                style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 13),
              ),
              SizedBox(height: dense ? 6 : 16),
              TextField(
                controller: _emailController,
                style: TextStyle(fontSize: dense ? 13 : 16),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  filled: true,
                  hintText: 'example@test.com',
                  hintStyle: TextStyle(
                      color: Color.fromRGBO(106, 106, 106, 1), fontSize: dense ? 12 : 14),
                  fillColor: const Color.fromRGBO(247, 247, 249, 1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _password(double horizontalPadding, {bool dense = false}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password',
                style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 13),
              ),
              SizedBox(height: dense ? 6 : 16),
              TextField(
                controller: _passwordController,
                obscureText: _isObscured,
                style: TextStyle(fontSize: dense ? 13 : 16),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  filled: true,
                  fillColor: const Color.fromRGBO(247, 247, 249, 1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 24, maxWidth: 40),
                      child: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: const Color.fromRGBO(158, 158, 158, 1),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        splashRadius: 18,
                      ),
                    ),
                  ),
                ),
                onSubmitted: (_) async {
                  await AuthService().signin(
                    email: _emailController.text,
                    password: _passwordController.text,
                    context: context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _forgotPasswordButton(BuildContext context, double horizontalPadding, {bool dense = false}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _resetPassword(context),
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Color.fromRGBO(203, 182, 119, 1), fontSize: dense ? 12 : 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _signin(BuildContext context, {bool dense = false}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300.0,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dense ? 10.0 : 20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.14),
            foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(
              color: Color.fromRGBO(255, 255, 255, 0.32),
              width: 1,
            ),
            minimumSize: Size(double.infinity, dense ? 36 : 48),
            elevation: 0, padding: EdgeInsets.symmetric(horizontal: dense ? 8.0 : 20.0),
          ),
          onPressed: () async {
            await AuthService().signin(
              email: _emailController.text,
              password: _passwordController.text,
              context: context,
            );
          },
          child: Text(
            "Sign In",
            style: TextStyle(color: Colors.white, fontSize: dense ? 14 : 18),
          ),
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "New User? ",
              style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1), fontSize: 13),
            ),
            TextSpan(
              text: "Create Account",
              style: const TextStyle(
                  color: Color.fromRGBO(203, 182, 119, 1), fontSize: 13, fontWeight: FontWeight.w500),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Signup()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Keep the logo generally larger while staying responsive across devices.
    final double logoWidth = (screenWidth * 0.72).clamp(260.0, 380.0).toDouble();
    return Image.asset(
      'assets/images/JMU-Logo-RGB-vert-white.png',
      width: logoWidth,
      fit: BoxFit.contain,
    );
  }
}
