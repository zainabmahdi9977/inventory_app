import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountListBloc.dart';
import 'package:inventory_app/bloc/bloc.base.dart';


import 'package:inventory_app/modelss/PhysicalCount/PhysicalCount.dart';
import 'package:inventory_app/modelss/PhysicalCount/PhysicalCountLine.dart';

import 'package:inventory_app/serviecs/PurchaseOrder.sarvise.dart';
import 'package:inventory_app/serviecs/PhysicalCount.service.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:invo_models/invo_models.dart';
//import 'package:inventory_app/modelss/product.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PhysicalCountFormBloc implements BlocBase {
  DateTime? selectedDate;
 List<PhysicalCountLine?>?  batch;
  List<PhysicalCountLine?>?  serials;
  Property<bool> search = Property(false);
  Property<List<Product>> products = Property([]);
  Property<List<Tax>> tax = Property([]);
  Property<bool> onTableUpdate = Property(false);
  late PhysicalCount physicalCount;
  String msg = '';
  String calculatedlabel = "Calculate";
  List<String> allBarcode = [];
  PhysicalCountFormBloc() {
    fetchProducts("");
  
  }
  @override
  void dispose() {
    onTableUpdate.dispose();
    search.dispose();
    products.dispose();
    tax.dispose();

 
  }
  Future<List<Product>> loadProducts(
      {required int page, required String searchTerm}) async {
    return  await ProductService().getBranchProductByBarcodelist(
        
        page: page,
        limit: 15,
        searchTerm: searchTerm);
  }

  Future<void> fetchProducts(String searchTerm) async {
    try {
      List<Product> fetchedProducts = await ProductService()
          .getBranchProductByBarcodelist(
              page: 1, limit: 15, searchTerm: searchTerm);

      products.sink(fetchedProducts);
      print(products.value.length);
    } catch (e) {
      print('Error fetching products: $e');
    }
  }
 Future<List<PhysicalCountLine?>?> fetchPatch(String branchId ,String productId ) async {
    try {
      List<PhysicalCountLine?>? batch = await PhysicalCountService()
          .getProductBatches(branchId, productId);

       this.batch=batch;
      
    } catch (e) {
      print('Error fetching products: $e');
    }
    return batch;
  }
   Future<List<PhysicalCountLine?>?> fetchSerial(String branchId ,String productId ) async {
    try {
      List<PhysicalCountLine?>? serial = await PhysicalCountService()
          .getProductSerials(branchId, productId);

       this.serials=serial;
      
    } catch (e) {
      print('Error fetching products: $e');
    }
    return serials;
  }
  searchbutton(BuildContext context) async {
    //fetchProducts();

    print(products.value.length);
    onTableUpdate.sink(true);
    bool currentSearchState = search.value; // Get current state

    search.sink(!currentSearchState);
  }

  factory PhysicalCountFormBloc.newPc(List<String> allBarcodes) {
    PhysicalCountFormBloc physicalCountFormBloc = PhysicalCountFormBloc();
    physicalCountFormBloc.physicalCount = PhysicalCount();
    physicalCountFormBloc.allBarcode = allBarcodes;
    physicalCountFormBloc.fetchAndAddProductsFromBarcodes2();
    physicalCountFormBloc.physicalCount.branchId = Utilts.branchid;
    return physicalCountFormBloc;
  }

  factory PhysicalCountFormBloc.editPc(PhysicalCount physicalCount) {
    PhysicalCountFormBloc physicalCountFormBloc = PhysicalCountFormBloc();
    physicalCountFormBloc.physicalCount= physicalCount;

    return physicalCountFormBloc;
  }
  void removeLine(PhysicalCountLine line) {
    physicalCount.lines.remove(line);
    onTableUpdate.sink(true);
    physicalCount.calculate();
  }

  Future<bool> closePhysicalCount(
      BuildContext context,
      TextEditingController _referenceController,
      TextEditingController _noteController) async {
    physicalCount.reference = _referenceController.text;
    physicalCount.note = _noteController.text;
    onTableUpdate.sink(true);
    bool success = await savePhysicalCount("Closed");
    print(physicalCount.id.isEmpty);

    if (success) {
      for (var element in physicalCount.lines) {
        Product? fetchedProduct = (await ProductService()
            .getBranchProductByBarcode(Utilts.branchid,
                searchTerm: element.barcode == ""
                    ? element.product!.barcode
                    : element.barcode));
        fetchedProduct!.onHand = element.enteredQty;
      }

      NavigationService(context).goToPhysicalCountList(PhysicalCountListBloc());
      print(physicalCount.id.isEmpty);
      print('Physical Count Closed successfully!');
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: 'Physical Count Closed successfully!',
        ),
      );
      //await physicalCount.updateProductOnHand();
    } else {
      print(physicalCount.toJson());
      print(success);
    }
_referenceController.dispose();
_noteController.dispose();
    return success;

  }

  Future<bool> savePhysicalCountAction(
      BuildContext context,
      TextEditingController _referenceController,
      TextEditingController _noteController,
      bool calculat) async {
    physicalCount.reference = _referenceController.text;
    physicalCount.note = _noteController.text;
    //  for (var element in physicalCount.lines)
    //           if (element.batches.isNotEmpty) {
    //         // Ensure batchQuantities matches the number of batches
    //         int count = element.batches.length;
    //         List<int> quantities = batchQuantities.length == count
    //             ? batchQuantities
    //             : List.filled(count, 0); // Default to 0 if not enough quantities

    //         element.batches = fetchedProduct.batches.asMap().map((index, fetchedBatch) {
    //           return MapEntry(index, ProductBatch2(
    //             onHand: fetchedBatch.onHand,
    //             batch: fetchedBatch.batch,
    //             expireDate: fetchedBatch.expireDate,
    //             qty: quantities[index], // Assign quantity from the list
    //           ));
    //         }).values.toList();
    //       }
    onTableUpdate.sink(true);
    bool success = false;
    if (calculat == true) {
      success = await savePhysicalCount("Calculated");
      msg = "Physical Count Calculated successfully!".tr();
    } else {
      success = await savePhysicalCount("Open");
      msg = "Physical Count Open successfully!".tr();
    }

    if (success) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: msg,
        ),
      );
      NavigationService(context).goToPhysicalCountList(PhysicalCountListBloc());
    } else {
      print(physicalCount.toJson());
      print(success);
      msg = "Failed to Save Count order".tr();
    }
// _referenceController.dispose();
// _noteController.dispose();
    return success;
  }

  Future<bool> toggleCalculate(BuildContext context) async {
    onTableUpdate.sink(true);

    if (calculatedlabel == "Calculate") {
      if (physicalCount.lines.isEmpty) {
        msg = 'Failed to Calculate, Please Select Some Products!';
        calculatedlabel = "Calculate";
        return false;
      } else {
        msg = '';
        calculatedlabel = "Re-Calculate";
        return true;
      }
    } else {
      calculatedlabel = "Calculate";
      return false;
    }
  }

  onIncreaseQty(PhysicalCountLine line) {
    line.increaseQty();
    physicalCount.calculate();
    onTableUpdate.sink(true);
  }

  onDecreaseQty(PhysicalCountLine line) {
    line.decreaseQty();
    physicalCount.calculate();
    onTableUpdate.sink(true);
  }
  onUpdateQty(PhysicalCountLine line) {
     
    physicalCount.calculate();
    onTableUpdate.sink(true);
  }


  Future<double> calculateActualValue() async {
    double actualValue = 0.0;

    for (var line in physicalCount.lines) {
      if (line.unitCost != null && line.expectedQty != null) {
        actualValue += line.unitCost! * line.expectedQty!;
      }
    }

    // Utilts.actualValue = actualValue;
    // Utilts.CalculatedValue = CalculatedValue;
    // Utilts.difference = Utilts.actualValue - Utilts.CalculatedValue;

    onTableUpdate.sink(true);
    return actualValue;
  }

  Future<bool> savePhysicalCount(String statue) async {
    physicalCount.status = statue;
    if (physicalCount.id == "") {
      List<String> accountIds =
          await PurchaseOrderServies().getPurchaseAccounts();
      String defaultAccountId = accountIds.isNotEmpty ? accountIds[0] : '';
for (var element in physicalCount.lines) {
  element.accountId = defaultAccountId;

  Product? fetchedProduct = await ProductService().getBranchProductByBarcode(
    Utilts.branchid,
    searchTerm: element.barcode == "" ? element.product!.barcode : element.barcode,
  );

  element.expectedQty = fetchedProduct!.onHand;
// if(element.batches.isNotEmpty)
// // ignore: curly_braces_in_flow_control_structures
// for(var batch in element.batches ) {
//   batch.unitCost=10;
// }
  // // Clear the existing batches before adding new ones
  // element.batches = [];

  // // Populate the batches with new data
  // element.batches = fetchedProduct.batches
  //     .asMap()
  //     .map((index, fetchedBatch) {
  //       return MapEntry(
  //         index,
  //         ProductBatch2(
  //           onHand: fetchedBatch.onHand,
  //           batch: fetchedBatch.batch,
  //           expireDate: fetchedBatch.expireDate,
  //           qty: 0,
  //         ),
  //       );
  //     })
  //     .values
  //     .toList();
}
    }
    try {
      
      bool success = await PhysicalCountService()
          .savePhysicalCount(physicalCount.toJson());

      return success;
    } catch (e) {
      return false;
    }
  }
//   Future<bool> savePhysicalCount(String statue) async {
//     physicalCount.status = statue;
//           List<String> accountIds =
//           await PurchaseOrderServies().getPurchaseAccounts();
//       String defaultAccountId = accountIds.isNotEmpty ? accountIds[0] : '';

//     if (physicalCount.id == "") {

//       for (var element in physicalCount.lines) {
//         element.accountId = defaultAccountId;
//         element.expectedQty = element.enteredQty;

//     }
//     }
// else
// {physicalCount.status = statue;
//      for (var element in physicalCount.lines) {
//         element.accountId = defaultAccountId;
//        element.expectedQty = element.enteredQty;
//       }

//       }
//     try {
//       bool success = await PhysicalCountService()
//           .savePhysicalCount(physicalCount.toJson());

//       return success;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }
Future<bool> fetchProduct(BuildContext context, String barcode, 
double quantity, [List<PhysicalCountLine?>? batch,
 List<double>? batchQuantities,List<PhysicalCountLine?>? serial]) async {
  String branchId = Utilts.branchid;
  Product? fetchedProduct = await ProductService().getBranchProductByBarcode(branchId, searchTerm: barcode);
  calculateActualValue();
  if (fetchedProduct != null) {
    print("Barcode: " + fetchedProduct.barcode);

    bool barcodeExists = physicalCount.lines.any((line) => line.product?.barcode == barcode);
Future<List<PhysicalCountLine?>> futureBatches = Future.value(batch);
Future<List<PhysicalCountLine?>> futureSerial = Future.value(serial);
    if (!barcodeExists) {
      physicalCount.addLine(fetchedProduct, quantity, futureBatches,batchQuantities,futureSerial );
     physicalCount.onTableUpdate.sink(true);
   
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product with this barcode already added.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product not found')),
    );
  }
  return false;
}

 
Future<void> fetchAndAddProductsFromBarcodes2() async {
  try {
    for (String barcodeWithQuantity in allBarcode) {
      String barcode = barcodeWithQuantity.split(' (Qty: ')[0]; // Get the barcode part

      Product? fetchedProduct = await ProductService()
          .getBranchProductByBarcode(Utilts.branchid, searchTerm: barcode);

      // Fetch batches and serials
      List<PhysicalCountLine?>? batches = await fetchPatch(Utilts.branchid, fetchedProduct!.id);
      List<PhysicalCountLine?>? serials = await fetchSerial(Utilts.branchid, fetchedProduct!.id);

      // Extract and parse the quantity safely
   String quantityString = barcodeWithQuantity.split(' (Qty: ')[1].split(')')[0].trim();
      double quantity = double.tryParse(quantityString.replaceAll(',', '.')) ?? 0.0; // Handle potential format issues

      if (fetchedProduct != null) {
      
    List<double> batchQuantities = [];
     
        if (barcodeWithQuantity.contains('No Batches')) {
          // Keep it empty if "No Batches"
          batchQuantities = [];
        } else {
          // Extract batches up to the first closing bracket
          String batchPart = barcodeWithQuantity.split('Batches: ')[1].split(']')[0].trim();

          // Handle multiple batches
          List<String> batchStrings = batchPart.split(',').map((s) => s.trim()).toList();
          batchQuantities = batchStrings.map((s) => double.tryParse(s) ?? 0.0).toList();
        }
       //No Serial Numbers
List<bool> serialSelections = [];
if (barcodeWithQuantity.contains('No Serial Numbers')) {
  serialSelections = []; // Keep it empty if "No Serial Numbers"
} else {
  // Extract serials up to the first closing bracket
  String serialsPart = barcodeWithQuantity.split('Serials: ')[1].split(']')[0].trim();

  // Handle multiple serials
  List<String> serialsStrings = serialsPart.split(',').map((s) => s.trim()).toList();
  
  // Convert serial strings to booleans
  serialSelections = serialsStrings.map((s) {
    // Assuming serials are supposed to be "true" or "false" strings
    return s.toLowerCase() == "true";
  }).toList();
}
          Future<List<PhysicalCountLine?>> futureBatches = Future.value(batch);
Future<List<PhysicalCountLine?>> futureSerial = Future.value(serials);
   
        //List<bool> serialSelections = serials?.map((serial) => serial?.isAvailable ?? false).toList() ?? [];

        // Pass the extracted quantities and selections to the addLine function
        physicalCount.addLine(fetchedProduct, quantity, futureBatches, batchQuantities, futureSerial,serialSelections);
        physicalCount.calculate();
      } else {
        print('Product not found for barcode: $barcode');
      }
    }

    onTableUpdate.sink(true);
  } catch (e) {
    print('Error fetching products: $e');
  }
}
 
 
  Future<void> fetchAndAddProductsFromBarcodes() async {
    try {

      for (String barcodeWithQuantity in allBarcode) {
        String barcode =
            barcodeWithQuantity.split(' (Qty: ')[0]; // Get the barcode part

        Product? fetchedProduct = await ProductService()
            .getBranchProductByBarcode(Utilts.branchid, searchTerm: barcode);
                  // List<PhysicalCountLine?>? batches = await fetchPatch(Utilts.branchid, fetchedProduct!.id);
  List<PhysicalCountLine?>? serial = await fetchSerial(Utilts.branchid, fetchedProduct!.id);
  Future<List<PhysicalCountLine?>> futureBatches = Future.value(batch);
Future<List<PhysicalCountLine?>> futureSerial = Future.value(serial);
        double quantity = double.parse(
            barcodeWithQuantity.split(' (Qty: ')[1].replaceAll(')', ''));
        if (fetchedProduct != null) {
          physicalCount.addLine(fetchedProduct, quantity ,futureBatches,[] , futureSerial);
          physicalCount.calculate();
        } else {
          print('Product not found for barcode: $barcode');
        }
      }

      onTableUpdate.sink(true);
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<Product?> fetchProductById(String id) async {
    try {
      // Fetch the product using your service
      Product? fetchedProduct = await ProductService().getProductById(id);

      if (fetchedProduct != null) {
        return fetchedProduct; 
      } else {
      
        print('Product not found for ID: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<Product?> fetchProductById2(String id) async {
    try {
      Product? products =
          await ProductService().getProductBranchData(id, Utilts.branchid);

      if (products != null) {
        return products;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }
}
