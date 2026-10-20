import 'package:flutter/material.dart';

class SpiritualNeed {
  final String label;
  final String query;
  final IconData icon;

  const SpiritualNeed({
    required this.label,
    required this.query,
    required this.icon,
  });
}

const spiritualNeeds = <SpiritualNeed>[
  SpiritualNeed(
    label: 'I feel sad',
    query:
        'Islamic emotional nasheed sabr naat Quran recitation comfort',
    icon: Icons.favorite_outline_rounded,
  ),
  SpiritualNeed(
    label: 'I feel stressed',
    query:
        'peaceful Quran recitation stress relief Islamic dua calming nasheed',
    icon: Icons.air_rounded,
  ),
  SpiritualNeed(
    label: 'I need peace',
    query:
        'relaxing Quran recitation peaceful Islamic nasheed heart touching',
    icon: Icons.spa_outlined,
  ),
  SpiritualNeed(
    label: 'I need motivation',
    query: 'Islamic motivational reminder tawakkul sabr hope nasheed',
    icon: Icons.trending_up_rounded,
  ),
  SpiritualNeed(
    label: 'I want Quran recitation',
    query: 'beautiful Quran recitation relaxing tilawat',
    icon: Icons.menu_book_rounded,
  ),
  SpiritualNeed(
    label: 'I want Naat, Nasheed',
    query: 'beautiful naat sharif Islamic nasheed heart touching',
    icon: Icons.mic_none_rounded,
  ),
  SpiritualNeed(
    label: 'I want something uplifting',
    query:
        'uplifting Islamic nasheed hamd shukr positive Islamic reminder',
    icon: Icons.wb_sunny_outlined,
  ),
  SpiritualNeed(
    label: 'I feel spiritually low',
    query:
        'Islamic reminder repentance tawbah Quran heart softening bayan',
    icon: Icons.nights_stay_outlined,
  ),
];
