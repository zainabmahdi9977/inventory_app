import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventory_app/dataa/orderdata.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final ValueNotifier<int> valueNotifier = ValueNotifier<int>(1);
  OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFEBEBF3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    order.name,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff45BBCF), // Blue color
                      borderRadius: BorderRadius.circular(8.0), // Rounded edges
                    ),
                    child: Text(
                      order.barcode,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white, // White text color
                      ),
                    ),
                  )
                ]),
                const SizedBox(height: 8.0),
                Row(children: [
                  const Text(
                    'Qty: ',
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: valueNotifier,
                    builder: (context, value, child) {
                      return Text(
                        value.toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  const Text(
                    'Total Cost: ',
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    order.total.toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff45BBCF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //         GestureDetector(
                    //           onTap: () {
                    //             // Decrement the value
                    //             decrementValue();
                    //           },
                    //           child: Container(
                    //  height: 20,width: 20,
                    //             margin: EdgeInsets.all(8),
                    //             color: Colors.white,
                    //             child:
                    //             //  Text(
                    //             //   "-",
                    //             //   style: TextStyle(
                    //             //     color: Colors.black,
                    //             //     fontSize: 24,
                    //             //     fontWeight: FontWeight.bold,
                    //             //   ),
                    //             // ),

                    //           ),
                    //         ),

                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: valueNotifier,
                        builder: (context, value, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))  ,color: Colors.white,),
                              
                                child: Center(
                                  child: value > 1
                                      ? IconButton(
                                          onPressed: decrementValue,
                                          icon: const FaIcon(
                                              FontAwesomeIcons.minus),
                                          iconSize: 15,
                                        )
                                      : SvgPicture.asset(
                                          'assets/Images/trash-bin-trash-svgrepo-com.svg',
                                          color: Colors.red,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),
                              Text(
                                value.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 30,
                                margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))  ,color: Colors.white,),
                              
                                child: Center(
                                  child: IconButton(
                                    onPressed: incrementValue,
                                    icon: const FaIcon(FontAwesomeIcons.plus),
                                    iconSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void decrementValue() {
    valueNotifier.value--;
  }

  void incrementValue() {
    valueNotifier.value++;
  }
}

class PurchaseOrderCard extends StatelessWidget {
  final Order order;
  final ValueNotifier<int> valueNotifier = ValueNotifier<int>(1);
  PurchaseOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFEBEBF3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text(
                    'PO Number: ',
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    order.Bonu.toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
                Row(children: [
                  const Text(
                    'Supplier: ',
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    order.supplier.toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
                Row(
                  children: [
                    const Text(
                      'Total: ',
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "${order.total.toString()} BD",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff45BBCF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            'assets/Images/edit-3-svgrepo-com.svg',
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatListCard extends StatelessWidget {
  final Order order;
  final ValueNotifier<int> valueNotifier = ValueNotifier<int>(1);
  
  CreatListCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFEBEBF3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    order.name,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff45BBCF),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      order.barcode,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                   SizedBox(width: 16),
                  const Text(
                    'Total Cost: ',
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    order.total.toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
             
               
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class PurchaseOrderCard2 extends StatelessWidget {
  final Order order;
  final ValueNotifier<int> valueNotifier = ValueNotifier<int>(1);
  PurchaseOrderCard2({required this.order});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Color(0xFFEBEBF3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
         margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Expanded(
                child: Center(
                  child: Column(
                   
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          const Text(
                            'PO Number: ',
                            style: const TextStyle(
                            //  fontSize: 17,
                            ),
                          ),
                         
                          Text(
                            order.Bonu.toString(),
                            style: const TextStyle(
                             // fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ), SizedBox(width: 8,),
                                             const Text(
                            'Supplier: ',
                            style: const TextStyle(
                          //    fontSize: 17,
                            ),
                          ),
                          Text(
                            order.supplier.toString(),
                            style: const TextStyle(
                        //      fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),SizedBox(width: 8,),
                          const Text(
                              'Total: ',
                              style: const TextStyle(
                             //   fontSize: 17,
                              ),
                            ),
                            Text(
                              "${order.total.toString()} BD",
                              style: const TextStyle(
                             //   fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),]),
                      ),
                            
                           
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                     
                padding: const EdgeInsets.all(0.0),
                child: Center(
                  child: Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xff45BBCF),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  'assets/Images/edit-3-svgrepo-com.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Edit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
