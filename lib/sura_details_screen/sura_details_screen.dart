import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islami/data/sura_details_model.dart';

class SuraDetailsScreen extends StatefulWidget {
  final SuraDetailsModel suraDetails;

  const SuraDetailsScreen({super.key, required this.suraDetails});

  static const String routeName = "SuraDetails";

  @override
  State<SuraDetailsScreen> createState() => _SuraDetailsScreenState();
}

class _SuraDetailsScreenState extends State<SuraDetailsScreen> {
  String fullSuraText = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSuraVerses();
  }

  Future<void> loadSuraVerses() async {
    try {
      final String response = await rootBundle.loadString('assets/files/${widget.suraDetails.index}.txt');
      final List<String> lines = response.split('\n');
      setState(() {
        // Join verses and add inline numbering
        fullSuraText = lines
            .where((line) => line.trim().isNotEmpty)
            .toList()
            .asMap()
            .entries
            .map((entry) => '${entry.value} [${entry.key + 1}]')
            .join(' ');
        isLoading = false;
      });
    } catch (e) {
      print('Error loading sura verses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
          widget.suraDetails.arabicName,
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
                  // Arabic Title with Golden Corner Decorations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        "assets/images/left_border.png",
                        width: 93,
                        height: 92,
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.suraDetails.arabicName,
                        style: GoogleFonts.amiri(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2BE7F),
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(
                        "assets/images/right_border.png",
                        width: 93,
                        height: 92,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Verses as continuous paragraph
                  isLoading
                      ? Center(child: CircularProgressIndicator(color: Color(0xFFE2BE7F)))
                      : Text(
                          fullSuraText,
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
