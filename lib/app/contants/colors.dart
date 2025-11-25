import 'package:flutter/material.dart';

const appPurple = Color(0xFF431AA1);
const appPurpleDark = Color(0xFF1E0771);
const appPurpleLight1 = Color(0xFF9345F2);
const appPurpleLight2 = Color(0xFFB9A2D8);
const appWhite = Colors.white;
const appOrange = Color(0xFFE6704A);

ThemeData themeLight = ThemeData(
  brightness: Brightness.light,
  primaryColor: appPurple,
  scaffoldBackgroundColor: appWhite,
  appBarTheme: const AppBarTheme(
    elevation: 4,
    backgroundColor: appPurple,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: appWhite, fontSize: 22),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.black)),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: appPurpleDark),
    bodyLarge: TextStyle(color: appPurpleDark),
    bodySmall: TextStyle(color: appPurpleDark),
  ),
  cardTheme: const CardThemeData(color: appPurpleLight2),
  listTileTheme: ListTileThemeData(textColor: appPurpleDark),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(appPurpleDark),
      foregroundColor: WidgetStatePropertyAll(appWhite),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
  ),
);

ThemeData themeDark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: appPurpleLight2,
  scaffoldBackgroundColor: appPurpleDark,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: appPurpleDark,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: appWhite, fontSize: 22),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: appWhite),
    bodyLarge: TextStyle(color: appWhite),
    bodySmall: TextStyle(color: appWhite),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white)),
  ),
  listTileTheme: ListTileThemeData(textColor: appWhite),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(appWhite),
      foregroundColor: WidgetStatePropertyAll(appPurpleDark),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
  ),
);
