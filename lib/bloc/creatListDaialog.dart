import 'package:flutter/material.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/modelss/creatlist/CreateListMod.dart';
import 'package:inventory_app/serviecs/PurchaseOrder.sarvise.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:invo_models/invo_models.dart';
import 'package:invo_models/utils/property.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class creatListDaialogBloc extends ChangeNotifier {
  List<CreateListMod> allOrders = [];
  List<CreateListMod> filteredOrders = [];
  Property<List<Supplier>> suppliers = Property([]);
 Property<bool> onTableUpdate = Property(false);
 String selectedsupplier ="";
  creatListDaialogBloc() {
    loadOrders();
      fetchSuppliers(1,"");
  }
    void dispose() {
    onTableUpdate.dispose();
    suppliers.dispose();
 
  }

  Future<List<Supplier>> fetchSuppliers(int page ,

   String searchTerm,) async {
    
    
  
    return await PurchaseOrderServies().getSupplierMiniList(page: page,limit: 15,searchTerm: searchTerm);
  }
  List<String> getAllBarcodes(String id) {
 CreateListMod s=   filteredOrders.firstWhere((order) => order.id == id);

        return s.lines.map((line) {
      return '${line.barcode} (Qty: ${line.qty})'; // Format: "barcode (Qty: quantity)"
    }).toList();
  }
  Future<void> loadOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ordersString = prefs.getString('enteredOrders');

    if (ordersString != null) {
      try {
        List<dynamic> jsonList = json.decode(ordersString);
        allOrders = jsonList.map((json) {
          if (json is Map<String, dynamic>) {
            return CreateListMod.fromJson(json);
          } else {
            throw Exception("Invalid data format");
          }
        }).toList();
      } catch (e) {
        print("Error loading orders: $e");
        allOrders = []; // Reset to empty on error
      }
      // Initialize filteredOrders
      filteredOrders = List.from(allOrders);
         Utilts.createList= prefs.getString('enteredOrders')!;

      notifyListeners();
    }
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      filteredOrders = List.from(allOrders); // Reset to all orders if search is empty
    } else {
      filteredOrders = allOrders.where((order) {
        return order.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners(); // Notify listeners to rebuild UI
  }

void removeOrder(String id) {
  // Find the index of the order to remove in the filtered list
  int index = filteredOrders.indexWhere((order) => order.id == id);
  
  if (index != -1) {
    // Remove the order from the filtered list
    CreateListMod removedOrder = filteredOrders.removeAt(index);
    
    // Also remove the order from allOrders to keep them in sync
    allOrders.removeWhere((order) => order.id == removedOrder.id);

    // Save the updated orders back to SharedPreferences
    _saveOrders().then((_) {
      print("Order removed and saved successfully");
    }).catchError((error) {
      print("Failed to save orders: $error");
    });

    // Notify listeners that the table has been updated
    onTableUpdate.sink(true);
  } else {
    print("Order with ID $id not found in filteredOrders.");
  }
}

Future<void> _saveOrders() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Convert the allOrders list to JSON
  String ordersString = json.encode(allOrders.map((order) => order.toJson()).toList());
  await prefs.setString('enteredOrders', ordersString);
}
}