import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/adhan_reciter_registry.dart';
import '../data/adhan_preferences_repository.dart';
import 'adhan_audio_state.dart';

class AdhanAudioCubit extends Cubit<AdhanAudioState> {
  late final AdhanPreferencesRepository _repo;
  AdhanAudioCubit():super(const AdhanAudioInitial());

  Future<void> initialize(SharedPreferences p) async {
    _repo=AdhanPreferencesRepository(p);
    final reciters=AdhanReciterRegistry.bundled;
    emit(AdhanAudioReady(reciters:reciters,defaultReciter:_repo.getDefaultReciter(),assignments:_repo.getAssignments(),isMuted:_repo.isMuted));
  }

  Future<void> setDefaultReciter(String id) async {
    await _repo.setDefaultReciterId(id);
    if(state is AdhanAudioReady){final s=state as AdhanAudioReady;emit(s.copyWith(dr:AdhanReciterRegistry.byId(id)??AdhanReciterRegistry.defaultReciter));}
  }

  Future<void> assignReciterToPrayer(String p,String id) async {
    await _repo.setReciterForPrayer(p,id);
    if(state is AdhanAudioReady){final s=state as AdhanAudioReady;final u={...s.assignments.reciterPerPrayer,p.toLowerCase():id};emit(s.copyWith(a:s.assignments.copyWith(reciterPerPrayer:u)));}
  }

  Future<void> toggleMute() async {final c=_repo.isMuted;await _repo.setMuted(!c);if(state is AdhanAudioReady)emit((state as AdhanAudioReady).copyWith(m:!c));}
  void setActivePrayer(String? n){if(state is AdhanAudioReady)emit((state as AdhanAudioReady).copyWith(ap:n));}
  void resetToReady(){if(state is AdhanAudioReady){final s=state as AdhanAudioReady;emit(AdhanAudioReady(reciters:s.reciters,defaultReciter:s.defaultReciter,assignments:s.assignments,isMuted:s.isMuted));}}
}