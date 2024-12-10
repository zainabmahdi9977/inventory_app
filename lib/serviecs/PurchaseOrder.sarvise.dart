import 'dart:convert';
import 'package:http/http.dart' as http; // Import the http package
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrder.dart';
import 'package:inventory_app/modelss/PurchaseOrderProduct.dart';

import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/serviecs/varHttp.dart';
import 'package:invo_models/models/Product.dart';
import 'package:invo_models/models/Supplier.dart';
import 'package:invo_models/models/custom/productList.dart';
import 'package:invo_models/models/tax.dart';

class PurchaseOrderServies {
  Future<List<PurchaseOrderProduct>> getPurchaseProducts(String supplierId,
      {String searchTerm = '', int page = 1, int limit = 15}) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;
    List<ProductList> products = [];

    final response = await http.post(
      Uri.parse('${myHTTP}getPurchaseProducts'),
      headers: {"Api-Auth": token.toString()},
      body: {
        "supplierId": supplierId,
        "searchTerm": searchTerm,
        "page": page.toString(),
        "limit": limit.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('map[]');
      Map<String, dynamic> map = jsonDecode(response.body);
      print(map['data']['list']);
      if (map['success'] == true) {
        return (map['data']['list'] as List)
            .map((product) => PurchaseOrderProduct.fromJson(product))
            .toList();
      }
    }

    throw Exception('Failed to load Product list');
  }

  Future<PurchaseOrderProduct?> getSinglePurchaseProduct(String supplierId,
      {String searchTerm = '', int page = 1, int limit = 15}) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getPurchaseProducts'),
      headers: {"Api-Auth": token},
      body: {
        "supplierId": supplierId,
        "searchTerm": searchTerm,
        "page": page.toString(),
        "limit": limit.toString(),
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true) {
        // Check if the list is not empty and return the first product
        if (map['data']['list'].isNotEmpty) {
          return PurchaseOrderProduct.fromJson(map['data']['list'][0]);
        }
      }
    }

    throw Exception('Failed to load Product');
  }

//PurchaseOrderProduct
  Future<PurchaseOrderProduct?> getBranchProductByBarcode(String branchId,
      {String searchTerm = ''}) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getBranchProductByBarcode'),
      headers: {"Api-Auth": token.toString()},
      body: {
        "branchId": branchId,
        "searchTerm": searchTerm,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        print(map['data']);
        // Check if map['data'] is a String or Map
        if (map['data'] is String) {
          return PurchaseOrderProduct.fromJson(json.decode(map['data']));
        } else if (map['data'] is Map) {
          return PurchaseOrderProduct.fromJson(map['data']);
        }
      }
    }
    return null;
  }

  Future<List<PurchaseOrder>> getOpenPurchaseOrderList({
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
        Uri.parse('${myHTTP}getOpenPurchaseOrderList'),
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
            List<PurchaseOrder> purchaseOrders = [];
            for (var element in map['data']['list']) {
              var purchaseOrder = PurchaseOrder.fromJson(element);
              purchaseOrders.add(purchaseOrder);
            }
            return purchaseOrders;
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

  Future<List<PurchaseOrder>> getClosedPurchaseOrderList({
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
        Uri.parse('${myHTTP}getClosedPurchaseOrderList'),
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
            List<PurchaseOrder> purchaseOrders = [];
            for (var element in map['data']['list']) {
              var purchaseOrder = PurchaseOrder.fromJson(element);
              purchaseOrders.add(purchaseOrder);
            }
            return purchaseOrders;
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

  Future<bool> savePurchaseOrder(Map<String, dynamic> purchaseOrderData) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    try {
      final response = await http.post(
        Uri.parse('${myHTTP}savePurchaseOrder'),
        headers: {
          "Api-Auth": token,
          "Content-Type": "application/json",
        },
        body: jsonEncode(purchaseOrderData),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        if (map['success']) {
          return true;
        } else {
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        throw Exception(
            'Failed to save purchase order: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Caught error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<String>> getPurchaseAccounts() async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.get(
      Uri.parse('${myHTTP}getPurchaseAccounts'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      Map map = jsonDecode(response.body);
      if (map['success'] == true && map['data'] is List) {
        // Extract only the IDs from the account objects
        return (map['data'] as List)
            .map((account) => account['id'] as String)
            .toList();
      }
    }

    throw Exception('Failed to load purchase accounts');
  }

  Future<List<Supplier>> getSupplierMiniList(    {int page = 1,
    int limit = 15,
   String searchTerm = ""}) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getSupplierMiniList'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "page": page,
        "limit": limit,
        "searchTerm":searchTerm
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success'] == true && map['data']['list'] is List) {
        return (map['data']['list'] as List)
            .map((supplier) => Supplier.fromMap(supplier))
            .toList();
      }
    }
    throw Exception('Failed to load supplier mini list');
  }

  Future<List<Tax>> getTaxesList() async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getTaxesList'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
    );

    print('Response body: ${response.body}'); // Debugging line

    if (response.statusCode == 200) {
      final Map<String, dynamic> map = jsonDecode(response.body);
      print('Decoded map: $map'); // Debugging line

      if (map['success'] == true && map['data']['list'] is List) {
        List<Tax> taxesList = [];

        for (var tax in map['data']['list']) {
          // Handle the 'taxes' field as a List directly
          List<childTax> childTaxes = [];
          if (tax['taxes'] != null && tax['taxes'] is List) {
            childTaxes = (tax['taxes'] as List)
                .map((child) => childTax.fromMap(child))
                .toList();
          }

          taxesList.add(Tax(
            id: tax['id'],
            name: tax['name'].toString(),
            taxPercentage: double.parse(tax['taxPercentage'].toString()),
            taxType: tax['taxType'] ?? "",
            taxes: childTaxes,
          ));
        }

        return taxesList;
      } else {
        throw Exception(
            'Invalid data structure: Expected a list but found something else.');
      }
    }

    throw Exception('Failed to load Tax list');
  }

  Future<String> getPurchaseNumber() async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.get(
      Uri.parse('${myHTTP}getPurchaseNumber'),
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
        // Extract the purchase number from the data object
        return map['data']['purchaseNumber'];
      }
    }

    throw Exception('Failed to load purchase number');
  }

// Future<List<void>> getPhysicalCountList({
//   int page = 1,
//   int limit = 15,
//   String searchTerm = '',
//   Map<String, dynamic> sortBy = const {},
//   Map<String, dynamic>? filter,
// }) async {
//   String myHTTP = await getServerURL();
//   String token = (await LoginServices().getToken())!;

//   final response = await http.post(
//     Uri.parse('${myHTTP}getPhysicalCountList'),
//     headers: {
//       "Api-Auth": token,
//       "Content-Type": "application/json",
//     },
//     body: jsonEncode({
//       "page": page,
//       "limit": limit,
//       "searchTerm": searchTerm,
//       "sortBy": sortBy,
//       "filter": filter ?? {},
//     }),
//   );

//   if (response.statusCode == 200) {
//     Map<String, dynamic> map = jsonDecode(response.body);
//     if (map['success'] == true && map['data']['list'] is List) {
//       return (map['data']['list'] as List)
//           .map((element) => PhysicalCount.parseJson(element)) // Use fromJson instead of ParseJson
//           .toList();
//           /**      if (map['success'] == true) {
//         if (map['data'] is Map && map['data']['list'] is List) {
//           List<PurchaseOrder> purchaseOrders = [];
//           for (var element in map['data']['list']) {
//             var purchaseOrder = PurchaseOrder();
//             purchaseOrder
//                 .parseJson(element); // Assuming you have a parseJson method
//             purchaseOrders.add(purchaseOrder);
//           }
//           return purchaseOrders;
//         } else {
//           throw Exception(
//               'Expected data to contain a list under the key "list", but got: ${map['data']}');
//         }
//       } else {
//         // Handle server-side error
//         throw Exception('Request was unsuccessful: ${map['msg']}');
//       } */
//     }
//   }
//   throw Exception('Failed to load physical count list');
// }
// Future<List<Supplier>?> _fetchSuppliers() async {
//   try {
//     return await getSupplierMiniList();
//   } catch (e) {
//     throw Exception(e);
//   }
// }

  Future<List<Tax>?> _fetchtax() async {
    try {
      return await getTaxesList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<PurchaseOrder>?> _fetchopenpuch() async {
    try {
      return await getOpenPurchaseOrderList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<PurchaseOrder>?> _fetchclosepurch() async {
    try {
      return await getClosedPurchaseOrderList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<PurchaseOrder?> getPurchaseOrderById(String purchaseOrderId) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    try {
      final response = await http.get(
        Uri.parse('${myHTTP}getPurchaseOrderById/$purchaseOrderId'),
        headers: {
          "Api-Auth": token,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        if (map['success'] == true && map['data'] is Map) {
          return PurchaseOrder.fromJson(map['data']);
        } else {
          throw Exception('Request was unsuccessful: ${map['msg']}');
        }
      } else {
        throw Exception(
            'Failed to load purchase order: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Caught error: $e');
      throw Exception('Error: $e');
    }
  }
}
//do this router.get("/getPurchaseOrderById/:purchaseOrderId",PurchaseOrderController.getPurchaseOrderById)