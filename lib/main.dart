import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/objects_screen.dart';
import 'screens/signin_screen.dart';
import 'providers/auth.dart';
import 'providers/objects.dart';

void main() {
  runApp(const DemoMobileApp());
}

class DemoMobileApp extends StatelessWidget {
  const DemoMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => Objects()),
      ],
      child: MaterialApp(
        title: 'Demo Mobile APP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        routes: {
          SigninScreen.routeName: (context) => const SigninScreen(),
          ObjectsScreen.routeName: (context) => const ObjectsScreen(),
        },
        home: const SigninScreen(),
      ),
    );
  }
}
