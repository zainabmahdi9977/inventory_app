import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:inventory_app/serviecs/dialog.service.dart';
import 'package:inventory_app/serviecs/routenotifier.dart';

class ConnectivityService {
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  ConnectivityService() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult>? event) {
      if (event != null) {
        var isConnected = !event.contains(ConnectivityResult.none);
        _connectionStatusController.add(isConnected);
        // Show dialog if not connected initially
        if (!isConnected) {
          _showNoInternetDialog();
        }
      }
    });

    checkInitialConnectivity();
  }

  // Check the initial connection status
  Future<void> checkInitialConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    var isConnected = !connectivityResult.contains(ConnectivityResult.none);
    _connectionStatusController.add(isConnected);

    // Show dialog if not connected initially
    if (!isConnected) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    final routeNotifier = GetIt.instance.get<RouteNotifier>();
    if (routeNotifier.currentRoute != 'Login') {
      GetIt.instance.get<DialogService>().alertDialog(
          "Connection failure".tr(), "No Internet Connection".tr());
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}

class ConnectivityNotifier extends ChangeNotifier {
  final ConnectivityService connectivityService;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityNotifier(this.connectivityService) {
    connectivityService.connectionStatus.listen((status) {
      _isConnected = status;
      notifyListeners();
    });
  }
}
