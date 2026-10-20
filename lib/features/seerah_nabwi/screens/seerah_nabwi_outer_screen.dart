import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/seerah_list_tile.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'lineage_tree_screen.dart';
import 'life_chronicle_screen.dart';
import 'physical_attributes_screen.dart';
import 'moral_screen.dart';
import 'social_conduct_screen.dart';
import 'miracles_screen.dart';
import 'naat_screen.dart';
import 'personal_possessions_screen.dart';

class SeerahNabwiOuterScreen extends StatelessWidget {
  const SeerahNabwiOuterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final isUrdu = titleLanguageCode == 'ur';
    final List<Map<String, String>> seerahTopics = [
      {'english': 'Lineage Tree', 'urdu': 'شجرۂ نسب'},
      {'english': 'Life Chronicle', 'urdu': 'مکمل زندگی'},
      {'english': 'Physical Attributes', 'urdu': 'ظاہری خصوصیات'},
      {'english': 'Moral', 'urdu': 'اخلاق'},
      {'english': 'Social Conduct', 'urdu': 'معاشرتی طرزِ عمل'},
      {'english': 'Miracles', 'urdu': 'معجزات'},
      {'english': 'Naat', 'urdu': 'نعت'},
      {'english': 'Personal Possessions', 'urdu': 'ذاتی اشیاء'},
    ];

    final screenRoutes = [
      LineageTreeScreen(),
      const LifeChronicleScreen(),
      const PhysicalAttributesScreen(),
      const MoralScreen(),
      const SocialConductScreen(),
      const MiraclesScreen(),
      const NaatScreen(),
      const PersonalPossessionsScreen(),
    ];

    return Scaffold(
      appBar: PAppBar(
        title: Text(
          'Seerah of Prophet',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: seerahTopics.length,
        itemBuilder: (context, index) {
          final topic = seerahTopics[index];
          return SeerahListTile(
            title: AppLanguageHelper.pickText(topic, titleLanguageCode),
            isUrdu: isUrdu,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => screenRoutes[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
