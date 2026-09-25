import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'home/home.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = "/";

  const OnboardingScreen({super.key});

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName.png', width: width);
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.elMessiri(
      color: const Color(0xFFE2BE7F),
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    );

    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.elMessiri(
        color: Color(0xFFE2BE7F),
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: const Color(0xFF202020),
      imageFlex: 4,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalHeader: Image.asset("assets/images/onboarding_header.png"),
      dotsFlex: 2,
      dotsDecorator: DotsDecorator(
        color: Color(0xFF707070),
        activeColor: Color(0xFFE2BE7F),
      ),
      globalBackgroundColor: Color(0xFF202020),
      showDoneButton: true,
      onDone: () {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      },
      done: Text(
        "Finish",
        style: GoogleFonts.elMessiri(
          color: Color(0xFFE2BE7F),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      showNextButton: true,
      next: Text(
        "Next",
        style: GoogleFonts.elMessiri(
          color: Color(0xFFE2BE7F),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      showBackButton: true,
      back: Text(
        "Back",
        style: GoogleFonts.elMessiri(
          color: Color(0xFFE2BE7F),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      pages: [
        PageViewModel(
          title: "Welcome To Islami App",
          body: "",
          image: _buildImage('onboarding_1'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Welcome To Islami",
          body: " We Are Very Excited To Have You In Our Community",
          image: _buildImage('onboarding_2'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Reading the Quran",
          body: "Read, and your Lord is the Most Generous",
          image: _buildImage('onboarding_3'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Bearish",
          body: "PPraise the name of your Lord, the Most High",
          image: _buildImage('onboarding_4'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Holy Quran Radio",
          body:
              "You can listen to the Holy Quran Radio through the application for free and easily",
          image: _buildImage('onboarding_5'),
          decoration: pageDecoration,
        ),
      ],
    );
  }
}
