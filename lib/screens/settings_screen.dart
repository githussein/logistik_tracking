import 'package:demo_mobile_app/services/user_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/locale.dart';
import '../providers/auth.dart';
import '../widgets/custom_app_bar_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(screenTitle: AppLocalizations.of(context)!.settings),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [FaIcon(FontAwesomeIcons.user, size: 26)],
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.username,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    Provider.of<Auth>(context).username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 3),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                AppLocalizations.of(context)!.switchLanguage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                if (Localizations.localeOf(context) == const Locale('de')) {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale.fromSubtags(languageCode: 'en'));
                } else {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale.fromSubtags(languageCode: 'de'));
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                AppLocalizations.of(context)!.signOut,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                UserSecureStorage.deleteCredentials();
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> route) => false);
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
