import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../shared/theme/app_colors.dart';

class CertificationRequestScreen extends ConsumerStatefulWidget {
  const CertificationRequestScreen({super.key});

  @override
  ConsumerState<CertificationRequestScreen> createState() =>
      _CertificationRequestScreenState();
}

class _CertificationRequestScreenState
    extends ConsumerState<CertificationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNumberController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _notesController = TextEditingController();

  File? _licenseImage;
  File? _idCardImage;
  XFile? _licenseImageXFile;
  XFile? _idCardImageXFile;
  Uint8List? _licenseImageBytes;
  Uint8List? _idCardImageBytes;
  bool _isSubmitting = false;
  String? _error;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _clinicNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isLicense) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // 웹과 모바일 모두 지원하도록 처리
        if (kIsWeb) {
          // 웹: XFile에서 직접 바이트 읽기
          final bytes = await image.readAsBytes();
          setState(() {
            if (isLicense) {
              _licenseImageXFile = image;
              _licenseImageBytes = bytes;
              _licenseImage = null;
            } else {
              _idCardImageXFile = image;
              _idCardImageBytes = bytes;
              _idCardImage = null;
            }
            _error = null;
          });
        } else {
          // 모바일: File 사용
          setState(() {
            if (isLicense) {
              _licenseImage = File(image.path);
              _licenseImageXFile = null;
              _licenseImageBytes = null;
            } else {
              _idCardImage = File(image.path);
              _idCardImageXFile = null;
              _idCardImageBytes = null;
            }
            _error = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '이미지를 선택하는 중 오류가 발생했습니다: $e';
        });
      }
    }
  }

  void _showImageSourceDialog(bool isLicense) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isLicense);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isLicense);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCertification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hasLicenseImage = kIsWeb
        ? (_licenseImageBytes != null)
        : (_licenseImage != null);
    
    if (!hasLicenseImage) {
      setState(() {
        _error = '한의사 자격증 이미지를 업로드해주세요.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final profileState = ref.read(profileStateNotifierProvider);
      final profile = profileState.asData?.value;

      if (profile == null) {
        throw const AppException.server(
          message: '프로필 정보를 불러올 수 없습니다.',
        );
      }

      // 자격증 이미지 업로드 (프로필 사진 업로드 API 재사용)
      if (kIsWeb) {
        // 웹: XFile에서 직접 바이트 읽기
        if (_licenseImageXFile == null || _licenseImageBytes == null) {
          throw const AppException.validation(
            message: '자격증 이미지를 선택해주세요.',
          );
        }
        // 웹에서는 바이트를 직접 업로드
        final apiClient = ref.read(apiClientProvider);
        final encoded = base64Encode(_licenseImageBytes!);
        
        // 이미지 크기 체크 (약 10MB 제한)
        if (encoded.length > 10 * 1024 * 1024) {
          throw const AppException.validation(
            message: '이미지 크기가 너무 큽니다. 10MB 이하의 이미지를 선택해주세요.',
          );
        }
        
        // 파일명 추출 (웹에서는 전체 경로가 아닐 수 있음)
        String fileName = _licenseImageXFile!.name;
        if (fileName.isEmpty || !fileName.contains('.')) {
          fileName = 'license.jpg'; // 기본 파일명
        }
        
        await apiClient.post(
          '/profiles/${profile.id}/photo',
          body: {
            'fileName': fileName,
            'imageData': encoded,
          },
        );
      } else {
        // 모바일: 파일 경로 사용
        if (_licenseImage == null) {
          throw const AppException.validation(
            message: '자격증 이미지를 선택해주세요.',
          );
        }
        await ref
            .read(profileStateNotifierProvider.notifier)
            .uploadProfileImage(_licenseImage!.path);
      }

      // 인증 상태를 pending으로 변경 (자격증 번호, 클리닉 이름 포함)
      await ref
          .read(profileStateNotifierProvider.notifier)
          .updateCertificationStatus(
            CertificationStatus.pending,
            licenseNumber: _licenseNumberController.text.trim(),
            clinicName: _clinicNameController.text.trim().isEmpty
                ? null
                : _clinicNameController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('한의사 인증 신청이 완료되었습니다. 검토 후 승인됩니다.'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '인증 신청 중 오류가 발생했습니다.';
        if (e is AppException) {
          errorMessage = e.message;
          // 서버 오류인 경우 더 자세한 정보 표시
          if (e.type == AppExceptionType.server) {
            errorMessage = '${e.message}\n상태 코드: ${e.statusCode ?? '알 수 없음'}';
            if (e.issues != null && e.issues!.isNotEmpty) {
              errorMessage += '\n\n상세 오류:\n${e.issues!.entries.map((e) => '${e.key}: ${e.value.join(", ")}').join('\n')}';
            }
          }
        } else {
          errorMessage = '인증 신청 중 오류가 발생했습니다: ${e.toString()}';
        }
        setState(() {
          _error = errorMessage;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '한의사 인증 신청',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '한의사 인증을 위해 자격증과 신분증을 업로드해주세요.\n검토 후 승인됩니다.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 자격증 번호
            TextFormField(
              controller: _licenseNumberController,
              decoration: InputDecoration(
                labelText: '한의사 자격증 번호',
                hintText: '예: 한의-12345',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.badge, color: AppColors.iconSecondary),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '자격증 번호를 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 병원/클리닉 이름
            TextFormField(
              controller: _clinicNameController,
              decoration: InputDecoration(
                labelText: '병원/클리닉 이름 (선택)',
                hintText: '예: 한방 건강 클리닉',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.local_hospital,
                    color: AppColors.iconSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // 한의사 자격증 이미지
            _buildImageUploadSection(
              title: '한의사 자격증 이미지',
              subtitle: '자격증 사진을 촬영하거나 업로드해주세요',
              image: _licenseImage,
              onTap: () => _showImageSourceDialog(true),
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 신분증 이미지 (선택)
            _buildImageUploadSection(
              title: '신분증 이미지 (선택)',
              subtitle: '본인 확인을 위해 신분증을 업로드해주세요',
              image: _idCardImage,
              onTap: () => _showImageSourceDialog(false),
              isRequired: false,
            ),
            const SizedBox(height: 16),

            // 추가 메모
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: '추가 메모 (선택)',
                hintText: '인증과 관련하여 추가로 전달할 사항이 있으면 입력해주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.note, color: AppColors.iconSecondary),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 에러 메시지
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null) const SizedBox(height: 16),

            // 제출 버튼
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCertification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '인증 신청하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    // 웹과 모바일 모두 지원
    final hasImage = kIsWeb
        ? (title.contains('자격증') ? _licenseImageBytes != null : _idCardImageBytes != null)
        : (image != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage
                    ? AppColors.primary
                    : AppColors.border,
                width: 2,
              ),
            ),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.memory(
                                title.contains('자격증')
                                    ? _licenseImageBytes!
                                    : _idCardImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                image!,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (title.contains('자격증')) {
                                  _licenseImage = null;
                                  _licenseImageXFile = null;
                                  _licenseImageBytes = null;
                                } else {
                                  _idCardImage = null;
                                  _idCardImageXFile = null;
                                  _idCardImageBytes = null;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: AppColors.iconSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '이미지 선택',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

