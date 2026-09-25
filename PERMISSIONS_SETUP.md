# إعدادات الأذونات (Permissions Setup)

## Android (android/app/src/main/AndroidManifest.xml)

أضف الأذونات التالية داخل `<manifest>` tag وقبل `<application>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- أذونات الموقع -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- إذن الوصول للإنترنت (مطلوب لـ API) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        ...>
        ...
    </application>
</manifest>
```

### إعدادات إضافية لـ Android 12+ (اختياري)

إذا كنت تستهدف Android 12 أو أحدث، أضف هذا داخل `<application>` tag:

```xml
<application
    ...>
    <activity
        ...>
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity>
    
    <!-- إعدادات الموقع الدقيق -->
    <property
        android:name="android.app.PROPERTY_ALLOW_ALLOCATION_WHILE_IN_BACKGROUND"
        android:value="false" />
</application>
```

---

## iOS (ios/Runner/Info.plist)

أضف المفاتيح التالية في ملف `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج إلى موقعك الحالي لعرض مواقيت الصلاة الدقيقة</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>نحتاج إلى موقعك الحالي لعرض مواقيت الصلاة الدقيقة</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>نحتاج إلى موقعك الحالي لعرض مواقيت الصلاة الدقيقة</string>
```

### إعدادات إضافية لـ iOS (خلفية الموقع)

إذا كنت تريد تحديث الموقع في الخلفية، أضف:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

---

## خطوات التثبيت

1. **تحديث التبعيات:**
   ```bash
   flutter pub get
   ```

2. **لـ iOS فقط:**
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **تشغيل التطبيق:**
   ```bash
   flutter run
   ```

---

## ملاحظات مهمة

- **Android:** تأكد من أن `minSdkVersion` في `android/app/build.gradle` هو 21 أو أعلى
- **iOS:** تأكد من أن `IPHONEOS_DEPLOYMENT_TARGET` في `ios/Podfile` هو 12.0 أو أعلى
- **الموقع:** التطبيق سيطلب إذن الموقع عند أول تشغيل
- **الإنترنت:** تأكد من أن الجهاز متصل بالإنترنت لجلب مواقيت الصلاة من API

---

## إضافة ملف الأذان (اختياري)

لإضافة ملف صوتي للأذان:

1. أنشئ مجلد `assets/audio/` في جذر المشروع
2. ضع ملف `azan.mp3` فيه
3. أضف المسار في `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/files/
    - assets/data/
    - assets/audio/
```

---

## استكشاف الأخطاء

### الموقع لا يعمل:
- تأكد من تفعيل خدمة الموقع في إعدادات الجهاز
- تأكد من منح الإذن للتطبيق
- تحقق من أن التطبيق لديه إذن الوصول للإنترنت

### مواقيت الصلاة لا تظهر:
- تحقق من اتصال الإنترنت
- تأكد من أن API يعمل (https://api.aladhan.com)
- جرب إعادة تشغيل التطبيق

### الصوت لا يعمل:
- تأكد من وجود ملف `azan.mp3` في `assets/audio/`
- تحقق من أن مستوى الصوت في الجهاز مرفوع
- تأكد من أن `audioplayers` مثبت بشكل صحيح
