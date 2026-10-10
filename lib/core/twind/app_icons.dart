import 'package:flutter/material.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ri.dart';
import 'sargam_icons.dart';

export 'sargam_icons.dart';

/// Centralized Iconify design icons catalog from https://icon-sets.iconify.design/si/
/// Powered by Sargam Icons (si) collection.
class AppIcons {
  // Navigation & Scanning
  static const String home = Si.home;
  static const String scan = Ri.qr_code_line;
  static const String qrCode = Ri.qr_code_line;
  static const String gift = Si.gift;
  static const String user = Ri.user_3_line;
  static const String userSolid = Ri.user_3_fill;
  static const String camera = Ri.camera_fill;
  static const String settings = Si.settings;

  // Actions
  static const String arrowLeft = Si.arrowLeft;
  static const String chevronRight = Si.chevronRight;
  static const String chevronDown = Si.chevronDown;
  static const String close = Si.close;
  static const String check = Si.check;
  static const String checkCircle = Si.checkCircle;
  static const String edit = Si.edit;
  static const String logout = Si.logout;
  static const String trash = Si.trash;
  static const String search = Si.search;
  static const String history = Si.history;
  static const String refresh = Si.refresh;
  static const String copy = Si.copy;
  static const String share = Si.share;

  // Auth & Forms
  static const String phone = Si.phone;
  static const String lock = Si.lock;
  static const String eye = Ri.eye_line;
  static const String eyeOff = Ri.eye_off_line;
  static const String calendar = Si.calendar;
  static const String clock = Si.clock;
  static const String hourglass = Si.hourglass;
  static const String location = Si.location;

  // Scanner & Hardware
  static const String flashOn = Ri.flashlight_fill;
  static const String flashOff = Ri.flashlight_line;
  static const String cameraSwitch = Ri.camera_switch_line;
  static const String keyboard = Ri.keyboard_line;
  static const String videoOff = Si.videoOff;

  // Loyalty & Rewards
  static const String star = Si.star;
  static const String points = Si.points;
  static const String plusCircle = Si.plusCircle;
  static const String minusCircle = Si.minusCircle;
  static const String coins = Ri.coins_line;
  static const String award = Ri.award_line;
  static const String shoppingBag = Ri.shopping_bag_3_line;
  static const String arrowUpRight = Ri.arrow_right_up_line;
  static const String arrowDownLeft = Ri.arrow_left_down_line;

  // Profile & Support
  static const String help = Si.help;
  static const String terms = Si.terms;
  static const String shield = Si.shield;
  static const String info = Si.info;
  static const String alert = Si.alert;
  static const String telegram = Ri.telegram_fill;
  static const String language = Si.language;
  static const String phoneCall = Si.phoneCall;
  static const String devices = Si.devices;
}

/// Unified Iconify icon renderer widget with support for theme color and scaling.
class AppIcon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double size;

  const AppIcon(this.icon, {super.key, this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Iconify(
      icon,
      color: color ?? IconTheme.of(context).color ?? Colors.white,
      size: size,
    );
  }
}
