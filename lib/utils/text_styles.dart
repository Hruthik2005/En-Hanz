import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class AppTextStyles {
  // Get the font size multiplier from settings
  static double getFontMultiplier(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return appState.settings.fontSizeMultiplier;
  }

  // Scaled TextStyles
  static TextStyle headline1(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 32 * getFontMultiplier(context),
      fontWeight: FontWeight.bold,
      color: color ?? Colors.black87,
    );
  }

  static TextStyle headline2(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 24 * getFontMultiplier(context),
      fontWeight: FontWeight.bold,
      color: color ?? Colors.black87,
    );
  }

  static TextStyle headline3(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 20 * getFontMultiplier(context),
      fontWeight: FontWeight.w600,
      color: color ?? Colors.black87,
    );
  }

  static TextStyle bodyLarge(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 18 * getFontMultiplier(context),
      color: color ?? Colors.black87,
    );
  }

  static TextStyle bodyMedium(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 16 * getFontMultiplier(context),
      color: color ?? Colors.black87,
    );
  }

  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 14 * getFontMultiplier(context),
      color: color ?? Colors.black87,
    );
  }

  static TextStyle caption(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 12 * getFontMultiplier(context),
      color: color ?? Colors.grey[600],
    );
  }

  static TextStyle button(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 16 * getFontMultiplier(context),
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white,
    );
  }
}
