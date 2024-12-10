import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransferLine.dart';
import 'package:invo_models/models/Product.dart';
import 'package:invo_models/models/ProductBatch.dart';
import 'package:invo_models/utils/property.dart';

class InventoryTransfer {
  String id = '';
  String transferNumber = '';
  DateTime createdDate;
  String reference = '';
  String employeeId = '';
  String type = 'Transfer Out';
  String status = '';
  String reason = '';
  String note = '';
  String branchId = '';
  String? destinationBranch;
  DateTime confirmDatetime;
  List<InventoryTransferLine> lines;
Property<bool> onTableUpdate = Property(false);
  String currentStatus = '';
  String employeeName = '';
  String branchName = '';
  String destinationBranchName = '';

  // Constructor
  InventoryTransfer()
      : createdDate = DateTime.now(),
        confirmDatetime = DateTime.now(),
        lines = [];

  InventoryTransfer.custom({
    this.id = '',
    this.transferNumber = '',
    DateTime? createdDate,
    this.reference = '',
    this.employeeId = '',
    this.type = '',
    this.status = '',
    this.reason = '',
    this.note = '',
    this.branchId = '',
    this.destinationBranch,
    DateTime? confirmDatetime,
    List<InventoryTransferLine>? lines,
    this.currentStatus = '',
    this.employeeName = '',
    this.branchName = '',
    this.destinationBranchName = '',
  })  : createdDate = createdDate ?? DateTime.now(),
        confirmDatetime = confirmDatetime ?? DateTime.now(),
        this.lines = lines ?? [];
     

  // Factory constructor to create an instance from JSON
  factory InventoryTransfer.fromJson(Map<String, dynamic> json) {
    return InventoryTransfer.custom(
      id: json['id'] as String? ?? '',
      transferNumber: json['transferNumber'] as String? ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      reference: json['reference'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      note: json['note'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      destinationBranch: json['destinationBranch'] as String?,
      confirmDatetime: DateTime.parse(json['confirmDatetime']),
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((item) => InventoryTransferLine.fromJson(item))
          .toList(),
      currentStatus: json['currentStatus'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      destinationBranchName: json['destinationBranchName'] as String? ?? '',
    );
  }

  // Convert the InventoryTransfer object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transferNumber': transferNumber,
      'createdDate': createdDate.toIso8601String(),
      'reference': reference,
      'employeeId': employeeId,
      'type': type,
      'status': status,
      'reason': reason,
      'note': note,
      'branchId': branchId,
      'destinationBranch': destinationBranch,
      'confirmDatetime': confirmDatetime.toIso8601String(),
      'lines': lines.map((item) => item.toJson()).toList(),
      'currentStatus': currentStatus,
      'employeeName': employeeName,
      'branchName': branchName,
      'destinationBranchName': destinationBranchName,
    };
  }

  // Calculate total for all lines
  double calculateTotal() {
double total = 0;
    for (var element in lines) {
    element.calculateTotal;
      total += element.total;
    }
// Utilts.total=total ;
return total;
  }
  /**void calculateTotal() {
  double itemSubTotal = 0.0;
  double purchaseTaxTotal = 0.0;
 double total = shipping; // Start with the shipping cost

  for (var element in lines) {
    element.calculateTotal(); // Ensure each line calculates its total
    itemSubTotal += element.subTotal;
    purchaseTaxTotal += element.taxTotal;
    total += element.total; // Aggregate the total from each line
  }

  this.itemSubTotal = itemSubTotal;
  this.purchaseTaxTotal = purchaseTaxTotal;
  this.total = total; 
  // Final total includes line totals and shipping
  Utilts.itemSubTotal=  this.itemSubTotal ;
Utilts.total=this.total ;
 Utilts.taxTotal = purchaseTaxTotal;

} */

  // Add a line item to the transfer
 void addLine(Product fetchedProduct, double qty,
    [Future<List<InventoryTransferLine?>>? productBatchesFuture,
    List<double>? batchQuantities,
    Future<List<InventoryTransferLine?>>? productSerilsFuture 
    ,  List<bool>? serialavalibale , bool? converted]) {
  InventoryTransferLine inventoryTransferLine = InventoryTransferLine();
  inventoryTransferLine.productName = fetchedProduct.name;
  inventoryTransferLine.productId = fetchedProduct.id;
 inventoryTransferLine.product = fetchedProduct;
 if(fetchedProduct.type != "batch") {

      inventoryTransferLine.qty = qty;
 }
inventoryTransferLine.type=fetchedProduct.type;
inventoryTransferLine.onHand=fetchedProduct.onHand; 
    inventoryTransferLine.unitCost = fetchedProduct.unitCost;



  if (fetchedProduct.type == "batch") {
  
    productBatchesFuture?.then((batches) {
      var validBatches = batches.whereType<InventoryTransferLine>().toList();

      if (batchQuantities != null && batchQuantities.isNotEmpty) {
        for (int i = 0; i < validBatches.length && i < batchQuantities.length; i++) {
          if(batchQuantities[i]> validBatches[i].onHand) {
            validBatches[i].qty = validBatches[i].onHand;
          } else if (validBatches[i].onHand==0)
           validBatches[i].qty = 0;
           else
          validBatches[i].qty = batchQuantities[i];
          if(converted==true)
          if (validBatches[i].onHand==0) {
            validBatches[i].isSelected=false;
          }
          else
    validBatches[i].isSelected=true;
        }
      }
       calculateTotal();

      inventoryTransferLine.batches = validBatches;
for(var batches in inventoryTransferLine.batches) {
  inventoryTransferLine.qty+=batches.qty;
}
      double totalBatchValue = validBatches.fold(0.0, (sum, batch) => sum + (batch.qty * batch.unitCost));

      //calculatedValue += totalBatchValue;
      lines.add(inventoryTransferLine);
      onTableUpdate.sink(true);
    }).catchError((error) {
      print('Error fetching product batches: $error');
    });
  }
    else if (fetchedProduct.type == "serialized") {
             calculateTotal();
  
  //  calculate();
    productSerilsFuture?.then((Serils) {
      var validSerils = Serils.whereType<InventoryTransferLine>().toList();

            if (serialavalibale != null && serialavalibale.length == validSerils.length) {
        for (int i = 0; i < validSerils.length; i++) {
          validSerils[i]?.isSelected = serialavalibale[i];
          if (validSerils[i].isSelected==true) {
            validSerils[i].qty = 1;
    //                   if(converted==true)
    // validSerils[i].isSelected=true;
          }
        }}
        for (int i = 0; i < validSerils.length ; i++) {
          if(validSerils[i].isSelected==true) {
            validSerils[i].qty = 1;
          }
       //   validBatches[i].unitCost=fetchedProduct.unitCost;
      
      }

      inventoryTransferLine.serials = validSerils;

      double totalserialsValue = validSerils.fold(0.0, (sum, seril) => sum + (seril.qty * seril.unitCost));

      //calculatedValue += totalserialsValue;
      lines.add(inventoryTransferLine);
      onTableUpdate.sink(true);
    }).catchError((error) {
      print('Error fetching product batches: $error');
    });
  }
  else
  {     
         calculateTotal();
  inventoryTransferLine.calculateTotal;
   lines.add(inventoryTransferLine);
      onTableUpdate.sink(true);}}
 // calculate();}

// void addLine(Product fetchedProduct, 
// double qty, [Future<List<InventoryTransferLine?>>?
//  productBatchesFuture,
//     List<double>? batchQuantities,
//     Future<List<InventoryTransferLine?>>?
//      productSerilsFuture ]) {
 
//   if (fetchedProduct.onHand <= 0) {
//     qty = 0.0; 
//   }

//   InventoryTransferLine inventoryTransferLine = InventoryTransferLine()
//     ..productId = fetchedProduct.id
//     ..product = fetchedProduct
//     ..type=fetchedProduct.type
//     ..qty = qty
//     ..onHand=fetchedProduct.onHand
//     ..unitCost=fetchedProduct.unitCost;

//     inventoryTransferLine.unitCost = fetchedProduct.unitCost;
//   if (fetchedProduct.type == "batch") {
//      calculateTotal();
//   inventoryTransferLine.calculateTotal();
//     productBatchesFuture?.then((batches) {
//       var validBatches = batches.whereType<InventoryTransferLine>().toList();

//       if (batchQuantities != null && batchQuantities.isNotEmpty) {
//         for (int i = 0; i < validBatches.length && i < batchQuantities.length; i++) {
//           validBatches[i].qty = batchQuantities[i];
//        //   validBatches[i].unitCost=fetchedProduct.unitCost;
//         }
//       }

//       inventoryTransferLine.batches = validBatches;

//       double totalBatchValue = validBatches.fold(0.0, (sum, batch) => sum + (batch.qty * batch.unitCost));

//       //calculatedValue += totalBatchValue;
//       lines.add(inventoryTransferLine);
//       onTableUpdate.sink(true);
//     }).catchError((error) {
//       print('Error fetching product batches: $error');
//     });
//   }
//     else if (fetchedProduct.type == "serialized") {
//   calculateTotal();
//   inventoryTransferLine.calculateTotal();
//     productSerilsFuture?.then((Serils) {
//       var validSerils = Serils.whereType<InventoryTransferLine>().toList();

     
//         for (int i = 0; i < validSerils.length ; i++) {
//           if(validSerils[i].isSelected==true)
//           validSerils[i].qty = 1;
//        //   validBatches[i].unitCost=fetchedProduct.unitCost;
      
//       }

//       inventoryTransferLine.serials = validSerils;

//       double totalserialsValue = validSerils.fold(0.0, (sum, seril) => sum + (seril.qty * seril.unitCost));

//       //calculatedValue += totalserialsValue;
//       lines.add(inventoryTransferLine);
//       onTableUpdate.sink(true);
//     }).catchError((error) {
//       print('Error fetching product batches: $error');
//     });
//   }
//   lines.add(inventoryTransferLine);
  
//   calculateTotal();
//   inventoryTransferLine.calculateTotal();
//}

  // Update product on hand based on lines
  Future<void> updateProductOnHand() async {
    for (var line in lines) {
      line.onHand = line.onHand - line.qty;
    }
  }
}