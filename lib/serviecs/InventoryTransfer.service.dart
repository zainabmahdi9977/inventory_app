import 'dart:convert';
import 'package:http/http.dart' as http; // Import the http package
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransfer.dart';
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransferLine.dart';

import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/serviecs/varHttp.dart';

class InventoryTransferService {
  Future<bool> saveInventoryTransfer(
      Map<String, dynamic> InventoryTransfer) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    print(jsonEncode(InventoryTransfer));

    final response = await http.post(
      Uri.parse('${myHTTP}saveInventoryTransfer'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode(InventoryTransfer),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return true;
      } else {
        throw Exception('Request was unsuccessful: ${map['msg']}');
      }
    }
    throw Exception(
        'Failed to save Inventory Transfer: ${response.reasonPhrase}');
  }

  Future<InventoryTransfer> getInventoryTransferById(
      String inventoryTransferId) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.get(
      Uri.parse('${myHTTP}getInventoryTransfer/$inventoryTransferId'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true && map['data'] is Map) {
        return InventoryTransfer.fromJson(map['data']);
      } else {
        throw Exception('Request was unsuccessful: ${map['msg']}');
      }
    }

    throw Exception(
        'Failed to load inventory transfer: ${response.reasonPhrase}');
  }

  Future<List<InventoryTransfer>> getInventoryTransferList({
    int page = 1,
    int limit = 15,
    String searchTerm = '',
    String status = '',
    DateTime? fromDate,
    DateTime? toDate,
    required Map<String, List<String>?> filter,
  }) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    try {
      final response = await http.post(
        Uri.parse('${myHTTP}getInventoryTransferList'),
        headers: {
          "Api-Auth": token,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "page": page,
          "limit": limit,
          "searchTerm": searchTerm,
          "sortBy": "",
          "filter": {
            "fromDate": fromDate?.toIso8601String(),
            "toDate": toDate?.toIso8601String(),
            "status": [status]
          },
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);

        if (map['success'] == true) {
          if (map['data'] is Map && map['data']['list'] is List) {
            List<InventoryTransfer> inventorys = [];

            for (var element in map['data']['list']) {
              var inventory = InventoryTransfer.fromJson(element);
              inventorys.add(inventory);
            }

            return inventorys;
          } else {
            throw Exception(
                'Expected data to contain a list under the key "list", but got: ${map['data']}');
          }
        } else {
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        throw Exception(
            'Failed to Inventory Transfer count list: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Caught error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<String> getTransferNumber() async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.get(
      Uri.parse('${myHTTP}getTransferNumber'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true && map['data'] is Map) {
        return map['data']['transferNumber'];
      }
    }

    throw Exception('Failed to load transfer number');
  }
  
    Future<List<InventoryTransferLine?>?> getProductSerials(String branchId, String productId) async {
  String myHTTP = await getServerURL();
  String token = (await LoginServices().getToken())!;

  final response = await http.get(
    Uri.parse('${myHTTP}getProductSerials/$branchId/$productId'),
    headers: {
      "Api-Auth": token.toString(),
    },
  );

  print(response.body);

  if (response.statusCode == 200) {
    Map<String, dynamic> map = jsonDecode(response.body);

    if (map['success']) {

      List<dynamic> dataList = map['data'] as List<dynamic>;

      return dataList.map((item) => InventoryTransferLine.fromJson(item)).toList();
    } else {
      print('Error: ${map['message']}'); // Log any error messages from the API
    }
  } else {
    print('Failed to fetch product: ${response.statusCode}'); // Log the status code
  }

  return []; // Return an empty list if there's an error
}
    Future<List<InventoryTransferLine?>?> getProductBatches(String branchId, String productId) async {
  String myHTTP = await getServerURL();
  String token = (await LoginServices().getToken())!;

  final response = await http.get(
    Uri.parse('${myHTTP}getProductBatches/$branchId/$productId'),
    headers: {
      "Api-Auth": token.toString(),
    },
  );

  print(response.body);

  if (response.statusCode == 200) {
    Map<String, dynamic> map = jsonDecode(response.body);

    if (map['success']) {

      List<dynamic> dataList = map['data'] as List<dynamic>;

      return dataList.map((item) => InventoryTransferLine.fromJson(item)).toList();
    } else {
      print('Error: ${map['message']}'); // Log any error messages from the API
    }
  } else {
    print('Failed to fetch product: ${response.statusCode}'); // Log the status code
  }

  return []; // Return an empty list if there's an error
}
}
