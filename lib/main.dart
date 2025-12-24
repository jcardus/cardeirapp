import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/tio_carlitos.dart';
import 'pages/vizcolas.dart';
import 'pages/maezinha.dart';
import 'pages/madoquinhas.dart';
import 'pages/nuno.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardeirApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/tio_carlitos': (context) => const TioCarlitosPage(),
        '/viczolas': (context) => const VizcolasPage(),
        '/maezinha': (context) => const MaezinhaPage(),
        '/madoquinhas': (context) => const MadoquinhasPage(),
        '/nuno': (context) => const NunoPage(),
      },
    );
  }
}
