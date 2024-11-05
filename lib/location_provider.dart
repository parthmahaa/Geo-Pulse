import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class LocationProvider with ChangeNotifier {
  bool _isInProximity = false;

  bool get isInProximity => _isInProximity;

  // Constructor to listen to updates from the background service
  LocationProvider() {
    FlutterBackgroundService().on('updateProximity').listen((event) {
      if (event != null && event['isInProximity'] is bool) {
        _isInProximity = event['isInProximity'];
        notifyListeners();
      }
    });
  }

  //
}
