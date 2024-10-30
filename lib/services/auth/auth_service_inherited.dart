import 'package:flutter/material.dart';
import 'auth_service.dart'; // Make sure to import your AuthService

class AuthServiceInherited extends InheritedWidget {
  final AuthService authService;

  const AuthServiceInherited({
    super.key,
    required this.authService,
    required super.child,
  });

  static AuthServiceInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthServiceInherited>();
  }

  @override
  bool updateShouldNotify(AuthServiceInherited oldWidget) {
    return oldWidget.authService != authService;
  }
}
