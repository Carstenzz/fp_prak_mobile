import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

/// Entry point aplikasi Manajemen Inventaris
void main() {
  runApp(const MyApp());
}

/// Widget utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario🤌',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
