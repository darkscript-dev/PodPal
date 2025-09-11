import 'package:flutter/material.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:podpal/screens/0_startup_screen.dart';
import 'package:podpal/screens/1_onboarding/connect_screen.dart';
import 'package:podpal/screens/1_onboarding/name_plant_screen.dart';
import 'package:podpal/screens/1_onboarding/plant_list_screen.dart';
import 'package:podpal/screens/2_home_screen.dart';
import 'package:podpal/screens/3_charts_screen.dart';
import 'package:podpal/screens/4_ask_expert_screen.dart';
import 'package:podpal/screens/5_profile_screen.dart';
import 'package:podpal/screens/6_settings_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => PodDataProvider()..initProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PodPal',
      theme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,

      home: const PodPalIntroScreen(),

      routes: {
        '/connect': (context) => const ConnectToPodScreen(),
        '/plant_list': (context) => const PlantSelectionScreen(),
        '/name_plant': (context) => const PodPalSetupScreen(),
        '/home': (context) => const PodPalHomeScreen(),
        '/charts': (context) => const ChartsScreen(),
        '/ask_expert': (context) => AskAIPage(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}