import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutListBloc.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransfer.dart';

import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/pagess/CreateList/creatlistdaialge.dart';
import 'package:inventory_app/pagess/homepage.dart';
//TransferOutFormpage  TransferOutFormBloc TransferOutList TransferOutListBloc
class TransferOutList extends StatefulWidget {
  final TransferOutListBloc bloc;
  const TransferOutList({super.key, required this.bloc});

  @override
  _TransferOutListPageState createState() => _TransferOutListPageState();
}

class _TransferOutListPageState extends State<TransferOutList>
    with SingleTickerProviderStateMixin {
  final TransferOutListBloc bloc = TransferOutListBloc();
  late TabController _tabController;
    String searchTerm = '';
  final _searchController = TextEditingController();
      final ScrollController _scrollController = ScrollController();
List<InventoryTransfer> openITItems = [];
  List<InventoryTransfer> ConfirmedITItems = [];
    int openITPage = 1;
  int ConfirmedITPage = 1;
  bool isLoadingMoreOpen = false;
  bool isLoadingMoreConfirmed = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
        _scrollController.addListener(_onScroll);
    _loadInitialData();
    // _searchController.addListener(_filterProducts);
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
    _loadOpenIT();
    _loadConfirmedIT();
  }


  _loadOpenIT() async {
    final loadedItems = await bloc.loadOpenIT(page: openITPage, searchTerm: searchTerm);
    setState(() {
      if (openITPage == 1) {
        openITItems = loadedItems; 
      } else {
        openITItems.addAll(loadedItems); 
      }
    });
  }


    _loadConfirmedIT() async {
    final loadedItems = await bloc.loadConfirmedIT(page: ConfirmedITPage, searchTerm: searchTerm);
    setState(() {
      if (ConfirmedITPage == 1) {
        ConfirmedITItems = loadedItems; 
      } else {
        ConfirmedITItems.addAll(loadedItems); 
      }
    });
  }
    void _onSearchChanged(String value) {
    setState(() {
      searchTerm = value;
      ConfirmedITPage = 1; 
      openITPage = 1; 
    
    });
   _loadOpenIT();
    _loadConfirmedIT();
  
  }
    void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_tabController.index == 0 && !isLoadingMoreOpen) {
        isLoadingMoreOpen = true;
        openITPage++;
        _loadOpenIT().then((_) => isLoadingMoreOpen = false);
      } else if (_tabController.index == 1 && !isLoadingMoreConfirmed) {
        isLoadingMoreConfirmed = true;
        ConfirmedITPage++;
        _loadConfirmedIT().then((_) => isLoadingMoreConfirmed = false);
      }
    }
  }
  // void _filterProducts() {
  //   String query = _searchController.text.toLowerCase();

  //   setState(() {
  //     _bloc.openPurchaseOrder.value = _products
  //         .where((order) => order.purchaseNumber.contains(query))
  //         .toList();
  //     _bloc.closePurchaseOrder.value = _products2
  //         .where((order) => order.purchaseNumber.contains(query))
  //         .toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: Utilts.updateLanguage.stream,
      builder: (context, snapshot) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar:  CustomAppBar(title: 'Transfer Out'.tr()),
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
                              borderSide:
                                  BorderSide(color: Color(0xFFEBEBF3), width: 2.0),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xFF59c0d2), width: 1.0),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                               padding:  EdgeInsets.only(left: Localizations.localeOf(context).toString()  =="en"?0:16, right: Localizations.localeOf(context).toString()  =="en"?16:0),

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
                        child:  Text(
                          "New".tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        onPressed: () {
                        
                        if(Utilts.addNewInventoryTransfer)
                                               CreateListDialog.show(context, CreateListViewBloc(), "InventoryTransfer");
        
                          else
                           _showNotAllowedDialog(context);
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
                  tabs:  [
                     Tab(text: 'Open'.tr()),
                      Tab(text: 'Confirmed'),
                  
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [       
                      //   FutureBuilder<List<InventoryTransfer>>(
                      //   future: widget.bloc.loadConfirmedIT(),
                      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                      //     return list(snapshot);
                      //   },
                      // ),
                      // FutureBuilder<List<InventoryTransfer>>(
                      //   future: widget.bloc.loadOpenIT(),
                      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                      //     return list(snapshot);
                      //   },
                 _buildList(openITItems, true),          // ),
              _buildList(ConfirmedITItems ,false ), 
          
                    
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: bottomNavigationBar(
              onPressed: () {
         //  NavigationService(context).goBackToHomePage();
        
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(branchName: Utilts.branchName),
                  ),
                );
              },
              label: 'Back'.tr()),
        );
      }
    );
  }
  Widget _buildList(List<InventoryTransfer> inventoryTransfer , bool isedit) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _onScroll();
        }
        return false;
      },
      child: Container(width: 500,child: dataTable(inventory: inventoryTransfer, isedit: isedit)),
    );
  }
  Widget dataTable({required List<InventoryTransfer> inventory , required bool isedit}  ) {
    return SingleChildScrollView(
       controller: _scrollController,
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 13,
        // Set custom row height
        columns:  [
           DataColumn(
            numeric: true,
            label: Expanded(
              child: Text(
                "Transfer \nNo".tr(),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          // DataColumn(
          //   label: Expanded(
          //     child: Center(child: Text("Reference No")),
          //   ),
          // ),
           DataColumn(
            numeric: true,
            label: Expanded(
              child: Center(child: Text("Reason".tr())),
            ),
          ),
                     DataColumn(
            numeric: true,
            label: Expanded(
              child: Center(child: Text("Date".tr())),
            ),
          ),
          if(isedit == true )
           DataColumn(
            numeric: true,
            label: Expanded(
              child: Center(child: Text("Edit".tr())),
            ),
          ),
        ],
        rows: List<DataRow>.generate(inventory.length, (index) {
          final inventorys = inventory[index];
          return DataRow(
            cells: [
              DataCell(Center(child: Text(inventorys.transferNumber))),
  //  DataCell(Center(child: Text(inventorys.reference ))),
              DataCell(Center(child: Text(inventorys.reason.tr() , textAlign: TextAlign.center,))),
              DataCell(Center(child:  Text(
      DateFormat('yyyy-MM-dd').format(inventorys.createdDate), // Format the date
    ),)),    if(isedit == true )   
              DataCell(
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xff45BBCF),
                  ),
                  onPressed: () {
                  bloc.editIT(context,inventorys );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
void _showNotAllowedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text("Access Denied".tr()),
        content:  Text("You are not allowed to perform this action.".tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child:  Text("OK".tr()),
          ),
        ],
      );
    },
  );
}
  Widget list(AsyncSnapshot snapshot , bool isedit) {
    List<Widget> children;
    if (snapshot.hasData) {
      return dataTable(inventory: snapshot.data, isedit: isedit);
    } else if (snapshot.hasError) {
      children = <Widget>[
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Error: ${snapshot.error}'),
        ),
      ];
    } else {
      children = const <Widget>[
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Awaiting result...'),
        ),
      ];
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
