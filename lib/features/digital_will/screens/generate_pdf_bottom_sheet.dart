import 'package:ecommerce_app/common/widgets/digital_will/pdf_dropdown_selector.dart';
import 'package:ecommerce_app/common/widgets/digital_will/pdf_options_toggle_tile.dart';
import 'package:ecommerce_app/common/widgets/digital_will/pdf_template_card.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/common/models/country_model.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/digital_will_landing.dart';
import 'package:ecommerce_app/utils/constants/pdf_constants.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium bottom sheet for configuring and generating Islamic Will PDFs.
class GeneratePdfBottomSheet extends StatelessWidget {
  const GeneratePdfBottomSheet({
    super.key,
    this.countryName,
    this.deceasedName,
  });

  final String? countryName;
  final String? deceasedName;

  static Future<void> show(
    BuildContext context, {
    String? countryName,
    String? deceasedName,
  }) async {
    final String? trimmedCountry = countryName?.trim();
    final ExternalServiceController externalController =
        Get.isRegistered<ExternalServiceController>()
            ? Get.find<ExternalServiceController>()
            : Get.put(ExternalServiceController());
    if (externalController.countries.isEmpty) {
      await externalController.fetchCountries();
    }

    final PdfGenerationController pdfController =
        Get.isRegistered<PdfGenerationController>()
            ? Get.find<PdfGenerationController>()
            : Get.put(PdfGenerationController());

    if (trimmedCountry != null && trimmedCountry.isNotEmpty) {
      pdfController.setCountryName(trimmedCountry);
    }
    if (deceasedName != null && deceasedName.trim().isNotEmpty) {
      pdfController.setDeceasedName(deceasedName.trim());
    }

    // Resolve missing countryName and deceasedName from DigitalWillController
    if (Get.isRegistered<DigitalWillController>()) {
      final DigitalWillController willController =
          Get.find<DigitalWillController>();

      // Try to fill country name if missing
      if ((pdfController.countryName ?? '').trim().isEmpty) {
        String? resolvedCountry;
        final String? reqCountry =
            willController.basicInfo?.countryJurisdiction;
        if (reqCountry != null && reqCountry.trim().isNotEmpty) {
          resolvedCountry = reqCountry.trim();
        }
        if (resolvedCountry == null) {
          final String? respCountry =
              willController.lastResponse.value?.basicInfo.countryJurisdiction;
          if (respCountry != null && respCountry.trim().isNotEmpty) {
            resolvedCountry = respCountry.trim();
          }
        }
        if (resolvedCountry != null) {
          pdfController.setCountryName(resolvedCountry);
        }
      }

      // Try to fill deceased name if missing
      if ((pdfController.deceasedName ?? '').trim().isEmpty) {
        String? resolvedName;
        final String? reqName = willController.basicInfo?.fullName;
        if (reqName != null && reqName.trim().isNotEmpty) {
          resolvedName = reqName.trim();
        }
        if (resolvedName == null) {
          final String? respName =
              willController.lastResponse.value?.basicInfo.fullName;
          if (respName != null && respName.trim().isNotEmpty) {
            resolvedName = respName.trim();
          }
        }
        if (resolvedName != null) {
          pdfController.setDeceasedName(resolvedName);
        }
      }
    }

    _seedCountryDefaultsForController(
      controller: pdfController,
      externalController: externalController,
      explicitCountryName: trimmedCountry,
    );

    if (!context.mounted) {
      return;
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GeneratePdfBottomSheet(
        countryName: trimmedCountry,
        deceasedName: deceasedName?.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PdfGenerationController controller =
        Get.find<PdfGenerationController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: <Widget>[
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 14),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCDAD4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFF1A5B48),
                            Color(0xFF2A7E66),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color:
                                const Color(0xFF1A5B48).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Generate Islamic Will PDF',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C3D35),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Configure your document settings',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF7A9B91),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: const Color(0xFFF0F5F3),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            color: Color(0xFF5A7A70),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Divider under header
              const Divider(height: 1, thickness: 1, color: Color(0xFFEAF0ED)),

              // Scrollable content
              Expanded(
                child: Obx(() {
                  if (controller.isGenerating) {
                    return const _GeneratingState();
                  }
                  if (controller.isDownloading) {
                    return const _GeneratingState(
                        message: 'Downloading PDF...',
                        subtitle: 'Saving your document to device storage...');
                  }
                  if ((controller.isSuccess ||
                          controller.lastGeneratedPdf.value != null) &&
                      controller.state.value != PdfGenerationState.error &&
                      controller.state.value !=
                          PdfGenerationState.configuring) {
                    return _SuccessState(
                      controller: controller,
                      onClose: () {
                        Navigator.of(context).pop();
                        Get.offAll(
                          () => const DigitalWillLandingScreen(),
                        );
                      },
                    );
                  }
                  if (controller.hasError) {
                    return _ErrorState(controller: controller);
                  }

                  return _ConfigurationForm(
                    scrollController: scrollController,
                    controller: controller,
                    explicitCountryName: countryName,
                  );
                }),
              ),

              // Bottom action button
              Obx(() {
                if (controller.isGenerating ||
                    controller.isDownloading ||
                    controller.isSuccess ||
                    controller.hasError) {
                  return const SizedBox.shrink();
                }
                return _GenerateButton(controller: controller);
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── Configuration Form ──────────────────────────────────────────────────────

class _ConfigurationForm extends StatelessWidget {
  const _ConfigurationForm({
    required this.scrollController,
    required this.controller,
    required this.explicitCountryName,
  });

  final ScrollController scrollController;
  final PdfGenerationController controller;
  final String? explicitCountryName;

  @override
  Widget build(BuildContext context) {
    final ExternalServiceController externalController =
        Get.isRegistered<ExternalServiceController>()
            ? Get.find<ExternalServiceController>()
            : Get.put(ExternalServiceController());
    if (externalController.countries.isEmpty &&
        !externalController.isLoadingCountries.value) {
      externalController.fetchCountries();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: <Widget>[
            const SizedBox(height: 16),

            // Section 1 — Language
            _SectionHeader(
              title: 'Language',
              number: '1',
              icon: Icons.language_rounded,
            ),
            const SizedBox(height: 10),
            Obx(() => PdfDropdownSelector<String>(
                  label: 'Document Language',
                  value: controller.selectedLanguage.value,
                  icon: Icons.translate_rounded,
                  items: PdfConstants.languages
                      .map((lang) => PdfDropdownItem<String>(
                            value: lang.code,
                            label: lang.label,
                            subtitle: lang.isRtl ? 'RTL Support' : 'LTR',
                          ))
                      .toList(),
                  onChanged: (String value) {
                    controller.selectedLanguage.value = value;
                  },
                )),

            const SizedBox(height: 36),

            // Section 2 — Template
            _SectionHeader(
              title: 'Template',
              number: '2',
              icon: Icons.dashboard_customize_rounded,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const gridSpacing = 12.0;
                final crossAxisCount = PSizes.isTablet(context) ? 3 : 2;
                final cardWidth = (constraints.maxWidth -
                        (gridSpacing * (crossAxisCount - 1))) /
                    crossAxisCount;
                final cardHeight = cardWidth < 160.0 ? 160.0 : cardWidth;
                final rowCount =
                    (PdfConstants.templates.length / crossAxisCount).ceil();
                final gridHeight =
                    (cardHeight * rowCount) + (gridSpacing * (rowCount - 1));

                return SizedBox(
                  height: gridHeight,
                  child: Obx(
                    () => GridView.count(
                      crossAxisCount: crossAxisCount,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                      childAspectRatio: cardWidth / cardHeight,
                      children: PdfConstants.templates.map((template) {
                        return PdfTemplateCard(
                          code: template.code,
                          label: template.label,
                          description: template.description,
                          icon: _templateIcon(template.icon),
                          isSelected: controller.selectedTemplate.value ==
                              template.code,
                          onTap: () {
                            controller.selectedTemplate.value = template.code;
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 36),

            // Section 3 — Narration Style
            _SectionHeader(
              title: 'Narration Style',
              number: '3',
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 10),
            Obx(() => PdfDropdownSelector<String>(
                  label: 'Writing Style',
                  value: controller.selectedNarrationStyle.value,
                  icon: Icons.format_quote_rounded,
                  items: PdfConstants.narrationStyles
                      .map((style) => PdfDropdownItem<String>(
                            value: style.code,
                            label: style.label,
                            subtitle: style.description,
                          ))
                      .toList(),
                  onChanged: (String value) {
                    controller.selectedNarrationStyle.value = value;
                  },
                )),

            const SizedBox(height: 36),

            // Section 4 — Currency
            _SectionHeader(
              title: 'Currency',
              number: '4',
              icon: Icons.monetization_on_outlined,
            ),
            const SizedBox(height: 10),
            Obx(() {
              externalController.countries.length;
              externalController.isLoadingCountries.value;
              final String? countryName = _resolveCountryNameForPdf(
                explicitCountryName,
              );
              final Country? country =
                  _resolveCountryForPdf(externalController, countryName);
              _applyCountryDefaults(controller, country, countryName);
              final List<PdfDropdownItem<String>> currencyItems =
                  _buildCurrencyItems(
                country: country,
                countryName: countryName,
                selectedValue: controller.selectedCurrency.value,
              );

              return PdfDropdownSelector<String>(
                label: 'Currency Code',
                value: controller.selectedCurrency.value,
                icon: Icons.attach_money_rounded,
                allowCustom: true,
                customHint: 'Enter custom currency code (e.g., INR)',
                items: currencyItems,
                onChanged: (String value) {
                  controller.selectedCurrency.value = value;
                },
                onCustomSubmitted: (String value) {
                  controller.selectedCurrency.value = value.toUpperCase();
                },
              );
            }),

            const SizedBox(height: 36),

            // Section 5 — Timezone
            _SectionHeader(
              title: 'Timezone',
              number: '5',
              icon: Icons.schedule_rounded,
            ),
            const SizedBox(height: 10),
            Obx(() {
              externalController.countries.length;
              externalController.isLoadingCountries.value;
              final String? countryName = _resolveCountryNameForPdf(
                explicitCountryName,
              );
              final Country? country =
                  _resolveCountryForPdf(externalController, countryName);
              _applyCountryDefaults(controller, country, countryName);
              final List<PdfDropdownItem<String>> timezoneItems =
                  _buildTimezoneItems(
                country: country,
                countryName: countryName,
                selectedValue: controller.selectedTimezone.value,
              );

              return PdfDropdownSelector<String>(
                label: 'Document Timezone',
                value: controller.selectedTimezone.value,
                icon: Icons.public_rounded,
                allowCustom: true,
                customHint: 'Enter custom timezone (e.g., Asia/Dubai)',
                items: timezoneItems,
                onChanged: (String value) {
                  controller.selectedTimezone.value = value;
                },
                onCustomSubmitted: (String value) {
                  controller.selectedTimezone.value = value;
                },
              );
            }),

            const SizedBox(height: 36),

            // Section 6 — Content Options
            _SectionHeader(
              title: 'Content Options',
              number: '6',
              icon: Icons.tune_rounded,
            ),
            const SizedBox(height: 10),
            _ContentOptionsSection(controller: controller),

            // Extra breathing room between sections 6 & 7
            const SizedBox(height: 36),

            // Section 7 — Advanced Options
            _SectionHeader(
              title: 'Advanced Options',
              number: '7',
              icon: Icons.settings_suggest_rounded,
            ),
            const SizedBox(height: 10),
            _AdvancedOptionsSection(controller: controller),
          ],
        ),
      ),
    );
  }

  IconData _templateIcon(String iconName) {
    switch (iconName) {
      case 'mosque':
        return Icons.mosque_outlined;
      case 'gavel':
        return Icons.gavel_outlined;
      case 'article':
        return Icons.article_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }
}

String? _resolveCountryNameForPdf(String? explicitCountryName) {
  String? countryName;

  if (explicitCountryName != null && explicitCountryName.trim().isNotEmpty) {
    countryName = explicitCountryName.trim();
  }

  // Source 1: PdfGenerationController (set during initializeForRecord)
  if (countryName == null && Get.isRegistered<PdfGenerationController>()) {
    final PdfGenerationController pdfController =
        Get.find<PdfGenerationController>();
    final String? pdfCountry = pdfController.countryName;
    if (pdfCountry != null && pdfCountry.trim().isNotEmpty) {
      countryName = pdfCountry.trim();
    }
  }

  // Source 2: DigitalWillController (request model + API response)
  if (countryName == null && Get.isRegistered<DigitalWillController>()) {
    final DigitalWillController willController =
        Get.find<DigitalWillController>();

    // 2a: The request model (user input from basic info step)
    final String? requestCountry =
        willController.basicInfo?.countryJurisdiction;
    if (requestCountry != null && requestCountry.trim().isNotEmpty) {
      countryName = requestCountry.trim();
    }

    // 2b: The API response
    if (countryName == null) {
      final String? responseCountry =
          willController.lastResponse.value?.basicInfo.countryJurisdiction;
      if (responseCountry != null && responseCountry.trim().isNotEmpty) {
        countryName = responseCountry.trim();
      }
    }
  }

  // If we found a country, also push it back to PdfGenerationController
  // so it stays available for future reads
  if (countryName != null && Get.isRegistered<PdfGenerationController>()) {
    final PdfGenerationController pdfController =
        Get.find<PdfGenerationController>();
    if ((pdfController.countryName ?? '').isEmpty) {
      pdfController.setCountryName(countryName);
    }
  }

  return countryName;
}

Country? _resolveCountryForPdf(
  ExternalServiceController externalController,
  String? countryName,
) {
  if (countryName == null || countryName.isEmpty) {
    return null;
  }

  Country? country = externalController.getCountryByName(countryName);
  country ??= externalController.getCountryByCode(countryName);

  if (country != null) {
    return country;
  }

  final String normalized = _normalizeCountryKey(countryName);
  for (final Country candidate in externalController.countries) {
    final String candidateName = _normalizeCountryKey(candidate.name);
    final String candidateCode = _normalizeCountryKey(candidate.code);
    if (candidateName == normalized ||
        candidateCode == normalized ||
        candidateName.contains(normalized) ||
        normalized.contains(candidateName)) {
      return candidate;
    }
  }

  return null;
}

String _normalizeCountryKey(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

void _seedCountryDefaultsForController({
  required PdfGenerationController controller,
  required ExternalServiceController externalController,
  String? explicitCountryName,
}) {
  final String? resolvedCountry =
      _resolveCountryNameForPdf(explicitCountryName);
  if (resolvedCountry == null || resolvedCountry.trim().isEmpty) {
    return;
  }

  final Country? country =
      _resolveCountryForPdf(externalController, resolvedCountry);
  final String? fallbackCurrency =
      _fallbackCurrencyForCountryName(resolvedCountry);
  final String? fallbackTimezone =
      _fallbackTimezoneForCountryName(resolvedCountry);

  if (country != null && country.currencies.isNotEmpty) {
    final String countryCurrency = country.currencies.keys.first;
    final bool hasCurrency =
        country.currencies.containsKey(controller.selectedCurrency.value);
    if (!hasCurrency) {
      controller.selectedCurrency.value = countryCurrency;
    }
  } else if (fallbackCurrency != null &&
      controller.selectedCurrency.value != fallbackCurrency) {
    controller.selectedCurrency.value = fallbackCurrency;
  }

  if (country != null && country.timezones.isNotEmpty) {
    final String countryTimezone = country.timezones.first;
    final bool hasTimezone =
        country.timezones.contains(controller.selectedTimezone.value);
    if (!hasTimezone) {
      controller.selectedTimezone.value = countryTimezone;
    }
  } else if (fallbackTimezone != null &&
      controller.selectedTimezone.value != fallbackTimezone) {
    controller.selectedTimezone.value = fallbackTimezone;
  }
}

void _applyCountryDefaults(
  PdfGenerationController controller,
  Country? country,
  String? countryName,
) {
  final String? fallbackCurrency = _fallbackCurrencyForCountryName(countryName);
  final String? fallbackTimezone = _fallbackTimezoneForCountryName(countryName);

  if (country != null && country.currencies.isNotEmpty) {
    final String countryCurrency = country.currencies.keys.first;
    final bool hasCurrency =
        country.currencies.containsKey(controller.selectedCurrency.value);
    if (!hasCurrency) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectedCurrency.value = countryCurrency;
      });
    }
  } else if (fallbackCurrency != null &&
      controller.selectedCurrency.value != fallbackCurrency) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedCurrency.value = fallbackCurrency;
    });
  }

  if (country != null && country.timezones.isNotEmpty) {
    final String countryTimezone = country.timezones.first;
    final bool hasTimezone =
        country.timezones.contains(controller.selectedTimezone.value);
    if (!hasTimezone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectedTimezone.value = countryTimezone;
      });
    }
  } else if (fallbackTimezone != null &&
      controller.selectedTimezone.value != fallbackTimezone) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedTimezone.value = fallbackTimezone;
    });
  }
}

List<PdfDropdownItem<String>> _buildCurrencyItems({
  required Country? country,
  required String? countryName,
  required String selectedValue,
}) {
  List<PdfDropdownItem<String>> items = <PdfDropdownItem<String>>[];

  if (country != null && country.currencies.isNotEmpty) {
    items = country.currencies.entries.map((entry) {
      final String code = entry.key;
      final String symbol = entry.value;
      final String label = symbol.isNotEmpty ? '$symbol  $code' : code;
      return PdfDropdownItem<String>(
        value: code,
        label: label,
        subtitle: code,
      );
    }).toList();
  } else if (countryName != null) {
    final String? fallback = _fallbackCurrencyForCountryName(countryName);
    if (fallback != null) {
      items = <PdfDropdownItem<String>>[
        PdfDropdownItem<String>(
          value: fallback,
          label: fallback,
          subtitle: fallback,
        ),
      ];
    }
  }

  if (items.isEmpty) {
    items = PdfConstants.currencies
        .map((currency) => PdfDropdownItem<String>(
              value: currency.code,
              label: '${currency.symbol}  ${currency.label}',
              subtitle: currency.code,
            ))
        .toList();
  }

  if (selectedValue.isNotEmpty &&
      !items.any((item) => item.value == selectedValue)) {
    items.insert(
      0,
      PdfDropdownItem<String>(
        value: selectedValue,
        label: selectedValue,
        subtitle: 'Custom',
      ),
    );
  }

  return items;
}

List<PdfDropdownItem<String>> _buildTimezoneItems({
  required Country? country,
  required String? countryName,
  required String selectedValue,
}) {
  List<PdfDropdownItem<String>> items = <PdfDropdownItem<String>>[];

  if (country != null && country.timezones.isNotEmpty) {
    items = country.timezones
        .where((tz) => tz.isNotEmpty)
        .map((tz) => PdfDropdownItem<String>(
              value: tz,
              label: tz,
            ))
        .toList();
  } else if (countryName != null) {
    final String? fallback = _fallbackTimezoneForCountryName(countryName);
    if (fallback != null) {
      items = <PdfDropdownItem<String>>[
        PdfDropdownItem<String>(
          value: fallback,
          label: fallback,
        ),
      ];
    }
  }

  if (items.isEmpty) {
    items = PdfConstants.timezones
        .map((tz) => PdfDropdownItem<String>(
              value: tz.code,
              label: tz.label,
            ))
        .toList();
  }

  if (selectedValue.isNotEmpty &&
      !items.any((item) => item.value == selectedValue)) {
    items.insert(
      0,
      PdfDropdownItem<String>(
        value: selectedValue,
        label: selectedValue,
      ),
    );
  }

  return items;
}

String? _fallbackCurrencyForCountryName(String? countryName) {
  if (countryName == null || countryName.trim().isEmpty) return null;
  final String key = countryName.trim().toLowerCase();
  const Map<String, String> fallback = {
    'saudi arabia': 'SAR',
    'united arab emirates': 'AED',
    'qatar': 'QAR',
    'kuwait': 'KWD',
    'oman': 'OMR',
    'bahrain': 'BHD',
    'pakistan': 'PKR',
    'india': 'INR',
    'bangladesh': 'BDT',
    'malaysia': 'MYR',
    'indonesia': 'IDR',
    'united kingdom': 'GBP',
    'united states': 'USD',
    'canada': 'CAD',
  };
  return fallback[key];
}

String? _fallbackTimezoneForCountryName(String? countryName) {
  if (countryName == null || countryName.trim().isEmpty) return null;
  final String key = countryName.trim().toLowerCase();
  const Map<String, String> fallback = {
    'saudi arabia': 'Asia/Riyadh',
    'united arab emirates': 'Asia/Dubai',
    'qatar': 'Asia/Qatar',
    'kuwait': 'Asia/Kuwait',
    'oman': 'Asia/Muscat',
    'bahrain': 'Asia/Bahrain',
    'pakistan': 'Asia/Karachi',
    'india': 'Asia/Kolkata',
    'bangladesh': 'Asia/Dhaka',
    'malaysia': 'Asia/Kuala_Lumpur',
    'indonesia': 'Asia/Jakarta',
    'united kingdom': 'Europe/London',
    'united states': 'America/New_York',
    'canada': 'America/Toronto',
  };
  return fallback[key];
}

// ─── Content Options Section ─────────────────────────────────────────────────

class _ContentOptionsSection extends StatelessWidget {
  const _ContentOptionsSection({required this.controller});

  final PdfGenerationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EDE9), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1A5B48).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
            children: <Widget>[
              PdfOptionsToggleTile(
                title: 'Islamic Explanation',
                subtitle: 'Include Quranic references & Islamic reasoning',
                icon: Icons.menu_book_rounded,
                value: controller.includeIslamicExplanation.value,
                onChanged: (v) =>
                    controller.includeIslamicExplanation.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Legal Narration',
                subtitle: 'Formal legal language for document validity',
                icon: Icons.gavel_rounded,
                value: controller.includeLegalNarration.value,
                onChanged: (v) => controller.includeLegalNarration.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Rules Applied',
                subtitle: 'Show Islamic inheritance rules used',
                icon: Icons.rule_rounded,
                value: controller.includeRules.value,
                onChanged: (v) => controller.includeRules.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Validation Notes',
                subtitle: 'Include calculation validation details',
                icon: Icons.fact_check_rounded,
                value: controller.includeValidationNotes.value,
                onChanged: (v) => controller.includeValidationNotes.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Warnings',
                subtitle: 'Show any warnings or edge cases',
                icon: Icons.warning_amber_rounded,
                value: controller.includeWarnings.value,
                onChanged: (v) => controller.includeWarnings.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'References',
                subtitle: 'Include scholarly references',
                icon: Icons.bookmark_border_rounded,
                value: controller.includeReferences.value,
                onChanged: (v) => controller.includeReferences.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Signature Section',
                subtitle: 'Add witness & executor signature areas',
                icon: Icons.draw_rounded,
                value: controller.includeSignatures.value,
                onChanged: (v) => controller.includeSignatures.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Distribution Tables',
                subtitle: 'Include detailed distribution tables',
                icon: Icons.table_chart_outlined,
                value: controller.includeTables.value,
                onChanged: (v) => controller.includeTables.value = v,
              ),
            ],
          )),
    );
  }
}

// ─── Advanced Options Section ────────────────────────────────────────────────

class _AdvancedOptionsSection extends StatelessWidget {
  const _AdvancedOptionsSection({required this.controller});

  final PdfGenerationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EDE9), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1A5B48).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
            children: <Widget>[
              PdfOptionsToggleTile(
                title: 'Force Regenerate',
                subtitle: 'Generate a new PDF even if one exists',
                icon: Icons.refresh_rounded,
                value: controller.forceRegenerate.value,
                onChanged: (v) => controller.forceRegenerate.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Include HTML Response',
                subtitle: 'Developer/debug feature',
                icon: Icons.code_rounded,
                value: controller.includeHtml.value,
                onChanged: (v) => controller.includeHtml.value = v,
              ),
              _OptionsDivider(),
              const SizedBox(height: 10),
              PdfOptionsToggleTile(
                title: 'Include Base64 PDF',
                subtitle: 'Embed PDF data in response',
                icon: Icons.data_object_rounded,
                value: controller.includeBase64Pdf.value,
                onChanged: (v) => controller.includeBase64Pdf.value = v,
              ),
            ],
          )),
    );
  }
}

// ─── Shared Divider ──────────────────────────────────────────────────────────

class _OptionsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F5F3)),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.number,
  });

  final String title;
  final IconData icon;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF1A5B48), Color(0xFF2A7E66)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF1A5B48).withValues(alpha: 0.22),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ✅ TITLE FIRST
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C3D35),
            letterSpacing: -0.1,
          ),
        ),

        const SizedBox(width: 8),

        // ✅ ICON AFTER TITLE
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF3A6B5C),
        ),
      ],
    );
  }
}

// ─── Generate Button ─────────────────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.controller});

  final PdfGenerationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () => controller.generatePdf(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A5B48),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none, // 🔥 removes outline
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.auto_awesome, size: 22),
              const SizedBox(width: 12),
              Text(
                'Generate AI PDF',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Generating State ────────────────────────────────────────────────────────

class _GeneratingState extends StatelessWidget {
  const _GeneratingState({
    this.message,
    this.subtitle,
  });

  final String? message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF1A5B48).withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1A5B48)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              message ?? 'Generating Your PDF',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C3D35),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle ??
                  'AI is crafting your Islamic Will document\nwith professional formatting...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF7A9B91),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  minHeight: 7,
                  //backgroundColor: Color(0xFFE0EDE8),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A5B48)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Success State ───────────────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  const _SuccessState({
    required this.controller,
    required this.onClose,
  });

  final PdfGenerationController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final response = controller.lastGeneratedPdf.value!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF1A5B48).withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: Color(0xFF1A5B48),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'PDF Generated Successfully!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C3D35),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Islamic Will document is ready',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF7A9B91),
              ),
            ),
            const SizedBox(height: 26),

            // Info chips
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: <Widget>[
                _InfoChip(
                  icon: Icons.language,
                  label: response.language.toUpperCase(),
                ),
                _InfoChip(
                  icon: Icons.dashboard_customize,
                  label: response.template,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: <Widget>[
                Expanded(
                  child: _SuccessActionButton(
                    icon: Icons.download_rounded,
                    label: 'Download',
                    onTap: () async {
                      final String? filePath = await controller.downloadPdf(
                        downloadUrl: response.downloadUrl,
                        pdfId: response.pdfId,
                      );
                      if (filePath != null) {
                        controller.openPdf(filePath);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SuccessActionButton(
                    icon: Icons.visibility_rounded,
                    label: 'Preview',
                    onTap: () {
                      controller.openUrlExternally(response.downloadUrl);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _SuccessActionButton(
                icon: Icons.check_rounded,
                label: 'Done',
                isPrimary: true,
                onTap: onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessActionButton extends StatelessWidget {
  const _SuccessActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? const Color(0xFF1A5B48) : const Color(0xFFF0F7F4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : const Color(0xFF1A5B48),
              ),
              const SizedBox(width: 9),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : const Color(0xFF1A5B48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD4E8E0), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xFF3A6B5C)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3A6B5C),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.controller});

  final PdfGenerationController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFB84A4A).withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFB84A4A),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Generation Failed',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A2020),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              controller.errorMessage.value ?? 'An unknown error occurred.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF8A5A5A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.state.value = PdfGenerationState.configuring;
                  controller.errorMessage.value = null;
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: Text(
                  'Back to Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5B48),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => controller.generatePdf(),
              child: Text(
                'Retry Generation',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A5B48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
