import 'package:flutter/material.dart';

void main() {
  runApp(const DemoMobileApp());
}

class DemoMobileApp extends StatelessWidget {
  const DemoMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Mobile APP',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const HomePage(title: 'Kinexon'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          'Hello Kinexians!',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }
}
