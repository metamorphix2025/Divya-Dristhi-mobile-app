import 'package:divya_drishti/screens/presentation/auth/registration_page.dart';
import 'package:divya_drishti/screens/presentation/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (index) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _showForgotPassword = false;
  bool _showOtpVerification = false;
  bool _showSetPassword = false;
  String _resetPhone = '';

  @override
  void initState() {
    super.initState();
    // Setup OTP focus nodes
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      _otpFocusNodes[i].addListener(() {
        if (!_otpFocusNodes[i].hasFocus && _otpControllers[i].text.isEmpty) {
          // Move focus to previous if current is empty and lost focus
          if (i > 0) {
            _otpFocusNodes[i - 1].requestFocus();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Name
                Center(
                  child: Text(
                    'Divya Drishti',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    _showSetPassword
                      ? 'Set your new password'
                      : _showOtpVerification 
                        ? 'Enter OTP sent to $_resetPhone'
                        : _showForgotPassword 
                          ? 'Reset your password'
                          : 'Sign in to continue your spiritual journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Login/Forgot Password Box
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: _showSetPassword
                      ? _buildSetPassword()
                      : _showOtpVerification 
                        ? _buildOtpVerification()
                        : _showForgotPassword 
                          ? _buildForgotPassword()
                          : _buildLoginForm(),
                  ),
                ),
                
                if (!_showForgotPassword && !_showOtpVerification && !_showSetPassword) ...[
                  SizedBox(height: 30),
                  
                  // Create Account Option (Outside the box)
                  Column(
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 400),
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistrationPage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppColors.primary),
                          ),
                          child: Text(
                            'Create New Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Phone Number Field
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hintText: 'Enter your phone number',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        
        SizedBox(height: 20),
        
        // Password Field
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock,
          isPassword: true,
          isPasswordVisible: _isPasswordVisible,
          onTogglePassword: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        
        SizedBox(height: 10),
        
        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _showForgotPassword = true;
              });
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 25),
        
        // Login Button
        Container(
          width: double.infinity,
          height: 56,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    _login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Column(
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 20),
        
        _buildTextField(
          controller: TextEditingController(),
          label: 'Phone Number',
          hintText: 'Enter your registered phone number',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _resetPhone = value;
          },
        ),
        
        SizedBox(height: 25),
        
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_resetPhone.length == 10) {
                setState(() {
                  _showOtpVerification = true;
                  _showForgotPassword = false;
                });
                _sendOtp();
              } else {
                _showErrorDialog(context, 'Please enter a valid 10-digit phone number');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Send OTP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 15),
        
        TextButton(
          onPressed: () {
            setState(() {
              _showForgotPassword = false;
            });
          },
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerification() {
    return Column(
      children: [
        Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter the 4-digit code sent to $_resetPhone',
          style: TextStyle(
            color: AppColors.primary.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 30),
        
        // OTP Input Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 3) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  
                  // Auto verify when all fields are filled
                  if (_isOtpComplete() && index == 3) {
                    _verifyOtp();
                  }
                },
              ),
            );
          }),
        ),
        
        SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code? ",
              style: TextStyle(color: AppColors.primary.withOpacity(0.7)),
            ),
            TextButton(
              onPressed: _resendOtp,
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 25),
        
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isOtpComplete() ? _verifyOtp : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 15),
        
        TextButton(
          onPressed: () {
            setState(() {
              _showOtpVerification = false;
              _showForgotPassword = true;
              _clearOtpFields();
            });
          },
          child: Text(
            'Change Phone Number',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetPassword() {
    return Column(
      children: [
        Text(
          'Set New Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Create a strong password for your account',
          style: TextStyle(
            color: AppColors.primary.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 25),
        
        // New Password Field
        _buildPasswordField(
          controller: _newPasswordController,
          label: 'New Password',
          hintText: 'Enter new password',
          isPasswordVisible: _isNewPasswordVisible,
          onTogglePassword: () {
            setState(() {
              _isNewPasswordVisible = !_isNewPasswordVisible;
            });
          },
        ),
        
        SizedBox(height: 20),
        
        // Confirm Password Field
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Re-enter new password',
          isPasswordVisible: _isConfirmPasswordVisible,
          onTogglePassword: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        
        SizedBox(height: 15),
        
        // Password requirements
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password must contain:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• At least 6 characters',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              Text(
                '• One uppercase letter',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              Text(
                '• One number',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 25),
        
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 15),
        
        TextButton(
          onPressed: () {
            setState(() {
              _showSetPassword = false;
              _showOtpVerification = true;
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            });
          },
          child: Text(
            'Back to OTP',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(prefixIcon, color: AppColors.primary),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primary,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onTogglePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.lock, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primary,
                ),
                onPressed: onTogglePassword,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isOtpComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  void _login(BuildContext context) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    
    if (phone.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'Please fill all fields');
      return;
    }
    
    if (phone.length != 10) {
      _showErrorDialog(context, 'Please enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
    
    print('Login successful with phone: $phone');
  }

  void _sendOtp() {
    print('Sending OTP to $_resetPhone');
    // Implement OTP sending logic
  }

  void _resendOtp() {
    print('Resending OTP to $_resetPhone');
    _clearOtpFields();
    _otpFocusNodes[0].requestFocus();
    // Implement OTP resend logic
  }

  void _verifyOtp() {
    String otp = _otpControllers.map((controller) => controller.text).join();
    print('Verifying OTP: $otp');
    
    // For demo, assume OTP is correct
    setState(() {
      _showOtpVerification = false;
      _showSetPassword = true;
    });
  }

  void _resetPassword() {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showErrorDialog(context, 'Please fill all fields');
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog(context, 'Passwords do not match');
      return;
    }
    
    if (_newPasswordController.text.length < 6) {
      _showErrorDialog(context, 'Password must be at least 6 characters');
      return;
    }
    
    // Implement password reset logic
    print('Password reset for $_resetPhone');
    
    // Show success and return to login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset successfully!')),
    );
    
    setState(() {
      _showSetPassword = false;
      _showForgotPassword = false;
      _showOtpVerification = false;
      _clearOtpFields();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}