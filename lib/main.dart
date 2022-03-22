import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/sign_in_screen.dart';
import 'screens/bottom_nav_bar.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/auth.dart';
import 'providers/objects.dart';
import 'providers/locale.dart';
import 'providers/thresholds.dart';

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
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ProcessStepThresholds()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Demo Mobile APP',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              primarySwatch: Colors.lightBlue,
            ),
            locale: Provider.of<LocaleProvider>(context).locale,
            routes: {
              SignInScreen.routeName: (context) => const SignInScreen(),
              BottomNavBar.routeName: (context) => const BottomNavBar(),
              HomeScreen.routeName: (context) => const HomeScreen(),
              OrdersScreen.routeName: (context) => const OrdersScreen(),
              SettingsScreen.routeName: (context) => const SettingsScreen(),
            },
            home: const SignInScreen(),
          );
        },
      ),
    );
  }
}
