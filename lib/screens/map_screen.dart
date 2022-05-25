import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/auth.dart';
import '../widgets/feedback_container_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

final Completer<WebViewController> _completer = Completer<WebViewController>();

class _MapScreenState extends State<MapScreen> {
  late WebViewController _controller;
  var targetBackendUrlController = TextEditingController(text: '');
  bool _isLoading = false;
  bool _isError = false;
  bool _isMapUrlSet = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    var basicAuthHeader = Provider.of<Auth>(context).authHeader;
    _completer.future.then((controller) {
      _controller = controller;
    });

    void update(){
      setState(() => _isMapUrlSet = true);
      _controller.loadUrl(targetBackendUrlController.text,
          headers: basicAuthHeader);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        title: Text(
          AppLocalizations.of(context)!.map,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            color: Colors.white70,
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.targetUrl),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isError)
                          FeedbackContainer(
                              errorMessage: AppLocalizations.of(context)!
                                  .errorInvalidBackendUrl),
                        TextFormField(
                          // minLines: 2,
                          maxLines: 3,
                          controller: targetBackendUrlController,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f3),
                              filled: true),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(AppLocalizations.of(context)!.updateLink),
                        onPressed: () async {
                          _isError = false;
                          setState(() => _isLoading = true);

                          try {
                            await Provider.of<Auth>(context, listen: false)
                                .validateTargetBackend(
                                    targetBackendUrlController.text);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green.shade400,
                                content: Text(
                                    '"${targetBackendUrlController.text}"\n${AppLocalizations.of(context)!.baseUrlUpdated}.'),
                              ),
                            );

                            Navigator.pop(context);
                            update();
                          } catch (error) {
                            _errorMessage = AppLocalizations.of(context)!
                                .errorInvalidBackendUrl;
                            setState(() => _isError = true);
                          }
                          setState(() => _isLoading = false);
                        },
                      ),
                    ],
                  );
                });
              },
            ),
          ),
        ],
      ),
      body: _isMapUrlSet
          ? WebView(
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) async {
                _completer.complete(controller);
              },
            )
          : Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image: const AssetImage('assets/images/nomap.png'),
                        color: Theme.of(context).primaryColor),
                    const SizedBox(height: 20),
                    const Text('Karten-URL ist noch nicht eingestelt.',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 16,
                    ),),
                  ],
                ),
            ),
          ),
    );
  }
}
