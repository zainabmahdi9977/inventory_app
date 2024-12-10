import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/BottomNavigationBar2.dart';
import 'package:inventory_app/Widgetss/SnackBar.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/bloc/creatlist/CreateListBloc.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountFormBloc.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountListBloc.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderBloc.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderFormBloc.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutFormBloc.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutListBloc.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:inventory_app/modelss/creatlist/CreateListMod.dart';
import 'package:inventory_app/modelss/creatlist/CreateListlineMod.dart';
import 'package:inventory_app/pagess/CreateList/CreateList.dart';
import 'package:inventory_app/pagess/homepage.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';
import 'package:invo_models/models/Product.dart';
import 'package:invo_models/models/Supplier.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../vendor/searchable_paginated_dropdown/lib/src/searchable_dropdown.dart';
import '../../vendor/searchable_paginated_dropdown/lib/src/searchable_dropdown_controller.dart';

class CreateList extends StatefulWidget {
  final CreateListBloc bloc;
  final CreateListMod? selectedOrder; // Accept selected order

  const CreateList({super.key, required this.bloc, this.selectedOrder});

  @override
  _CreateListState createState() => _CreateListState();
}

class _CreateListState extends State<CreateList> {
  final TextEditingController _barcodeController = TextEditingController();
  late TextEditingController _nameController;
  final SearchableDropdownController<String> _searchcontroller =
      SearchableDropdownController<String>();

  DateTime? lastSnackBarTime;

  bool search = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.selectedOrder?.name ?? '',
    );
    widget.bloc.initializeNewOrder();
  }

  void dispose() {
    widget.bloc.dispose();
    _searchcontroller.dispose();
    _barcodeController.dispose();
    _nameController.dispose();
    widget.bloc.dispose();
    super.dispose();
  }

  // bool isSnackBarVisible = false;
  // void _showSnackBar(String message) {
  //   if (isSnackBarVisible) return;
  //   isSnackBarVisible = true;
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       duration: const Duration(seconds: 2),
  //       behavior: SnackBarBehavior.floating,
  //       onVisible: () {
  //         Future.delayed(const Duration(seconds: 2), () {
  //           isSnackBarVisible = false;
  //         });
  //       },
  //     ),
  //   );
  // }

  Future<void> _showQuantityDialog(Product? fetchedProduct) async {
    final TextEditingController qtyController = TextEditingController();
    int quantity = 0;
    List<TextEditingController> batchQtyControllers = [];
    // List<CreateListlineMod?>? selectedSerials = [];
    // Fetch batches asynchronously
    List<CreateListlineMod?>? batches =
        await widget.bloc.fetchPatch(Utilts.branchid, fetchedProduct!.id);
    List<CreateListlineMod?>? serial =
        await widget.bloc.fetchSerial(Utilts.branchid, fetchedProduct.id);

    // Clear the controllers
    batchQtyControllers.clear();
    qtyController.text = quantity.toString();

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
                List<int> batchQuantities =
                    batchQtyControllers.map((controller) {
                  return int.tryParse(controller.text) ?? 0;
                }).toList();
                if (fetchedProduct.type == 'batch') {
                  quantity = batchQuantities.reduce((a, b) => a + b);
                }
                if (fetchedProduct.type == "serialized") {
                  quantity = serial!
                      .where((serial) => serial!.isAvailable == true)
                      .length
                      .toInt();
                }

                widget.bloc.fetchProduct(context, fetchedProduct.barcode,
                    quantity, batches, batchQuantities, serial!);
                Navigator.of(context).pop();
              },
              child: Text("OK".tr()),
            ),
          ],
        );
      },
    );
    //   qtyController.dispose();
    // for (var controller in batchQtyControllers) {
    //   controller.dispose();
    // }
  }

  Widget _buildSerialList(List<CreateListlineMod?>? serials) {
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
                        serial?.qty = 1;
                      } else {
                        serial?.qty = 0;
                      }
                    },
                  );
                });
          }).toList() ??
          [],
    );
  }

  Widget _buildBatchTable(List<CreateListlineMod?>? batches,
      List<TextEditingController> batchQtyControllers) {
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
                  controller.text = (batch?.qty ?? 0).toString();
                  batchQtyControllers
                      .add(controller); // Add to the list for later retrieval
                  int currentValue = int.tryParse(controller.text) ?? 0;
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
                              icon: const Icon(
                                Icons.remove,
                                size: 35,
                              ),
                              onPressed: () {
                                if (currentValue > 1) {
                                  currentValue--;
                                  batch!.qty = currentValue;
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
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    currentValue = 0;
                                  } else if (value.isNotEmpty ||
                                      int.tryParse(value) == null) {
                                    int? newQty = int.tryParse(value);
                                    controller.text = value;
                                    currentValue = newQty!;
                                  }
                                  batch!.qty = currentValue;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 35),
                              onPressed: () {
                                currentValue++;
                                batch!.qty = currentValue;
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
      TextEditingController qtyController, Function(int) onQuantityChanged) {
    int quantity = 0; // Local quantity variable

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
                  quantity = int.tryParse(value) ?? 0; // Update local quantity
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

  Future<void> _showQuantityDialog2(CreateListlineMod? fetchedProduct) async {
    List<CreateListlineMod?>? selectedSerials = [];
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
                      text: fetchedProduct!.name ?? 'Unknown Product',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              if (fetchedProduct.productType == 'batch')
                Container(
                    width: 300,
                    child: _buildBatchTable(
                        fetchedProduct.batches, batchQtyControllers))
              else if (fetchedProduct.productType == 'serialized')
                Container(
                  width: 300,
                  child: _buildSerialList(fetchedProduct.serials),
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
                for (int i = 0; i < fetchedProduct.batches!.length; i++) {
                  final currentQty =
                      int.tryParse(batchQtyControllers[i].text) ?? 0;
                  fetchedProduct.batches![i]!.qty = currentQty;
                }
                widget.bloc.onUpdateQty(fetchedProduct);
                if (fetchedProduct.productType == 'batch') {
                  fetchedProduct.qty = 0;
                  // Check if batches is not null and not empty
                  if (fetchedProduct.batches != null &&
                      fetchedProduct.batches!.isNotEmpty) {
                    // Iterate over batches and sum the quantities
                    for (var element in fetchedProduct.batches!) {
                      fetchedProduct.qty +=
                          element!.qty; // Ensure that element is a numeric type
                    }
                  }
                }

                if (fetchedProduct.productType == "serialized") {
                  // Check if serials is not null
                  if (fetchedProduct.serials != null) {
                    fetchedProduct.qty = fetchedProduct.serials!
                        .where((serial) => serial!.isAvailable == true)
                        .length;
                  } else {
                    fetchedProduct.qty = 0; // If serials is null, set qty to 0
                  }
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

  static showSupplierDialog(
      BuildContext context, CreateListBloc bloc, List<String> allBarcodes) {
    String? errorMessage; // To hold the error message
    ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
    SearchableDropdownController<String>? _searchcontrollerforsupplier =
        SearchableDropdownController<String>();
    _searchcontrollerforsupplier = null;
    bloc.fetchSuppliers(1, "");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("Select Supplier".tr())),
          content: Container(
            width: double.maxFinite,
            height: 120,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(215, 215, 215, 1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.maxFinite,
                  height: 57,
                  child: SearchableDropdown<String>.paginated(
                    isDialogExpanded: false,
                    dialogOffset: 0,
                    controller: _searchcontrollerforsupplier,
                    hintText: Text('Search'.tr()),
                    margin: const EdgeInsets.all(15),
                    paginatedRequest: (int page, String? searchKey) async {
                      final paginatedList = await bloc.fetchSuppliers(
                        page,
                        searchKey = "",
                      );

                      return paginatedList
                          .map((e) => SearchableDropdownMenuItem(
                              value: e.id,
                              label: e.name ?? '',
                              child: Text(e.name ?? '')))
                          .toList();
                    },
                    requestItemCount: 15,
                    onChanged: (String? newValue) async {
                      FocusScope.of(context).unfocus();
                      bloc.selectedsupplier = newValue ?? "";
                      errorNotifier.value = null;
                    },
                  ),
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: errorNotifier,
                  builder: (context, error, child) {
                    if (error != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return SizedBox
                          .shrink(); // Return an empty box if no error
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Close".tr()),
            ),
            TextButton(
              onPressed: () {
                if (bloc.selectedsupplier.isNotEmpty) {
                  Navigator.of(context).pop(); // Close the dialog first
                  NavigationService(context).goToPurchaseOrder(
                    PurchaseOrderFormBloc.newPO(
                        allBarcodes, bloc.selectedsupplier),
                  );
                } else {
                  // Set error message if no supplier is selected
                  errorNotifier.value = "Please select a supplier.".tr();
                }
              },
              child: Text("Ok".tr()),
            ),
          ],
        );
      },
    );
  }

  @override
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

  void _validateAndSave() {
    if (_nameController.text.isEmpty) {
      _showErrorDialog("Name cannot be empty.".tr());
      return;
    }

    if (widget.bloc.enteredOrders2.isEmpty) {
      _showErrorDialog("No items to save. Please add items.".tr());
      return;
    }
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: "Created List successfully!".tr(),
      ),
    );
    widget.bloc.saveOrders(_nameController.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateListViewPage(bloc: CreateListViewBloc()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: Utilts.updateLanguage.stream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Create List'.tr()),
            bottomNavigationBar: BottomNavigationBar2(
              onPressed1: () {
                NavigationService(context)
                    .goToCreateListlistBloc(CreateListViewBloc());
              },
              onPressed2: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: const Color(0xFF59c0d2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'Choose an action'.tr(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 40),
                                        backgroundColor:
                                            const Color(0xFF59c0d2),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      // onPressed: () {
                                      //   widget.bloc.saveOrders(_nameController.text); // Pass the name
                                      //   Navigator.pushReplacement(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => CreateListViewPage(bloc: CreateListViewBloc(),),
                                      //     ),
                                      //   );
                                      // },
                                      onPressed: _validateAndSave,
                                      child: Text(
                                        "Save".tr(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 40),
                                        backgroundColor:
                                            const Color(0xFF59c0d2),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      child: Text(
                                        "Convaret to Purchase Order".tr(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      onPressed: () {
                                        showSupplierDialog(context, widget.bloc,
                                            widget.bloc.getAllBarcodes());

                                        // NavigationService(context).goToPurchaseOrder(
                                        //     PurchaseOrderFormBloc.newPO(
                                        //         widget.bloc.getAllBarcodes()));
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 40),
                                        backgroundColor:
                                            const Color(0xFF59c0d2),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      child: Text(
                                        "Convaret to Physical Count".tr(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      onPressed: () {
                                        if (Utilts.addNewPhysicalCounts) {
                                          NavigationService(context)
                                              .goToPhysicalCountForm(
                                                  PhysicalCountFormBloc.newPc(
                                                      widget.bloc
                                                          .getAllBarcodes2()));
                                        } else {
                                          _showNotAllowedDialog(context);
                                        }
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 40),
                                        backgroundColor:
                                            const Color(0xFF59c0d2),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      child: Text(
                                        "Convaret to Transfer Out".tr(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      onPressed: () {
                                        if (Utilts.addNewInventoryTransfer) {
                                          NavigationService(context)
                                              .goToTransferOutFormpage(
                                                  TransferOutFormBloc.newIT(
                                                      widget.bloc
                                                          .getAllBarcodes2()));
                                        } else {
                                          _showNotAllowedDialog(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              Label1: 'Back'.tr(),
              Label2: 'Next'.tr(),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _nameController.text.isEmpty
                                ? Colors.red
                                : const Color.fromRGBO(215, 215, 215, 1),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.maxFinite,
                        height: 57,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            onChanged: (text) {
                              setState(() {
                                _nameController.text = text;
                              });
                            },
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name'.tr(),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    StreamBuilder<bool>(
                        stream: widget.bloc.search.stream,
                        builder: (context, snapshot) {
                          bool isSearchActive = snapshot.data ?? false;

                          return Row(
                            children: [
                              !isSearchActive
                                  ? Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: TextField(
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                              fontWeight: FontWeight.bold,
                                            ),
                                            hintText: "Enter barcode".tr(),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFEBEBF3),
                                                  width: 1.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFF59c0d2),
                                                  width: 1.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            suffixIcon: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(58, 57),
                                                backgroundColor:
                                                    const Color(0xFF59c0d2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Localizations
                                                                    .localeOf(
                                                                        context)
                                                                .toString() ==
                                                            "en"
                                                        ? Radius.zero
                                                        : Radius.circular(10),
                                                    topRight: Localizations
                                                                    .localeOf(
                                                                        context)
                                                                .toString() ==
                                                            "en"
                                                        ? Radius.circular(10)
                                                        : Radius.zero,
                                                    bottomRight: Localizations
                                                                    .localeOf(
                                                                        context)
                                                                .toString() ==
                                                            "en"
                                                        ? Radius.circular(10)
                                                        : Radius.zero,
                                                    bottomLeft: Localizations
                                                                    .localeOf(
                                                                        context)
                                                                .toString() ==
                                                            "en"
                                                        ? Radius.zero
                                                        : Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                "Add".tr(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              onPressed: () async {
                                                String barcode =
                                                    _barcodeController.text
                                                        .trim();
                                                if (barcode.isNotEmpty) {
                                                  Product? fetchedProduct =
                                                      await ProductService()
                                                          .getBranchProductByBarcode(
                                                              Utilts.branchid,
                                                              searchTerm:
                                                                  barcode);

                                                  if (fetchedProduct != null) {
                                                    bool barcodeExists = widget
                                                        .bloc.enteredOrders2
                                                        .any((line) =>
                                                            line.barcode ==
                                                            fetchedProduct
                                                                .barcode);
                                                    if (barcodeExists) {
                                                      SnackBarUtil.showSnackBar(
                                                          context,'product already added'
                                                              .tr());
                                                    } else {
                                                      _showQuantityDialog(
                                                          fetchedProduct);
                                                    }
                                                    _barcodeController.clear();
                                                  } else {
                                                  SnackBarUtil.showSnackBar(
                                                          context,
                                                        'Product not found'
                                                            .tr());
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          controller: _barcodeController,
                                          onChanged: (String value) async {
                                            if (value.length >= 12) {
                                              String barcode =
                                                  _barcodeController.text
                                                      .trim();
                                              if (barcode.isNotEmpty) {
                                                Product? fetchedProduct =
                                                    await ProductService()
                                                        .getBranchProductByBarcode(
                                                            Utilts.branchid,
                                                            searchTerm:
                                                                barcode);

                                                if (fetchedProduct != null) {
                                                  bool barcodeExists = widget
                                                      .bloc.enteredOrders2
                                                      .any((line) =>
                                                          line.barcode ==
                                                          fetchedProduct
                                                              .barcode);

                                                  if (barcodeExists) {
                                              
                                                     SnackBarUtil.showSnackBar(
                                                          context,
                                                          'product already added'
                                                              .tr());
                                                  
                                                    
                                                  } else {
                                                    _showQuantityDialog(
                                                        fetchedProduct);
                                                  }
                                                } else {
                                               
                                             
                                                  SnackBarUtil.showSnackBar(
                                                          context,
                                                        'Product not found'
                                                            .tr());
                                               
                                                  
                                                }
                                              }
                                              _barcodeController.clear();
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
                                        padding: const EdgeInsets.all(16.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xFFEBEBF3),
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          width: double.maxFinite,
                                          height: 57,
                                          child: SearchableDropdown<
                                              String>.paginated(
                                            rightpadding: 23,
                                            isDialogExpanded: false,
                                            dialogOffset: 0,
                                            hintText: Text('Search'.tr()),
                                            controller: _searchcontroller,
                                            margin: const EdgeInsets.all(15),
                                            paginatedRequest: (int page,
                                                String? searchKey) async {
                                              final paginatedList = await widget
                                                  .bloc
                                                  .loadProducts(
                                                      page: page,
                                                      searchTerm:
                                                          searchKey ?? "");
                                              return paginatedList
                                                  .map((e) =>
                                                      SearchableDropdownMenuItem(
                                                          value: e.barcode,
                                                          label: e.name ?? '',
                                                          child: Text(
                                                              e.name ?? '')))
                                                  .toList();
                                            },
                                            requestItemCount: 15,
                                            onChanged: (String? value) async {
                                              if (value!.isNotEmpty) {
                                                Product? fetchedProduct =
                                                    await ProductService()
                                                        .getBranchProductByBarcode(
                                                            Utilts.branchid,
                                                            searchTerm: value);
                                                bool barcodeExists = widget
                                                    .bloc.enteredOrders2
                                                    .any((line) =>
                                                        line.barcode ==
                                                        fetchedProduct!
                                                            .barcode);
                                                if (barcodeExists) {
                                                SnackBarUtil.showSnackBar(
                                                          context,
                                                      "Product  already added"
                                                          .tr());
                                                } else {
                                                  _showQuantityDialog(
                                                      fetchedProduct);
                                                }
                                                _barcodeController.clear();
                                                _searchcontroller?.clear();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: Localizations.localeOf(context)
                                                .toString() ==
                                            "en"
                                        ? 16.0
                                        : 0,
                                    left: Localizations.localeOf(context)
                                                .toString() ==
                                            "en"
                                        ? 0
                                        : 16),
                                child: IconButton(
                                  onPressed: () {
                                    widget.bloc.searchbutton(context);
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
                                      : Icon(
                                          size: 25,
                                          Icons.search,
                                          color: const Color(0xFF59c0d2),
                                        ),
                                ),
                              ),
                            ],
                          );
                        }),
                    const SizedBox(height: 20),
                    StreamBuilder(
                      stream: widget.bloc.onTableUpdate.stream,
                      builder: (context, snapshot) {
                        return Container(
                          width: 500,
                          child: dataTable(widget.selectedOrder?.lines ??
                              widget.bloc.enteredOrders2),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _showNotAllowedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Access Denied".tr()),
          content: Text("You are not allowed to perform this action.".tr()),
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

  dataTable(List<CreateListlineMod> orders) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DataTable(
            dataRowHeight: 120,
            showBottomBorder: true,
            columnSpacing: 22,
            headingTextStyle: TextStyle(fontSize: orders.isEmpty ? 14 : 16),
            dataTextStyle: const TextStyle(fontSize: 16),
            columns: [
              DataColumn(
                label: SizedBox(
                  width: 120,
                  child: Text("Name".tr(),
                      textAlign:
                          Localizations.localeOf(context).toString() == "en"
                              ? TextAlign.left
                              : TextAlign.right),
                ),
              ),
              DataColumn(
                label: SizedBox(
                    width: 70,
                    child: Center(
                        child: Text("Unit Cost".tr(),
                            textAlign: TextAlign.center))),
              ),
              DataColumn(
                label: SizedBox(
                    width: 100,
                    child: Center(
                        child: Text("Qty".tr(), textAlign: TextAlign.center))),
              ),
              DataColumn(
                label: SizedBox(
                    width: 55, child: Center(child: Text("Delete".tr()))),
              ),
            ],
            rows: List<DataRow>.generate(orders.length, (index) {
              return DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 160,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orders[index].name ?? "",
                                  maxLines: 2,
                                  textAlign: Localizations.localeOf(context)
                                              .toString() ==
                                          "en"
                                      ? TextAlign.left
                                      : TextAlign.right,
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff45BBCF),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(orders[index].barcode ?? "",
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Center(
                      child: Text(
                          orders[index].unitCost.toStringAsFixed(2) ?? ""))),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            orders[index].productType != "batch" &&
                                    orders[index].productType != "serialized"
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          widget.bloc
                                              .onDecreaseQty(orders[index]);
                                        },
                                      ),
                                      Text(orders[index].qty.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          widget.bloc
                                              .onIncreaseQty(orders[index]);
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
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))),
                                          ),
                                          child: Text(
                                            "Select".tr(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            _showQuantityDialog2(orders[index]);
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0.0, horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                            orders[index].qty.toString(),
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                        onPressed: () {
                          widget.bloc.removeOrder(orders[index].barcode);
                        },
                      ),
                    ),
                  ),
                ],
              );
            })),
      ),
    );
  }
}
