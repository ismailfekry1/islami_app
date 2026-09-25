import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class DateService {
  static Map<String, String> getCurrentGregorianDateArabic() {
    DateTime now = DateTime.now();
    
    // Arabic day names
    const arabicDays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    
    // Arabic month names
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    
    String dayName = arabicDays[now.weekday % 7];
    String monthName = arabicMonths[now.month - 1];
    
    return {
      'day': dayName,
      'date': '${now.day} $monthName، ${now.year}',
    };
  }

  static Map<String, String> getCurrentHijriDateArabic() {
    HijriCalendar hijriDate = HijriCalendar.now();
    
    // Arabic Hijri month names
    const hijriMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    
    String monthName = hijriMonths[hijriDate.hMonth - 1];
    
    return {
      'date': '${hijriDate.hDay} $monthName، ${hijriDate.hYear}',
    };
  }

  static String formatTime24To12(String time24) {
    try {
      List<String> parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      String period = hour >= 12 ? 'م' : 'ص';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}\n$period';
    } catch (e) {
      return time24;
    }
  }

  static DateTime parseTime(String time24) {
    try {
      List<String> parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  static String formatCountdown(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
