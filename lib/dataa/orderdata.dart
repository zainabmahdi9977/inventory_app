import 'package:flutter/cupertino.dart';

class orderdata extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

// ignore: non_constant_identifier_names
class orderss {
  List<Order> Orderss = [
    Order(
        name: "chicken Felet",
        qty: 1,
        total: 10.0,
        barcode: "12345678",
        status: 'Open',
        Bonu: '5432',
        supplier: 'flan'),
    Order(
        name: "chicken Felet",
        qty: 1,
        total: 10.0,
        barcode: "12345557",
        status: 'Closed',
        Bonu: '5412',
        supplier: 'flan'),
    Order(
        name: "chicken Felet",
        qty: 1,
        total: 10.0,
        barcode: "12345855",
        status: 'Open',
        Bonu: '5322',
        supplier: 'flan'),
    Order(
        name: "chicken Felet",
        qty: 1,
        total: 10.0,
        barcode: "12311459",
        status: 'Closed',
        Bonu: '5429',
        supplier: 'flan'),
    Order(
        name: "chicken Felet",
        qty: 1,
        total: 10.0,
        barcode: "12344450",
        status: 'Open',
        Bonu: '2222',
        supplier: 'flan'),
    Order(
        name: "chicken Felet",
        qty: 1,
        total: 10.0,
        barcode: "12346556",
        status: 'Closed',
        Bonu: '5432',
        supplier: 'flan'),
  ];

  static where(bool Function(dynamic order) param0) {}
}

class Order {
  final String name;
  final int qty;
  final double total;
  final String barcode;
  final String status;
  final String Bonu;
  final String supplier;
  Order({
    required this.status,
    required this.name,
    required this.qty,
    required this.total,
    required this.barcode,
    required this.Bonu,
    required this.supplier,
  });
}
