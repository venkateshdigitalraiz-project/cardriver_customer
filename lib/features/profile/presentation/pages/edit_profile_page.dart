import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatelessWidget {
  final ProfileBloc profileBloc;
  const EditProfilePage({super.key, required this.profileBloc});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme.copyWith(scaffoldBackgroundColor: Colors.white),
      child: BlocProvider.value(
        value: profileBloc,
        child: const EditProfileView(),
      ),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile updated successfully!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context); // Go back after success
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final profile = state is ProfileLoaded
              ? state.profile
              : (state is ProfileLoading
                    ? state.currentProfile
                    : (state is ProfileError ? state.currentProfile : null));

          if (profile == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Beautiful Curved Header with Overlapping Avatar
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 150,
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
                        child: Stack(
                          children: [
                            Container(
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
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () =>
                                    _showImageSourceActionSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Body content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader(
                          context,
                          'Personal Information',
                          Icons.badge,
                        ),
                        _buildCardForm(
                          children: [
                            _buildTextField(
                              context,
                              label: 'Full Name',
                              initialValue: profile.fullName,
                              icon: Icons.person_outline,
                              onChanged: (val) => context
                                  .read<ProfileBloc>()
                                  .add(UpdateProfileFieldEvent(fullName: val)),
                            ),
                            _buildDivider(),
                            _buildTextField(
                              context,
                              label: 'Last Name',
                              initialValue: profile.lastName,
                              icon: Icons.person_outline,
                              onChanged: (val) => context
                                  .read<ProfileBloc>()
                                  .add(UpdateProfileFieldEvent(lastName: val)),
                            ),
                            _buildDivider(),
                            _buildTextField(
                              context,
                              label: 'Mobile Number',
                              initialValue: profile.mobileNumber,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              onChanged: (val) =>
                                  context.read<ProfileBloc>().add(
                                    UpdateProfileFieldEvent(mobileNumber: val),
                                  ),
                            ),
                            _buildDivider(),
                            _buildTextField(
                              context,
                              label: 'Email Address',
                              initialValue: profile.email,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) => context
                                  .read<ProfileBloc>()
                                  .add(UpdateProfileFieldEvent(email: val)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        _buildSectionHeader(
                          context,
                          'Vehicle Information',
                          Icons.directions_car,
                        ),
                        _buildDropdownField(
                          context,
                          label: 'Vehicle Color',
                          value: profile.vehicleColor.isEmpty
                              ? null
                              : profile.vehicleColor,
                          icon: Icons.color_lens_outlined,
                          items: const [
                            'White',
                            'Black',
                            'Silver',
                            'Red',
                            'Blue',
                            'Grey',
                            'Other',
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              context.read<ProfileBloc>().add(
                                UpdateProfileFieldEvent(vehicleColor: val),
                              );
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildTextField(
                          context,
                          label: 'Car Name',
                          initialValue: profile.carName,
                          icon: Icons.drive_eta_outlined,
                          onChanged: (val) => context.read<ProfileBloc>().add(
                            UpdateProfileFieldEvent(carName: val),
                          ),
                        ),
                        _buildDivider(),
                        _buildCardForm(
                          children: [
                            _buildTextField(
                              context,
                              label: 'Car Type (e.g. SUV, Sedan)',
                              initialValue: profile.carType,
                              icon: Icons.directions_car_outlined,
                              onChanged: (val) => context
                                  .read<ProfileBloc>()
                                  .add(UpdateProfileFieldEvent(carType: val)),
                            ),

                            _buildDivider(),
                            _buildTextField(
                              context,
                              label: 'Registration Number',
                              initialValue: profile.registrationNumber,
                              icon: Icons.pin_outlined,
                              onChanged: (val) =>
                                  context.read<ProfileBloc>().add(
                                    UpdateProfileFieldEvent(
                                      registrationNumber: val,
                                    ),
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: state is ProfileLoading
                              ? null
                              : () {
                                  bool isFormValid = _formKey.currentState!
                                      .validate();
                                  bool isImageValid =
                                      profile.imagePath != null &&
                                      profile.imagePath!.isNotEmpty;

                                  if (!isImageValid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Please select a profile picture',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }

                                  if (!isFormValid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Please fill all required fields',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }

                                  if (isFormValid && isImageValid) {
                                    context.read<ProfileBloc>().add(
                                      SubmitProfileEvent(),
                                    );
                                  }
                                },
                          child: state is ProfileLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Profile'),
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
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String initialValue,
    required IconData icon,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  child: Text(
                    'Update Profile Picture',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    context.read<ProfileBloc>().add(
                      const PickProfileImageEvent(fromCamera: false),
                    );
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    context.read<ProfileBloc>().add(
                      const PickProfileImageEvent(fromCamera: true),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
