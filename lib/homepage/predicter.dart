import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/mapping_service.dart';
import '../services/prediction_service.dart';

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
      String garageAddress = _mappingService.getGarageAddress(_selectedGarage!) ?? _selectedGarage!;
      
      print('Starting calculation...');
      print('From: $_selectedAddress');
      print('To: $garageAddress');
      
      // Get route information
      final routeInfo = await _mappingService.getRouteInfo(_selectedAddress!, garageAddress);
      
      if (routeInfo != null) {
        final travelMinutes = routeInfo['duration_minutes'];
        final distanceKm = routeInfo['distance_km'];
        final arrivalTime = _mappingService.calculateArrivalTime(travelMinutes);
        final formattedArrivalTime = _mappingService.formatArrivalTime(arrivalTime);
        
        // Now get parking prediction for the arrival time
        print('Getting prediction for arrival time: $arrivalTime');
        final prediction = await _predictionService.getPrediction(
          arrivalTime: arrivalTime,
          garageName: _selectedGarage!,
          zoneType: 'commuter', // Could be made configurable
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
        final afterArrival = arrivalParts.length > 1 ? arrivalParts.sublist(1).join('\n') : '';
        
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 14),
            children: [
              TextSpan(text: beforeArrival),
              const TextSpan(
                text: 'ESTIMATED ARRIVAL: ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      List<String> addresses = [];
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
      }
      setState(() {
        _savedAddresses = addresses;
        _selectedAddress = null;
        _selectedGarage = null;
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
                          child: DropdownButtonFormField<String>(
                            value: _selectedGarage,
                            decoration: InputDecoration(
                              labelText: 'Desired Parking Garage',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            hint: const Text('Select a parking garage'),
                            items: _jmuGarages.map((String garage) {
                              return DropdownMenuItem<String>(
                                value: garage,
                                child: Text(garage),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGarage = newValue;
                              });
                            },
                          ),
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
                                backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? const Color.fromRGBO(69, 0, 132, 1),
                                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: _calculating ? null : _calculatePrediction, // Disable when calculating
                              child: _calculating 
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                child: _buildPredictionDisplay(),
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
