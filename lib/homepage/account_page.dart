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
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
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
  final String googleApiKey = "AIzaSyBFrTsiYcpETNVw4fnwXZHREUx8XvB91jQ"; // <-- Replace with your actual API Key

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
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          List<String> loadedAddresses = [];
          if (data['savedAddresses'] != null && data['savedAddresses'] is List) {
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
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: const Color.fromRGBO(69, 0, 132, 1),
        foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
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
      body: Center(
        child: isLoading
            ? const Text(
                'Please Login or Register for an account',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              )
            : user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, ${username ?? user.email}!',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 0, 0, 1)),
                      ),
                      const SizedBox(height: 20),

                      // Address and Garage Inputs with Saved Lists
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Input bars take 2/3 of the width
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: GooglePlaceAutoCompleteTextField(
                                      textEditingController: _addressController,
                                      googleAPIKey: googleApiKey,
                                      inputDecoration: InputDecoration(
                                        labelText: 'Enter Address',
                                        labelStyle: const TextStyle(color: Colors.black),
                                        filled: true,
                                        fillColor: const Color.fromRGBO(247, 247, 249, 1),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        floatingLabelBehavior: FloatingLabelBehavior.never, 
                                      ),
                                      debounceTime: 800,
                                      isLatLngRequired: false,
                                      itemClick: (prediction) {
                                        _addressController.text = prediction.description!;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: SizedBox(
                                      width: 160,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? const Color.fromRGBO(69, 0, 132, 1),
                                          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: _updateHomeAddress,
                                        child: const Text('Save Address'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Space between bars and boxes
                            const SizedBox(width: 40),
                            // Boxes take 1/3 of the width
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 220,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(247, 247, 249, 1),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: savedAddresses.isEmpty
                                              ? const Text('No saved addresses', style: TextStyle(color: Colors.grey))
                                              : Scrollbar(
                                                  child: ListView.builder(
                                                    itemCount: savedAddresses.length,
                                                    itemBuilder: (context, index) {
                                                      final addr = savedAddresses[index];
                                                      return Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                addr,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(fontSize: 14),
                                                              ),
                                                            ),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ...removed old button row, now buttons are under their respective bars...
                    ],
                  )
                : const Text('User not authenticated'),
      ),
    );
  }
}
