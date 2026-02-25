import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/mapping_service.dart';
import '../services/prediction_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/appbar_datetime_center.dart';

class PredicterPage extends StatefulWidget {
  const PredicterPage({Key? key}) : super(key: key);

  @override
  State<PredicterPage> createState() => _PredicterPageState();
}

class _PredicterPageState extends State<PredicterPage> {
  String _predictionMessage = 'Prediction results will appear here.';
  String? _selectedAddress;
  String? _selectedGarage;
  String _selectedZoneType = 'commuter';
  List<String> _savedAddresses = [];
  bool _loading = true;
  bool _calculating = false;

  final MappingService _mappingService = MappingService();
  final PredictionService _predictionService = PredictionService();
  final TextEditingController _addressController = TextEditingController();

  // JMU parking garages
  final List<String> _jmuGarages = [
    'Chesapeake Hall Parking Deck',
    'Grace Street Parking Deck',
    'Warsaw Avenue Parking Deck',
    'Champions Drive Parking Deck',
    'Ballard Hall Parking Deck',
    'Mason Parking Deck',
  ];

  final List<Map<String, String>> _spaceTypes = const [
    {'value': 'commuter', 'label': 'Commuter'},
    {'value': 'faculty', 'label': 'Faculty'},
    {'value': 'accessible', 'label': 'Accessible'},
    {'value': 'electric', 'label': 'Electric'},
  ];

  double _menuHeightForCount(int count,
      {double rowHeight = 48, double maxHeight = 280}) {
    final double computed = count * rowHeight;
    if (computed <= 0) {
      return rowHeight;
    }
    return computed > maxHeight ? maxHeight : computed;
  }

  Future<void> _calculatePrediction() async {
    // Validate inputs
    if (_selectedAddress == null || _selectedAddress!.trim().isEmpty) {
      setState(() {
        _predictionMessage = 'Please enter a starting location.';
      });
      return;
    }

    if (_selectedGarage == null || _selectedGarage!.trim().isEmpty) {
      setState(() {
        _predictionMessage = 'Please enter a parking garage.';
      });
      return;
    }

    setState(() {
      _calculating = true;
      _predictionMessage = 'Calculating route and arrival time...';
    });

    try {
      // Get garage address - either from predefined list or use input directly
      String garageAddress =
          _mappingService.getGarageAddress(_selectedGarage!) ??
              _selectedGarage!;

      print('Starting calculation...');
      print('From: $_selectedAddress');
      print('To: $garageAddress');

      // Get route information
      final routeInfo =
          await _mappingService.getRouteInfo(_selectedAddress!, garageAddress);

      if (routeInfo != null) {
        final travelMinutes = routeInfo['duration_minutes'];
        final distanceKm = routeInfo['distance_km'];
        final arrivalTime = _mappingService.calculateArrivalTime(travelMinutes);
        final formattedArrivalTime =
            _mappingService.formatArrivalTime(arrivalTime);

        // Now get parking prediction for the arrival time
        print('Getting prediction for arrival time: $arrivalTime');
        final prediction = await _predictionService.getPrediction(
          arrivalTime: arrivalTime,
          garageName: _selectedGarage!,
          zoneType: _selectedZoneType,
        );

        setState(() {
          if (prediction != null) {
            // Success - show route info and prediction
            _predictionMessage = '''
Route Information:
From: $_selectedAddress
To: $_selectedGarage
Travel Time: $travelMinutes minutes
Distance: $distanceKm km

ESTIMATED ARRIVAL: $formattedArrivalTime

${_predictionService.formatPredictionMessage(prediction)}''';
          } else {
            // Route worked but prediction failed
            _predictionMessage = '''
Route Information:
From: $_selectedAddress
To: $_selectedGarage
Travel Time: $travelMinutes minutes
Distance: $distanceKm km

ESTIMATED ARRIVAL: $formattedArrivalTime

PARKING PREDICTION: Currently unavailable
The prediction service is not responding. Please ensure the Flask API is running.

To start the prediction service:
1. Navigate to smart_parking/APPAPI/
2. Run: python appAPI.py''';
          }
        });
      } else {
        setState(() {
          _predictionMessage = '''Unable to calculate route.

Debug Info:
From: $_selectedAddress
To: $garageAddress

Please check:
- Starting location is valid
- Parking garage name/address is correct  
- Internet connection is working
- API key is configured

Check the console/logs for more detailed error information.

Try using full addresses like:
"123 Main St, Harrisonburg, VA"''';
        });
      }
    } catch (e) {
      setState(() {
        _predictionMessage = 'Error calculating route: $e';
      });
    } finally {
      setState(() {
        _calculating = false;
      });
    }
  }

  Widget _buildPredictionDisplay() {
    // Check if we have arrival time info to highlight
    if (_predictionMessage.contains('ESTIMATED ARRIVAL:')) {
      final parts = _predictionMessage.split('ESTIMATED ARRIVAL: ');
      if (parts.length >= 2) {
        final beforeArrival = parts[0];
        final afterArrivalFull = parts[1];
        final arrivalParts = afterArrivalFull.split('\n');
        final arrivalTime = arrivalParts[0];
        final afterArrival =
            arrivalParts.length > 1 ? arrivalParts.sublist(1).join('\n') : '';

        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1), fontSize: 14),
            children: [
              TextSpan(text: beforeArrival),
              const TextSpan(
                text: 'ESTIMATED ARRIVAL: ',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              TextSpan(
                text: arrivalTime,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(69, 0, 132, 1),
                ),
              ),
              if (afterArrival.isNotEmpty) TextSpan(text: '\n$afterArrival'),
            ],
          ),
        );
      }
    }

    // Default display for messages without arrival time
    return Text(
      _predictionMessage,
      style: const TextStyle(color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }

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
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      List<String> addresses = [];
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        // Home address
        final homeAddress = data['homeAddress'];
        if (homeAddress != null &&
            homeAddress is String &&
            homeAddress.isNotEmpty) {
          addresses.add(homeAddress);
        }
        // All saved addresses
        if (data['savedAddresses'] != null && data['savedAddresses'] is List) {
          for (var addr in data['savedAddresses']) {
            if (addr is String &&
                addr.isNotEmpty &&
                !addresses.contains(addr)) {
              addresses.add(addr);
            }
          }
        }
      }
      setState(() {
        _savedAddresses = addresses;
        _selectedAddress = null;
        _selectedGarage = null;
        _selectedZoneType = 'commuter';
        _addressController.text = '';
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
    final double panelHeight = MediaQuery.of(context).size.height * 0.69;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Predicter',
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
                    content: const Text('The Predicter page allows you to get real-time parking availability predictions for JMU parking garages based on your estimated arrival time.\n\n'
                        '1. Enter your starting location in the top input field. You can type an address or select from your saved addresses.\n'
                        '2. Select a JMU parking garage from the dropdown menu.\n'
                        '3. Choose the type of parking space you are looking for (commuter, faculty, accessible, electric).\n'
                        '4. Click the "Calculate" button to get your route information and parking prediction.\n\n'
                        'Make sure you have an active internet connection and that the prediction service is running for the best experience.'),
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
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            _loading
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
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (_savedAddresses.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }
                                    return _savedAddresses
                                        .where((String option) {
                                      return option.toLowerCase().contains(
                                          textEditingValue.text.toLowerCase());
                                    });
                                  },
                                  displayStringForOption: (option) => option,
                                  onSelected: (String selection) {
                                    setState(() {
                                      _selectedAddress = selection;
                                      _addressController.text = selection;
                                    });
                                  },
                                  fieldViewBuilder: (context, controller,
                                      focusNode, onEditingComplete) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        labelText: 'Starting Location',
                                        labelStyle: const TextStyle(
                                            color: Color.fromRGBO(
                                                130, 130, 130, 1)),
                                        filled: true,
                                        fillColor: const Color.fromRGBO(
                                            255, 255, 255, 1),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        hintText: _savedAddresses.isEmpty
                                            ? 'No saved addresses'
                                            : 'Type or select saved address',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAddress = value;
                                        });
                                      },
                                      onEditingComplete: onEditingComplete,
                                    );
                                  },
                                  optionsViewBuilder:
                                      (context, onSelected, options) {
                                    final optionList = options.toList();
                                    if (_savedAddresses.isEmpty) {
                                      return Material(
                                        child: ListTile(
                                          title:
                                              const Text('No saved addresses'),
                                        ),
                                      );
                                    }
                                    return Material(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: _menuHeightForCount(
                                              optionList.length,
                                              rowHeight: 56),
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: optionList.length,
                                          itemBuilder: (context, index) {
                                            final option = optionList[index];
                                            return ListTile(
                                              title: Text(option),
                                              onTap: () => onSelected(option),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            255, 255, 255, 1),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              180, 180, 180, 1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final menuWidth =
                                                    constraints.maxWidth;
                                                return DropdownMenu<String>(
                                                  initialSelection:
                                                      _selectedGarage,
                                                  hintText:
                                                      'Select a parking garage',
                                                  width: menuWidth,
                                                  menuHeight:
                                                      _menuHeightForCount(
                                                          _jmuGarages.length),
                                                  menuStyle: MenuStyle(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    minimumSize:
                                                        WidgetStatePropertyAll(
                                                      Size(menuWidth, 0),
                                                    ),
                                                    maximumSize:
                                                        WidgetStatePropertyAll(
                                                      Size(menuWidth,
                                                          double.infinity),
                                                    ),
                                                  ),
                                                  inputDecorationTheme:
                                                      const InputDecorationTheme(
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 12),
                                                  ),
                                                  dropdownMenuEntries:
                                                      _jmuGarages
                                                          .map((garage) =>
                                                              DropdownMenuEntry<
                                                                  String>(
                                                                  value:
                                                                      garage,
                                                                  label:
                                                                      garage))
                                                          .toList(),
                                                  onSelected:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _selectedGarage =
                                                          newValue;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 28,
                                            color: const Color.fromRGBO(
                                                210, 210, 210, 1),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: DropdownMenu<String>(
                                              initialSelection:
                                                  _selectedZoneType,
                                              width: 120,
                                              menuHeight: _menuHeightForCount(
                                                  _spaceTypes.length),
                                              menuStyle: const MenuStyle(
                                                alignment: Alignment.bottomLeft,
                                              ),
                                              inputDecorationTheme:
                                                  const InputDecorationTheme(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 12),
                                              ),
                                              dropdownMenuEntries: _spaceTypes
                                                  .map((spaceTypeOption) =>
                                                      DropdownMenuEntry<String>(
                                                        value:
                                                            spaceTypeOption[
                                                                'value']!,
                                                        label:
                                                            spaceTypeOption[
                                                                'label']!,
                                                      ))
                                                  .toList(),
                                              onSelected: (String? newValue) {
                                                if (newValue == null) {
                                                  return;
                                                }
                                                setState(() {
                                                  _selectedZoneType = newValue;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // COMMENTED OUT TEST BUTTONS - keeping code for future development
                              // Test API button
                              // Center(
                              //   child: SizedBox(
                              //     width: 160,
                              //     child: ElevatedButton(
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: Colors.orange,
                              //         foregroundColor: Colors.white,
                              //         textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              //       ),
                              //       onPressed: _calculating ? null : () async {
                              //         setState(() {
                              //           _calculating = true;
                              //           _predictionMessage = 'Testing API key...';
                              //         });
                              //
                              //         final isWorking = await _mappingService.testApiKey();
                              //
                              //         setState(() {
                              //           _calculating = false;
                              //           _predictionMessage = isWorking
                              //               ? 'API Key is working! Check console for details.'
                              //               : 'API Key test failed. Check console for error details.';
                              //         });
                              //       },
                              //       child: const Text('Test API'),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 16),
                              // Test Prediction API button
                              // Center(
                              //   child: SizedBox(
                              //     width: 160,
                              //     child: ElevatedButton(
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: Colors.green,
                              //         foregroundColor: Colors.white,
                              //         textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              //       ),
                              //       onPressed: _calculating ? null : () async {
                              //         setState(() {
                              //           _calculating = true;
                              //           _predictionMessage = 'Testing prediction API...';
                              //         });
                              //
                              //         final isWorking = await _predictionService.testConnection();
                              //
                              //         if (isWorking) {
                              //           // Test actual prediction
                              //           final testPrediction = await _predictionService.getPrediction(
                              //             arrivalTime: DateTime.now().add(const Duration(minutes: 15)),
                              //             garageName: 'Chesapeake Hall Parking Deck',
                              //             zoneType: 'commuter',
                              //           );
                              //
                              //           setState(() {
                              //             _calculating = false;
                              //             if (testPrediction != null) {
                              //               _predictionMessage = '''
                              // Prediction API Test: SUCCESS
                              //
                              // Test prediction for Chesapeake Hall:
                              // ${_predictionService.formatPredictionMessage(testPrediction)}
                              //
                              // The prediction service is working correctly!''';
                              //             } else {
                              //               _predictionMessage = 'Prediction API connected but prediction failed. Check Flask API logs.';
                              //             }
                              //           });
                              //         } else {
                              //           setState(() {
                              //             _calculating = false;
                              //             _predictionMessage = '''
                              // Prediction API Test: FAILED
                              //
                              // Cannot connect to the Flask API server.
                              //
                              // To start the prediction service:
                              // 1. Open terminal in smart_parking/APPAPI/
                              // 2. Run: python appAPI.py
                              // 3. Ensure Flask is running on http://localhost:5000''';
                              //           });
                              //         }
                              //       },
                              //       child: const Text('Test Prediction'),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 24),
                              Center(
                                child: SizedBox(
                                  width: 160, // Set a much smaller width
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                          255, 255, 255, 0.14),
                                      foregroundColor: const Color.fromRGBO(
                                          255, 255, 255, 1),
                                    ),
                                    onPressed: _calculating
                                        ? null
                                        : _calculatePrediction, // Disable when calculating
                                    child: _calculating
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text('Calculate'),
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
                            padding: const EdgeInsets.only(top: 90, bottom: 72),
                            child: SizedBox(
                              height: panelHeight,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Prediction Output',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Center(
                                        child: _buildPredictionDisplay(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
