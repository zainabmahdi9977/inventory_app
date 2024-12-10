import 'dart:ffi';
//import 'dart:js_interop';

import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/modelss/ProductBatch.dart';
import 'package:inventory_app/serviecs/product.services.dart';
//import 'package:invo_models/invo_models.dart';
import 'package:invo_models/models/Product.dart';
import 'package:invo_models/models/ProductSerial.dart';
//import 'package:inventory_app/modelss/product.dart';

class PhysicalCountLine {
  String id = '';
  String physicalCountId = '';
  String productId = '';
  double enteredQty = 0;
  double expectedQty = 0.0;
  double unitCost = 0;
  Product? product;
  List<PhysicalCountLine> serials;
  List<PhysicalCountLine> batches;
  String? parentId = '';
  String serial = '';
  String batch = '';
  double total = 0.0;
  bool? isAvailable = false;
  double subTotal = 0.0;
   double onHand = 0;
  String productType = '';
  String productName = '';
  String categoryName = '';
  // ignore: non_constant_identifier_names
  String UOM = '';
  String barcode = '';
  String accountId = '';
  // Constructor
  PhysicalCountLine({
    String batch = '',
    String? parentId = '',
    double enteredQty = 0,
    unitCost = 0.0,
  })  : serials = [],
        batches = [];

  double get difference {
    return actualvalue - calculatedValue;
  }

  double get calculatedValue {
    if (batches.isNotEmpty) {
      double value = 0;
      for (var element in batches) {
        value += element.enteredQty * element.unitCost;
      }
      return value;
    } else if (serials.isNotEmpty) {
      double value = 0;
      for (var element in serials) {
        if(element.isAvailable==true)
        value += element.unitCost;
      }
      return value;
    } else {
      return enteredQty * unitCost!;
    }
  }

  double get actualvalue {
    if (product != null) expectedQty = product?.onHand ?? 0;
    return expectedQty * unitCost!;
  }


  factory PhysicalCountLine.fromJson(Map<String, dynamic> json) {
    PhysicalCountLine temp = PhysicalCountLine()
      ..id = json['id'] as String? ?? ''
      ..physicalCountId = json['physicalCountId'] as String? ?? ''
      ..productId = json['productId'] as String? ?? ''
      ..enteredQty = (json['enteredQty'] as num?)?.toDouble() ?? 0.0
      ..expectedQty = (json['expectedQty'] as num?)?.toDouble() ?? 0.0
      ..unitCost = (json['unitCost'] as num?)?.toDouble() ?? 0.0
      ..serials = (json['serials'] as List<dynamic>? ?? [])
          .map((serial) => PhysicalCountLine.fromJson(serial))
          .toList()
      ..batches = (json['batches'] as List<dynamic>? ?? [])
          .map((batch) => PhysicalCountLine.fromJson(batch))
          .toList()
      ..total = (json['total'] as num?)?.toDouble() ?? 0.0
      ..subTotal = (json['subTotal'] as num?)?.toDouble() ?? 0.0
      ..parentId = json['parentId'] as String?
      ..serial = json['serial'] as String? ?? ''
      ..batch = json['batch'] as String? ?? ''
      ..isAvailable = json['isAvailable'] as bool?
      ..productType = json['productType'] as String? ?? ''
      ..productName = json['productName'] as String? ?? ''
      ..categoryName = json['categoryName'] as String? ?? ''
      ..UOM = json['UOM'] as String? ?? ''
      ..barcode = json['barcode'] as String? ?? ''
      ..onHand =(json['onHand'] as num?)?.toDouble() ?? 0 
      ..accountId = json['accountId'] as String? ?? '';
    return temp;
  }

  // Convert the PhysicalCountLine object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'physicalCountId': physicalCountId,
      'subTotal': subTotal,
      'productId': productId,
      'enteredQty': enteredQty,
      'expectedQty': expectedQty,
      'unitCost': unitCost,
      'serials': serials.map((serial) => serial).toList(),
      'batches': batches.map((batch) => batch).toList(),
      'parentId': parentId,
      'serial': serial,
      'batch': batch,
      'total': total,
      'accountId': accountId,
      'isAvailable': isAvailable,
      'productType': productType,
      'productName': productName,
      'categoryName': categoryName,
      'UOM': UOM,
      'barcode': barcode,
       'onHand': onHand,
    };
  }

  // Method to parse JSON (similar to the original ParseJson)
  void parseJson(Map<String, dynamic> json) {
    for (final key in json.keys) {
      if (this.toJson().containsKey(key)) {
        this.toJson()[key] = json[key];
      }
    }
  }

//     static void calculateTotal() {
//     // unitCost = Helper.roundNum(unitCost, afterDecimal);
//     this.subTotal = enteredQty * unitCost;
//     total = subTotal;
// Utilts.total+=total;
//     // if (taxId != '' && taxId != null) {
//     //   calculateTax(afterDecimal);
//     //   if (!isInclusiveTax) {
//     //     total += taxTotal;
//     //   }
//     // }
//   }
  // Future<bool> updateBatches(
  //     String barcode, double quantity, List<double> batchQuantities) async {
  //   // Fetch the product using the barcode
  //   String branchId = Utilts.branchid;
  //   Product? fetchedProduct = await ProductService()
  //       .getBranchProductByBarcode(branchId, searchTerm: barcode);

  //   if (fetchedProduct != null) {
  //     bool barcodeExists = batches.any((batch) => batch.batch == barcode);

  //     if (!barcodeExists) {
  //       // If the batch does not exist, create new batches
  //       int count = fetchedProduct.batches.length;
  //       List<double> quantities = batchQuantities.length == count
  //           ? batchQuantities
  //           : List.filled(count, 0);

  //       batches = fetchedProduct.batches
  //           .asMap()
  //           .map((index, fetchedBatch) {
  //             return MapEntry(
  //                 index,
  //                 ProductBatch2(
  //                   onHand: fetchedBatch.onHand,
  //                   batch: fetchedBatch.batch,
  //                   expireDate: fetchedBatch.expireDate,
  //                   qty: quantities[index],
  //                 ));
  //           })
  //           .values
  //           .toList();
  //     } else {
  //       // If the barcode exists, update the existing batches
  //       for (var fetchedBatch in fetchedProduct.batches) {
  //         var existingBatch = batches.firstWhere(
  //           (b) => b.batch == fetchedBatch.batch,
  //         );
  //         if (existingBatch != null) {
  //           // Update the quantity of the existing batch
  //           int index = batches.indexOf(existingBatch);
  //           batches[index].qty += batchQuantities[index];
  //         } else {
  //           // If the batch does not exist, add it
  //           batches.add(ProductBatch2(
  //             onHand: fetchedBatch.onHand,
  //             batch: fetchedBatch.batch,
  //             expireDate: fetchedBatch.expireDate,
  //             qty: batchQuantities[batches.length],
  //           ));
  //         }
  //       }
  //     }

  //     // Recalculate totals
  //     calculateTotals();
  //     return true;
  //   } else {
  //     return false; // Product not found
  //   }
  // }

  void calculateTotals() {
    // Implement total calculation logic here
    subTotal = enteredQty * unitCost!;
    total = subTotal; // Or any other logic needed
  }

  void decreaseQty() {
    if (enteredQty > 0) {
      enteredQty--;
    }
  }

  void increaseQty() {
    enteredQty++;
  }
}
