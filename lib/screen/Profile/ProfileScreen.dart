import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapplictions/screen/Profile/bloc/logout/logout_bloc.dart';
import 'package:blogapplictions/screen/auth/LoginScreen/LoginScreen.dart';
import 'package:blogapplictions/screen/Profile/bloc/profileBloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
   const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(FetchUserProfile()),
      child: Builder(
        builder: (context) {
          return BlocListener<LogoutBloc, LogoutState>(
            listener: (context, state) {
              if (state is LogoutLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
              } else if (state is LogoutSuccess) {
                Navigator.pop(context); // pop loading
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyLoginScreen()),
                  (route) => false,
                );
              } else if (state is LogoutFailure) {
                Navigator.pop(context); // pop loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            child: Scaffold(
              backgroundColor:  Color(0xFFF8F9FE),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                title:  Text(
                  'InsightBlog',
                  style: TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    return Column(
                  children: [
                    // --- Profile Header Card ---
                    Container(
                      width: double.infinity,
                      padding:  EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color:  Color(0xFFF1F4F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color:  Color(0xFFDDE3F0)),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    'https://i.pravatar.cc/300?u=julian',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding:  EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:  Color(0xFF2D62ED),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child:  Icon(Icons.edit, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            state is ProfileLoaded ? state.name : (state is ProfileLoading ? 'Loading...' : 'No Name'),
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            state is ProfileLoaded ? state.email : (state is ProfileLoading ? 'Loading...' : 'No Email'),
                            style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // --- Menu Items ---
                    _buildMenuItem(Icons.person_outline, 'Edit Profile'),
                    _buildMenuItem(Icons.settings_outlined, 'App Settings'),
                    _buildMenuItem(Icons.notifications_none_outlined, 'Notifications'),
                    _buildMenuItem(Icons.help_outline_rounded, 'Help & Support'),

                    SizedBox(height: 12),

                    // --- Logout Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Are you sure?'),
                                content: const Text('Do you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      context.read<LogoutBloc>().add(PerformLogout());
                                    },
                                    child: const Text('Logout', style: TextStyle(color: Color(0xFFC62828))),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon:  Icon(Icons.logout, color: Colors.white),
                        label:  Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin:  EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color:  Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: Container(
          padding:  EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:  Color(0xFFE8EFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color:  Color(0xFF2D62ED)),
        ),
        title: Text(
          title,
          style:  TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing:  Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}