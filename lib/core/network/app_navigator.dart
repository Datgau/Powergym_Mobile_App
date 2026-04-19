import 'package:flutter/material.dart';

/// Global navigator key — dùng để navigate từ ngoài widget tree (vd: Dio interceptor).
class AppNavigator {
  AppNavigator._();
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static void goToLogin() {
    key.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  static void goToHome() {
    key.currentState?.pushNamedAndRemoveUntil('/home', (_) => false);
  }
}
