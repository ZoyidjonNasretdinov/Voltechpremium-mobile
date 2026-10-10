import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final bgColor = theme.scaffoldBackgroundColor;
        final textColor = theme.colorScheme.onSurface;
        final primaryColor = theme.colorScheme.primary;
        final subTextColor = textColor.withValues(alpha: 0.75);

        final sections = [
          {
            'icon': AppIcons.terms,
            'title': 'terms_sec1_title'.tr,
            'desc': 'terms_sec1_desc'.tr,
          },
          {
            'icon': AppIcons.star,
            'title': 'terms_sec2_title'.tr,
            'desc': 'terms_sec2_desc'.tr,
          },
          {
            'icon': AppIcons.gift,
            'title': 'terms_sec3_title'.tr,
            'desc': 'terms_sec3_desc'.tr,
          },
          {
            'icon': AppIcons.shield,
            'title': 'terms_sec4_title'.tr,
            'desc': 'terms_sec4_desc'.tr,
          },
          {
            'icon': AppIcons.alert,
            'title': 'terms_sec5_title'.tr,
            'desc': 'terms_sec5_desc'.tr,
          },
          {
            'icon': AppIcons.help,
            'title': 'terms_sec6_title'.tr,
            'desc': 'terms_sec6_desc'.tr,
          },
        ];

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: AppIcon(AppIcons.arrowLeft, color: textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: WText(
              'terms_title'.tr,
              className: 'text-lg font-bold',
              color: textColor,
            ),
            centerTitle: true,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner with Twind styling
                    WContainer(
                      className: isDark
                          ? 'p-5 rounded-2xl bg-gray-900 border border-gray-800 shadow-lg'
                          : 'p-5 rounded-2xl bg-red-500/5 border border-red-500/20 shadow-sm',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              WContainer(
                                className: 'p-2.5 rounded-full bg-red-600/15',
                                child: AppIcon(
                                  AppIcons.terms,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WText(
                                      'Voltech Premium',
                                      className:
                                          'text-xs font-bold tracking-wider',
                                      color: primaryColor,
                                    ),
                                    const SizedBox(height: 2),
                                    WText(
                                      'terms_last_updated'.tr,
                                      className: 'text-xs',
                                      color: subTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          WText(
                            'terms_subtitle'.tr,
                            className: 'text-sm font-medium leading-relaxed',
                            color: textColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Terms Sections
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sections.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sec = sections[index];
                        return TwCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  WContainer(
                                    className: 'p-2 rounded-xl bg-red-600/10',
                                    child: AppIcon(
                                      sec['icon'] as String,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: WText(
                                      sec['title'] as String,
                                      className: 'text-sm font-bold',
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              WText(
                                sec['desc'] as String,
                                className: 'text-xs leading-relaxed',
                                color: subTextColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
