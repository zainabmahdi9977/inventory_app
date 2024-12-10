// // import 'package:flutter/material.dart';
// // import 'package:inventory_app/serviecs/product.services.dart';

// // class PurchaseOrderPage extends StatefulWidget {
// //   @override
// //   _PurchaseOrderPageState createState() => _PurchaseOrderPageState();
// // }

// // class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
// //   final Map<String, dynamic> _purchaseOrderData = {
// //     "id": "0b4cd4eb-beff-4b38-9f14-d98f2ce7bf94",
// //     "purchaseNumber": "PO-2009",
// //     "reference": "",
// //     "employeeId": "",
// //     "supplierId": "51d2fa87-4965-4a01-9310-1db1731a90e5",
// //     "supplierName": "abc",
// //     "dueDate": "2024-10-16T00:00:00.000Z",
// //     "createdAt": "2024-09-16T09:21:28.574Z",
// //     "purchaseDate": "2024-09-16T00:00:00.000Z",
// //     "branchId": "94ffb51a-adf3-4e20-b45c-3dea0eaa1505",
// //     "total": 0,
// //     "lines": [
// //       {
// //         "id": "72430d97-82ab-48a8-ba42-1686aafc9f78",
// //         "purchaseOrderId": "",
// //         "productId": "f715ebb5-a694-4544-bb0f-9d4fb1adfecc",
// //         "note": "",
// //         "barcode": "2916014679409",
// //         "qty": 2,
// //         "unitCost": 0,
// //         "total": 0,
// //         "accountId": "fd471000-d64f-48c0-b0dc-d8141bcf42c1",
// //         "accountName": "Inventory Assets",
// //         "isNew": false,
// //         "selectedItem": {
// //           "id": "f715ebb5-a694-4544-bb0f-9d4fb1adfecc",
// //           "name": "check builder",
// //           "type": "inventory"
// //         },
// //         "showDropdownItems": false,
// //         "isBill": false,
// //         "tax": 0,
// //         "UOM": "",
// //         "batch": "",
// //         "serial": "",
// //         "SIC": "",
// //         "isInclusiveTax": false,
// //         "taxId": null,
// //         "taxTotal": 0,
// //         "taxes": [],
// //         "taxType": "",
// //         "taxPercentage": 0,
// //         "subTotal": 0,
// //         "typeOfCost": ""
// //       }
// //     ],
// //     "isBill": false,
// //     "deliveryCharge": 0,
// //     "itemSubTotal": 0,
// //     "purchaseTaxTotal": 0,
// //     "subTotal": 0,
// //     "employeeName": "",
// //     "branchName": "Zayed town",
// //     "isInclusiveTax": false,
// //     "supplierVatNumber": "",
// //     "status": "",
// //     "billingId": "",
// //     "billingNumber": ""
// //   };

// //   Future<void> _submitOrder() async {
// //     try {
// //       bool success = await savePurchaseOrder(_purchaseOrderData);
// //       if (success) {
// //         // Order saved successfully
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Purchase order saved successfully!')),
// //         );
// //       }
// //     } catch (e) {
// //       // Handle the error
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error saving order: $e')),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Purchase Order')),
// //       body: Center(
// //         child: ElevatedButton(
// //           onPressed: _submitOrder,
// //           child: Text('Save Purchase Order'),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:inventory_app/Utlits.dart';
// import 'package:inventory_app/Widgetss/BottomNavigationBar2.dart';
// import 'package:inventory_app/Widgetss/customappbar.dart';
// import 'package:inventory_app/Widgetss/table.dart';
// import 'package:inventory_app/pagess/PurchaseOrder.dart';
// import 'package:inventory_app/pagess/createlist.dart';
// import 'package:inventory_app/serviecs/login.services.dart';
// import 'package:inventory_app/serviecs/product.services.dart';
// import 'package:inventory_app/serviecs/varHttp.dart';
// import 'package:invo_models/invo_models.dart';

// import 'package:invo_models/models/Product.dart';
// import 'package:inventory_app/dataa/orderdata.dart';

// class NewPurchaseOrder extends StatefulWidget {
//   const NewPurchaseOrder({Key? key}) : super(key: key);

//   @override
//   _NewPurchaseOrderState createState() => _NewPurchaseOrderState();
// }

// class _NewPurchaseOrderState extends State<NewPurchaseOrder> {
//   String? _selectedSupplier;
//   String? _selectedSuppliername;
//   String? _selectedTaxType;
//   String? _selectedTaxTypename;
//   TextEditingController _barcodeController = TextEditingController();
//   TextEditingController _dateController = TextEditingController();
//   DateTime? _selectedDate;
//   List<Product> enteredOrders = []; // List to store Order objects
//   Map<String, int> quantities = {};
//   Future<void> fetchProduct(String barcode) async {
//     String branchId =
//         Utilts.branchid; // Assuming you have a method to get the branch ID

//     // Fetch the product by barcode
//     Product? fetchedProduct =
//         await getBranchProductByBarcode(branchId, searchTerm: barcode);

//     setState(() {
//       if (fetchedProduct != null) {
//         // Add product info to the list
//         enteredOrders.add(Product(
//           barcode: fetchedProduct
//               .barcode, // Assuming barcode is part of the Product model
//           name: fetchedProduct.name,
//           unitCost: fetchedProduct.price,

//           id: fetchedProduct.id,
//           type: '',
//           quickOptions: [],
//           optionGroups: [],
//           package: [],
//           selection: [],
//           batches: [],
//           serials: [],
//           priceByQty: [],
//           barcodes: [],
//           employeePrices: [],
//           customFields: [],
//           alternativeProducts: [],
//           excludedOptions: [],
//           // Default quantity, modify as needed
//         ));
//       } else {
//         // Show a message if the product is not found
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Product not found')),
//         );
//       }
//     });
//   }
// double tableHeight = 200;
//   List<Supplier> _suppliers = []; // Store all suppliers
//   List<Tax> _tax = [];
//   @override
//   void initState() {
//     super.initState();
//     _fetchSuppliers();
//     _fetchTax();
//   }
//     void _handleSubmit() {
//     String barcode = _barcodeController.text.trim();
//     if (barcode.isNotEmpty) {
//       bool isBarcode = true /*Barcoder().validate(barcode)*/;
//       if (isBarcode) {
//         fetchProduct(barcode);
//         _barcodeController.clear();
//       } else {
//         _barcodeController.clear();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid barcode format')),
//         );
//       }
//     }
//   }


//   Future<void> _fetchSuppliers() async {
//     try {
//       List<Supplier> suppliers = await getSupplierMiniList();
//       setState(() {
//         _suppliers = suppliers;
//       });
//     } catch (e) {
//       print('Error fetching suppliers: $e');
//     }
//   }

//   Future<void> _fetchTax() async {
//     try {
//       List<Tax> tax = await getTaxesList();
//       setState(() {
//         _tax = tax;
//       });
//     } catch (e) {
//       print('Error fetching tax: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _barcodeController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }

//   void _showDatePicker() async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         _selectedDate = pickedDate;
//         _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//       });
//     }
//   }

//   Future<void> _savePurchaseOrder() async {
//     if (_selectedSupplier != null &&
//         _selectedTaxType != null &&
//         enteredOrders.isNotEmpty &&
//         _selectedDate != null) {
//       // Fetch the purchase accounts
//       List<String> accountIds = await getPurchaseAccounts();

//       // Ensure there's at least one account ID to use
//       String defaultAccountId = accountIds.isNotEmpty ? accountIds[0] : '';
//       Map<String, dynamic> purchaseOrderData = {
//         "id": "",
//         "branchId": Utilts.branchid,
//         "purchaseNumber": "",
//         "reference": "",
//         "employeeId": "",
//         "supplierId": _selectedSupplier,
//         "taxType": _selectedTaxType,
//         "total": 0,
//         "supplierName": _selectedSuppliername,
//         "dueDate": _selectedDate?.toIso8601String(),
//         "createdAt": DateTime.now().toIso8601String(),
//         "purchaseDate": DateTime.now().toIso8601String(),
//         "lines": enteredOrders.map((order) {
//         int qty = quantities[order.id] ?? 0; // Get quantity for each order
//         return {
//             "id": "72430d97-82ab-48a8-ba42-1686aafc9f78",
//             "purchaseOrderId": "",
//             "productId": order.id,
//             "note": "",
//             "barcode": order.barcode,
//             "qty": qty,
//             "unitCost": order.unitCost,
//             "total": order.unitCost * 2,
//             "accountId": defaultAccountId != null
//                 ? defaultAccountId
//                 : null, // use the accountId
//             "accountName": "Inventory Assets",
//             "isNew": false,
//             "selectedItem": {
//               "id": "f715ebb5-a694-4544-bb0f-9d4fb1adfecc",
//               "name": "check builder",
//               "type": "inventory"
//             },
//           };
//         }).toList(),
//       };

//       try {
//         bool success = await savePurchaseOrder(purchaseOrderData);
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Purchase order saved successfully!')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving order: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill in all fields')),
//       );
//     }
//   }

// // Your service remains the same

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Purchase Order'),
//       bottomNavigationBar: BottomNavigationBar2(
//         onPressed1: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const PurchaseOrders()),
//           );
//         },
//         onPressed2: _savePurchaseOrder,
//         Label1: 'Cancel',
//         Label2: 'Save',
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           child: Column(
//             children: [
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                 decoration: BoxDecoration(
//                   border:
//                       Border.all(color: const Color.fromRGBO(215, 215, 215, 1)),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 width: double.maxFinite,
//                 height: 57,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: DropdownMenu<String>(
//                     width: 370,
//                     label: Text("Supplier"),
//                     enableFilter: true,
//                     requestFocusOnTap: true,
//                     inputDecorationTheme: const InputDecorationTheme(
//                       filled: false,
//                       contentPadding: EdgeInsets.symmetric(vertical: 5.0),
//                       border: InputBorder.none,
//                     ),
//                     onSelected: (String? newValue) {
//                       setState(() {
//                         _selectedSupplier = newValue;
//                         _selectedSuppliername = _suppliers
//                             .firstWhere(
//                               (supplier) => supplier.id == newValue,
//                             )
//                             .name;
//                       });
//                     },
//                     dropdownMenuEntries: _suppliers.map((Supplier supplier) {
//                       return DropdownMenuEntry<String>(
//                         value: supplier.id,
//                         label: supplier.name,
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16), // Tax Type Dropdown
//               // DropdownButton<String>(
//               //   value: _selectedTaxType,
//               //   hint: const Text("Select Tax Type"),
//               //   items: _tax.map((Tax tax) {
//               //     return DropdownMenuItem<String>(
//               //       value: tax.id,
//               //       child: Text(tax.name),
//               //     );
//               //   }).toList(),
//               //   onChanged: (String? newValue) {
//               //     setState(() {
//               //       _selectedTaxType = newValue;
//               //       _selectedTaxTypename = _tax
//               //           .firstWhere(
//               //             (tax) => tax.id == newValue,
//               //           )
//               //           .name;
//               //     });
//               //   },
//               // ),
//                Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                 decoration: BoxDecoration(
//                   border:
//                       Border.all(color: const Color.fromRGBO(215, 215, 215, 1)),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 width: double.maxFinite,
//                 height: 57,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: DropdownMenu<String>(
//                     width: 370,
//                     label: Text("Tax Type"),
//                     enableFilter: true,
//                     requestFocusOnTap: true,
//                     inputDecorationTheme: const InputDecorationTheme(
//                       filled: false,
//                       contentPadding: EdgeInsets.symmetric(vertical: 5.0),
//                       border: InputBorder.none,
//                     ),
//                     onSelected: (String? newValue) {
//                       setState(() {
//                         _selectedTaxType = newValue;
//                         _selectedTaxTypename = _tax
//                             .firstWhere(
//                               (tax) => tax.id == newValue,
//                             )
//                             .name;
//                       });
//                     },
//                     dropdownMenuEntries: _tax.map((Tax tax) {
//                       return DropdownMenuEntry<String>(
//                         value: tax.id,
//                         label: tax.name,
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Date Input
//   Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: TextField(
//                   controller: _dateController,
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
//                     hintText: 'issue date',
//                     enabledBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(color: Color(0xFFEBEBF3), width: 2.0),
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                     ),
//                     focusedBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(color: Color(0xFF59c0d2), width: 2.0),
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                     ),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.calendar_today),
//                       onPressed: _showDatePicker,
//                     ),
//                   ),
//                   onTap: _showDatePicker,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Barcode Input
//               // TextField(
//               //   controller: _barcodeController,
//               //   decoration: InputDecoration(
//               //     hintText: "Enter barcode",
//               //     suffixIcon: IconButton(
//               //       icon: const Icon(Icons.add),
//               //       onPressed: () {
//               //         // Handle barcode submission
//               //         String barcode = _barcodeController.text.trim();
//               //         if (barcode.isNotEmpty) {
//               //           // Fetch product and add to enteredOrders
//               //           fetchProduct(barcode);
//               //           _barcodeController.clear();
//               //         }
//               //       },
//               //     ),
//               //   ),
//               // ),
//               const Padding(
//                 padding: EdgeInsets.only(left: 17.0 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text("Items", style: TextStyle(fontSize: 19)),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(17.0),
//                 child: TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
//                     hintText: "Enter barcode",
//                     enabledBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(color: Color(0xFFEBEBF3), width: 1.0),
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                     ),
//                     focusedBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(color: Color(0xFF59c0d2), width: 1.0),
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                     ),
//                     suffixIcon: Container(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size(58, 57),
//                           backgroundColor: const Color(0xFF59c0d2),
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.zero,
//                               topRight: Radius.circular(10),
//                               bottomRight: Radius.circular(10),
//                               bottomLeft: Radius.zero,
//                             ),
//                           ),
//                         ),
//                         child: const Text(
//                           "Add",
//                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
//                         ),
//                         onPressed: () {
//                           _handleSubmit();
//                           setState(() {
                           
//                             tableHeight += 50; 
//                           });
                        
//               //         // Handle barcode submission
//                       String barcode = _barcodeController.text.trim();
//                       if (barcode.isNotEmpty) {
//                         // Fetch product and add to enteredOrders
//                         fetchProduct(barcode);
//                         _barcodeController.clear();
//                       }
                    
//                         },
//                       ),
//                     ),
//                   ),
//                   controller: _barcodeController,
//                 ),
//               ),
    
//               const SizedBox(height: 16),
//          Container(
              
//                 height: tableHeight, 
//                 child: DataTable3(orders: enteredOrders, quantities: quantities,),
//               ),

//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
