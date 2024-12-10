import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountFormBloc.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrder.dart';
import 'package:inventory_app/modelss/PhysicalCount/PhysicalCount.dart';
import 'package:inventory_app/serviecs/PhysicalCount.service.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:invo_models/utils/property.dart'; 

// BLoC class
class PhysicalCountListBloc extends ChangeNotifier {
  Property<List<PurchaseOrder>> closePurchaseOrder = Property([]);
  Property<List<PhysicalCount>> openPhysicalCount = Property([]);

  PhysicalCountListBloc();
  @override
  void dispose() {
    closePurchaseOrder.dispose();
    openPhysicalCount.dispose();
    super.dispose();
  }
Future<List<PhysicalCount>> loadOpenPC({required int page, required String searchTerm}) async {
  return await PhysicalCountService().getPhysicalCountList(
    status: 'Open',
    page:page,
    limit: 15,
    searchTerm: searchTerm, filter: {}, 
  );
}

  Future<List<PhysicalCount>> loadClosePC({required int page , required String searchTerm}) async {
    return await PhysicalCountService().getPhysicalCountList(
        page: page, limit: 15, status: 'Closed', filter: {}, searchTerm: searchTerm,);
   
  }

  Future<List<PhysicalCount>> loadCalculatedPC({required int page ,  required String searchTerm}) async {
    return await PhysicalCountService().getPhysicalCountList(
        page:page, limit: 15, status: 'Calculated', filter: {} ,searchTerm: searchTerm,);
   
  }






  void editPc(BuildContext context, PhysicalCount physicalCounts) async {
    try {
      PhysicalCount physicalCount =
          await PhysicalCountService().getPhysicalCountById(physicalCounts.id);
    physicalCount.calculate();
      NavigationService(context).goToPhysicalCountForm(PhysicalCountFormBloc.editPc(physicalCount));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Physical Count.')),
      );
    }
  }

  void newPO(BuildContext context) {
      NavigationService(context).goToPhysicalCountForm(PhysicalCountFormBloc.newPc([]));


  }
}
