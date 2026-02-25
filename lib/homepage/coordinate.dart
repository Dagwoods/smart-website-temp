// Written by Rafael Margary - Last Updated 4/9/2025
// Written with the assistance of Openstack and ChatGPT

import 'dart:math';

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate(this.latitude, this.longitude);

  // Haversine formula to calculate distance between two coordinates in kilometers
  double distanceTo(Coordinate other) {
    const earthRadius = 6371; // Radius of the Earth in kilometers

    double lat1 = toRadians(latitude);
    double lon1 = toRadians(longitude);
    double lat2 = toRadians(other.latitude);
    double lon2 = toRadians(other.longitude);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  // Convert degrees to radians
  double toRadians(double degree) {
    return degree * pi / 180;
  }

  //Print the Latitude and Longitude of Coordinate Object
  @override
  String toString() {
    return latitude.toString() + longitude.toString();
  }

  //Compares two Coordinates to see if they have the same Latitude and Longitude
  bool isEqual(Coordinate two) {
    return (longitude == two.longitude && latitude == two.latitude);
  }
}
