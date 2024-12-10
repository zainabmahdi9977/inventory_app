import 'package:flutter/material.dart';
import 'package:inventory_app/bloc/creatlist/CreateListBloc.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountFormBloc.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountListBloc.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderBloc.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderFormBloc.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutFormBloc.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutListBloc.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:inventory_app/pagess/CreateList/CreateList.dart';
import 'package:inventory_app/pagess/CreateList/CreateListForm.dart';
import 'package:inventory_app/pagess/PhysicalCount/PhysicalCountForm.dart';
import 'package:inventory_app/pagess/PhysicalCount/PhysicalCountList.dart';
import 'package:inventory_app/pagess/PurchaseOrder/PurchaseOrderForm.dart';
import 'package:inventory_app/pagess/PurchaseOrder/PurchaseOrderList.dart';
import 'package:inventory_app/pagess/TransferOut/TransferOutForm.dart';
import 'package:inventory_app/pagess/TransferOut/TransferOutList.dart';
import 'package:invo_models/invo_models.dart';

class NavigationService {
  BuildContext context;
  NavigationService(this.context);
  Property<String> currentPage = Property("Home");
  List<String> pageStack = ["Home"];
  _pushPage(dynamic page) async {
    return await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secAndimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1, 0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<bool> goBackToHomePage() async {
    // Navigator.of(context).popUntil((route) => route.isFirst);
       NavigationService(context).goBackToHomePage();

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => HomePage(branchName: Utilts.branchName),
    //   ),
    // );
    currentPage.sink("HomePage");
    pageStack = ["HomePage"];
    return true;
  }

  Future<bool> goToPurchaseOrder(PurchaseOrderFormBloc  bloc) async {
    _pushPage(PurchaseOrderForm(bloc: bloc));
    currentPage.sink("PurchaseOrderForm");
    pageStack.add("PurchaseOrderForm");
    return true;
  }
  
  Future<bool> goToPurchaseOrderList(PurchaseOrderBloc  bloc, ) async {
    _pushPage(PurchaseOrderList(bloc: bloc));
    currentPage.sink("PurchaseOrderList");
    pageStack.add("PurchaseOrderList");
    return true;
  }

  Future<bool> goToPhysicalCountList(PhysicalCountListBloc  bloc) async {
    _pushPage(PhysicalCountList(bloc: bloc, showDialog: false,));
    currentPage.sink("PhysicalCountList");
    pageStack.add("PhysicalCountList");
    return true;
  }
    Future<bool> goToPhysicalCountForm(PhysicalCountFormBloc  bloc) async {
    _pushPage(PhysicalCountFormpage(bloc: bloc));
    currentPage.sink("PhysicalCountFormpage");
    pageStack.add("PhysicalCountFormpage");
    return true;
  }
  
    Future<bool> goToTransferOutList(TransferOutListBloc bloc) async {
    _pushPage(TransferOutList(bloc: bloc));
    currentPage.sink("TransferOutList");
    pageStack.add("TransferOutList");
    return true;
  }
    Future<bool> goToTransferOutFormpage(TransferOutFormBloc  bloc) async {
    _pushPage(TransferOutFormpage(bloc: bloc));
    currentPage.sink("TransferOutFormpage");
    pageStack.add("TransferOutFormpage");
    return true;
  }
  //CreateList CreateListBloc
      Future<bool> goToCreateListBloc(CreateListBloc  bloc) async {
    _pushPage(CreateList(bloc: bloc));
    currentPage.sink("CreateList");
    pageStack.add("CreateList");
    return true;
  }
        Future<bool> goToCreateListlistBloc(CreateListViewBloc  bloc) async {
    _pushPage(CreateListViewPage(bloc: bloc));
    currentPage.sink("CreateListViewPage");
    pageStack.add("CreateListViewPage");
    return true;
  }
  void goBack(dynamic resault) {
    if (Navigator.of(context).canPop()) {
      pageStack.removeLast();
      if (pageStack.isEmpty) {
        currentPage.sink("HomePage");
        pageStack = ["HomePage"];
      } else {
        currentPage.sink(pageStack.last);
      }
      Navigator.of(context).pop(resault);
    }
  }
}
