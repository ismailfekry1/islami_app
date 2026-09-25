class SuraDetailsModel {
  final String arabicName;
  final String englishName;
  final int index;
  final int versesCount;
  final List<String> verses;

  SuraDetailsModel({
    required this.arabicName,
    required this.englishName,
    required this.index,
    required this.versesCount,
    required this.verses,
  });
}
