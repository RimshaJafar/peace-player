import 'package:ecommerce_app/common/widgets/button/notification_action_button.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/main_screen_drawer.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreMainScreen extends StatelessWidget {
  MoreMainScreen({super.key});

  static const _darkGreen = Color(0xFF00533E);
  static const _deepGreen = Color(0xFF00513D);
  static const _softGreen = Color(0xFFD8EDEA);
  static const _pageBackground = Color(0xFFF8FAF9);
  static const _gold = Color(0xFFD2AF2A);

  final List<String> carouselImages = [
    PImages.banner1,
    PImages.banner2,
    PImages.banner3,
    PImages.banner4,
    PImages.banner5,
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth >= 420 ? 28.0 : 20.0;
    // Slightly reduced banner height for better balance on different screens
    final bannerHeight = (screenHeight * 0.24).clamp(160.0, 240.0).toDouble();
    final gridCount = screenWidth >= 700 ? 3 : 2;

    final discoverItems = [
      _DiscoverItem(
        title: 'Kids Module',
        imagePath: 'assets/icons/kids.png',
        backgroundColor: _deepGreen,
        iconBackgroundColor: Colors.white.withValues(alpha: 0.20),
        foregroundColor: Colors.white,
        onTap: () => Get.toNamed('/kids'),
      ),
      _DiscoverItem(
        title: 'Seerah Nabwi',
        imagePath: 'assets/icons/seerah_nabwi.png',
        backgroundColor: _gold,
        iconBackgroundColor: Colors.white.withValues(alpha: 0.26),
        foregroundColor: const Color(0xFF3E3305),
        onTap: () => Get.toNamed('/seerah-nabwi'),
      ),
      _DiscoverItem(
        title: 'Quran Listening',
        imagePath: 'assets/icons/quran_listening.png',
        backgroundColor: const Color(0xFF1E6FA8),
        iconBackgroundColor: Colors.white.withValues(alpha: 0.22),
        foregroundColor: Colors.white,
        onTap: () => Get.toNamed('/quran-listening'),
      ),
      _DiscoverItem(
        title: 'App Support',
        imagePath: 'assets/icons/charity.png',
        backgroundColor: const Color(0xFFB65F3D),
        iconBackgroundColor: Colors.white.withValues(alpha: 0.22),
        foregroundColor: Colors.white,
        onTap: () => Get.toNamed('/app-support'),
      ),
    ];

    final utilityItems = [
      _UtilityItem(
        title: 'About Us',
        icon: Icons.info_outline_rounded,
        onTap: () => Get.toNamed('/about-us'),
      ),
      _UtilityItem(
        title: 'Notifications',
        icon: Icons.notifications_none_rounded,
        onTap: () => showNotificationPreviewSheet(context),
      ),
      _UtilityItem(
        title: 'Subscription',
        icon: Icons.stars_rounded,
        onTap: () => Get.toNamed('/subscription'),
      ),
      _UtilityItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        onTap: () => Get.toNamed('/app-settings'),
      ),
    ];

    return Scaffold(
      backgroundColor: _pageBackground,
      drawer: const MainScreenDrawer(),
      appBar: PAppBar(
        gradient: PColors.linearGradient,
        leadingWidth: 56,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Islamic Utilities',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Get.toNamed('/app-settings'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: MaxWidthWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenWidth >= 420 ? 30 : 22),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _BannerCarousel(
                    images: carouselImages,
                    height: bannerHeight,
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const _PlainSectionHeader(title: 'Discover'),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: discoverItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.08,
                    ),
                    itemBuilder: (context, index) {
                      return _DiscoverCard(item: discoverItems[index]);
                    },
                  ),
                ),
                const SizedBox(height: 34),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _UpgradeBanner(
                    onTap: () => Get.toNamed('/subscription'),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const _SectionHeader(
                    title: 'Explore & Utility',
                    subtitle: 'Services and shortcuts',
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: utilityItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (context, index) {
                      return _UtilityTile(item: utilityItems[index]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _AppSupportTile(
                    onTap: () => Get.toNamed('/app-support'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  final List<String> images;
  final double height;

  const _BannerCarousel({
    required this.images,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        autoPlay: true,
        // Keep the banner aligned with the page grid width.
        enlargeCenterPage: true,
        viewportFraction: 1,
        // slower autoplay for better readability
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 1200),
      ),
      items: images.map((imgPath) {
        return Padding(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imgPath,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black45, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PlainSectionHeader extends StatelessWidget {
  final String title;

  const _PlainSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: MoreMainScreen._darkGreen,
        fontFamily: 'Poppins',
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: MoreMainScreen._darkGreen,
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF4C5754),
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _DiscoverItem {
  final String title;
  final String imagePath;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _DiscoverItem({
    required this.title,
    required this.imagePath,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });
}

class _DiscoverCard extends StatelessWidget {
  final _DiscoverItem item;

  const _DiscoverCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.backgroundColor,
      borderRadius: BorderRadius.circular(25),
      elevation: 5,
      shadowColor: item.backgroundColor.withValues(alpha: 0.24),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: item.iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                item.imagePath,
                width: 38,
                height: 38,
                color: item.foregroundColor,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: item.foregroundColor,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _UpgradeBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: PColors.linearGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C3C30).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.24),
                      Colors.white.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFE5FFF5),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Upgrade to Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Unlock all features, ad-free',
                      style: TextStyle(
                        color: Color(0xFFD8F7EF),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF0FFF9),
                foregroundColor: MoreMainScreen._darkGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View plans',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilityItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _UtilityItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _UtilityTile extends StatelessWidget {
  final _UtilityItem item;

  const _UtilityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F6F6),
      borderRadius: BorderRadius.circular(23),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(23),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0xFFE0E4E2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: MoreMainScreen._softGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: MoreMainScreen._darkGreen,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MoreMainScreen._darkGreen,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppSupportTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AppSupportTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F2F1),
      borderRadius: BorderRadius.circular(23),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0xFFE0E4E2)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: MoreMainScreen._softGreen.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: MoreMainScreen._darkGreen,
                  size: 34,
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'App Support',
                      style: TextStyle(
                        color: MoreMainScreen._darkGreen,
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Need help? We're here for you.",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF5A6461),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9FB0AA),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
