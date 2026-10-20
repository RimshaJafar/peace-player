import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/features/quran_hadith/screens/juzz_ayah_list_screen.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/juzz_list_tile.dart';

class JuzzListScreen extends StatefulWidget {
  const JuzzListScreen({super.key});

  @override
  State<JuzzListScreen> createState() => _JuzListScreenState();
}

class _JuzListScreenState extends State<JuzzListScreen> {
  final QuranHadithController controller = Get.put(QuranHadithController());
  late String externalJuzTileLeftName;
  String externalJuzTileRightName =
      QuranHadithDefaults.externalJuzTileRightName;
  String innerJuzAyahsBismillahTileRightName =
      QuranHadithDefaults.innerJuzAyahsBismillahTileRightName;

  @override
  void initState() {
    super.initState();
    externalJuzTileLeftName = QuranHadithDefaults.externalJuzTileLeftName;
    controller.fetchJuz(); // Fetch data before widget build
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.juzError.value.isNotEmpty && controller.juz.isEmpty) {
          return _RetryState(
            message: controller.juzError.value,
            onRetry: () => controller.fetchJuz(),
          );
        }
        if (controller.juz.isEmpty) {
          return const Center(child: Text('No Juz found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 24.0),
          itemCount: controller.juz.length,
          itemBuilder: (context, index) {
            final juz = controller.juz[index];

            return JuzzListTile(
              juzNumber: juz.juzNumber,
              juzNameEnglish: juz.juzName[externalJuzTileLeftName] ?? '',
              juzNameArabic: juz.juzName[externalJuzTileRightName] ?? '',
              startAyahNumber: juz.startAyahNumber,
              endAyahNumber: juz.endAyahNumber,
              onTap: () {
                Get.to(() => JuzzAyah(
                      juzNumber: juz.juzNumber,
                      juzName:
                          juz.juzName[innerJuzAyahsBismillahTileRightName] ??
                              '',
                    ));
              },
            );
          },
        );
      }),
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
// import 'package:ecommerce_app/features/quran_hadith/screens/ayah_list_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// class JuzzListScreen extends StatefulWidget {
//   const JuzzListScreen({super.key});

//   @override
//   State<JuzzListScreen> createState() => _JuzListScreenState();
// }

// class _JuzListScreenState extends State<JuzzListScreen> {
//   final QuranHadithController controller = Get.put(QuranHadithController());

//   @override
//   void initState() {
//     super.initState();
//     controller.fetchJuz(); // Fetch data before widget build
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }
//         return ListView.builder(
//           padding: const EdgeInsets.only(top: 24.0),
//           itemCount: controller.juz.length,
//           itemBuilder: (context, index) {
//             final juz = controller.juz[index];

//             return Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//               child: Container(
//                 // Remove fixed height here to prevent overflow
//                 // height: 80,
//                 decoration: BoxDecoration(
//                   color: Color(0xFFE6F0EF),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha(
//                           (255 * 0.14).toInt()), // subtle black shadow
//                       offset: Offset(0, 1), // x=0, y=1
//                       blurRadius: 2.0, // soft blur
//                       spreadRadius: 0.0, // no spread
//                     ),
//                   ],
//                 ),
//                 child: ListTile(
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   title: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize
//                         .min, // Important: lets Column shrink wrap content
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Left side: "1 - English Name"
//                           Expanded(
//                             flex: 3,
//                             child: Text(
//                               "${juz.number}   ${juz.nameEnglish}",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),

//                           // Right side: Arabic name in Amiri font
//                           Text(
//                             juz.name,
//                             textAlign: TextAlign.right,
//                             style: GoogleFonts.amiri(
//                               fontSize: 22,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 14),
//                       Container(
//                         width: 110,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               Color(0xFF60BEA8),
//                               Color(0xFF329070),
//                               Color(0xFF1C5D4E),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withAlpha(
//                                   (255 * 0.1).toInt()), // subtle shadow
//                               blurRadius: 6,
//                               offset: const Offset(2, 2),
//                             ),
//                           ],
//                         ),
//                         child: Center(
//                           child: Text(
//                             "${juz.startAyahNumber} - ${juz.endAyahNumber}",
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     Future.delayed(Duration.zero, () {
//                       Get.to(() =>
//                           JuzzAyah(juzNumber: juz.number, juzName: juz.name));
//                     });
//                   },
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
