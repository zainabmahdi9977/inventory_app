import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/pagess/homepage.dart';
import 'package:inventory_app/main.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[200],
      leadingWidth: 100,
      leading: Center(
        child: GestureDetector(
          onTap: () {
            // NavigationService(context).goBackToHomePage();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(branchName: Utilts.branchName),
              ),
            );
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
                left:
                    Localizations.localeOf(context).toString() == "en" ? 0 : 24,
                right: Localizations.localeOf(context).toString() == "en"
                    ? 24
                    : 0),
            child: SvgPicture.asset(
              'assets/Images/gear-alt-svgrepo-com.svg',
            ),
          ),
        ),
      ],
      title: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
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
            child:       GestureDetector(
            
                          onTap: () {
                            logoutUser(context);
                          },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                 Expanded(
                    
                          child: Text(
                            "LogOut".tr(),
                            style: TextStyle(fontSize: 18),
                          )
                    ),
                  
                ],
              ),
            ),
          ),
          PopupMenuItem(
           
            child:   StreamBuilder(
                      stream: Utilts.updateLanguage.stream,
                    
                    
                      builder: (context, snapshot)  {
                  return GestureDetector(
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
             
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.language),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                                "english".tr(),
                                style: TextStyle(fontSize: 18),
                              ),
                        ),
                      ],
                    ),
                  );
                }
              ),
           
          ),

        ],
      );

}
