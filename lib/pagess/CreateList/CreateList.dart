
 import 'package:flutter/material.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/bloc/creatlist/CreateListBloc.dart';

import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:inventory_app/modelss/creatlist/CreateListMod.dart';
import 'package:inventory_app/pagess/homepage.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:provider/provider.dart';
import 'CreateListForm.dart';
import 'package:easy_localization/easy_localization.dart';
class CreateListViewPage extends StatefulWidget {
  final CreateListViewBloc bloc;
  const CreateListViewPage({Key? key, required this.bloc}) : super(key: key);

  @override
  State<CreateListViewPage> createState() => _CreateListViewPageState();
}

class _CreateListViewPageState extends State<CreateListViewPage> {
  late CreateListViewBloc bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc; 
    bloc.loadOrders();
  }
void dispose(){
  _searchController.dispose();
  bloc.dispose();
super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateListViewBloc>(
      create: (_) => bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        appBar:  CustomAppBar(title: 'Create List'.tr()),
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Consumer<CreateListViewBloc>(
                  builder: (context, bloc, child) {
                    return StreamBuilder(
                      stream: widget.bloc.onTableUpdate.stream,
                      builder: (context, snapshot) {
                        return Container(
                          width: double.infinity,
                          child: dataTable(bloc.filteredOrders.isNotEmpty 
                            ? bloc.filteredOrders 
                            : bloc.allOrders),
                        );
                      }
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Call searchOrders directly whenever the text changes
                bloc.searchOrders(value);
              },
              decoration:  InputDecoration(
                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                hintText: 'Search'.tr(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEBEBF3), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
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
              NavigationService(context).goToCreateListBloc(CreateListBloc("", []));
            },
          ),
        ),
      ],
    );
  }

  Widget dataTable(List<CreateListMod> createList) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns:  [
          DataColumn(label: Expanded(child: Text("Name".tr(), textAlign: TextAlign.center))),
          DataColumn(label: Expanded(child: Text("Edit".tr(), textAlign: TextAlign.center))),
          DataColumn(label: Expanded(child: Text("Delete".tr(), textAlign: TextAlign.center))),

        ],
        rows: List<DataRow>.generate(createList.length, (index) {
          final createListItem = createList[index];
          return DataRow(
            cells: [
              DataCell(Center(child: Text(createListItem.name))),
              DataCell(
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xff45BBCF)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateList(
                            bloc: CreateListBloc(createListItem.id, createListItem.lines),
                            selectedOrder: createListItem,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
 DataCell(
  Center(
    child: IconButton(
      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
      onPressed: () {
        // Show confirmation dialog before deleting
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:  Text('Confirm Deletion'.tr()),
              content:  Text('Are you sure you want to delete this list?'.tr()),
              actions: <Widget>[
                TextButton(
                  child:  Text('Cancel'.tr()),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child:  Text('Delete'.tr()),
                  onPressed: () {
                    widget.bloc.removeOrder(createListItem.id);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    ),
  ),
),
            ],
          );
        }),
      ),
    );
  }
}