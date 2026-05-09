import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapplictions/utils/flutter_color_themes.dart';
import 'package:blogapplictions/utils/flutter_font_style.dart';
import 'package:blogapplictions/utils/constants.dart';
import 'package:blogapplictions/screen/auth/LoginScreen/bloc/sigUpBloc/sig_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
   SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isAgreed = false;
  bool _obscurePassword = true;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocListener<SigUpBloc, SigUpState>(
            listener: (context, state) {
              if (state is SignUpLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );
              } else if (state is SignUpSuccess) {
                Navigator.pop(context); // pop loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign Up Successful!')),
                );
                Navigator.pop(context); // pop to login
              } else if (state is SignUpFailure) {
                Navigator.pop(context); // pop loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(height: 20),
                // --- Logo ---
                 Center(
                  child: Text(
                    Constants.appName,
                    style: FTextStyle.heading(context).copyWith(color: AppColors.primary),
                  ),
                ),
                 SizedBox(height: 40),
  
                // --- Header ---
                 Text(
                  Constants.createAccount,
                  style: FTextStyle.heading(context).copyWith(fontSize: 32),
                ),
                 SizedBox(height: 8),
                 Text(
                  Constants.signUpSubtitle,
                  style: FTextStyle.body(context).copyWith(color: AppColors.grey),
                ),
                 SizedBox(height: 32),
  
                // --- Form Fields ---
                _buildFieldLabel(Constants.fullName),
                _buildTextField(
                  hint: Constants.fullNameHint,
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) return 'Enter a valid name (letters only)';
                    return null;
                  },
                ),
  
                 SizedBox(height: 20),
                _buildFieldLabel(Constants.emailAddress),
                _buildTextField(
                  hint: Constants.emailHint,
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
                    return null;
                  },
                ),
  
                 SizedBox(height: 20),
                _buildFieldLabel(Constants.mobileNumber),
                _buildTextField(
                  hint: Constants.mobileHint,
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter phone number';
                    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) return 'Enter a valid phone number';
                    return null;
                  },
                ),
  
                 SizedBox(height: 20),
                _buildFieldLabel(Constants.password),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter password';
                    if (value.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: Constants.passwordCreateHint,
                    hintStyle:  FTextStyle.hint(context),
                    filled: true,
                    fillColor:  AppColors.background,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                 Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(Constants.passwordRule, style: FTextStyle.small(context).copyWith(color: AppColors.grey)),
                ),
  
                 SizedBox(height: 24),
  
                // --- Terms and Conditions ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) => setState(() => _isAgreed = value!),
                      ),
                    ),
                     SizedBox(width: 12),
                     Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: Constants.agreeTo,
                          style: FTextStyle.body(context).copyWith(color: AppColors.darkGrey),
                          children: [
                            TextSpan(text: Constants.termsOfService, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            TextSpan(text: Constants.and),
                            TextSpan(text: Constants.privacyPolicy, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            TextSpan(text: Constants.regardingData),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
  
                 SizedBox(height: 32),
  
                // --- Sign Up Button ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isAgreed ? () {
                      if (_formKey.currentState!.validate()) {
                        context.read<SigUpBloc>().add(
                          SignUpSubmitted(
                            email: _emailController.text,
                            password: _passwordController.text,
                            name: _nameController.text,
                            phone: _phoneController.text,
                          ),
                        );
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  AppColors.primary,
                      disabledBackgroundColor:  AppColors.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child:  Text(Constants.signUp, style: FTextStyle.button(context).copyWith(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
  
                 SizedBox(height: 24),
                 Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: FTextStyle.body(context).copyWith(color: AppColors.grey))),
                    Expanded(child: Divider()),
                  ],
                ),
                 SizedBox(height: 32),
  
                // --- Footer ---
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(Constants.alreadyHaveAccount, style: FTextStyle.body(context)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child:  Text(Constants.logIn, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                 SizedBox(height: 20),
              ],
            ),
          ),
         ),
        ),
       ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 8.0),
      child: Text(label, style:  FTextStyle.title(context).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, required String? Function(String?)? validator, required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:  FTextStyle.hint(context),
        filled: true,
        fillColor:  AppColors.background,
        suffixIcon: Icon(icon, color: AppColors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}