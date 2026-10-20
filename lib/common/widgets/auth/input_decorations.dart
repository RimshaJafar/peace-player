import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

class AuthFieldBox extends StatelessWidget {
  const AuthFieldBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [],
      ),
      child: child,
    );
  }
}

class InputDecorations {
  static InputDecoration authInputDecoration({
    required BuildContext context,
    String? label,
    String? hint,
    Widget? prefix,
    bool isRequired = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Center(
                        child: IconTheme.merge(
                          data: const IconThemeData(
                            color: Color(0xFF258A67),
                            size: 25,
                          ),
                          child: prefix,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 72,
        minHeight: 64,
      ),
      prefixIconColor: const Color(0xFF329070),
      suffixIconColor: const Color(0xFF258A67),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 58,
        minHeight: 64,
      ),
      label: _buildLabel(label, isRequired),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: const TextStyle(
        color: Color(0xFF4E5661),
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 19,
        horizontal: PSizes.md,
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8A9492),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDAE5E1), width: 1.15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDAE5E1), width: 1.15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFBFD2CB), width: 1.15),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.25),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.55),
      ),
    );
  }

  static Widget? _buildLabel(String? label, bool isRequired) {
    if (label == null) return null;

    const labelStyle = TextStyle(
      color: Color(0xFF4E5661),
      fontSize: 18,
      fontWeight: FontWeight.w400,
    );

    if (!isRequired) {
      return Text(
        label,
        style: labelStyle,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        text: label,
        style: labelStyle,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
