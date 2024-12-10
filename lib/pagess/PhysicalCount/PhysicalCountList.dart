import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountFormBloc.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountListBloc.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/modelss/PhysicalCount/PhysicalCount.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/pagess/CreateList/creatlistdaialge.dart';
import 'package:inventory_app/pagess/homepage.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';

class PhysicalCountList extends StatefulWidget {
  final PhysicalCountListBloc bloc;  final bool showDialog;
  const PhysicalCountList({super.key, required this.bloc, required this.showDialog});

  @override
  _PhysicalCountListPageState createState() => _PhysicalCountListPageState();
}
class _PhysicalCountListPageState extends State<PhysicalCountList>
    with SingleTickerProviderStateMixin {
  final PhysicalCountListBloc bloc = PhysicalCountListBloc();
  late TabController _tabController;
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchTerm = '';
  List<PhysicalCount> openPCItems = [];
  List<PhysicalCount> calculatedPCItems = [];
  List<PhysicalCount> closedPCItems = [];
  int openPCPage = 1;
  int calculatedPCPage = 1;
  int closedPCPage = 1;

  bool isLoadingMoreOpen = false;
  bool isLoadingMoreCalculated = false;
  bool isLoadingMoreClosed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
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
    _loadOpenPC();
    _loadCalculatedPC();
    _loadClosedPC();
  }

  _loadOpenPC() async {
    final loadedItems = await bloc.loadOpenPC(page: openPCPage, searchTerm: searchTerm);
    setState(() {
      if (openPCPage == 1) {
        openPCItems = loadedItems; 
      } else {
        openPCItems.addAll(loadedItems); 
      }
    });
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
  _loadCalculatedPC() async {
    final loadedItems = await bloc.loadCalculatedPC(page: calculatedPCPage, searchTerm: searchTerm);
    setState(() {
      if (calculatedPCPage == 1) {
        calculatedPCItems = loadedItems; 
      } else {
        calculatedPCItems.addAll(loadedItems); 
      }
    });
  }

  _loadClosedPC() async {
    final loadedItems = await bloc.loadClosePC(page: closedPCPage, searchTerm: searchTerm);
    setState(() {
      if (closedPCPage == 1) {
        closedPCItems = loadedItems; 
      } else {
        closedPCItems.addAll(loadedItems); 
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchTerm = value;
      openPCPage = 1; 
      calculatedPCPage = 1; 
      closedPCPage = 1; 
    });
    _loadOpenPC();
    _loadCalculatedPC();
    _loadClosedPC();
  }

  void _onScroll() {
    // Check if the user has scrolled to the bottom of the list
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_tabController.index == 0 && !isLoadingMoreOpen) {
        isLoadingMoreOpen = true;
        openPCPage++;
        _loadOpenPC().then((_) => isLoadingMoreOpen = false);
      } else if (_tabController.index == 1 && !isLoadingMoreCalculated) {
        isLoadingMoreCalculated = true;
        calculatedPCPage++;
        _loadCalculatedPC().then((_) => isLoadingMoreCalculated = false);
      } else if (_tabController.index == 2 && !isLoadingMoreClosed) {
        isLoadingMoreClosed = true;
        closedPCPage++;
        _loadClosedPC().then((_) => isLoadingMoreClosed = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     if (showDialog==true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(context);
      });
    }
    return StreamBuilder<Object>(
      stream: Utilts.updateLanguage.stream,
      builder: (context, snapshot) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar:  CustomAppBar(title: 'Physical Count'.tr()),
          body: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
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
                    Padding(
                               padding:  EdgeInsets.only(left: Localizations.localeOf(context).toString()  =="en"?0:16, right: Localizations.localeOf(context).toString()  =="en"?16:0),

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size(60, 55),
                          backgroundColor: const Color(0xFF59c0d2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child:  Text(
                          "New".tr(),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        onPressed: () {
                          if(Utilts.addNewPhysicalCounts) {
                         
                            CreateListDialog.show(context, CreateListViewBloc(), "PhysicalCount".tr());
                          } else {
                            _showNotAllowedDialog(context);
                          }
                      
                        },
                      ),
                      
                    ),
        //                 ElevatedButton(
        //   onPressed: () {
        //     CreateListDialog.show(context, CreateListViewBloc());
        //   },
        //   child: Text('Open Create List Dialog'),
        // )
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
                    Tab(text: 'Calculated'.tr()),
                    Tab(text: 'Closed'.tr()),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // isLoadingMoreOpen?
                      // Center(child: CircularProgressIndicator()):
                      _buildList(openPCItems),
                      // isLoadingMoreCalculated?Center(child: CircularProgressIndicator()):
                      _buildList(calculatedPCItems),
                      // isLoadingMoreOpen?Center(child: CircularProgressIndicator()):
                      _buildList(closedPCItems),
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
                  builder: (context) => HomePage(branchName: Utilts.branchName),
                ),
              );
            },
            label: 'Back'.tr(),
          ),
        );
      }
    );
  }

  Widget _buildList(List<PhysicalCount> counts) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _onScroll();
        }
        return false;
      },
      child: Container(width: 500,child: dataTable(Counts: counts, showEditColumn: counts == closedPCItems ||counts == calculatedPCItems )),
    );
  }

  Widget dataTable({required List<PhysicalCount> Counts, required bool showEditColumn}) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 13,
        columns: [
           DataColumn(
            label: Expanded(child: Text("Reference No".tr(), textAlign: TextAlign.left)),
          ),
           DataColumn(
            label: Expanded(child: Center(child: Text("Note".tr()))),
          ),
           DataColumn(
            numeric: true,
            label: Expanded(child: Center(child: Text("Date".tr()))),
          ),
          if (!showEditColumn) // Conditionally add the Edit column
             DataColumn(
              numeric: true,
              label: Expanded(child: Center(child: Text("Edit".tr()))),
            ),
        ],
        rows: List<DataRow>.generate(Counts.length, (index) {
          final count = Counts[index];
          final cells = [
            DataCell(Center(child: Text(count.reference))),
            DataCell(
              Center(
                child: SizedBox(
                  width: 100,
                  child: Text(
                    count.note,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
              ),
            ),
            DataCell(Center(child: Text(DateFormat('yyyy-MM-dd').format(count.createdDate)))),
          ];

          if (!showEditColumn) {
            cells.add(DataCell(
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xff45BBCF),
                ),
                onPressed: () {
                  bloc.editPc(context, count);
                },
              ),
            ));
          }

          return DataRow(cells: cells);
        }),
      ),
    );
  }
}

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'.tr()),
          content: Text('Physical Count saved successfully!'.tr()),
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
    Future.delayed(Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close the dialog
      }
    });
  }
