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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Pass the current ProfileBloc instance to the EditProfilePage
              final profileBloc = context.read<ProfileBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage(profileBloc: profileBloc),
                ),
              );
            },
          ),
        ],
      ),
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
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Beautiful Curved Header with Avatar (Read-Only)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 140,
                      margin: const EdgeInsets.only(bottom: 60),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: profile.imagePath != null
                              ? FileImage(File(profile.imagePath!))
                              : null,
                          child: profile.imagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),

                if (profile.fullName.isNotEmpty ||
                    profile.lastName.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${profile.fullName} ${profile.lastName}'.trim(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
                if (profile.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Body content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardForm(
                        children: [
                          _buildMenuItem(
                            context,
                            title: 'Notifications',
                            icon: Icons.notifications_none_outlined,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'Saved Locations',
                            icon: Icons.location_on_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => LocationBloc(),
                                    child: const SavedLocationsPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'Help & Support',
                            icon: Icons.help_outline,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'My Tickets',
                            icon: Icons.confirmation_num_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TicketsPage(),
                                ),
                              );
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'Terms & Conditions',
                            icon: Icons.description_outlined,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'Privacy Policy',
                            icon: Icons.lock_outline,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'Rate App',
                            icon: Icons.star_border,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'Share App',
                            icon: Icons.share_outlined,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            title: 'Logout',
                            icon: Icons.logout,
                            textColor: AppColors.error,
                            iconColor: AppColors.error,
                            showTrailingArrow: false,
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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

  // Widget _buildSectionHeader(
  //   BuildContext context,
  //   String title,
  //   IconData icon,
  // ) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: AppColors.primaryDark, size: 22),
  //         const SizedBox(width: 10),
  //         Text(
  //           title,
  //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //             fontWeight: FontWeight.w700,
  //             color: AppColors.textPrimaryLight,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCardForm({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
      color: Color(0xFFF0F4F9),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool showTrailingArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.grey[600], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.textPrimaryLight,
                ),
              ),
            ),
            if (showTrailingArrow)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
