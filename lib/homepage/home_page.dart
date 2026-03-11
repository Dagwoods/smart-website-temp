import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'parkingDeck.dart';
import 'weather_page.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'parkingMethods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/appbar_datetime_center.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

int mode1 = 1;
Key key1 = UniqueKey();
int mode2 = 1;
int mode3 = 1;
int mode4 = 1;
int mode5 = 1;
int mode6 = 2;
//Color of Google Map Icons
BitmapDescriptor lotIcon =
    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
BitmapDescriptor garageIcon =
    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
/*
Future<void> launchGoogleMaps(double latitude, double longitude) async {
  final Uri googleMapsUrl = Uri(
    scheme: 'https',
    host: 'www.google.com',
    path: 'maps/search/',
    queryParameters: {'api': '1', 'query': '$latitude,$longitude'},
  );

  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl);
  } else {
    print('Could not launch Google Maps: $googleMapsUrl');
  }
}

late Set<Marker> markers;
List<String> markerTypes = ['All', 'Resident', 'Commuter', 'Garage'];
String selectedType = 'All';

// Resident and Commuter Parking Lot data
Set<Marker> residentLot = {
  Marker(
      markerId: const MarkerId("R1 Lot"),
      position: const LatLng(38.43730, -78.86554),
      icon: lotIcon,
      infoWindow: InfoWindow(
          title: "R1 Lot",
          snippet: "A Parking lot near the Village",
          onTap: () {
            launchGoogleMaps(38.43730, -78.86554);
          })),
  // ... (other resident markers remain unchanged) ...
  Marker(
      markerId: const MarkerId("R20 Lot"),
      position: const LatLng(38.43594, -78.87931),
      icon: lotIcon,
      infoWindow: const InfoWindow(
        title: "R20 Lot",
        snippet: "A Small Parking lot near the Quad",
      ),
      onTap: () {
        launchGoogleMaps(38.43594, -78.87931);
      }),
};

Set<Marker> commuterLot = {
  Marker(
      markerId: const MarkerId("C3 Lot"),
      position: const LatLng(38.43619, -78.86565),
      icon: lotIcon,
      infoWindow: const InfoWindow(
        title: "C3 Lot",
        snippet: "A Small Parking lot near the Longfield ",
      ),
      onTap: () {
        launchGoogleMaps(38.43619, -78.86565);
      }),
  // ... (other commuter markers) ...
};

Set<Marker> markerGarage = {
  Marker(
      markerId: const MarkerId("Warsaw Deck"),
      position: const LatLng(38.44065, -78.87756),
      icon: garageIcon,
      infoWindow: const InfoWindow(
        title: "Warsaw Deck",
        snippet: "A Parking Deck located near Forbes and the Quad",
      ),
      onTap: () {
        launchGoogleMaps(38.44065, -78.87756);
      }),
  // ... (other garage markers) ...
};
*/
class HomePageState extends State<HomePage> {
  String _weatherStatus = "Fetching weather...";
  String _weatherAlert = "No alerts";
  Timer? _refreshTimer;

  late List<Container> commuter;
  Future<Map<int, int>?> globalValues = fetchAll();

  late GoogleMapController mapController;

  // Optional image asset paths for each box. Leave empty strings to show a placeholder.
  Map<String, String> boxImagePaths = {
    'ballard': 'assets/images/ballard.png',
    'grace': 'assets/images/grace.png',
    'warsaw': 'assets/images/warsaw.png',
    'chesapeake': 'assets/images/chesapeake.png',
    'champions': 'assets/images/champions.png',
    'mason': 'assets/images/mason.png',
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /*Future<void> _fetchWeather() async {
    if (!mounted) return;
    setState(() {
      _weatherStatus = "Fetching weather data...";
    });

    String weather = await getWeatherStatus();
    String alert = _checkWeatherAlert(weather);

    if (!mounted) return;
    setState(() {
      _weatherStatus = weather;
      _weatherAlert = alert;
    });
  }*/

  Future<String> getWeatherStatus() async {
    try {
      final url = Uri.parse(
          "https://www.weather-forecast.com/locations/Harrisonburg/forecasts/latest");
      final response =
          await http.get(url, headers: {"User-Agent": "Mozilla/5.0"});

      if (response.statusCode != 200) {
        return "Failed to retrieve weather data";
      }

      final document = html.parse(response.body);
      final weatherSection = document.querySelector("span.phrase");

      if (weatherSection != null) {
        return weatherSection.text.trim();
      } else {
        return "Weather data not found.";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  /*String _checkWeatherAlert(String weather) {
    if (weather.contains("snow") || weather.contains("Snow")) {
      return "⚠️ Snowy conditions!";
    } else if (weather.contains("rain") || weather.contains("Rain")) {
      return "⚠️ Rainy weather!";
    } else if (weather.contains("hot") || weather.contains("35°C")) {
      return "🔥 Extreme heat!";
    }
    return "No alerts";
  }*/

  void _navigateToWeatherPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeatherPage()),
    );
  }

  // Builds the inner content of a commuter card: left image (or placeholder) and
  // right-side column with title and the existing FutureBuilder that renders mode counters.
  Widget _cardBody(
      String keyPrefix, Future<Map<int, int>?> future, String title,
      {double imageWidth = 80}) {
    final String imagePath = boxImagePaths[keyPrefix] ?? '';
    return Row(
      children: [
        const SizedBox(width: 18), // Add space from left edge
        Container(
          width: imageWidth * 1.5, // Make image even larger
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imagePath.isNotEmpty
                ? Center(
                    child: Image.asset(
                      imagePath,
                      width: imageWidth * 1.5,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 2,
                  fontSize: 22,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: FutureBuilder(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data is Map<int, int>) {
                        return _buildAllModesFor(
                            keyPrefix, snapshot.data as Map<int, int>);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: build widgets for all available modes (1..4) for a location
  Widget _buildAllModesFor(String keyPrefix, Map<int, int> data) {
    final List<Widget> modeWidgets = [];
    for (int m = 1; m <= 4; m++) {
      final String type = translateType(m);
      final int id = translateId(keyPrefix + type);
      final int? value = data.containsKey(id) ? data[id] : null;

      if (value == null) {
        continue;
      }

      modeWidgets.add(Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value <= 0 ? "FULL" : value.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(
                height: 1.2,
                fontSize: 26,
                color: translateColor(type),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              type,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
          ],
        ),
      ));
    }

    if (modeWidgets.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        runSpacing: 6,
        children: modeWidgets,
      ),
    );
  }

  Future<void> loadData() async {
    final newValues = fetchAll();

    // Update commuter list using the fresh future (will rebuild cards with new FutureBuilder)
    if (!mounted) return;
    setState(() {
      commuter = [
        // Ballard
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]),
            child: GestureDetector(
                onTap: () => loadData(), // single tap refresh — no cycling
                child: Card(
                  margin: EdgeInsets.zero,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    child: SizedBox(
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Card body handles image (placeholder) + title + future counters
                                Expanded(
                                  child: _cardBody(
                                      "ballard", newValues, "Ballard",
                                      imageWidth: 180),
                                ),
                              ],
                            )))))),
        // Grace
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]),
            child: GestureDetector(
                onTap: () => loadData(),
                child: Card(
                margin: EdgeInsets.zero,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    child: SizedBox(
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _cardBody("grace", newValues, "Grace",
                                      imageWidth: 180),
                                ),
                              ],
                            )))))),
        // Warsaw
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]),
            child: GestureDetector(
                onTap: () => loadData(),
                child: Card(
                margin: EdgeInsets.zero,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    child: SizedBox(
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _cardBody(
                                      "warsaw", newValues, "Warsaw",
                                      imageWidth: 180),
                                ),
                              ],
                            )))))),
        // Chesapeake
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]),
            child: GestureDetector(
                onTap: () => loadData(),
                child: Card(
                margin: EdgeInsets.zero,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    child: SizedBox(
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _cardBody(
                                      "chesapeake", newValues, "Chesapeake",
                                      imageWidth: 180),
                                ),
                              ],
                            )))))),
        // Champions
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]),
            child: GestureDetector(
                onTap: () => loadData(),
                child: Card(
                margin: EdgeInsets.zero,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    child: SizedBox(
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _cardBody(
                                      "champions", newValues, "Champions",
                                      imageWidth: 180),
                                ),
                              ],
                            )))))),
        // Mason
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]),
            child: GestureDetector(
                onTap: () => loadData(),
                child: Card(
                margin: EdgeInsets.zero,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    child: SizedBox(
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _cardBody("mason", newValues, "Mason",
                                      imageWidth: 180),
                                ),
                              ],
                            )))))),
      ];
    });
  }
/*
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
      markers = result;
    });
  }
*/
  @override
  void initState() {
    super.initState();
    ///markers = residentLot.union(markerGarage).union(commuterLot);

    // Build initial commuter list using globalValues and same card structure
    commuter = [
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
          child: GestureDetector(
              onTap: () => loadData(),
              child: Card(
                margin: EdgeInsets.zero,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Ballard",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1,
                                    fontSize: 18,
                                    color: Color.fromRGBO(0, 0, 0, 1)),
                              ),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 0),
                                      child: FutureBuilder(
                                          future: globalValues,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData &&
                                                snapshot.data
                                                    is Map<int, int>) {
                                              return _buildAllModesFor(
                                                  "ballard",
                                                  snapshot.data
                                                      as Map<int, int>);
                                            } else {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                          }))),
                            ],
                          )))))),
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
          child: GestureDetector(
              onTap: () => loadData(),
              child: Card(
                margin: EdgeInsets.zero,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Grace",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 2,
                                    fontSize: 22,
                                    color: Color.fromRGBO(0, 0, 0, 1)),
                              ),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 0),
                                      child: FutureBuilder(
                                          future: globalValues,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData &&
                                                snapshot.data
                                                    is Map<int, int>) {
                                              return _buildAllModesFor(
                                                  "grace",
                                                  snapshot.data
                                                      as Map<int, int>);
                                            } else {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                          }))),
                            ],
                          )))))),
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
          child: GestureDetector(
              onTap: () => loadData(),
              child: Card(
                margin: EdgeInsets.zero,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Warsaw",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 2,
                                    fontSize: 22,
                                    color: Color.fromRGBO(0, 0, 0, 1)),
                              ),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 0),
                                      child: FutureBuilder(
                                          future: globalValues,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData &&
                                                snapshot.data
                                                    is Map<int, int>) {
                                              return _buildAllModesFor(
                                                  "warsaw",
                                                  snapshot.data
                                                      as Map<int, int>);
                                            } else {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                          }))),
                            ],
                          )))))),
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
          child: GestureDetector(
              onTap: () => loadData(),
              child: Card(
                margin: EdgeInsets.zero,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _cardBody(
                                    "chesapeake", globalValues, "Chesapeake",
                                    imageWidth: 180),
                              ),
                            ],
                          )))))),
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
          child: GestureDetector(
              onTap: () => loadData(),
              child: Card(
                margin: EdgeInsets.zero,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _cardBody(
                                    "champions", globalValues, "Champions",
                                    imageWidth: 180),
                              ),
                            ],
                          )))))),
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
          child: GestureDetector(
              onTap: () => loadData(),
              child: Card(
                margin: EdgeInsets.zero,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _cardBody("mason", globalValues, "Mason",
                                    imageWidth: 180),
                              ),
                            ],
                          )))))),
    ];

    loadData();

    /*// Fetch weather immediately and set up periodic updates
    _fetchWeather();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      _fetchWeather();
      loadData();
    });*/
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    double padding = screenWidth * 0.02;
    final double topPadding = mediaQuery.padding.top + kToolbarHeight + 12;
    final double bottomPadding = mediaQuery.padding.bottom + 12;
    double carouselHeight = screenHeight * 0.3;
    double mapHeight = screenHeight * 0.30;
    double mapWidth = screenWidth * 0.85;
    double buttonWidth = screenWidth * 0.45;
    double buttonHeight = screenWidth * 0.10;
    final double containerWidth =
      (screenWidth * 0.80).clamp(320.0, 1100.0).toDouble();

    if (screenWidth < 400) {
      carouselHeight = screenHeight * 0.35;
      mapHeight = screenHeight * 0.28;
      mapWidth = screenWidth * 0.60;
      buttonWidth = screenWidth * 0.30;
      buttonHeight = screenHeight * 0.08;
    }
    if (screenWidth < 600) {
      carouselHeight = screenHeight * 0.25;
      mapHeight = screenHeight * 0.28;
      mapWidth = screenWidth * 0.66;
      buttonWidth = screenWidth * 0.40;
    } else if (screenWidth >= 600 && screenWidth < 900) {
      carouselHeight = screenHeight * 0.38;
      mapHeight = screenHeight * 0.30;
      mapWidth = screenWidth * 0.85;
      buttonWidth = screenWidth * 0.42;
    } else {
      carouselHeight = screenHeight * 0.25;
      mapHeight = screenHeight * 0.35;
      mapWidth = screenWidth * 0.80;
      buttonWidth = screenWidth * 0.45;
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Live Counter',
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
                    content: const Text('The Live Counter page provides real-time parking availability for JMU commuter lots. Each card represents a different lot, showing the number of available spaces for each parking type (commuter, faculty, accessible, electric).'),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding)
                  .copyWith(top: topPadding, bottom: bottomPadding),
              child: Center(
                child: SizedBox(
                  height: double.infinity,
                  width: containerWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PageView(
                      children: [
                        GridView.count(
                          padding: const EdgeInsets.all(10),
                          crossAxisCount: 1,
                          shrinkWrap: true,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                          childAspectRatio: 3.4286,
                          children: commuter,
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

  int increaseMode(String title, int mode) {
    if (mode == 4) {
      mode = 1;
    } else {
      mode = mode + 1;
    }

    if (translateId(title + translateType(mode)) == 0) {
      return increaseMode(title, mode);
    }
    return mode;
  }
}
