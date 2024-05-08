import 'package:flutter/material.dart';

var lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.deepPurple,
      ),
    ),
  ),
  useMaterial3: true,
);

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
        borderRadius: BorderRadius.all(Radius.circular(24))),
  ),
  useMaterial3: true,
);
