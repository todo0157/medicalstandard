import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../models/address.dart';
import 'api_client.dart';

abstract class AddressService {
  Future<AddressSearchResult> searchAddress(String query);
  Future<Address> reverseGeocode(double lat, double lng);
  Future<Address> geocodeAddress(String roadAddress, String? jibunAddress);
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
      // 우편번호 검색은 응답이 크고 처리 시간이 오래 걸릴 수 있으므로 더 긴 타임아웃 사용
      final isPostalCode = RegExp(r'^\d{5}$').hasMatch(query.trim());
      final timeout = isPostalCode 
          ? AppConfig.addressSearchTimeout 
          : AppConfig.apiTimeout;
      
      final response = await _apiClient.get(
        '/addresses/search?query=${Uri.encodeComponent(query)}',
        headers: {},
        timeout: timeout,
      );

      debugPrint('[AddressService] Response received: ${response.keys}');
      
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        debugPrint('[AddressService] No data in response. Response keys: ${response.keys}');
        debugPrint('[AddressService] Full response: $response');
        throw const AppException.server(
          message: '주소 검색 결과를 받지 못했습니다.',
        );
      }

      final addressesList = data['addresses'] as List<dynamic>?;
      if (addressesList == null) {
        debugPrint('[AddressService] No addresses list in data. Data keys: ${data.keys}');
        throw const AppException.server(
          message: '주소 목록을 받지 못했습니다.',
        );
      }

      debugPrint('[AddressService] Found ${addressesList.length} addresses');

      // 각 주소를 파싱 (에러 발생 시 상세 정보 제공)
      final addresses = <Address>[];
      for (int i = 0; i < addressesList.length; i++) {
        try {
          final item = addressesList[i];
          if (item is! Map<String, dynamic>) {
            debugPrint('[AddressService] Address at index $i is not a Map: ${item.runtimeType}');
            continue;
          }
          
          // 필수 필드 확인
          if (!item.containsKey('roadAddress') || !item.containsKey('jibunAddress')) {
            debugPrint('[AddressService] Address at index $i missing required fields: ${item.keys}');
            continue;
          }
          
          // x, y가 없거나 0인 경우도 허용 (우편번호 검색 결과)
          // 기본값 설정
          final addressData = Map<String, dynamic>.from(item);
          if (!addressData.containsKey('x') || addressData['x'] == null) {
            addressData['x'] = 0.0;
          }
          if (!addressData.containsKey('y') || addressData['y'] == null) {
            addressData['y'] = 0.0;
          }
          if (!addressData.containsKey('distance') || addressData['distance'] == null) {
            addressData['distance'] = 0.0;
          }
          if (!addressData.containsKey('addressElements') || addressData['addressElements'] == null) {
            addressData['addressElements'] = [];
          }
          
          final address = Address.fromJson(addressData);
          addresses.add(address);
        } catch (e, stackTrace) {
          // 개별 주소 파싱 실패 시 로그만 남기고 계속 진행
          debugPrint('[AddressService] Failed to parse address at index $i: $e');
          debugPrint('[AddressService] Stack trace: $stackTrace');
          debugPrint('[AddressService] Address data: ${addressesList[i]}');
          // 첫 번째 주소 파싱 실패 시에만 에러 발생
          if (i == 0 && addresses.isEmpty) {
            throw AppException.server(
              message: '주소 데이터 형식이 올바르지 않습니다: $e',
            );
          }
        }
      }

      debugPrint('[AddressService] Successfully parsed ${addresses.length} addresses');

      return AddressSearchResult(
        addresses: addresses,
        total: data['total'] as int? ?? addresses.length,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      debugPrint('[AddressService] Search error: $e');
      debugPrint('[AddressService] Error type: ${e.runtimeType}');
      debugPrint('[AddressService] Stack trace: $stackTrace');
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

  @override
  Future<Address> geocodeAddress(String roadAddress, String? jibunAddress) async {
    try {
      final response = await _apiClient.post(
        '/addresses/geocode',
        headers: {'Content-Type': 'application/json'},
        body: {
          'roadAddress': roadAddress,
          'jibunAddress': jibunAddress,
        },
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const AppException.server(
          message: '주소 좌표 변환 결과를 받지 못했습니다.',
        );
      }

      return Address.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.server(
        message: '주소 좌표 변환 중 오류가 발생했습니다: $e',
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

