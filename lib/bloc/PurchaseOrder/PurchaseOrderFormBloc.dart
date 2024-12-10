import 'dart:async';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderBloc.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrder.dart';
import 'package:inventory_app/modelss/PurchaseOrder/PurchaseOrderLine.dart';
import 'package:inventory_app/modelss/PurchaseOrderProduct.dart';
import 'package:inventory_app/serviecs/PurchaseOrder.sarvise.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:inventory_app/serviecs/product.services.dart';
import 'package:invo_models/invo_models.dart';

class PurchaseOrderFormBloc {
  DateTime? selectedDate;
  
Property<bool> covareted = Property(false);
  Property<List<Supplier>> suppliers = Property([]);
  Property<bool> search = Property(false);
  Property<List<Tax>> tax = Property([]);
  Property<bool> onTableUpdate = Property(false);
  Property<List<Product>> products = Property([]);
  List<String> allBarcode = [];
  late PurchaseOrder purchaseOrder;
  String selectedsupplier = "";
    Future<String>? selectedsuppliername;
  PurchaseOrderFormBloc() {
    fetchSuppliers(1,"");
    fetchProducts("");
    fetchTax();
    supplierName(selectedsupplier!);
  }
  
  @override
  void dispose() {
    onTableUpdate.dispose();
    suppliers.dispose();
    tax.dispose();
    covareted.dispose();
    search.dispose();
    products.dispose();
  
  }
Future<List<PurchaseOrderProduct>> loadProducts(String supplierId,
    {required int page, required String searchTerm}) async {
  return await PurchaseOrderServies().getPurchaseProducts(
    supplierId, 
    searchTerm: searchTerm, 
    page: page, 
    limit: 15, 
  );
}

  Future<void> fetchProducts(String searchTerm) async {
    try {
      List<Product> fetchedProducts = await ProductService()
          .getBranchProductByBarcodelist(
              page: 1, limit: 15, searchTerm: searchTerm);

      products.sink(fetchedProducts);
      print(products.value.length);
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  searchbutton(BuildContext context) async {
    //fetchProducts();

    print(products.value.length);
    onTableUpdate.sink(true);
    bool currentSearchState = search.value; // Get current state

    search.sink(!currentSearchState);
  }

  factory PurchaseOrderFormBloc.newPO(List<String> allBarcodes , String supplier) {
    PurchaseOrderFormBloc purchaseOrderFormBloc = PurchaseOrderFormBloc();
      purchaseOrderFormBloc.supplierName(supplier);
    purchaseOrderFormBloc.purchaseOrder = PurchaseOrder();
    purchaseOrderFormBloc.allBarcode = allBarcodes;
    purchaseOrderFormBloc.purchaseOrder.branchId = Utilts.branchid;
   purchaseOrderFormBloc.selectedsupplier=supplier;
     purchaseOrderFormBloc.selectedsuppliername =  purchaseOrderFormBloc.supplierName(supplier);
 
   // purchaseOrderFormBloc.selectedsuppliername=supplierName(supplier) ;
    if(allBarcodes.isNotEmpty)
   {purchaseOrderFormBloc.selectedsupplier=supplier;purchaseOrderFormBloc.covareted.sink(false);} 
    else
 purchaseOrderFormBloc.covareted.sink(true);
   purchaseOrderFormBloc.fetchAndAddProductsFromBarcodes();
    return purchaseOrderFormBloc;
  }

  factory PurchaseOrderFormBloc.editPO(PurchaseOrder purchaseOrder) {
    print(purchaseOrder.lines.length);
    PurchaseOrderFormBloc purchaseOrderFormBloc = PurchaseOrderFormBloc();
    purchaseOrderFormBloc.purchaseOrder = purchaseOrder;
    purchaseOrderFormBloc.covareted.sink(true);
    return purchaseOrderFormBloc;
  }

  get purchaseOrderStream => null;

  Future<List<Supplier>> fetchSuppliers(int page ,

   String searchTerm) async {
    
    
  
    return await PurchaseOrderServies().getSupplierMiniList(page: page,limit: 15,searchTerm: searchTerm);
  }

  Future<void> fetchTax() async {
    try {
      tax.sink(await PurchaseOrderServies().getTaxesList());
    } catch (e) {
      // _stateController.add(PurchaseOrderErrorState('Error fetching tax: $e'));
    }
  }
Future<String> supplierName(String id) async {
  try {
    
    List<Supplier> suppliers = await fetchSuppliers(1, "");

  
    Supplier? matchedSupplier = suppliers.firstWhere(
      (supplier) => supplier.id == id,
  
    );

onTableUpdate.sink(true);
    return matchedSupplier?.name ?? 'Supplier Not Found';
  } catch (e) {
    print('Error fetching suppliers: $e');
    return '';
  }
}
  onIncreaseQty(PurchaseOrderLine line) {
    line.increaseQty();
    onTableUpdate.sink(true);
    purchaseOrder.calculateTotal();
//     Utilts.total =line.total;
  }

  onDecreaseQty(PurchaseOrderLine line) {
    line.decreaseQty();
    onTableUpdate.sink(true);
    purchaseOrder.calculateTotal();
  }

  void removeLine(PurchaseOrderLine line) {
    purchaseOrder.lines.remove(line);
    onTableUpdate.sink(true);
    purchaseOrder.calculateTotal();
  }


  Future<bool> savePurchaseOrder(BuildContext context) async {
    List<String> accountIds =
        await PurchaseOrderServies().getPurchaseAccounts();
    String defaultAccountId = accountIds.isNotEmpty ? accountIds[0] : '';

    if (purchaseOrder.id == "") {
      String purchaseNumber =
          await PurchaseOrderServies().getPurchaseNumber() ?? '';
          if(purchaseOrder.supplierId=="") {
            purchaseOrder.supplierId=selectedsupplier;
          }
      purchaseOrder.purchaseNumber = purchaseNumber;
      if (purchaseOrder.purchaseDate != null) {
        DateTime purchaseDate = purchaseOrder.purchaseDate!;
        purchaseOrder.dueDate = DateTime(
            purchaseDate.year, purchaseDate.month + 1, purchaseDate.day);
      }
      for (var element in purchaseOrder.lines) {
        element.accountId = defaultAccountId;
        element.taxId = element.product!.taxId ?? "";
        Tax? matchedTax = tax.value.firstWhere(
          (t) => t.id == element.product!.taxId,
          orElse: () => Tax(id: '', taxPercentage: 0.0, name: '', taxes: []),
        );
        element.taxPercentage = matchedTax?.taxPercentage ?? 0.0;
      }
    } else {
      for (var element in purchaseOrder.lines) {
        element.accountId = defaultAccountId;
      }
    }

    try {
      bool success = await PurchaseOrderServies()
          .savePurchaseOrder(purchaseOrder.toJson());

      if (success) {
        // Display a SnackBar for 3 seconds

        showTopSnackBar(
          Overlay.of(context),
           CustomSnackBar.success(
            message: 'Purchase Order saved successfully!'.tr(),
          ),
        );

        // Navigate to Purchase Order List
        NavigationService(context).goToPurchaseOrderList(PurchaseOrderBloc());
      }
      return success;
    } catch (e) {
      return false;
    }
  }
Future<double?> newUnitcost(String barcode, String supplierId) async{
  double? unitcost =0;
   PurchaseOrderProduct? fetchedProduct = await PurchaseOrderServies()
    .getSinglePurchaseProduct(supplierId, searchTerm: barcode);
       unitcost = fetchedProduct?.supplierCost==0 ?
    fetchedProduct?.productCost
:
   fetchedProduct?.supplierCost;
    purchaseOrder.calculateTotal();
return unitcost;

}
  Future<bool> fetchProduct(
      BuildContext context, String barcode, int quantity , String supplierId,)  async {
    String branchId = Utilts.branchid;
    PurchaseOrderProduct? fetchedProduct = await PurchaseOrderServies()
    .getSinglePurchaseProduct(supplierId, searchTerm: barcode);

    if (fetchedProduct != null) {
      bool barcodeExists = purchaseOrder.lines.any(
          (line) => line.product != null && line.product!.barcode == barcode);
 onTableUpdate.sink(true);
      if (!barcodeExists) {
        
        purchaseOrder.addLine(fetchedProduct, quantity);
        for (var element in purchaseOrder.lines) {
                  element.taxId = element.product!.taxId ?? "";
          Tax? matchedTax = tax.value.firstWhere(
            (t) => t.id == element.product!.taxId,
            orElse: () => Tax(id: '', taxPercentage: 0.0, name: '', taxes: []),
          );
          element.taxPercentage = matchedTax.taxPercentage ?? 0.0; 
           if (element.productId == fetchedProduct.id) 

          {element.qty = quantity;
 element.taxPercentage = matchedTax.taxPercentage ?? 0.0; 
           
           
           
            purchaseOrder.calculateTotal();
          
         }

        }

     
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Row(
            children: [
              Text('Product with this barcode already added.'),
            ],
          )),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Product not found'.tr())),
      );
    }
    return false;
  }

  Future<Product?> fetchProductById(String id) async {
    try {
      Product? fetchedProduct = await ProductService().getProductById(id);

      if (fetchedProduct != null) {
        return fetchedProduct;
      } else {
        print('Product not found for ID: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  // Future<String> fetchProductnameById(String id) async {
  //   try {
  //     Product? fetchedProduct = await ProductService().getProductById(id);

  //     if (fetchedProduct != null) {
  //       return fetchedProduct.name;
  //     } else {
  //       return 'Product not found';
  //     }
  //   } catch (e) {
  //     return 'Error fetching product: $e';
  //   }
  // }

  // Future<String> fetchProductparcodeById(String id) async {
  //   try {
  //     Product? fetchedProduct = await ProductService().getProductById(id);

  //     if (fetchedProduct != null) {
  //       return fetchedProduct.name;
  //     } else {
  //       return 'Product not found';
  //     }
  //   } catch (e) {
  //     return 'Error fetching product: $e';
  //   }
  // }

  Future<void> fetchAndAddProductsFromBarcodes() async {

    for (String barcodeWithQuantity in allBarcode) {
      String barcode =
          barcodeWithQuantity.split(' (Qty: ')[0]; // Get the barcode part

      PurchaseOrderProduct? fetchedProduct = await PurchaseOrderServies()
          .getSinglePurchaseProduct(selectedsupplier, searchTerm: barcode);
      int quantity = int.parse(
          barcodeWithQuantity.split(' (Qty: ')[1].replaceAll(')', ''));
      if (fetchedProduct != null) {
        purchaseOrder.addLine(fetchedProduct, quantity);
 for (var element in purchaseOrder.lines) {
        PurchaseOrderLine newLine = purchaseOrder.lines.last;
        newLine.taxId = fetchedProduct.taxId ?? "";
        Tax? matchedTax = tax.value.firstWhere(
          (t) => t.id == newLine.taxId,
          orElse: () => Tax(id: '', taxPercentage: 0.0, name: '', taxes: []),
        );
        newLine.taxPercentage = matchedTax?.taxPercentage ?? 0.0;
          purchaseOrder.calculateTotal();
         
      }}
    }
    onTableUpdate.sink(true);
  }
}
