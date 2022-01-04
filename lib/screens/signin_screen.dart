import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/feedback_container_widget.dart';
import '../providers/auth.dart';
import 'objects_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  static const routeName = '/sign-in';

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final usernameController = TextEditingController(text: 'kinexon');
  final passwordController = TextEditingController(text: 'kinexon');
  final targetBackendUrlController =
      TextEditingController(text: 'http://mohamed-hussein.base.knx');
  bool _isError = false;
  bool _isLoading = false;
  static const errorInvalidCredentials = 'Invalid username or password';
  static const errorInvalidBackendUrl = 'Server could not be reached';
  static const errorInvalidPath = 'Could not connect to the server';
  String _errorMessage = '';

  final Divider _lineDivider =
      Divider(color: Colors.grey.shade300, height: 1, thickness: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        title: const Image(image: AssetImage('assets/images/logo.png')),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                _isError = false;
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Target backend URL'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isError)
                          const FeedbackContainer(
                              errorMessage: errorInvalidBackendUrl),
                        TextFormField(
                          maxLines: 2,
                          controller: targetBackendUrlController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f3),
                              filled: true),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Update link'),
                        onPressed: () async {
                          _isError = false;
                          setState(() => _isLoading = true);
                          try {
                            await Provider.of<Auth>(context, listen: false)
                                .validateTargetBackend(
                                    targetBackendUrlController.text);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${targetBackendUrlController.text} \nis now being used.'),
                              ),
                            );

                            Navigator.pop(context);
                          } catch (error) {
                            _errorMessage = errorInvalidBackendUrl;
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
            icon: const Icon(Icons.link),
            color: Colors.white70,
          ),
        ],
      ),
      body: Center(
        child: Card(
          elevation: 16,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Sign in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColorDark),
                      ),
              ),
              if (_isError) FeedbackContainer(errorMessage: _errorMessage),
              _lineDivider,
              TextFormField(
                controller: usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Username',
                    suffixIcon: Icon(Icons.person),
                    border: InputBorder.none,
                    fillColor: Color(0xfff3f3f3),
                    filled: true),
              ),
              _lineDivider,
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password',
                    suffixIcon: Icon(Icons.lock),
                    border: InputBorder.none,
                    fillColor: Color(0xfff3f3f3),
                    filled: true),
              ),
              ListTile(
                onTap: () async => await _onSigninTap(context),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                tileColor: Theme.of(context).primaryColorDark,
                title: const Text(
                  'Sign in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSigninTap(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final statusCode = await Provider.of<Auth>(context, listen: false).signIn(
          targetBackendUrlController.text,
          usernameController.text,
          passwordController.text);

      if (statusCode == 200) {
        _errorMessage = '';
        Navigator.of(context).pushNamed(ObjectsScreen.routeName);
      } else if (statusCode == 401) {
        _errorMessage = errorInvalidCredentials;
      } else if (statusCode == 404) {
        _errorMessage = errorInvalidPath;
      }
    } catch (error) {
      _errorMessage = errorInvalidBackendUrl;
    }

    setState(() {
      _isError = _errorMessage != '';
      _isLoading = false;
    });
  }
}
