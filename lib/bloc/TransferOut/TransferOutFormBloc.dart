import 'dart:async';
import 'package:flutter/material.dart';

import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutListBloc.dart';
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransfer.dart';
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransferLine.dart';
import 'package:inventory_app/modelss/branch.models.dart';
import 'package:inventory_app/serviecs/InventoryTransfer.service.dart';
import 'package:inventory_app/serviecs/branch.services.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:invo_models/invo_models.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TransferOutFormBloc {
   List<InventoryTransferLine?>?  batch;
  List<InventoryTransferLine?>?  serials;
   Property<bool> search = Property(false);
  Property<List<Product>> products = Property([]);
  Property<bool> onTableUpdate = Property(false);
List<String> allBarcode =[];
  late InventoryTransfer inventoryTransfer;
   final Property<List<Branch>> branches = Property([]);
   String msg = '';
   String selectedbranch = '';
  TransferOutFormBloc() {
  loadbranch();
  }
  void dispose() {
    onTableUpdate.dispose();
 products.dispose();
 search.dispose();
 branches.dispose();
  }
Future<void> loadbranch() async {
  try {
   
    List<Branch> allBranches = await BranchService().getBranchList();

    
    List<Branch> filteredBranches = allBranches.where((branch) => branch.id != Utilts.branchid).toList();

  
    branches.sink(filteredBranches);
  // ignore: empty_catches
  } catch (e) {
   
  }
}
 Future<List<InventoryTransferLine?>?> fetchPatch(String branchId ,String productId ) async {
    try {
      List<InventoryTransferLine?>? batch = await InventoryTransferService()
          .getProductBatches(branchId, productId);

       this.batch=batch;
      
    } catch (e) {
      print('Error fetching products: $e');
    }
    return batch;
  }
   Future<List<InventoryTransferLine?>?> fetchSerial(String branchId ,String productId ) async {
    try {
      List<InventoryTransferLine?>? serial = await InventoryTransferService()
          .getProductSerials(branchId, productId);

       this.serials=serial;
      
    } catch (e) {
      print('Error fetching products: $e');
    }
    return serials;
  }
// Future<bool> loadbranch() async {
//   if (!GetIt.instance.isRegistered<Repository>()) {
//     _repository = Repository();
//     GetIt.instance.registerSingleton<Repository>(_repository);
//     await _repository.load();
//   } else {
//     _repository = GetIt.instance.get<Repository>();
//   }

//   // Filter out branches that match the utilist.branchId
//   final filteredBranches = _repository.branches
//       .where((branch) => branch.id != Utilts.branchid)
//       .toList(); // Convert Iterable to List
  
//   branches.sink(filteredBranches);

//   return true;
// }
  factory TransferOutFormBloc.newIT(List<String> allBarcodes) {
    TransferOutFormBloc transferOutFormBloc = TransferOutFormBloc();
     transferOutFormBloc.allBarcode=allBarcodes;
    transferOutFormBloc.inventoryTransfer = InventoryTransfer();
    transferOutFormBloc.inventoryTransfer.branchId = Utilts.branchid;
    transferOutFormBloc.fetchAndAddProductsFromBarcodes2();
    return transferOutFormBloc;
  }

  factory TransferOutFormBloc.editIT(InventoryTransfer inventoryTransfer) {
    TransferOutFormBloc transferOutFormBloc = TransferOutFormBloc();
       transferOutFormBloc.inventoryTransfer = inventoryTransfer;
    return transferOutFormBloc;
  }

Future<List<Product>> loadProducts({required int page, required String searchTerm}) async {
  return await ProductService()
          .getBranchProductByBarcodelist( page: page, limit: 15 , searchTerm: searchTerm);
}
 Future<void> fetchProducts(String searchTerm) async {
    try {
      List<Product> fetchedProducts = await ProductService()
          .getBranchProductByBarcodelist( page: 1, limit:15 , searchTerm: searchTerm);

      products.sink(fetchedProducts);
     // print(products.value.length);
    } catch (e) {
 //     print('Error fetching products: $e');
    }
  }
   searchbutton(BuildContext context) async {
   //fetchProducts();

    //print(products.value.length);
    onTableUpdate.sink(true);
    bool currentSearchState = search.value; // Get current state

    search.sink(!currentSearchState);
  }

  onIncreaseQty(InventoryTransferLine line) {
    line.increaseQty();
   onTableUpdate.sink(true);
    inventoryTransfer.calculateTotal();
//     Utilts.total =line.total;
  }
  onUpdateQty(InventoryTransferLine line) {
     
   onTableUpdate.sink(true);
    inventoryTransfer.calculateTotal();
  }
  onDecreaseQty(InventoryTransferLine line) {
    line.decreaseQty();
    onTableUpdate.sink(true);
    inventoryTransfer.calculateTotal();
 //   Utilts.total =line.total;
  }
  void removeLine(InventoryTransferLine line) {
  inventoryTransfer.lines.remove(line);
  onTableUpdate.sink(true);
    inventoryTransfer.calculateTotal();
}


  Future<bool> saveInventoryTransfer(String statue, BuildContext context) async {
 inventoryTransfer.status = statue;
    if (inventoryTransfer.id == "") {
      String getTransferNumber =
          await InventoryTransferService().getTransferNumber() ?? '';
         inventoryTransfer.transferNumber= getTransferNumber;
    }
    try {
      bool success = await InventoryTransferService()
          .saveInventoryTransfer(inventoryTransfer.toJson());
showTopSnackBar(
                        // ignore: use_build_context_synchronously
                        Overlay.of(context),
                         CustomSnackBar.success(
                          message:
                          statue=="open"?
                             'inventory Transfer open successfully!'.tr()
                              :'inventory Transfer $statue successfully!',
                        ),);
      return success;
    } catch (e) {
//  showTopSnackBar(
//                         // ignore: use_build_context_synchronously
//                         Overlay.of(context),
//                          CustomSnackBar.error(
//                           message:
//                              statue=="open"?
//                              'Faild to open inventory Transfer!'.tr()
//                               :'Faild to  $statue inventory Transfer',
//                         ),);
      return false;
    }
  }
  Future<Product?> fetchProductById(String id) async {
  try {
    Product? fetchedProduct = await ProductService().getProductById(id);

    if (fetchedProduct != null) {
      return fetchedProduct;
    } else {
      // Handle case where product is not found
 //     print('Product not found for ID: $id');
      return null;
    }
  } catch (e) {
    // Handle the error appropriately
  //  print('Error fetching product: $e');
    return null;
  }
}
 // ignore: non_constant_identifier_names
 Future<bool> ConfirmedInventoryTransfer(
      BuildContext context,
      TextEditingController referenceController,
      TextEditingController noteController) async {
   inventoryTransfer.reference = referenceController.text;
    inventoryTransfer.note = noteController.text;

 onTableUpdate.sink(true);
    bool success = await saveInventoryTransfer("Confirmed" , context);
  //  print(inventoryTransfer.id.isEmpty);

    if (success) {
       // ignore: use_build_context_synchronously
       NavigationService(context).goToTransferOutList(TransferOutListBloc());
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => TransferOutList(
      //       bloc: TransferOutListBloc(),
      //     ),
      //   ),
      // );
      // print(inventoryTransfer.id.isEmpty);
      // print('inventory Transfer Confirmed successfully!');

      await inventoryTransfer.updateProductOnHand();
    } else {
      // print(inventoryTransfer.toJson());
      // print(success);
    }

    msg = success
        ? 'inventory Transfer Confirmed successfully!'
        : 'Failed to Confirmed inventory Transfer order.';

// referenceController.dispose();
// noteController.dispose();
    return success; 
  }
   // ignore: non_constant_identifier_names
   Future<bool> OpenInventoryTransfer(
      BuildContext context,
      TextEditingController referenceController,
      TextEditingController noteController) async {
   inventoryTransfer.reference = referenceController.text;
    inventoryTransfer.note = noteController.text;
    if(inventoryTransfer.reason=="To Another Branch") {
      inventoryTransfer.destinationBranch=inventoryTransfer.destinationBranch;
    }
 onTableUpdate.sink(true);
    bool success = await saveInventoryTransfer("Open",context);
   // print(inventoryTransfer.id.isEmpty);

    if (success) {
       // ignore: use_build_context_synchronously
       NavigationService(context).goToTransferOutList(TransferOutListBloc());

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => TransferOutList(
      //       bloc: TransferOutListBloc(),
      //     ),
      //   ),
      // );
      // print(inventoryTransfer.id.isEmpty);
      // print('inventory Transfer Open successfully!');

    } else {
      // print(inventoryTransfer.toJson());
      // print(success);
    }

// referenceController.dispose();
// noteController.dispose();
    return success; 
  }
Future<bool> fetchProduct(BuildContext context, String barcode, 
double quantity, [List<InventoryTransferLine?>? batch,
 List<double>? batchQuantities,List<InventoryTransferLine?>? serial]) async {
  String branchId = Utilts.branchid;
  Product? fetchedProduct = await ProductService().getBranchProductByBarcode(branchId, searchTerm: barcode);
 
  if (fetchedProduct != null) {
    print("Barcode: " + fetchedProduct.barcode);

    bool barcodeExists = inventoryTransfer.lines.any((line) => line.product?.barcode == barcode);
Future<List<InventoryTransferLine?>> futureBatches = Future.value(batch);
Future<List<InventoryTransferLine?>> futureSerial = Future.value(serial);
    if (!barcodeExists) {
      inventoryTransfer.addLine(fetchedProduct, quantity, futureBatches,batchQuantities,futureSerial );
     inventoryTransfer.onTableUpdate.sink(true);
   
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
   inventoryTransfer.calculateTotal();
  return false;
}
  Future<void> fetchAndAddProductsFromBarcodes() async {
   try{for (String barcodeWithQuantity in allBarcode) {
      
      String barcode = barcodeWithQuantity.split(' (Qty: ')[0]; 

      Product? fetchedProduct = await ProductService().getBranchProductByBarcode(Utilts.branchid, searchTerm: barcode);
      double quantity = double.parse(barcodeWithQuantity.split(' (Qty: ')[1].replaceAll(')', ''))-1;
      if (fetchedProduct != null) {
        inventoryTransfer.addLine(fetchedProduct , quantity);
     for (var element in inventoryTransfer.lines) {
if(element.productId == fetchedProduct.id)
{element.onHand=fetchedProduct.onHand;
element.unitCost=fetchedProduct.unitCost;}
      }
      
    inventoryTransfer.calculateTotal();
      }
    }
    onTableUpdate.sink(true); }
    catch (e) {
 
 //   print('Error fetching products: $e');

  }
  }
 
 Future<void> fetchAndAddProductsFromBarcodes2() async {
  try {
    for (String barcodeWithQuantity in allBarcode) {
      String barcode = barcodeWithQuantity.split(' (Qty: ')[0]; // Get the barcode part

      Product? fetchedProduct = await ProductService()
          .getBranchProductByBarcode(Utilts.branchid, searchTerm: barcode);

      // Fetch batches and serials
      List<InventoryTransferLine?>? batches = await fetchPatch(Utilts.branchid, fetchedProduct!.id);
      List<InventoryTransferLine?>? serials = await fetchSerial(Utilts.branchid, fetchedProduct!.id);

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
          Future<List<InventoryTransferLine?>> futureBatches = Future.value(batch);
Future<List<InventoryTransferLine?>> futureSerial = Future.value(serials);
   
        //List<bool> serialSelections = serials?.map((serial) => serial?.isAvailable ?? false).toList() ?? [];

        // Pass the extracted quantities and selections to the addLine function
        inventoryTransfer.addLine(fetchedProduct, quantity, futureBatches, batchQuantities, futureSerial,serialSelections , true);
        inventoryTransfer.calculateTotal();
      } else {
        print('Product not found for barcode: $barcode');
      }
    }

    onTableUpdate.sink(true);
  } catch (e) {
    print('Error fetching products: $e');
  }
}
 
 
 
 Future<String> fetchProductnameById(String id) async {
  
    try {
    
     Product? fetchedProduct = await ProductService().getProductById(id);

      if (fetchedProduct != null) {
        return fetchedProduct.name;
      } else {
        return 'Product not found';
      }
    } catch (e) {
      return 'Error fetching product: $e';
    }
  }
}
