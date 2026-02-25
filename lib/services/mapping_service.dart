import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MappingService {
  static const String _baseUrl = 'https://api.openrouteservice.org';
  static const String _apiKey = ApiConfig.openRouteServiceApiKey;
  
  Future<bool> testApiKey() async {
    try {
      final url = Uri.parse('$_baseUrl/v2/directions/driving-car');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'coordinates': [
            [-78.8689, 38.4331],
            [-78.8676, 38.4344],
          ],
        }),
      );
      
      print('API Test - Status: ${response.statusCode}');
      print('API Test - Response: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('API Test - Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRouteInfo(String origin, String destination) async {
    print('Getting route from "$origin" to "$destination"');
    
    try {
      print('Geocoding addresses...');
      final originCoords = await _geocodeAddress(origin);
      final destCoords = await _geocodeAddress(destination);
      
      print('Origin coords: $originCoords');
      print('Destination coords: $destCoords');
      
      if (originCoords == null || destCoords == null) {
        print('Failed to geocode addresses');
        return null;
      }

      final url = Uri.parse('$_baseUrl/v2/directions/driving-car');
      
      print('Making API request to OpenRouteService...');
      final requestBody = {
        'coordinates': [
          [originCoords['lng'], originCoords['lat']],
          [destCoords['lng'], destCoords['lat']],
        ],
      };
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final route = data['routes'][0];
        final summary = route['summary'];
        
        final result = {
          'duration_minutes': (summary['duration'] / 60).round(),
          'distance_km': (summary['distance'] / 1000).round(),
          'origin_coords': originCoords,
          'destination_coords': destCoords,
        };
        
        print('Route calculated successfully: $result');
        return result;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting route info: $e');
      return null;
    }
  }
  
  Future<Map<String, double>?> _geocodeAddress(String address) async {
    try {
      print('Geocoding via OpenRouteService: "$address"');
      
      final url = Uri.parse('$_baseUrl/geocode/search')
          .replace(queryParameters: {
        'api_key': _apiKey,
        'text': address,
        'size': '1',
      });
      
      final response = await http.get(url);
      
      print('Geocoding response status: ${response.statusCode}');
      print('Geocoding response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List;
        
        if (features.isNotEmpty) {
          final coordinates = features[0]['geometry']['coordinates'];
          final Map<String, double> result = {
            'lat': coordinates[1].toDouble(),
            'lng': coordinates[0].toDouble(),
          };
          print('Geocoded successfully: $result');
          return result;
        } else {
          print('No geocoding results found for "$address"');
          return null;
        }
      } else {
        print('Geocoding API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Geocoding error for "$address": $e');
      return null;
    }
  }
  
  DateTime calculateArrivalTime(int travelMinutes) {
    return DateTime.now().add(Duration(minutes: travelMinutes));
  }
  
  String formatArrivalTime(DateTime arrivalTime) {
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }
  
  static const Map<String, String> jmuParkingGarages = {
    'Chesapeake Hall Parking Deck': '395 S Main St, Harrisonburg, VA 22807',
    'Grace Street Parking Deck': '721 Grace St, Harrisonburg, VA 22807', 
    'Warsaw Avenue Parking Deck': '198 Warsaw Ave, Harrisonburg, VA 22807',
    'Champions Drive Parking Deck': '261 Champions Dr, Harrisonburg, VA 22807',
    'Ballard Hall Parking Deck': '298 Bluestone Dr, Harrisonburg, VA 22807',
    'Mason Parking Deck': '715 S Mason St, Harrisonburg, VA 22801',
  };
  
  String? getGarageAddress(String garageName) {
    if (jmuParkingGarages.containsKey(garageName)) {
      return jmuParkingGarages[garageName];
    }
    
    for (String key in jmuParkingGarages.keys) {
      if (key.toLowerCase().contains(garageName.toLowerCase()) || 
          garageName.toLowerCase().contains(key.toLowerCase())) {
        return jmuParkingGarages[key];
      }
    }
    
    return garageName;
  }
}