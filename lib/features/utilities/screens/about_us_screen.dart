import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _primary = Color(0xFF1C5D4E);
  static const _mint = Color(0xFFE3F3EF);
  static const _surface = Color(0xFFFFFFFF);
  static const _background = Color(0xFFF7FAF9);
  static const _border = Color(0xFFE1E8E5);
  static const _text = Color(0xFF10231E);
  static const _muted = Color(0xFF687773);
  static const _gold = Color(0xFFD3AE2D);
  static const _blue = Color(0xFF1E6FA8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: PAppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Get.toNamed('/app-settings'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: MaxWidthWrapper(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
          children: [
            const _MissionCard(),
            const SizedBox(height: 26),
            const _SectionTitle(title: 'Core Values'),
            const SizedBox(height: 14),
            const _ValueTile(
              icon: Icons.eco_outlined,
              title: 'Distraction-Free',
              subtitle: 'A calm space for worship, learning, and reflection.',
              accent: _primary,
            ),
            const SizedBox(height: 12),
            const _ValueTile(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Guidance',
              subtitle: 'Personalized Islamic assistance with thoughtful flow.',
              accent: _blue,
            ),
            const SizedBox(height: 12),
            const _ValueTile(
              icon: Icons.self_improvement_rounded,
              title: 'Spiritual Growth',
              subtitle: 'Practical tools that help you build consistency.',
              accent: _gold,
            ),
            const SizedBox(height: 26),
            const _SectionTitle(
              title: 'In Sight',
              trailing: 'GALLERY',
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: const [
                  _InsightCard(
                    imagePath: PImages.banner1,
                    title: 'Scripture and Hadith',
                    subtitle: 'Guided reading',
                  ),
                  _InsightCard(
                    imagePath: 'assets/images/kids/mainscreen.png',
                    title: 'Kids Learning',
                    subtitle: 'Stories and quizzes',
                  ),
                  _InsightCard(
                    imagePath: 'assets/images/content/kaaba.png',
                    title: 'Daily Utilities',
                    subtitle: 'Prayer, Qibla, and more',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Meet the Developers'),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final double cardWidth =
                    ((constraints.maxWidth - 12) / 2).clamp(150.0, 190.0);
                final double cardHeight = cardWidth / 0.76;

                return SizedBox(
                  height: cardHeight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: const _DeveloperCard(
                            initials: 'ST',
                            name: 'Saljok Tanveer',
                            role: 'Full Stack Developer',
                            gradient: [Color(0xFF1C5D4E), Color(0xFF58B79E)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: cardWidth,
                          child: const _DeveloperCard(
                            initials: 'ZQ',
                            name: 'Zainab Qayyum',
                            role: 'Frontend Developer',
                            gradient: [Color(0xFF1E6FA8), Color(0xFF9ED7EA)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: cardWidth,
                          child: const _DeveloperCard(
                            initials: 'RJ',
                            name: 'Rimsha Jafar',
                            role: 'Frontend Developer',
                            gradient: [Color(0xFFB65F3D), Color(0xFFE6A17E)],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Follow Us'),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _SocialButton(
                    label: 'YOUTUBE',
                    iconPath: 'assets/logos/youtube.png',
                    onTap: () => _showComingSoon('YouTube'),
                  ),
                  _SocialButton(
                    label: 'INSTAGRAM',
                    iconPath: 'assets/logos/instagram.png',
                    onTap: () => _showComingSoon('Instagram'),
                  ),
                  _SocialButton(
                    label: 'FACEBOOK',
                    iconPath: 'assets/logos/facebook.png',
                    onTap: () => _showComingSoon('Facebook'),
                  ),
                  _SocialButton(
                    label: 'X',
                    textIcon: 'X',
                    onTap: () => _showComingSoon('X'),
                  ),
                  _SocialButton(
                    label: 'TIKTOK',
                    iconPath: 'assets/logos/tiktok.png',
                    onTap: () => _showComingSoon('TikTok'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Collaborators'),
            const SizedBox(height: 14),
            const _CollaboratorTile(
              icon: Icons.account_balance_outlined,
              title: 'Islamic Relief Org',
              subtitle: 'Community impact partner',
            ),
            const SizedBox(height: 12),
            const _CollaboratorTile(
              icon: Icons.menu_book_outlined,
              title: 'Quran Academy Global',
              subtitle: 'Learning and recitation guidance',
            ),
            const SizedBox(height: 22),
            _PolicyPanel(
              onPrivacyTap: () => _showComingSoon('Privacy Policy'),
              onTermsTap: () => _showComingSoon('Terms & Conditions'),
              onLibrariesTap: () => _showComingSoon('Open Source Libraries'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(String label) {
    PLoaders.warningSnackBar(
      title: label,
      message: 'This section will be available soon.',
      duration: 2,
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E765C),
            Color(0xFF00533E),
            Color(0xFF073F32),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AboutUsScreen._primary.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Mission',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Peace Player is a comprehensive Islamic ecosystem designed to harmonize your digital life with your spiritual path. We provide a seamless flow for scripture recitation, prayer management, learning, and support.',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          _MissionQuote(),
        ],
      ),
    );
  }
}

class _MissionQuote extends StatelessWidget {
  const _MissionQuote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            '"Eliminating distractions, offering a serene environment where technology serves the soul."',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.45,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 18,
          decoration: BoxDecoration(
            color: AboutUsScreen._primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AboutUsScreen._text,
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AboutUsScreen._surface,
              border: Border.all(color: AboutUsScreen._border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: AboutUsScreen._primary,
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _ValueTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _ValueTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AboutUsScreen._surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AboutUsScreen._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0B2C23),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 25),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AboutUsScreen._text,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AboutUsScreen._muted,
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const _InsightCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240A3027),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.74),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final List<Color> gradient;

  const _DeveloperCard({
    required this.initials,
    required this.name,
    required this.role,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AboutUsScreen._surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AboutUsScreen._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120A3027),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AboutUsScreen._text,
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AboutUsScreen._muted,
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.link_rounded, color: AboutUsScreen._primary, size: 14),
              SizedBox(width: 8),
              Icon(Icons.mail_outline_rounded,
                  color: AboutUsScreen._primary, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String? iconPath;
  final String? textIcon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.onTap,
    this.iconPath,
    this.textIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Material(
            color: AboutUsScreen._surface,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 58,
                height: 54,
                child: Center(
                  child: iconPath != null
                      ? Image.asset(iconPath!, width: 22, height: 22)
                      : Text(
                          textIcon ?? '',
                          style: const TextStyle(
                            color: AboutUsScreen._text,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 62,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AboutUsScreen._text,
                fontFamily: 'Poppins',
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollaboratorTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CollaboratorTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AboutUsScreen._surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => AboutUsScreen._showComingSoon(title),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AboutUsScreen._border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AboutUsScreen._mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AboutUsScreen._primary, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AboutUsScreen._text,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AboutUsScreen._muted,
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new_rounded,
                color: AboutUsScreen._primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyPanel extends StatelessWidget {
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;
  final VoidCallback onLibrariesTap;

  const _PolicyPanel({
    required this.onPrivacyTap,
    required this.onTermsTap,
    required this.onLibrariesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AboutUsScreen._border),
      ),
      child: Column(
        children: [
          _PolicyRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: onPrivacyTap,
          ),
          const Divider(height: 1, color: AboutUsScreen._border),
          _PolicyRow(
            icon: Icons.gavel_rounded,
            title: 'Terms & Conditions',
            onTap: onTermsTap,
          ),
          const Divider(height: 1, color: AboutUsScreen._border),
          _PolicyRow(
            icon: Icons.code_rounded,
            title: 'Open Source Libraries',
            onTap: onLibrariesTap,
          ),
        ],
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PolicyRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AboutUsScreen._primary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AboutUsScreen._text,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AboutUsScreen._muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
