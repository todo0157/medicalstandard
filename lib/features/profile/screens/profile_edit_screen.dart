import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../core/errors/app_exception.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageController = TextEditingController();
  final _appointmentCountController = TextEditingController();
  final _treatmentCountController = TextEditingController();
  Map<String, List<String>>? _serverIssues;
  bool _initialized = false;
  bool _isPractitioner = false;
  Gender _gender = Gender.male;
  CertificationStatus _certificationStatus = CertificationStatus.none;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageController.dispose();
    _appointmentCountController.dispose();
    _treatmentCountController.dispose();
    super.dispose();
  }

  void _hydrate(UserProfile profile) {
    if (_initialized) return;
    _nameController.text = profile.name;
    _ageController.text = profile.age.toString();
    _addressController.text = profile.address;
    _phoneController.text = profile.phoneNumber ?? '';
    _imageController.text = profile.profileImageUrl ?? '';
    _appointmentCountController.text = profile.appointmentCount.toString();
    _treatmentCountController.text = profile.treatmentCount.toString();
    _gender = profile.gender;
    _isPractitioner = profile.isPractitioner;
    _certificationStatus = profile.certificationStatus;
    _initialized = true;
  }

  void _clearServerIssuesFor(String key) {
    if (_serverIssues == null || !_serverIssues!.containsKey(key)) return;
    setState(() {
      final cloned = Map<String, List<String>>.from(_serverIssues!);
      cloned.remove(key);
      _serverIssues = cloned.isEmpty ? null : cloned;
    });
  }

  String? _fieldError(String key, String? localError) {
    if (localError != null) return localError;
    return _serverIssues?[key]?.first;
  }

  Future<void> _handleSave(UserProfile original) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _serverIssues = null;
    });
    try {
      final updated = original.copyWith(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? original.age,
        address: _addressController.text.trim(),
        gender: _gender,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        profileImageUrl: _imageController.text.trim().isEmpty
            ? null
            : _imageController.text.trim(),
        appointmentCount:
            int.tryParse(_appointmentCountController.text) ??
            original.appointmentCount,
        treatmentCount:
            int.tryParse(_treatmentCountController.text) ??
            original.treatmentCount,
        isPractitioner: _isPractitioner,
        certificationStatus: _certificationStatus,
      );

      await ref
          .read(profileStateNotifierProvider.notifier)
          .updateProfile(updated);
      // 프로필 상태를 강제로 새로고침하여 최신 데이터를 가져옴
      await ref
          .read(profileStateNotifierProvider.notifier)
          .loadProfile(forceRefresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다.')));
      context.pop(true);
    } catch (error) {
      if (error is AppException &&
          error.type == AppExceptionType.validation &&
          error.issues != null) {
        setState(() {
          _serverIssues = error.issues;
        });
        _formKey.currentState!.validate();
        if (!mounted) return;
        // 검증 에러는 필드별로 표시되므로 전체 메시지는 표시하지 않음
        return;
      }
      if (!mounted) return;
      final errorMessage = error is AppException
          ? error.message
          : '저장 중 오류가 발생했습니다: $error';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isSaving || profileState is! AsyncData<UserProfile>
                ? null
                : () => _handleSave(profileState.value),
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('프로필을 불러오지 못했습니다: $error')),
        data: (profile) {
          _hydrate(profile);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTextField(
                  label: '이름',
                  controller: _nameController,
                  onChanged: (_) => _clearServerIssuesFor('name'),
                  validator: (value) => _fieldError(
                    'name',
                    (value == null || value.trim().isEmpty)
                        ? '이름을 입력해주세요.'
                        : null,
                  ),
                ),
                _buildNumberField(
                  label: '나이',
                  controller: _ageController,
                  onChanged: (_) => _clearServerIssuesFor('age'),
                  validator: (value) => _fieldError('age', () {
                    final age = int.tryParse(value ?? '');
                    if (age == null || age < 0) return '올바른 나이를 입력해주세요.';
                    return null;
                  }()),
                ),
                _buildDropdown<Gender>(
                  label: '성별',
                  value: _gender,
                  items: Gender.values,
                  itemLabel: (g) => g == Gender.male ? '남성' : '여성',
                  onChanged: (value) {
                    _clearServerIssuesFor('gender');
                    setState(() => _gender = value ?? _gender);
                  },
                ),
                _buildTextField(
                  label: '주소',
                  controller: _addressController,
                  onChanged: (_) => _clearServerIssuesFor('address'),
                  validator: (value) => _fieldError(
                    'address',
                    (value == null || value.trim().isEmpty)
                        ? '주소를 입력해주세요.'
                        : null,
                  ),
                ),
                _buildTextField(
                  label: '전화번호',
                  controller: _phoneController,
                  onChanged: (_) => _clearServerIssuesFor('phoneNumber'),
                  validator: (value) => _fieldError('phoneNumber', null),
                ),
                _buildTextField(
                  label: '프로필 이미지 URL',
                  controller: _imageController,
                  onChanged: (_) => _clearServerIssuesFor('profileImageUrl'),
                  validator: (value) => _fieldError('profileImageUrl', null),
                ),
                _buildNumberField(
                  label: '진료 횟수',
                  controller: _appointmentCountController,
                  onChanged: (_) => _clearServerIssuesFor('appointmentCount'),
                  validator: (value) => _fieldError('appointmentCount', null),
                ),
                _buildNumberField(
                  label: '치료 횟수',
                  controller: _treatmentCountController,
                  onChanged: (_) => _clearServerIssuesFor('treatmentCount'),
                  validator: (value) => _fieldError('treatmentCount', null),
                ),
                SwitchListTile(
                  value: _isPractitioner,
                  onChanged: (value) {
                    _clearServerIssuesFor('isPractitioner');
                    setState(() => _isPractitioner = value);
                  },
                  title: const Text('한의사 여부'),
                ),
                _buildDropdown<CertificationStatus>(
                  label: '인증 상태',
                  value: _certificationStatus,
                  items: CertificationStatus.values,
                  itemLabel: (s) {
                    switch (s) {
                      case CertificationStatus.none:
                        return '없음';
                      case CertificationStatus.pending:
                        return '검토중';
                      case CertificationStatus.verified:
                        return '인증완료';
                    }
                  },
                  onChanged: (value) {
                    _clearServerIssuesFor('certificationStatus');
                    setState(
                      () =>
                          _certificationStatus = value ?? _certificationStatus,
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _handleSave(profile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '변경 사항 저장',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return _buildTextField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(itemLabel(item)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
