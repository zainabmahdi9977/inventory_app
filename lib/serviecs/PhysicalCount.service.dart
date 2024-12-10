import 'dart:convert';
import 'package:http/http.dart' as http; // Import the http package

import 'package:inventory_app/modelss/PhysicalCount/PhysicalCount.dart';
import 'package:inventory_app/modelss/PhysicalCount/PhysicalCountLine.dart';
import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/serviecs/varHttp.dart';
import 'package:invo_models/models/Product.dart';

class PhysicalCountService {
  Future<List<Product>> getPhysicalCountProducts(
    String branchId, {
    int page = 1,
    int limit = 500,
  }) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getPhysicalCountProducts'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "branchId": branchId,
        "page": page,
        "limit": limit,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true && map['data']['products'] is List) {
        return (map['data']['products'] as List)
            .map((product) =>
                Product.fromJson(product)) // Assuming a fromJson method exists
            .toList();
      }
    }
    throw Exception('Failed to load physical count products');
  }

  Future<List<String>> getLocationsByBranch(String branchId) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.get(
      Uri.parse('${myHTTP}getLocationsByBranch/$branchId'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true && map['data'] is List) {
        return (map['data'] as List)
            .map((location) => location['id'] as String)
            .toList();
      }
    }
    throw Exception('Failed to load locations by branch');
  }

  Future<List<Product>> getPhysicalCountProductsByInventory(
      String branchId, List<String> inventoryLocationIds) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getPhysicalCountProductsbyInventory'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "branchId": branchId,
        "inventorylocationsid": inventoryLocationIds,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true && map['data']['products'] is List) {
        return (map['data']['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      }
    }
    throw Exception('Failed to load physical count products by inventory');
  }

  Future<List<Product>> getPhysicalCountProductsByCategory(
      String branchId, List<String> categoryIds) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getPhysicalCountProductsbyCategory'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "branchId": branchId,
        "categoryId": categoryIds,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true && map['data']['products'] is List) {
        return (map['data']['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      }
    }
    throw Exception('Failed to load physical count products by category');
  }

  Future<bool> savePhysicalCount(Map<String, dynamic> physicalCountData) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    print(jsonEncode(physicalCountData));

    final response = await http.post(
      Uri.parse('${myHTTP}savePhysicalCount'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode(physicalCountData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return true;
      } else {
        print(map);
        throw Exception('Request was unsuccessful: ${map['msg']}');
      }
    }
    throw Exception('Failed to save physical count: ${response.reasonPhrase}');
  }

//router.post('/getOpenPhysicalCountList',PhysicalCountController.getOpenPhysicalCountList)/**
//{"page":1,"limit":15,"searchTerm":"","sortBy":{},"filter":{"status":[],"fromDate":null,"toDate":null}} */
  Future<List<PhysicalCount>> getOpenPhysicalCountList({
    int page = 1,
    int limit = 999,
    String searchTerm = '',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    try {
      print('Server URL: $myHTTP');
      print('Token: $token');

      final response = await http.post(
        Uri.parse('${myHTTP}getOpenPhysicalCountList'),
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
          },
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        print('Response body: ${map}');

        if (map['success'] == true) {
          if (map['data'] is Map && map['data']['list'] is List) {
            List<PhysicalCount> physicalCounts = []; // Change the variable name

            for (var element in map['data']['list']) {
              // Create a PhysicalCount instance from the JSON
              var physicalCount = PhysicalCount.fromJson(element);
              physicalCounts.add(physicalCount); // Add to the list
            }

            return physicalCounts; // Return the list of PhysicalCount
          } else {
            throw Exception(
                'Expected data to contain a list under the key "list", but got: ${map['data']}');
          }
        } else {
          // Handle server-side error
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        // Log the response body for non-200 status codes
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load open purchase orders: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Log the caught error
      print('Caught error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<PhysicalCount>> getClosedPhysicalCountList({
    int page = 1,
    int limit = 999,
    String searchTerm = '',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    try {
      print('Server URL: $myHTTP');
      print('Token: $token');

      final response = await http.post(
        Uri.parse('${myHTTP}getClosedPhysicalCountList'),
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
          },
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        print('Response body: ${map}');

        if (map['success'] == true) {
          if (map['data'] is Map && map['data']['list'] is List) {
            List<PhysicalCount> physicalCounts = []; // Change the variable name

            for (var element in map['data']['list']) {
              // Create a PhysicalCount instance from the JSON
              var physicalCount = PhysicalCount.fromJson(element);
              physicalCounts.add(physicalCount); // Add to the list
            }

            return physicalCounts; // Return the list of PhysicalCount
          } else {
            throw Exception(
                'Expected data to contain a list under the key "list", but got: ${map['data']}');
          }
        } else {
          // Handle server-side error
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        // Log the response body for non-200 status codes
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load open purchase orders: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Log the caught error
      print('Caught error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<PhysicalCount>> getCalculatedPhysicalCountList({
    int page = 1,
    int limit = 15,
    String searchTerm = '',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    try {
      print('Server URL: $myHTTP');
      print('Token: $token');

      final response = await http.post(
        Uri.parse('${myHTTP}getClosedPhysicalCountList'),
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
          },
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        print('Response body: ${map}');

        if (map['success'] == true) {
          if (map['data'] is Map && map['data']['list'] is List) {
            List<PhysicalCount> physicalCounts = []; // Change the variable name

            for (var element in map['data']['list']) {
              // Create a PhysicalCount instance from the JSON
              var physicalCount = PhysicalCount.fromJson(element);
              physicalCounts.add(physicalCount); // Add to the list
            }

            return physicalCounts; // Return the list of PhysicalCount
          } else {
            throw Exception(
                'Expected data to contain a list under the key "list", but got: ${map['data']}');
          }
        } else {
          // Handle server-side error
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        // Log the response body for non-200 status codes
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load open purchase orders: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Log the caught error
      print('Caught error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<PhysicalCount>> getPhysicalCountList({
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
        Uri.parse('${myHTTP}getPhysicalCountList'),
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
            List<PhysicalCount> physicalCounts = [];

            for (var element in map['data']['list']) {
              var physicalCount = PhysicalCount.fromJson(element);
              physicalCounts.add(physicalCount);
            }

            return physicalCounts;
          } else {
            throw Exception(
                'Expected data to contain a list under the key "list", but got: ${map['data']}');
          }
        } else {
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        throw Exception(
            'Failed to load physical count list: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Caught error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<PhysicalCount> getPhysicalCountById(String physicalCountId) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    try {
      final response = await http.get(
        Uri.parse('${myHTTP}getphysicalCount/$physicalCountId'),
        headers: {
          "Api-Auth": token,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        Map map = json.decode(response.body);
        print(map['data']['lines'][0]["enteredQty"]);
        if (map['success'] == true) {
          // Assuming the response contains the physical count data directly
          return PhysicalCount.fromJson(map['data']);
        } else {
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        throw Exception(
            'Failed to load physical count: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
    Future<List<PhysicalCountLine?>?> getProductSerials(String branchId, String productId) async {
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

      return dataList.map((item) => PhysicalCountLine.fromJson(item)).toList();
    } else {
      print('Error: ${map['message']}'); // Log any error messages from the API
    }
  } else {
    print('Failed to fetch product: ${response.statusCode}'); // Log the status code
  }

  return []; // Return an empty list if there's an error
}
    Future<List<PhysicalCountLine?>?> getProductBatches(String branchId, String productId) async {
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

      return dataList.map((item) => PhysicalCountLine.fromJson(item)).toList();
    } else {
      print('Error: ${map['message']}'); // Log any error messages from the API
    }
  } else {
    print('Failed to fetch product: ${response.statusCode}'); // Log the status code
  }

  return []; // Return an empty list if there's an error
}
}
