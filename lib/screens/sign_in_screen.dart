import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../widgets/feedback_container_widget.dart';
import '../services/user_secure_storage.dart';
import '../providers/locale.dart';
import '../providers/auth.dart';
import 'bottom_nav_bar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  static const routeName = '/sign-in';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final usernameController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');
  var targetBackendUrlController = TextEditingController(text: '');
  bool _isError = false;
  bool _isLoading = false;
  bool _isAuthenticating = true;
  String _errorMessage = '';

  @override
  void didChangeDependencies() async {
    final storedLocale =
        await Provider.of<LocaleProvider>(context, listen: false).getLocale();
    await Provider.of<LocaleProvider>(context, listen: false)
        .setLocale(storedLocale);

    await checkAuthLocally();
    setState(() => _isAuthenticating = false);

    super.didChangeDependencies();
  }

  Future checkAuthLocally() async {
    final username = await UserSecureStorage.readUsername() ?? '';
    final password = await UserSecureStorage.readPassword() ?? '';
    final targetUrl = await UserSecureStorage.readTargetUrl() ?? '';

    targetBackendUrlController.text = targetUrl;

    if (username != '' && password != '' && targetUrl != '') {
      Provider.of<Auth>(context, listen: false)
          .saveAuthData(targetUrl, username, password);
      await Navigator.of(context).pushReplacementNamed(BottomNavBar.routeName);
    }
  }

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
                    title: Text(AppLocalizations.of(context)!.targetUrl),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isError)
                          FeedbackContainer(
                              errorMessage: AppLocalizations.of(context)!
                                  .errorInvalidBackendUrl),
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
                                content: Text(
                                    '${targetBackendUrlController.text} \n${AppLocalizations.of(context)!.baseUrlUpdated}.'),
                              ),
                            );

                            Navigator.pop(context);
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
            icon: const Icon(Icons.link),
            color: Colors.white70,
          ),
        ],
      ),
      body: Center(
        child: _isAuthenticating
            ? const CircularProgressIndicator()
            : Card(
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
                              AppLocalizations.of(context)!.signIn,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).primaryColorDark),
                            ),
                    ),
                    if (_isError)
                      FeedbackContainer(errorMessage: _errorMessage),
                    _lineDivider,
                    TextFormField(
                      controller: usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.username,
                          suffixIcon: const Icon(Icons.person),
                          border: InputBorder.none,
                          fillColor: const Color(0xfff3f3f3),
                          filled: true),
                    ),
                    _lineDivider,
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                          suffixIcon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          fillColor: const Color(0xfff3f3f3),
                          filled: true),
                    ),
                    ListTile(
                      onTap: () async => await _onSignInTap(context),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      tileColor: Theme.of(context).primaryColorDark,
                      title: Text(
                        AppLocalizations.of(context)!.signIn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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

  Future<void> _onSignInTap(BuildContext context) async {
    if (targetBackendUrlController.text == '') {
      _errorMessage = AppLocalizations.of(context)!.errorEmptyTargetUrl;
    } else {
      setState(() => _isLoading = true);

      try {
        final statusCode = await Provider.of<Auth>(context, listen: false)
            .signIn(targetBackendUrlController.text, usernameController.text,
                passwordController.text);

        if (statusCode == 200) {
          _errorMessage = '';
          await UserSecureStorage.storeUsername(usernameController.text);
          await UserSecureStorage.storePassword(passwordController.text);
          await UserSecureStorage.storeTargetUrl(
              targetBackendUrlController.text);
          Navigator.of(context).pushReplacementNamed(BottomNavBar.routeName);
        } else if (statusCode == 401) {
          _errorMessage = AppLocalizations.of(context)!.errorInvalidCredentials;
        } else if (statusCode == 404) {
          _errorMessage = AppLocalizations.of(context)!.errorInvalidPath;
        }
      } catch (error) {
        _errorMessage = AppLocalizations.of(context)!.errorInvalidBackendUrl;
      }
    }

    setState(() {
      _isError = _errorMessage != '';
      _isLoading = false;
    });
  }
}
