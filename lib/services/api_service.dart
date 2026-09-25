import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://www.mp3quran.net/api/v3';

  static Future<List<Map<String, dynamic>>> getRadios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/radios?language=ar'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['radios'] != null) {
          final radios = data['radios'];
          if (radios is List) {
            return List<Map<String, dynamic>>.from(radios);
          }
          if (radios is Set) {
            return List<Map<String, dynamic>>.from(radios);
          }
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getReciters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reciters'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['reciters'] != null) {
          final reciters = data['reciters'];
          if (reciters is List) {
            return List<Map<String, dynamic>>.from(reciters);
          }
          if (reciters is Set) {
            return List<Map<String, dynamic>>.from(reciters);
          }
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
