import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import '../../../core/twind/twind_ui.dart';

class TwindDemoScreen extends StatefulWidget {
  const TwindDemoScreen({super.key});

  @override
  State<TwindDemoScreen> createState() => _TwindDemoScreenState();
}

class _TwindDemoScreenState extends State<TwindDemoScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _showDemoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => TwDialogWrapper(
        title: 'Twind Dialog',
        content: const WText(
          'This is a verified Twind modal dialog component with smooth styling.',
          className: 'text-sm text-gray-500 mb-4',
        ),
        actions: [
          WButton(
            text: 'Yopish',
            onPressed: () => Navigator.pop(ctx),
            size: ButtonSize.small,
            backgroundColor: TwTokens.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const WText(
          'Flutter Twind Demo & QA',
          className: 'text-lg font-bold text-white',
        ),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. WCard & WContainer Showcase
              WContainer(
                className: 'p-4 rounded-2xl bg-red-600 mb-4 shadow-lg',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    WText(
                      'Twind Container (bg-red-600)',
                      className: 'text-white text-lg font-bold',
                    ),
                    SizedBox(height: 4),
                    WText(
                      'Active utility class styling powered by flutter_twind',
                      className: 'text-white/80 text-sm',
                    ),
                  ],
                ),
              ),

              // 2. TwCard with badges
              TwCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        WText(
                          'Status Badges',
                          className: 'font-bold text-base',
                        ),
                        TwBadge(
                          text: 'ACTIVE',
                          color: Colors.green,
                          icon: AppIcons.checkCircle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        TwBadge(
                          text: 'PENDING',
                          color: Colors.orange,
                          icon: AppIcons.hourglass,
                        ),
                        TwBadge(
                          text: 'REJECTED',
                          color: Colors.red,
                          icon: AppIcons.close,
                        ),
                        TwBadge(
                          text: 'PREMIUM',
                          color: TwTokens.gold,
                          icon: AppIcons.star,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. WInput Showcase
              TwCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WText(
                      'WInput Component',
                      className: 'font-bold text-base mb-3',
                    ),
                    WInput(
                      controller: _inputController,
                      placeholder: 'Matn kiriting...',
                      prefixIcon: const AppIcon(AppIcons.search, size: 20),
                      backgroundColor: isDark
                          ? const Color(0xFF26262B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ),

              // 4. TwButton Variants
              TwCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WText(
                      'Button Variants',
                      className: 'font-bold text-base mb-3',
                    ),
                    TwButton(
                      text: 'Primary Button',
                      onPressed: () {
                        setState(() => _isLoading = !_isLoading);
                      },
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 8),
                    TwButton(
                      text: 'Secondary Button',
                      isSecondary: true,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 8),
                    TwButton(
                      text: 'Outlined Button',
                      isOutlined: true,
                      onPressed: _showDemoDialog,
                    ),
                  ],
                ),
              ),

              // 5. Responsive Class Showcase
              WContainer(
                className:
                    'p-4 rounded-xl bg-blue-600/10 border border-blue-500/20 mb-4',
                child: Row(
                  children: [
                    const AppIcon(AppIcons.devices, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WText(
                            'Responsive Breakpoints',
                            className: 'font-bold text-sm text-blue-500',
                          ),
                          WText(
                            'Width: ${MediaQuery.of(context).size.width.toInt()}px (sm: 640, md: 768, lg: 1024)',
                            className: 'text-xs text-gray-400',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
