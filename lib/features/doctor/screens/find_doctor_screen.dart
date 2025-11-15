import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

class FindDoctorScreen extends StatelessWidget {
  const FindDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.iconPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '한의사 찾기',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          _MapPreview(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _clinics.length,
              itemBuilder: (context, index) {
                final clinic = _clinics[index];
                return _ClinicCard(clinic: clinic);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _NavButton(label: '목록', icon: Icons.list_alt, selected: true),
                _NavButton(label: '지도', icon: Icons.map_outlined),
                _NavButton(label: '즐겨찾기', icon: Icons.favorite_border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage(
                'https://public.readdy.ai/gen_page/map_placeholder_1280x720.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 32,
          top: 28,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ),
        Positioned(
          left: 32,
          right: 32,
          bottom: 24,
          child: _SearchBar(),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textHint),
            const SizedBox(width: 8),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '한의원 이름 또는 지역 검색',
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({required this.clinic});

  final _Clinic clinic;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _DoctorAvatar(imageUrl: clinic.imageUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        clinic.clinicName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFACC15), size: 18),
                        Text(
                          clinic.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  clinic.doctorName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 16, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      clinic.distance,
                      style: const TextStyle(color: AppColors.textHint),
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
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.surfaceVariant,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surfaceVariant,
            child: const Icon(Icons.person, color: AppColors.iconSecondary, size: 32),
          );
        },
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textHint,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.textHint,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _Clinic {
  const _Clinic({
    required this.clinicName,
    required this.doctorName,
    required this.distance,
    required this.rating,
    required this.imageUrl,
  });

  final String clinicName;
  final String doctorName;
  final String distance;
  final double rating;
  final String imageUrl;
}

const List<_Clinic> _clinics = [
  _Clinic(
    clinicName: '청담 한의원',
    doctorName: '김태현 한의사',
    distance: '250m',
    rating: 4.8,
    imageUrl:
        'https://readdy.ai/api/search-image?query=Professional%20korean%20traditional%20medicine%20doctor%20portrait%2C%20middle-aged%20male%2C%20friendly%20smile%2C%20white%20coat&width=160&height=160&seq=doctor1',
  ),
  _Clinic(
    clinicName: '서울 경희 한의원',
    doctorName: '박지영 한의사',
    distance: '320m',
    rating: 4.6,
    imageUrl:
        'https://readdy.ai/api/search-image?query=Professional%20korean%20traditional%20medicine%20doctor%20portrait%2C%20young%20female%2C%20white%20coat&width=160&height=160&seq=doctor2',
  ),
  _Clinic(
    clinicName: '건강 한의원',
    doctorName: '이승호 한의사',
    distance: '450m',
    rating: 4.9,
    imageUrl:
        'https://readdy.ai/api/search-image?query=Professional%20korean%20traditional%20medicine%20doctor%20portrait%2C%20mature%20male%2C%20white%20coat&width=160&height=160&seq=doctor3',
  ),
  _Clinic(
    clinicName: '명동 한의원',
    doctorName: '정민수 한의사',
    distance: '580m',
    rating: 4.7,
    imageUrl:
        'https://readdy.ai/api/search-image?query=Professional%20korean%20traditional%20medicine%20doctor%20portrait%2C%20young%20male%2C%20white%20coat&width=160&height=160&seq=doctor4',
  ),
];
