import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const LoginPage({super.key, this.onToggleTheme, this.isDarkMode = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginBloc>().add(const LoadIntroBannersRequested());
    });
  }

  void _startAutoScroll(int count) {
    _autoScrollTimer?.cancel();
    if (count <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final current = _pageController.page?.round() ?? 0;
      final next = (current + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark &&
        MediaQuery.of(context).size.width == 0; // Forced light theme
    final size = MediaQuery.of(context).size;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.introBanners.isNotEmpty && _autoScrollTimer == null) {
          _startAutoScroll(state.introBanners.length);
        }

        if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppDimens.p16),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDimens.borderRadiusMedium,
              ),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: AppDimens.p12),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state.status == LoginStatus.success) {
          context.read<LoginBloc>().add(const ResetLoginState());
          context.go(AppRoutes.main);
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: Stack(
          children: [
            // Top Intro Carousel with PageView & dynamic API banners
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.5, // Fixed height at top
              child: BlocBuilder<LoginBloc, LoginState>(
                buildWhen: (prev, curr) =>
                    prev.introBanners != curr.introBanners ||
                    prev.currentBannerIndex != curr.currentBannerIndex ||
                    prev.isLoadingBanners != curr.isLoadingBanners,
                builder: (context, state) {
                  final banners = state.introBanners;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // PageView for dynamic banners
                      if (banners.isNotEmpty)
                        PageView.builder(
                          controller: _pageController,
                          itemCount: banners.length,
                          onPageChanged: (index) {
                            context
                                .read<LoginBloc>()
                                .add(IntroBannerPageChanged(index));
                          },
                          itemBuilder: (context, index) {
                            final banner = banners[index];
                            final fullUrl =
                                ApiEndpoints.resolveImageUrl(banner.imageUrl);

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  fullUrl,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFF1B2838),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white54,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?q=80&w=1000',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        )
                      else
                        // Fallback while loading or if offline
                        Image.network(
                          'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?q=80&w=1000',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),

                      // Gradient overlay for contrast and sleek visual polish
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.65),
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.40),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // App Icon / Logo & Title at top
                      Positioned(
                        top: 60,
                        left: 24,
                        right: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE94E34), // Orange/Red
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Positioned(
                                      left: 8,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2A33A)
                                              .withValues(alpha: 0.9), // Yellow
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "Let's drive",
                              style: AppTypography.displayMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animated Page Indicator Dots (above the frosted glass sheet)
                      if (banners.length > 1)
                        Positioned(
                          top: (size.height * 0.4) - 26,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              banners.length,
                              (index) {
                                final isActive =
                                    index == state.currentBannerIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: isActive ? 22 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Overlapping Sheet with Glassmorphism & Animation
            Positioned(
              top: size.height * 0.4, // Glass panel starts here
              left: 0,
              right: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.75,
                        ), // Light frosted glass
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: AppDimens.p24,
                          right: AppDimens.p24,
                          top: AppDimens.p32,
                          bottom: AppDimens.p32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Logo Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Find a Driver',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                // Brand Mark (Similar to the reference logo)
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceElevatedDark
                                        : AppColors.inputFillLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Positioned(
                                          left: 10,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.8),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimens.p24),

                            // Form Fields & Action
                            const LoginForm(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
