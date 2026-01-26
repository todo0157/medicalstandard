import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/chat_message.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';

class AppMessageBubble extends StatelessWidget {
  const AppMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.showAvatar = true,
    this.showTime = true,
    this.senderName,
  });

  final ChatMessage message;
  final bool isUser;
  final bool showAvatar;
  final bool showTime;
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor = isUser ? AppColors.primary : Colors.white;
    final textColor = isUser ? Colors.white : AppColors.textPrimary;
    final timeFormat = DateFormat('a h:mm', 'ko'); // 오전/오후 h:mm
    final messageTime = message.createdAt.toLocal();
    final timeString = timeFormat.format(messageTime);

    // 말풍선 모서리 설정 (보낸 사람에 따라 꼬리 위치 다르게)
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.sm,
        top: showAvatar ? 0 : 2.0,
      ),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 상대방 프로필 아바타 (왼쪽)
          if (!isUser)
            Container(
              margin: EdgeInsets.only(right: AppSpacing.xs),
              width: 36,
              height: 36,
              child: showAvatar
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceVariant,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Center(
                        child: Icon(Icons.person, color: AppColors.iconSecondary, size: 20),
                      ),
                    )
                  : null, // 아바타 숨김 공간 확보
            ),

          // 메시지 내용 및 시간
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 상대방 이름 (첫 메시지일 때만)
                if (!isUser && showAvatar && senderName != null)
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xs, bottom: 4),
                    child: Text(
                      senderName!,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    // 시간 표시 (사용자 메시지인 경우 왼쪽)
                    if (isUser && showTime)
                      Padding(
                        padding: EdgeInsets.only(right: 6, bottom: 2),
                        child: _buildTimeText(timeString, message.readAt != null),
                      ),

                    // 말풍선
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: borderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          message.content,
                          style: AppTypography.bodyMedium.copyWith(
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),

                    // 시간 표시 (상대방 메시지인 경우 오른쪽)
                    if (!isUser && showTime)
                      Padding(
                        padding: EdgeInsets.only(left: 6, bottom: 2),
                        child: _buildTimeText(timeString, false),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeText(String time, bool isRead) {
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (isUser && !isRead)
          Text(
            '1', // 안 읽음 표시 (카카오톡 스타일)
            style: AppTypography.captionSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        Text(
          time,
          style: AppTypography.captionSmall.copyWith(color: AppColors.textHint, fontSize: 10),
        ),
      ],
    );
  }
}

