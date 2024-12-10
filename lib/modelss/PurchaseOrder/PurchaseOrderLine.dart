// Adjust according to your file structure

import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/modelss/PurchaseOrderProduct.dart';
import 'package:invo_models/invo_models.dart';
import 'package:invo_models/models/Product.dart';

class PurchaseOrderLine {
  String id = '';
  String taxName='';
  String purchaseOrderId = '';
  String? productId;
  PurchaseOrderProduct? product;
  String barcode = '';
  int qty = 0;
  double unitCost = 0.0;
  String accountId = '';
  String note = '';

  double subTotal = 0.0;
  double total = 0.0;

  String taxId ="";
  double taxTotal = 0.0;
  List<dynamic> taxes = []; 
  String taxType = ''; // 'flat' or 'stacked'
  double taxPercentage =0.0;

  bool isInclusiveTax = false;
  Map<String, dynamic> selectedItem = {};

  String accountName = '';
  String SIC = ''; // Supplier Item Code

  PurchaseOrderLine();

  factory PurchaseOrderLine.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine()
      ..id = json['id'] as String? ?? ''
      ..purchaseOrderId = json['purchaseOrderId'] as String? ?? ''
      ..taxName = json['taxName'] as String? ?? ''
      ..productId = json['productId'] as String?
      ..barcode = json['barcode'] as String? ?? ''
      ..qty = json['qty'] as int? ?? 0
      ..unitCost = (json['unitCost'] as num?)?.toDouble() ?? 0.0
      ..accountId = json['accountId'] as String? ?? ''
      ..note = json['note'] as String? ?? ''
      ..subTotal = (json['subTotal'] as num?)?.toDouble() ?? 0.0
      ..total = (json['total'] as num?)?.toDouble() ?? 0.0
      ..taxId = json['taxId'] as String? ?? ''
      ..taxTotal = (json['taxTotal'] as num?)?.toDouble() ?? 0.0
      ..taxes = json['taxes'] as List<dynamic> ?? []
      ..taxType = json['taxType'] as String? ?? ''
      ..taxPercentage = (json['taxPercentage'] as num?)?.toDouble() ?? 0.0
      ..isInclusiveTax = json['isInclusiveTax'] as bool? ?? false
      ..selectedItem = json['selectedItem'] as Map<String, dynamic>? ?? {}
      ..accountName = json['accountName'] as String? ?? ''
      ..SIC = json['SIC'] as String? ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taxName':taxName,
      'purchaseOrderId': purchaseOrderId,
      'productId': productId,
      'barcode': barcode,
      'qty': qty,
      'unitCost': unitCost,
      'accountId': accountId,
      'note': note,
      'subTotal': subTotal,
      'total': total,
      'taxId': taxId,
      'taxTotal': taxTotal,
      'taxes': taxes,
      'taxType': taxType,
      'taxPercentage': taxPercentage,
      'isInclusiveTax': isInclusiveTax,
      'selectedItem': selectedItem,
      'accountName': accountName,
      'SIC': SIC,
    };
  }

  void increaseQty() {
    qty++;
    calculateTotal();
    //calculateTax(0.00001);
    // Utilts.itemSubTotal = total;
    // Utilts.itemSubTotal += total;
  }

  void decreaseQty() {
    if (qty > 0) {
      qty--;
    }
        calculateTotal();
         // calculateTax(0.00001);
     //     Utilts.itemSubTotal += total;

  }
  // void calculateTax(double afterDecimal) {
  //   if (taxes.isNotEmpty) {
  //     double total = this.total; // qty * price
  //     double taxTotal = 0.0;
  //     double taxTotalPercentage = 0.0;
  //     List<dynamic> taxesTemp = [];

  //     if (taxType == 'flat') {
  //       for (var tax in taxes) {
  //         double taxAmount = isInclusiveTax
  //             ? ((total * taxPercentage)/ (100 + taxPercentage)/ afterDecimal)
  //             : (total * (taxPercentage / 100));

  //         taxTotalPercentage += taxPercentage;
  //         taxTotal += taxAmount;
  //    Utilts.taxTotal = taxAmount;
  //         taxesTemp.add(tax);
  //       }
  //     } else if (taxType == 'stacked') {
  //       for (var tax in taxes) {
  //         double taxAmount = isInclusiveTax
  //             ? (total * taxPercentage)/ (100 + taxPercentage)/afterDecimal
  //             : (total * (taxPercentage / 100));

  //         taxTotalPercentage += taxPercentage;
  //         taxTotal += taxAmount;
  //         total += taxAmount;
  //  Utilts.taxTotal = taxAmount;
  //         taxesTemp.add(tax);
  //       }
  //     }
  //     this.taxPercentage = taxTotalPercentage;
  //     this.taxTotal = taxTotal;
  //     this.taxes = taxesTemp;
  //   } else {
  //     taxTotal = isInclusiveTax
  //         ? (Utilts.total * this.taxPercentage)/(100 + this.taxPercentage)/ afterDecimal
  //          : (Utilts.total/ (this.taxPercentage / 100)/ afterDecimal);
  //        Utilts.taxTotal = taxTotal;
  //   }
  // }
void calculateTax(double afterDecimal) {
  if (taxes.isNotEmpty) {

    double taxTotal = 0.0;
    double taxTotalPercentage = 0.0;

    for (var tax in taxes) {
      double taxAmount = isInclusiveTax
          ? (total * taxPercentage) / (100 + taxPercentage)
          : (total * (taxPercentage / 100));

      taxTotalPercentage +=  taxPercentage;
      taxTotal += taxAmount;
    }

    this.taxPercentage = taxTotalPercentage;
    this.taxTotal = taxTotal;
  } else {
    
    taxTotal = isInclusiveTax
        ? ( qty * unitCost * taxPercentage) / (100 + taxPercentage)
        :  qty * unitCost * (taxPercentage / 100);
  }
      
// total += taxTotal;
 /// calculateTotal();
 //  Utilts.taxTotal = taxTotal;
// Utilts.total +=total ;
 //
}
  void calculateTotal() {
    // unitCost = Helper.roundNum(unitCost, afterDecimal);
   
    subTotal = qty * unitCost;
    if (qty == 0) {
      taxTotal=0;
    }
calculateTax(0.10);
    total = subTotal + taxTotal;


    // if (taxId != '' && taxId != null) {
    //   calculateTax(0.01);
    //   if (!isInclusiveTax) {
    //     total += taxTotal;
    //  //  Utilts.taxTotal = taxTotal;
    //   }
    // }
  }
}
