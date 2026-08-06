class PrayerAdhanAssignment {
  final Map<String,String> reciterPerPrayer;
  final String defaultReciterId;

  const PrayerAdhanAssignment({required this.reciterPerPrayer, required this.defaultReciterId});

  String reciterFor(String p) => reciterPerPrayer[p.toLowerCase()] ?? defaultReciterId;

  PrayerAdhanAssignment copyWith({Map<String,String>? reciterPerPrayer, String? defaultReciterId}) =>
    PrayerAdhanAssignment(reciterPerPrayer:reciterPerPrayer??this.reciterPerPrayer, defaultReciterId:defaultReciterId??this.defaultReciterId);

  Map<String,dynamic> toJson() => {'reciterPerPrayer':reciterPerPrayer,'defaultReciterId':defaultReciterId};
  factory PrayerAdhanAssignment.fromJson(Map<String,dynamic> j) =>
    PrayerAdhanAssignment(reciterPerPrayer:Map<String,String>.from(j['reciterPerPrayer'] as Map),defaultReciterId:j['defaultReciterId'] as String);
}