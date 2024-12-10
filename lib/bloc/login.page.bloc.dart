import 'package:flutter/material.dart';
import 'package:inventory_app/serviecs/login.services.dart';
import 'package:invo_models/invo_models.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPageBloc {
  Property<String> errorMsg = Property("");

  String email = "";
  String password = "";

  dynamic focusNode = FocusNode();
void dispose(){
  errorMsg.dispose();
  
}
  Future<bool> login() async {
    bool res = await LoginServices()
    .checkLogin(email, password);
    if (res) {
   
        errorMsg.sink("");
      await setLoggedIn(true);
      return true;
    } else {
      errorMsg.sink("Invalid email and password!");
      return false;
    }
  }

  Future<bool> isTokenValid() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await getToken();
    if (token != null) {
      return true;
    }
    return false;
  }

  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
    
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }
  
}
