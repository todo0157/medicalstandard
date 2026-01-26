import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';

class AppChatInput extends StatefulWidget {
  const AppChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttachmentPressed,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachmentPressed;

  @override
  State<AppChatInput> createState() => _AppChatInputState();
}

class _AppChatInputState extends State<AppChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 첨부 파일 버튼 (추후 구현)
              IconButton(
                icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.textSecondary),
                onPressed: widget.onAttachmentPressed,
                splashRadius: 24,
                padding: EdgeInsets.all(AppSpacing.xs),
                constraints: BoxConstraints(),
              ),
              SizedBox(width: AppSpacing.xs),
              
              // 텍스트 입력 필드
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          maxLines: 5,
                          minLines: 1,
                          style: AppTypography.bodyMedium,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            if (_hasText) widget.onSend();
                          },
                          decoration: InputDecoration(
                            hintText: '메시지 입력...',
                            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 10, // 높이 조절
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: AppSpacing.sm),
              
              // 전송 버튼
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _hasText ? AppColors.primary : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_upward_rounded, 
                    color: _hasText ? Colors.white : AppColors.textDisabled,
                    size: 20,
                  ),
                  onPressed: _hasText ? widget.onSend : null,
                  splashRadius: 24,
                  padding: EdgeInsets.all(AppSpacing.xs),
                  constraints: BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

