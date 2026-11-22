import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/profile/profile_bloc.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/error_handle.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePagePageState();
}

class _ProfilePagePageState extends State<ProfilePage> {
  final _formProfilKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  File? _image;
  final picker = ImagePicker();

  Map<String, String> _errorMessages = {};

  String? _avatarUrl;

  Future getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(_buildSnackbar('No Image Selected', Colors.red));
        }
      });
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context)
            .showSnackBar(_buildSnackbar('No Image Selected', Colors.red));
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileSection();
  }

  Widget _buildProfileSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          state.maybeWhen(
            loadedProfile: (customer) {
              _fullNameController.text = customer.name.toString();
              _emailController.text = customer.email.toString();

              _avatarUrl = customer.image == null
                  ? null
                  : '${AppConfig.STORAGE_AVATAR}${customer.image}';
            },
            updatedProfile: (message) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(_buildSnackbar(message, Colors.green));
              context.read<ProfileBloc>().add(ProfileEvent.loadProfile());
            },
            orElse: () {},
            failure: (error) {
              _errorMessages = ErrorHandler.parseErrors(error);
            },
          );
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 18,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formProfilKey,
                        child: Column(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: _image != null
                                        ? FileImage(_image!) // Gunakan gambar yang dipilih pengguna
                                        : (_avatarUrl != null)
                                        ? NetworkImage(
                                            _avatarUrl!,
                                          ) // Gunakan URL dari server
                                        : null, // Tidak ada gambar
                                    backgroundColor: Colors.grey,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Implement change photo logic
                                        getImage();
                                      },
                                      child: const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.deepOrange,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _textFieldFullName(),
                            _textFieldEmail(),
                            _textFieldPassword(),
                            _textFieldConfirmPassword(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buttonUpdateProfile(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _textFieldPassword() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        errorText: _errorMessages['password'],
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget _textFieldFullName() {
    return TextFormField(
      controller: _fullNameController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        return null;
      },
    );
  }

  Widget _textFieldEmail() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _errorMessages['email'],
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _textFieldConfirmPassword() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        errorText: _errorMessages['password'],
        prefixIcon: Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget _buttonUpdateProfile() {
    return FilledButton(
      onPressed: () {
        if (_formProfilKey.currentState!.validate()) {
          final fullName = _fullNameController.text;
          final email = _emailController.text;
          final password = _passwordController.text;
          final confirmPassword = _confirmPasswordController.text;

          context.read<ProfileBloc>().add(
            ProfileEvent.updateProfile(
              name: fullName,
              email: email,
              image: _image,
              password: password,
              passwordConfirmation: confirmPassword,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Center(
        child: Text(
          'Update Profile',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  SnackBar _buildSnackbar(String message, Color color) {
    return SnackBar(
      content: Text(message),
      backgroundColor: color,
      showCloseIcon: true,
    );
  }
}
