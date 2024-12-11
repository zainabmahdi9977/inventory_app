import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrder.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/pagess/CreateList/creatlistdaialge.dart';
import 'package:inventory_app/pagess/homepage.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderBloc.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';
import 'package:invo_models/models/Supplier.dart';

import '../../vendor/searchable_paginated_dropdown/lib/src/searchable_dropdown_controller.dart';


class PurchaseOrderList extends StatefulWidget {
  final PurchaseOrderBloc bloc;

  const PurchaseOrderList({super.key, required this.bloc});

  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderList>
    with SingleTickerProviderStateMixin {
  final PurchaseOrderBloc bloc = PurchaseOrderBloc();
  late TabController _tabController;
  String searchTerm = '';

  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();
  List<PurchaseOrder> openPOItems = [];
  List<PurchaseOrder> closedPOItems = [];
  int openPOPage = 1;
  int closedPOPage = 1;
  bool isLoadingMoreOpen = false;
  bool isLoadingMoreClosed = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
    // _searchController.addListener(_filterProducts);
  }
  //                  FocusScope.of(context).unfocus();
//  widget.bloc.selectedsupplier = newValue ?? "";

  showSupplierDialog(BuildContext context) {
    SearchableDropdownController<String>? _searchcontrollerforsupplier =
        SearchableDropdownController<String>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Supplier".tr()),
          content: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Default border color
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.maxFinite,
            height: 200, // Adjust height as needed
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
                widget.bloc.selectedsupplier = newValue ?? "";
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Close".tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    bloc.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    _loadOpenPO();
    _loadClosedPO();
  }

  _loadOpenPO() async {
    final loadedItems =
        await bloc.loadOpenPO(page: openPOPage, searchTerm: searchTerm);
    setState(() {
      if (openPOPage == 1) {
        openPOItems = loadedItems;
      } else {
        openPOItems.addAll(loadedItems);
      }
    });
  }

  _loadClosedPO() async {
    final loadedItems =
        await bloc.loadClosedPO(page: closedPOPage, searchTerm: searchTerm);
    setState(() {
      if (closedPOPage == 1) {
        closedPOItems = loadedItems;
      } else {
        closedPOItems.addAll(loadedItems);
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchTerm = value;
      openPOPage = 1;
      closedPOPage = 1;
    });
    _loadOpenPO();

    _loadClosedPO();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_tabController.index == 0 && !isLoadingMoreOpen) {
        isLoadingMoreOpen = true;
        openPOPage++;
        _loadOpenPO().then((_) => isLoadingMoreOpen = false);
      } else if (_tabController.index == 1 && !isLoadingMoreClosed) {
        isLoadingMoreClosed = true;
        closedPOPage++;
        _loadClosedPO().then((_) => isLoadingMoreClosed = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {



    return StreamBuilder<Object>(
        stream: Utilts.updateLanguage.stream,
        builder: (context, snapshot) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: CustomAppBar(title: 'Purchase Order'.tr()),
            body: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold),
                              hintText: 'Search'.tr(),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFEBEBF3), width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF59c0d2), width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: Localizations.localeOf(context).toString() ==
                                    "en"
                                ? 0
                                : 16,
                            right: Localizations.localeOf(context).toString() ==
                                    "en"
                                ? 16
                                : 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            minimumSize: const Size(60, 55),
                            backgroundColor: const Color(0xFF59c0d2),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                          child: Text(
                            "New".tr(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          onPressed: () {
                            CreateListDialog.show(
                              context,
                              CreateListViewBloc(),
                              "PurchaseOrder",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xff45BBCF),
                    indicatorWeight: 3.0,
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Open'.tr()),
                      Tab(text: 'Closed'.tr()),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // isLoadingMoreOpen?
                        // const Center(child: CircularProgressIndicator()):

                        _buildList(openPOItems),
                        // isLoadingMoreClosed?
                        // const Center(child: CircularProgressIndicator()):
                        _buildList(closedPOItems),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: bottomNavigationBar(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomePage(branchName: Utilts.branchName),
                    ),
                  );
                },
                label: 'Back'.tr()),
          );
        });
  }

  Widget _buildList(List<PurchaseOrder> counts) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _onScroll();
        }
        return false;
      },
      child: Container(
          width: 500,
          child: dataTable(
              orders: counts, showEditColumn: counts == closedPOItems)),
    );
  }

  Widget dataTable(
      {required List<PurchaseOrder> orders, required bool showEditColumn}) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 13,
        // Set custom row height
        columns: [
          DataColumn(
            label: Expanded(
              child: Text(
                "PO Number".tr(),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Center(child: Text("Supplier".tr())),
            ),
          ),
          DataColumn(
            numeric: true,
            label: Expanded(
              child: Center(child: Text("Total".tr())),
            ),
          ),
          if (!showEditColumn) // Conditionally add the Edit column
            DataColumn(
              numeric: true,
              label: Expanded(child: Center(child: Text("Edit".tr()))),
            ),
        ],
        rows: List<DataRow>.generate(orders.length, (index) {
          final order = orders[index];
          return DataRow(
            cells: [
              DataCell(Center(child: Text(order.purchaseNumber))),
              DataCell(
                Center(
                  child: SizedBox(
                    width: 100,
                    child: Text(
                      order.supplierName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ),
              ),
              DataCell(Center(child: Text("${order.total} BD"))),
              if (!showEditColumn)
                DataCell(
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Color(0xff45BBCF),
                    ),
                    onPressed: () {
                      bloc.editPO(context, order);
                    },
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

_showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Success'.tr()),
        content: Text('Purchase Order saved successfully!'.tr()),
        actions: <Widget>[
          TextButton(
            child: Text('OK'.tr()),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );

  // Optionally, close the dialog after 3 seconds
  Future.delayed(const Duration(seconds: 5), () {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(); // Close the dialog
    }
  });
}
