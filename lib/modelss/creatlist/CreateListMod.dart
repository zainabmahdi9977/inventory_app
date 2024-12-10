// import 'package:inventory_app/modelss/CreateListlineMod.dart';
// import 'package:invo_models/models/Product.dart';
// import 'package:uuid/uuid.dart';
// class CreateListMod {
//   String id;
//    String name;
//   List<CreateListlineMod> lines;

// CreateListMod({required this.lines, required this.name}) : id = Uuid().v4();

//   Map<String, dynamic> toJson() {
//     return {
//       'lines': lines.map((line) => line.toJson()).toList(),
//       'id': id,
//       'name': name,
//     };
//   }

//   void addLine(Product fetchedProduct) {
//     CreateListlineMod createListlineMod = CreateListlineMod();
//     createListlineMod.id = fetchedProduct.id;
//     createListlineMod.product = fetchedProduct;
//     createListlineMod.unitCost = fetchedProduct.unitCost;
//     createListlineMod.name = fetchedProduct.name;
//     lines.add(createListlineMod);
//   }
 
//   factory CreateListMod.fromJson(Map<String, dynamic> json) {
//     return CreateListMod(
//       lines: (json['lines'] as List).map((lineJson) => CreateListlineMod.fromJson(lineJson)).toList(),
//       id: json['id'] as String,
//       name: json['name'] as String,
//     );
//   }

// }
import 'package:inventory_app/modelss/creatlist/CreateListlineMod.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid.dart';

class CreateListMod {
  List<CreateListlineMod> lines =[];
   String id=''; 
  String name='';

  // Constructor that auto-generates a unique ID
  CreateListMod() : id = Uuid().v4(); // Generate a unique ID

  factory CreateListMod.fromJson(Map<String, dynamic> json) {
    return CreateListMod(
   
    
    )..id = json['id'] as String? ??''
      ..lines = (json['lines'] as List<dynamic>?)
              ?.map(
                  (e) => CreateListlineMod.fromJson(e as Map<String, dynamic>))
              .toList() ??[]
                ..name= json['name'] as String? ??'';
  }

  Map<String, dynamic> toJson() {
    return {
    'lines': lines.map((e) => e.toJson()).toList(),
      'id': id,
      'name': name,
    };
  }
}