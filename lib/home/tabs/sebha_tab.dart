import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SebhaTab extends StatefulWidget {
  const SebhaTab({super.key});

  @override
  State<SebhaTab> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends State<SebhaTab> {
  int counter = 30;
  int currentIndex = 0;
  double turns = 0.0;

  final List<String> tasabeeh = [
    "سبحان الله",
    "الحمد لله",
    "الله أكبر",
    "لا إله إلا الله",
  ];

  void onTasbeehPressed() {
    setState(() {
      counter--;
      turns += 0.1; // تأثير دوران خفيف للسبحة عند الضغط
      if (counter == 0) {
        counter = 30;
        currentIndex = (currentIndex + 1) % tasabeeh.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Image.asset("assets/images/onboarding_header.png"),
        const SizedBox(height: 20),
        Text(
          "سَبِّحْ اسْمَ رَبِّكَ الْأَعْلَى",
          style: GoogleFonts.elMessiri(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: onTasbeehPressed,
              child: Column(
                children: [
                  Positioned(
                    top: 1, // يمكنك تعديل القيمة دي لضبط الارتفاع بدقة
                    child: Image.asset(
                      "assets/images/sebha.png", // اسم صورة الرأس اللي رفعتها
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedRotation(
                        turns: turns,
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset(
                          "assets/images/SebhaBody 1.png",
                          width: 370,
                          height: 350,
                        ),
                      ),
                      // النصوص في المنتصف (التسبيحة والعداد)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tasabeeh[currentIndex],
                            style: GoogleFonts.elMessiri(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "$counter",
                            style: GoogleFonts.elMessiri(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
