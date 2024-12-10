import 'package:intl/intl.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/modelss/PhysicalCount/PhysicalCountLine.dart';
import 'package:inventory_app/modelss/ProductBatch.dart';
import 'package:inventory_app/serviecs/product.services.dart';
//import 'package:inventory_app/modelss/product.dart';
import 'package:invo_models/models/Product.dart';
import 'package:invo_models/utils/property.dart';

class PhysicalCount {
  String id;
  String reference;
  String status;
  String note;
  String type;
  String branchId;

  DateTime createdDate;
  DateTime? calculatedDate;
  DateTime? closedDate;
  String createdEmployeeId;
  String? calculatedEmployeeId;
  String? closedEmployeeId;

  List<PhysicalCountLine> lines;
  String currentStatus;
  String calculatedEmployeeName;
  String createdEmployeeName;
  String closedEmployeeName;

  List<Log> logs;

  // Constructor
  PhysicalCount({
    this.id = '',
    this.reference = '',
    this.status = '',
    this.note = '',
    this.type = 'By Product',
    this.branchId = '',
    DateTime? createdDate,
    this.calculatedDate,
    this.closedDate,
    this.createdEmployeeId = '',
    this.calculatedEmployeeId = '',
    this.closedEmployeeId,
    List<PhysicalCountLine>? lines,
    this.currentStatus = '',
    this.calculatedEmployeeName = '',
    this.createdEmployeeName = '',
    this.closedEmployeeName = '',
    List<Log>? logs,
  })  : this.createdDate = createdDate ?? DateTime.now(),
        this.lines = lines ?? [],
        this.logs = logs ?? [];

  // Factory method to create an instance from JSON
  factory PhysicalCount.fromJson(Map<String, dynamic> json) {
    return PhysicalCount(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      type: json['type'] ?? '',
      branchId: json['branchId'] ?? '',
      createdDate: DateTime.parse(
          json['createdDate'] ?? DateTime.now().toIso8601String()),
      calculatedDate: json['calculatedDate'] != null
          ? DateTime.parse(json['calculatedDate'])
          : null,

      // calculatedDate: DateTime.parse(
      //     json['calculatedDate'] ?? DateTime.parse(json['calculatedDate']).toIso8601String()),
      closedDate: json['closedDate'] != null
          ? DateTime.parse(json['closedDate'])
          : null,

      //   closedDate: DateTime.parse(
      // json['closedDate'] ?? DateTime.parse(json['closedDate']).toIso8601String()),
      createdEmployeeId: json['createdEmployeeId'] ?? '',
      calculatedEmployeeId: json['calculatedEmployeeId'],
      closedEmployeeId: json['closedEmployeeId'],
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((line) => PhysicalCountLine.fromJson(line))
          .toList(),
      currentStatus: json['currentStatus'] ?? '',
      calculatedEmployeeName: json['calculatedEmployeeName'] ?? '',
      createdEmployeeName: json['createdEmployeeName'] ?? '',
      closedEmployeeName: json['closedEmployeeName'] ?? '',
      logs: (json['logs'] as List<dynamic>? ?? [])
          .map((log) => Log.fromJson(log))
          .toList(),
    );
  }

  // void calculateTotals() {
  //   double totalQuantity = 0.0;
  //   double CalculatedValue=0.0;
  //   double actualValue=0.0;
  //   for (var line in lines) {
  //     totalQuantity += line.enteredQty;
  //     CalculatedValue+=line.CalculatedValue;
  //     actualValue+=line.Actualvalue;
  //   }
  //   print('Total Quantity: $CalculatedValue');
  // }
  Property<bool> onTableUpdate = Property(false);
  double calculatedValue = 0;
  double actualValue = 0.0;

  calculate() {
    calculatedValue = 0.0;
    for (var line in lines) {
      calculatedValue += line.calculatedValue;
    }

    actualValue = 0.0;
    for (var line in lines) {
      actualValue += line.actualvalue;
    }
  }

  double get difference {
    return actualValue - calculatedValue;
  }

  // double get CalculatedValue {
  //   double CalculatedValue = 0.0;
  //   for (var line in lines) {
  //     CalculatedValue += line.CalculatedValue;
  //   }
  //   Utilts.CalculatedValue = CalculatedValue;
  //   return CalculatedValue;
  // }

  // double get actualValue {
  //   double actualValue = 0.0;
  //   for (var line in lines) {
  //     actualValue += line.Actualvalue;
  //   }
  //   Utilts.actualValue = actualValue;
  //   return actualValue;
  // }

  // double get setex {
  //   for (var line in lines) {
  //     line.setExpectedQty;
  //   }

  //   return 0.0;
  // }

  // Future<void> updateProductOnHand() async {
  //   for (var line in lines) {
  //     line.product?.onHand = line.enteredQty;
  //   }
  // }

  // Convert the PhysicalCount object back to JSON
  Map<String, dynamic> toJson() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    return {
      'id': id,
      'reference': reference,
      'status': status,
      'note': note,
      'type': type,
      'branchId': branchId,
      'createdDate': formatter.format(createdDate),
      'calculatedDate':
          calculatedDate == null ? null : formatter.format(calculatedDate!),
      'closedDate': closedDate == null ? null : formatter.format(closedDate!),
      'createdEmployeeId': createdEmployeeId,
      'calculatedEmployeeId': calculatedEmployeeId,
      'closedEmployeeId': closedEmployeeId,
      'lines': lines.map((line) => line.toJson()).toList(),
      'currentStatus': currentStatus,
      'calculatedEmployeeName': calculatedEmployeeName,
      'createdEmployeeName': createdEmployeeName,
      'closedEmployeeName': closedEmployeeName,
      'logs': logs.map((log) => log.toJson()).toList(),
    };
  }

 void addLine(Product fetchedProduct, double qty, 
 

    [Future<List<PhysicalCountLine?>>? productBatchesFuture,
    List<double>? batchQuantities,
    Future<List<PhysicalCountLine?>>? productSerilsFuture ,
     List<bool>? serialavalibale]) {
  PhysicalCountLine physicalCountLine = PhysicalCountLine();

  physicalCountLine.productId = fetchedProduct.id;
  physicalCountLine.product = fetchedProduct;
  physicalCountLine.enteredQty = qty;
physicalCountLine.productType=fetchedProduct.type;
physicalCountLine.productName=fetchedProduct.name;
    physicalCountLine.unitCost = fetchedProduct.unitCost;



  if (fetchedProduct.type == "batch") {
  
    productBatchesFuture?.then((batches) {
      var validBatches = batches.whereType<PhysicalCountLine>().toList();

      if (batchQuantities != null && batchQuantities.isNotEmpty) {
        for (int i = 0; i < validBatches.length && i < batchQuantities.length; i++) {
          validBatches[i].enteredQty = batchQuantities[i];
       //   validBatches[i].unitCost=fetchedProduct.unitCost;
        }
      }

      physicalCountLine.batches = validBatches;

      double totalBatchValue = validBatches.fold(0.0, (sum, batch) => sum + (batch.enteredQty * batch.unitCost));

      calculatedValue += totalBatchValue;
      lines.add(physicalCountLine);
      onTableUpdate.sink(true);
    }).catchError((error) {
      print('Error fetching product batches: $error');
    });
  }
    else if (fetchedProduct.type == "serialized") {
    calculate();
    productSerilsFuture?.then((Serils) {
      var validSerils = Serils.whereType<PhysicalCountLine>().toList();
  
       if (serialavalibale != null && serialavalibale.length == validSerils.length) {
        for (int i = 0; i < validSerils.length; i++) {
          validSerils[i]?.isAvailable = serialavalibale[i];
          if (validSerils[i].isAvailable==true) {
            validSerils[i].enteredQty = 1;
          }
        }}
     
        for (int i = 0; i < validSerils.length ; i++) {
     
          if(validSerils[i].isAvailable==true)
          validSerils[i].enteredQty = 1;
       //   validBatches[i].unitCost=fetchedProduct.unitCost;
      
      }

      physicalCountLine.serials = validSerils;

      double totalserialsValue = validSerils.fold(0.0, (sum, seril) => sum + (seril.enteredQty * seril.unitCost));

      calculatedValue += totalserialsValue;
      lines.add(physicalCountLine);
      onTableUpdate.sink(true);
    }).catchError((error) {
      print('Error fetching product batches: $error');
    });
  }
  else
  {     
   lines.add(physicalCountLine);
      onTableUpdate.sink(true);}
  calculate();}

}

class Log {
  String action;
  DateTime timestamp;

  Log({
    this.action = '',
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();

  // Factory method to create an instance from JSON
  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      action: json['action'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
