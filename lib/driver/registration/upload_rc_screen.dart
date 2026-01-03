import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class UploadRCScreen extends StatefulWidget {
  const UploadRCScreen({super.key});

  @override
  State<UploadRCScreen> createState() => _UploadRCScreenState();
}

class _UploadRCScreenState extends State<UploadRCScreen> {
  final AppTheme _appTheme = AppTheme();
  final ImagePicker _picker = ImagePicker();
  
  File? _frontImage;
  File? _backImage;
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

  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(image.path);
          } else {
            _backImage = File(image.path);
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
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload both front and back images'),
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
          content: const Text('RC uploaded successfully'),
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
            'Upload RC',
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
                      Text(
                        'Upload RC *',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 20)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildImagePicker(
                              label: 'Front',
                              image: _frontImage,
                              onTap: () => _pickImage(true),
                            ),
                          ),
                          SizedBox(width: Responsive.spacing(context, 16)),
                          Expanded(
                            child: _buildImagePicker(
                              label: 'Back',
                              image: _backImage,
                              onTap: () => _pickImage(false),
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
            height: Responsive.hp(context, 20),
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
                        size: Responsive.iconSize(context, 40),
                        color: _appTheme.textGrey.withOpacity(0.5),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        'Take Photo',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 12),
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

