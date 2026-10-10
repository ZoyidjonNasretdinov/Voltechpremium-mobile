import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/screens/profile_screen.dart';
import '../../gifts/screens/gift_screen.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/api_service.dart';
import '../../../core/twind/twind_ui.dart';
import '../../../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final DateFormat _activityDateFormat = DateFormat('dd.MM.yyyy, HH:mm');
  int _selectedCardDesign = cardDesignNotifier.value;
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  List<dynamic> _recentActivities = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _selectedCardDesign = cardDesignNotifier.value;
    cardDesignNotifier.addListener(_onCardDesignChanged);
    _loadSavedCardDesign();
    _loadData();
  }

  void _onCardDesignChanged() {
    if (mounted && _selectedCardDesign != cardDesignNotifier.value) {
      setState(() => _selectedCardDesign = cardDesignNotifier.value);
    }
  }

  @override
  void dispose() {
    cardDesignNotifier.removeListener(_onCardDesignChanged);
    super.dispose();
  }

  Future<void> _updateCardDesign(int index) async {
    cardDesignNotifier.value = index;
    if (mounted) {
      setState(() => _selectedCardDesign = index);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_card_design', index);
      final phone = _profileData?['phoneNumber']?.toString();
      if (phone != null && phone.isNotEmpty) {
        await prefs.setInt('card_design_$phone', index);
      }
    } catch (e) {
      debugPrint("Error saving card design: $e");
    }
  }

  Future<void> _loadSavedCardDesign() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? savedIndex;
      final phone = _profileData?['phoneNumber']?.toString();
      if (phone != null && phone.isNotEmpty) {
        savedIndex = prefs.getInt('card_design_$phone');
      }
      savedIndex ??= prefs.getInt('selected_card_design');
      if (savedIndex != null) {
        cardDesignNotifier.value = savedIndex;
        if (mounted) {
          setState(() => _selectedCardDesign = savedIndex!);
        }
      }
    } catch (e) {
      debugPrint("Error loading card design: $e");
    }
  }

  Future<void> _loadData() async {
    final token = await _apiService.getToken();
    if (token == null || !mounted) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getTransactionHistory(page: 0, size: 20),
      ]);
      if (!mounted) return;

      final profileResponse = results[0];
      final txResponse = results[1];

      if (profileResponse['success'] == true) {
        _profileData = profileResponse['data'];
        final phone = _profileData?['phoneNumber']?.toString();
        if (phone != null && phone.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final userSaved = prefs.getInt('card_design_$phone');
          if (userSaved != null) {
            cardDesignNotifier.value = userSaved;
            if (mounted) setState(() => _selectedCardDesign = userSaved);
          }
        }
      }

      if (txResponse['success'] == true) {
        final data = txResponse['data'];
        List<dynamic> activities = data?['content'] ?? [];
        activities.sort((a, b) {
          final dateA = DateTime.tryParse(a['date']?.toString() ?? '');
          final dateB = DateTime.tryParse(b['date']?.toString() ?? '');
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        _recentActivities = activities;
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showDesignPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'choose_design'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildBottomSheetSelector(
                      context,
                      0,
                      const Color(0xFF1A5BB5),
                      'basic'.tr,
                    ),
                    _buildBottomSheetSelector(
                      context,
                      1,
                      const Color(0xFFEFA517),
                      'orange'.tr,
                    ),
                    _buildBottomSheetSelector(
                      context,
                      2,
                      const Color(0xFFF00A5B),
                      'pink'.tr,
                    ),
                    _buildBottomSheetSelector(
                      context,
                      3,
                      const Color(0xFF333333),
                      'black'.tr,
                    ),
                    _buildBottomSheetSelector(
                      context,
                      4,
                      const Color(0xFFD30A0A),
                      'red'.tr,
                    ),
                    _buildBottomSheetSelector(
                      context,
                      5,
                      const Color(0xFF0A0A0A),
                      'night'.tr,
                    ),
                    _buildBottomSheetSelector(
                      context,
                      6,
                      const Color(0xFF6B45FF),
                      'purple'.tr,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetSelector(
    BuildContext context,
    int index,
    Color color,
    String name,
  ) {
    final isSelected = _selectedCardDesign == index;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context); // Close sheet after selection
        await _updateCardDesign(index);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WText('${'welcome'.tr},', className: 'text-xs text-gray-400'),
                WText(
                  _profileData != null
                      ? '${_profileData!['firstName']} ${_profileData!['lastName']}'
                      : 'loading'.tr,
                  className: 'text-lg font-bold',
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GiftScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: AppIcon(
                      AppIcons.gift,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ).then((_) {
                      if (mounted) _loadData();
                    });
                  },
                  child: UserAvatar(
                    imageUrl: _profileData?['imageUrl'],
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: WText(
                                  'my_card'.tr,
                                  className: 'text-lg font-bold',
                                ),
                              ),
                              IconButton(
                                icon: const AppIcon(
                                  AppIcons.settings,
                                  color: Colors.grey,
                                  size: 22,
                                ),
                                onPressed: _showDesignPicker,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LoyaltyCardWidget(
                            designIndex: _selectedCardDesign,
                            onDesignChanged: _updateCardDesign,
                            cardHolderName: _profileData != null
                                ? '${_profileData!['firstName']} ${_profileData!['lastName']}'
                                : '',
                            points: (_profileData?['totalBonusPoints'] ?? 0)
                                .toInt(),
                            phoneNumber: _profileData?['phoneNumber'] ?? '',
                          ),
                          const SizedBox(height: 24),
                          WText(
                            'recent_activity'.tr,
                            className: 'text-lg font-bold',
                          ),
                          const SizedBox(height: 16),
                          if (_recentActivities.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32.0,
                                ),
                                child: WText(
                                  'no_activity'.tr,
                                  className: 'text-sm text-gray-500',
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recentActivities.length,
                              itemBuilder: (context, index) {
                                final activity = _recentActivities[index];
                                final type = activity['type'] ?? 'EARNED';
                                final description =
                                    activity['description'] ?? '';
                                final points = activity['points'] ?? 0;
                                final dateStr = activity['date'];
                                final isEarned = type == 'EARNED';

                                String formattedDate = '';
                                if (dateStr != null) {
                                  try {
                                    String dStr = dateStr;
                                    if (!dStr.endsWith('Z')) dStr += 'Z';
                                    final date = DateTime.parse(
                                      dStr,
                                    ).toUtc().add(const Duration(hours: 5));
                                    formattedDate =
                                        _activityDateFormat.format(date);
                                  } catch (e) {
                                    formattedDate = dateStr.toString();
                                  }
                                }

                                final displayPoints =
                                    TwTokens.formatTransactionPoints(points, isEarned);
                                final pointsColor = isEarned
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444);

                                return TwCard(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      TransactionIconBadge(
                                        type: type,
                                        description: description,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            WText(
                                              description.isNotEmpty
                                                  ? description
                                                  : (isEarned
                                                        ? 'points_earned'.tr
                                                        : 'points_spent'.tr),
                                              className:
                                                  'text-sm font-semibold truncate',
                                            ),
                                            if (formattedDate.isNotEmpty) ...[
                                              const SizedBox(height: 3),
                                              WText(
                                                formattedDate,
                                                className:
                                                    'text-xs text-gray-400',
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      WText(
                                        displayPoints,
                                        className: 'text-base font-bold',
                                        color: pointsColor,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

class LoyaltyCardWidget extends StatefulWidget {
  final int designIndex;
  final ValueChanged<int>? onDesignChanged;
  final String cardHolderName;
  final int points;
  final String phoneNumber;
  const LoyaltyCardWidget({
    super.key,
    required this.designIndex,
    this.onDesignChanged,
    required this.cardHolderName,
    required this.points,
    required this.phoneNumber,
  });

  @override
  State<LoyaltyCardWidget> createState() => _LoyaltyCardWidgetState();
}

class _LoyaltyCardWidgetState extends State<LoyaltyCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  Widget _buildCardBackground(int index) {
    switch (index) {
      case 1: // Orange/Purple
        return Container(
          decoration: const BoxDecoration(color: Color(0xFF332087)),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -40,
                child: Container(
                  width: 200,
                  height: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEE9F8E),
                    borderRadius: BorderRadius.circular(120),
                  ),
                ),
              ),
              Positioned(
                top: -50,
                right: -80,
                child: Container(
                  width: 280,
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFA517),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
            ],
          ),
        );
      case 2: // Pink Spirograph
        return Container(
          decoration: const BoxDecoration(color: Color(0xFFF00A5B)),
          child: Stack(
            children:
                List.generate(8, (i) {
                  return Positioned(
                    top: -100.0 + (i * 12),
                    right: -100.0 + (i * 18),
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                })..addAll(
                  List.generate(6, (i) {
                    return Positioned(
                      bottom: -120.0 + (i * 20),
                      left: -80.0 + (i * 12),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
          ),
        );
      case 3: // Black/Grey Abstract
        return Container(
          decoration: const BoxDecoration(color: Color(0xFF141414)),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -80,
                child: Container(
                  width: 250,
                  height: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                right: -40,
                child: Container(
                  width: 320,
                  height: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFF888888).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(160),
                  ),
                ),
              ),
            ],
          ),
        );
      case 4: // Red Concentric
        return Container(
          decoration: const BoxDecoration(color: Color(0xFFD30A0A)),
          child: Stack(
            children: [
              ...List.generate(
                5,
                (i) => Positioned(
                  top: -100.0 - (i * 40),
                  left: 60.0 - (i * 40),
                  child: Container(
                    width: 200.0 + (i * 80),
                    height: 200.0 + (i * 80),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB50000),
                        width: 15,
                      ),
                    ),
                  ),
                ),
              ),
              ...List.generate(
                4,
                (i) => Positioned(
                  bottom: -100.0 - (i * 40),
                  right: -50.0 - (i * 40),
                  child: Container(
                    width: 200.0 + (i * 80),
                    height: 200.0 + (i * 80),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB50000),
                        width: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 5: // Black/Purple/Pink
        return Container(
          decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                left: -50,
                child: Container(
                  width: 250,
                  height: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D24FF),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                right: -80,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0055),
                    borderRadius: BorderRadius.circular(180),
                  ),
                ),
              ),
            ],
          ),
        );
      case 6: // Purple Geometric
        return Container(
          decoration: const BoxDecoration(color: Color(0xFF6B45FF)),
          child: Stack(
            children: [
              Positioned(
                top: 40,
                left: -100,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: 400,
                    height: 20,
                    color: const Color(0xFF4A2DA8),
                  ),
                ),
              ),
              Positioned(
                top: -50,
                right: 60,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Container(
                    width: 20,
                    height: 400,
                    color: const Color(0xFF4A2DA8),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: 50,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Container(
                    width: 300,
                    height: 20,
                    color: const Color(0xFF4A2DA8),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                right: -50,
                child: Transform.rotate(
                  angle: -0.6,
                  child: Container(
                    width: 300,
                    height: 20,
                    color: const Color(0xFF4A2DA8),
                  ),
                ),
              ),
            ],
          ),
        );
      case 0:
      default: // Blue
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A5BB5), Color(0xFF11387A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                left: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return GestureDetector(
          onTap: _flipCard,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null && widget.onDesignChanged != null) {
              const totalDesigns = 7;
              if (details.primaryVelocity! < -150) {
                // Swiped left -> next design
                final next = (widget.designIndex + 1) % totalDesigns;
                widget.onDesignChanged!(next);
              } else if (details.primaryVelocity! > 150) {
                // Swiped right -> previous design
                final prev = (widget.designIndex - 1 + totalDesigns) % totalDesigns;
                widget.onDesignChanged!(prev);
              }
            }
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * pi;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

              final isFront = angle < pi / 2;

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: isFront
                    ? _buildFront()
                    : Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildBack(),
                      ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatPhone(String phone) {
    if (phone.isEmpty) return 'XXXX XXXX XXXX XXXX';
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('998')) {
      return '+998 ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10, 12)}';
    } else {
      return phone;
    }
  }

  Widget _buildFront() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCardBackground(widget.designIndex),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        children: const [
                          AppIcon(AppIcons.star, color: Colors.amber, size: 24),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    _formatPhone(widget.phoneNumber),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'card_holder'.tr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.cardHolderName.isEmpty
                                ? 'Kutib turing...'
                                : widget.cardHolderName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'current_balance'.tr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${NumberFormat('#,###').format(widget.points).replaceAll(',', ' ')} ${'points'.tr}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 40,
                        height: 24,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildBack() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCardBackground(widget.designIndex),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  height: 44,
                  width: double.infinity,
                  color: Colors.black87,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          color: Colors.white,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 8),
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 50,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Text(
                          '123',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Text(
                    'card_info'.tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
