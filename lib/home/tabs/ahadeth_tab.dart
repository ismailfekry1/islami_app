import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islami/data/hadeth_model.dart';
import 'package:islami/hadeth_details_screen/hadeth_details_screen.dart';

class AhadethTab extends StatefulWidget {
  const AhadethTab({super.key});

  @override
  State<AhadethTab> createState() => _AhadethTabState();
}

class _AhadethTabState extends State<AhadethTab> {
  List<HadethModel> hadithList = [];
  bool isLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    loadHadithFiles();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadHadithFiles() async {
    List<HadethModel> loadedHadith = [];
    for (int i = 1; i <= 50; i++) {
      try {
        final String response = await rootBundle.loadString(
          'assets/files/h$i.txt',
        );
        // Remove BOM character if present
        final String cleanResponse = response.replaceFirst('\uFEFF', '');
        final List<String> lines = cleanResponse.split('\n');
        if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
          String title = lines[0].trim();
          String content = lines.skip(1).join('\n').trim();
          loadedHadith.add(HadethModel(title: title, content: content));
        }
      } catch (e) {
        print('Error loading hadith $i: $e');
      }
    }
    setState(() {
      hadithList = loadedHadith;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/images/onboarding_header.png"),
        SizedBox(height: 15),
        isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFFE2BE7F)))
            : Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: hadithList.length,
                  itemBuilder: (context, index) {
                    double scale =
                        1.0 -
                        ((_currentPage - index).abs() * 0.04).clamp(0.0, 0.15);
                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                HadethDetailsScreen.routeName,
                                arguments: hadithList[index],
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/images/onboarding_3.png",
                                  ),
                                  fit: BoxFit.cover,
                                  opacity: 0.15,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                color: Color(0xFFE2BE7F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  // Corner decorations
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Image.asset(
                                      "assets/images/left_border.png",
                                      width: 60,
                                      height: 60,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Image.asset(
                                      "assets/images/right_border.png",
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.fill,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: 40),
                                      // Hadeth Title
                                      Text(
                                        hadithList[index].title,
                                        style: GoogleFonts.elMessiri(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF202020),
                                        ),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                      ),
                                      SizedBox(height: 20),

                                      // Hadeth Content
                                      Expanded(
                                        child: SingleChildScrollView(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          child: Text(
                                            hadithList[index].content,
                                            style: GoogleFonts.elMessiri(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF202020),
                                              height: 1.8,
                                            ),
                                            textAlign: TextAlign.justify,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                      ),

                                      // Mosque Silhouette at bottom
                                      Image.asset(
                                        "assets/images/mosque_silhouette.png",
                                        width: double.infinity,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
