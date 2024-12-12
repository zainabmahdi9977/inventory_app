import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/BottomNavigationBar2.dart';
import 'package:inventory_app/Widgetss/SnackBar.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutFormBloc.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutListBloc.dart';
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransferLine.dart';
import 'package:inventory_app/modelss/branch.models.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';
import 'package:invo_models/invo_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:invo_models/models/Product.dart';

//TransferOutFormpage  TransferOutFormBloc
class TransferOutFormpage extends StatefulWidget {
  final TransferOutFormBloc bloc;
  const TransferOutFormpage({super.key, required this.bloc});

  @override
  _TransferOutFormpageState createState() => _TransferOutFormpageState();
}

class _TransferOutFormpageState extends State<TransferOutFormpage> {
  final TextEditingController _barcodeController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final SearchableDropdownController<String>? _searchcontroller =
      SearchableDropdownController<String>();
  bool search = false;
  int count = 0;
  bool success = false;
  double tableHeight = 300;
  String reason = "";
  DateTime? lastSnackBarTime;

  @override
  void initState() {
    super.initState();
    // reasonController = TextEditingController(
    //   text: widget.bloc.inventoryTransfer.reason.isNotEmpty
    //       ? widget.bloc.inventoryTransfer.reason.tr()
    //       : Reason.first, // Initial value
    // );
    if (widget.bloc.inventoryTransfer.reason == "To Another Branch") {
      isToAnotherBranch = true;
    }
    widget.bloc.inventoryTransfer.branchId = Utilts.branchid;
    tableHeight = 380;
//Utilts.total=0.0;
    _referenceController =
        TextEditingController(text: widget.bloc.inventoryTransfer.reference);
    _noteController =
        TextEditingController(text: widget.bloc.inventoryTransfer.note);
  }

  List<String> Reason = [
    "Standard",
    "Return to supplier",
    "To Another Branch",
    "Wastage",
    "Expired",
    "Damaged",
    "Operational usage"
  ];

// Map of translations for display
  Map<String, String> reasonTranslations = {
    "Standard": "قياسي",
    "Return to supplier": "العودة إلى المورد",
    "To Another Branch": "إلى فرع آخر",
    "Wastage": "هدر",
    "Expired": "منتهي الصلاحية",
    "Damaged": "تالف",
    "Operational usage": "استخدام تشغيلي"
  };
  Map<String, int> quantities = {};
  bool isToAnotherBranch = false;
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _referenceController.dispose();
    _noteController.dispose();
    _barcodeController.dispose();
    _dateController.dispose();
    widget.bloc.dispose();
    super.dispose();
  }

  Future<void> _validateAndSave(BuildContext context) async {
    if (widget.bloc.inventoryTransfer.lines.isEmpty) {
      await _showErrorDialog("Please add at least one item.".tr());
      return;
    }

    for (var line in widget.bloc.inventoryTransfer.lines) {
      if ( line.onhand <= 0)
      {await _showErrorDialog(
          "${"Sorry,  there are no available items for "
                                    .tr()}${line.product?.name}.",
          line);
             return;}if (line.qty > line.onhand) {
        await _showErrorDialog(
            "${"Quantity for".tr()} ${line.product?.name} ${"must be less than or equal to On Hand.".tr()}",
            line);
        return;
      }
      if (line.qty <= 0 ) {
        await _showErrorDialog(
            "${"Quantity must be greater than 0 for ".tr()}${line.product?.name}.",
            line);
        return;
      } 
    }

    
  }



  Future<void> _showQuantityDialog(Product? fetchedProduct) async {
    final TextEditingController qtyController = TextEditingController();
    double quantity = 0;
    List<TextEditingController> batchQtyControllers = [];
    List<InventoryTransferLine?>? selectedSerials = [];

    List<InventoryTransferLine?>? batches =
        await widget.bloc.fetchPatch(Utilts.branchid, fetchedProduct!.id);
    List<InventoryTransferLine?>? serial =
        await widget.bloc.fetchSerial(Utilts.branchid, fetchedProduct!.id);

    batchQtyControllers.clear();
    qtyController.text = quantity.toString();
    bool allBatchesOnHandZero =
        batches?.every((batch) => (batch?.onHand ?? 0) == 0) ?? true;

    bool showError = (fetchedProduct.type == 'batch' &&
            (allBatchesOnHandZero || batches?.isEmpty == true)) ||
        (fetchedProduct.type == 'serialized' && (serial?.isEmpty == true));
    bool inventoryerror = (fetchedProduct.type != 'serialized' &&
        fetchedProduct.type != 'batch' &&
        fetchedProduct.onHand <= 0);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          title: Text("Enter Quantity".tr(), textAlign: TextAlign.center),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: Localizations.localeOf(context).toString() == "ar"
                    ? TextAlign.right
                    : TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Product Name: '.tr(),
                      style: const TextStyle(
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
              const SizedBox(height: 10),
              if (fetchedProduct.type != "batch" &&
                  fetchedProduct.type != "serialized")
                RichText(
                  textAlign: Localizations.localeOf(context).toString() == "ar"
                      ? TextAlign.right
                      : TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Product onHand: '.tr(),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      TextSpan(
                        text: fetchedProduct.onHand.toString(),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              if (showError)
                Container(
                  padding: const EdgeInsetsDirectional.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Sorry, you cannot proceed because there are no available items for this product.'
                                      .tr(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else if (fetchedProduct.type == 'batch')
                Container(
                  width: 300,
                  child: _buildBatchTable(batches, batchQtyControllers),
                )
              else if (fetchedProduct.type == 'serialized')
                Container(
                  width: 300,
                  child: _buildSerialList(serial),
                )
              else
                _buildQuantityInput(qtyController, (newQuantity) {
                  quantity =
                      newQuantity; // Update the quantity based on user input
                }, fetchedProduct.onHand),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel".tr()),
            ),
            if (!showError && !inventoryerror)
              TextButton(
                onPressed: () {
                  List<double> batchQuantities =
                      batchQtyControllers.map((controller) {
                    return double.tryParse(controller.text) ?? 0;
                  }).toList();

                  if (fetchedProduct.type == 'batch') {
                    quantity = batchQuantities.reduce((a, b) => a + b);
                  } else if (fetchedProduct.type == 'serialized') {
                    quantity =
                        serial!.where((s) => s!.isSelected).length.toDouble();
                  }
                  if(quantity==0)
                   quantity = 1;
                  
                  widget.bloc.fetchProduct(
                    context,
                    fetchedProduct.barcode,
                    quantity,
                    batches,
                    batchQuantities,
                    serial!,
                  );
                  Navigator.of(context).pop();
                },
                child: Text("OK".tr()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSerialList(List<InventoryTransferLine?>? serials,
      [List<InventoryTransferLine>? serialss]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: serials?.map((serial) {
            return StreamBuilder<Object>(
              stream: widget.bloc.onTableUpdate.stream,
              builder: (context, snapshot) {
                return CheckboxListTile(
                  title: Text(serial?.serial ?? 'Unknown Serial'),
                  value: serial?.isSelected ?? false,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (serial != null) {
                        serial.isSelected = checked ?? false;

                        serial.qty = serial.isSelected ? 1 : 0;

                        InventoryTransferLine? matchingSerial =
                            serialss?.firstWhere(
                          (s) => s?.serial == serial.serial,
                          orElse: () => InventoryTransferLine(),
                        );

                        if (matchingSerial != null &&
                            matchingSerial.serial == serial.serial) {
                          matchingSerial.isSelected = serial.isSelected;
                        } else if (serial.isSelected) {
                          serialss?.add(serial);
                        }

                        widget.bloc.onTableUpdate.sink(true);
                      }
                    });
                  },
                );
              },
            );
          }).toList() ??
          [],
    );
  }

  Future<void> _showQuantityDialog2(
      InventoryTransferLine? fetchedProduct) async {
    final TextEditingController qtyController = TextEditingController();
    double quantity = 0; // Initialize quantity
    qtyController.text = quantity.toString();
    List<TextEditingController> batchQtyControllers = [];
    List<InventoryTransferLine?>? batches = await widget.bloc
        .fetchPatch(Utilts.branchid, fetchedProduct!.productId);
    List<InventoryTransferLine?>? serial = await widget.bloc
        .fetchSerial(Utilts.branchid, fetchedProduct!.productId);
    bool allBatchesOnHandZero =
        batches?.every((batch) => (batch?.onHand ?? 0) == 0) ?? true;
    bool showError = (fetchedProduct?.type == 'batch' &&
            (allBatchesOnHandZero || batches?.isEmpty == true)) ||
        (fetchedProduct?.type == 'serialized' && (serial?.isEmpty == true));
    for (var serial in serial!) {
      for (var serialss in fetchedProduct.serials) {
        if (serial?.serial == serialss.serial && serialss.isSelected) {
          serial?.isSelected = true;
        }
      }
    }
    for (var batches in batches!) {
      for (var batchess in fetchedProduct.batches) {
        if (batches?.batch == batchess.batch && batchess.isSelected) {
          batches?.isSelected = true;
          batches?.qty = batchess.qty;
        }
      }
    }
    // fetchedProduct.serials = List<InventoryTransferLine>.from(serial!);
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
                textAlign: Localizations.localeOf(context).toString() == "ar"
                    ? TextAlign.right
                    : TextAlign.left,
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
              if (showError)
                Container(
                  padding: const EdgeInsetsDirectional.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Sorry, you cannot proceed because there are no available items for this product.'
                                      .tr(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else if (fetchedProduct!.type == 'batch')
                Container(
                    width: 300,
                    child: _buildBatchTable(
                        batches, batchQtyControllers, fetchedProduct!.batches))
              else if (fetchedProduct!.type == 'serialized')
                Container(
                  width: 300,
                  child: _buildSerialList(serial, fetchedProduct.serials),
                )
              else
                _buildQuantityInput(qtyController, (newQuantity) {
                  quantity =
                      newQuantity; // Update the quantity based on user input
                }, fetchedProduct.onHand),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel".tr()),
            ),
            if (showError == false)
              TextButton(
                onPressed: () {
                  for (int i = 0; i < fetchedProduct!.batches.length; i++) {
                    final currentQty =
                        double.tryParse(batchQtyControllers[i].text) ?? 0;
                    fetchedProduct!.batches[i].qty = currentQty;
                  }
                  widget.bloc.onUpdateQty(fetchedProduct);
                  if (fetchedProduct.type == 'batch') {
                    fetchedProduct.qty = 0;
                    for (var element in fetchedProduct!.batches) {
                      if (element.isSelected) fetchedProduct.qty += element.qty;
                    }
                  } else if (fetchedProduct.type == "serialized") {
                    fetchedProduct.qty = fetchedProduct!.serials
                        .where((serial) => serial!.isSelected == true)
                        .length
                        .toDouble();
                  } else
                  if(quantity==0)
                   fetchedProduct.qty = 1;
                   else
                    fetchedProduct.qty = quantity;

                  Navigator.of(context).pop();
                },
                child: Text("OK".tr()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBatchTable(List<InventoryTransferLine?>? batches,
      List<TextEditingController> batchQtyControllers,
      [List<InventoryTransferLine>? batchess]) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SingleChildScrollView(
          child: DataTable(
            dataTextStyle: TextStyle(fontSize: 20),
            headingTextStyle: TextStyle(fontSize: 20),
            columnSpacing: 20,
            columns: [
              DataColumn(
                  label: Text('Select'.tr(),
                      textAlign: TextAlign.center)), // New column for checkbox
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
                  if (batch!.qty > batch.onHand) batch?.qty = batch.onHand;
                  controller.text =
                      (batch?.qty == 0 ? 1 : batch?.qty).toString();
                  batchQtyControllers.add(controller);
                  double currentValue = double.tryParse(controller.text) ?? 1;

                  return DataRow(cells: [
                    DataCell(
                      StreamBuilder<Object>(
                          stream: widget.bloc.onTableUpdate.stream,
                          builder: (context, snapshot) {
                            return Center(
                              child: Checkbox(
                                value: batch?.isSelected ?? false,
                                onChanged: (bool? value) {
                                  if (batch != null) {
                                    if (batch.onHand == 0)
                                      batch.isSelected = false;
                                    else
                                      batch.isSelected = value ?? false;

                                    //batch.qty = batch.isSelected ? 1 : 0;

                                    InventoryTransferLine? matchingSerial =
                                        batchess?.firstWhere(
                                      (s) => s?.batch == batch.batch,
                                      orElse: () => InventoryTransferLine(),
                                    );

                                    if (matchingSerial != null &&
                                        matchingSerial.batch == batch.batch) {
                                      matchingSerial.isSelected =
                                          batch.isSelected;
                                    } else if (batch.isSelected) {
                                      batchess?.add(batch);
                                    }

                                    widget.bloc.onTableUpdate.sink(true);
                                  }
                                },
                              ),
                            );
                          }),
                    ),
                    DataCell(
                        Text(batch?.batch ?? '', textAlign: TextAlign.center)),
                    DataCell(Center(
                        child: Text(batch?.onHand.toString() ?? '0',
                            textAlign: TextAlign.center))),
                    DataCell(
                      batch!.onHand > 0
                          ? SizedBox(
                              width: 180,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      size: 35,
                                    ),
                                    onPressed: () {
                                      // Decrement quantity
                                      if (currentValue > 1) {
                                        currentValue--;
                                        controller.text = currentValue
                                            .toString(); // Update the text field
                                      } else {
                                        _showSnackBar2(
                                            context,
                                            "Cannot decrease quantity below 1."
                                                .tr());
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: TextField(
                                        style: TextStyle(fontSize: 20),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          if (value.isEmpty) {
                                            currentValue = 1;
                                          } else {
                                            double? newQty =
                                                double.tryParse(value);
                                            if (newQty != null &&
                                                newQty >= 0 &&
                                                newQty <= batch!.onHand) {
                                              controller.text = value;
                                              currentValue = newQty;
                                            } else if (newQty != null &&
                                                newQty > batch!.onHand) {
                                              controller.text =
                                                  batch!.onHand.toString();
                                              currentValue = batch!.onHand;
                                            } else {
                                              controller.text =
                                                  currentValue.toString();
                                              controller.selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                offset: controller.text.length,
                                              ));
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      size: 35,
                                    ),
                                    onPressed: () {
                                      if (batch!.onHand >= currentValue + 1) {
                                        currentValue++;
                                        controller.text =
                                            currentValue.toString();
                                      } else {
                                        _showSnackBar2(context,
                                            "You have reached the maximum quantity available in stock.");
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                                onPressed: () {},
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

  Widget _buildQuantityInput(TextEditingController qtyController,
      Function(double) onQuantityChanged, double onhand) {
    double quantity = 1; // Initialize quantity to 1
    qtyController.text =
        quantity.toString(); // Set initial value of the controller
    if (onhand > 0) {
      return Center(
        child: SizedBox(
          width: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    quantity--;
                    qtyController.text = quantity.toString();
                    onQuantityChanged(
                        quantity); // Call the callback with the new quantity
                  } else {
                    _showSnackBar2(
                        context, "Cannot decrease quantity below 1.".tr());
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
                    if (value.isEmpty) {
                      quantity = 0;
                    } else {
                      double? newQty = double.tryParse(value);
                      if (newQty != null && newQty >= 0 && newQty <= onhand) {
                        qtyController.text = value;
                        quantity = newQty;
                        onQuantityChanged(quantity);
                      } else if (newQty != null && newQty > onhand) {
                        qtyController.text = onhand.toString();
                        quantity = onhand;
                        onQuantityChanged(quantity);
                      } else {
                        qtyController.text = quantity.toString();
                        onQuantityChanged(quantity);
                        qtyController.selection =
                            TextSelection.fromPosition(TextPosition(
                          offset: qtyController.text.length,
                        ));
                      }
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (onhand >= quantity + 1) {
                    quantity++;
                    onQuantityChanged(quantity);
                    qtyController.text = quantity.toString();
                  } else {
                    _showSnackBar2(
                        context,
                        "You have reached the maximum quantity available in stock."
                            .tr());
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
          padding: const EdgeInsetsDirectional.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                color: Colors.red,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Sorry, you cannot add this product because the onHand is '
                              .tr(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    TextSpan(
                      text: onhand.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ));
    }
  }

  void _showSnackBar2(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height *
            0.4, // Adjust position as needed
        left: MediaQuery.of(context).size.width * 0.2,
        right: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

Future<void> _showErrorDialog(String message, [InventoryTransferLine? line]) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          actionsPadding: EdgeInsets.symmetric(horizontal:1,vertical:10),
        title: Text("Error".tr()),
        content: Text(message),
        actions: [
              
          Row( 
                crossAxisAlignment: CrossAxisAlignment.start,
children: [
  if (line == null) 
    TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("OK".tr()),
    ),
  if (line != null) ...[
    TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("OK".tr()),
    ),
    if (line.onhand > 0)
      TextButton(
        onPressed: () {
          _showQuantityDialog2(line);
          Navigator.of(context).pop();
        },
        child: Text("Edit Qty".tr()),
      ),
    TextButton(
      onPressed: () {
        widget.bloc.removeLine(line);
        Navigator.of(context).pop();
      },
      child: Text("Delete the product".tr()),
    ),
  ]
],
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
            appBar: CustomAppBar(title: 'Transfer Out'.tr()),
            bottomNavigationBar: BottomNavigationBar2(
              onPressed1: () {
                NavigationService(context)
                    .goToTransferOutList(TransferOutListBloc());
              },
              onPressed2: () async {
                if (widget.bloc.inventoryTransfer.reason.isEmpty) {
                  widget.bloc.inventoryTransfer.reason = Reason.first;
                }

                success = await widget.bloc.OpenInventoryTransfer(
                    context, _referenceController, _noteController);
                !success ? _validateAndSave(context) : null;
              },
              Label1: 'Cancel'.tr(),
              Label2: 'Save'.tr(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                    
                      child: StreamBuilder<Object>(
                          stream: widget.bloc.onTableUpdate.stream,
                          builder: (context, snapshot) {
                            return Column(
                              children: [
    

                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 16.0, right: 16, left: 16),
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
                                        border: InputBorder
                                            .none, // Removes the underline
                                      ),
                                    ),
                                  ),
                                ),

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
                                      controller: _noteController,
                                      decoration: InputDecoration(
                                        labelText: 'Note'.tr(),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 0),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color.fromRGBO(
                                                    215, 215, 215, 1)),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          height: 57,
                                          child: DropdownMenu<String>(
                                            width:
                                                isToAnotherBranch ? 150 : 315,
                                            label: Text("Transfer Reason".tr()),
                                            enableFilter: false,
                                            requestFocusOnTap: true,
                                            enableSearch: true,
                                            controller: TextEditingController(
                                              text: widget
                                                      .bloc
                                                      .inventoryTransfer
                                                      .reason
                                                      .isNotEmpty
                                                  ? widget.bloc
                                                      .inventoryTransfer.reason
                                                      .tr()
                                                  : Reason.first
                                                      .tr(), 
                                            ),
                                            
                                            inputDecorationTheme:
                                                const InputDecorationTheme(
                                              filled: false,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              border: InputBorder.none,
                                            ),
                                            onSelected: (String? newValue) {
                                              FocusScope.of(context).unfocus();
                                              setState(() {
                                                widget.bloc.inventoryTransfer
                                                    .reason = newValue ?? "";
                                                isToAnotherBranch = newValue ==
                                                    "To Another Branch";
                                              });
                                            },
                                            dropdownMenuEntries:
                                                Reason.map((reason) {
                                              return DropdownMenuEntry<String>(
                                                value: reason,
                                                label: reason.tr(),
                                              );
                                            }).toList(),
                                            menuHeight: 250,
                                          ),
                                        ),
                                      ),
                                      if (isToAnotherBranch)
                                        const SizedBox(width: 10),
                                      if (isToAnotherBranch)
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      215, 215, 215, 1)),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            height: 57,
                                            child: StreamBuilder<List<Branch>>(
                                              stream:
                                                  widget.bloc.branches.stream,
                                              builder: (context, snapshot) {
                                                // if (snapshot.connectionState == ConnectionState.waiting) {
                                                //   return const Center(child: CircularProgressIndicator());
                                                // }

                                                List<Branch> branches =
                                                    widget.bloc.branches.value;
                                                String? initialBranchId = branches
                                                        .isNotEmpty
                                                    ? widget
                                                            .bloc
                                                            .inventoryTransfer
                                                            .destinationBranch ??
                                                        branches[0].id
                                                    : null;

                                                return DropdownMenu<String>(
                                                  width: 150,
                                                  label: Text(
                                                      "Select Branch".tr()),
                                                  enableFilter: false,
                                                  requestFocusOnTap: true,
                                                  enableSearch: true,
                                                  initialSelection:
                                                      initialBranchId,
                                                  inputDecorationTheme:
                                                      const InputDecorationTheme(
                                                    filled: false,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.0),
                                                    border: InputBorder.none,
                                                  ),
                                                  onSelected:
                                                      (String? newValue) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    setState(() {
                                                      initialBranchId =
                                                          newValue;
                                                      widget.bloc
                                                              .selectedbranch =
                                                          newValue!;
                                                      widget
                                                              .bloc
                                                              .inventoryTransfer
                                                              .destinationBranch =
                                                          newValue;
                                                    });
                                                  },
                                                  dropdownMenuEntries: branches
                                                      .map((Branch branch) {
                                                    return DropdownMenuEntry<
                                                        String>(
                                                      value: branch.id,
                                                      label: branch.name.tr(),
                                                    );
                                                  }).toList(),
                                                  menuHeight: 250,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 17.0,
                                    top: 16,
                                    right: Localizations.localeOf(context)
                                                .toString() ==
                                            "ar"
                                        ? 17
                                        : 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Items".tr(),
                                          style: TextStyle(fontSize: 19)),
                                    ],
                                  ),
                                ),
                                StreamBuilder<bool>(
                                    stream: widget.bloc.search.stream,
                                    builder: (context, snapshot) {
                                      bool isSearchActive =
                                          snapshot.data ?? false;

                                      return Row(
                                        children: [
                                          //Text(widget.bloc.inventoryTransfer.destinationBranch!),
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
                                                          color:
                                                              Colors.grey[400],
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
                                                              BorderRadius.all(
                                                                  Radius
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
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        suffixIcon:
                                                            ElevatedButton(
                                                          style: ElevatedButton
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
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          onPressed: () async {
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
                                                                    .inventoryTransfer
                                                                    .lines
                                                                    .any((line) =>
                                                                        line.barcode ==
                                                                        fetchedProduct!
                                                                            .barcode);
                                                                if (barcodeExists) {
                                                                  SnackBarUtil.showSnackBar(context,
                                                                      'product already added'
                                                                          .tr());
                                                                } else {
                                                                  _showQuantityDialog(
                                                                      fetchedProduct);
                                                                }
                                                                _barcodeController
                                                                    .clear();
                                                              } else {
                                                             SnackBarUtil.showSnackBar(context,
                                                                    'Product not found'
                                                                        .tr());
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      controller:
                                                          _barcodeController,
                                                      onChanged:
                                                          (String value) async {
                                                        if (value.length >=
                                                            12) {
                                                          String barcode =
                                                              _barcodeController
                                                                  .text
                                                                  .trim();
                                                          if (barcode
                                                              .isNotEmpty) {
                                                            Product?
                                                                fetchedProduct =
                                                                await ProductService()
                                                                    .getBranchProductByBarcode(
                                                                        Utilts
                                                                            .branchid,
                                                                        searchTerm:
                                                                            barcode);

                                                            if (fetchedProduct != null) {
                                                              bool barcodeExists = widget
                                                                  .bloc
                                                                  .inventoryTransfer
                                                                  .lines
                                                                  .any((line) =>
                                                                      line.productId ==
                                                                      fetchedProduct!
                                                                          .id);
                  if (barcodeExists) {
          
         
           SnackBarUtil.showSnackBar(context,'product already added'.tr());
            lastSnackBarTime = DateTime.now();
         
        } else {
          _showQuantityDialog(fetchedProduct);
        }
        
      } else {
        
        
         SnackBarUtil.showSnackBar(context,'Product not found'.tr());
          lastSnackBarTime = DateTime.now(); 
       
      }
    }_barcodeController
                                                                  .clear();
                                                        }
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
                                                      decoration: BoxDecoration(
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
                                                        rightpadding: 23,
                                                        isDialogExpanded: false,
                                                        dialogOffset: 0,
                                                        hintText:
                                                            Text('Search'.tr()),
                                                        margin: const EdgeInsets
                                                            .all(15),
                                                        paginatedRequest: (int
                                                                page,
                                                            String?
                                                                searchKey) async {
                                                          final paginatedList =
                                                              await widget.bloc
                                                                  .loadProducts(
                                                                      page:
                                                                          page,
                                                                      searchTerm:
                                                                          searchKey ??
                                                                              "");
                                                          return paginatedList
                                                              .map((e) => SearchableDropdownMenuItem(
                                                                  value:
                                                                      e.barcode,
                                                                  label:
                                                                      e.name ??
                                                                          '',
                                                                  child: Text(
                                                                      e.name ??
                                                                          '')))
                                                              .toList();
                                                        },
                                                        requestItemCount: 15,
                                                        controller:
                                                            _searchcontroller,
                                                        onChanged: (String?
                                                            value) async {
                                                          if (value!
                                                              .isNotEmpty) {
                                                            widget.bloc
                                                                .onTableUpdate
                                                                .sink(true);
                                                            Product?
                                                                fetchedProduct =
                                                                await ProductService()
                                                                    .getBranchProductByBarcode(
                                                                        Utilts
                                                                            .branchid,
                                                                        searchTerm:
                                                                            value);
                                                            bool barcodeExists = widget
                                                                .bloc
                                                                .inventoryTransfer
                                                                .lines
                                                                .any((line) =>
                                                                    line.productId ==
                                                                    fetchedProduct!
                                                                        .id);
                                                            if (barcodeExists) {
                                                             SnackBarUtil.showSnackBar(context,
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
                                                              0xFF59c0d2)))
                                                  : const Icon(
                                                      size: 25,
                                                      Icons.search,
                                                      color: Color(0xFF59c0d2),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),

                                const SizedBox(height: 16),

                                StreamBuilder(
                                    stream: widget.bloc.inventoryTransfer
                                        .onTableUpdate.stream,
                                    builder: (context, snapshot) {
                                      return Container(
                                        width: 500,
                                        child: dataTable(widget
                                            .bloc.inventoryTransfer.lines),
                                      );
                                    }),

                                Container(
                                  height: 20,
                                  color: Colors.transparent,
                                ),
                                StreamBuilder(
                                  stream: widget.bloc.inventoryTransfer
                                      .onTableUpdate.stream,
                                  builder: (context, snapshot) {
                                    //    double total = widget.bloc.inventoryTransfer.calculateTotal();
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Total: ".tr(),
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                            // "${PhysicalCount().CalculatedValue.toStringAsFixed(2)}"),
                                                            "${widget.bloc.inventoryTransfer.calculateTotal().toStringAsFixed(2)}"),
                                                      ],
                                                    ),
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

  dataTable(List<InventoryTransferLine> lines) {
    //   final Map<String, int> quantities2;
    count = lines.length;
    print(lines.length.toString());
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DataTable(
          headingTextStyle: TextStyle(fontSize: count == 0 ? 15 : 18),
          showBottomBorder: true,
          dataTextStyle: const TextStyle(fontSize: 18),
          dataRowHeight: 150,
          columnSpacing: 10,
          columns: [
            DataColumn(label: SizedBox(width: 95, child: Text("Name".tr()))),
            DataColumn(
                label: SizedBox(
                    width: 65, child: Center(child: Text("On \nHand".tr())))),
            DataColumn(
                label: SizedBox(
                    width: 110,
                    child: Center(
                        child: Text(
                      "Qty".tr(),
                      textAlign: TextAlign.center,
                    )))),
            DataColumn(
                label: SizedBox(
                    width: 50, child: Center(child: Text("Unit \nCost".tr())))),
            DataColumn(
                label: SizedBox(
                    width: 60, child: Center(child: Text("Total".tr())))),
            DataColumn(
                label: SizedBox(
                    width: 50, child: Center(child: Text("Delete".tr())))),
          ],
          rows: List<DataRow>.generate(lines.length, (index) {
            final line = lines[index];
            if (line.type != "batch" &&
                line.type != "serialized") if (line.onHand < line.qty) {
              if (line.onHand > 0) {
                line.qty = line.onHand.floorToDouble();
              } else {
                line.qty = 0;
              }
            }
            // int qty = widget.quantities[order.id] ?? 0;
            // double total = qty * order.unitCost;
            final productId = line.productId;
            return DataRow(
              cells: [
                DataCell(
                  FutureBuilder<Product?>(
                      future: widget.bloc.fetchProductById(productId!),
                      builder: (context, snapshot) {
                        return SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //  mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      snapshot.data?.name ??
                                          'Product not found',
                                      maxLines: 2,
                                      textAlign: Localizations.localeOf(context)
                                                  .toString() ==
                                              "ar"
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                    // Text(
                                    //   //line.product!.barcode,
                                    // ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff45BBCF),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Text(snapshot.data?.barcode ?? "",
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                DataCell(Center(child: Text(line.onhand.toString()))),
                DataCell(line.type != "batch" && line.type != "serialized"
                    ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            line.qty > 1
                                ? IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      widget.bloc.onDecreaseQty(line);
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.cancel_outlined,
                                        color: Colors.red),
                                    onPressed: () {
                                      widget.bloc.removeLine(line);
                                    },
                                  ),
                            Text(line.qty.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (line.qty >= line.onHand.floorToDouble()) {
                                  _showSnackBar2(
                                      context,
                                      "You have reached the maximum quantity available in stock."
                                          .tr());
                                } else {
                                  widget.bloc.onIncreaseQty(line);
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF59c0d2),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                              ),
                              child: Text(
                                "Select".tr(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                _showQuantityDialog2(line);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(line.qty.toString(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      )),
                DataCell(Center(child: Text(line.unitcost.toStringAsFixed(2)))),
                DataCell(Center(
                    child: Text(line.calculateTotal.toStringAsFixed(2)))),
                DataCell(Center(
                    child: IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () {
                    widget.bloc.removeLine(line);
                  },
                ))),
              ],
            );
          }),
        ),
      ),
    );
  }
}
