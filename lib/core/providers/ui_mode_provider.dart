import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UIMode {
  patient, // 환자 모드
  practitioner, // 한의사 모드
}

// UI 모드 상태 관리
class UIModeNotifier extends StateNotifier<UIMode> {
  UIModeNotifier() : super(UIMode.patient);

  void switchToPatient() {
    state = UIMode.patient;
  }

  void switchToPractitioner() {
    state = UIMode.practitioner;
  }
}

final uiModeProvider = StateNotifierProvider<UIModeNotifier, UIMode>((ref) {
  return UIModeNotifier();
});

