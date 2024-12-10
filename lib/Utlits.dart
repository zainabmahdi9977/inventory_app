import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:inventory_app/modelss/creatlist/CreateListMod.dart';
import 'package:inventory_app/modelss/creatlist/CreateListlineMod.dart';
import 'package:inventory_app/pagess/CreateList/CreateListForm.dart';
import 'package:invo_models/invo_models.dart';

class Utilts {
  static GlobalKey<NavigatorState> rootNavigationKey = GlobalKey();
  static List<CreateListlineMod> enteredOrders = []; 
  static List<Product> Productlist = []; 
  static BuildContext? mainContext;
static Property<bool> updateLanguage = Property(false);
 static String branchName = '';
  static String Language = 'en';
static String branchid= '';

  static String userPrivilegeName='';

  static bool addNewPhysicalCounts=true;

  static bool viewPhysicalCounts=true;

  static bool addNewInventoryTransfer=true;

  static bool viewInventoryTransfer=true;

  static List<CreateListMod> FilteredOrders=[];
  static String createList="";
  // static double total=0;

  // static double difference=0.0;

  // static double actualValue=0.0;

  // static double CalculatedValue=0.0;

  // static String acountid="";

  // static double taxTotal=0.0;

  // static double itemSubTotal=0.0;

  // static double selectedTaxPercentage=0.0;

  // static double totaltax=0.0;

}
