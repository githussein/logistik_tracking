import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'map_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  static const routeName = '/bottom-nav-bar';

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String _currentPage = 'Orders';
  int _selectedIndex = 0;

  List<String> pageKeys = ['Orders', 'Map', 'Settings'];

  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    'Orders': GlobalKey<NavigatorState>(),
    'Map': GlobalKey<NavigatorState>(),
    'Settings': GlobalKey<NavigatorState>(),
  };

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> _items = [
      BottomNavigationBarItem(
        icon: const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: FaIcon(FontAwesomeIcons.box),
        ),
        label: AppLocalizations.of(context)!.orders,
      ),
       BottomNavigationBarItem(
        icon: const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: FaIcon(FontAwesomeIcons.map),
        ),
        label: AppLocalizations.of(context)!.map,
      ),
      BottomNavigationBarItem(
        icon: const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: FaIcon(FontAwesomeIcons.cog),
        ),
        label: AppLocalizations.of(context)!.settings,
      ),
    ];
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != 'Orders') {
            _selectTab('Orders', 0);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator('Orders'),
            _buildOffstageNavigator('Map'),
            _buildOffstageNavigator('Settings'),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: _items,
          currentIndex: _selectedIndex,
          onTap: (int index) => _selectTab(pageKeys[index], index),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  const TabNavigator(
      {Key? key, required this.navigatorKey, required this.tabItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = const OrdersScreen();

    if (tabItem == 'Map') {
      child = const MapScreen();
    } else if (tabItem == 'Settings') {
      child = const SettingsScreen();
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
