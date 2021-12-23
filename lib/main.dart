import 'package:flutter/material.dart';
import 'screens/signin_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth.dart';

void main() {
  runApp(const DemoMobileApp());
}

class DemoMobileApp extends StatelessWidget {
  const DemoMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Auth(),
      child: MaterialApp(
        title: 'Demo Mobile APP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        home: const SigninScreen(),
      ),
    );
  }
}
