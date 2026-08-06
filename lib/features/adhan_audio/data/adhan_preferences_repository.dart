import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'adhan_reciter.dart';
import 'adhan_reciter_registry.dart';
import 'prayer_adhan_assignment.dart';

class AdhanPreferencesRepository {
  static const _dk='adhan_default_reciter_id',_ak='adhan_prayer_assignments',_mk='adhan_is_muted';
  final SharedPreferences _p;
  AdhanPreferencesRepository(this._p);

  String getDefaultReciterId()=>_p.getString(_dk)??AdhanReciterRegistry.defaultReciterId;
  Future<void> setDefaultReciterId(String id)=>_p.setString(_dk,id);
  AdhanReciter getDefaultReciter()=>AdhanReciterRegistry.byId(getDefaultReciterId())??AdhanReciterRegistry.defaultReciter;

  PrayerAdhanAssignment getAssignments() {
    final r=_p.getString(_ak);if(r==null)return PrayerAdhanAssignment(reciterPerPrayer:{},defaultReciterId:getDefaultReciterId());
    try{return PrayerAdhanAssignment.fromJson(jsonDecode(r) as Map<String,dynamic>);}catch(_){return PrayerAdhanAssignment(reciterPerPrayer:{},defaultReciterId:getDefaultReciterId());}
  }

  Future<void> setAssignments(PrayerAdhanAssignment a)=>_p.setString(_ak,jsonEncode(a.toJson()));
  Future<void> setReciterForPrayer(String p,String i)async{final a=getAssignments();final u=Map<String,String>.from(a.reciterPerPrayer);u[p.toLowerCase()]=i;await setAssignments(a.copyWith(reciterPerPrayer:u));}
  AdhanReciter getReciterForPrayer(String p){final a=getAssignments();return AdhanReciterRegistry.byId(a.reciterFor(p))??getDefaultReciter();}
  bool get isMuted=>_p.getBool(_mk)??false;
  Future<void> setMuted(bool m)=>_p.setBool(_mk,m);
}