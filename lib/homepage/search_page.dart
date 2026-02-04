// Written by Rafael Margary - Last Updated 4/1/2025
// Written with the assistance of Openstack, Google Codelabs and ChatGPT

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(38.4392, -78.8749); // JMU campus

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _markers = residentLot.union(markerGarage).union(commuterLot);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: const Color.fromRGBO(69, 0, 132, 1),
        foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedType,
              items: markerTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedType = value;
                  filterMarkers(value);
                }
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15.5,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
            ),
          ),
        ],
      ),
    );
  }
}
