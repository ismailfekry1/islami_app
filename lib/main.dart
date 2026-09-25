import 'package:flutter/material.dart';

import 'data/hadeth_model.dart';
import 'data/sura_details_model.dart';
import 'hadeth_details_screen/hadeth_details_screen.dart';
import 'home/home.dart';
import 'onboarding_Screen.dart';
import 'sura_details_screen/sura_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:HomeScreen.routeName,
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        SuraDetailsScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as SuraDetailsModel?;
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Error: No sura details provided')),
            );
          }
          return SuraDetailsScreen(suraDetails: args);
        },
        HadethDetailsScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as HadethModel?;
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Error: No hadeth details provided')),
            );
          }
          return HadethDetailsScreen(hadeth: args);
        },
      },
    );
  }
}
