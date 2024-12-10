// ignore_for_file: non_constant_identifier_names
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrder.dart';
import 'package:inventory_app/modelss/branch.models.dart';
import 'package:inventory_app/serviecs/PurchaseOrder.sarvise.dart';
import 'package:inventory_app/serviecs/branch.services.dart';
import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/serviecs/privielg.services.dart';
import 'package:invo_models/invo_models.dart';




class Repository {
  late String token;
  List<Branch> branches = [];
List<Supplier> suppliers = [];
List<PurchaseOrder> closePurchaseOrder = [];
List<PurchaseOrder> openPurchaseOrder= [];
List<Tax> tax = [];
List<EmployeePrivilege> privileges = [];
  Repository() {
    loadToken();
  }

  loadToken() async {
    token = (await LoginServices().getToken()) ?? '';
  }

  Future<void> load() async {
    try {
            branches = (await BranchService().getBranchList());
            privileges = (await PrivielgService().getEmployeePrivielges())!;
            suppliers = (await PurchaseOrderServies().getSupplierMiniList());
            closePurchaseOrder=(await PurchaseOrderServies().getClosedPurchaseOrderList());
            openPurchaseOrder=(await PurchaseOrderServies().getOpenPurchaseOrderList());
            tax=(await PurchaseOrderServies().getTaxesList());
     
    } catch (e) {
    //  GetIt.instance.get<DialogService>().alertDialog("Error".tr(), "Connection failure or server error".tr());
      return;
    }
  }
}
