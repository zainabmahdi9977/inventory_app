import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/BottomNavigationBar2.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountFormBloc.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountListBloc.dart';

import 'package:inventory_app/modelss/PhysicalCount/PhysicalCountLine.dart';
import 'package:inventory_app/modelss/ProductBatch.dart';
import 'package:inventory_app/pagess/PhysicalCount/PhysicalCountList.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';
import 'package:invo_models/invo_models.dart';
import 'package:invo_models/models/Product.dart';

import 'package:easy_localization/easy_localization.dart';

class PhysicalCountFormpage extends StatefulWidget {
  final PhysicalCountFormBloc bloc;
  const PhysicalCountFormpage({super.key, required this.bloc});

  @override
  _PhysicalCountFormpageState createState() => _PhysicalCountFormpageState();
}

class _PhysicalCountFormpageState extends State<PhysicalCountFormpage> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final SearchableDropdownController<String>? _searchcontroller =
      SearchableDropdownController<String>();
  DateTime? _selectedDate;
  bool search = false;
  bool isCalculatePressed = false;
  bool isCalculate = false;
  bool isComitPressed = true;
  bool Commit = false;
     
  DateTime? lastSnackBarTime;
  // String calculatedlabel = "Calculate";
  int count = 0;
  bool calculat = false;
  double tableHeight = 300;
  @override
  void initState() {
    super.initState();
    widget.bloc.physicalCount.branchId = Utilts.branchid;
    tableHeight = 400;
    //Utilts.CalculatedValue = 0.0;
    //Utilts.actualValue = 0.0;
    widget.bloc.calculateActualValue();
    //Utilts.difference=Utilts.actualValue-Utilts.CalculatedValue;

    if (widget.bloc.physicalCount.status == "Calculated") {
      calculat = true;
      widget.bloc.calculatedlabel = "Re-Calculate";
    }
    //
    isComitPressed == true;
    _referenceController =
        TextEditingController(text: widget.bloc.physicalCount.reference);
    _noteController =
        TextEditingController(text: widget.bloc.physicalCount.note);
  }

  Map<String, int> quantities = {};

  late TextEditingController _referenceController = TextEditingController();
  late TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _referenceController.dispose();
    _noteController.dispose();
    _barcodeController.dispose();
    _dateController.dispose();
    widget.bloc.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration:
            const Duration(seconds: 2), // Duration for the snackbar to appear
        behavior: SnackBarBehavior.floating, // Optional: Make it floating
      ),
    );
  }

  void _validateAndSave(BuildContext context) {
    if (widget.bloc.physicalCount.lines.isEmpty) {
      _showErrorDialog("Please add at least one item.".tr());
      return;
    }
  }

  Future<void> _showQuantityDialog(Product? fetchedProduct) async {
    final TextEditingController qtyController = TextEditingController();
    double quantity = 0;
    List<TextEditingController> batchQtyControllers = [];
    List<PhysicalCountLine?>? selectedSerials = [];
    // Fetch batches asynchronously
    List<PhysicalCountLine?>? batches =
        await widget.bloc.fetchPatch(Utilts.branchid, fetchedProduct!.id);
    List<PhysicalCountLine?>? serial =
        await widget.bloc.fetchSerial(Utilts.branchid, fetchedProduct!.id);

    // Clear the controllers
    batchQtyControllers.clear();
    qtyController.text = quantity.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
               EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          title: Text("Enter Quantity".tr(), textAlign: TextAlign.center),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign:Localizations.localeOf(context).toString() =="ar" ?  TextAlign.right:TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Product Name: '.tr(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: fetchedProduct?.name ?? 'Unknown Product',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              if (fetchedProduct.type == 'batch')
                Container(
                  width: 300,
                  child: _buildBatchTable(batches, batchQtyControllers),
                )
              else if (fetchedProduct.type == 'serialized')
                Container(
                  width: 300,
                  child: _buildSerialList(serial /*, selectedSerials*/),
                )
              else
                _buildQuantityInput(qtyController, (newQuantity) {
                  quantity =
                      newQuantity; // Update the quantity based on user input
                }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel".tr()),
            ),
            TextButton(
              onPressed: () {
                List<double> batchQuantities =
                    batchQtyControllers.map((controller) {
                  return double.tryParse(controller.text) ?? 0;
                }).toList();
                if (fetchedProduct.type == 'batch') {
                  quantity = batchQuantities.reduce((a, b) => a + b);
                }
                if (fetchedProduct.type == "serialized") {
                  quantity = serial!
                      .where((serial) => serial!.isAvailable == true)
                      .length
                      .toDouble();
                }

                widget.bloc.fetchProduct(context, fetchedProduct.barcode,
                    quantity, batches!, batchQuantities, serial!);
                Navigator.of(context).pop();
              },
              child: Text("OK".tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSerialList(List<PhysicalCountLine?>? serials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: serials?.map((serial) {
            return StreamBuilder<Object>(
                stream: widget.bloc.onTableUpdate.stream,
                builder: (context, snapshot) {
                  return CheckboxListTile(
                    title: Text(serial?.serial ?? 'Unknown Serial'),
                    value: serial?.isAvailable ?? false,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (serial != null) {
                          widget.bloc.onTableUpdate.sink(true);
                          serial.isAvailable = checked ?? false;
                        }
                      });

                      if (serial?.isAvailable == true) {
                        serial?.enteredQty = 1;
                      } else {
                        serial?.enteredQty = 0;
                      }
                    },
                  );
                });
          }).toList() ??
          [],
    );
  }

  Widget _buildBatchTable(List<PhysicalCountLine?>? batches,
      List<TextEditingController> batchQtyControllers) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SingleChildScrollView(
          child: DataTable(
                dataTextStyle:  TextStyle(fontSize: 20),
        headingTextStyle:TextStyle(fontSize: 20), 
            columnSpacing: 20,
            columns: [
              DataColumn(
                  label: Text('Batch'.tr(), textAlign: TextAlign.center)),
              DataColumn(
                  label: Text('On Hand'.tr(), textAlign: TextAlign.center)),
              DataColumn(
                  label: Container(
                      width: 180,
                      child:
                          Text('Quantity'.tr(), textAlign: TextAlign.center))),
            ],
            rows: batches?.map((batch) {
                  final controller = TextEditingController();
                  // Initialize the controller with the entered quantity or '0'
                  controller.text = (batch?.enteredQty ?? 0).toString();
                  batchQtyControllers
                      .add(controller); // Add to the list for later retrieval
                  double currentValue = double.tryParse(controller.text) ?? 0;
                  return DataRow(cells: [
                    DataCell(Center(
                        child: Text(batch?.batch ?? '',
                            textAlign: TextAlign.center))),
                    DataCell(Center(
                        child: Text(batch!.onHand.toString() ?? '0',
                            textAlign:
                                TextAlign.center))), // Display on-hand quantity
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 35),
                              onPressed: () {
                                if (currentValue > 1) {
                                  currentValue--;
                                  batch.enteredQty = currentValue;
                                  controller.text = (currentValue)
                                      .toString(); // Update the text field
                                }
                              },
                            ),
                            Expanded(
                              child: TextField(
                                
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: controller,
                                style: TextStyle(fontSize: 20),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    currentValue = 0;
                                  } else if (value.isNotEmpty ||
                                      int.tryParse(value) == null) {
                                    double? newQty = double.tryParse(value);
                                    controller.text = value;
                                    currentValue = newQty!;
                                  }
                                  batch.enteredQty = currentValue;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 35),
                              onPressed: () {
                                currentValue++;
                                batch.enteredQty = currentValue;
                                controller.text = (currentValue)
                                    .toString(); // Update the text field
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]);
                }).toList() ??
                [],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityInput(
      TextEditingController qtyController, Function(double) onQuantityChanged) {
    double quantity = 0; // Local quantity variable

    return Center(
      child: Container(
        width: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (quantity > 0) {
                  quantity--;
                  qtyController.text = quantity.toString();
                  onQuantityChanged(
                      quantity); // Call the callback with the new quantity
                }
              },
            ),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: qtyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (value) {
                  quantity =
                      double.tryParse(value) ?? 0; // Update local quantity
                  onQuantityChanged(
                      quantity); // Call the callback with the new quantity
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                quantity++;
                qtyController.text = quantity.toString();
                onQuantityChanged(
                    quantity); // Call the callback with the new quantity
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuantityDialog2(PhysicalCountLine? fetchedProduct) async {
    List<PhysicalCountLine?>? selectedSerials = [];
    final TextEditingController qtyController = TextEditingController();
    double quantity = 0; // Initialize quantity
    List<TextEditingController> batchQtyControllers = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          title: Text(
            "Enter Quantity".tr(),
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Wraps content
            children: [
              RichText(
                textAlign: Localizations.localeOf(context).toString() =="ar" ?  TextAlign.right:TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Product Name: '.tr(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: fetchedProduct!.productName ?? 'Unknown Product',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              if (fetchedProduct!.productType == 'batch')
                Container(
                    width: 300,
                    child: _buildBatchTable(
                        fetchedProduct!.batches, batchQtyControllers))
              else if (fetchedProduct!.productType == 'serialized')
                Container(
                  width: 300,
                  child: _buildSerialList(fetchedProduct!.serials),
                )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel".tr()),
            ),
            TextButton(
              onPressed: () {
                for (int i = 0; i < fetchedProduct!.batches.length; i++) {
                  final currentQty =
                      double.tryParse(batchQtyControllers[i].text) ?? 0;
                  fetchedProduct!.batches[i].enteredQty = currentQty;
                }
                widget.bloc.onUpdateQty(fetchedProduct);
                if (fetchedProduct.productType == 'batch') {
                  fetchedProduct.enteredQty = 0;
                  for (var element in fetchedProduct!.batches) {
                    fetchedProduct.enteredQty += element.enteredQty;
                  }
                }
                if (fetchedProduct.productType == "serialized") {
                  fetchedProduct.enteredQty = fetchedProduct!.serials
                      .where((serial) => serial!.isAvailable == true)
                      .length
                      .toDouble();
                }
                Navigator.of(context).pop();
              },
              child: Text("OK".tr()),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error".tr()),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK".tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: Utilts.updateLanguage.stream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Physical Count'.tr()),
            // bottomNavigationBar: StreamBuilder<Object>(
            //     stream: widget.bloc.onTableUpdate.stream,
            //     builder: (context, snapshot) {
            //       return bottomNavigationBar(

            //         onPressed: () async {
            //           Commit = await widget.bloc.savePhysicalCountAction(
            //               context, _referenceController, _noteController, calculat);
            //           !calculat ? _validateAndSave(context) : null;
            //         },

            //         label: 'Save',

            //       );
            //     }),

            bottomNavigationBar: BottomNavigationBar2(
              onPressed1: () {
                NavigationService(context)
                    .goToPhysicalCountList(PhysicalCountListBloc());
              },
              onPressed2: () async {
                Commit = await widget.bloc.savePhysicalCountAction(
                    context, _referenceController, _noteController, calculat);
                !calculat ? _validateAndSave(context) : null;
              },
              Label1: 'Cancel'.tr(),
              Label2: 'Save'.tr(),
            ),

            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      //  padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: StreamBuilder<Object>(
                          stream: widget.bloc.onTableUpdate.stream,
                          builder: (context, snapshot) {
                            return Column(
                              children: [
                                //                     Text(
                                //               widget.bloc.msg,
                                //               style: TextStyle(
                                // fontSize: 16,
                                // color: widget.bloc.msg.startsWith('Failed')
                                //     ? Colors.red
                                //     : Colors.green,
                                //               ),),

                                Container(
                                  margin: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromRGBO(
                                            215, 215, 215, 1)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: double.maxFinite,
                                  height: 57,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: TextField(
                                      controller: _referenceController,
                                      decoration: InputDecoration(
                                        labelText: 'Reference No'.tr(),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromRGBO(
                                            215, 215, 215, 1)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: double.maxFinite,
                                  height: 57,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: TextField(
                                      controller: _noteController,
                                      decoration: InputDecoration(
                                        labelText: 'Note'.tr(),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                if (widget.bloc.calculatedlabel == "Calculate")
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 17.0,
                                        top: 16,
                                        right: Localizations.localeOf(context)
                                                    .toString() ==
                                                "ar"
                                            ? 17
                                            : 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text("Items".tr(),
                                            style: TextStyle(fontSize: 19)),
                                      ],
                                    ),
                                  ),
                                if (widget.bloc.calculatedlabel == "Calculate")
                                  StreamBuilder<bool>(
                                      stream: widget.bloc.search.stream,
                                      builder: (context, snapshot) {
                                        bool isSearchActive =
                                            snapshot.data ?? false;

                                        return Row(
                                          children: [
                                            !isSearchActive
                                                ? Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: TextField(
                                                        autofocus: true,
                                                        decoration:
                                                            InputDecoration(
                                                          hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[400],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          hintText:
                                                              "Enter barcode"
                                                                  .tr(),
                                                          enabledBorder:
                                                              const OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0xFFEBEBF3),
                                                                width: 1.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0xFF59c0d2),
                                                                width: 1.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          suffixIcon:
                                                              ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              minimumSize:
                                                                  const Size(
                                                                      58, 57),
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xFF59c0d2),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: Localizations.localeOf(context)
                                                                              .toString() ==
                                                                          "en"
                                                                      ? Radius
                                                                          .zero
                                                                      : Radius
                                                                          .circular(
                                                                              10),
                                                                  topRight: Localizations.localeOf(context)
                                                                              .toString() ==
                                                                          "en"
                                                                      ? Radius
                                                                          .circular(
                                                                              10)
                                                                      : Radius
                                                                          .zero,
                                                                  bottomRight: Localizations.localeOf(context)
                                                                              .toString() ==
                                                                          "en"
                                                                      ? Radius
                                                                          .circular(
                                                                              10)
                                                                      : Radius
                                                                          .zero,
                                                                  bottomLeft: Localizations.localeOf(context)
                                                                              .toString() ==
                                                                          "en"
                                                                      ? Radius
                                                                          .zero
                                                                      : Radius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "Add".tr(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              String barcode =
                                                                  _barcodeController
                                                                      .text
                                                                      .trim();
                                                              if (barcode
                                                                  .isNotEmpty) {
                                                                Product?
                                                                    fetchedProduct =
                                                                    await ProductService().getBranchProductByBarcode(
                                                                        Utilts
                                                                            .branchid,
                                                                        searchTerm:
                                                                            barcode);

                                                                if (fetchedProduct !=
                                                                    null) {
                                                                  bool barcodeExists = widget
                                                                      .bloc
                                                                      .physicalCount
                                                                      .lines
                                                                      .any((line) =>
                                                                          line.productId ==
                                                                          fetchedProduct
                                                                              .id);
                                                                  if (barcodeExists) {
                                                                    _showSnackBar(
                                                                        'product already added'
                                                                            .tr());
                                                                  } else {
                                                                    _showQuantityDialog(
                                                                        fetchedProduct);
                                                                  }
                                                                  _barcodeController
                                                                      .clear();
                                                                } else {
                                                                  _showSnackBar(
                                                                      'Product not found'
                                                                          .tr());
                                                                }
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        controller:
                                                            _barcodeController,
onChanged: (String value) async {
if (value.length >=12) {
   String barcode =_barcodeController .text .trim();
 if (barcode.isNotEmpty) {
Product?fetchedProduct = await ProductService().
getBranchProductByBarcode( Utilts .branchid, searchTerm:barcode);

  if (fetchedProduct !=null) {
 bool barcodeExists = widget .bloc .physicalCount.lines.any((line) 
 => line.productId ==  fetchedProduct.id);
        if (barcodeExists) {
        
          if (lastSnackBarTime == null || DateTime.now().difference(lastSnackBarTime!).inSeconds >= 3.5) {
            _showSnackBar('product already added'.tr());
            lastSnackBarTime = DateTime.now(); 
          }
        } else {
          _showQuantityDialog(fetchedProduct);
        }
        
      } else {
       
        if (lastSnackBarTime == null || DateTime.now().difference(lastSnackBarTime!).inSeconds >= 3.5) {
          _showSnackBar('Product not found'.tr());
          lastSnackBarTime = DateTime.now(); 
        }
      }
 }   _barcodeController.clear();
                                                          }
                                                          // if (value.length >= 12) {

                                                          //   widget.bloc.fetchProduct(context, value.trim());
                                                          //   _barcodeController.clear();
                                                          // }
                                                        },
                                                     
                                                      ),
                                                    ),
                                                  )
                                                : Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: const Color(
                                                                  0xFFEBEBF3),
                                                              width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        width: double.maxFinite,
                                                        height: 57,
                                                        child: SearchableDropdown<
                                                            String>.paginated(
                                                              rightpadding:23,
                                                          isDialogExpanded:
                                                              false,
                                                          dialogOffset: 0,
                                                          hintText: Text(
                                                              'Search'.tr()),
                                                          controller:
                                                              _searchcontroller,
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          paginatedRequest: (int
                                                                  page,
                                                              String?
                                                                  searchKey) async {
                                                            final paginatedList = await widget
                                                                .bloc
                                                                .loadProducts(
                                                                    page: page,
                                                                    searchTerm:
                                                                        searchKey ??
                                                                            "");
                                                            return paginatedList
                                                                .map((e) => SearchableDropdownMenuItem(
                                                                    value: e
                                                                        .barcode,
                                                                    label:
                                                                        e.name ??
                                                                            '',
                                                                    child: Text(
                                                                        e.name ??
                                                                            '')))
                                                                .toList();
                                                          },
                                                          requestItemCount: 15,
                                                          onChanged: (String?
                                                              value) async {
                                                            if (value!
                                                                .isNotEmpty) {
                                                              widget.bloc
                                                                  .onTableUpdate
                                                                  .sink(true);
                                                              Product?
                                                                  fetchedProduct =
                                                                  await ProductService().getBranchProductByBarcode(
                                                                      Utilts
                                                                          .branchid,
                                                                      searchTerm:
                                                                          value);
                                                              bool barcodeExists = widget
                                                                  .bloc
                                                                  .physicalCount
                                                                  .lines
                                                                  .any((line) =>
                                                                      line.productId ==
                                                                      fetchedProduct!
                                                                          .id);
                                                              if (barcodeExists) {
                                                                _showSnackBar(
                                                                    'product already added'
                                                                        .tr());
                                                              } else {
                                                                _showQuantityDialog(
                                                                    fetchedProduct);
                                                              }
                                                              _barcodeController
                                                                  .clear();
                                                              _searchcontroller
                                                                  ?.clear();
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: Localizations.localeOf(
                                                                  context)
                                                              .toString() ==
                                                          "en"
                                                      ? 16.0
                                                      : 0,
                                                  left: Localizations.localeOf(
                                                                  context)
                                                              .toString() ==
                                                          "en"
                                                      ? 0
                                                      : 16),
                                              child: IconButton(
                                                onPressed: () {
                                                  widget.bloc
                                                      .searchbutton(context);
                                                },
                                                icon: isSearchActive
                                                    ? Container(
                                                        width: 25,
                                                        height: 25,
                                                        child: SvgPicture.asset(
                                                            'assets/Images/barcode-solid.svg',
                                                            fit: BoxFit.contain,
                                                            color: const Color(
                                                                0xFF59c0d2))) // Path to your SVG asset
                                                    : const Icon(
                                                        size: 25,
                                                        Icons.search,
                                                        color:
                                                            Color(0xFF59c0d2),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),

                                const SizedBox(height: 16),
                                StreamBuilder(
                                    stream: widget.bloc.physicalCount
                                        .onTableUpdate.stream,
                                    builder: (context, snapshot) {
                                      double screenWidth =
                                          MediaQuery.of(context).size.width;
                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: screenWidth,
                                              // height: tableHeight,
                                              child: dataTable(widget
                                                  .bloc.physicalCount.lines),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                Container(
                                  width: double.maxFinite,
                                  height: 20,
                                  color: Colors.transparent,
                                ),
                                StreamBuilder(
                                  stream: widget
                                      .bloc.physicalCount.onTableUpdate.stream,
                                  builder: (context, snapshot) {
                                    return Column(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Container(
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.grey[300]!,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Calculated Value: "
                                                                .tr(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(widget
                                                              .bloc
                                                              .physicalCount
                                                              .calculatedValue
                                                              .toStringAsFixed(
                                                                  2)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  dataTable(List<PhysicalCountLine> lines) {
    //   final Map<String, int> quantities;
    count = lines.length;

    print(lines.length.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Card(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: DataTable(
            dataRowHeight: 120,
            showBottomBorder: true,
            // headingTextStyle:  TextStyle(fontSize:!calculat ? 16:20),
            // dataTextStyle:  TextStyle(fontSize:!calculat ? 16:20),
            headingTextStyle: const TextStyle(fontSize: 16),
            dataTextStyle: const TextStyle(fontSize: 16),
            columnSpacing: 90,
            columns: [
              DataColumn(label: SizedBox(width: 100, child: Text("Name".tr()))),
              DataColumn(
                  label: SizedBox(
                      width: 100,
                      child: Text("Entered Qty".tr(),
                          textAlign: TextAlign.center))),
              DataColumn(
                  label: SizedBox(width: 65, child: Text("Delete".tr()))),
            ],
            rows: List<DataRow>.generate(lines.length, (index) {
              final line = lines[index];
              // int qty = widget.bloc.quantities[order.id] ?? 0;
              double total = line.enteredQty * line.unitCost;
              double allenteredQty = 0;
              if (line.productType == "batch")
                for (var batch in line.batches) {
                  allenteredQty += batch.enteredQty;
                }
              if (line.productType == "serialized")
                for (var serial in line.serials) {
                  allenteredQty += serial.enteredQty;
                }
              final productId = line.productId;
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: FutureBuilder(
                          future: widget.bloc.fetchProductById(productId),
                          builder: (context, snapshot) {
                            return Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${snapshot.data?.name ?? ""} \n${snapshot.data?.UOM} \n${line.categoryName ?? 'Unknown Category'}",
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0.0, horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff45BBCF),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                            snapshot.data?.barcode ?? "",
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                  DataCell(
                    FutureBuilder(
                        future: widget.bloc.fetchProductById(productId),
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  snapshot.data?.type != "batch" &&
                                          snapshot.data?.type != "serialized"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            //   if (calculat == false)
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                widget.bloc.onDecreaseQty(line);
                                              },
                                            ),
                                            Text(line.enteredQty.toString()),
                                            // if (calculat == false)
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                widget.bloc.onIncreaseQty(line);
                                              },
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            SizedBox(
                                              height: 50,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF59c0d2),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                ),
                                                child: Text(
                                                  "Select".tr(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  _showQuantityDialog2(line);
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0.0,
                                                      horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              child: Text(
                                                  line.enteredQty.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        )
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: calculat ? 8 : 20.0),
                        child: IconButton(
                          icon: const Icon(Icons.cancel_outlined,
                              color: Colors.red),
                          onPressed: () {
                            widget.bloc.removeLine(line);
                          },
                        ),
                      ),
                    ],
                  )),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
