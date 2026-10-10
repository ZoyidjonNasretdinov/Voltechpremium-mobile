import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';
export 'app_icons.dart';

/// Central Design System tokens and helper widgets for Völtech Premium
/// powered by flutter_twind.
class TwTokens {
  // Spacing
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;

  // Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // Colors
  static const Color primary = AppTheme.voltechRed;
  static const Color gold = AppTheme.voltechGold;
  static const Color darkBg = AppTheme.premiumBlack;
  static const Color darkSurface = AppTheme.premiumDarkGray;
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;

  // Twind utility classes strings
  static String cardClass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? 'p-4 rounded-2xl bg-gray-900 border border-gray-800 shadow-md'
        : 'p-4 rounded-2xl bg-white border border-gray-100 shadow-sm';
  }

  static String surfaceCardClass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? 'p-5 rounded-2xl bg-gray-900 border border-gray-800 shadow-lg'
        : 'p-5 rounded-2xl bg-white border border-gray-200 shadow-sm';
  }

  static String badgeSuccess =
      'px-3 py-1 rounded-full bg-green-500/10 text-green-500 font-bold';
  static String badgeWarning =
      'px-3 py-1 rounded-full bg-yellow-500/10 text-yellow-500 font-bold';
  static String badgeError =
      'px-3 py-1 rounded-full bg-red-500/10 text-red-500 font-bold';
  static String badgeInfo =
      'px-3 py-1 rounded-full bg-blue-500/10 text-blue-500 font-bold';

  /// Formats transaction points without double-minus and with space thousand separators.
  /// E.g. points = -360, isEarned = false -> "-360"
  ///      points = 20000, isEarned = true  -> "+20 000"
  static String formatTransactionPoints(dynamic points, bool isEarned) {
    int parsed = 0;
    if (points is num) {
      parsed = points.toInt().abs();
    } else if (points != null) {
      parsed = (int.tryParse(points.toString()) ?? 0).abs();
    }
    final formatted = NumberFormat('#,###').format(parsed).replaceAll(',', ' ');
    return '${isEarned ? '+' : '-'}$formatted';
  }
}

/// A premium card wrapper built with WCard and WContainer
class TwCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final String? className;

  const TwCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.className,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg =
        backgroundColor ?? (isDark ? const Color(0xFF141416) : Colors.white);
    final defaultBorder =
        border ??
        Border.all(
          color: isDark ? const Color(0xFF26262B) : const Color(0xFFE2E8F0),
          width: 1,
        );
    final defaultRadius = borderRadius ?? BorderRadius.circular(16);
    final defaultShadow =
        boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

    return WCard(
      className: className,
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      backgroundColor: defaultBg,
      borderRadius: defaultRadius,
      border: defaultBorder,
      boxShadow: defaultShadow,
      child: child,
    );
  }
}

/// A modern button variant built on WButton
class TwButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonSize size;
  final bool isOutlined;
  final bool isSecondary;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const TwButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.isOutlined = false,
    this.isSecondary = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;

    if (isOutlined) {
      bg = Colors.transparent;
      fg = textColor ?? (isDark ? Colors.white : Colors.black87);
      border = Border.all(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFCBD5E1),
        width: 1.5,
      );
    } else if (isSecondary) {
      bg =
          backgroundColor ??
          (isDark ? const Color(0xFF26262B) : const Color(0xFFF1F5F9));
      fg = textColor ?? (isDark ? Colors.white : const Color(0xFF1E293B));
    } else {
      bg = backgroundColor ?? AppTheme.voltechRed;
      fg = textColor ?? Colors.white;
    }

    final buttonWidget = WButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      size: size,
      backgroundColor: bg,
      textColor: fg,
      border: border,
      borderRadius: BorderRadius.circular(16),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );

    if (width != null) {
      return SizedBox(width: width, child: buttonWidget);
    }

    return buttonWidget;
  }
}

/// A status badge widget
class TwBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final dynamic icon;

  const TwBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.voltechRed;
    final effectiveText = textColor ?? effectiveColor;

    return WContainer(
      className: 'px-3 py-1.5 rounded-full',
      backgroundColor: effectiveColor.withValues(alpha: 0.12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon is String
                ? AppIcon(icon as String, size: 14, color: effectiveText)
                : Icon(icon as IconData, size: 14, color: effectiveText),
            const SizedBox(width: 4),
          ],
          WText(text, className: 'text-xs font-bold', color: effectiveText),
        ],
      ),
    );
  }
}

/// A dialog with consistent Twind styling
class TwDialogWrapper extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const TwDialogWrapper({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WDialog(
      title: title,
      backgroundColor: isDark ? const Color(0xFF16181D) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      actions: actions,
      child: content,
    );
  }
}

/// A sleek, modern avatar widget with automatic image resolution and a premium default avatar icon.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showBorder;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 50,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.showBorder = true,
  });

  Widget _buildDefaultAvatar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? const Color(0xFF26282E) : const Color(0xFFE2E8F0));
    final ic = iconColor ??
        (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.08),
                width: 1,
              )
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: size * 0.62,
          color: ic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiService.resolveImageUrl(imageUrl);

    Widget avatarContent;
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      avatarContent = ClipOval(
        child: kIsWeb
            ? Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.38,
                      height: size * 0.38,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE52D27),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(context),
              )
            : CachedNetworkImage(
                imageUrl: resolvedUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                memCacheWidth: (size * 3).toInt(),
                memCacheHeight: (size * 3).toInt(),
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: size * 0.38,
                    height: size * 0.38,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE52D27),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _buildDefaultAvatar(context),
              ),
      );
    } else {
      avatarContent = _buildDefaultAvatar(context);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarContent,
      );
    }

    return avatarContent;
  }
}

/// Modern, contextual transaction icon badge with custom iconography and color styling.
class TransactionIconBadge extends StatelessWidget {
  final String? type;
  final String? description;
  final double size;
  final double iconSize;

  const TransactionIconBadge({
    super.key,
    this.type,
    this.description,
    this.size = 42,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEarned = (type ?? '').toUpperCase() == 'EARNED';
    final desc = (description ?? '').toLowerCase();

    final String icon;
    final Color accentColor;
    final Color bgColor;
    final Color borderColor;

    if (desc.contains('sovg') ||
        desc.contains('gift') ||
        desc.contains('xarid') ||
        desc.contains('purchase') ||
        !isEarned) {
      // Gift redemption or spent
      icon = AppIcons.gift;
      accentColor = const Color(0xFFEF4444);
      bgColor = isDark
          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
          : const Color(0xFFFEE2E2);
      borderColor = isDark
          ? const Color(0xFFEF4444).withValues(alpha: 0.28)
          : const Color(0xFFFECACA);
    } else if (desc.contains('admin') ||
        desc.contains('bonus') ||
        desc.contains('mukofot')) {
      // Admin points / bonus grant
      icon = AppIcons.coins;
      accentColor = const Color(0xFF10B981);
      bgColor = isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.15)
          : const Color(0xFFDCFCE7);
      borderColor = isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.28)
          : const Color(0xFFBBF7D0);
    } else if (desc.contains('qr') ||
        desc.contains('kod') ||
        desc.contains('skaner') ||
        desc.contains('scan') ||
        desc.contains('mahsulot')) {
      // QR Code scan / activation
      icon = AppIcons.qrCode;
      accentColor = const Color(0xFF0284C7);
      bgColor = isDark
          ? const Color(0xFF0284C7).withValues(alpha: 0.15)
          : const Color(0xFFE0F2FE);
      borderColor = isDark
          ? const Color(0xFF0284C7).withValues(alpha: 0.28)
          : const Color(0xFFBAE6FD);
    } else {
      // General earned
      icon = AppIcons.coins;
      accentColor = const Color(0xFF10B981);
      bgColor = isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.15)
          : const Color(0xFFDCFCE7);
      borderColor = isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.28)
          : const Color(0xFFBBF7D0);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      alignment: Alignment.center,
      child: AppIcon(
        icon,
        color: accentColor,
        size: iconSize,
      ),
    );
  }
}

