import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/appointment.dart';
import '../../../core/models/doctor.dart';
import '../../../core/models/slot.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/services/doctor_service.dart';

class DoctorSearchArgs {
  const DoctorSearchArgs({this.query = '', this.lat, this.lng, this.radiusKm});

  final String query;
  final double? lat;
  final double? lng;
  final double? radiusKm;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorSearchArgs &&
        other.query == query &&
        other.lat == lat &&
        other.lng == lng &&
        other.radiusKm == radiusKm;
  }

  @override
  int get hashCode => Object.hash(query, lat, lng, radiusKm);
}

final doctorSearchProvider =
    FutureProvider.autoDispose.family<List<Doctor>, DoctorSearchArgs>((ref, args) async {
      final service = DoctorService();
      return service.searchDoctors(
        query: args.query,
        lat: args.lat,
        lng: args.lng,
        radiusKm: args.radiusKm,
      );
    });

final slotsProvider =
    FutureProvider.autoDispose.family<List<Slot>, String>((ref, doctorId) async {
      final service = DoctorService();
      return service.getSlots(doctorId);
    });

class AppointmentNotifier extends StateNotifier<AsyncValue<List<Appointment>>> {
  AppointmentNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadAppointments();
  }

  final AppointmentService _service;

  Future<void> _loadAppointments() async {
    try {
      state = const AsyncValue.loading();
      final result = await _service.fetchMyAppointments();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadAppointments();
  }

  Future<void> book({
    required String doctorId,
    required String slotId,
    String? notes,
  }) async {
    try {
      await _service.createAppointment(
        doctorId: doctorId,
        slotId: slotId,
        notes: notes,
      );
      await _loadAppointments();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancel(String appointmentId, {String? notes}) async {
    final current = state.value;
    try {
      final updated = await _service.updateAppointment(
        appointmentId: appointmentId,
        status: 'cancelled',
        notes: notes,
      );
      if (current != null) {
        state = AsyncValue.data([
          for (final item in current)
            if (item.id == appointmentId) updated else item,
        ]);
      } else {
        await _loadAppointments();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> remove(String appointmentId) async {
    final current = state.value;
    try {
      await _service.deleteAppointment(appointmentId);
      if (current != null) {
        state = AsyncValue.data(
          current.where((item) => item.id != appointmentId).toList(),
        );
      } else {
        await _loadAppointments();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final appointmentsNotifierProvider = StateNotifierProvider<AppointmentNotifier,
    AsyncValue<List<Appointment>>>(
  (ref) => AppointmentNotifier(AppointmentService()),
);
