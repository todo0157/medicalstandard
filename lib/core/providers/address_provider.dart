import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../services/api_client.dart';
import 'profile_provider.dart';

final addressServiceProvider = Provider<AddressService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiAddressService(apiClient);
});

final addressSearchProvider = FutureProvider.family
    .autoDispose<AddressSearchResult, String>((ref, query) async {
  final trimmedQuery = query.trim();
  
  // 빈 쿼리 또는 최소 길이 미만이면 빈 결과 반환
  if (trimmedQuery.isEmpty || trimmedQuery.length < 2) {
    return AddressSearchResult(addresses: [], total: 0);
  }

  final service = ref.watch(addressServiceProvider);
  
  try {
    return await service.searchAddress(trimmedQuery);
  } catch (e) {
    // 에러 발생 시 상세 로그
    debugPrint('[AddressSearchProvider] Error searching address: $e');
    debugPrint('[AddressSearchProvider] Query: $trimmedQuery');
    rethrow;
  }
});

final reverseGeocodeProvider = FutureProvider.family
    .autoDispose<Address, ReverseGeocodeParams>((ref, params) async {
  final service = ref.watch(addressServiceProvider);
  return await service.reverseGeocode(params.lat, params.lng);
});

class ReverseGeocodeParams {
  ReverseGeocodeParams({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReverseGeocodeParams &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}

