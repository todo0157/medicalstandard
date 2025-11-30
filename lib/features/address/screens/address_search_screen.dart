import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/address.dart';
import '../../../core/providers/address_provider.dart';
import '../../../core/services/address_service.dart';
import '../../../shared/theme/app_colors.dart';

class AddressSearchScreen extends ConsumerStatefulWidget {
  const AddressSearchScreen({
    super.key,
    this.onAddressSelected,
  });

  final void Function(Address)? onAddressSelected;

  @override
  ConsumerState<AddressSearchScreen> createState() =>
      _AddressSearchScreenState();
}

class _AddressSearchScreenState extends ConsumerState<AddressSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentQuery = '';
  String _debouncedQuery = ''; // 디바운싱된 쿼리
  Address? _selectedAddress;
  Timer? _debounceTimer;

  // 최소 입력 길이 (2자 이상)
  static const int _minQueryLength = 2;
  // 디바운스 시간 (500ms)
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final trimmedValue = value.trim();
    
    setState(() {
      _currentQuery = trimmedValue;
    });

    // 디바운싱: 이전 타이머 취소
    _debounceTimer?.cancel();

    // 최소 입력 길이 미만이면 검색하지 않음
    if (trimmedValue.length < _minQueryLength) {
      setState(() {
        _debouncedQuery = '';
      });
      // provider도 무효화
      if (mounted) {
        ref.invalidate(addressSearchProvider(''));
      }
      return;
    }

    // 새로운 타이머 시작
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && _currentQuery == trimmedValue) {
        // 쿼리가 변경되지 않았을 때만 업데이트
        setState(() {
          _debouncedQuery = trimmedValue;
        });
      }
    });
  }

  void _selectAddress(Address address) async {
    // 좌표가 없는 경우 (우편번호 검색 결과) 네이버 지도 API로 좌표 가져오기
    Address finalAddress = address;
    if (address.x == 0 && address.y == 0 && address.roadAddress.isNotEmpty) {
      try {
        final service = ref.read(addressServiceProvider);
        final geocodedAddress = await service.geocodeAddress(
          address.roadAddress,
          address.jibunAddress.isNotEmpty ? address.jibunAddress : null,
        );
        finalAddress = address.copyWith(
          x: geocodedAddress.x,
          y: geocodedAddress.y,
        );
      } catch (e) {
        // 좌표 가져오기 실패해도 계속 진행 (좌표 없이 사용)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('좌표 정보를 가져오지 못했습니다. 주소만 사용합니다.'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
    
    // 세부 주소 입력 다이얼로그 표시
    final detailAddress = await _showDetailAddressDialog(finalAddress);
    
    // 세부 주소가 입력된 경우 주소에 추가
    final finalAddressWithDetail = detailAddress != null
        ? finalAddress.copyWith(detailAddress: detailAddress)
        : finalAddress;
    
    setState(() {
      _selectedAddress = finalAddressWithDetail;
    });
    widget.onAddressSelected?.call(finalAddressWithDetail);
    Navigator.of(context).pop(finalAddressWithDetail);
  }

  Future<String?> _showDetailAddressDialog(Address address) async {
    final detailController = TextEditingController();
    
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('세부 주소 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address.roadAddress.isNotEmpty
                  ? address.roadAddress
                  : address.jibunAddress,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailController,
              decoration: const InputDecoration(
                labelText: '세부 주소 (선택)',
                hintText: '예: 101동 301호',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              '동, 호수 등을 입력해주세요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('건너뛰기'),
          ),
          ElevatedButton(
            onPressed: () {
              final detail = detailController.text.trim();
              Navigator.of(context).pop(detail.isEmpty ? null : detail);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 디바운싱된 쿼리를 사용하여 API 요청
    final searchAsync = _debouncedQuery.isNotEmpty
        ? ref.watch(addressSearchProvider(_debouncedQuery))
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.iconPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '주소 검색',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // 검색 입력 필드
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '도로명, 지번, 건물명, 우편번호로 검색 (최소 $_minQueryLength자 이상)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
          ),

          // 검색 결과
          Expanded(
            child: _buildSearchResultsWidget(searchAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsWidget(AsyncValue<AddressSearchResult>? searchAsync) {
    // 입력이 없거나 최소 길이 미만
    if (_currentQuery.isEmpty) {
      return _buildEmptyState();
    }

    if (_currentQuery.length < _minQueryLength) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '최소 $_minQueryLength자 이상 입력해주세요',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    // 디바운싱 중 (아직 API 요청 전)
    if (_debouncedQuery.isEmpty || _debouncedQuery != _currentQuery) {
      return _buildLoadingState();
    }

    // API 요청 결과 표시
    if (searchAsync == null) {
      return _buildLoadingState(); // null이면 로딩 상태로 표시
    }

    return searchAsync.when(
      data: (result) {
        // 데이터가 있지만 주소 목록이 비어있으면 빈 상태 표시
        if (result.addresses.isEmpty) {
          return _buildEmptyState();
        }
        return _buildSearchResults(result);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) {
        // 에러 발생 시 상세 로그
        debugPrint('[AddressSearchScreen] Error: $error');
        debugPrint('[AddressSearchScreen] Stack: $stack');
        debugPrint('[AddressSearchScreen] Query: $_debouncedQuery');
        return _buildErrorState(error);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '주소를 검색해주세요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '도로명, 지번, 건물명, 우편번호로 검색할 수 있습니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(Object error) {
    // 우편번호 검색인지 확인 (5자리 숫자)
    final isPostalCode = RegExp(r'^\d{5}$').hasMatch(_debouncedQuery);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            isPostalCode ? '우편번호 검색에 실패했습니다' : '주소 검색에 실패했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isPostalCode
                ? '네이버 지도 API가 우편번호 검색을 지원하지 않을 수 있습니다.\n도로명, 지번, 건물명으로 검색해보세요.'
                : error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_debouncedQuery.isNotEmpty) {
                ref.refresh(addressSearchProvider(_debouncedQuery));
              }
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AddressSearchResult result) {
    if (result.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 검색어로 시도해보세요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: result.addresses.length,
      itemBuilder: (context, index) {
        final address = result.addresses[index];
        return _buildAddressItem(address);
      },
    );
  }

  Widget _buildAddressItem(Address address) {
    final isSelected = _selectedAddress?.roadAddress == address.roadAddress;

    return InkWell(
      onTap: () => _selectAddress(address),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on,
              color: isSelected ? AppColors.primary : AppColors.iconSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address.roadAddress.isNotEmpty)
                    Text(
                      address.roadAddress,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  if (address.roadAddress.isNotEmpty &&
                      address.jibunAddress.isNotEmpty)
                    const SizedBox(height: 4),
                  if (address.jibunAddress.isNotEmpty)
                    Text(
                      '지번: ${address.jibunAddress}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

