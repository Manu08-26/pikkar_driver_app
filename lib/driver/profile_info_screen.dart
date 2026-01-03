import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final AppTheme _appTheme = AppTheme();
  final ImagePicker _picker = ImagePicker();

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
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_profileImage == null ||
        _aadharFrontImage == null ||
        _aadharBackImage == null ||
        _dlFrontImage == null ||
        _dlBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload all required documents'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile information uploaded successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Return true to indicate successful upload
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              _appTheme.rtlEnabled ? Icons.arrow_forward : Icons.arrow_back,
              color: _appTheme.textColor,
              size: Responsive.iconSize(context, 24),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Profile Info',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: _appTheme.textColor,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Responsive.padding(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage('profile'),
                              child: Container(
                                width: Responsive.wp(context, 32),
                                height: Responsive.wp(context, 32),
                                decoration: BoxDecoration(
                                  color: _appTheme.iconBgColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _appTheme.dividerColor,
                                    width: 1,
                                  ),
                                ),
                                child: _profileImage != null
                                    ? ClipOval(
                                        child: Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.camera_alt,
                                        size: Responsive.iconSize(context, 48),
                                        color: _appTheme.textGrey
                                            .withOpacity(0.5),
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickImage('profile'),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      Responsive.padding(context, 6)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _appTheme.dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: Responsive.iconSize(context, 16),
                                    color: _appTheme.textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Center(
                        child: Text(
                          'Profile picture *',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 14),
                            fontWeight: FontWeight.w500,
                            color: _appTheme.textColor,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 32)),

                      // Upload Aadhar
                      Text(
                        'Upload Aadhar *',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildImagePicker(
                              label: 'Front',
                              image: _aadharFrontImage,
                              onTap: () => _pickImage('aadhar_front'),
                            ),
                          ),
                          SizedBox(width: Responsive.spacing(context, 16)),
                          Expanded(
                            child: _buildImagePicker(
                              label: 'Back',
                              image: _aadharBackImage,
                              onTap: () => _pickImage('aadhar_back'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),

                      // Upload Driving License
                      Text(
                        'Upload Driving License*',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildImagePicker(
                              label: 'Front',
                              image: _dlFrontImage,
                              onTap: () => _pickImage('dl_front'),
                            ),
                          ),
                          SizedBox(width: Responsive.spacing(context, 16)),
                          Expanded(
                            child: _buildImagePicker(
                              label: 'Back',
                              image: _dlBackImage,
                              onTap: () => _pickImage('dl_back'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Submit Button
              Padding(
                padding: EdgeInsets.all(Responsive.padding(context, 24)),
                child: SizedBox(
                  width: double.infinity,
                  height: Responsive.hp(context, 6.9),
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
                        ? SizedBox(
                            width: Responsive.iconSize(context, 24),
                            height: Responsive.iconSize(context, 24),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Submit',
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
            fontWeight: FontWeight.w500,
            color: _appTheme.textGrey,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 8)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: Responsive.hp(context, 15),
            decoration: BoxDecoration(
              color: _appTheme.iconBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _appTheme.dividerColor,
                width: 1,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: Responsive.iconSize(context, 32),
                        color: _appTheme.textGrey.withOpacity(0.5),
                      ),
                      SizedBox(height: Responsive.spacing(context, 4)),
                      Text(
                        'Take Photo',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 10),
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

