// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/bloc/branch.page.bloc.dart';
import 'package:inventory_app/modelss/branch.models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inventory_app/serviecs/connection.services.dart';
import 'package:inventory_app/pagess/homepage.dart';
import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/main.dart';

import 'package:invo_models/models/Employee.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class branchPage extends StatefulWidget {
  final branchPageBloc bloc;
  const branchPage({super.key, required this.bloc});

  @override
  State<branchPage> createState() => _branchPageState();
}

class BranchProvider extends ChangeNotifier {
  String _branchName = '';

  String get branchName => _branchName;

  void setBranchName(String name) {
    _branchName = name;
    notifyListeners();
  }
}

class _branchPageState extends State<branchPage> with WidgetsBindingObserver {

  int selectedBranchIndex = -1;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    loading();
  }

  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.bloc.dispose();
    super.dispose();
  }

  bool loadingComplete = false;
  loading() async {
    await widget.bloc.loadData();
    if (mounted) {
      setState(() {
        loadingComplete = true;
      });
    }
  }
openDialog(context) => showMenu(
  context: context,
  position: const RelativeRect.fromLTRB(280, 75, 10, 0),
  items: [
    PopupMenuItem(
      value: 'logout',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.logout),
          SizedBox(width: 8),
        GestureDetector(
          onTap: () {
          logoutUser(context);
          },
          child:  Text("LogOut".tr(), style: TextStyle(fontSize: 18),)),
        ],
      ),
    ),
 
  ],
);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Check connectivity when the app resumes
      final connectivityNotifier =
          Provider.of<ConnectivityNotifier>(context, listen: false);
      connectivityNotifier.connectivityService.checkInitialConnectivity();
    }
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
          leadingWidth: 80,
          leading: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
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
          child:  Container(
      padding: EdgeInsets.only(right: 24),
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
            FutureBuilder<Employee?>(
              future: LoginServices().getEmployee(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  final employee = snapshot.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(' Hello '.tr(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(employee.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  );
                } else {
                  return  Text('User'.tr());
                }
              },
            ),
             Text('Choose a Branch'.tr(), style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16.0),
            StreamBuilder(
                stream: widget.bloc.branches.stream,
                builder: (context, snapshot) {
                  if (widget.bloc.branches.value.isNotEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          widget.bloc.branches.value.asMap().entries.map((entry) {
                        return Column(
                          children: [
                            _buildBranchListContainer(
                                context, entry.key, entry.value),
                            SizedBox(height: 16.0),
                          ],
                        );
                      }).toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                })
          ],
        ),
      ),
    );
  }

  bool selectedBranch = false;

  Widget _buildBranchListContainer(
      BuildContext context, int index, Branch branch) {
    return GestureDetector(
      onTap: () {
        getbranchName();
        Utilts.branchName = branch.name;
        Utilts.branchid = branch.id;
        setState(() {
          selectedBranchIndex = index;
        });
      // NavigationService(context).goBackToHomePage();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(branchName: Utilts.branchName),
          ),
        );
      },
      child: Container(
        width: 280.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: selectedBranchIndex == index
              ? const Color(0xff45BBCF)
              : const Color(0xffEBEBF3),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            branch.name,
            style: TextStyle(
              fontSize: 20.0,
              color: selectedBranchIndex == index ? Colors.white : Colors.black,
              fontWeight: selectedBranchIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  getbranchName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("branchName", Utilts.branchName);
    await prefs.setString("branchid", Utilts.branchid);
  }
}
