import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Brightness;
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor que se encargá de manejar el tema de la aplicación.
class ThemeProvider with ChangeNotifier {
  bool? isLightTheme;

  ThemeProvider({this.isLightTheme});

  /// Retorna el tema actual de la aplicación.
  ThemeData get getThemeData => isLightTheme! ? lightTheme : darkTheme;

  /// Actualiza el tema de la aplicación de manera asíncrona.
  /// Además guarda la preferencia del usuario respecto al tema.
  Future<void> setThemeDataAsync(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLightTheme', value);
    isLightTheme = value;
    notifyListeners();
  }

  //  Actualiza el tema de la aplicación de manera síncrona.
  set setThemeDataSync(bool value) {
    isLightTheme = value;
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  colorScheme: colorSchemeLight,
  primaryColor: colorSchemeLight.primary,
  errorColor: colorSchemeLight.error,
  backgroundColor: colorSchemeLight.background,
  accentColor: colorSchemeLight.primary,
  brightness: colorSchemeLight.brightness,
  buttonColor: colorSchemeLight.primary,
  appBarTheme: appBarThemeLight,
  inputDecorationTheme: inputDecorationThemeLight,
  iconTheme: iconThemeDataLight,
  textButtonTheme: textButtonTheme,
  elevatedButtonTheme: elevatedButtonTheme,
);

final darkTheme = ThemeData(
  colorScheme: colorSchemeDark,
  primaryColor: colorSchemeDark.primary,
  errorColor: colorSchemeDark.error,
  backgroundColor: colorSchemeDark.background,
  accentColor: colorSchemeDark.primary,
  brightness: colorSchemeDark.brightness,
  buttonColor: colorSchemeDark.primary,
  appBarTheme: appBarThemeDark,
  inputDecorationTheme: inputDecorationThemeDark,
  iconTheme: iconThemeDataDark,
  textButtonTheme: textButtonTheme,
  elevatedButtonTheme: elevatedButtonTheme,
);

final appBarThemeLight = AppBarTheme(
  color: Colors.transparent,
  elevation: 0.0,
  iconTheme: iconThemeDataLight,
);

final appBarThemeDark = AppBarTheme(
  color: Colors.transparent,
  elevation: 0.0,
  iconTheme: iconThemeDataDark,
);

final iconThemeDataLight = IconThemeData(
  color: colorSchemeLight.primary,
);

final iconThemeDataDark = IconThemeData(
  color: Colors.white,
);

final inputDecorationThemeLight = InputDecorationTheme(
  hoverColor: colorSchemeLight.primary,
  border: OutlineInputBorder(
    borderSide: BorderSide(color: colorSchemeLight.primary),
  ),
);

final inputDecorationThemeDark = InputDecorationTheme(
  hoverColor: colorSchemeDark.primary,
  border: OutlineInputBorder(
    borderSide: BorderSide(color: colorSchemeDark.primary),
  ),
);

final textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
  ),
);

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    elevation: 8.0,
  ),
);

final colorSchemeLight = ColorScheme(
  primary: const Color(0xFF6B06C4),
  primaryVariant: const Color(0xFF6B06C4),
  secondary: Colors.black,
  secondaryVariant: Colors.black,
  surface: Colors.grey[300]!,
  background: Colors.grey[300]!,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.black,
  brightness: Brightness.light,
);

final colorSchemeDark = ColorScheme(
  primary: const Color(0xFF9B38FF),
  primaryVariant: const Color(0xFF9B38FF),
  secondary: Colors.black,
  secondaryVariant: Colors.black,
  surface: Colors.grey[900]!,
  background: Colors.grey[900]!,
  error: Colors.red,
  onPrimary: Colors.grey[300]!,
  onSecondary: Colors.grey[300]!,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.black,
  brightness: Brightness.dark,
);
