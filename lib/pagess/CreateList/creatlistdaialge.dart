import 'package:flutter/material.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountFormBloc.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderBloc.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderFormBloc.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutFormBloc.dart';
import 'package:inventory_app/bloc/creatlist/CreateListBloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:inventory_app/modelss/creatlist/CreateListMod.dart';
import 'package:inventory_app/pagess/PurchaseOrder/PurchaseOrderForm.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';
import 'package:invo_models/models/Supplier.dart';
import 'package:provider/provider.dart';


class CreateListViewContent extends StatefulWidget {
  final CreateListViewBloc bloc;
  final String action;

  const CreateListViewContent({
    super.key,
    required this.bloc,
    required this.action,
  });

  @override
  State<CreateListViewContent> createState() => _CreateListViewContentState();
}

class CreateListDialog {
  static Future<void> show(
      BuildContext context, CreateListViewBloc bloc, String action) {
    if (Utilts.createList == "[]") {
      if (action == "PhysicalCount") {
        return NavigationService(context)
            .goToPhysicalCountForm(PhysicalCountFormBloc.newPc([]));
      } else if (action == "PurchaseOrder") {
        return NavigationService(context)
            .goToPurchaseOrder(PurchaseOrderFormBloc.newPO([], ""));
      } else {
        return NavigationService(context)
            .goToTransferOutFormpage(TransferOutFormBloc.newIT([]));
      }
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              height: 600,
              child: CreateListViewContent(bloc: bloc, action: action),
            ),
          );
        },
      );
    }
  }
}

class _CreateListViewContentState extends State<CreateListViewContent> {
  late CreateListViewBloc bloc;
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    bloc.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateListViewBloc>(
      create: (_) => bloc,
      child: Scaffold(
        bottomNavigationBar: _buildNewButton(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Select From The List".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 21),
                ),
              ),
              _buildSearchBar(),
              Expanded(
                child: Consumer<CreateListViewBloc>(
                  builder: (context, bloc, child) {
                    return StreamBuilder(
                      stream: widget.bloc.onTableUpdate.stream,
                      builder: (context, snapshot) {
                        return Container(
                          width: double.infinity,
                          child: _dataTable(bloc.filteredOrders.isNotEmpty
                              ? bloc.filteredOrders
                              : bloc.allOrders),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF59c0d2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(
          "New".tr(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        onPressed: () {
          if (widget.action == "PhysicalCount") {
            NavigationService(context)
                .goToPhysicalCountForm(PhysicalCountFormBloc.newPc([]));
          } else if (widget.action == "PurchaseOrder") {
            NavigationService(context)
                .goToPurchaseOrder(PurchaseOrderFormBloc.newPO([], ""));
          } else {
            NavigationService(context).goToTransferOutFormpage(
              TransferOutFormBloc.newIT([]),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                bloc.searchOrders(value);
              },
              decoration: InputDecoration(
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold),
                hintText: 'Search'.tr(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEBEBF3), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF59c0d2), width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataTable2(List<CreateListMod> createList) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        dividerThickness: 0,
        headingTextStyle: const TextStyle(fontSize: 16),
        columns: [
          DataColumn(
              label: Expanded(
                  child: Text("Select From The List".tr(),
                      textAlign: TextAlign.center))),
        ],
        rows: List<DataRow>.generate(createList.length, (index) {
          final createListItem = createList[index];
          return DataRow(
            cells: [
              DataCell(
                Center(child: Text(createListItem.name)),
                onTap: () {
                  if (widget.action == "PhysicalCount") {
                    NavigationService(context).goToPhysicalCountForm(
                      PhysicalCountFormBloc.newPc(
                          widget.bloc.getAllBarcodes2(createListItem.id)),
                    );
                  } else if (widget.action == "PurchaseOrder") {
                    //  NavigationService(context).goToPurchaseOrder(
                    //    PurchaseOrderFormBloc.newPO(widget.bloc.getAllBarcodes(createListItem.id),""),
                    //  );
                    showSupplierDialog(context, widget.bloc,
                        widget.bloc.getAllBarcodes(createListItem.id));
                  } else {
                    NavigationService(context).goToTransferOutFormpage(
                      TransferOutFormBloc.newIT(
                          widget.bloc.getAllBarcodes2(createListItem.id)),
                    );
                  }
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  //  return Column(
  //     children: <Widget>[
  //       const ExpansionTile(
  //         title: Text('ExpansionTile 1'),
  //         subtitle: Text('Trailing expansion arrow icon'),
  //         children: <Widget>[
  //           ListTile(title: Text('This is tile number 1')),
  //         ],
  //       ),
  Widget _dataTable(List<CreateListMod> createList) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        dividerThickness: 0,
        headingRowHeight: 0,
        dataRowMaxHeight: double.infinity, // Allow the row to grow
        //  headingTextStyle: const TextStyle(fontSize: 16),
        columns: const [
          DataColumn(
            label: Expanded(
              child: Text("", textAlign: TextAlign.center),
            ),
          ),
        ],
        rows: List<DataRow>.generate(createList.length, (index) {
          final createListItem = createList[index];
          return DataRow(
            cells: [
              DataCell(
                onTap: () {
                  if (widget.action == "PhysicalCount") {
                    NavigationService(context).goToPhysicalCountForm(
                      PhysicalCountFormBloc.newPc(
                          widget.bloc.getAllBarcodes2(createListItem.id)),
                    );
                  } else if (widget.action == "PurchaseOrder") {
                    //  NavigationService(context).goToPurchaseOrder(
                    //    PurchaseOrderFormBloc.newPO(widget.bloc.getAllBarcodes(createListItem.id),""),
                    //  );
                    showSupplierDialog(context, widget.bloc,
                        widget.bloc.getAllBarcodes(createListItem.id));
                  } else {
                    NavigationService(context).goToTransferOutFormpage(
                      TransferOutFormBloc.newIT(
                          widget.bloc.getAllBarcodes2(createListItem.id)),
                    );
                  }
                },
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 15),
                      child: Container(
                        child: Text(createListItem.name,
                            textAlign: TextAlign.left),
                      ),
                    ),
                    Container(
                      child: ExpansionTile(
                        minTileHeight: 5,
                        title: Text(
                          "item Number:".tr() +
                              "  ${createListItem.lines.length.toString()}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        children: [
                          for (var element in createListItem.lines)
                            ListTile(
                              title: Text(
                                element.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                  "Qty".tr() + ": ${element.qty.toString()}"),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  static showSupplierDialog(
      //                              FocusScope.of(context).unfocus();
      //   bloc.selectedsupplier = newValue ?? "";
      // errorNotifier.value = null;
      BuildContext context,
      CreateListViewBloc bloc,
      List<String> allBarcodes) {
    String? errorMessage; // To hold the error message
    ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
    SearchableDropdownController<String>? _searchcontrollerforsupplier =
        SearchableDropdownController<String>();

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
                      color: const Color.fromRGBO(215, 215, 215, 1),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 197,
                  height: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SearchableDropdown<String>.paginated(
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
                   
                    ],
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
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return const SizedBox
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
    // _searchcontrollerforsupplier.dispose();
  }
}
