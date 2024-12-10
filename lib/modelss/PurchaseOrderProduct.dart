import 'dart:convert';

import 'package:invo_models/invo_models.dart';
import 'package:invo_models/models/ProductPackage.dart';

class PurchaseOrderProduct {
  String id;
  String parentId;
  String name;
  String translation;
  String barcode;
  String sku = "";
  double onHand = 0;
  double price = 0;
  String color = "";
  String description = "";

  String defaultImage = "";

  String type;
  String warning = "";
  String UOM = "";

  double unitCost = 0;
  double productCost = 0;
  double supplierCost = 0;
    int minimumOrder = 0;
  int serviceTime = 0;

  bool available = true;
  bool isDeleted = false;
  String selectedPricingType =
      ""; //["priceByQty","buyDownPrice","priceBoundary","openPrice", ""]
  double priceBoundriesFrom = 0;
  double priceBoundriesTo = 0;
  double buyDownPrice = 0;
  int buyDownQty = 0;
  int buyDownQtyTemp = 0; //hold the buy donw qty

  List<PriceByQty> priceByQty = [];
  List<ProductBarcode> barcodes = [];

  double commissionAmount = 0;
  bool commissionPercentage = false;

  String? taxId;

  bool orderByWeight = false;
  bool discountable = true;
  ProductPriceModel? priceModel;
  List<QuickOptions> quickOptions = [];
  List<ProductOptionGroup> optionGroups = [];
  List<ProductPackage> package = [];
  List<ProductSelection> selection = [];
  List<ProductBatch> batches = [];
  List<ProductSerial> serials = [];
  List<ProductEmployeePrice> employeePrices = [];
  String? categoryId;
  Category? category;
  int maxItemPerTicket = 0;
  List<String> alternativeProducts = [];
  List<ExcludedOption> excludedOptions = [];
  String kitchenName = "";
  ProductMeasurement? measurements;
  List<ProductCustomField> customFields = [];
  String? brandid;
  DateTime? notAvailableOnlineUntil;


  get kitchenNameText {
    if (kitchenName.isNotEmpty) {
      return kitchenName;
    }
    return name;
  }

  double get stock {
    switch (type) {
      case "serialized":
        double temp = 0;
        for (var serial in serials) {
          if (serial.status == "Available") temp++;
        }
        return temp;
      case "batch":
        double temp = 0;
        for (var productBatch in batches) {
          temp += productBatch.onHand;
        }
        return temp;
      default:
        return onHand;
    }
  }

  bool isSelected = false;
  PurchaseOrderProduct(
      {required this.id,
      required this.name,
      this.translation = "{}",
      this.parentId = "",
      this.barcode = "",
      this.sku = "",
      this.onHand = 0,
      this.price = 0,
      this.description = "",
      required this.type,
      this.warning = "",
      this.UOM = "",
      /**  double productCost = 0;
  double supplierCost = 0;
    int minimumOrder = 0; */
      this.unitCost = 0,
      this.supplierCost = 0,
      this.productCost = 0,
      this.minimumOrder = 0,
      this.defaultImage = "",
      this.serviceTime = 0,
      this.color = "",
      this.available = true,
      this.isDeleted = false,
      this.selectedPricingType = "",
      this.priceBoundriesFrom = 0,
      this.priceBoundriesTo = 0,
      this.buyDownPrice = 0,
      this.buyDownQty = 0,
      this.commissionAmount = 0,
      this.commissionPercentage = false,
      this.discountable = true,
      this.orderByWeight = false,
      this.taxId,
      this.priceModel,
      required this.quickOptions,
      required this.optionGroups,
      required this.package,
      required this.selection,
      required this.batches,
      required this.serials,
      required this.priceByQty,
      required this.barcodes,
      required this.employeePrices,
      required this.customFields,
      this.categoryId,
      this.brandid,
      this.maxItemPerTicket = 0,
      required this.alternativeProducts,
      required this.excludedOptions,
      this.measurements,
      this.kitchenName = "",
      this.notAvailableOnlineUntil});

  String getTranslatedName(String lang) {
    try {
      String temp = "";
      if (translation != "") {
        Map translationObject = jsonDecode(translation);
        if (translationObject.containsKey("name")) {
          Map nameMap = translationObject["name"];
          if (nameMap.containsKey(lang)) {
            temp = translationObject["name"][lang];
          }
        }
      }
      if (temp.isEmpty) {
        return name;
      }
      return temp;
    } catch (e) {
      return name;
    }
  }

  Map<String, Object?> toFullMap() {
    Map<String, Object?> map = toMap();
    if (category != null) {
      map['category'] = category!.toMap();
    }
    return map;
  }

  factory PurchaseOrderProduct.fromFullMap(Map<String, dynamic> map) {
    PurchaseOrderProduct product = PurchaseOrderProduct.fromMap(map);

    if (map['category'] != null) {
      product.category = Category.fromMap(map['category']);
    }
    return product;
  }

  factory PurchaseOrderProduct.fromJson(Map<String, dynamic> json) {
    List<QuickOptions> options = [];
    if (json['quickOptions'] != null) {
      for (var element in json['quickOptions']) {
        options.add(QuickOptions(element));
      }
    }

    List<ProductOptionGroup> _optionGroups = [];
    if (json['optionGroups'] != null) {
      for (var element in json['optionGroups']) {
        _optionGroups.add(ProductOptionGroup.fromJson(element));
      }
    }

    List<ProductPackage> _package = [];
    if (json['package'] != null) {
      for (var element in json['package']) {
        _package.add(ProductPackage.fromJson(element));
      }
    }

    List<ProductSelection> _selection = [];
    if (json['selection'] != null) {
      for (var element in json['selection']) {
        _selection.add(ProductSelection.fromJson(element));
      }
    }

    List<ProductBatch> _batches = [];
    if (json['batches'] != null) {
      for (var element in json['batches']) {
        _batches.add(ProductBatch.fromJson(element));
      }
    }

    List<ProductSerial> _serials = [];
    if (json['serials'] != null) {
      for (var element in json['serials']) {
        if (element['serial'] != null)
          _serials.add(ProductSerial.fromJson(element));
      }
    }

    List<ProductBarcode> barcodes = [];
    if (json['barcodes'] != null) {
      for (var element in json['barcodes']) {
        barcodes.add(ProductBarcode.fromMap(element));
      }
    }

    List<PriceByQty> priceByQtys = [];
    if (json['priceByQty'] != null) {
      for (var element in json['priceByQty']) {
        priceByQtys.add(PriceByQty.fromMap(element));
      }
    }

    List<ProductEmployeePrice> _employeePrices = [];
    if (json['employeePrices'] != null) {
      for (var element in json['employeePrices']) {
        _employeePrices.add(ProductEmployeePrice.fromMap(element));
      }
    }

    String translation = "";
    if (json['translation'] != null) {
      translation = jsonEncode(json['translation']);
    }

    ProductPriceModel? _priceModel = null;
    if (json['priceModel'] != null) {
      _priceModel = ProductPriceModel.fromMap(json['priceModel']);
    }

    List<String> alternativeProducts = [];
    if (json['alternativeProducts'] != null) {
      for (var element in json['alternativeProducts']) {
        alternativeProducts.add(element);
      }
    }

    List<ExcludedOption> _excludedOptions = [];

    if (json['excludedOptions'] != null) {
      try {
        for (var element in json['excludedOptions']) {
          _excludedOptions.add(ExcludedOption.fromJson(element));
        }
      } catch (e) {}
    }

    List<ProductCustomField> _customFields = [];

    if (json['customFields'] != null) {
      try {
        for (var element in json['customFields']) {
          if (element['value'] != null) {
            _customFields.add(ProductCustomField.fromJson(element));
          }
        }
      } catch (e) {}
    }

    double _price = json['price'] == null
        ? (json['defaultPrice'] == null
            ? 0
            : double.parse(json['defaultPrice'].toString()))
        : double.parse(json['price'].toString());

    return PurchaseOrderProduct(
        id: json['id'],
        name: json['name'] ?? "",
        parentId: json['parentId'] ?? "",
        translation: translation,
        barcode: json['barcode'] ?? "",
        sku: json['sku'] ?? "",
        onHand: json['onHand'] == null
            ? 0
            : double.parse(json['onHand'].toString()),
        //price: double.parse((json['price'] ?? json['defaultPrice']).toString()),
        price: _price,
        description: json['description'] ?? "",
        type: json['type'].toString(),
        warning: json['warning'] ?? "",
        UOM: json['UOM'] ?? "",
        defaultImage: json['defaultImage'] ?? "",
        color: json['color'] ?? "#313512",
        commissionAmount: json['commissionAmount'] == null
            ? 0
            : double.parse(json['commissionAmount'].toString()),
        commissionPercentage: json['commissionPercentage'] ?? false,
        available: json['available'] ?? false,
        isDeleted: json['isDeleted'] ?? false,
        discountable: json['discountable'] ?? false,
        orderByWeight: json['orderByWeight'] ?? false,
        selectedPricingType: json['selectedPricingType'] ?? "",
        priceModel: _priceModel,
        priceBoundriesFrom: json['priceBoundriesFrom'] == null
            ? 0
            : double.parse(json['priceBoundriesFrom'].toString()),
        priceBoundriesTo: json['priceBoundriesTo'] == null
            ? 0
            : double.parse(json['priceBoundriesTo'].toString()),
        buyDownPrice: json['buyDownPrice'] == null
            ? 0
            : double.parse(json['buyDownPrice'].toString()),
        buyDownQty: json['buyDownQty'] == null
            ? 0
            : int.parse(json['buyDownQty'].toString()),
        taxId: json['taxId'],
        quickOptions: options,
        optionGroups: _optionGroups,
        package: _package,
        selection: _selection,
        batches: _batches,
        serials: _serials,
        barcodes: barcodes,
        priceByQty: priceByQtys,
        employeePrices: _employeePrices,
        unitCost: json['unitCost'] == null
            ? 0
            : double.parse(json['unitCost'].toString()),
                  /**  double productCost = 0;
  double supplierCost = 0;
    int minimumOrder = 0; */
            productCost: json['productCost'] == null
            ? 0
            : double.parse(json['productCost'].toString()),
            supplierCost: json['supplierCost'] == null
            ? 0
            : double.parse(json['supplierCost'].toString()),
             minimumOrder: json['serviceTime'] ?? 0,
        serviceTime: json['serviceTime'] ?? 0,
        categoryId: json['categoryId'],
        brandid: json['brandid'],
        kitchenName: json['kitchenName'] ?? "",
        maxItemPerTicket: json['maxItemPerTicket'] != null
            ? int.parse(json['maxItemPerTicket'].toString())
            : 0,
        alternativeProducts: alternativeProducts,
        excludedOptions: _excludedOptions,
        measurements: json['measurements'] == null
            ? null
            : ProductMeasurement.fromJson(json['measurements']),
        customFields: _customFields,
        notAvailableOnlineUntil: json['notAvailableOnlineUntil'] != null
            ? DateTime.parse(json['notAvailableOnlineUntil'])
            : null);
  }

  factory PurchaseOrderProduct.newFromId(String id) {
    return PurchaseOrderProduct(
        id: id,
        name: "",
        type: "",
        quickOptions: [],
        optionGroups: [],
        package: [],
        selection: [],
        batches: [],
        serials: [],
        barcodes: [],
        priceByQty: [],
        employeePrices: [],
        categoryId: '',
        brandid: '',
        maxItemPerTicket: 0,
        alternativeProducts: [],
        excludedOptions: [],
        customFields: []);
  }

  factory PurchaseOrderProduct.newFromName(String name) {
    return PurchaseOrderProduct(
        id: "",
        name: name,
        type: "",
        quickOptions: [],
        optionGroups: [],
        package: [],
        selection: [],
        batches: [],
        serials: [],
        barcodes: [],
        priceByQty: [],
        employeePrices: [],
        categoryId: '',
        brandid: '',
        maxItemPerTicket: 0,
        alternativeProducts: [],
        excludedOptions: [],
        customFields: []);
  }

  Map<String, dynamic> toMap({bool noImage = false}) {
    List<Map<String, dynamic>> options = [];
    for (var element in quickOptions) {
      options.add(element.toMap());
    }

    List<Map<String, dynamic>> _optionGroups = [];
    for (var element in optionGroups) {
      _optionGroups.add(element.toMap());
    }

    List<Map<String, dynamic>> _package = [];
    for (var element in package) {
      _package.add(element.toMap());
    }

    List<Map<String, dynamic>> _selection = [];
    for (var element in selection) {
      _selection.add(element.toMap());
    }

    List<Map<String, dynamic>> _batches = [];
    for (var element in batches) {
      _batches.add(element.toMap());
    }

    List<Map<String, dynamic>> _serials = [];
    for (var element in serials) {
      _serials.add(element.toMap());
    }

    List<Map<String, dynamic>> _barcodes = [];
    for (var element in barcodes) {
      _barcodes.add(element.toMap());
    }

    List<Map<String, dynamic>> _priceByQty = [];
    for (var element in priceByQty) {
      _priceByQty.add(element.toMap());
    }

    List<Map<String, dynamic>> _employeePrices = [];
    for (var element in employeePrices) {
      _employeePrices.add(element.toMap());
    }

    List<Map<String, Object?>> customFieldsMap = [];
    for (var element in customFields) {
      customFieldsMap.add(element.toMap());
    }

    List<Map<String, Object?>> _excludedOptions = [];
    for (var element in excludedOptions) {
      _excludedOptions.add(element.toMap());
    }

    String image = "";
    if (!noImage) {
      image = defaultImage;
    }
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'translation': translation,
      'parentId': parentId,
      'barcode': barcode,
      'sku': sku,
      'onHand': onHand,
      'color': color,
      'price': price,
      'description': description,
      'type': type,
      'warning': warning,
      'UOM': UOM,
      'defaultImage': image,
      'commissionAmount': commissionAmount,
      'commissionPercentage': commissionPercentage ? 1 : 0,
      'available': available ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'selectedPricingType': selectedPricingType,
      'priceBoundriesFrom': priceBoundriesFrom,
      'priceBoundriesTo': priceBoundriesTo,
      'buyDownPrice': buyDownPrice,
      'buyDownQty': buyDownQty,
      'discountable': discountable ? 1 : 0,
      'orderByWeight': orderByWeight ? 1 : 0,
      'taxId': taxId,
      'priceModel':
          priceModel == null ? null : json.encode(priceModel!.toMap()),
      'quickOptions': json.encode(options),
      'optionGroups': json.encode(_optionGroups),
      'package': json.encode(_package),
      'selection': json.encode(_selection),
      'batches': json.encode(_batches),
      'serials': json.encode(_serials),
      'barcodes': json.encode(_barcodes),
      'priceByQty': json.encode(_priceByQty),
      'employeePrices': json.encode(_employeePrices),
      'unitCost': unitCost,
                        /**  double productCost = 0;
  double supplierCost = 0;
    int minimumOrder = 0; */
      'serviceTime': serviceTime,
      'productCost':productCost,
      'supplierCost':supplierCost,
      'minimumOrder':minimumOrder,
      'categoryId': categoryId,
      'brandid': brandid,
      'kitchenName': kitchenName,
      'maxItemPerTicket': maxItemPerTicket ?? 0,
      'alternativeProducts': json.encode(alternativeProducts),
      'excludedOptions': json.encode(_excludedOptions),
      "measurements":
          measurements == null ? null : json.encode(measurements?.toMap()),
      'customFields': json.encode(customFieldsMap),
      'notAvailableOnlineUntil': notAvailableOnlineUntil != null
          ? notAvailableOnlineUntil!.millisecondsSinceEpoch
          : null,
    };
    return map;
  }

  factory PurchaseOrderProduct.fromMap(Map<String, dynamic> map) {
    List<QuickOptions> _options = [];
    if (map['quickOptions'] != null) {
      dynamic products = json.decode(map['quickOptions']);
      for (var element in products) {
        _options.add(QuickOptions.fromMap(element));
      }
    }

    List<ProductOptionGroup> _optionGroups = [];
    if (map['optionGroups'] != null) {
      dynamic groups = json.decode(map['optionGroups']);
      for (var element in groups) {
        _optionGroups.add(ProductOptionGroup.fromMap(element));
      }
    }

    List<ProductPackage> _package = [];
    if (map['package'] != null) {
      dynamic packages = json.decode(map['package']);
      for (var element in packages) {
        _package.add(ProductPackage.fromMap(element));
      }
    }

    List<ProductSelection> _selection = [];
    if (map['selection'] != null) {
      dynamic selections = json.decode(map['selection']);
      for (var element in selections) {
        _selection.add(ProductSelection.fromMap(element));
      }
    }

    List<ProductBatch> _batches = [];
    if (map['batches'] != null) {
      dynamic batches = json.decode(map['batches']);
      for (var element in batches) {
        _batches.add(ProductBatch.fromMap(element));
      }
    }

    List<ProductSerial> _serials = [];
    if (map['serials'] != null) {
      dynamic serials = json.decode(map['serials']);
      for (var element in serials) {
        _serials.add(ProductSerial.fromMap(element));
      }
    }

    List<ProductBarcode> _barcodes = [];
    if (map['barcodes'] != null) {
      dynamic barcodes = json.decode(map['barcodes']);
      for (var element in barcodes) {
        _barcodes.add(ProductBarcode.fromMap(element));
      }
    }

    List<PriceByQty> _priceByQtys = [];
    if (map['priceByQty'] != null) {
      dynamic priceByQtys = json.decode(map['priceByQty']);
      for (var element in priceByQtys) {
        _priceByQtys.add(PriceByQty.fromMap(element));
      }
    }

    List<ProductEmployeePrice> _employeePrices = [];
    if (map['employeePrices'] != null) {
      dynamic employeePrices = json.decode(map['employeePrices']);
      for (var element in employeePrices) {
        _employeePrices.add(ProductEmployeePrice.fromMap(element));
      }
    }

    String translation = "";
    if (map['translation'] != null) {
      translation = map['translation'];
    }

    ProductPriceModel? _priceModel = null;
    if (map['priceModel'] != null) {
      _priceModel = ProductPriceModel.fromMap(json.decode(map['priceModel']));
    }

    List<String> alternativeProducts = [];
    if (map['alternativeProducts'] != null) {
      dynamic _alternativeProducts = json.decode(map['alternativeProducts']);
      for (var element in _alternativeProducts) {
        alternativeProducts.add(element);
      }
    }

    List<ExcludedOption> _excludedOptions = [];
    if (map['excludedOptions'] != null) {
      dynamic excludedOptions = json.decode(map['excludedOptions']);
      for (var element in excludedOptions) {
        _excludedOptions.add(ExcludedOption.fromMap(element));
      }
    }

    //  List<CustomField> customFields = [];
    // if (map['customFields'] != null) {
    //   dynamic _customFields = json.decode(map['customFields']);
    //   for (var element in _customFields) {
    //     customFields.add(element);
    //   }
    // }

    List<ProductCustomField> customFields = [];
    if (map['customFields'] != null) {
      for (var element in json.decode(map['customFields'])) {
        customFields.add(ProductCustomField.fromMap(element));
      }
    }

    return PurchaseOrderProduct(
        id: map['id'],
        name: map['name'] ?? "",
        translation: translation,
        parentId: map['parentId'] ?? "",
        barcode: map['barcode'] ?? "",
        sku: map['sku'] ?? "",
        onHand: map['onHand'],
        price: map['price'],
        description: map['description'],
        type: map['type'],
        warning: map['warning'],
        UOM: map['UOM'],
        priceModel: _priceModel,
        color: map['color'] ?? "#313512",
        defaultImage: map['defaultImage'] ?? "",
        commissionAmount: map['commissionAmount'] ?? 0,
        commissionPercentage: map['commissionPercentage'] == 1 ? true : false,
        available: map['available'] == 1 ? true : false,
        isDeleted: map['isDeleted'] == 1 ? true : false,
        discountable: map['discountable'] == 1 ? true : false,
        orderByWeight: map['orderByWeight'] == 1 ? true : false,
        selectedPricingType: map['selectedPricingType'] ?? "",
        priceBoundriesFrom: map['priceBoundriesFrom'] ?? 0,
        priceBoundriesTo: map['priceBoundriesTo'] ?? 0,
        buyDownPrice: map['buyDownPrice'] ?? 0,
        buyDownQty: map['buyDownQty'] ?? 0,
        taxId: map['taxId'],
        quickOptions: _options,
        optionGroups: _optionGroups,
        package: _package,
        selection: _selection,
        batches: _batches,
        serials: _serials,
        barcodes: _barcodes,
        priceByQty: _priceByQtys,
        employeePrices: _employeePrices,
        unitCost: map['unitCost'],
        productCost: map['productCost'],
        supplierCost: map['supplierCost'],
        minimumOrder: map['minimumOrder'],

                               /**  double productCost = 0;
  double supplierCost = 0;
    int minimumOrder = 0; */
    
        serviceTime: map['serviceTime'],
        categoryId: map['categoryId'],
        brandid: map['brandid'],
        kitchenName: map['kitchenName'] ?? "",
        maxItemPerTicket: map['maxItemPerTicket'] ?? 0,
        alternativeProducts: alternativeProducts,
        excludedOptions: _excludedOptions,
        measurements: map['measurements'] == null
            ? null
            : ProductMeasurement.fromMap(json.decode(map['measurements'])),
        customFields: customFields,
        notAvailableOnlineUntil: map['notAvailableOnlineUntil'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                map['notAvailableOnlineUntil'])
            : null);
  }
}

class QuickOptions {
  String id = "";
  QuickOptions(this.id);

  factory QuickOptions.fromMap(Map<String, dynamic> json) {
    return QuickOptions(json['id']);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
    };
    return map;
  }
}

class PriceByQty {
  int qty;
  double price;

  PriceByQty(this.qty, this.price);

  factory PriceByQty.fromMap(Map<String, dynamic> json) {
    return PriceByQty(json['qty'], double.parse(json['price'].toString()));
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'qty': qty,
      'price': price,
    };
    return map;
  }
}

class ProductBarcode {
  String barcode = "";
  ProductBarcode(this.barcode);

  factory ProductBarcode.fromMap(Map<String, dynamic> json) {
    return ProductBarcode(json['barcode']);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'barcode': barcode,
    };
    return map;
  }
}

class ProductEmployeePrice {
  String employeeId;
  double price;
  int serviceTime;

  ProductEmployeePrice(this.employeeId, this.price, this.serviceTime);

  factory ProductEmployeePrice.fromMap(Map<String, dynamic> json) {
    return ProductEmployeePrice(
      json['employeeId'],
      double.parse(json['price'].toString()),
      int.parse(json['serviceTime'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'employeeId': employeeId,
      'price': price,
      'serviceTime': serviceTime,
    };
    return map;
  }
}

class ProductPriceModel {
  String model;
  double discount;

  ProductPriceModel(this.model, this.discount);

  factory ProductPriceModel.fromMap(Map<String, dynamic> json) {
    return ProductPriceModel(
      json['model'],
      json['discount'] == null ? 0 : double.parse(json['discount'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'model': model,
      'discount': discount,
    };
    return map;
  }
}

class ProductMeasurement {
  bool shoulder = false;
  bool acrossShoulder = false;
  bool ankle = false;
  bool armholeGrith = false;
  bool bodyHeight = false;
  bool bustGrith = false;
  bool frontShoulderToWaist = false;
  bool hipGrith = false;
  bool insideLeg = false;
  bool napeOfNeckToWaist = false;
  bool outsteam = false;
  bool sleeve = false;
  bool thigh = false;
  bool upperarmGrith = false;
  bool waistGrith = false;
  bool wristGrith = false;

  ProductMeasurement(
    this.shoulder,
    this.acrossShoulder,
    this.ankle,
    this.armholeGrith,
    this.bodyHeight,
    this.bustGrith,
    this.frontShoulderToWaist,
    this.hipGrith,
    this.insideLeg,
    this.napeOfNeckToWaist,
    this.outsteam,
    this.sleeve,
    this.thigh,
    this.upperarmGrith,
    this.waistGrith,
    this.wristGrith,
  );

  factory ProductMeasurement.fromMap(Map<String, dynamic> json) {
    return ProductMeasurement(
      json['shoulder'] == 1 ? true : false,
      json['acrossShoulder'] == 1 ? true : false,
      json['ankle'] == 1 ? true : false,
      json['armholeGrith'] == 1 ? true : false,
      json['bodyHeight'] == 1 ? true : false,
      json['bustGrith'] == 1 ? true : false,
      json['frontShoulderToWaist'] == 1 ? true : false,
      json['hipGrith'] == 1 ? true : false,
      json['insideLeg'] == 1 ? true : false,
      json['napeOfNeckToWaist'] == 1 ? true : false,
      json['outsteam'] == 1 ? true : false,
      json['sleeve'] == 1 ? true : false,
      json['thigh'] == 1 ? true : false,
      json['upperarmGrith'] == 1 ? true : false,
      json['waistGrith'] == 1 ? true : false,
      json['wristGrith'] == 1 ? true : false,
    );
  }

  factory ProductMeasurement.fromJson(Map<String, dynamic> json) {
    return ProductMeasurement(
      json['shoulder'] ?? false,
      json['acrossShoulder'] ?? false,
      json['ankle'] ?? false,
      json['armholeGrith'] ?? false,
      json['bodyHeight'] ?? false,
      json['bustGrith'] ?? false,
      json['frontShoulderToWaist'] ?? false,
      json['hipGrith'] ?? false,
      json['insideLeg'] ?? false,
      json['napeOfNeckToWaist'] ?? false,
      json['outsteam'] ?? false,
      json['sleeve'] ?? false,
      json['thigh'] ?? false,
      json['upperarmGrith'] ?? false,
      json['waistGrith'] ?? false,
      json['wristGrith'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'shoulder': shoulder ? 1 : 0,
      'acrossShoulder': acrossShoulder ? 1 : 0,
      'ankle': ankle ? 1 : 0,
      'armholeGrith': armholeGrith ? 1 : 0,
      'bodyHeight': bodyHeight ? 1 : 0,
      'bustGrith': bustGrith ? 1 : 0,
      'frontShoulderToWaist': frontShoulderToWaist ? 1 : 0,
      'hipGrith': hipGrith ? 1 : 0,
      'insideLeg': insideLeg ? 1 : 0,
      'napeOfNeckToWaist': napeOfNeckToWaist ? 1 : 0,
      'outsteam': outsteam ? 1 : 0,
      'sleeve': sleeve ? 1 : 0,
      'thigh': thigh ? 1 : 0,
      'upperarmGrith': upperarmGrith ? 1 : 0,
      'waistGrith': waistGrith ? 1 : 0,
      'wristGrith': wristGrith ? 1 : 0,
    };
    return map;
  }
}

class ProductCustomField {
  String id;
  String value;

  ProductCustomField(this.id, this.value);

  factory ProductCustomField.fromMap(Map<String, dynamic> map) {
    return ProductCustomField(map['id'], map['value']);
  }

  factory ProductCustomField.fromJson(Map<String, dynamic> json) {
    return ProductCustomField(json['id'], json['value']);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'value': value,
    };
    return map;
  }
}

class ExcludedOption {
  String optionId;
  DateTime? pauseUntil;

  ExcludedOption(this.optionId, this.pauseUntil);

  factory ExcludedOption.fromMap(Map<String, dynamic> map) {
    return ExcludedOption(
      map['optionId'],
      map['pauseUntil'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['pauseUntil'])
          : null,
    );
  }

  factory ExcludedOption.fromJson(Map<String, dynamic> json) {
    return ExcludedOption(json['optionId'],
        json['pauseUntil'] != null ? DateTime.parse(json['pauseUntil']) : null);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'optionId': optionId,
      'pauseUntil':
          pauseUntil == null ? null : pauseUntil!.millisecondsSinceEpoch,
    };
    return map;
  }
}
