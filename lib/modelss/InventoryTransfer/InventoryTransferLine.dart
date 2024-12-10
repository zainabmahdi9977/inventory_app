import 'package:flutter/material.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:invo_models/invo_models.dart';

class InventoryTransferLine {
  String id = '';
  String inventoryTransferId = '';
  String productId = '';
  double qty = 0;
  double unitCost = 0.0;
  Product? product;
  List<InventoryTransferLine> serials;
  List<InventoryTransferLine> batches;
  String? parentId = '';
  String serial = '';
  String batch = '';
  double total=0.0;
  DateTime? expireDate;
  DateTime? prodDate;
  String productName = '';
  String categoryName = '';
  String barcode = '';
  String type = '';
  String UOM = '';
  double onHand = 0;
  bool isSelected = false;
  bool transfer = false;

  // Constructor
  InventoryTransferLine()
      : serials = [],
        batches = [];
  double get onhand {
    if(batches.isNotEmpty)
    {
    onHand=0;
    for(var onhands in batches)
onHand+=onhands.onhand;
return onHand;}
    else if(serials.isNotEmpty)
    {
   

return serials.length.toDouble();}
else return onHand;
  }
    double get unitcost {
    if(batches.isNotEmpty)
    {
    double totalunitCost=0;
    unitCost=0;
    for(var unitCosts in batches)
totalunitCost+=unitCosts.unitCost;
unitCost=totalunitCost/batches.length;
return unitCost;}
    else if(serials.isNotEmpty)

    {
    double totalunitCost=0;
       unitCost=0;
    for(var unitCosts in serials) {
      totalunitCost+=unitCosts.unitCost;
    }
unitCost=totalunitCost/serials.length;
return unitCost;}
else return unitCost;
  }
  // Factory constructor to create an instance from JSON
  factory InventoryTransferLine.fromJson(Map<String, dynamic> json) {
    return InventoryTransferLine()
      ..id = json['id'] as String? ?? ''
      ..inventoryTransferId = json['InventoryTransferId'] as String? ?? ''
      ..productId = json['productId'] as String? ?? ''
      ..qty = (json['qty'] as num?)?.toDouble() ?? 0
      ..unitCost = (json['unitCost'] as num?)?.toDouble() ?? 0.0
      ..total=(json['total'] as num?)?.toDouble() ?? 0.0
      ..serials = (json['serials'] as List<dynamic>? ?? [])
          .map((serial) => InventoryTransferLine.fromJson(serial))
          .toList()
      ..batches = (json['batches'] as List<dynamic>? ?? [])
          .map((batch) => InventoryTransferLine.fromJson(batch))
          .toList()
      ..serial = json['serial'] as String? ?? ''
      ..batch = json['batch'] as String? ?? ''
      ..expireDate = json['expireDate'] != null ? DateTime.parse(json['expireDate']) : null
      ..prodDate = json['prodDate'] != null ? DateTime.parse(json['prodDate']) : null
      ..parentId = json['parentId'] as String?
      ..productName = json['productName'] as String? ?? ''
      ..categoryName = json['categoryName'] as String? ?? ''
      ..barcode = json['barcode'] as String? ?? ''
      ..type = json['type'] as String? ?? ''
      ..UOM = json['UOM'] as String? ?? ''
      ..onHand =(json['onHand'] as num?)?.toDouble() ?? 0 
      ..isSelected = json['isSelected'] as bool? ?? false
      ..transfer = json['transfer'] as bool? ?? false;
  }

  // Convert the InventoryTransferLine object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'InventoryTransferId': inventoryTransferId,
      'productId': productId,
      'qty': qty,
      'unitCost': unitCost,
      'serials': serials.map((serial) => serial).toList(),
      'batches': batches.map((batch) => batch).toList(),
      'serial': serial,
      'batch': batch,
      'expireDate': expireDate?.toIso8601String(),
      'prodDate': prodDate?.toIso8601String(),
      'parentId': parentId,
      'productName': productName,
      'categoryName': categoryName,
      'barcode': barcode,
      'type': type,
      'UOM': UOM,
      'onHand': onHand,
      'isSelected': isSelected,
      'transfer': transfer,
      'total':total
    };
  }

  // Method to increase quantity
  void increaseQty() {
    if((qty<onHand || qty==onHand-1 )&& onHand!=0)
    qty++;
    calculateTotal;
  }

  // Method to decrease quantity
  void decreaseQty() {
    if (qty > 0) {
      qty--;
    }
    calculateTotal;
  }

  // Method to calculate total
  double get calculateTotal{
  //  total = qty * unitCost;
    if (batches.isNotEmpty) {
     total=0;
      for (var element in batches) {
        if(element.isSelected)
        total += element.qty * element.unitCost;
        
      }return total;} 

      
  else if (serials.isNotEmpty){
    total =0;
   for (var element in serials) {
            
        if(element.isSelected==true) {
          total += element.unitCost;
        }
      }  return total;}

     else{   
     total = qty * unitCost;  
      return total;}
  }
 
  /**
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
  } */
}