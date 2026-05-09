import 'package:flutter/material.dart';
import 'package:blogapplictions/utils/flutter_color_themes.dart';
import 'package:blogapplictions/utils/flutter_font_style.dart';
import 'package:blogapplictions/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapplictions/screen/auth/LoginScreen/bloc/sigUpBloc/sig_up_bloc.dart';

import '../../../utils/ImageAssets.dart';
import '../../homepage/homepages.dart';
import '../../widgets/bottomNavBar.dart';
import 'SignUpScreen.dart';

class MyLoginScreen extends StatefulWidget {
  MyLoginScreen({super.key});

  @override
  State<MyLoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  bool _obscurePassword = true;
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<SigUpBloc, SigUpState>(
          listener: (context, state) {
            if (state is LoginLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );
            } else if (state is LoginSuccess) {
              Navigator.pop(context); // pop loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login Successful!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomeScreens()),
              );
            } else if (state is LoginFailure) {
              Navigator.pop(context); // pop loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE4E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    // --- Logo and Brand ---
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(Icons.menu_book_rounded, size: 40, color: AppColors.primary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      Constants.appName,
                      style: FTextStyle.heading(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    SizedBox(height: 32),

                    // --- Login Card ---
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Constants.welcomeBack,
                            style: FTextStyle.heading(context).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            Constants.loginSubtitle,
                            style: FTextStyle.body(context).copyWith(color: AppColors.grey),
                          ),
                          SizedBox(height: 24),

                          // --- Email Field ---
                          Text(Constants.emailAddress, style: FTextStyle.title(context).copyWith(fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: Constants.emailHint,
                              hintStyle: FTextStyle.hint(context),
                              filled: true,
                              fillColor: AppColors.inputFill,
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.error),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.error, width: 2),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // --- Password Field ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Constants.password, style: FTextStyle.title(context).copyWith(fontWeight: FontWeight.w600)),
                              GestureDetector(
                                onTap: () {},
                                child: Text(Constants.forgotPassword, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter password';
                              if (value.length < 8) return 'Password must be at least 8 characters';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: Constants.passwordHint,
                              hintStyle: FTextStyle.hint(context),
                              filled: true,
                              fillColor: AppColors.inputFill,
                              prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.error),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.error, width: 2),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // --- Login Button ---
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<SigUpBloc>().add(
                                    LoginSubmitted(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                              ),
                              child: Text(Constants.login, style: FTextStyle.button(context).copyWith(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 20),

                          // --- Divider ---
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.border)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(Constants.or, style: FTextStyle.body(context).copyWith(color: AppColors.grey, fontSize: 13)),
                              ),
                              Expanded(child: Divider(color: AppColors.border)),
                            ],
                          ),
                          SizedBox(height: 20),

                          // --- Google Sign In ---
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<SigUpBloc>().add(GoogleSignInSubmitted());
                            },
                            icon: Image.asset(ImageAssets.googleIcon, height: 20, width: 20),
                            label: Text(Constants.signInWithGoogle, style: FTextStyle.button(context).copyWith(color: AppColors.black, fontSize: 15)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 54),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // --- Footer ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Constants.dontHaveAccount, style: FTextStyle.body(context).copyWith(color: AppColors.grey)),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                          child: Text(
                            Constants.signUp,
                            style: FTextStyle.body(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
         ),
        ),
       ),
    );
  }
}