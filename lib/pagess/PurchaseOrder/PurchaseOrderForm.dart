import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/BottomNavigationBar2.dart';
import 'package:inventory_app/Widgetss/SnackBar.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderFormBloc.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrder.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrderLine.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/pagess/PurchaseOrder/PurchaseOrderList.dart';

import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderBloc.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';

import 'package:invo_models/invo_models.dart';


import '../../vendor/searchable_paginated_dropdown/lib/src/searchable_dropdown.dart';

class PurchaseOrderForm extends StatefulWidget {
  final PurchaseOrderFormBloc bloc;
  const PurchaseOrderForm({super.key, required this.bloc});

  @override
  _PurchaseOrderFormState createState() => _PurchaseOrderFormState();
}

class _PurchaseOrderFormState extends State<PurchaseOrderForm> {
  bool search = false;
  TextEditingController _barcodeController = TextEditingController();
  final SearchableDropdownController<String> _searchcontroller =
      SearchableDropdownController<String>();
  final SearchableDropdownController<String> _searchcontrollerforsupplier =
      SearchableDropdownController<String>();
  DateTime? selectedDate;
  String selectedsupplier = '';
  Map<String, int> quantities = {};
  bool istextselect = false;
  bool issuppliertselect = false;
  bool isdate = false;
  double tableHeight = 380;
  int count = 0;
  bool success = false;
DateTime? lastSnackBarTime;
  List<PurchaseOrderLine> lines = [];

  @override
  initState() {
    lines = widget.bloc.purchaseOrder.lines;
    tableHeight = 380;
    super.initState();
    quantities = {};
    //   Utilts.total=0.0;
    //  Utilts.taxTotal=0.0;
    //   Utilts.itemSubTotal=0.0;
    String? initialSupplierId = widget.bloc.selectedsupplier ?? "";
    issuppliertselect =
        widget.bloc.purchaseOrder.supplierName.isNotEmpty ?? false;
    istextselect = widget.bloc.purchaseOrder.id.isNotEmpty ?? false;
    if (widget.bloc.selectedsupplier == "") {
      selectedsupplier = widget.bloc.purchaseOrder.supplierId;
    } else
      selectedsupplier = widget.bloc.selectedsupplier!;
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    _barcodeController.dispose();
    _searchcontroller.dispose();
    _searchcontrollerforsupplier.dispose();
    widget.bloc.dispose();
    super.dispose();
  }

  void _validateAndSave(BuildContext context) {
    if (!istextselect || !issuppliertselect || !isdate) {
      _showErrorDialog("Please fill in all fields".tr());
      return;
    } else if (widget.bloc.purchaseOrder.lines.isEmpty) {
      _showErrorDialog("Please add at least one item.".tr());
      return;
    }
  }

  Future<void> _showQuantityDialog(String barcode, String productName) async {
    final TextEditingController qtyController = TextEditingController();
    int quantity = 0; 

    qtyController.text = quantity.toString();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      text: '$productName ',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  width: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 0) {
                            quantity--; // Decrement quantity
                            qtyController.text =
                                quantity.toString(); // Update the text field
                          }
                        },
                      ),
                      Expanded(
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Allow only digits
                          ],
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              quantity = 0; // Reset quantity if cleared
                            } else {
                              // Update quantity based on user input
                              int? newQty = int.tryParse(value);
                              if (newQty != null && newQty >= 0) {
                                quantity = newQty;
                              } else {
                                qtyController.text = quantity.toString();
                                qtyController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: qtyController.text.length));
                              }
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          quantity++;
                          qtyController.text = quantity.toString();
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
                widget.bloc
                    .fetchProduct(context, barcode, quantity, selectedsupplier);
                Navigator.of(context).pop();
              },
              child: Text("OK".tr()),
            ),
          ],
        );
      },
    );
    qtyController.dispose();
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
            appBar: CustomAppBar(title: "Purchase Order".tr()),
            bottomNavigationBar: BottomNavigationBar2(
              onPressed1: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseOrderList(
                      bloc: PurchaseOrderBloc(),
                    ),
                  ),
                );
              },
              onPressed2: () async {
                bool success = await widget.bloc.savePurchaseOrder(context);
                !success ? _validateAndSave(context) : null;
              },
              Label1: 'Cancel'.tr(),
              Label2: 'Save'.tr(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                              color: issuppliertselect ||
                                      widget.bloc.selectedsupplier != ""
                                  ? const Color.fromRGBO(215, 215, 215, 1)
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.maxFinite,
                          height: 57,
                          child: FutureBuilder<String>(
                            future: widget.bloc.selectedsuppliername,
                            builder: (context, snapshot) {
                              // Check for loading state
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child:
                                        CircularProgressIndicator()); // Show loading indicator
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Error: ${snapshot.error}')); // Show error message
                              } else {
                                // If data is available, proceed
                                String displayName = snapshot.data ?? "";

                                return SearchableDropdown<String>.paginated(
                                  hasTrailingClearIcon: false,
                                  isDialogExpanded: true,
                                  dialogOffset: 0,
                                  controller: _searchcontrollerforsupplier,
                                  hintText: Text('Search'.tr()),
                                  initialValue: widget.bloc.purchaseOrder
                                                  .supplierId ==
                                              "" &&
                                          snapshot.data == ""
                                      ? null
                                      : SearchableDropdownMenuItem<String>(
                                          value: widget.bloc.purchaseOrder
                                                      .supplierId !=
                                                  ""
                                              ? widget
                                                  .bloc.purchaseOrder.supplierId
                                              : widget.bloc.selectedsupplier,
                                          label: widget.bloc.purchaseOrder
                                                      .supplierId !=
                                                  ""
                                              ? widget.bloc.purchaseOrder
                                                  .supplierName
                                              : displayName,
                                          child: widget.bloc.purchaseOrder
                                                      .supplierId !=
                                                  ""
                                              ? Text(widget.bloc.purchaseOrder
                                                  .supplierName)
                                              : Text(displayName),
                                        ),
                                  margin: const EdgeInsets.all(15),
                                  paginatedRequest:
                                      (int page, String? searchKey) async {
                                    final paginatedList =
                                        await widget.bloc.fetchSuppliers(
                                      page,
                                      searchKey ??
                                          "", // Ensure searchKey is not null
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

                                    if (newValue == null || newValue.isEmpty) {
                    
                                      issuppliertselect = false;
                                    } else {
                                      widget.bloc.purchaseOrder.supplierId =
                                          newValue;
                                      issuppliertselect = true;
                                      selectedsupplier = newValue;

                                      if (widget.bloc.purchaseOrder.lines
                                          .isNotEmpty) {
                                        widget.bloc.purchaseOrder.total = 0;
                                        widget.bloc.purchaseOrder.itemSubTotal =
                                            0;
                                        widget.bloc.purchaseOrder
                                            .purchaseTaxTotal = 0;

                                        for (var element in widget
                                            .bloc.purchaseOrder.lines) {
                                          double? newCost = await widget.bloc
                                              .newUnitcost(
                                                  element.barcode, newValue);
                                          element.unitCost = newCost!;
                                          element.total = element.subTotal +
                                              element.taxTotal;
                                          widget.bloc.onTableUpdate.sink(true);

                                          widget.bloc.purchaseOrder
                                              .calculateTotal();
                                        }
                                      }
                                    }
                                    setState(() {});
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: DatePicker(
                            label: "Issued Date".tr(),
                            initialDate: widget.bloc.purchaseOrder.purchaseDate,
                            onSelect: (date) {
                              if (date != null) {
                                isdate = true;
                                widget.bloc.purchaseOrder.purchaseDate = date;
                              }
                            },
                          ),
                        ),
                        if (issuppliertselect ||
                            widget.bloc.selectedsupplier != "")
                          Padding(
                            padding: EdgeInsets.only(
                                left: 17.0,
                                right: Localizations.localeOf(context)
                                            .toString() ==
                                        "ar"
                                    ? 17
                                    : 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Items".tr(),
                                    style: TextStyle(fontSize: 19)),
                              ],
                            ),
                          ),
                        if (issuppliertselect ||
                            widget.bloc.selectedsupplier != "")
                          StreamBuilder<bool>(
                              stream: widget.bloc.search.stream,
                              builder: (context, snapshot) {
                                bool isSearchActive = snapshot.data ?? false;

                                return Row(
                                  children: [
                                    !isSearchActive
                                        ? Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: TextField(
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  hintText:
                                                      "Enter barcode".tr(),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFEBEBF3),
                                                        width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFF59c0d2),
                                                        width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  suffixIcon: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      minimumSize:
                                                          const Size(58, 57),
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF59c0d2),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft: Localizations
                                                                          .localeOf(
                                                                              context)
                                                                      .toString() ==
                                                                  "en"
                                                              ? Radius.zero
                                                              : Radius.circular(
                                                                  10),
                                                          topRight: Localizations
                                                                          .localeOf(
                                                                              context)
                                                                      .toString() ==
                                                                  "en"
                                                              ? Radius.circular(
                                                                  10)
                                                              : Radius.zero,
                                                          bottomRight: Localizations
                                                                          .localeOf(
                                                                              context)
                                                                      .toString() ==
                                                                  "en"
                                                              ? Radius.circular(
                                                                  10)
                                                              : Radius.zero,
                                                          bottomLeft: Localizations
                                                                          .localeOf(
                                                                              context)
                                                                      .toString() ==
                                                                  "en"
                                                              ? Radius.zero
                                                              : Radius.circular(
                                                                  10),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Add".tr(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      String barcode =
                                                          _barcodeController
                                                              .text
                                                              .trim();
                                                      if (barcode.isNotEmpty) {
                                                        Product?
                                                            fetchedProduct =
                                                            await ProductService()
                                                                .getBranchProductByBarcode(
                                                                    Utilts
                                                                        .branchid,
                                                                    searchTerm:
                                                                        barcode);

                                                        if (fetchedProduct !=
                                                            null) {
                                                          bool barcodeExists = widget
                                                              .bloc
                                                              .purchaseOrder
                                                              .lines
                                                              .any((line) =>
                                                                  line.productId ==
                                                                  fetchedProduct!
                                                                      .id);
                                                          if (barcodeExists)
                                                            SnackBarUtil.showSnackBar(context,
                                                                'product already added'
                                                                    .tr());
                                                          else
                                                            _showQuantityDialog(
                                                                barcode,
                                                                fetchedProduct
                                                                    .name);
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
                                                controller: _barcodeController,
                                                onChanged:
                                                    (String value) async {
                                                  if (value.length >= 12) {
                                                    String barcode =
                                                        _barcodeController.text
                                                            .trim();
                                                    if (barcode.isNotEmpty) {
                                                      Product? fetchedProduct =
                                                          await ProductService()
                                                              .getBranchProductByBarcode(
                                                                  Utilts
                                                                      .branchid,
                                                                  searchTerm:
                                                                      barcode);

                                                      if (fetchedProduct !=
                                                          null) {
                                                        bool barcodeExists = widget
                                                            .bloc
                                                            .purchaseOrder
                                                            .lines
                                                            .any((line) =>
                                                                line.productId ==
                                                                fetchedProduct!
                                                                    .id);
                                                                                      if (barcodeExists) {
       
         
            SnackBarUtil.showSnackBar(context,'product already added'.tr());
            lastSnackBarTime = DateTime.now(); 
          
        } else {
          _showQuantityDialog(barcode,fetchedProduct.name);
        }
        
      } else {
    
       SnackBarUtil.showSnackBar(context,'Product not found'.tr());
          lastSnackBarTime = DateTime.now(); 
        
      }
                                                    } _barcodeController
                                                            .clear();
                                                  }
                                                },
                                              ),
                                            ),
                                          )
                                        :
                                         Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color(0xFFEBEBF3),
                                                      width: 2.0),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              
                                                height: 57,
                                                child: SearchableDropdown<
                                                    String>.paginated(
                                                 rightpadding:23,
                                                  isDialogExpanded: false,
                                                  dialogOffset:0,
                                                  controller: _searchcontroller,
                                                  hintText: Text('Search'.tr()),
                                                  margin:
                                                      const EdgeInsets.all(15),
                                                  paginatedRequest: (int page,
                                                      String? searchKey) async {
                                                    final paginatedList =
                                                        await widget.bloc
                                                            .loadProducts(
                                                      selectedsupplier,
                                                      page: page,
                                                      searchTerm:
                                                          searchKey ?? "",
                                                    );

                                                    return paginatedList
                                                        .map((e) =>
                                                            SearchableDropdownMenuItem(
                                                                value:
                                                                    e.barcode,
                                                                label: e.name ??
                                                                    '',
                                                                child: Text(
                                                                    e.name ??
                                                                        '')))
                                                        .toList();
                                                  },
                                                  requestItemCount: 15,
                                                  onChanged:
                                                      (String? value) async {
                                                    if (value!.isNotEmpty) {
                                                      widget.bloc.onTableUpdate
                                                          .sink(true);
                                                      Product? fetchedProduct =
                                                          await ProductService()
                                                              .getBranchProductByBarcode(
                                                                  Utilts
                                                                      .branchid,
                                                                  searchTerm:
                                                                      value);
                                                      bool barcodeExists = widget
                                                          .bloc
                                                          .purchaseOrder
                                                          .lines
                                                          .any((line) =>
                                                              line.productId ==
                                                              fetchedProduct!
                                                                  .id);
                                                      if (barcodeExists)
                                                       SnackBarUtil.showSnackBar(context,
                                                            'product already added'
                                                                .tr());
                                                      else
                                                        _showQuantityDialog(
                                                            value,
                                                            fetchedProduct!
                                                                .name);
                                                      _barcodeController
                                                          .clear();
                                                    }
                                                    _searchcontroller?.clear();
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
                        if (issuppliertselect ||
                            widget.bloc.selectedsupplier != "")
                          StreamBuilder(
                            stream: widget.bloc.onTableUpdate.stream,
                            builder: (context, snapshot) {
                              double screenWidth =
                                  MediaQuery.of(context).size.width;

                              return SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      width: screenWidth,
                                      child: dataTable(
                                          widget.bloc.purchaseOrder.lines),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        Container(
                          width: double.maxFinite,
                          height: 20,
                          color: Colors.transparent,
                        ),
                        StreamBuilder(
                          stream: widget.bloc.onTableUpdate.stream,
                          builder: (context, snapshot) {
                            return Column(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        height: 100,
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Sub Total: ".tr(),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      "${widget.bloc.purchaseOrder.itemSubTotal.toStringAsFixed(2)}"),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Tax Total: ".tr(),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      "${widget.bloc.purchaseOrder.purchaseTaxTotal.toStringAsFixed(2)}"),
                                                ],
                                              ),
                                              Row(
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
                                                      "${widget.bloc.purchaseOrder.total.toStringAsFixed(2)}"),
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
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  dataTable(List<PurchaseOrderLine> lines) {
    //   final Map<String, int> quantities2;
    count = lines.length;
    print(lines.length.toString());
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DataTable(
          dataRowHeight: 150,
          showBottomBorder: true,
          columnSpacing: 22,
          headingTextStyle: TextStyle(fontSize: count == 0 ? 16 : 20),
          dataTextStyle: const TextStyle(fontSize: 20),
          columns: [
            DataColumn(
                label: SizedBox(
                    width: 146,
                    child: Text(
                      "Name".tr(),
                      textAlign:
                          Localizations.localeOf(context).toString() == "en"
                              ? TextAlign.left
                              : TextAlign.right,
                    ))),
            DataColumn(
                label: SizedBox(
                    width: 97, child: Center(child: Text("Unit Cost".tr())))),
            DataColumn(
                label: SizedBox(
                    width: 110,
                    child: Center(
                        child: Text("Qty".tr(), textAlign: TextAlign.center)))),
            DataColumn(
                label: SizedBox(
                    width: 90, child: Center(child: Text("Total".tr())))),
            DataColumn(
                label: SizedBox(
                    width: 90, child: Center(child: Text("Delete".tr())))),
          ],
          rows: List<DataRow>.generate(lines.length, (index) {
            final line = lines[index];
            final productId = line.productId;
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 146,
                    child: FutureBuilder<Product?>(
                        future: widget.bloc.fetchProductById(productId!),
                        builder: (context, snapshot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      snapshot.data?.name ??
                                          'Product not found'.tr(),
                                      maxLines: 2,
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
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ),
                DataCell(Center(child: Text(line.unitCost.toStringAsFixed(2)))),
                DataCell(
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        line.qty > 0
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
                            widget.bloc.onIncreaseQty(line);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Center(child: Text(line.total.toStringAsFixed(2)))),
                DataCell(
                  Center(
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

class DatePicker extends StatefulWidget {
  final String label;
  final Function(DateTime?) onSelect;
  final DateTime initialDate;

  const DatePicker({
    super.key,
    required this.label,
    required this.onSelect,
    required this.initialDate,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late TextEditingController _dateController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _dateController = TextEditingController(
      text: DateFormat("dd-MM-yyyy").format(selectedDate!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        hintStyle:
            TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
        hintText: widget.label,
        label: Text(widget.label),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _dateController.text.isNotEmpty
                ? const Color(0xFFEBEBF3)
                : Colors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF59c0d2), width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => selectDate(context),
        ),
      ),
      onTap: () => selectDate(context),
    );
  }

  selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text = DateFormat("dd-MM-yyyy").format(pickedDate);
      });
      widget.onSelect(selectedDate);
    }
  }
}
