import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:invo_models/models/EmployeePrivilege.dart';

import 'login.services.dart';
import 'varHttp.dart';

class PrivielgService {
  Future<List<EmployeePrivilege>?> getEmployeePrivielges() async {
    try {
      String token = (await LoginServices().getToken())!;
      String myHTTP = await getServerURL();
      final response = await http.get(
        Uri.parse('${myHTTP}/getEmployeePrivielges'),
        headers: {"Api-Auth": token},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> map = jsonDecode(response.body);
        if (map['success']) {
          return (map['data'] as List)
              .map((element) => EmployeePrivilege.fromJson(element))
              .toList();
        }
      } else {
        throw Exception('Failed to load privileges: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions (e.g., log them)
      print('Error fetching privileges: $e');
    }
    return null;
  }
}
