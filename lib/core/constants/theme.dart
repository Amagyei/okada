
import 'package:flutter/material.dart';

// Ghana flag colors
const Color ghanaRed = Color(0xFFCE1126);
const Color ghanaGold = Color(0xFFFCD116);
const Color ghanaGreen = Color(0xFF006B3F);
const Color ghanaBlack = Color(0xFF000000);
const Color ghanaWhite = Color(0xFFFFFFFF);
// Ghana flag color variations
const Color ghanaRedLight = Color(0xFFE14E5F);
const Color ghanaRedDark = Color(0xFFA60D1E);
const Color ghanaGoldLight = Color(0xFFFDDA4F);
const Color ghanaGoldDark = Color(0xFFD9B30E);
const Color ghanaGreenLight = Color(0xFF008C52);
const Color ghanaGreenDark = Color(0xFF004D2D);


// Market theme colors
const Color clayBrown = Color(0xFFD2691E);
const Color basketBeige = Color(0xFFDEB887);
const Color fabricLavender = Color(0xFFE6E6FA);

// Kente colors
const Color kenteYellow = Color(0xFFFFC107);
const Color kenteGreen = Color(0xFF4CAF50);
const Color kenteRed = Color(0xFFF44336);
const Color kenteBlue = Color(0xFF2196F3);

// Text colors
const Color textPrimary = Color(0xFF212121);
const Color textSecondary = Color(0xFF757575);
const Color textHint = Color(0xFFBDBDBD);

final ThemeData okadaTheme = ThemeData(
  primaryColor: ghanaGreen,
  colorScheme: ColorScheme.light(
    primary: ghanaGreen,
    secondary: ghanaGold,
    error: ghanaRed,
    surface: ghanaWhite,
    background: Color(0xFFF5F5F5),
    onPrimary: ghanaWhite,
    onSecondary: ghanaBlack,
    onError: ghanaWhite,
    onSurface: textPrimary,
    onBackground: textPrimary,
  ),
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  appBarTheme: AppBarTheme(
    backgroundColor: ghanaWhite,
    foregroundColor: ghanaBlack,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: ghanaBlack),
    titleTextStyle: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: ghanaBlack,
    ),
  ),
  fontFamily: 'Inter',
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      color: textPrimary,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: ghanaWhite,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ghanaGreen,
      foregroundColor: ghanaWhite,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ghanaGreen,
      side: BorderSide(color: ghanaGreen, width: 1.5),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ghanaWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: textHint, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: textHint, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: ghanaGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: ghanaRed, width: 1),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 2,
    color: ghanaWhite,
  ),
);
