// Written by Rafael Margary - Last Updated 4/1/2025
// Written with the assistance of Openstack, Google Codelabs and ChatGPT

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../widgets/appbar_datetime_center.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late GoogleMapController mapController;
  bool _isMapReady = false;
  final LatLng _center = const LatLng(38.4392, -78.8749); // JMU campus
  bool _customIconsApplied = false;

    BitmapDescriptor lotIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  Set<Marker> residentLot = {
    Marker(
        markerId: const MarkerId("R1 Lot"),
        position: const LatLng(38.43730, -78.86554),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R1 Lot", snippet: "A Parking lot near the Village")),
    Marker(
        markerId: const MarkerId("R2 Lot"),
        position: const LatLng(38.43003, -78.87736),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow:
            const InfoWindow(title: "R2 Lot", snippet: "A Parking lot near Xlabs")),
    Marker(
        markerId: const MarkerId("R3 Lot"),
        position: const LatLng(38.43863, -78.87984),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R3 Lot", snippet: "A Parking lot near the Quad")),
    Marker(
        markerId: const MarkerId("R6 Lot"),
        position: const LatLng(38.43009, -78.86627),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R6 Lot", snippet: "A Parking lot near the Paul Jennings")),
    Marker(
        markerId: const MarkerId("R8 Lot"),
        position: const LatLng(38.43862, -78.86392),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R8 Lot", snippet: "A Parking lot near the Village")),
    Marker(
        markerId: const MarkerId("R9 Lot"),
        position: const LatLng(38.44648, -78.87849),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R9 Lot", snippet: "A Parking lot near the Memorial Hall")),
    Marker(
        markerId: const MarkerId("R10 Lot"),
        position: const LatLng(38.42681, -78.87594),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R10 Lot",
            snippet: "A Parking lot near University Outpost")),
    Marker(
        markerId: const MarkerId("R13 Lot"),
        position: const LatLng(38.44423, -78.87717),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R13 Lot",
            snippet: "A Parking lot located near Memorial Hall")),
    Marker(
        markerId: const MarkerId("R14 Lot"),
        position: const LatLng(38.44371, -78.87641),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R14 Lot",
            snippet: "A Parking lot located near Grace Street Apts")),
    Marker(
        markerId: const MarkerId("R15 Lot"),
        position: const LatLng(38.44311, -78.87666),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R15 Lot",
            snippet: "A Parking lot located near Grace Street Apts")),
    Marker(
        markerId: const MarkerId("R16 Lot"),
        position: const LatLng(38.44337, -78.87721),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R16 Lot",
            snippet: "A Parking lot located near Grace Street Apts")),
    Marker(
        markerId: const MarkerId("R17 Lot"),
        position: const LatLng(38.43743, -78.87955),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R17 Lot", snippet: "A Small Parking lot near the Quad")),
    Marker(
        markerId: const MarkerId("R18 Lot"),
        position: const LatLng(38.43709, -78.87948),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R18 Lot", snippet: "A Small Parking lot near the Quad")),
    Marker(
        markerId: const MarkerId("R19 Lot"),
        position: const LatLng(38.43657, -78.87878),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R19 Lot", snippet: "A Small Parking lot near the Quad")),
    Marker(
        markerId: const MarkerId("R20 Lot"),
        position: const LatLng(38.43594, -78.87931),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
            title: "R20 Lot", snippet: "A Small Parking lot near the Quad")),
  };
  Set<Marker> commuterLot = {
    Marker(
        markerId: const MarkerId("C3 Lot"),
        position: const LatLng(38.43619, -78.86565),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(
            title: "C3 Lot",
            snippet: "A Small Parking lot near the Longfield ")),
    Marker(
        markerId: const MarkerId("C4 Lot"),
        position: const LatLng(38.43816, -78.86598),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(
            title: "C4 Lot", snippet: "A Parking lot near the Village")),
    Marker(
        markerId: const MarkerId("C5 Lot"),
        position: const LatLng(38.43380, -78.87110),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(
            title: "C5 Lot",
            snippet: "A Parking lot near the College of Business")),
    Marker(
        markerId: const MarkerId("C8 Lot"),
        position: const LatLng(38.44574, -78.87798),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(
            title: "C8 Lot", snippet: "A Parking lot near the Memorial Hall")),
    Marker(
        markerId: const MarkerId("C9 Lot"),
        position: const LatLng(38.43432, -78.86999),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(
            title: "C9 Lot", snippet: "A Parking lot near Duke Dog Alley")),
    Marker(
        markerId: const MarkerId("C13 Lot"),
        position: const LatLng(38.44730, -78.87852),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(
            title: "C13 Lot",
            snippet: "A Parking lot near Memorial Art Complex")),
  };
  Set<Marker> markerGarage = {
    Marker(
        markerId: const MarkerId("Warsaw Deck"),
        position: const LatLng(38.44065, -78.87756),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
            title: "Warsaw Deck",
            snippet: "A Parking Deck located near Forbes and the Quad")),
    Marker(
        markerId: const MarkerId("Chesapeake Deck"),
        position: const LatLng(38.44273, -78.87711),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
            title: "Chesapeake Deck",
            snippet:
                "A Parking Deck located near Forbes and Grace Street Apts")),
    Marker(
        markerId: const MarkerId("Grace Deck"),
        position: const LatLng(38.44121, -78.87790),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
            title: "Grace Deck",
            snippet: "A Parking Deck located near the Student Success Center")),
    Marker(
        markerId: const MarkerId("Ballard Deck"),
        position: const LatLng(38.43102, -78.85838),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
            title: "Ballard Deck",
            snippet: "A Parking Deck located near Festival and the AUBC")),
    Marker(
        markerId: const MarkerId("Champions Deck"),
        position: const LatLng(38.43487, -78.87400),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
            title: "Champions Deck",
            snippet: "A Parking Deck located near Bridgeforth Stadium")),
    Marker(
        markerId: const MarkerId("Mason Deck"),
        position: const LatLng(38.44131, -78.87197),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
            title: "Mason Deck",
            snippet: "A Parking Deck located near Student Success Center")),
  };

  List<String> markerTypes = ['All', 'Resident', 'Commuter', 'Garage'];
  String selectedType = 'All';
  Set<Marker> _markers = {};

  Set<Marker> _markersForCategory(String setting) {
    switch (setting) {
      case 'Resident':
        return residentLot;
      case "Commuter":
        return commuterLot;
      case 'Garage':
        return markerGarage;
      case 'All':
        return residentLot.union(markerGarage).union(commuterLot);
      default:
        return residentLot.union(markerGarage).union(commuterLot);
    }
  }

  List<Marker> _sortedMarkersForCategory(String category) {
    final markerList = _markersForCategory(category).toList();
    markerList.sort((a, b) => a.markerId.value.compareTo(b.markerId.value));
    return markerList;
  }

  Color _iconColorForMarker(Marker marker) {
    final markerId = marker.markerId.value;
    if (commuterLot
        .any((commuterMarker) => commuterMarker.markerId.value == markerId)) {
      return Colors.yellow.shade700;
    }
    if (markerGarage.any((garageMarker) => garageMarker.markerId.value == markerId)) {
      return Colors.red.shade700;
    }
    return Colors.blue;
  }

  Future<BitmapDescriptor> _createMarkerIcon(Color color) async {
    const double size = 64;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const double centerX = size / 2;
    const double headCenterY = 23;
    const double headRadius = 13;
    const double tailTopY = 31;
    const double tailTipY = 59;

    final Paint headPaint = Paint()..color = color;
    final Paint tailPaint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final Paint centerDotPaint = Paint()..color = Colors.white;

    final Path tailPath = Path()
      ..moveTo(centerX - 8, tailTopY)
      ..lineTo(centerX, tailTipY)
      ..lineTo(centerX + 8, tailTopY)
      ..close();

    canvas.drawPath(tailPath, tailPaint);
    canvas.drawPath(tailPath, borderPaint);

    canvas.drawCircle(const Offset(centerX, headCenterY), headRadius, headPaint);
    canvas.drawCircle(const Offset(centerX, headCenterY), headRadius, borderPaint);
    canvas.drawCircle(const Offset(centerX, headCenterY), 4.5, centerDotPaint);

    final ui.Image image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
    );
  }

  Future<void> _applyCustomMarkerIcons() async {
    if (_customIconsApplied) {
      return;
    }

    final BitmapDescriptor residentIcon =
        await _createMarkerIcon(Colors.blue.shade700);
    final BitmapDescriptor commuterIcon =
        await _createMarkerIcon(Colors.yellow.shade700);
    final BitmapDescriptor garageIcon =
        await _createMarkerIcon(Colors.red.shade700);

    if (!mounted) {
      return;
    }

    setState(() {
      residentLot = residentLot
          .map((marker) => marker.copyWith(iconParam: residentIcon))
          .toSet();
      commuterLot = commuterLot
          .map((marker) => marker.copyWith(iconParam: commuterIcon))
          .toSet();
      markerGarage = markerGarage
          .map((marker) => marker.copyWith(iconParam: garageIcon))
          .toSet();
      _markers = _markersForCategory(selectedType);
      _customIconsApplied = true;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedType = category;
      _markers = _markersForCategory(category);
    });
  }

  void _focusMarker(Marker marker) {
    if (_isMapReady) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(marker.position, 17),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _isMapReady = true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _markers = _markersForCategory(selectedType);
      });
    });
    _applyCustomMarkerIcons();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double topPanelInset = mediaQuery.padding.top + kToolbarHeight + 12;
    final double bottomPanelInset = mediaQuery.padding.bottom + 12;
    const double panelVerticalOffset = 0;
    final double pageHorizontalPadding =
      (mediaQuery.size.width * 0.02).clamp(12.0, 28.0).toDouble();
    final double containerWidth =
      (mediaQuery.size.width * 0.80).clamp(320.0, 1100.0).toDouble();
    final List<Marker> visibleMarkers = _sortedMarkersForCategory(selectedType);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Map',
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
                    content: const Text('The Map page allows you to view the locations of JMU parking lots and garages on an interactive map.'),
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
      body: SizedBox.expand(
        child: Container(
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
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPanelInset,
                  left: pageHorizontalPadding,
                  right: pageHorizontalPadding,
                  bottom: bottomPanelInset,
                ),
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, panelVerticalOffset),
                    child: SizedBox(
                      width: containerWidth,
                      child: Row(
                        children: [
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
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 132,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final menuWidth = constraints.maxWidth;
                                        return DropdownMenu<String>(
                                          initialSelection: selectedType,
                                          hintText: 'Filter',
                                          width: menuWidth,
                                          menuHeight: 48.0 * markerTypes.length,
                                          menuStyle: const MenuStyle(
                                            alignment: Alignment.bottomLeft,
                                          ),
                                          inputDecorationTheme: const InputDecorationTheme(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          ),
                                          dropdownMenuEntries: markerTypes
                                              .map((type) => DropdownMenuEntry<String>(
                                                    value: type,
                                                    label: type,
                                                  ))
                                              .toList(),
                                          onSelected: (value) {
                                            if (value != null) {
                                              _onCategorySelected(value);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 6),
                                      itemCount: visibleMarkers.length,
                                      itemBuilder: (context, index) {
                                        final marker = visibleMarkers[index];
                                        return ListTile(
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          contentPadding:
                                              const EdgeInsets.symmetric(horizontal: 6),
                                          leading: Icon(
                                            Icons.location_on,
                                            color: _iconColorForMarker(marker),
                                            size: 20,
                                          ),
                                          title: Text(
                                            marker.markerId.value,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          onTap: () => _focusMarker(marker),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
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
