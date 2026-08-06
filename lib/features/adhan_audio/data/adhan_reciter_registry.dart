import 'adhan_reciter.dart';

class AdhanReciterRegistry {
  AdhanReciterRegistry._();

  static const bundled = [
    AdhanReciter(id:'ali_mala',name:'Ali Ibn Ahmad Mala',nameAr:'علي بن أحمد ملا',country:'Saudi Arabia (Mecca)',audioPath:'assets/audio/adhan/ali_mala.m4a',fajrAudioPath:'assets/audio/adhan/ali_mala_fajr.m4a'),
    AdhanReciter(id:'mishary_alafasy',name:'Mishary Rashid Alafasy',nameAr:'مشاري راشد العفاسي',country:'Kuwait',audioPath:'assets/audio/adhan/mishary_alafasy.m4a',fajrAudioPath:'assets/audio/adhan/mishary_alafasy_fajr.m4a'),
    AdhanReciter(id:'abdulbasit',name:'Abdulbasit Abdusamad',nameAr:'عبد الباسط عبد الصمد',country:'Egypt',audioPath:'assets/audio/adhan/abdulbasit.m4a'),
    AdhanReciter(id:'nasser_alqatami',name:'Nasser Al Qatami',nameAr:'ناصر القطامي',country:'Saudi Arabia',audioPath:'assets/audio/adhan/nasser_alqatami.m4a'),
    AdhanReciter(id:'naji_qazaz',name:'Najee Qazaz',nameAr:'ناجي قزاز',country:'Palestine (Al-Aqsa)',audioPath:'assets/audio/adhan/naji_qazaz.m4a'),
    AdhanReciter(id:'minshawi',name:'Mohamed Siddiq El-Minshawi',nameAr:'محمد صديق المنشاوي',country:'Egypt',audioPath:'assets/audio/adhan/minshawi.m4a'),
  ];

  static AdhanReciter? byId(String id) { try { return bundled.firstWhere((r)=>r.id==id); } catch(_) { return null; } }
  static const defaultReciterId = 'ali_mala';
  static AdhanReciter get defaultReciter => byId(defaultReciterId)!;
}