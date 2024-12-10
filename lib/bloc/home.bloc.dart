import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/serviecs/privielg.services.dart';
import 'package:invo_models/models/EmployeePrivilege.dart';
import 'package:inventory_app/serviecs/varHttp.dart';
import 'package:get_it/get_it.dart';
import 'package:invo_models/models/Employee.dart';
import 'package:invo_models/models/Terminal.dart';
import 'package:invo_models/utils/property.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Make sure to import the Employee model
import 'package:easy_localization/easy_localization.dart';
class Homebloc extends ChangeNotifier {
 late String userPrivilegeName;
  bool? userPrivilegeValue;
  Property<bool> updateLanguage = Property(false);
 late Terminal terminal;
  Homebloc() {
    _fetchUserPrivilege();
  }

  changeLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    Terminal terminalTemp;
    if (prefs.getString("terminal") != null) {
      terminalTemp = Terminal.fromMap(jsonDecode(prefs.getString("terminal")!));

      terminal.language == lang;
      terminalTemp.language = lang;
     GetIt.instance.get<BuildContext>().setLocale(Locale(terminalTemp.language, ''));
   updateLanguage.sink(true);

      prefs.setString("terminal", jsonEncode(terminalTemp.toMap()));
    }
  }
Future<void> _fetchUserPrivilege() async {
  try {
    // Get the logged-in employee
    final LoginServices loginServices = LoginServices();
    final Employee? employee = await loginServices.getEmployee();

    if (employee != null) {
      final privilegesService = PrivielgService();
      final privileges = await privilegesService.getEmployeePrivielges();

      if (privileges != null) {
        for (var privilege in privileges) {
          if (privilege.id == employee.privilegeId) {
            Utilts.userPrivilegeName = privilege.name;

            var addNewPhysicalCountPrivilege = privilege.privileges.firstWhere(
              (p) => p.name == 'addNewPhysicalCounts',
              
            );

            if (addNewPhysicalCountPrivilege != null) {
              Utilts.addNewPhysicalCounts = addNewPhysicalCountPrivilege.value;
            } else {
              Utilts.addNewPhysicalCounts = false; 
            }
             var viewPhysicalCounts = privilege.privileges.firstWhere(
              (p) => p.name == 'viewPhysicalCounts',
              
            );

            if (viewPhysicalCounts != null) {
              Utilts.viewPhysicalCounts = viewPhysicalCounts.value;
            } else {
              Utilts.viewPhysicalCounts = false; 
            }
                       var addNewInventoryTransfer = privilege.privileges.firstWhere(
              (p) => p.name == 'addNewInventoryTransfer',
              
            );

            if (addNewInventoryTransfer != null) {
              Utilts.addNewInventoryTransfer = addNewInventoryTransfer.value;
            } else {
              Utilts.addNewInventoryTransfer = false; 
            }  
            var viewInventoryTransfer = privilege.privileges.firstWhere(
              (p) => p.name == 'viewInventoryTransfer',
              
            );

            if (viewInventoryTransfer != null) {
              Utilts.viewInventoryTransfer = viewInventoryTransfer.value;
            } else {
              Utilts.viewInventoryTransfer = false; 
            }  
//viewPhysicalCounts addNewInventoryTransfer viewInventoryTransfer
            userPrivilegeValue = privilege.privileges.isNotEmpty ? privilege.privileges[0].value : false;
          }
        }
      }
    }
  } catch (e) {
    print('Error fetching user privilege: $e');
  }
  notifyListeners();
}

  @override
  void dispose() {
    super.dispose();
  }
}



