// Written by Tim Hudson - Last Updated 4/1/2025
// Written with the assistance of Openstack, Google Codelabs and ChatGPT

// This code is responsible for the traffic page that displays a value of how heavy the traffic is from a scale of low, medium and heavy
// It does this by taking the saved home address and the saved garage address from the database, and when the button is clicked, runs the script and siplays the result on the same page.

// This page can be accessed either logged in or logged out. The script will only function when logged in. This page is accessed through the navigation bar 


// Import the needed packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrafficPage extends StatefulWidget {
  const TrafficPage({super.key});

  @override
  _TrafficPageState createState() => _TrafficPageState();
}


class _TrafficPageState extends State<TrafficPage> {
  String _weatherInfo = "Fetching weather...";
  String _weatherAlert = "No alerts";
  bool _weatherLoading = false;
  List<Map<String, dynamic>> _forecast = [];
  bool _forecastLoading = false;


  Future<void> _fetchWeatherAndForecast() async {
    setState(() {
      _weatherLoading = true;
      _forecastLoading = true;
      _weatherInfo = "Fetching weather...";
      _weatherAlert = "No alerts";
      _forecast = [];
    });
    String weather = await getWeatherStatus();
    String alert = _checkWeatherAlert(weather);
    List<Map<String, dynamic>> forecast = await getWeatherForecast();
    setState(() {
      _weatherInfo = weather;
      _weatherAlert = alert;
      _weatherLoading = false;
      _forecast = forecast;
      _forecastLoading = false;
    });
  }


  Future<void> _fetchWeather() async {
    setState(() {
      _weatherLoading = true;
      _weatherInfo = "Fetching weather...";
      _weatherAlert = "No alerts";
    });
    String weather = await getWeatherStatus();
    String alert = _checkWeatherAlert(weather);
    setState(() {
      _weatherInfo = weather;
      _weatherAlert = alert;
      _weatherLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getWeatherForecast() async {
    try {
      const double lat = 38.4495;
      const double lon = -78.8690;
      const String apiKey = 'baafe52addb7f3b1397a36e85a1cf4e9';
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=imperial',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return [];
      }
      final data = json.decode(response.body);
      final List<dynamic> list = data['list'] ?? [];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      List<Map<String, dynamic>> forecasts = [];
      for (var entry in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch((entry['dt'] ?? 0) * 1000, isUtc: true).toLocal();
        if (dt.day == today.day) {
          final temp = entry['main']?['temp'];
          final desc = entry['weather']?[0]?['description'] ?? '';
          if (temp != null || (desc is String && desc.isNotEmpty)) {
            forecasts.add({
              'time': DateTime(today.year, today.month, today.day, dt.hour),
              'temp': temp,
              'desc': desc,
            });
          }
        }
      }
      return forecasts;
    } catch (e) {
      return [];
    }
  }

  Future<String> getWeatherStatus() async {
    try {
      const double lat = 38.4495;
      const double lon = -78.8690;
      const String apiKey = 'baafe52addb7f3b1397a36e85a1cf4e9';
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=imperial',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return "Failed to retrieve weather data (${response.statusCode})";
      }
      final data = json.decode(response.body);
      final String description = (data['weather'] != null && data['weather'].isNotEmpty)
          ? data['weather'][0]['description']
          : 'No description';
      final double temp = data['main'] != null && data['main']['temp'] != null
          ? data['main']['temp'].toDouble()
          : double.nan;
      String weatherString = '${description[0].toUpperCase()}${description.substring(1)}, ${temp.toStringAsFixed(1)}°F';
      if (data['alerts'] != null && data['alerts'] is List && data['alerts'].isNotEmpty) {
        final alert = data['alerts'][0];
        if (alert['event'] != null) {
          weatherString += '\nALERT: ${alert['event']}';
        }
      }
      return weatherString;
    } catch (e) {
      return "Error: $e";
    }
  }

  String _checkWeatherAlert(String weather) {
    if (weather.contains("snow") || weather.contains("Snow")) {
      return "⚠️ Snowy conditions!";
    } else if (weather.contains("rain") || weather.contains("Rain")) {
      return "⚠️ Rainy weather!";
    } else if (weather.contains("hot") || weather.contains("35°C")) {
      return "🔥 Extreme heat!";
    }
    return "No alerts";
  }

  Future<void> _fetchTrafficAndIncidents() async {
    setState(() {
      _trafficLoading = true;
      _incidentsLoading = true;
      _trafficInfo = "Fetching traffic...";
      _trafficAlert = "No alerts";
      _trafficIncidents = [];
    });
    String traffic = await getTrafficStatus();
    String alert = _checkTrafficAlert(traffic);
    List<Map<String, dynamic>> incidents = await getTrafficIncidents();
    setState(() {
      _trafficInfo = traffic;
      _trafficAlert = alert;
      _trafficLoading = false;
      _trafficIncidents = incidents;
      _incidentsLoading = false;
    });
  }

  Future<void> _fetchTraffic() async {
    setState(() {
      _trafficLoading = true;
      _trafficInfo = "Fetching traffic...";
      _trafficAlert = "No alerts";
    });
    String traffic = await getTrafficStatus();
    String alert = _checkTrafficAlert(traffic);
    setState(() {
      _trafficInfo = traffic;
      _trafficAlert = alert;
      _trafficLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getTrafficIncidents() async {
    try {
      // TomTom Traffic Incidents API for Harrisonburg area
      const String apiKey = 'YOUR_TOMTOM_API_KEY'; // Replace with actual TomTom API key
      const double lat = 38.4495;
      const double lon = -78.8690;
      const double radius = 10000; // 10km radius around JMU
      
      final url = Uri.parse(
        'https://api.tomtom.com/traffic/services/5/incidentDetails?key=$apiKey&bbox=${lon-0.1},${lat-0.1},${lon+0.1},${lat+0.1}&fields=incidents{type,geometry,properties{iconCategory,magnitudeOfDelay,events{description,code},startTime,endTime}}&language=en&categoryFilter=0,1,2,3,4,5,6,7,8,9,10,11,14',
      );
      
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return [];
      }
      
      final data = json.decode(response.body);
      final List<dynamic> incidents = data['incidents'] ?? [];
      List<Map<String, dynamic>> processedIncidents = [];
      
      for (var incident in incidents.take(5)) { // Limit to 5 incidents
        final properties = incident['properties'] ?? {};
        final events = properties['events'] ?? [];
        String description = 'Traffic incident';
        if (events.isNotEmpty && events[0]['description'] != null) {
          description = events[0]['description'];
        }
        
        processedIncidents.add({
          'description': description,
          'delay': properties['magnitudeOfDelay'] ?? 0,
          'category': properties['iconCategory'] ?? 0,
        });
      }
      return processedIncidents;
    } catch (e) {
      return [];
    }
  }

  Future<String> getTrafficStatus() async {
    try {
      // TomTom Traffic Flow API for general area traffic
      const String apiKey = 'W2nPBT8SqHnugaBP3Co8MWh58O8tVLCs'; // Replace with actual TomTom API key
      const double lat = 38.4495;
      const double lon = -78.8690;
      
      final url = Uri.parse(
        'https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/10/json?point=$lat,$lon&unit=mph&key=$apiKey',
      );
      
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return "Failed to retrieve traffic data (${response.statusCode})";
      }
      
      final data = json.decode(response.body);
      final flowSegmentData = data['flowSegmentData'];
      
      if (flowSegmentData != null) {
        final currentSpeed = flowSegmentData['currentSpeed'] ?? 0;
        final freeFlowSpeed = flowSegmentData['freeFlowSpeed'] ?? currentSpeed;
        final confidence = flowSegmentData['confidence'] ?? 0.5;
        
        String trafficLevel = _calculateTrafficLevel(currentSpeed.toDouble(), freeFlowSpeed.toDouble());
        String confidenceText = confidence > 0.7 ? "High confidence" : "Moderate confidence";
        
        return '$trafficLevel traffic conditions in Harrisonburg area. Current speed: ${currentSpeed}mph ($confidenceText)';
      } else {
        return "Traffic conditions: Normal flow expected in Harrisonburg area";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  String _calculateTrafficLevel(double currentSpeed, double freeFlowSpeed) {
    if (freeFlowSpeed == 0) return "Normal";
    
    double ratio = currentSpeed / freeFlowSpeed;
    if (ratio >= 0.8) {
      return "Light";
    } else if (ratio >= 0.5) {
      return "Moderate";
    } else {
      return "Heavy";
    }
  }

  String _checkTrafficAlert(String traffic) {
    if (traffic.contains("Heavy")) {
      return "🚗 Heavy traffic conditions!";
    } else if (traffic.contains("Moderate")) {
      return "⚠️ Moderate traffic delays";
    } else if (traffic.contains("Error") || traffic.contains("Failed")) {
      return "❌ Traffic data unavailable";
    }
    return "No alerts";
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _eventsLoading = true;
      _eventsInfo = "Fetching events...";
      _todaysEvents = [];
    });
    
    List<Map<String, dynamic>> events = await getCampusEvents();
    String eventsInfo = events.isEmpty ? "No campus events today" : "${events.length} campus event(s) today";
    
    setState(() {
      _eventsInfo = eventsInfo;
      _todaysEvents = events;
      _eventsLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getCampusEvents() async {
    try {
      // Using Cronofy API - replace 'YOUR_CRONOFY_API_KEY' with your actual API key
      const String apiKey = 'YOUR_CRONOFY_API_KEY';
      
      // Get today's date range
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final url = Uri.parse(
        'https://api.cronofy.com/v1/events?tzid=America/New_York&from=${startOfDay.toIso8601String()}&to=${endOfDay.toIso8601String()}',
      );
      
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      });
      
      if (response.statusCode != 200) {
        // Fallback to mock data for testing
        return _getMockEvents();
      }
      
      final data = json.decode(response.body);
      final List<dynamic> events = data['events'] ?? [];
      
      List<Map<String, dynamic>> processedEvents = [];
      for (var event in events) {
        final eventData = event['event'] ?? event;
        final startTime = eventData['start'];
        final summary = eventData['summary'] ?? eventData['title'];
        final location = eventData['location'];
        
        if (summary != null && summary.isNotEmpty) {
          String timeStr = 'TBD';
          if (startTime != null) {
            try {
              final dt = DateTime.parse(startTime['time'] ?? startTime['date_time'] ?? startTime.toString());
              final hour = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
              final ampm = dt.hour < 12 ? 'AM' : 'PM';
              timeStr = '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
            } catch (e) {
              timeStr = 'TBD';
            }
          }
          
          processedEvents.add({
            'title': summary,
            'time': timeStr,
            'location': location?['description'] ?? location?.toString(),
          });
        }
      }
      
      return processedEvents;
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockEvents();
    }
  }

  List<Map<String, dynamic>> _getMockEvents() {
    // Mock events for testing - remove when you have real API key
    final now = DateTime.now();
    switch (now.weekday) {
      case 1: // Monday
        return [{'title': 'Student Government Meeting', 'time': '6:00 PM', 'location': 'Taylor Hall'}];
      case 2: // Tuesday
        return [{'title': 'Career Fair', 'time': '10:00 AM - 4:00 PM', 'location': 'Festival Conference Center'}];
      case 3: // Wednesday
        return [{'title': 'Guest Lecture: Technology Innovation', 'time': '2:00 PM', 'location': 'ISAT Building'}];
      case 4: // Thursday
        return [{'title': 'Basketball Game vs. ODU', 'time': '7:00 PM', 'location': 'Convocation Center'}];
      case 5: // Friday
        return [{'title': 'Campus Movie Night', 'time': '8:00 PM', 'location': 'Grafton-Stovall Theatre'}];
      case 6: // Saturday
        return [{'title': 'Farmers Market', 'time': '9:00 AM - 1:00 PM', 'location': 'Festival Lawn'}];
      case 7: // Sunday
        return [{'title': 'Study Group Session', 'time': '7:00 PM', 'location': 'Carrier Library'}];
      default:
        return [];
    }
  }

  // Traffic-related variables
  String _trafficInfo = "Fetching traffic...";
  String _trafficAlert = "No alerts";
  bool _trafficLoading = false;
  List<Map<String, dynamic>> _trafficIncidents = [];
  bool _incidentsLoading = false;

  // Events-related variables
  String _eventsInfo = "Fetching events...";
  bool _eventsLoading = false;
  List<Map<String, dynamic>> _todaysEvents = [];

  // Placeholder for legacy variables
  String _trafficStatus = 'Traffic status will be displayed here...';
  String _homeAddress = 'Login to select these addresses';
  String _favoriteGarage = 'Login to select these addresses';
  late Timer _timer;

  // Google Map state
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(38.4392, -78.8749); // JMU campus
  // OG marker types and state
  BitmapDescriptor lotIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  BitmapDescriptor garageIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
  Set<Marker> residentLot = {
  Marker(
    markerId: const MarkerId("R1 Lot"),
    position: const LatLng(38.43730, -78.86554),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R1 Lot", snippet: "A Parking lot near the Village")),
  Marker(
    markerId: const MarkerId("R2 Lot"),
    position: const LatLng(38.43003, -78.87736),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R2 Lot", snippet: "A Parking lot near Xlabs")),
  Marker(
    markerId: const MarkerId("R3 Lot"),
    position: const LatLng(38.43863, -78.87984),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R3 Lot", snippet: "A Parking lot near the Quad")),
  Marker(
    markerId: const MarkerId("R6 Lot"),
    position: const LatLng(38.43009, -78.86627),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R6 Lot", snippet: "A Parking lot near the Paul Jennings")),
  Marker(
    markerId: const MarkerId("R8 Lot"),
    position: const LatLng(38.43862, -78.86392),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R8 Lot", snippet: "A Parking lot near the Village")),
  Marker(
    markerId: const MarkerId("R9 Lot"),
    position: const LatLng(38.44648, -78.87849),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R9 Lot", snippet: "A Parking lot near the Memorial Hall")),
  Marker(
    markerId: const MarkerId("R10 Lot"),
    position: const LatLng(38.42681, -78.87594),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R10 Lot", snippet: "A Parking lot near University Outpost")),
  Marker(
    markerId: const MarkerId("R13 Lot"),
    position: const LatLng(38.44423, -78.87717),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R13 Lot", snippet: "A Parking lot located near Memorial Hall")),
  Marker(
    markerId: const MarkerId("R14 Lot"),
    position: const LatLng(38.44371, -78.87641),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R14 Lot", snippet: "A Parking lot located near Grace Street Apts")),
  Marker(
    markerId: const MarkerId("R15 Lot"),
    position: const LatLng(38.44311, -78.87666),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R15 Lot", snippet: "A Parking lot located near Grace Street Apts")),
  Marker(
    markerId: const MarkerId("R16 Lot"),
    position: const LatLng(38.44337, -78.87721),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R16 Lot", snippet: "A Parking lot located near Grace Street Apts")),
  Marker(
    markerId: const MarkerId("R17 Lot"),
    position: const LatLng(38.43743, -78.87955),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R17 Lot", snippet: "A Small Parking lot near the Quad")),
  Marker(
    markerId: const MarkerId("R18 Lot"),
    position: const LatLng(38.43709, -78.87948),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R18 Lot", snippet: "A Small Parking lot near the Quad")),
  Marker(
    markerId: const MarkerId("R19 Lot"),
    position: const LatLng(38.43657, -78.87878),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R19 Lot", snippet: "A Small Parking lot near the Quad")),
  Marker(
    markerId: const MarkerId("R20 Lot"),
    position: const LatLng(38.43594, -78.87931),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "R20 Lot", snippet: "A Small Parking lot near the Quad")),
  };
  Set<Marker> commuterLot = {
  Marker(
    markerId: const MarkerId("C3 Lot"),
    position: const LatLng(38.43619, -78.86565),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "C3 Lot", snippet: "A Small Parking lot near the Longfield ")),
  Marker(
    markerId: const MarkerId("C4 Lot"),
    position: const LatLng(38.43816, -78.86598),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "C4 Lot", snippet: "A Parking lot near the Village")),
  Marker(
    markerId: const MarkerId("C5 Lot"),
    position: const LatLng(38.43380, -78.87110),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "C5 Lot", snippet: "A Parking lot near the College of Business")),
  Marker(
    markerId: const MarkerId("C8 Lot"),
    position: const LatLng(38.44574, -78.87798),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "C8 Lot", snippet: "A Parking lot near the Memorial Hall")),
  Marker(
    markerId: const MarkerId("C9 Lot"),
    position: const LatLng(38.43432, -78.86999),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "C9 Lot", snippet: "A Parking lot near Duke Dog Alley")),
  Marker(
    markerId: const MarkerId("C13 Lot"),
    position: const LatLng(38.44730, -78.87852),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: InfoWindow(title: "C13 Lot", snippet: "A Parking lot near Memorial Art Complex")),
  };
  Set<Marker> markerGarage = {
  Marker(
    markerId: const MarkerId("Warsaw Deck"),
    position: const LatLng(38.44065, -78.87756),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    infoWindow: InfoWindow(title: "Warsaw Deck", snippet: "A Parking Deck located near Forbes and the Quad")),
  Marker(
    markerId: const MarkerId("Chesapeake Deck"),
    position: const LatLng(38.44273, -78.87711),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    infoWindow: InfoWindow(title: "Chesapeake Deck", snippet: "A Parking Deck located near Forbes and Grace Street Apts")),
  Marker(
    markerId: const MarkerId("Grace Deck"),
    position: const LatLng(38.44121, -78.87790),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    infoWindow: InfoWindow(title: "Grace Deck", snippet: "A Parking Deck located near the Student Success Center")),
  Marker(
    markerId: const MarkerId("Ballard Deck"),
    position: const LatLng(38.43102, -78.85838),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    infoWindow: InfoWindow(title: "Ballard Deck", snippet: "A Parking Deck located near Festival and the AUBC")),
  Marker(
    markerId: const MarkerId("Champions Deck"),
    position: const LatLng(38.43487, -78.87400),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    infoWindow: InfoWindow(title: "Champions Deck", snippet: "A Parking Deck located near Bridgeforth Stadium")),
  Marker(
    markerId: const MarkerId("Mason Deck"),
    position: const LatLng(38.44131, -78.87197),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    infoWindow: InfoWindow(title: "Mason Deck", snippet: "A Parking Deck located near Student Success Center")),
  };
  List<String> markerTypes = ['All', 'Resident', 'Commuter', 'Garage'];
  String selectedType = 'All';
  Set<Marker> _markers = {};
  void filterMarkers(String setting) {
    Set<Marker> result = {};
    switch (setting) {
      case 'Resident':
        result = residentLot;
        break;
      case "Commuter":
        result = commuterLot;
        break;
      case 'Garage':
        result = markerGarage;
        break;
      case 'All':
        result = residentLot.union(markerGarage).union(commuterLot);
    }
    setState(() {
      _markers = result;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _homeAddress =
                userDoc['homeAddress'] ?? 'Login to select these addresses';
            _favoriteGarage = userDoc['favoriteGarage']['address'] ??
                'Login to select these addresses';
          });
        }
      } catch (e) {
        setState(() {
          _trafficStatus = "Error fetching user data: $e";
        });
      }
    } else {
      setState(() {
        _homeAddress = 'Login to set this addresses';
        _favoriteGarage = 'Login to set this addresses';
        _trafficStatus = 'Traffic status will be displayed here';
      });
    }
  }

  Future<void> _getTrafficStatus() async {
    // Replace old Google Directions logic with TomTom traffic data
    await _fetchTrafficAndIncidents();
  }

  void _startUserDataTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getUserData();
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    _startUserDataTimer();
    _markers = residentLot.union(markerGarage).union(commuterLot);
    _fetchWeatherAndForecast();
    _fetchTrafficAndIncidents();
    _fetchEvents();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        backgroundColor: const Color.fromRGBO(69, 0, 132, 1),
        foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campus Events Card
                    Card(
                      color: const Color.fromRGBO(247, 247, 249, 1),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.event, color: Color.fromRGBO(158, 158, 158, 1)),
                                const SizedBox(width: 8),
                                Text('Campus Events', style: Theme.of(context).textTheme.titleMedium),
                                const Spacer(),
                                _eventsLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : IconButton(
                                        icon: const Icon(Icons.refresh),
                                        tooltip: 'Refresh',
                                        onPressed: _fetchEvents,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_eventsInfo),
                            if (_todaysEvents.isNotEmpty) ...[
                              const Divider(),
                              Text('Today\'s Events:', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 120,
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: [
                                        for (final event in _todaysEvents)
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 6),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event['title'] ?? 'Campus Event',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '⏰ ${event['time'] ?? 'TBD'}',
                                                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                                                ),
                                                if (event['location'] != null)
                                                  Text(
                                                    '📍 ${event['location']}',
                                                    style: const TextStyle(fontSize: 11, color: Colors.green),
                                                  ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '📅 No events scheduled for today',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  children: [
                    // Traffic Card
                    Card(
                      color: const Color.fromRGBO(247, 247, 249, 1),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.traffic, color: Color.fromRGBO(158, 158, 158, 1)),
                                const SizedBox(width: 8),
                                Text('Traffic', style: Theme.of(context).textTheme.titleMedium),
                                const Spacer(),
                                _trafficLoading || _incidentsLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : IconButton(
                                        icon: const Icon(Icons.refresh),
                                        tooltip: 'Refresh',
                                        onPressed: _fetchTrafficAndIncidents,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_trafficInfo),
                            const SizedBox(height: 4),
                            Text(_trafficAlert, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (_trafficIncidents.isNotEmpty) ...[
                              const Divider(),
                              Text('Traffic Incidents:', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 60,
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: [
                                        for (final incident in _trafficIncidents)
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  incident['description'] ?? 'Traffic incident',
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (incident['delay'] > 0)
                                                  Text(
                                                    'Delay: ${incident['delay']} min',
                                                    style: const TextStyle(fontSize: 10, color: Colors.red),
                                                  ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Weather Card
                    Card(
                      color: const Color.fromRGBO(247, 247, 249, 1),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Row(
                          children: [
                            const Icon(Icons.cloud, color: Color.fromRGBO(158, 158, 158, 1)),
                            const SizedBox(width: 8),
                            Text('Weather', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            _weatherLoading || _forecastLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : IconButton(
                                    icon: const Icon(Icons.refresh),
                                    tooltip: 'Refresh',
                                    onPressed: _fetchWeatherAndForecast,
                                  ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_weatherInfo),
                        const SizedBox(height: 4),
                        Text(_weatherAlert, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (_forecast.isNotEmpty) ...[
                          const Divider(),
                          Text('Today\'s Forecast:', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 60,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Row(
                                  children: [
                                    for (final f in _forecast)
                                      Container(
                                        width: 70,
                                        margin: const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              (() {
                                                final dt = f['time'] as DateTime;
                                                final hour = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
                                                final ampm = dt.hour < 12 ? 'AM' : 'PM';
                                                return '$hour $ampm';
                                              })(),
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                            Text(
                                              (() {
                                                final desc = f['desc'] ?? '';
                                                return desc.isNotEmpty ? '${desc[0].toUpperCase()}${desc.substring(1)}' : '--';
                                              })(),
                                              style: const TextStyle(fontSize: 10),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              f['temp'] != null ? '${f['temp'].toStringAsFixed(1)}°F' : '--',
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]
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
    );
  }
}
