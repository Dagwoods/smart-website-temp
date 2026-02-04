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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_parking/homepage/home_page.dart';

// Import your HomePage or starting page

class Login extends StatefulWidget {
  Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscured = true; // Password visibility state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signup(context),
      // appBar: AppBar(
      //   title: const Text('Parking Pal - Sign In Below'), // OG - Login
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              
              _buildImage(),
              const SizedBox(height: 40),
              const Text(
                'Smart Parking Assistant',
                style: TextStyle(
                    color: Color.fromRGBO(69, 0, 132, 1),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _emailAddress(),
              const SizedBox(height: 20),
              _password(),
              const SizedBox(height: 10),
              _forgotPasswordButton(context),
              const SizedBox(height: 50),
              _signin(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailAddress() {

    return Center (
      child: ConstrainedBox(
        constraints: const BoxConstraints(
        ),
        child: Padding (
          padding: const EdgeInsets.symmetric(horizontal: 60.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Address',
                style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'example@test.com',
                  hintStyle: const TextStyle(color: Color.fromRGBO(106, 106, 106, 1), fontSize: 14),
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

  Widget _password() {
    return Center (
      child: ConstrainedBox(
        constraints: const BoxConstraints(
        ),
        child: Padding (
          padding: const EdgeInsets.symmetric(horizontal: 60.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Password',
              style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromRGBO(247, 247, 249, 1),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: const Color.fromRGBO(158, 158, 158, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
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

  Widget _forgotPasswordButton(BuildContext context) {
    return Center (
      child: ConstrainedBox(
        constraints: const BoxConstraints(
        ),
        child: Padding (
          padding: const EdgeInsets.symmetric(horizontal: 60.0),

          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
            onPressed: () => _resetPassword(context),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: Color.fromRGBO(69, 0, 132, 1)),
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

  Widget _signin(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400.0, 
    ),
      child: Padding (
      
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(69, 0, 132, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size(double.infinity, 60), // OG minimumSize: const Size(double.infinity, 60),
            elevation: 0,    padding: const EdgeInsets.symmetric(horizontal: 20.0), 
          ),
          onPressed: () async {
            await AuthService().signin(
              email: _emailController.text,
              password: _passwordController.text,
              context: context,
            );
          },
          child: const Text(
            "Sign In",
            style: TextStyle(color: Colors.white, fontSize: 18),
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
              style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 16),
            ),
            TextSpan(
              text: "Create Account",
              style: const TextStyle(color: Color.fromRGBO(69, 0, 132, 1), fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signup()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Padding (
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Image.asset(
        'assets/images/JMU Logo Purple.png',
         width: 350,
        fit: BoxFit.contain,
      ),
  );
}
}
