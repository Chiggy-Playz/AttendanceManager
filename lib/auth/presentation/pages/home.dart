import 'package:attendance_manager/auth/data/user_repository.dart';
import 'package:attendance_manager/auth/presentation/pages/loading.dart';
import 'package:attendance_manager/auth/presentation/pages/login.dart';
import 'package:attendance_manager/auth/presentation/pages/splash.dart';
import 'package:attendance_manager/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, UserRepository user, _) {
        switch (user.status) {
          case Status.unauthenticated:
            return const LoginPage();
          case Status.authenticating:
            return Loading();
          case Status.authenticated:
            return const HomePage();
          case Status.uninitialized:
          default:
            return Splash();
        }
      },
    );
  }
}
