import 'package:invo_models/models/Product.dart';

class CreateListlineMod {
  String barcode;
  String id; 
  String productId; 
  String? parentId; // Kept nullable
  String name; 
  String serial; 
  String batch; 
  String productType; 
  final List<CreateListlineMod?>? serials; 
  final List<CreateListlineMod?>? batches; 
  double unitCost;
  double onHand;
  Product? product;
  int qty;
  bool isAvailable=false;

  CreateListlineMod({
    this.parentId, // Made optional
    this.serial = '',
    this.onHand = 0,
    this.batch = '',
    this.productType = '', 
    this.serials,
    this.batches,
    this.barcode = '',
    this.id = '',
    this.productId = '',
    this.name = '',
    this.unitCost = 0.0,
    this.qty = 0,
    this.isAvailable = false,
  });

  Map<String, dynamic> toJson() => {
    'barcode': barcode,
    'name': name,
    'unitCost': unitCost,
    'id': id,
    'onHand': onHand,
    'qty': qty,
    'serial': serial,
    'batch': batch,
    'productType': productType,
    'isAvailable':isAvailable,
    'serials': serials?.map((serial) => serial?.toJson()).toList(),
    'batches': batches?.map((batch) => batch?.toJson()).toList(),
  };

  factory CreateListlineMod.fromJson(Map<String, dynamic> json) {
    return CreateListlineMod(
      barcode: json['barcode'] as String? ?? '',
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0.0,
      qty: json['qty'] ?? 0,
      onHand: (json['onHand'] as num?)?.toDouble() ?? 0.0,
      productType: json['productType'] as String? ?? '',
      serial: json['serial'] as String? ?? '',
      batch: json['batch'] as String? ?? '',
      serials: (json['serials'] as List<dynamic>? ?? [])
          .map((serial) => CreateListlineMod.fromJson(serial))
          .toList(),
      batches: (json['batches'] as List<dynamic>? ?? [])
          .map((batch) => CreateListlineMod.fromJson(batch))
          .toList(),
          isAvailable: json['isAvailable'] as bool? ?? false
    );
  }

  void decreaseQty() {
    if (qty > 0) {
      qty--;
    }
  }

  void increaseQty() {
    qty++;
  }
}