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
      return;
    }

    // 새로운 타이머 시작
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        setState(() {
          _debouncedQuery = trimmedValue;
        });
      }
    });
  }

  void _selectAddress(Address address) {
    setState(() {
      _selectedAddress = address;
    });
    widget.onAddressSelected?.call(address);
    Navigator.of(context).pop(address);
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
                hintText: '도로명, 지번, 건물명으로 검색 (최소 $_minQueryLength자 이상)',
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
      return _buildEmptyState();
    }

    return searchAsync.when(
      data: (result) => _buildSearchResults(result),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
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
            '도로명, 지번, 건물명으로 검색할 수 있습니다',
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
            '주소 검색에 실패했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
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

