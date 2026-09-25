import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/prayer_times_service.dart';
import '../../services/location_service.dart';
import '../../services/date_service.dart';

class DatesTab extends StatefulWidget {
  const DatesTab({super.key});

  @override
  State<DatesTab> createState() => _DatesTabState();
}

class _DatesTabState extends State<DatesTab> {
  int activePrayerIndex = 2;
  bool isSoundOn = true;
  bool isLoading = true;
  String? errorMessage;
  
  List<Map<String, String>> prayerTimes = [];
  Map<String, String> gregorianDate = {};
  Map<String, String> hijriDate = {};
  DateTime? _nextPrayerTime;
  String nextPrayerCountdown = '00:00:00';
  
  late final AudioPlayer _audioPlayer;
  Timer? _countdownTimer;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadData();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Load dates
    gregorianDate = DateService.getCurrentGregorianDateArabic();
    hijriDate = DateService.getCurrentHijriDateArabic();

    // Get location and prayer times
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      final prayerData = await PrayerTimesService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        method: 2, // Islamic Society of North America (ISNA)
      );

      if (prayerData != null && mounted) {
        _processPrayerTimes(prayerData);
      } else if (mounted) {
        setState(() {
          errorMessage = 'فشل في تحميل مواقيت الصلاة';
          isLoading = false;
        });
      }
    } else {
      // Fallback to Cairo if location not available
      final prayerData = await PrayerTimesService.getPrayerTimesByCity(
        city: 'Cairo',
        country: 'Egypt',
        method: 2,
      );

      if (prayerData != null && mounted) {
        _processPrayerTimes(prayerData);
      } else if (mounted) {
        setState(() {
          errorMessage = 'فشل في تحميل مواقيت الصلاة';
          isLoading = false;
        });
      }
    }
  }

  void _processPrayerTimes(Map<String, dynamic> prayerData) {
    final timings = prayerData['timings'] as Map<String, dynamic>?;
    final arabicNames = PrayerTimesService.getPrayerNamesArabic();
    final prayerOrder = PrayerTimesService.getPrayerOrder();

    if (timings != null) {
      List<Map<String, String>> times = [];
      for (String prayer in prayerOrder) {
        if (timings[prayer] != null) {
          times.add({
            'name': arabicNames[prayer] ?? prayer,
            'time': DateService.formatTime24To12(timings[prayer]),
            'time24': timings[prayer],
          });
        }
      }

      if (mounted) {
        setState(() {
          prayerTimes = times;
          isLoading = false;
        });
        // تحديث الصلاة النشطة وحساب الوقت فور وصول البيانات
        _updateActivePrayer();
      }
    }
  }


  void _updateActivePrayer() {
    if (prayerTimes.isEmpty) return;

    DateTime now = DateTime.now();
    int currentIndex = 0;
    DateTime? nextPrayerTime;

    for (int i = 0; i < prayerTimes.length; i++) {
      DateTime prayerTime = DateService.parseTime(prayerTimes[i]['time24']!);

      if (prayerTime.isAfter(now)) {
        nextPrayerTime = prayerTime;
        currentIndex = i;
        break;
      }
    }

    // If all prayers have passed today, next prayer is Fajr tomorrow
    if (nextPrayerTime == null && prayerTimes.isNotEmpty) {
      currentIndex = 0;
      DateTime fajrTime = DateService.parseTime(prayerTimes[0]['time24']!);
      nextPrayerTime = fajrTime.add(const Duration(days: 1));
    }

    if (mounted) {
      setState(() {
        activePrayerIndex = currentIndex;
        _nextPrayerTime = nextPrayerTime;

        if (nextPrayerTime != null) {
          Duration difference = nextPrayerTime.difference(now);
          nextPrayerCountdown = DateService.formatCountdown(difference);
        }
      });

        // Scroll to active prayer
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && prayerTimes.isNotEmpty) {
            final itemWidth = currentIndex == activePrayerIndex ? 104.0 : 86.0;
            final padding = 12.0;
            final screenWidth = MediaQuery.of(context).size.width;
            final targetPosition = (currentIndex * (itemWidth + padding)) - (screenWidth / 2) + (itemWidth / 2);
            _scrollController.animateTo(
              targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final now = DateTime.now();

      // لو وقت الصلاة القادمة مش متحدد، نحسبه فوراً
      if (_nextPrayerTime == null && prayerTimes.isNotEmpty) {
        _updateActivePrayer();
      }

      if (_nextPrayerTime != null) {
        Duration difference = _nextPrayerTime!.difference(now);

        if (difference.isNegative) {
          _loadData(); // لو وقت الصلاة جه، نعيد تحميل الجدول
        } else {
          setState(() {
            nextPrayerCountdown = DateService.formatCountdown(difference);
          });
        }
      }
    });
  }

  Future<void> _playAzan() async {
    try {
      // You can replace this with a real Azan audio file URL
      await _audioPlayer.play(AssetSource('audio/azan.mp3'));
    } catch (e) {
      print('Error playing Azan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header with Logo
              Image.asset('assets/images/onboarding_header.png'),
              const SizedBox(height: 15),
              
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: Color(0xFFE2BE7F),
                  ),
                )
              else if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: GoogleFonts.elMessiri(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2BE7F),
                          foregroundColor: const Color(0xFF202020),
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    // Prayer Time Card
                    _buildPrayerTimeCard(),
                    
                    const SizedBox(height: 30),
                    
                    // Azkar Section
                    _buildAzkarSection(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2BE7F),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Section
          _buildDateSection(),
          
          const Divider(
            color: Color(0x33202020),
            thickness: 1,
            height: 1,
          ),
          
          // Prayer Times Row
          _buildPrayerTimesRow(),
          
          const Divider(
            color: Color(0x33202020),
            thickness: 1,
            height: 1,
          ),
          
          // Next Prayer Section
          _buildNextPrayerSection(),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gregorian Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gregorianDate['date'] ?? '16 يوليو، 2024',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202020),
                ),
              ),
              const Text(
                'ميلادي',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0x80202020),
                ),
              ),
            ],
          ),
          
          // Day and Pray Time
          Column(
            children: [
              Text(
                gregorianDate['day'] ?? 'الثلاثاء',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202020),
                ),
              ),
              const Text(
                '- مواقيت الصلاة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202020),
                ),
              ),
            ],
          ),
          
          // Hijri Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hijriDate['date'] ?? '09 محرم، 1446',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202020),
                ),
              ),
              const Text(
                'هجري',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0x80202020),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: prayerTimes.length,
          itemBuilder: (context, index) {
            Map<String, String> prayer = prayerTimes[index];
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _buildPrayerCard(
                prayer['name']!,
                prayer['time']!,
                index == activePrayerIndex,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrayerCard(String name, String time, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isActive ? 104 : 86,
      height: isActive ? 128 : 106,
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 16 : 12,
        vertical: isActive ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF202020) : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: isActive ? null : Border.all(
          color: const Color(0xFF202020).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.elMessiri(
              fontSize: isActive ? 16 : 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? const Color(0xFFE2BE7F) : const Color(0xFF202020),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            time,
            textAlign: TextAlign.center,
            style: GoogleFonts.elMessiri(
              fontSize: isActive ? 24 : 16,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFFE2BE7F) : const Color(0xFF202020),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerSection() {
    String nextPrayerName = activePrayerIndex < prayerTimes.length 
        ? prayerTimes[activePrayerIndex]['name']! 
        : 'الفجر';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFF202020),
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة - $nextPrayerName',
                    style: GoogleFonts.elMessiri(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextPrayerCountdown,
                    style: GoogleFonts.elMessiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF202020),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSoundOn = !isSoundOn;
              });
              if (isSoundOn) {
                _playAzan();
              } else {
                _audioPlayer.stop();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF202020).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSoundOn ? Icons.volume_up : Icons.volume_off,
                color: const Color(0xFF202020),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأذكار',
            style: GoogleFonts.elMessiri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAzkarCard(
                  'أذكار المساء',
                  'assets/images/onboarding_3.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAzkarCard(
                  'أذكار الصباح',
                  'assets/images/onboarding_2.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarCard(String title, String imagePath) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2BE7F),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Background image with opacity
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mosque illustration
                Image.asset(
                  'assets/images/mosque_silhouette.png',
                  height: 60,
                  color: const Color(0xFFE2BE7F),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.elMessiri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
