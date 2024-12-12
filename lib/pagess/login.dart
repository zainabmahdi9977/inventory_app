import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/Utlits.dart';
import 'package:inventory_app/bloc/branch.page.bloc.dart';
import 'package:inventory_app/bloc/login.page.bloc.dart';
import 'package:inventory_app/Widgetss/bottomNavigationBar.dart';
import 'package:inventory_app/pagess/branch.dart';
import 'package:inventory_app/serviecs/dialog.service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory_app/main.dart';
import 'package:inventory_app/serviecs/reposiory.services.dart';
import 'package:restart_app/restart_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get_it/get_it.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Repository _repository;
  String error = "";
  LoginPageBloc bloc = LoginPageBloc();
  String currentServer = 'Production';
  final Map<String, String> serverNames = {
    'https://productionback.invopos.co': 'Production',
    'https://testBack.invopos.co': 'Test',
    'https://devBack.invopos.co': 'Development',
    'http://10.2.2.95:3001': 'Local',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
    loadData();
    _loadCurrentServer();

    //var _focusNode = FocusNode();
  }
@override
void dispose() {
  // Dispose of the controllers to free up resources
  emailController.dispose();
  passwordController.dispose();
  super.dispose();
}
  load() async {
    _loadCurrentServer();
    if (await bloc.isTokenValid()) {
      //Navigator.of(context).popAndPushNamed("branch");
                         Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => branchPage(bloc: branchPageBloc(),),
          ),
        );
    }
  }
  Future<bool> loadData() async {
    if (!GetIt.instance.isRegistered<Repository>()) {
      _repository = Repository();
      GetIt.instance.registerSingleton<Repository>(_repository);
      await _repository.load();
    } else {
      _repository = GetIt.instance.get<Repository>();
    }
   
   
    return true;
  }
  Future<void> _loadCurrentServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =prefs.getString('serverURL') ??
     'https://productionback.invopos.co';
    setState(() {
      currentServer = serverNames[url] ?? 'Production';
    });
  }

  Future<void> _changeServerDialog(BuildContext context) async {
    await DialogService().changeServerDialog(context);

    _loadCurrentServer();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return exitApp(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: bottomNavigationBar(
              onPressed: () async {
                if (await bloc.login()) {
                  bloc.errorMsg.value = '';
                   Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => branchPage(bloc: branchPageBloc(),),
          ),
        );
       // Navigator.of(context).pushNamed('branch');
                  setState(() {});
                }
              },
              label: 'Log in'.tr()),
   
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xffEBEBF3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SvgPicture.asset(
                            'assets/Images/image.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/Images/Group 7.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                //    const SizedBox(height: 20.0),
          Expanded(
  flex: 7,
  child: Container(
    padding: const EdgeInsets.all(25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (Localizations.localeOf(context).toString() == "en") {
                  context.setLocale(Locale('ar'));
                  Utilts.updateLanguage.sink(true);
                } else if (Localizations.localeOf(context).toString() == "ar") {
                  context.setLocale(Locale('en'));
                  Utilts.updateLanguage.sink(true);
                }
              },
              child: Text(
                "english".tr(),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        _emailTextField(),
        const SizedBox(height: 5.0),
        _passwordTextField(),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _changeServerDialog(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(10, 10),
                fixedSize: const Size(10, 10),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: Text(
                currentServer,
                style: const TextStyle(color: Colors.transparent),
              ),
            ),
            _forgetPasswordText(),
          ],
        ),
        const SizedBox(height: 5.0),
        StreamBuilder(
          stream: bloc.errorMsg.stream,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                bloc.errorMsg.value,
                style: const TextStyle(
                  color: Colors.red, // Set the text color to red
                ),
              ),
            );
          },
        ),
      ],
    ),
  ),
)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return _textField(
      "Email".tr(),
      controller: emailController,
      onFieldSubmitted: (value) async {
        bloc.email = value;
      },
      onChanged: (value) {
        bloc.email = value;
      },
      validator: MultiValidator(
        [
          RequiredValidator(errorText: '     Enter email address'.tr()),
          EmailValidator(errorText: '     Please correct email filled'.tr()),
        ],
      ).call,
    );
  }

  Widget _passwordTextField() {
    return _textField(
      'Password'.tr(),
      obscureText: true,
      onChanged: (value) {
        bloc.password = value;
      },
      controller: passwordController,
      validator: MultiValidator(
        [
          RequiredValidator(errorText: 'Please enter Password'.tr()),
          MinLengthValidator(6, errorText: 'Password must be atlist 6 digit'.tr()),
          // PatternValidator(r'(?=.*?[#!@$%^&*-])',
          // errorText:
          //     'Password must be atlist one special character')
        ],
      ).call,
      // onPressed: () {
      //   setState(() {
      //     _passwordVisible = !_passwordVisible;
      //   });
      // },
    );
  }

  Widget _textField(
    String labelText, {
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Stack(
      children: <Widget>[
        Container(
          height: 80.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.grey,
            ),
          ),
          child: TextFormField(       
            controller: controller,
            onChanged: onChanged,

            onFieldSubmitted: onFieldSubmitted,
            validator: validator,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 20.0,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.fromLTRB(50, 10, 50, 0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Text(
              labelText,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgetPasswordText() {
    return Container(
      alignment: Alignment.bottomRight,
      child:  Text(
        'Forget Password?'.tr(),
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
 
}
