import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final theme = Theme.of(context);
        final bgColor = theme.scaffoldBackgroundColor;
        final cardColor = theme.colorScheme.surface;
        final textColor = theme.colorScheme.onSurface;
        final subTextColor = textColor.withValues(alpha: 0.7);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('faq'.tr, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildFaqItem('faq_q1'.tr, 'faq_a1'.tr, cardColor, textColor, subTextColor),
              _buildFaqItem('faq_q2'.tr, 'faq_a2'.tr, cardColor, textColor, subTextColor),
              _buildFaqItem('faq_q3'.tr, 'faq_a3'.tr, cardColor, textColor, subTextColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        iconColor: textColor,
        collapsedIconColor: subTextColor,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            answer,
            style: TextStyle(color: subTextColor, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
