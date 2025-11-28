import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../models/address.dart';
import 'api_client.dart';

abstract class AddressService {
  Future<AddressSearchResult> searchAddress(String query);
  Future<Address> reverseGeocode(double lat, double lng);
}

class ApiAddressService implements AddressService {
  ApiAddressService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AddressSearchResult> searchAddress(String query) async {
    if (query.trim().isEmpty) {
      throw const AppException.validation(
        message: '검색어를 입력해주세요.',
      );
    }

    try {
      // query parameter를 URL에 포함
      final response = await _apiClient.get(
        '/addresses/search?query=${Uri.encodeComponent(query)}',
        headers: {},
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const AppException.server(
          message: '주소 검색 결과를 받지 못했습니다.',
        );
      }

      final addresses = (data['addresses'] as List<dynamic>?)
              ?.map((item) => Address.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      return AddressSearchResult(
        addresses: addresses,
        total: data['total'] as int? ?? addresses.length,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.server(
        message: '주소 검색 중 오류가 발생했습니다: $e',
      );
    }
  }

  @override
  Future<Address> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _apiClient.get(
        '/addresses/reverse?lat=$lat&lng=$lng',
        headers: {},
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const AppException.server(
          message: '주소 변환 결과를 받지 못했습니다.',
        );
      }

      return Address.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.server(
        message: '주소 변환 중 오류가 발생했습니다: $e',
      );
    }
  }
}

class AddressSearchResult {
  AddressSearchResult({
    required this.addresses,
    required this.total,
  });

  final List<Address> addresses;
  final int total;
}

