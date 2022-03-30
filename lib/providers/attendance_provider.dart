import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;

class AttendanceProvider with ChangeNotifier {
  LatLng _kwasuLatLng = LatLng(8.508, 4.585);
  LatLng get kwasuLatLng => _kwasuLatLng;
  StreamSubscription<Position> _positionStream;

  Position _currentPosition;
  Position get currentPosition => _currentPosition;

  LatLng _currentLatLng;
  LatLng get currentLatLng => _currentLatLng;

  getCurrentLatLng() async {
    _positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen((Position position) {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      _currentPosition = position;
      _currentLatLng = LatLng(position.latitude, position.longitude);
      notifyListeners();
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  bool checkDistance() {
    var totalDistance = calculateDistance(
        _kwasuLatLng.latitude,
        _kwasuLatLng.longitude,
        _currentLatLng.latitude,
        _currentLatLng.longitude);

    if (totalDistance > 2) {
      return false;
    }
    return true;
  }
}
