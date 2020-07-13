import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/pages/HomePage.dart';
import 'package:salarymanager/providers/EmployeeProvider.dart';
import 'package:salarymanager/providers/LoginProvider.dart';
import 'package:salarymanager/providers/UserDataProvider.dart';
import 'package:salarymanager/providers/WorkProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseAuth.instance.onAuthStateChanged.listen((user) {
    print(user?.uid);
    if (user == null)
      LoginProvider().signIn().then((value) => runApp(MyApp()));
    else {
      LoginProvider().user = user;
      return runApp(RestartWidget(child: MyApp()));
    }
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserDataProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primaryColor: Colors.deepPurple,
            accentColor: Colors.deepPurple,
            cursorColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            )),
        home: HomePage(),
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}