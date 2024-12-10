import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/modelss/PhysicalCount/PhysicalCountLine.dart';
import 'package:inventory_app/modelss/ProductBatch.dart';
import 'package:inventory_app/modelss/creatlist/CreateListlineMod.dart';

import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/serviecs/varHttp.dart';
import 'package:invo_models/models/Product.dart';

class ProductService {
  Future<Product?> getBranchProductByBarcode(String branchId,
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
          return Product.fromJson(json.decode(map['data']));
        } else if (map['data'] is Map) {
          return Product.fromJson(map['data']);
        }
      }
    }
    return null;
  }

  // ignore: slash_for_doc_comments
  /**  Future<List<Product>> getPhysicalCountProducts(
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
  } */

  Future<List<Product>> getBranchProductByBarcodelist(
  {
    int page = 1,
    int limit = 15,
   String searchTerm = ''
  } ) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.post(
      Uri.parse('${myHTTP}getPhysicalCountProducts'),
      headers: {
        "Api-Auth": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "branchId": Utilts.branchid,
        "page": page,
        "limit": limit,
        "searchTerm":searchTerm
      }),
    );

    if (response.statusCode == 200) {
      print('map[]');
      Map<String, dynamic> map = jsonDecode(response.body);
      print(map['data']['list']);
      if (map['success'] == true) {
        return (map['data']['list'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      }
    }

    throw Exception('Failed to load Product list');
  }

  Future<Product?> getProductById(String productId) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.get(
      Uri.parse('${myHTTP}getProduct/$productId'),
      headers: {"Api-Auth": token.toString()},
    );
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return Product.fromJson(map['data']);
      }
    }
    return null;
  }

  Future<Product?> getProductBranchData(
      String productId, String branchId) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;

    final response = await http.get(
      Uri.parse('${myHTTP}getProductBranchData/$productId?branchId=$branchId'),
      headers: {
        "Api-Auth": token.toString(),
      },
    );

    print(response.body); 

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);

      if (map['success']) {
        // Assuming 'data' contains the product information.
        return Product.fromJson(map['data']);
      } else {
        print(
            'Error: ${map['message']}'); // Log any error messages from the API
      }
    } else {
      print(
          'Failed to fetch product: ${response.statusCode}'); // Log the status code
    }

    return null; // Return null if the response is not successful
  }

   //router.get("/getProductSerials/:branchId/:productId",ProductController.getProductSerials)
   
//router.post("/getProductBranchData", ProductController.getProductBranchData);
    Future<List<CreateListlineMod?>?> getProductSerials(String branchId, String productId) async {
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

      return dataList.map((item) => CreateListlineMod.fromJson(item)).toList();
    } else {
      print('Error: ${map['message']}'); // Log any error messages from the API
    }
  } else {
    print('Failed to fetch product: ${response.statusCode}'); // Log the status code
  }

  return []; // Return an empty list if there's an error
}
 Future<List<CreateListlineMod?>?> getProductBatches(String branchId, String productId) async {
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

      return dataList.map((item) => CreateListlineMod.fromJson(item)).toList();
    } else {
      print('Error: ${map['message']}'); // Log any error messages from the API
    }
  } else {
    print('Failed to fetch product: ${response.statusCode}'); // Log the status code
  }

  return []; // Return an empty list if there's an error
}
}

