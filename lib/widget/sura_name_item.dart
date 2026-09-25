import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islami/data/sura_details_model.dart';
import 'package:islami/sura_details_screen/sura_details_screen.dart';

class SuraNameItem extends StatelessWidget {
  final String nameAR, nameNG;
  final int index;
  final String numOfVerses;

  const SuraNameItem({
    super.key,
    required this.nameAR,
    required this.nameNG,
    required this.index,
    required this.numOfVerses,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          SuraDetailsScreen.routeName,
          arguments: SuraDetailsModel(
            arabicName: nameAR,
            englishName: nameNG,
            index: index,
            versesCount: int.parse(numOfVerses),
            verses: [],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/index_ic.png"),
                Text(
                  "$index",
                  style: GoogleFonts.elMessiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$nameNG",
                    style: GoogleFonts.elMessiri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "$numOfVerses Verses",
                    style: GoogleFonts.elMessiri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "$nameAR",
              style: GoogleFonts.elMessiri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
