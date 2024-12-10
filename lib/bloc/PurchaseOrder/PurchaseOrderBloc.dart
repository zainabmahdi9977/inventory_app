import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderFormBloc.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrder.dart';
import 'package:inventory_app/serviecs/PurchaseOrder.sarvise.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:invo_models/models/Supplier.dart';
import 'package:invo_models/utils/property.dart'; // Adjust according to your project structure

// BLoC class
class PurchaseOrderBloc extends ChangeNotifier {
  Property<List<PurchaseOrder>> closePurchaseOrder = Property([]);
  Property<List<PurchaseOrder>> openPurchaseOrder = Property([]);
    Property<List<Supplier>> suppliers = Property([]);
 String selectedsupplier ='';
  PurchaseOrderBloc(){fetchSuppliers(1,"");}
  @override
  void dispose() {
    closePurchaseOrder.dispose();
    openPurchaseOrder.dispose();
    suppliers.dispose();
    super.dispose();
  }

  Future<List<PurchaseOrder>> loadOpenPO({required int page ,required String searchTerm}) async {
    return await PurchaseOrderServies()
        .getOpenPurchaseOrderList(page: page, limit: 15 , searchTerm: searchTerm,);
  }

  Future<List<Supplier>> fetchSuppliers(int page ,

   String searchTerm,) async {
    
    
  
    return await PurchaseOrderServies().getSupplierMiniList(page: page,limit: 15,searchTerm: searchTerm);
  }
  Future<List<PurchaseOrder>> loadClosedPO({required page ,required String searchTerm}) async {
    return await PurchaseOrderServies()
        .getClosedPurchaseOrderList(page: page, limit: 15, searchTerm: searchTerm,);
  }





  void editPO(BuildContext context, PurchaseOrder orders) async {

  try {
  
    PurchaseOrder? order = await PurchaseOrderServies().getPurchaseOrderById(orders.id);
order?.calculateTotal();
    if (order != null) {
  NavigationService(context).goToPurchaseOrder(PurchaseOrderFormBloc.editPO(order));


    } else {
  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase order not found.')),
      );
    }
  } catch (e) {
 
    print('Error fetching purchase order: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching purchase order.')),
    );
  }
}

  void newPO(BuildContext context) {
  
   
  NavigationService(context).goToPurchaseOrder(PurchaseOrderFormBloc.newPO([] , selectedsupplier));

  }
}
