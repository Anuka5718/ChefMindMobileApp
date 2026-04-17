import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance section
          _SectionHeader(title: 'Appearance'),

          _SettingsTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            subtitle: isDark ? 'Currently dark' : 'Currently light',
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeProvider.notifier).toggleTheme(),
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 20),

          _SectionHeader(title: 'About ChefMind'),

          // App info
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0 — Built with Flutter + Firebase + Gemini AI',
            trailing: null,
          ),

          const SizedBox(height: 20),

          _SectionHeader(title: 'Development Team'),

          // Team members
          _TeamMemberTile(
            name: 'Chamath Wickramasinghe',
            studentId: '10965639',
            contribution: 'Development & Firebase Integration',
            color: AppColors.primary,
          ),
          _TeamMemberTile(
            name: 'Hiranya Piumath',
            studentId: '10965632',
            contribution: 'Firebase & Authentication',
            color: AppColors.accent,
          ),
          _TeamMemberTile(
            name: 'Lakshan Wishwajith',
            studentId: '10965635',
            contribution: 'UI/UX Design & Testing',
            color: const Color(0xFF6C63FF),
          ),
          _TeamMemberTile(
            name: 'Sithika Dinujaya',
            studentId: '10965638',
            contribution: 'Frontend & Testing',
            color: const Color(0xFF00BCD4),
          ),

          const SizedBox(height: 20),

          // Made with love
          Center(
            child: Text(
              'Made with ❤️ by Group 2 • PUSL2023',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'Plymouth International College • 2026',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF30363D)
              : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
        trailing: trailing,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

class _TeamMemberTile extends StatelessWidget {
  final String name;
  final String studentId;
  final String contribution;
  final Color color;

  const _TeamMemberTile({
    required this.name,
    required this.studentId,
    required this.contribution,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF30363D)
              : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: color.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  studentId,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  contribution,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}