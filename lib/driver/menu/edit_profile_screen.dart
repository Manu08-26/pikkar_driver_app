import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AppTheme _appTheme = AppTheme();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _firstNameController = TextEditingController(text: 'Sri');
  final TextEditingController _lastNameController = TextEditingController(text: 'Akshay');
  final TextEditingController _emailController = TextEditingController(text: 'sri.akshay@email.com');
  final TextEditingController _phoneController = TextEditingController(text: '+91-99667 78855');
  final TextEditingController _addressController = TextEditingController(text: 'Hyderabad, Telangana');
  final TextEditingController _emergencyContactController = TextEditingController(text: '+91-98765 43210');

  bool _isLoading = false;
  bool _phoneChanged = false;
  bool _profilePictureChanged = false;
  String _originalPhone = '+91-99667 78855';

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    
    // Listen for phone number changes
    _phoneController.addListener(() {
      if (_phoneController.text != _originalPhone) {
        setState(() {
          _phoneChanged = true;
        });
      } else {
        setState(() {
          _phoneChanged = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _pickImage() async {
    // Show warning dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: Responsive.iconSize(context, 28),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Text(
              'Review Required',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Changing your profile picture requires admin review. Your new picture will be visible after approval. Do you want to continue?',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            color: _appTheme.textGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: _appTheme.textGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _appTheme.brandRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profilePictureChanged = true;
        });
        
        // Here you would upload the image to your server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture submitted for review'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to pick image'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Check if sensitive data was changed
      if (_phoneChanged || _profilePictureChanged) {
        _showReviewDialog();
      } else {
        _submitChanges();
      }
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.pending_actions,
              color: Colors.orange,
              size: Responsive.iconSize(context, 28),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: Text(
                'Review Required',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your changes require admin review:',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 12)),
            if (_phoneChanged)
              _buildReviewItem('Mobile number change'),
            if (_profilePictureChanged)
              _buildReviewItem('Profile picture change'),
            SizedBox(height: Responsive.spacing(context, 12)),
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 12)),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: Responsive.iconSize(context, 20),
                  ),
                  SizedBox(width: Responsive.spacing(context, 8)),
                  Expanded(
                    child: Text(
                      'You can continue using the app while under review. Changes will be visible after approval.',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 12),
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: _appTheme.textGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitChanges();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _appTheme.brandRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Submit for Review',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context, 6)),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.orange,
            size: Responsive.iconSize(context, 18),
          ),
          SizedBox(width: Responsive.spacing(context, 8)),
          Text(
            text,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 13),
              color: _appTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _submitChanges() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String message;
        Color bgColor;
        
        if (_phoneChanged || _profilePictureChanged) {
          message = 'Changes submitted for review. You will be notified once approved.';
          bgColor = Colors.orange;
        } else {
          message = 'Profile updated successfully';
          bgColor = Colors.green;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _appTheme.textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, 24)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: Responsive.wp(context, 32),
                      height: Responsive.wp(context, 32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _profilePictureChanged ? Colors.orange : Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: Responsive.iconSize(context, 64),
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (_profilePictureChanged)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 4)),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.pending,
                            size: Responsive.iconSize(context, 16),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 10)),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: Responsive.iconSize(context, 20),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 8)),
              Text(
                _profilePictureChanged 
                    ? 'Pending admin review'
                    : 'Tap to change profile picture',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 12),
                  color: _profilePictureChanged ? Colors.orange : _appTheme.textGrey,
                  fontWeight: _profilePictureChanged ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 24)),

              // Info Banner
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: Responsive.iconSize(context, 20),
                    ),
                    SizedBox(width: Responsive.spacing(context, 8)),
                    Expanded(
                      child: Text(
                        'Name cannot be changed after registration. Phone & profile picture changes require review.',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 11),
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 24)),

              // First Name Field (Disabled)
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline,
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, 16)),

              // Last Name Field (Disabled)
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, 16)),

              // Phone Field (Enabled but with review warning)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: true,
                    showWarning: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  if (_phoneChanged)
                    Padding(
                      padding: EdgeInsets.only(
                        top: Responsive.spacing(context, 6),
                        left: Responsive.spacing(context, 4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pending_outlined,
                            size: Responsive.iconSize(context, 14),
                            color: Colors.orange,
                          ),
                          SizedBox(width: Responsive.spacing(context, 4)),
                          Text(
                            'This change requires admin review',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 11),
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: Responsive.spacing(context, 16)),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, 16)),

              // Address Field
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, 16)),

              // Emergency Contact Field
              _buildTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact',
                icon: Icons.contact_phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter emergency contact';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, 32)),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: Responsive.hp(context, 6.5),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _appTheme.brandRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: _appTheme.brandRed.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: Responsive.iconSize(context, 24),
                          height: Responsive.iconSize(context, 24),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    bool showWarning = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(
        fontSize: Responsive.fontSize(context, 15),
        color: enabled ? _appTheme.textColor : _appTheme.textGrey,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: Responsive.fontSize(context, 14),
          color: _appTheme.textGrey,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? Colors.black : _appTheme.textGrey,
          size: Responsive.iconSize(context, 22),
        ),
        suffixIcon: showWarning
            ? Tooltip(
                message: 'Requires admin review',
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: Responsive.iconSize(context, 20),
                ),
              )
            : null,
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 16),
          vertical: Responsive.padding(context, 16),
        ),
      ),
    );
  }
}

