import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/api_service.dart';

class RadioTab extends StatefulWidget {
  const RadioTab({super.key});

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AudioPlayer _audioPlayer;
  int? playingIndex;

  List<Map<String, dynamic>> radioStations = [];
  List<Map<String, dynamic>> reciters = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> _onPlayToggle(int index, String url, {bool isRadio = false}) async {
    try {
      if (playingIndex == index) {
        await _audioPlayer.stop();
        if (mounted) {
          setState(() {
            playingIndex = null;
          });
        }
      } else {
        await _audioPlayer.stop();

        if (mounted) {
          setState(() {
            playingIndex = index;
          });
        }

        if (isRadio) {
          await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        } else {
          await _audioPlayer.setReleaseMode(ReleaseMode.release);
        }

        await _audioPlayer.play(UrlSource(url)).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Connection timeout'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          playingIndex = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في تشغيل الصوت: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _audioPlayer = AudioPlayer();
    _fetchData();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _audioPlayer.stop();
        setState(() {
          playingIndex = null;
        });
      }
    });
  }

  Future<void> _fetchData() async {
    try {
      final radios = await ApiService.getRadios();
      final recitersData = await ApiService.getReciters();

      if (mounted) {
        setState(() {
          radioStations = radios.map((radio) {
            return {
              'name': radio['name']?.toString() ?? 'Unknown Radio',
              'url': radio['url']?.toString() ?? '',
            } as Map<String, dynamic>;
          }).toList();
          reciters = recitersData.map((reciter) {
            final moshafList = reciter['moshaf'] as List<dynamic>? ?? [];
            final firstMoshaf = moshafList.isNotEmpty ? moshafList[0] as Map<String, dynamic>? : null;
            final server = firstMoshaf?['server']?.toString() ?? '';
            final surahList = firstMoshaf?['surah_list']?.toString() ?? '';
            final firstSurah = surahList.isNotEmpty ? surahList.split(',')[0].trim() : '1';
            return {
              'name': reciter['name']?.toString() ?? 'Unknown Reciter',
              'url': '$server${firstSurah.padLeft(3, '0')}.mp3',
            } as Map<String, dynamic>;
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'خطأ في تحميل البيانات: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Image.asset('assets/images/onboarding_header.png'),
          const SizedBox(height: 7),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRadioList(),
                _buildRecitersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFFE2BE7F),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: const Color(0xFF202020),
        unselectedLabelColor: Colors.white,
        labelStyle: GoogleFonts.elMessiri(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.elMessiri(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'Radio'),
          Tab(text: 'Reciters'),
        ],
      ),
    );
  }

  Widget _buildRadioList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE2BE7F),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.elMessiri(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2BE7F),
                  foregroundColor: const Color(0xFF202020),
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (radioStations.isEmpty) {
      return Center(
        child: Text(
          'لا توجد محطات راديو متاحة',
          style: GoogleFonts.elMessiri(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: radioStations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AudioCard(
            title: radioStations[index]['name']?.toString() ?? '',
            isRadio: true,
            isPlaying: playingIndex == index,
            onPlayToggle: () => _onPlayToggle(index, radioStations[index]['url']?.toString() ?? '', isRadio: true),
          ),
        );
      },
    );
  }

  Widget _buildRecitersList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE2BE7F),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.elMessiri(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2BE7F),
                  foregroundColor: const Color(0xFF202020),
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (reciters.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد قراء متاحين',
          style: GoogleFonts.elMessiri(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: reciters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AudioCard(
            title: reciters[index]['name']?.toString() ?? '',
            isRadio: false,
            isPlaying: playingIndex == index + radioStations.length,
            onPlayToggle: () => _onPlayToggle(index + radioStations.length, reciters[index]['url']?.toString() ?? ''),
          ),
        );
      },
    );
  }
}

class AudioCard extends StatelessWidget {
  final String title;
  final bool isRadio;
  final bool isPlaying;
  final VoidCallback onPlayToggle;

  const AudioCard({
    super.key,
    required this.title,
    required this.isRadio,
    required this.isPlaying,
    required this.onPlayToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 133,
      decoration: BoxDecoration(
        color: const Color(0xFFE2BE7F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: 20,
            child: Opacity(
              opacity: 0.5,
              child: isPlaying
                  ? Image.asset(
                      'assets/images/Mask group.png',
                      color: Colors.black,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/mosque_silhouette.png',
                      fit: BoxFit.cover,
                      color: Colors.black,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.elMessiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF202020),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onPlayToggle,
                      icon: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: const Color(0xFF202020),
                      ),
                      iconSize: 50,
                    ),
                    Icon(
                      isPlaying ? Icons.volume_up : Icons.volume_off,
                      color: const Color(0xFF202020),
                      size: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
