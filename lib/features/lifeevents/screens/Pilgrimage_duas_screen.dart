import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/layouts/simple_tabs.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
import 'package:ecommerce_app/features/home/models/worship_item_model.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class PilgrimageDuasScreen extends StatefulWidget {
  const PilgrimageDuasScreen({super.key});

  @override
  State<PilgrimageDuasScreen> createState() => _PilgrimageDuasScreenState();
}

class _PilgrimageDuasScreenState extends State<PilgrimageDuasScreen> {
  final Color primaryColor = const Color(0xFF346B8C);
  final HomeController controller = Get.find<HomeController>();
  int selectedIndex = 0; // 0 = Hajj, 1 = Umrah

  @override
  void initState() {
    super.initState();
    if (controller.getTagWorshipItems('dua').isEmpty) {
      controller.fetchWorshipByTag('dua');
    }
  }

  List<WorshipItem> _getCurrentDuas() {
    final subTag = selectedIndex == 0 ? 'pilgrimage_hajj' : 'pilgrimage_umrah';
    return controller.filterWorshipBySubTag(
      controller.getTagWorshipItems('dua'),
      subTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PAppBar(
        title: Text(
          'Pilgrimage Duas',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/content/hajj_umrah.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SimpleTabs(
              selectedIndex: selectedIndex,
              onTabSelected: (index) => setState(() => selectedIndex = index),
              tabs: const ['Hajj', 'Umrah'],
              backgroundColor: primaryColor,
              selectedTabColor: Colors.white,
              unselectedTabColor: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          Expanded(
            child: GetBuilder<HomeController>(
              builder: (homeController) {
                final isLoading = homeController.isTagLoading('dua');
                final duaas = _getCurrentDuas();

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (duaas.isEmpty) {
                  return Center(
                    child: Text(
                      'No duas found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: duaas.length,
                  itemBuilder: (context, index) {
                    final item = duaas[index];
                    final title = AppLanguageHelper.pickText(
                      item.title,
                      textLanguageCode,
                    );
                    final translation = AppLanguageHelper.pickText(
                      item.translations,
                      textLanguageCode,
                    );

                    return DropdownListTile(
                      key: ValueKey(
                          'pilgrimage_dua_${selectedIndex}_${item.id}'),
                      title: title.isNotEmpty ? title : '—',
                      arabic: item.textArabic ?? '',
                      translation: translation,
                      tileColor: primaryColor,
                      showBookmark: false,
                      isSaved: false,
                      onSaveToggle: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
