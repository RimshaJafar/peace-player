import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/dropdown_list_tile.dart';
import 'package:ecommerce_app/common/widgets/dialogs/checklist_dialog.dart';
import 'package:ecommerce_app/common/layouts/simple_tabs.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ecommerce_app/features/lifeevents/screens/Pilgrimage_duas_screen.dart';
import 'package:ecommerce_app/features/home/controllers/home_controller.dart';
import 'package:ecommerce_app/common/controllers/audio_tts_stt_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class PilgrimageGuidanceScreen extends StatefulWidget {
  const PilgrimageGuidanceScreen({super.key});

  @override
  State<PilgrimageGuidanceScreen> createState() =>
      _PilgrimageGuidanceScreenState();
}

class _PilgrimageGuidanceScreenState extends State<PilgrimageGuidanceScreen> {
  final Color primaryColor = const Color(0xFF346B8C);
  final HomeController controller = Get.find<HomeController>();
  late AudioTTSSTTController audioController;
  late UserController userController;
  late AuthenticationRepository authRepo;
  final storage = GetStorage();

  // Persistent checklist state
  final Set<int> hajjChecked = <int>{};
  final Set<int> umrahChecked = <int>{};

  // User ID for per-user storage
  String? currentUserId;

  // Storage keys (will be prefixed with user ID)
  static const String hajjChecklistKey = 'hajj_checklist_items';
  static const String umrahChecklistKey = 'umrah_checklist_items';

  int selectedIndex = 0; // 0 = Hajj, 1 = Umrah

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioTTSSTTController>();
    userController = Get.find<UserController>();
    authRepo = Get.find<AuthenticationRepository>();

    // Get current user ID
    if (authRepo.isLoggedInRx.value) {
      currentUserId = userController.user.value.id;
    }

    // Load persisted checklist data
    _loadChecklistData();

    // Fetch life events for both hajj and umrah
    controller.fetchLifeEventsByTag('hajj_umrah', 'hajj');
    controller.fetchLifeEventsByTag('hajj_umrah', 'umrah');
  }

  String _getUserStorageKey(String baseKey) {
    return currentUserId != null ? '${currentUserId}_$baseKey' : baseKey;
  }

  void _loadChecklistData() {
    final hajjKey = _getUserStorageKey(hajjChecklistKey);
    final umrahKey = _getUserStorageKey(umrahChecklistKey);

    final hajjList = storage.read<List>(hajjKey) ?? [];
    final umrahList = storage.read<List>(umrahKey) ?? [];

    hajjChecked.clear();
    umrahChecked.clear();

    // Convert list back to set of integers
    for (var item in hajjList) {
      hajjChecked.add(item as int);
    }
    for (var item in umrahList) {
      umrahChecked.add(item as int);
    }
  }

  void _saveChecklistData(bool isHajj, Set<int> checkedItems) {
    final baseKey = isHajj ? hajjChecklistKey : umrahChecklistKey;
    final key = _getUserStorageKey(baseKey);
    final list = checkedItems.toList();
    storage.write(key, list);
  }

  final List<String> hajjChecklist = [
    // 📄 سفری دستاویزات
    'پاسپورٹ (کم از کم 6 ماہ کی میعاد)',
    'حج ویزا',
    'فلائٹ ٹکٹ',
    'ہوٹل بکنگ کی تصدیق',
    'میننجائٹس ویکسینیشن سرٹیفکیٹ',
    'پاسپورٹ سائز تصاویر (اضافی)',
    'تمام دستاویزات کی فوٹو کاپیاں',
    'میاں بیوی کا نکاح نامہ (اگر ساتھ سفر ہو)',
    'سعودی ریال اور کریڈٹ/ڈیبٹ کارڈ',

    // 👕 لباس اور احرام
    'احرام کے دو سفید بے سلے کپڑے — مرد کے لیے',
    'احرام بیلٹ / کمربند — مرد کے لیے',
    'عبایا (3-4 عدد) — خواتین کے لیے',
    'حجاب / اسکارف (کئی) — خواتین کے لیے',
    'روزمرہ کے ڈھیلے ڈھالے سوتی کپڑے',
    'زیر جامہ / انڈرگارمنٹس (کافی مقدار)',
    'ٹوپی / کوفی — مرد کے لیے',
    'انڈر کیپ / اسکارف — خواتین کے لیے',
    'جرابیں (کئی جوڑے)',

    // 👟 جوتے اور چپل
    'آرام دہ چپل بغیر سلائی (احرام کے لیے) — مرد کے لیے',
    'آرام دہ بند جوتے (لمبی واک کے لیے)',
    'کراکس یا آسانی سے اتارنے والی چپل',
    'جوتے رکھنے کا تھیلا',

    // 🕌 عبادت کی اشیاء
    'نماز کی چٹائی (ہلکی اور فولڈ ہونے والی)',
    'قرآن پاک (جیب سائز)',
    'دعاؤں کی کتاب',
    'تسبیح / ڈیجیٹل تسبیح',
    'قبلہ کمپاس',

    // 🧴 صفائی اور ذاتی نگہداشت
    'بے خوشبو صابن اور شیمپو',
    'بے خوشبو ڈیوڈرنٹ',
    'بے خوشبو موئسچرائزر / کریم',
    'ٹوتھ برش اور ٹوتھ پیسٹ',
    'مسواک',
    'بے خوشبو سن اسکرین',
    'لپ بام (SPF والا)',
    'ناخن تراشنے والی قینچی / نیل کٹر',
    'استرا / شیونگ کٹ — مرد کے لیے',
    'چھوٹا تولیہ (مائیکرو فائبر)',
    'ویٹ وائپس / مرطوب ٹشو',
    'ہینڈ سینیٹائزر (بے خوشبو)',

    // 💊 ادویات اور صحت
    'ذاتی نسخے کی ادویات',
    'درد کش ادویات',
    'اینٹی بائیوٹک کریم',
    'سردی، بخار کی ادویات',
    'الرجی کی ادویات',
    'معدے کی ادویات',
    'بینڈیج اور پلاسٹر',
    'پیروں کے چھالوں کا علاج',
    'ORS / ری ہائیڈریشن سیچٹ',
    'ڈاکٹر کا نسخہ (انگریزی میں)',

    // 🎒 بیگ اور سامان
    'درمیانہ سوٹ کیس',
    'چھوٹا بیک پیک (منیٰ، عرفات کے لیے)',
    'بیلٹ پاؤچ / منی بیلٹ',
    'زپ لاک تھیلے (مختلف سائز)',
    'لگیج لاک',

    // 📱 الیکٹرونکس
    'موبائل فون اور چارجر',
    'پاور بینک',
    'یونیورسل ٹریول اڈاپٹر',
    'سعودی سم کارڈ',
    'ہیڈ فون / ایئر بڈز',

    // ☀️ موسم اور آرام
    'سفید چھتری (سن شیڈ)',
    'سن گلاسز',
    'اسپرے بوتل (ٹھنڈے پانی کے لیے)',
    'پانی کی بوتل (دوبارہ بھرنے والی)',
    'نرم اسنیکس (کھجور، بسکٹ، میوے)',

    // ✂️ دیگر اہم اشیاء
    'بال کاٹنے کی قینچی (قصر کے لیے)',
    'سوئی دھاگہ اور سیفٹی پن',
    'پلاسٹک بیگ (گندے کپڑوں کے لیے)',
    'دعاؤں کی ڈائری اور قلم',
    'ایمرجنسی رابطہ نمبروں کی فہرست',
  ];

  final List<String> umrahChecklist = [
    // 📄 سفری دستاویزات
    'پاسپورٹ (کم از کم 6 ماہ کی میعاد)',
    'عمرہ ویزا',
    'فلائٹ ٹکٹ',
    'ہوٹل بکنگ کی تصدیق',
    'میننجائٹس ویکسینیشن سرٹیفکیٹ',
    'پاسپورٹ سائز تصاویر',
    'تمام دستاویزات کی فوٹو کاپیاں',
    'میاں بیوی کا نکاح نامہ (اگر ساتھ سفر ہو)',
    'سعودی ریال اور کریڈٹ/ڈیبٹ کارڈ',

    // 👕 لباس اور احرام
    'احرام کے دو سفید بے سلے کپڑے — مرد کے لیے',
    'احرام بیلٹ / کمربند — مرد کے لیے',
    'عبایا (3 عدد) — خواتین کے لیے',
    'حجاب / اسکارف (کئی) — خواتین کے لیے',
    'روزمرہ کے ڈھیلے ڈھالے سوتی کپڑے',
    'زیر جامہ / انڈرگارمنٹس (کافی مقدار)',
    'ٹوپی / کوفی — مرد کے لیے',
    'انڈر کیپ / اسکارف — خواتین کے لیے',
    'جرابیں (کئی جوڑے)',

    // 👟 جوتے اور چپل
    'آرام دہ چپل بغیر سلائی (احرام کے لیے) — مرد کے لیے',
    'آرام دہ بند جوتے (لمبی واک کے لیے)',
    'کراکس یا آسانی سے اتارنے والی چپل',
    'جوتے رکھنے کا تھیلا',

    // 🕌 عبادت کی اشیاء
    'نماز کی چٹائی (ہلکی اور فولڈ ہونے والی)',
    'قرآن پاک (جیب سائز)',
    'دعاؤں کی کتاب',
    'تسبیح / ڈیجیٹل تسبیح',
    'قبلہ کمپاس',

    // 🧴 صفائی اور ذاتی نگہداشت
    'بے خوشبو صابن اور شیمپو',
    'بے خوشبو ڈیوڈرنٹ',
    'بے خوشبو موئسچرائزر / کریم',
    'ٹوتھ برش اور ٹوتھ پیسٹ',
    'مسواک',
    'بے خوشبو سن اسکرین',
    'لپ بام',
    'ناخن تراشنے والی قینچی / نیل کٹر',
    'استرا / شیونگ کٹ — مرد کے لیے',
    'چھوٹا تولیہ (مائیکرو فائبر)',
    'ویٹ وائپس / مرطوب ٹشو',
    'ہینڈ سینیٹائزر (بے خوشبو)',

    // 💊 ادویات اور صحت
    'ذاتی نسخے کی ادویات',
    'درد کش ادویات',
    'اینٹی بائیوٹک کریم',
    'سردی، بخار کی ادویات',
    'معدے کی ادویات',
    'بینڈیج اور پلاسٹر',
    'پیروں کے چھالوں کا علاج',
    'ORS / ری ہائیڈریشن سیچٹ',

    // 🎒 بیگ اور سامان
    'سوٹ کیس',
    'چھوٹا بیک پیک',
    'بیلٹ پاؤچ / منی بیلٹ',
    'زپ لاک تھیلے',
    'لگیج لاک',

    // 📱 الیکٹرونکس
    'موبائل فون اور چارجر',
    'پاور بینک',
    'یونیورسل ٹریول اڈاپٹر',
    'سعودی سم کارڈ',
    'ہیڈ فون / ایئر بڈز',

    // ☀️ موسم اور آرام
    'چھتری (سن شیڈ)',
    'سن گلاسز',
    'اسپرے بوتل (ٹھنڈے پانی کے لیے)',
    'پانی کی بوتل (دوبارہ بھرنے والی)',
    'نرم اسنیکس (کھجور، بسکٹ، میوے)',

    // ✂️ دیگر اہم اشیاء
    'بال کاٹنے کی قینچی (قصر کے لیے)',
    'سوئی دھاگہ اور سیفٹی پن',
    'پلاسٹک بیگ (گندے کپڑوں کے لیے)',
    'دعاؤں کی ڈائری اور قلم',
    'ایمرجنسی رابطہ نمبروں کی فہرست',
  ];

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final ttsLanguageCode = textLanguageCode == 'ur' ? 'ur' : 'en';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PAppBar(
        title: Text(
          'Pilgrimage Guidance',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: const ReferenceAyahHadithBox(
              featureKey: 'pilgrimage',
              borderColor: Color(0xFF346B8C),
            ),
          ),
          const SizedBox(height: 24),
          SimpleTabs(
            selectedIndex: selectedIndex,
            onTabSelected: (index) => setState(() => selectedIndex = index),
            tabs: const ['Hajj', 'Umrah'],
            backgroundColor: primaryColor,
            selectedTabColor: Colors.white,
            unselectedTabColor: const Color.fromARGB(255, 0, 0, 0),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Center(
                  child: Material(
                    elevation: 6,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      width: 330,
                      height: 102,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF3C98A0),
                            Color(0xFF2E6E80),
                            Color(0xFF3C467B),
                          ],
                          stops: [0.14, 0.59, 0.9],
                          center: Alignment.center,
                          radius: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildGradientButton(
                              'Checklist',
                              onPressed: () => _showChecklist(),
                            ),
                            const SizedBox(width: 16),
                            _buildGradientButton(
                              'Duas',
                              onPressed: () {
                                Get.to(() => const PilgrimageDuasScreen());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GetBuilder<HomeController>(
                  builder: (homeController) {
                    final mainTag = 'hajj_umrah';
                    final subTag = selectedIndex == 0 ? 'hajj' : 'umrah';
                    final key = '${mainTag}_$subTag';
                    final isLoading = homeController.isLifeEventLoading(key);
                    final items = homeController.getLifeEventItems(key);

                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No steps found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(
                        items.length,
                        (index) {
                          final item = items[index];
                          final audioId = (item.step ?? index).hashCode;
                          final title = AppLanguageHelper.pickText(
                              item.title, titleLanguageCode);
                          final content = AppLanguageHelper.pickText(
                              item.text, textLanguageCode);
                          return DropdownListTile(
                            key: ValueKey(
                                'pilgrimage_${selectedIndex}_${item.step ?? index}'),
                            index: item.step ?? index + 1,
                            title: title.isNotEmpty ? title : '—',
                            content: content,
                            tileColor: primaryColor,
                            showActions: false,
                            onPlayAudio: () {
                              if (content.isNotEmpty) {
                                audioController.textToSpeechSingleLanguage(
                                    content, audioId,
                                    language: ttsLanguageCode);
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, {required VoidCallback onPressed}) {
    return SizedBox(
      width: 110,
      height: 35,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showChecklist() {
    final isHajj = selectedIndex == 0;
    final title = isHajj ? 'Hajj Checklist' : 'Umrah Checklist';
    final List<String> items = List<String>.from(
      isHajj ? hajjChecklist : umrahChecklist,
    );
    final Set<int> checked = isHajj ? hajjChecked : umrahChecked;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return ChecklistDialog(
          title: title,
          items: items,
          checked: checked,
          primaryColor: primaryColor,
          onUpdate: () {
            setState(() {});
            // Save the updated checklist data
            _saveChecklistData(isHajj, checked);
          },
        );
      },
    ).then((_) {
      // Save data when dialog is closed
      _saveChecklistData(isHajj, checked);
    });
  }
}
