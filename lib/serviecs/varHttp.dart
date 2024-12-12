// import 'package:shared_preferences/shared_preferences.dart';
// Future<String> getServerURL() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? url = prefs.getString("serverURL");
//   url ??= "http://10.2.2.95:3001";
//   String myHTTP = "$url/v1/inventoryApp/";
//   return myHTTP;
// }

import 'package:shared_preferences/shared_preferences.dart';

Future<String> getServerURL() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? url = prefs.getString("serverURL");
 url ??= "https://productionback.invopos.co";
  String myHTTP = "$url/v1/inventoryApp/";
  return myHTTP;
}
