import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/localization/app_localizations.dart';
import 'purchases_screen.dart';
import '../../../core/api_service.dart';
import '../../../core/twind/twind_ui.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  List<dynamic> _realGifts = [];
  List<dynamic> _filteredGifts = [];
  int _userPoints = 0;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredGifts = List.from(_realGifts);
      } else {
        _filteredGifts = _realGifts.where((g) {
          final name = (g['name'] ?? '').toString().toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getAllGifts(),
      ]);

      final profileRes = results[0];
      final giftsRes = results[1];

      if (profileRes['success'] == true) {
        _userPoints = (profileRes['data']['totalBonusPoints'] ?? 0).toInt();
      }

      if (giftsRes['success'] == true) {
        _realGifts = giftsRes['data']['content'] ?? [];
        _filteredGifts = List.from(_realGifts);
      }
    } catch (e) {
      debugPrint("Gifts load error: $e");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseGift(Map<String, dynamic> gift) async {
    final giftId = gift['id'] as int;
    final price = (gift['points'] ?? 0) as int;
    final giftName = gift['name'] ?? 'unknown_gift'.tr;

    if (_userPoints < price) {
      final needed = price - _userPoints;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${'insufficient_points'.tr} (${'not_enough_points'.tr}: ${NumberFormat('#,###').format(needed).replaceAll(',', ' ')} ${'points_unit'.tr})",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final remainingPoints = _userPoints - price;
    final imageUrl = gift['imageUrl'];

    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final dialogBg = isDark ? const Color(0xFF1E1F25) : Colors.white;
        final cardBg =
            isDark ? const Color(0xFF141519) : const Color(0xFFF7F8FA);
        final textColor = isDark ? Colors.white : const Color(0xFF111827);
        final subTextColor = isDark
            ? Colors.white.withValues(alpha: 0.65)
            : const Color(0xFF6B7280);
        const primaryRed = Color(0xFFE52D27);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top glowing icon badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryRed.withValues(alpha: 0.22),
                            primaryRed.withValues(alpha: 0.06),
                          ],
                        ),
                        border: Border.all(
                          color: primaryRed.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withValues(alpha: 0.25),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: AppIcon(
                          AppIcons.gift,
                          color: primaryRed,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dialog Title - crisp and visible in all themes
                    Text(
                      'get_gift_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gift Showcase Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.black.withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail or placeholder
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 52,
                              height: 52,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade200,
                              child: _buildGiftImageWidget(
                                rawUrl: imageUrl?.toString(),
                                fit: BoxFit.cover,
                                memCacheWidth: 200,
                                memCacheHeight: 200,
                                indicatorColor: primaryRed,
                                placeholderWidget: const AppIcon(
                                  AppIcons.gift,
                                  size: 24,
                                  color: primaryRed,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name and price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  giftName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const AppIcon(
                                      AppIcons.points,
                                      color: primaryRed,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      NumberFormat('#,###')
                                          .format(price)
                                          .replaceAll(',', ' '),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: primaryRed,
                                      ),
                                    ),
                                    Text(
                                      ' ${'points_unit'.tr}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryRed.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Balance after purchase chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'remaining_balance'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                NumberFormat('#,###')
                                    .format(remainingPoints)
                                    .replaceAll(',', ' '),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                ' ${'points_unit'.tr}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description text
                    Text(
                      'gift_order_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx, false),
                            borderRadius: BorderRadius.circular(13),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'cancel'.tr,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Confirm button
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx, true),
                            borderRadius: BorderRadius.circular(13),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE52D27),
                                    Color(0xFFC71610),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE52D27,
                                    ).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'confirm'.tr,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    if (!mounted || _isPurchasing) return;
    setState(() => _isPurchasing = true);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F25) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      color: Color(0xFFE52D27),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'loading'.tr,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final res = await _apiService.purchaseGift(giftId);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('order_submitted_success'.tr),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        _loadData(); // reload balance
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'order_submit_error'.tr),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      } else {
        _isPurchasing = false;
      }
    }
  }

  Widget _buildGiftImageWidget({
    required String? rawUrl,
    required BoxFit fit,
    int? memCacheWidth,
    int? memCacheHeight,
    required Color indicatorColor,
    required Widget placeholderWidget,
  }) {
    final resolved = ApiService.resolveImageUrl(rawUrl?.toString());
    if (resolved == null || resolved.isEmpty) {
      return Center(child: placeholderWidget);
    }

    if (kIsWeb) {
      return Image.network(
        resolved,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: indicatorColor,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            Center(child: placeholderWidget),
      );
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      memCacheWidth: memCacheWidth ?? 400,
      memCacheHeight: memCacheHeight ?? 400,
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: indicatorColor,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Center(child: placeholderWidget),
    );
  }

  Widget _buildGiftPlaceholderIcon(Color accentColor) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.22),
            accentColor.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: AppIcon(
          AppIcons.gift,
          size: 26,
          color: accentColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final bgColor = theme.scaffoldBackgroundColor;
        final accentColor = theme.colorScheme.primary;
        final textColor = theme.colorScheme.onSurface;
        final hintColor = textColor.withValues(alpha: 0.5);

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
              'gifts'.tr,
              className: 'text-lg font-bold',
              color: textColor,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: AppIcon(AppIcons.history, color: textColor, size: 22),
                tooltip: 'purchase_history'.tr,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PurchasesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Current Balance Header (VIP Rewards Banner)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE52D27), Color(0xFFB31217)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE52D27).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // Watermark background gift icon
                      Positioned(
                        right: -15,
                        top: -15,
                        child: Opacity(
                          opacity: 0.09,
                          child: const AppIcon(
                            AppIcons.gift,
                            size: 130,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const AppIcon(
                                        AppIcons.star,
                                        color: Colors.amberAccent,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'your_points'.tr,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const AppIcon(
                                      AppIcons.points,
                                      color: Colors.amberAccent,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      NumberFormat('#,###')
                                          .format(_userPoints)
                                          .replaceAll(',', ' '),
                                      style: const TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'points_unit'.tr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Purchase History Pill Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PurchasesScreen(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const AppIcon(
                                        AppIcons.history,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'purchase_history'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF18181B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'search_gifts'.tr,
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 13.5,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(13),
                        child: AppIcon(
                          AppIcons.search,
                          color: hintColor,
                          size: 19,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: AppIcon(
                                AppIcons.close,
                                color: hintColor,
                                size: 17,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Grid of Gifts
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredGifts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: AppIcon(
                                AppIcons.gift,
                                size: 52,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            WText(
                              'no_gifts_available'.tr,
                              className: 'text-sm font-semibold',
                              color: hintColor,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                        itemCount: _filteredGifts.length,
                        itemBuilder: (context, index) {
                          final gift = _filteredGifts[index];
                          final giftName = gift['name'] ?? 'unknown_gift'.tr;
                          final giftPoints = (gift['points'] ?? 0) as int;
                          final imageUrl = gift['imageUrl'];
                          final bool canAfford = _userPoints >= giftPoints;

                          return Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF18181C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.black.withValues(alpha: 0.07),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.25 : 0.04,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Image / Showcase Container
                                  Expanded(
                                    flex: 7,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: isDark
                                                  ? [
                                                      accentColor.withValues(
                                                        alpha: 0.14,
                                                      ),
                                                      const Color(0xFF121214),
                                                      accentColor.withValues(
                                                        alpha: 0.04,
                                                      ),
                                                    ]
                                                  : [
                                                      accentColor.withValues(
                                                        alpha: 0.08,
                                                      ),
                                                      Colors.grey.shade100,
                                                      accentColor.withValues(
                                                        alpha: 0.02,
                                                      ),
                                                    ],
                                            ),
                                          ),
                                          child: _buildGiftImageWidget(
                                            rawUrl: imageUrl?.toString(),
                                            fit: BoxFit.cover,
                                            memCacheWidth: 400,
                                            memCacheHeight: 400,
                                            indicatorColor:
                                                accentColor.withValues(alpha: 0.5),
                                            placeholderWidget:
                                                _buildGiftPlaceholderIcon(accentColor),
                                          ),
                                        ),

                                        // Top brand badge
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'VOLTECH',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Top status pill (Mavjud / Points needed)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: canAfford
                                                  ? const Color(0xFF16A34A)
                                                      .withValues(alpha: 0.9)
                                                  : Colors.black.withValues(
                                                      alpha: 0.65,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (canAfford) ...[
                                                  const Icon(
                                                    Icons.check,
                                                    size: 11,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    'available'.tr,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  const AppIcon(
                                                    AppIcons.lock,
                                                    size: 10,
                                                    color: Colors.white70,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '-${NumberFormat('#,###').format(giftPoints - _userPoints).replaceAll(',', ' ')}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Details & Action
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      10,
                                      12,
                                      12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title (2 lines max for neatness)
                                        SizedBox(
                                          height: 34,
                                          child: Text(
                                            giftName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: textColor,
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Points Chip
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accentColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            border: Border.all(
                                              color: accentColor.withValues(
                                                alpha: 0.2,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppIcon(
                                                AppIcons.points,
                                                color: accentColor,
                                                size: 13,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                NumberFormat('#,###')
                                                    .format(giftPoints)
                                                    .replaceAll(',', ' '),
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: accentColor,
                                                ),
                                              ),
                                              Text(
                                                ' ${'points_unit'.tr}',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: accentColor.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        // Claim / Locked Button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _purchaseGift(gift),
                                            borderRadius:
                                                BorderRadius.circular(11),
                                            child: Container(
                                              height: 36,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: canAfford
                                                    ? const LinearGradient(
                                                        colors: [
                                                          Color(0xFFE52D27),
                                                          Color(0xFFC71610),
                                                        ],
                                                      )
                                                    : null,
                                                color: canAfford
                                                    ? null
                                                    : (isDark
                                                        ? Colors.white
                                                            .withValues(
                                                              alpha: 0.06,
                                                            )
                                                        : Colors.black
                                                            .withValues(
                                                              alpha: 0.05,
                                                            )),
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                                border: canAfford
                                                    ? null
                                                    : Border.all(
                                                        color: isDark
                                                            ? Colors.white
                                                                .withValues(
                                                                  alpha: 0.08,
                                                                )
                                                            : Colors.black
                                                                .withValues(
                                                                  alpha: 0.08,
                                                                ),
                                                      ),
                                                boxShadow: canAfford
                                                    ? [
                                                        BoxShadow(
                                                          color: const Color(
                                                            0xFFE52D27,
                                                          ).withValues(
                                                            alpha: 0.32,
                                                          ),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            3,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AppIcon(
                                                      canAfford
                                                          ? AppIcons.gift
                                                          : AppIcons.lock,
                                                      color: canAfford
                                                          ? Colors.white
                                                          : (isDark
                                                              ? Colors.white38
                                                              : Colors.black38),
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      canAfford
                                                          ? 'claim_gift'.tr
                                                          : 'not_enough_points'.tr,
                                                      style: TextStyle(
                                                        color: canAfford
                                                            ? Colors.white
                                                            : (isDark
                                                                ? Colors.white38
                                                                : Colors
                                                                    .black38),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
