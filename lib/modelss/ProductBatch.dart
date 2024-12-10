class ProductBatch2 {
  String id = "";
  String branchProductId = "";
  String batch = "";
  double onHand = 0.0;
  double unitCost = 0.0;
  DateTime prodDate;
  DateTime expireDate;
  String companyId = "";
  DateTime createdAt;
  double qty = 0.0;

  ProductBatch2({
    required this.batch,
    required this.onHand,
    required this.expireDate,
    this.unitCost = 0.0,
    DateTime? prodDate,
    String? companyId,
    DateTime? createdAt,
    this.qty = 0.0,
  })  : this.prodDate = prodDate ?? DateTime.now(),
        this.companyId = companyId ?? '',
        this.createdAt = createdAt ?? DateTime.now();

  // Factory constructor to create an instance from JSON
  factory ProductBatch2.fromJson(Map<String, dynamic> json) {
    return ProductBatch2(
      batch: json['batch'] as String? ?? '',
      onHand: (json['onHand'] as num?)?.toDouble() ?? 0.0,
      expireDate: DateTime.parse(json['expireDate'] ?? DateTime.now().toIso8601String()),
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0.0,
      prodDate: DateTime.tryParse(json['prodDate'] ?? '') ?? DateTime.now(), // Use tryParse for safety
      companyId: json['companyId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(), // Use tryParse for safety
    );
  }

  // Convert the ProductBatch2 object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'batch': batch,
      'onHand': onHand,
      'expireDate': expireDate.toIso8601String(),
      'qty': qty,
      'unitCost': unitCost,
      'prodDate': prodDate.toIso8601String(),
      'companyId': companyId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}