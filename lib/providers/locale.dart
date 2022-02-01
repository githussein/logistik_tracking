import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale.fromSubtags();

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;

    //Save selected language locally
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('languageCode', locale.languageCode);

    //Update app UI
    notifyListeners();
  }

  Future<Locale> getLocale() async {
    //Retrieve stored language preference
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode =
        _prefs.getString('languageCode') ?? ui.window.locale.languageCode;
    return Locale(languageCode);
  }
}
