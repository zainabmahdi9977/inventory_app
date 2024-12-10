import 'dart:async';
import 'package:flutter/material.dart';

import 'package:inventory_app/bloc/TransferOut/TransferOutFormBloc.dart';
import 'package:inventory_app/modelss/InventoryTransfer/InventoryTransfer.dart';
import 'package:inventory_app/serviecs/InventoryTransfer.service.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:invo_models/utils/property.dart'; // Adjust according to your project structure

// BLoC class
class TransferOutListBloc extends ChangeNotifier {
  // ignore: non_constant_identifier_names
  Property<List<InventoryTransfer>> ConfirmedPurchaseOrder = Property([]);
  Property<List<InventoryTransfer>> openInventoryTransfer = Property([]);
 late InventoryTransfer inventoryTransfer;
  TransferOutListBloc();
  @override
  void dispose() {
    ConfirmedPurchaseOrder.dispose();
    openInventoryTransfer  .dispose();
    super.dispose();
  }
  Future<List<InventoryTransfer>> loadOpenIT({required int page, required String searchTerm}) async {
    return await InventoryTransferService().getInventoryTransferList(
        page: page, limit: 15, status: 'Open', filter: {}, searchTerm: searchTerm,);
  }

  Future<List<InventoryTransfer>> loadConfirmedIT({required int page, required String searchTerm}) async {
    return await InventoryTransferService().getInventoryTransferList(
        page: page, limit: 15, status: 'Confirmed', filter: {}, searchTerm: searchTerm,);
  }


  // factory TransferOutListBloc.newPO() {
  //   TransferOutListBloc transferOutFormBloc = TransferOutListBloc();
  //   transferOutFormBloc.inventoryTransfer = InventoryTransfer();
  //   transferOutFormBloc.inventoryTransfer.branchId = Utilts.branchid;
  //   return transferOutFormBloc;
  // }

  factory TransferOutListBloc.editIT(InventoryTransfer inventoryTransfer) {
    TransferOutListBloc transferOutFormBloc = TransferOutListBloc();
       transferOutFormBloc.inventoryTransfer = inventoryTransfer;
    return transferOutFormBloc;
  }
  void filterProducts(String query) {
    // final lowerCaseQuery = query.toLowerCase();

    // openPurchaseOrder.value = _products
    //     .where((order) => order.purchaseNumber.contains(lowerCaseQuery))
    //     .toList();

    // closePurchaseOrder.value = _products2
    //     .where((order) => order.purchaseNumber.contains(lowerCaseQuery))
    //     .toList();
  }



  Future<void> editIT(BuildContext context, InventoryTransfer inventoryTransfer) async {
        InventoryTransfer inventoryTransfers =
          await InventoryTransferService().getInventoryTransferById(inventoryTransfer.id);
       // ignore: use_build_context_synchronously
       NavigationService(context).goToTransferOutFormpage(TransferOutFormBloc.editIT(inventoryTransfers));
    
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TransferOutFormpage(
    //       bloc:TransferOutFormBloc.editIT(inventoryTransfers),
    //     ),
    //   ),
    // );
  }

  void newIT(BuildContext context) {
       NavigationService(context).goToTransferOutFormpage(TransferOutFormBloc.newIT([]));

    // replace with the navigation service
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TransferOutFormpage(
    //       bloc: TransferOutFormBloc.newPO(),
    //     ),
    //   ),
    // );
  }

}
