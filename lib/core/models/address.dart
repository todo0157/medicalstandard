import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required String roadAddress, // 도로명 주소
    required String jibunAddress, // 지번 주소
    String? englishAddress, // 영문 주소
    required double x, // 경도
    required double y, // 위도
    @Default(0) double distance, // 거리 (미터)
    @Default([]) List<AddressElement> addressElements, // 주소 구성 요소
    String? detailAddress, // 세부 주소 (예: 101동 301호)
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

@freezed
class AddressElement with _$AddressElement {
  const factory AddressElement({
    required List<String> types, // 주소 타입 (SIDO, SIGUGUN, etc.)
    required String longName, // 전체 이름
    required String shortName, // 짧은 이름
    @Default('') String code, // 코드
  }) = _AddressElement;

  factory AddressElement.fromJson(Map<String, dynamic> json) =>
      _$AddressElementFromJson(json);
}


