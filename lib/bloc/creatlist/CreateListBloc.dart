import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventory_app/Utlits.dart';

import 'package:inventory_app/modelss/creatlist/CreateListMod.dart';
import 'package:inventory_app/modelss/creatlist/CreateListlineMod.dart';
import 'package:inventory_app/serviecs/PurchaseOrder.sarvise.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:invo_models/models/Product.dart';
import 'package:invo_models/models/Supplier.dart';
import 'package:invo_models/utils/property.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateListBloc extends ChangeNotifier {
  Property<bool> onTableUpdate = Property(false);
  Property<bool> search = Property(false);
  List<CreateListMod> enteredOrders = [];
  Property<List<Supplier>> suppliers = Property([]);
  List<CreateListlineMod> enteredOrders2 = [];
   List<CreateListlineMod?>?  batch;
  List<CreateListlineMod?>?  serials;
   String selectedsupplier ="";
  Property<List<Product>> products = Property([]);
  Product? fetchedProduct;
  String id = "";
  CreateListBloc(String id, List<CreateListlineMod> lines) {
    enteredOrders2 = lines;
    this.id = id;
    loadOrders();
    fetchProducts("");
    getAllBarcodes();
   // fetchSuppliers();
    initializeNewOrder(); // Initialize for new order

  }
    @override
  void dispose() {
    onTableUpdate.dispose();
    search.dispose();
    suppliers.dispose();   
    products.dispose();
    super.dispose();
 
  }
 Future<List<CreateListlineMod?>?> fetchPatch(String branchId ,String productId ) async {
    try {
      List<CreateListlineMod?>? batch = await ProductService()
          .getProductBatches(branchId, productId);

       this.batch=batch;
      
    } catch (e) {
      print('Error fetching products: $e');
    }
    return batch;
  }
   Future<List<CreateListlineMod?>?> fetchSerial(String branchId ,String productId ) async {
    try {
      List<CreateListlineMod?>? serial = await ProductService()
          .getProductSerials(branchId, productId);

       this.serials=serial;
      
    } catch (e) {
      print('Error fetching products: $e');
    }
    return serials;
  }
  Future<List<Supplier>> fetchSuppliers(int page ,

   String searchTerm,) async {
    
    
  
    return await PurchaseOrderServies().getSupplierMiniList(page: page,limit: 15,searchTerm: searchTerm);
  }
  void initializeNewOrder() {
    //enteredOrders2 = []; // Reset the list for a new order
    notifyListeners();
  }

  searchbutton(BuildContext context) async {
   //fetchProducts();

    print(products.value.length);
    onTableUpdate.sink(true);
    bool currentSearchState = search.value; // Get current state

    search.sink(!currentSearchState);
  }
  // searchbutton(BuildContext context) async {
  //   onTableUpdate.sink(true);

  //   if (search == "false") {
  // search.sink(true);

  //     } else {
  //    search.sink(false);

  //     }

  // }
  Future<void> loadOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ordersString = prefs.getString('enteredOrders');

    if (ordersString != null) {
      List<dynamic> jsonList = json.decode(ordersString);
      enteredOrders =
          jsonList.map((json) => CreateListMod.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> saveOrders(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Find the index of the existing order
    int orderIndex = enteredOrders.indexWhere((order) => order.id == id);

    if (orderIndex != -1) {
      enteredOrders[orderIndex].name = name;
      enteredOrders[orderIndex].lines = List.from(enteredOrders2);
      print(enteredOrders[orderIndex].name);
    } else {
      if (fetchedProduct != null) {
        List<CreateListlineMod> currentOrderLines = List.from(enteredOrders2);

        CreateListMod newOrder = CreateListMod();
        newOrder.name = name;

        newOrder.lines = currentOrderLines;
        enteredOrders.add(newOrder);
      }
    }

   
    String ordersString =
        json.encode(enteredOrders.map((order) => order.toJson()).toList());
    await prefs.setString('enteredOrders', ordersString);

    enteredOrders2.clear();
    notifyListeners();
  }

 Future<void> fetchProduct(
  BuildContext context,
  String barcode, 
  int quantity, [
  List<CreateListlineMod?>? batches,
  List<int>? batchQuantities,
  List<CreateListlineMod?>? serials,
]) async {
  String branchId = Utilts.branchid;
  fetchedProduct = await ProductService()
      .getBranchProductByBarcode(branchId, searchTerm: barcode);
  
  if (fetchedProduct != null) {
    bool barcodeExists =
        enteredOrders2.any((line) => line.barcode == fetchedProduct!.barcode);

    if (!barcodeExists) {
    
      CreateListlineMod newLine = CreateListlineMod(
        barcode: fetchedProduct!.barcode,
        name: fetchedProduct!.name,
        id: fetchedProduct!.id,
        unitCost: fetchedProduct!.unitCost,
        qty: quantity,
        productType: fetchedProduct!.type,
        serials: serials, 
        batches:  batches,
      
      );

      enteredOrders2.add(newLine);
      onTableUpdate.sink(true); // Notify listeners
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product with this barcode already added.'),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product not found')),
    );
  }
}
  List<String> getAllBarcodes() {
    return enteredOrders2.map((line) {
      return '${line.barcode} (Qty: ${line.qty})'; // Format: "barcode (Qty: quantity)"
    }).toList();
  }
List<String> getAllBarcodes2() {
  return enteredOrders2.map((line) {
    // Format the batches and serials
    String batchesInfo = line.batches != null && line.batches!.isNotEmpty
        ? 'Batches: ${line.batches!.map((batch) => batch?.qty ?? 'N/A').join(', ')}]'
        : 'No Batches';
        
    String serialsInfo = line.serials != null && line.serials!.isNotEmpty
        ? 'Serials: ${line.serials!.map((serial) => serial?.isAvailable ?? false ? 'true' : 'false').join(', ')}]'
        : 'No Serial Numbers';

    // Combine all information into a string
    return '${line.barcode} (Qty: ${line.qty}), $batchesInfo, $serialsInfo';
  }).toList();
}
  void removeOrder(String barcode) {
    int index = enteredOrders2.indexWhere((order) => order.barcode == barcode);

    if (index != -1) {
      enteredOrders2.removeAt(index);

      onTableUpdate.sink(true);
    }
  }
Future<List<Product>> loadProducts({required int page, required String searchTerm}) async {
  return await await ProductService()
          .getBranchProductByBarcodelist( page: page, limit: 15 , searchTerm: searchTerm);
}
  Future<void> fetchProducts(String searchTerm) async {
    try {
      List<Product> fetchedProducts = await ProductService()
          .getBranchProductByBarcodelist( page: 1, limit:15 , searchTerm: searchTerm);

      products.sink(fetchedProducts);
      print(products.value.length);
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  onIncreaseQty(CreateListlineMod line) {
    line.increaseQty();

    onTableUpdate.sink(true);
  }
  onUpdateQty(CreateListlineMod line) {
     
   
    onTableUpdate.sink(true);
  }
  onDecreaseQty(CreateListlineMod line) {
    line.decreaseQty();

    onTableUpdate.sink(true);
  }


}
