import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../providers/life_providers.dart';

class HealthTipDetailScreen extends ConsumerWidget {
  final String tipId;

  const HealthTipDetailScreen({super.key, required this.tipId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipAsync = ref.watch(healthTipDetailProvider(tipId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("건강 정보 상세"),
        centerTitle: true,
      ),
      body: tipAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("정보를 불러올 수 없습니다.")),
        data: (tip) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tip.imageUrl != null)
                Image.network(
                  tip.imageUrl!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tip.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tip.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(tip.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '조회수 ${tip.viewCount}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),
                    // Markdown 지원
                    MarkdownBody(
                      data: tip.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF374151)),
                        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 2.0),
                        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.8),
                        listBullet: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

