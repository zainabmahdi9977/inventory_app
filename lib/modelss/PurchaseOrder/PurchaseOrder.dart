//import 'log.dart'; // Adjust the import according to your file structure
//import 'purchase_order_line.dart'; // Adjust the import according to your file structure

import 'dart:math';

import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrderLine.dart';
import 'package:inventory_app/modelss/PurchaseOrderProduct.dart';
import 'package:invo_models/models/Product.dart';

class PurchaseOrder {
  String id = '';
  String employeeId = '';
  String supplierId = '';

  String purchaseNumber = '';
  String reference = '';

  String branchId = '';
  bool isBill = false;

  DateTime purchaseDate = DateTime.now();
  DateTime dueDate = DateTime.now();
  DateTime createdAt = DateTime.now();

  double total = 0.0;
  double shipping = 0.0;

  List<PurchaseOrderLine> lines = [];
  bool isInclusiveTax = false;

  double itemSubTotal = 0.0;
  double purchaseTaxTotal = 0.0;

  String supplierName = '';
  String branchName = '';
  String supplierVatNumber = '';

  //String taxId = "";
  //List<Log> logs = [];
  PurchaseOrder();

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder()
      ..id = json['id'] as String? ?? ''
      ..employeeId = json['employeeId'] as String? ?? ''
      ..supplierId = json['supplierId'] as String? ?? ''
      ..purchaseNumber = json['purchaseNumber'] as String? ?? ''
      ..reference = json['reference'] as String? ?? ''
      ..branchId = json['branchId'] as String? ?? ''
      ..isBill = json['isBill'] as bool? ?? false
      ..purchaseDate = json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : DateTime.now()
      ..dueDate = json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : DateTime.now()
      ..createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now()
      ..total = (json['total'] as num?)?.toDouble() ?? 0.0
      ..shipping = (json['shipping'] as num?)?.toDouble() ?? 0.0
      ..lines = (json['lines'] as List<dynamic>?)
              ?.map(
                  (e) => PurchaseOrderLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..isInclusiveTax = json['isInclusiveTax'] as bool? ?? false
      ..itemSubTotal = (json['itemSubTotal'] as num?)?.toDouble() ?? 0.0
      ..purchaseTaxTotal = (json['purchaseTaxTotal'] as num?)?.toDouble() ?? 0.0
      ..supplierName = json['supplierName'] as String? ?? ''
      ..branchName = json['branchName'] as String? ?? ''
      ..supplierVatNumber = json['supplierVatNumber'] as String? ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'supplierId': supplierId,
      'purchaseNumber': purchaseNumber,
      'reference': reference,
      'branchId': branchId,
      'isBill': isBill,
      'purchaseDate': purchaseDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'total': total,
      'shipping': shipping,
      'lines': lines.map((e) => e.toJson()).toList(),
      'isInclusiveTax': isInclusiveTax,
      'itemSubTotal': itemSubTotal,
      'purchaseTaxTotal': purchaseTaxTotal,
      'supplierName': supplierName,
      'branchName': branchName,
      'supplierVatNumber': supplierVatNumber,
    };
  }

//   void calculateTotal() {
 
//     double itemSubTotal = 0.0;
//     double purchaseTaxTotal = 0.0;
// double taxTotal =0.0;
//     for (var element in lines) {
//       element.calculateTotal();

//       element.isInclusiveTax = this.isInclusiveTax;
//       itemSubTotal += element.subTotal;
//       purchaseTaxTotal += element.taxTotal;
//       total += element.total;
   
//     }
//         for (var element in lines) {

//         taxTotal=element.qty*Utilts.selectedTaxPercentage*element.unitCost*0.0100;
// Utilts.taxTotal =taxTotal;
//     }

//     this.itemSubTotal += itemSubTotal;
//     this.purchaseTaxTotal += purchaseTaxTotal;
//     this.total = total + shipping;
//    // Utilts.itemSubTotal=  this.itemSubTotal ;
//    // Utilts.total = this.total;
//   }
void calculateTotal() {
  double itemSubTotal = 0.0;
  double purchaseTaxTotal = 0.0;
 double total = shipping; 
  for (var element in lines) {
    element.calculateTotal(); 
    itemSubTotal += element.subTotal;
    purchaseTaxTotal += element.taxTotal;
    total += element.total; 
  }

  this.itemSubTotal = itemSubTotal;
  this.purchaseTaxTotal = purchaseTaxTotal;
  this.total = total; 
 
//   Utilts.itemSubTotal=  this.itemSubTotal ;
// Utilts.total=this.total ;
//  Utilts.taxTotal = purchaseTaxTotal;

}
  void addLine(PurchaseOrderProduct fetchedProduct , int qty) {
    PurchaseOrderLine purchaseOrderLine = PurchaseOrderLine();
    purchaseOrderLine.productId = fetchedProduct.id;
    purchaseOrderLine.product = fetchedProduct;
    purchaseOrderLine.barcode=fetchedProduct.barcode;
 purchaseOrderLine.qty = qty;
    purchaseOrderLine.unitCost = fetchedProduct.supplierCost==0 ?
    fetchedProduct.productCost
:
   fetchedProduct.supplierCost;

    lines.add(purchaseOrderLine);
    calculateTotal();

  }
}
