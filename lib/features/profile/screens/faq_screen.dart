import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final theme = Theme.of(context);
        final bgColor = theme.scaffoldBackgroundColor;
        final textColor = theme.colorScheme.onSurface;
        final subTextColor = textColor.withValues(alpha: 0.7);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: AppIcon(AppIcons.arrowLeft, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: WText(
              'faq'.tr,
              className: 'text-lg font-semibold',
              color: textColor,
            ),
            centerTitle: true,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  _buildFaqItem(
                    'faq_q1'.tr,
                    'faq_a1'.tr,
                    textColor,
                    subTextColor,
                  ),
                  _buildFaqItem(
                    'faq_q2'.tr,
                    'faq_a2'.tr,
                    textColor,
                    subTextColor,
                  ),
                  _buildFaqItem(
                    'faq_q3'.tr,
                    'faq_a3'.tr,
                    textColor,
                    subTextColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(
    String question,
    String answer,
    Color textColor,
    Color subTextColor,
  ) {
    return TwCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: WText(
            question,
            className: 'text-sm font-bold',
            color: textColor,
          ),
          iconColor: textColor,
          collapsedIconColor: subTextColor,
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          children: [
            WText(
              answer,
              className: 'text-sm leading-relaxed',
              color: subTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
