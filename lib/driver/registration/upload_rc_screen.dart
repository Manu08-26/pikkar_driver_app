import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _rcNumberController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _manufacturingYearController = TextEditingController();
  
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
    _rcNumberController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _manufacturingYearController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _pickImage(bool isFront) async {
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
          if (isFront) {
            _frontImage = File(image.path);
          } else {
            _backImage = File(image.path);
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

    if (_frontImage == null || _backImage == null) {
      _showSnackBar('Please upload both front and back images of RC', isError: true);
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

      _showSnackBar('Vehicle information uploaded successfully!');

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
            'Vehicle Information',
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
                        // Vehicle Details Section
                        // _buildSectionHeader('Vehicle Details', Icons.directions_car),
                        // SizedBox(height: Responsive.spacing(context, 16)),
                        
                        // _buildTextField(
                        //   controller: _vehicleNumberController,
                        //   label: 'Vehicle Number',
                        //   hint: 'e.g., KA01AB1234',
                        //   icon: Icons.pin,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter vehicle number';
                        //     }
                        //     return null;
                        //   },
                        //   textCapitalization: TextCapitalization.characters,
                        // ),

                        // SizedBox(height: Responsive.spacing(context, 16)),

                        // _buildTextField(
                        //   controller: _vehicleModelController,
                        //   label: 'Vehicle Model',
                        //   hint: 'e.g., Honda Activa 6G',
                        //   icon: Icons.two_wheeler,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter vehicle model';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        // SizedBox(height: Responsive.spacing(context, 16)),

                        // _buildTextField(
                        //   controller: _manufacturingYearController,
                        //   label: 'Manufacturing Year',
                        //   hint: 'e.g., 2022',
                        //   icon: Icons.calendar_today,
                        //   keyboardType: TextInputType.number,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     LengthLimitingTextInputFormatter(4),
                        //   ],
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter manufacturing year';
                        //     }
                        //     final year = int.tryParse(value);
                        //     if (year == null || year < 1900 || year > DateTime.now().year) {
                        //       return 'Please enter a valid year';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        // SizedBox(height: Responsive.spacing(context, 16)),

                        // _buildTextField(
                        //   controller: _rcNumberController,
                        //   label: 'RC Number',
                        //   hint: 'e.g., 123456789012',
                        //   icon: Icons.credit_card,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter RC number';
                        //     }
                        //     return null;
                        //   },
                        // ),

                        // SizedBox(height: Responsive.spacing(context, 32)),

                        // Upload RC Section
                        _buildSectionHeader('Upload RC Certificate', Icons.upload_file),
                        SizedBox(height: Responsive.spacing(context, 8)),
                        Text(
                          'Please upload clear photos of both sides of your RC',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 13),
                            color: _appTheme.textGrey,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),

                        Row(
                          children: [
                            Expanded(
                              child: _buildImagePicker(
                                label: 'RC Front',
                                image: _frontImage,
                                onTap: () => _pickImage(true),
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 16)),
                            Expanded(
                              child: _buildImagePicker(
                                label: 'RC Back',
                                image: _backImage,
                                onTap: () => _pickImage(false),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.spacing(context, 24)),

                        // Info Card
                        Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 16)),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber.shade700,
                                size: Responsive.iconSize(context, 24),
                              ),
                              SizedBox(width: Responsive.spacing(context, 12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tips for clear photos:',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(context, 14),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.spacing(context, 4)),
                                    Text(
                                      '• Ensure good lighting\n• Keep document flat\n• All text should be clearly visible\n• No blur or glare',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(context, 12),
                                        color: Colors.amber.shade900,
                                        height: 1.5,
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
            height: Responsive.hp(context, 20),
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
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 6)),
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
                            size: Responsive.iconSize(context, 16),
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
                        size: Responsive.iconSize(context, 48),
                        color: _appTheme.textGrey.withOpacity(0.5),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        'Add Photo',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 13),
                          fontWeight: FontWeight.w500,
                          color: _appTheme.textGrey,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 4)),
                      Text(
                        'Tap to upload',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 11),
                          color: _appTheme.textGrey.withOpacity(0.7),
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
