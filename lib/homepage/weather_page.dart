// Written by Tim Hudson - Last Updated 4/1/2025
// Written with the assistance of Openstack, Google Codelabs and ChatGPT

// This code is responsible for the weather report script that is displayed.
// This code runs a web scrape to gather a weather report from the weather-forecast.com every hour. When the weather alerts button on the home screen is clicked it displays a weather report for harrsionburg
// This page is accessed from the "weather alerts" button on the home page, it does not require a user to be sgined in


// import the necessary packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;


// WeatherPage is stateful
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _weatherStatus = "Fetching weather data...";
  String? _weatherAlert;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchWeather(); // Fetch initial data
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchWeather(); // Automatically update weather every hour
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer to prevent memory leaks
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    String weather = await getWeatherStatus();
    setState(() {
      _weatherStatus = weather; // Ensure UI updates with new weather
      _checkForWeatherAlert(weather);
    });
  }

  void _checkForWeatherAlert(String weather) {
    if (weather.toLowerCase().contains("snow")) {
      _weatherAlert = "⚠️ Weather Alert: Be cautious due to snowy road conditions!";
    } else if (weather.toLowerCase().contains("rain")) {
      _weatherAlert = "⚠️ Weather Alert: Be cautious due to rainy road conditions!";
    } else if (_containsExcessiveHeat(weather)) {
      _weatherAlert = "🔥 Weather Alert: Extreme heat. Stay hydrated!";
    } else {
      _weatherAlert = null; // Clear alert if no condition is met
    }
    if (mounted) {
    setState(() {}); // Force UI update
  }
}

  bool _containsExcessiveHeat(String weather) {
    RegExp heatRegEx = RegExp(r'\b(\d+)\s*(°F)\b'); // Updated to detect °F
    final match = heatRegEx.firstMatch(weather);
    if (match != null) {
      final temperature = int.parse(match.group(1)!);
      if (temperature > 95) { // Adjusted threshold for Fahrenheit
        return true;
      }
    }
    return false;
  }

  Future<String> getWeatherStatus() async {
    try {
      final url = Uri.parse("https://www.weather-forecast.com/locations/Harrisonburg/forecasts/latest");
      final response = await http.get(url, headers: {"User-Agent": "Mozilla/5.0"});

      if (response.statusCode != 200) {
        return "Failed to retrieve weather data";
      }

      final document = html.parse(response.body);
      final weatherSection = document.querySelector("span.b-forecast__table-description-content");
      if (weatherSection != null) {
        String weatherText = weatherSection.text.trim();
        return _convertCelsiusToFahrenheitInText(weatherText);
      } else {
        return "Weather data not found.";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  String _convertCelsiusToFahrenheitInText(String weatherText) {
    RegExp celsiusPattern = RegExp(r'(\d+)\s*°C'); // Matches "XX°C"

    return weatherText.replaceAllMapped(celsiusPattern, (match) {
      int celsius = int.parse(match.group(1)!);
      int fahrenheit = ((celsius * 9/5) + 32).round();
      return "$fahrenheit°F"; // Replace with Fahrenheit
    });
  }

  // builds the actual UI for the App
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Information"),
        backgroundColor: const Color(0xFFB599CE),
      ),
      backgroundColor: const Color(0xFF2C2C2C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_weatherAlert != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _weatherAlert!,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
            ],
            const Text(
              'Weather Report',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10, width: double.infinity),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey<String>(_weatherStatus), // Ensure rebuild on change
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFB599CE)),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFB599CE),
                ),
                child: Text(
                  _weatherStatus,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
