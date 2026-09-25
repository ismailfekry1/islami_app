import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islami/home/tabs/ahadeth_tab.dart';
import 'package:islami/home/tabs/dates_tab.dart';
import 'package:islami/home/tabs/quran_tab.dart';
import 'package:islami/home/tabs/radio_tab.dart';
import 'package:islami/home/tabs/sebha_tab.dart';


class HomeScreen extends StatefulWidget {
  static const String routeName = "Home";

  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/${getBackgroundImageName()}.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (value) {
              currentIndex = value;
              setState(() {});
            },
            backgroundColor: Color(0xFFE2BE7F),
            showUnselectedLabels: false,
            showSelectedLabels: true,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Color(0xFF202020),
            selectedItemColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavItem("quran", 0),
                label: "Quran",
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem("ahadith", 1),
                label: "Hadith",
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem("sebha", 2),
                label: "Tasbeeh",
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem("radio", 3),
                label: "Radio",
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem("dates", 4),
                label: "Time",
              ),
            ],
          ),
          body:tabs[currentIndex] ,
        ),
      ),
    );
  }
  List<Widget> tabs=[
    QuranTab(),
    AhadethTab(),
    SebhaTab(),
    RadioTab(),
    DatesTab(),
  ];

  String getBackgroundImageName() {
    switch (currentIndex) {
      case 0:
        return "home_bg";
      case 1:
        return "Background2";
      case 2:
        return "Background3";
      case 3:
        return "Background4";
      case 4:
        return "Background5";
      default:
        return "home_bg";
    }
  }

  Widget _buildNavItem(String imageName, int index) {
    return currentIndex == index
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            decoration: BoxDecoration(
              color: Color(0x99202020),
              borderRadius: BorderRadius.circular(66),
            ),
            child: ImageIcon(AssetImage("assets/images/$imageName.png")),
          )
        : ImageIcon(AssetImage("assets/images/$imageName.png"));
  }
}
