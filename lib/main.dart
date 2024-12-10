import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/bloc/branch.page.bloc.dart';
import 'package:inventory_app/modelss/creatlist/CreateListlineMod.dart';
import 'package:inventory_app/pagess/branch.dart';
import 'package:inventory_app/serviecs/connection.services.dart';
import 'package:inventory_app/serviecs/dialog.service.dart';
import 'package:inventory_app/pagess/homepage.dart';
import 'package:inventory_app/pagess/login.dart';
import 'package:inventory_app/serviecs/login_provider.dart';
import 'package:inventory_app/serviecs/naviagtion.service.dart';
import 'package:inventory_app/serviecs/routenotifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  debugPaintSizeEnabled = false;
  HttpOverrides.global = MyHttpOverrides();
  GetIt.instance.registerLazySingleton<DialogService>(() => DialogService());

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final connectivityService = ConnectivityService();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  
  String? ordersString = prefs.getString('enteredOrders');
  if (ordersString != null) {
   
    final jsonResponse = json.decode(ordersString);
    if (jsonResponse is List) {
      Utilts.enteredOrders = jsonResponse.map((json) => CreateListlineMod.fromJson(json)).toList();
    } else {
      
      print('Error: Expected a list but got a map or other type.');
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/i18n', // Change the path of the translation files
      startLocale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
          ChangeNotifierProvider(create: (_) => ConnectivityNotifier(connectivityService)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  Future<String> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Utilts.branchName = prefs.getString("branchName") ?? ''; // Use null-aware operator
    Utilts.branchid = prefs.getString("branchid") ?? ''; // Use null-aware operator
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
Utilts.createList=prefs.getString('enteredOrders')??"[]";
    // Load entered orders again if necessary
    String? ordersString = prefs.getString('enteredOrders');
    if (ordersString != null) {
      final jsonResponse = json.decode(ordersString);
      if (jsonResponse is List) {
        Utilts.enteredOrders = jsonResponse.map((json) => CreateListlineMod.fromJson(json)).toList();
      }
    }

    return (isLoggedIn && Utilts.branchName.isNotEmpty) ? "home" : "login";
  }

  @override
  State<MyApp> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  final RouteNotifier routeNotifier = RouteNotifier();

  @override
  Widget build(BuildContext context) {
    if (!GetIt.instance.isRegistered<NavigationService>()) {
      GetIt.instance.registerSingleton<NavigationService>(NavigationService(context));
    } else {
      GetIt.instance.get<NavigationService>().context = context;
    }
    DialogService.mainContext = context;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: '',
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff45BBCF)),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<String>(
        future: widget.isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == "login") {
            return  LoginPage();
          } else {
            return HomePage(branchName: Utilts.branchName);
          }
        },
      ),
      routes: {
        'login': (context) {
          routeNotifier.updateRoute('login');
          return const LoginPage();
        },
        'branch': (context) {
          routeNotifier.updateRoute('branch');
          return branchPage(bloc: branchPageBloc(),);
        },
      },
    );
  }
}

// Logout function
Future<void> logoutUser(BuildContext context) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('branchName');
    await prefs.remove('branchid');
 await prefs.remove('enteredOrders');

await prefs.remove("serverURL");
 Utilts.createList="[]";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  
  } catch (e) {
    print('Logout error: $e'); // Handle error if needed
  }
}

// Exit app confirmation
Future<bool> exitApp(BuildContext context) async {
  if (Navigator.of(context).userGestureInProgress) {
    return false;
  } else {
    bool exitConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);

              Navigator.of(context).popUntil((route) => route.isFirst);
              SystemNavigator.pop();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (exitConfirmed == true) {
      // Delay the exit slightly to ensure the navigation stack is properly handled
      Future.delayed(Duration(milliseconds: 100), () {
        Navigator.of(context).pop();
      });
    }

    return exitConfirmed;
  }
}