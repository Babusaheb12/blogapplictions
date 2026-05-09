import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
   ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:  Icon(Icons.menu, color: Color(0xFF003399)),
        title:  Text(
          'InsightBlog',
          style: TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions:  [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none_outlined, color: Color(0xFF003399)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
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
                    'Julian Alexander',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                   SizedBox(height: 4),
                   Text(
                    'julian.a@insightblog.com',
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
                              // TODO: Add logout logic here
                              Navigator.pop(context);
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
        ),
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