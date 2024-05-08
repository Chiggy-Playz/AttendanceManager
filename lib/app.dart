import 'package:attendance_manager/auth/data/user_repository.dart';
import 'package:attendance_manager/auth/presentation/pages/home.dart';
import 'package:attendance_manager/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    var darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.deepPurple,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
      ),
      useMaterial3: true,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRepository>(
          create: (_) => UserRepository.instance(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: AuthHomePage(),
      ),
    );
  }
}
