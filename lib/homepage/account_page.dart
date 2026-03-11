// Written by Tim Hudson - Last Updated 4/1/2025
// Written with the assistance of Openstack, Google Codelabs and ChatGPT

// This code is responsible for the account page that is displayed once a user signs in with an account
// This code has two main functions: Allow the user to set a home address and Allow the user to set a favorite garage

// This page is accessed through the account tab once a user signs in or signs up

// Import the needed packaged
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/appbar_datetime_center.dart';

// Account page is stateful
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

// Set strings for information that is pulled from the Firebase Cloud Storage
class _AccountPageState extends State<AccountPage> {
  Future<void> _deleteSavedAddress(String address) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<String> updatedAddresses = List<String>.from(savedAddresses);
      updatedAddresses.remove(address);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'savedAddresses': updatedAddresses,
      });
      setState(() {
        savedAddresses = updatedAddresses;
      });
    }
  }

  String? username;
  String? homeAddress;
  bool isLoading = true;
  List<String> savedAddresses = [];

  final TextEditingController _addressController = TextEditingController();

  // API key for Google Places Autocomplete
  final String googleApiKey =
      "AIzaSyBFrTsiYcpETNVw4fnwXZHREUx8XvB91jQ"; // <-- Replace with your actual API Key

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Grabs the needed data from the database
  Future<void> _getUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          List<String> loadedAddresses = [];
          if (data['savedAddresses'] != null &&
              data['savedAddresses'] is List) {
            loadedAddresses = List<String>.from(data['savedAddresses']);
          }
          setState(() {
            username = data['username'];
            homeAddress = data['homeAddress'];
            _addressController.text = homeAddress ?? '';
            savedAddresses = loadedAddresses;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching user data: $e");
      }
    }
  }

// Updates the home address once the save address button is completed
  Future<void> _updateHomeAddress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final address = _addressController.text.trim();

      if (address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid address.')),
        );
        return;
      }

      try {
        // Add to savedAddresses if not already present
        List<String> updatedAddresses = List<String>.from(savedAddresses);
        if (!updatedAddresses.contains(address)) {
          updatedAddresses.add(address);
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'homeAddress': address,
          'savedAddresses': updatedAddresses,
        });

        setState(() {
          homeAddress = address;
          savedAddresses = updatedAddresses;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home address updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating address: $e')),
        );
      }
    }
  }

  // Actually building of the application
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final mediaQuery = MediaQuery.of(context);
    final double topPanelInset = mediaQuery.padding.top + kToolbarHeight + 12;
    final double bottomPanelInset = mediaQuery.padding.bottom + 12;
    const double panelVerticalOffset = 0;
    final double pageHorizontalPadding =
        (mediaQuery.size.width * 0.028).clamp(14.0, 34.0).toDouble();
    final double containerWidth =
      (mediaQuery.size.width * 0.80).clamp(320.0, 1100.0).toDouble();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Account',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Instructions',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Instructions'),
                    content: const Text('This page allows you to manage your account settings, including updating your home address and viewing saved addresses.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const AppBarDateTimeCenter(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPanelInset,
                  left: pageHorizontalPadding,
                  right: pageHorizontalPadding,
                  bottom: bottomPanelInset,
                ),
                child: Transform.translate(
                  offset: const Offset(0, panelVerticalOffset),
                  child: isLoading
                      ? const Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            'Please Login or Register for an account',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : user != null
                          ? Center(
                              child: SizedBox(
                                width: containerWidth,
                                height: double.infinity,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(247, 247, 249, 1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                                const Text('Saved Addresses',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child:
                                                      GooglePlaceAutoCompleteTextField(
                                                    textEditingController:
                                                        _addressController,
                                                    googleAPIKey: googleApiKey,
                                                    inputDecoration:
                                                        InputDecoration(
                                                      labelText:
                                                          'Enter Address',
                                                      labelStyle:
                                                          const TextStyle(
                                                              color: Colors
                                                                  .black),
                                                      filled: true,
                                                      fillColor:
                                                          const Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              1),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                      ),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .never,
                                                    ),
                                                    debounceTime: 800,
                                                    isLatLngRequired: false,
                                                    itemClick: (prediction) {
                                                      _addressController.text =
                                                          prediction
                                                              .description!;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: SizedBox(
                                                    width: 160,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                        const Color
                                                          .fromRGBO(
                                                          69,
                                                          0,
                                                          132,
                                                          1),
                                                        foregroundColor:
                                                            const Color
                                                                .fromRGBO(
                                                                255,
                                                                255,
                                                                255,
                                                                1),
                                                      ),
                                                      onPressed:
                                                          _updateHomeAddress,
                                                      child: const Text(
                                                          'Save Address'),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                        Expanded(
                                          child: savedAddresses.isEmpty
                                              ? const Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    'No saved addresses',
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                                )
                                              : Scrollbar(
                                                  child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    itemCount: savedAddresses.length,
                                                    itemBuilder: (context, index) {
                                                      final addr = savedAddresses[index];
                                                      return Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                addr,
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(fontSize: 17, height: 1.25),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 6),
                                                            IconButton(
                                                              icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(),
                                                              tooltip: 'Delete',
                                                              onPressed: () => _deleteSavedAddress(addr),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          : const Align(
                              alignment: Alignment.topCenter,
                              child: Text('User not authenticated'),
                            ),
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
}
