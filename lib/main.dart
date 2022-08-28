import 'package:flutter/material.dart';
import 'package:ambibuzz/screens/dog_screen.dart';
import 'package:ambibuzz/screens/task_screen.dart';
import 'package:ambibuzz/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.purple,
      ),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        TaskScreen.id: (context) => const TaskScreen(),
        DogScreen.id: (context) => const DogScreen(),
      },
    );
  }
}
