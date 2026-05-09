import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Profile/ProfileScreen.dart';
import '../SavedArticles/SavedArticlesScreen.dart';
import '../Search/SearchScreen.dart';
import '../homepage/homepages.dart';


class MyHomeScreens extends StatefulWidget {
   MyHomeScreens({super.key});

  @override
  State<MyHomeScreens> createState() => _MyHomeScreensState();
}

class _MyHomeScreensState extends State<MyHomeScreens> {
  int currentIndex = 0;

  final List<Widget> pages = [
     MyHomePage(),

    SearchScreen(),

    SavedArticlesScreen(),

    ProfileScreen(),

  ];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex != 0) {
          onItemTapped(0);
          return false;
        }

        SystemNavigator.pop();

        return false;
      },

      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),

        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: currentIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String title;
  final IconData icon;

   DummyPage({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 90,
              color:  Color(0xff4A90E2),
            ),

             SizedBox(height: 20),

            Text(
              title,
              style:  TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

   CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.all(16),

      padding:  EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset:  Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _buildItem(
            index: 0,
            icon: Icons.home_filled,
            label: "Home",
          ),

          _buildItem(
            index: 1,
            icon: Icons.search,
            label: "Search",
          ),

          _buildItem(
            index: 2,
            icon: Icons.bookmark_border,
            label: "saved",
          ),

          _buildItem(
            index: 3,
            icon: Icons.person_outline,
            label: "profile",
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected
                ?  Color(0xff4A90E2)
                : Colors.grey,
          ),

           SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 13,

              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w500,

              color: isSelected
                  ?  Color(0xff4A90E2)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}