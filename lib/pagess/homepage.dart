import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/bloc/creatlist/CreateListBloc.dart';
import 'package:inventory_app/bloc/creatlist/CreateListViewBloc.dart';
import 'package:inventory_app/bloc/PhysicalCount/PhysicalCountListBloc.dart';
import 'package:inventory_app/bloc/TransferOut/TransferOutListBloc.dart';
import 'package:inventory_app/Widgetss/customappbar.dart';
import 'package:inventory_app/bloc/PurchaseOrder/PurchaseOrderBloc.dart';
import 'package:inventory_app/bloc/home.bloc.dart';
import 'package:inventory_app/main.dart';
import 'package:inventory_app/pagess/CreateList/CreateList.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';

class HomePage extends StatefulWidget {
  final String branchName;
  HomePage({Key? key, required this.branchName}) : super(key: key);
  Homebloc bloc = Homebloc();
  @override
  _HomePageState createState() => _HomePageState();
}

  openDialog(context) => showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            Localizations.localeOf(context).toString() == "en" ? 280 : 10,
            75,
            Localizations.localeOf(context).toString() == "en" ? 10 : 280,
            0),
        items: [
          PopupMenuItem(
            value: "Logout",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.logout),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                      onTap: () {
                        logoutUser(context);
                      },
                      child: Text(
                        "LogOut".tr(),
                        style: TextStyle(fontSize: 18),
                      )),
                ),
              ],
            ),
          ),
          PopupMenuItem(
           
            child: StreamBuilder(
                    stream: Utilts.updateLanguage.stream,
                  
                  
                    builder: (context, snapshot)  {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.language),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                                                  if ((Localizations.localeOf(context).toString() ==
                                        "en")) {
                                      context.setLocale(Locale('ar'));
                                      Utilts.updateLanguage.sink(true);
                                    } else if ((Localizations.localeOf(context)
                                            .toString() ==
                                        "ar")) {
                                      context.setLocale(Locale('en'));
                                      Utilts.updateLanguage.sink(true);
                                    }
                                   Navigator.pop(context);  
                          },
                          child: Text(
                            "english".tr(),
                            style: TextStyle(fontSize: 18),
                          )),
                    ),
                  ],
                );
              }
            ),
          ),

        ],
      );

class _HomePageState extends State<HomePage> {
  void initState() {
    super.initState();
    widget.bloc = Homebloc(); // Initialize your bloc or any resources here
  }

  @override
  void dispose() {
    widget.bloc.dispose(); // Dispose of the bloc or any controllers here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return exitApp(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          leadingWidth: 100,
          leading: Center(
            child: GestureDetector(
              onTap: () {
                // NavigationService(context).goBackToHomePage();

                //      Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => HomePage(branchName:  Utilts.branchName),
                //   ),
                // );
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Localizations.localeOf(context).toString() == "en"
                          ? 24
                          : 0,
                      right: Localizations.localeOf(context).toString() == "en"
                          ? 0
                          : 24),
                  child: Image.asset(
                    'assets/Images/Group 7.png',
                  ),
                ),
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                openDialog(context);
              },
              child: Container(
                padding: EdgeInsets.only(
                    left: Localizations.localeOf(context).toString() == "en"
                        ? 0
                        : 24,
                    right: Localizations.localeOf(context).toString() == "en"
                        ? 24
                        : 0),
                child: SvgPicture.asset(
                  'assets/Images/gear-alt-svgrepo-com.svg',
                ),
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Your branch is '.tr(), style: TextStyle(fontSize: 20)),
                Text(" ${Utilts.branchName}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            Text('Choose an action'.tr(), style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildactionsButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateListViewPage(
                            bloc: CreateListViewBloc(),
                          ),
                        ));
                    //NavigationService(context).goToCreateListBloc(CreateListBloc());
                    ///
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => CreateList(bloc: CreateListBloc(),),
                    //   ),
                    // );
                  },
                  label: 'Create\nList'.tr(),
                ),
                const SizedBox(width: 16.0),
                _buildactionsButton(
                  onPressed: () {
                    NavigationService(context)
                        .goToPurchaseOrderList(PurchaseOrderBloc());

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         PurchaseOrderList(bloc: PurchaseOrderBloc()),
                    //   ),
                    // );
                  },
                  label: 'Purchase\nOrder'.tr(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              //PhysicalCount
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildactionsButton(
                  label: 'Physical\nCount'.tr(),
                  onPressed: () {
                    if (Utilts.viewPhysicalCounts)
                      NavigationService(context)
                          .goToPhysicalCountList(PhysicalCountListBloc());
                    else
                      _showNotAllowedDialog(context);
                  },
                ),
                const SizedBox(width: 16.0),
                _buildactionsButton(
                  label: 'Transfer\nOut'.tr(),
                  onPressed: () {
                    if (Utilts.viewInventoryTransfer)
                      NavigationService(context)
                          .goToTransferOutList(TransferOutListBloc());
                    else
                      _showNotAllowedDialog(context);
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>  TransferOutList(bloc: TransferOutListBloc(),),
                    //   ),
                    // );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotAllowedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Access Denied".tr()),
          content: Text("You are not allowed to perform this action.".tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK".tr()),
            ),
          ],
        );
      },
    );
  }

// Usage

  Widget _buildactionsButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
        backgroundColor: MaterialStateProperty.all(const Color(0xffEBEBF3)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        minimumSize: MaterialStateProperty.all(const Size(150.0, 100.0)),
        // Add the following properties
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color(
                  0xff45BBCF); // Set the background color when clicked
            }
            return null; // Use the default background color
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white; // Set the text color when clicked
            }
            return Colors.black; // Use the default text color
          },
        ),
        shadowColor:
            MaterialStateProperty.all(Colors.transparent), // Remove the shadow
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
