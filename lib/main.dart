  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/form_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FormProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Form App',
      theme: ThemeData(
          primarySwatch: Colors.red,
        useMaterial3: false
      ),
      home: const HomeScreen(),
    );
  }
}