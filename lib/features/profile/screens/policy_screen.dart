import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

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
            title: Text('policy_title'.tr, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'policy_content'.tr,
                style: TextStyle(color: subTextColor, fontSize: 15, height: 1.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
