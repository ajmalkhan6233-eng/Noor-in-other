import 'package:equatable/equatable.dart';
import '../data/adhan_reciter.dart';
import '../data/prayer_adhan_assignment.dart';

sealed class AdhanAudioState extends Equatable {
  const AdhanAudioState();
  @override List<Object?> get props=>[];
}

class AdhanAudioInitial extends AdhanAudioState { const AdhanAudioInitial(); }

class AdhanAudioReady extends AdhanAudioState {
  final List<AdhanReciter> reciters;
  final AdhanReciter defaultReciter;
  final PrayerAdhanAssignment assignments;
  final bool isMuted;
  final String? activePrayer;

  const AdhanAudioReady({required this.reciters,required this.defaultReciter,required this.assignments,this.isMuted=false,this.activePrayer});

  AdhanReciter get reciterForActivePrayer {
    if(activePrayer==null)return defaultReciter;
    final id=assignments.reciterFor(activePrayer!);
    return reciters.firstWhere((r)=>r.id==id,orElse:()=>defaultReciter);
  }

  AdhanAudioReady copyWith({List<AdhanReciter>? r,AdhanReciter? dr,PrayerAdhanAssignment? a,bool? m,String? ap}) =>
    AdhanAudioReady(reciters:r??reciters,defaultReciter:dr??defaultReciter,assignments:a??assignments,isMuted:m??isMuted,activePrayer:ap??activePrayer);

  @override List<Object?> get props=>[reciters,defaultReciter,assignments,isMuted,activePrayer];
}

class AdhanAudioPlaying extends AdhanAudioReady {
  final String reciterName, prayerName;
  final Duration duration, position;

  const AdhanAudioPlaying({required super.reciters,required super.defaultReciter,required super.assignments,required super.isMuted,required super.activePrayer,required this.reciterName,required this.prayerName,required this.duration,required this.position});

  double get progress=>duration.inMilliseconds>0?position.inMilliseconds/duration.inMilliseconds:0.0;
  @override List<Object?> get props=>[...super.props,reciterName,prayerName,duration,position];
}