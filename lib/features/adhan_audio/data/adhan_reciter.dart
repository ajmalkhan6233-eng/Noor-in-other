class AdhanReciter {
  final String id, name, nameAr, country, audioPath;
  final String? fajrAudioPath;
  final String source;

  const AdhanReciter({required this.id,required this.name,required this.nameAr,required this.country,required this.audioPath,this.fajrAudioPath,this.source='Kiwifu/adhan-mp3'});

  String get fajrPath => fajrAudioPath ?? audioPath;

  @override bool operator ==(Object o) => identical(this,o) || o is AdhanReciter && id == o.id;
  @override int get hashCode => id.hashCode;
}