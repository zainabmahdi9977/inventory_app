import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:inventory_app/serviecs/reposiory.services.dart';
import 'package:invo_5_widget/invo_5_widget.dart';

import 'package:resize/resize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogService {
  static BuildContext? mainContext;
  Map<String, String>? serverNames = {
    'https://productionback.invopos.co': 'Production',
    'https://testBack.invopos.co': 'Test',
    'https://devBack.invopos.co': 'Development',
    'http://10.2.2.95:3001': 'Local',
  };

  void dispose() {}

  hideLoading() {
    if (isLoading) Navigator.of(mainContext!).pop();
  }

  bool isLoading = false;
  showLoading() async {
    isLoading = true;
    await showDialog<void>(
        context: mainContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Material(
              color:
                  Colors.transparent, // can change this to your prefered color
              child: Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.r))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 15.h),
                      Text(
                        "Loading",
                        style: TextStyle(fontSize: 20.sp, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ));
        });

    isLoading = false;
  }

  Future<bool?> alertDialog(String title, String msg) async {
    if (mainContext == null) return false;
    await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 300.h,
                width: 350.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        msg,
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(238, 238, 238, 1),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            OptionButton(
                              "OK".tr(),
                              lineHeight: 1.2,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 20.w),
                              fontSize: 20.sp,
                              style: "primary",
                              onTap: () async {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                if (msg ==
                                        'Connection failure or server error'
                                            .tr() ||
                                    title == "Connection failure".tr()) {
                                  await prefs.remove('token');
                                  //GetIt.instance.unregister<NavigationService>();
                                  GetIt.instance.unregister<Repository>();

                                  // Navigate to the login page
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context)
                                      .popAndPushNamed("Login");
                                } else {
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pop(true);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });
    return true;
  }

  Future<void> changeServerDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Server'),
            content: SingleChildScrollView(
              child: ListBody(
                children: serverNames!.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value),
                    onTap: () async {
                      Navigator.of(context).pop();

                      prefs.setString("serverURL", entry.key);
                      // await _switchServer(entry.key);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        });
  }
}
