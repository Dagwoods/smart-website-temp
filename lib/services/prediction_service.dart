import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  static const String _baseUrl = 'http://127.0.0.1:5000'; // Flask API URL
  
  /// Get parking availability prediction
  Future<Map<String, dynamic>?> getPrediction({
    required DateTime arrivalTime,
    required String garageName,
    String zoneType = 'commuter',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/predict');
      
      final requestBody = {
        'arrival_time': arrivalTime.toIso8601String(),
        'garage_name': garageName,
        'zone_type': zoneType,
      };
      
      print('Making prediction request...');
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('Prediction response status: ${response.statusCode}');
      print('Prediction response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return data['prediction'];
        } else {
          print('Prediction API returned success=false');
          return null;
        }
      } else {
        print('Prediction API error: ${response.statusCode} - ${response.body}');
        return null;
      }
      
    } catch (e) {
      print('Error calling prediction API: $e');
      return null;
    }
  }
  
  /// Format prediction for display
  String formatPredictionMessage(Map<String, dynamic> prediction) {
    final spaces = prediction['predicted_spaces'];
    final percentage = prediction['availability_percentage'];
    final garageName = prediction['garage_name'];
    final zoneType = prediction['zone_type'];
    
    String availabilityStatus;
    if (percentage >= 70) {
      availabilityStatus = 'EXCELLENT';
    } else if (percentage >= 40) {
      availabilityStatus = 'GOOD';
    } else if (percentage >= 15) {
      availabilityStatus = 'LIMITED';
    } else {
      availabilityStatus = 'VERY LIMITED';
    }
    
    return '''
Prediction for $garageName ($zoneType)

AVAILABILITY: $availabilityStatus
Estimated Spaces: $spaces
Availability: ${percentage.toStringAsFixed(1)}%''';
  }
  
  /// Test if the prediction API is running
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/decks');
      final response = await http.get(url);
      
      print('API Connection Test - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('API Connection Test - Error: $e');
      return false;
    }
  }
}