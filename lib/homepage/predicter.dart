import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PredicterPage extends StatefulWidget {
  const PredicterPage({Key? key}) : super(key: key);

  @override
  State<PredicterPage> createState() => _PredicterPageState();
}

class _PredicterPageState extends State<PredicterPage> {
  String _predictionMessage = 'Prediction results will appear here.';
  String? _selectedAddress;
  String? _selectedGarage;
  List<String> _savedAddresses = [];
  List<String> _garageNames = [];
  bool _loading = true;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _garageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      List<String> addresses = [];
      List<String> garages = [];
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        // Home address
        final homeAddress = data['homeAddress'];
        if (homeAddress != null && homeAddress is String && homeAddress.isNotEmpty) {
          addresses.add(homeAddress);
        }
        // All saved addresses
        if (data['savedAddresses'] != null && data['savedAddresses'] is List) {
          for (var addr in data['savedAddresses']) {
            if (addr is String && addr.isNotEmpty && !addresses.contains(addr)) {
              addresses.add(addr);
            }
          }
        }
        // Favorite garage
        final favoriteGarage = data['favoriteGarage'];
        if (favoriteGarage != null && favoriteGarage['address'] != null && favoriteGarage['address'].toString().isNotEmpty) {
          garages.add(favoriteGarage['address']);
        }
        // All saved garages
        if (data['savedGarages'] != null && data['savedGarages'] is List) {
          for (var g in data['savedGarages']) {
            if (g is String && g.isNotEmpty && !garages.contains(g)) {
              garages.add(g);
            }
          }
        }
      }
      setState(() {
        _savedAddresses = addresses;
        _garageNames = garages;
        _selectedAddress = null;
        _selectedGarage = null;
        _addressController.text = '';
        _garageController.text = '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicter'),
        backgroundColor: const Color.fromRGBO(69, 0, 132, 1),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input bars take 2/3 of the width
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (_savedAddresses.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _savedAddresses.where((String option) {
                                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption: (option) => option,
                            onSelected: (String selection) {
                              setState(() {
                                _selectedAddress = selection;
                                _addressController.text = selection;
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              controller.text = _addressController.text;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'Starting Location',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  hintText: _savedAddresses.isEmpty ? 'No saved addresses' : 'Type or select saved address',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAddress = value;
                                    _addressController.text = value;
                                  });
                                },
                                onEditingComplete: onEditingComplete,
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              if (_savedAddresses.isEmpty) {
                                return Material(
                                  child: ListTile(
                                    title: const Text('No saved addresses'),
                                  ),
                                );
                              }
                              return Material(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (_garageNames.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _garageNames.where((String option) {
                                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption: (option) => option,
                            onSelected: (String selection) {
                              setState(() {
                                _selectedGarage = selection;
                                _garageController.text = selection;
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              controller.text = _garageController.text;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'Desired Parking Garage',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  hintText: _garageNames.isEmpty ? 'No saved garages' : 'Type or select saved garage',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGarage = value;
                                    _garageController.text = value;
                                  });
                                },
                                onEditingComplete: onEditingComplete,
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              if (_garageNames.isEmpty) {
                                return Material(
                                  child: ListTile(
                                    title: const Text('No saved garages'),
                                  ),
                                );
                              }
                              return Material(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: SizedBox(
                            width: 160, // Set a much smaller width
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? const Color.fromRGBO(69, 0, 132, 1),
                                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                setState(() {
                                  _predictionMessage = 'Calculation complete! (This is a placeholder message)';
                                });
                              },
                              child: const Text('Calculate'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Space between bars and box
                  const SizedBox(width: 40),
                  // Single box to the right, vertically aligned with top box in account page
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120), // Adjusted for visible vertical alignment
                      child: Container(
                        width: double.infinity,
                        height: 550,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(247, 247, 249, 1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prediction Output', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _predictionMessage,
                                  style: const TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
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
    );
  }
}
