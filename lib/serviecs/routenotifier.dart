import 'package:flutter/material.dart';

class RouteNotifier extends ChangeNotifier {
  String _currentRoute = 'Login';

  String get currentRoute => _currentRoute;

  void updateRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }
}
