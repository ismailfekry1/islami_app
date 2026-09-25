import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  static Future<Map<String, dynamic>?> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/timings?latitude=$latitude&longitude=$longitude&method=$method',
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/timingsByCity?city=$city&country=$country&method=$method',
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Map<String, String> getPrayerNamesArabic() {
    return {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
  }

  static List<String> getPrayerOrder() {
    return ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  }
}
