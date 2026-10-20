// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AppBarDropdownButton extends StatelessWidget {
//   final String label;
//   final RxList<String> items;
//   final RxString selectedValue;
//   final Function(String) onSelected;

//   const AppBarDropdownButton({
//     super.key,
//     required this.label,
//     required this.items,
//     required this.selectedValue,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (items.isEmpty) return const SizedBox();

//       return PopupMenuButton<String>(
//         onSelected: onSelected,
//         itemBuilder: (context) {
//           return items
//               .map(
//                 (item) => PopupMenuItem<String>(
//                   value: item,
//                   child: Text(item),
//                 ),
//               )
//               .toList();
//         },
//         child: Row(
//           children: [
//             Text(label, style: const TextStyle(fontSize: 12)),
//             const Icon(Icons.arrow_drop_down, size: 18),
//             const SizedBox(width: 8),
//           ],
//         ),
//       );
//     });
//   }
// }
