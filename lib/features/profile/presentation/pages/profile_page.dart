import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_page.dart';
import '../../../tickets/presentation/pages/tickets_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../locations/presentation/pages/saved_locations_page.dart';
import '../../../locations/presentation/bloc/location_bloc.dart';
import '../../../locations/presentation/bloc/location_event.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../legal/presentation/pages/legal_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme.copyWith(scaffoldBackgroundColor: Colors.white),
      child: BlocProvider(
        create: (context) => ProfileBloc(),
        child: const ProfileView(),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final profile = state is ProfileLoaded
              ? state.profile
              : (state is ProfileLoading
                    ? state.currentProfile
                    : (state is ProfileError ? state.currentProfile : null));

          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Brand Yellow Header
                Container(
                  padding: const EdgeInsets.only(bottom: 24),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // AppBar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 48,
                              ), // Balance for centering
                              const Text(
                                'My Profile',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  final profileBloc = context
                                      .read<ProfileBloc>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                        profileBloc: profileBloc,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Profile Info Row
                        Padding(
                          padding: EdgeInsets.zero,
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: 24,
                          //   vertical: 16,
                          // ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black87,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  backgroundImage: profile.imagePath != null
                                      ? FileImage(File(profile.imagePath!))
                                      : null,
                                  child: profile.imagePath == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.black54,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (profile.fullName.isNotEmpty ||
                                  profile.lastName.isNotEmpty) ...[
                                Text(
                                  '${profile.fullName} ${profile.lastName}'
                                      .trim(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              if (profile.email.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  profile.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // const SizedBox(height: 16),

                        // Stats Row inside Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                _buildStatItem('Bookings', '24'),
                                _buildStatDivider(color: Colors.black12),
                                _buildStatItem('Rating', '4.9 ★'),
                                _buildStatDivider(color: Colors.black12),
                                _buildStatItem('Wallet', '₹450'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menus
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 40),
                  child: Column(
                    children: [
                      // Account Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildSectionHeader('Account Settings'),
                            _buildCardGroup(
                              children: [
                                _buildPremiumMenuItem(
                                  title: 'Saved Locations',
                                  icon: Icons.location_on_rounded,
                                  iconBgColor: Colors.blue.shade50,
                                  iconColor: Colors.blue.shade700,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider(
                                          create: (context) =>
                                              LocationBloc()
                                                ..add(LoadLocations()),
                                          child: const SavedLocationsPage(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildPremiumMenuItem(
                                  title: 'My Tickets',
                                  icon: Icons.confirmation_num_rounded,
                                  iconBgColor: Colors.orange.shade50,
                                  iconColor: Colors.orange.shade700,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TicketsPage(),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildPremiumMenuItem(
                                  title: 'Notifications',
                                  icon: Icons.notifications_rounded,
                                  iconBgColor: Colors.purple.shade50,
                                  iconColor: Colors.purple.shade700,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationsPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Support Section
                            _buildSectionHeader('Support & About'),
                            _buildCardGroup(
                              children: [
                                // _buildPremiumMenuItem(
                                //   title: 'Help & Support',
                                //   icon: Icons.help_rounded,
                                //   iconBgColor: Colors.green.shade50,
                                //   iconColor: Colors.green.shade700,
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) =>
                                //             const SupportPage(),
                                //       ),
                                //     );
                                //   },
                                // ),
                                // _buildDivider(),
                                _buildPremiumMenuItem(
                                  title: 'Terms & Conditions',
                                  icon: Icons.description_rounded,
                                  iconBgColor: Colors.grey.shade100,
                                  iconColor: Colors.grey.shade700,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LegalPage(
                                          pageType: LegalPageType.terms,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildPremiumMenuItem(
                                  title: 'Privacy Policy',
                                  icon: Icons.shield_rounded,
                                  iconBgColor: Colors.grey.shade100,
                                  iconColor: Colors.grey.shade700,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LegalPage(
                                          pageType: LegalPageType.privacy,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Logout Button
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                '     Log Out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider({Color? color}) {
    return Container(
      height: 40,
      width: 1,
      color: color ?? Colors.grey.shade200,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF4F7FB),
      indent: 56,
      endIndent: 16,
    );
  }

  Widget _buildPremiumMenuItem({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    bool showTrailingArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (showTrailingArrow)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black26,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
