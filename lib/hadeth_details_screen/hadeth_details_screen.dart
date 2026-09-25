import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islami/data/hadeth_model.dart';

class HadethDetailsScreen extends StatelessWidget {
  final HadethModel hadeth;

  const HadethDetailsScreen({super.key, required this.hadeth});

  static const String routeName = "HadethDetails";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFFE2BE7F),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          hadeth.title,
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE2BE7F),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Golden Corner Decorations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/left_border.png",
                        width: 93,
                        height: 92,
                      ),
                      Image.asset(
                        "assets/images/right_border.png",
                        width: 93,
                        height: 92,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Hadeth Title
                  Text(
                    hadeth.title,
                    style: GoogleFonts.amiri(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BE7F),
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 30),

                  // Hadeth Content
                  Text(
                    hadeth.content,
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BE7F),
                      height: 2.0,
                    ),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),

          // Mosque Silhouette at bottom - fixed
          Image.asset(
            "assets/images/mosque_silhouette.png",
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
