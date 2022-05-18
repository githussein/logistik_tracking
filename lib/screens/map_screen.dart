import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../providers/auth.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

final Completer<WebViewController> _completer = Completer<WebViewController>();

class _MapScreenState extends State<MapScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    var basicAuthHeader = Provider.of<Auth>(context).authHeader;
    _completer.future.then((controller) {
      _controller = controller;

      _controller.loadUrl(
          Uri.encodeFull('http://mohamed-hussein.base.knx/riot/embed/map?location=5,3'),
          headers: basicAuthHeader);
    });

    return Scaffold(
      appBar: const CustomAppBar(screenTitle: 'Karte'),
      body: SafeArea(
        child: WebView(
          debuggingEnabled: true,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) async {
            _completer.complete(controller);
          },
        ),
      ),
    );
  }
}
