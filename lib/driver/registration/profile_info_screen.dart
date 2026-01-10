import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final AppTheme _appTheme = AppTheme();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _dlNumberController = TextEditingController();

  File? _profileImage;
  File? _aadharFrontImage;
  File? _aadharBackImage;
  File? _dlFrontImage;
  File? _dlBackImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aadharController.dispose();
    _dlNumberController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _pickImage(String type) async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(Responsive.padding(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 20)),
              Text(
                'Choose Photo Source',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: _appTheme.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 20)),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, 16)),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacing(context, 20)),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (type) {
            case 'profile':
              _profileImage = File(image.path);
              break;
            case 'aadhar_front':
              _aadharFrontImage = File(image.path);
              break;
            case 'aadhar_back':
              _aadharBackImage = File(image.path);
              break;
            case 'dl_front':
              _dlFrontImage = File(image.path);
              break;
            case 'dl_back':
              _dlBackImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _appTheme.brandRed : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_profileImage == null) {
      _showSnackBar('Please upload profile photo', isError: true);
      return;
    }

    if (_aadharFrontImage == null ||
        _aadharBackImage == null ||
        _dlFrontImage == null ||
        _dlBackImage == null) {
      _showSnackBar('Please upload all required documents', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate upload
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      _showSnackBar('Profile information uploaded successfully!');

      // Return true to indicate successful upload
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: _appTheme.brandRed,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Profile Information',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Responsive.padding(context, 20)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _pickImage('profile'),
                                    child: Container(
                                      width: Responsive.wp(context, 32),
                                      height: Responsive.wp(context, 32),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _profileImage != null
                                              ? _appTheme.brandRed
                                              : Colors.grey.shade300,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: _profileImage != null
                                          ? ClipOval(
                                              child: Image.file(
                                                _profileImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: Responsive.iconSize(context, 64),
                                              color: _appTheme.textGrey.withOpacity(0.3),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _pickImage('profile'),
                                      child: Container(
                                        padding: EdgeInsets.all(Responsive.padding(context, 10)),
                                        decoration: BoxDecoration(
                                          color: _appTheme.brandRed,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: Responsive.iconSize(context, 20),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.spacing(context, 12)),
                              Text(
                                'Profile Picture *',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: _appTheme.textColor,
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 4)),
                              Text(
                                'Tap to upload',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 12),
                                  color: _appTheme.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: Responsive.spacing(context, 32)),

                        // Personal Details Section
                        _buildSectionHeader('Personal Details', Icons.person_outline),
                        SizedBox(height: Responsive.spacing(context, 16)),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                hint: 'Enter first name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 12)),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                hint: 'Enter last name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.spacing(context, 16)),

                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'your.email@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Responsive.spacing(context, 16)),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '10-digit mobile number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (value.length != 10) {
                              return 'Enter 10-digit number';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Responsive.spacing(context, 32)),

                        // Aadhar Section
                        _buildSectionHeader('Aadhar Card', Icons.credit_card),
                        // SizedBox(height: Responsive.spacing(context, 12)),
                        
                        // _buildTextField(
                        //   controller: _aadharController,
                        //   label: 'Aadhar Number',
                        //   hint: '12-digit Aadhar number',
                        //   icon: Icons.badge_outlined,
                        //   keyboardType: TextInputType.number,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     LengthLimitingTextInputFormatter(12),
                        //   ],
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter Aadhar number';
                        //     }
                        //     if (value.length != 12) {
                        //       return 'Enter 12-digit Aadhar number';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        SizedBox(height: Responsive.spacing(context, 16)),

                        Row(
                          children: [
                            Expanded(
                              child: _buildImagePicker(
                                label: 'Aadhar Front',
                                image: _aadharFrontImage,
                                onTap: () => _pickImage('aadhar_front'),
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 16)),
                            Expanded(
                              child: _buildImagePicker(
                                label: 'Aadhar Back',
                                image: _aadharBackImage,
                                onTap: () => _pickImage('aadhar_back'),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.spacing(context, 32)),

                        // // Driving License Section
                        _buildSectionHeader('Driving License', Icons.payment),
                        SizedBox(height: Responsive.spacing(context, 12)),
                        
                        // _buildTextField(
                        //   controller: _dlNumberController,
                        //   label: 'DL Number',
                        //   hint: 'Enter DL number',
                        //   icon: Icons.assignment_ind_outlined,
                        //   textCapitalization: TextCapitalization.characters,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter DL number';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        // SizedBox(height: Responsive.spacing(context, 16)),

                        Row(
                          children: [
                            Expanded(
                              child: _buildImagePicker(
                                label: 'DL Front',
                                image: _dlFrontImage,
                                onTap: () => _pickImage('dl_front'),
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 16)),
                            Expanded(
                              child: _buildImagePicker(
                                label: 'DL Back',
                                image: _dlBackImage,
                                onTap: () => _pickImage('dl_back'),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.spacing(context, 24)),

                        // Info Card
                        Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 16)),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.blue.shade700,
                                size: Responsive.iconSize(context, 24),
                              ),
                              SizedBox(width: Responsive.spacing(context, 12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Data is Safe',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(context, 14),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.spacing(context, 4)),
                                    Text(
                                      'All documents are encrypted and stored securely. We never share your personal information.',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(context, 12),
                                        color: Colors.blue.shade900,
                                        height: 1.4,
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
                  ),
                ),
              ),

              // Submit Button
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: Responsive.hp(context, 6.5),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _appTheme.brandRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor:
                          _appTheme.brandRed.withOpacity(0.6),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: Responsive.iconSize(context, 20),
                                height: Responsive.iconSize(context, 20),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: Responsive.spacing(context, 12)),
                              Text(
                                'Uploading...',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Submit & Continue',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.padding(context, 8)),
          decoration: BoxDecoration(
            color: _appTheme.brandRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: _appTheme.brandRed,
            size: Responsive.iconSize(context, 20),
          ),
        ),
        SizedBox(width: Responsive.spacing(context, 12)),
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: _appTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _appTheme.brandRed),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _appTheme.brandRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 20)),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: Responsive.iconSize(context, 40),
              color: _appTheme.brandRed,
            ),
            SizedBox(height: Responsive.spacing(context, 8)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: _appTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 8)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: Responsive.hp(context, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: image != null ? _appTheme.brandRed : Colors.grey.shade300,
                width: image != null ? 2 : 1,
              ),
            ),
            child: image != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 5)),
                          decoration: BoxDecoration(
                            color: _appTheme.brandRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: Responsive.iconSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: Responsive.iconSize(context, 36),
                        color: _appTheme.textGrey.withOpacity(0.5),
                      ),
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Text(
                        'Add Photo',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 12),
                          fontWeight: FontWeight.w500,
                          color: _appTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
