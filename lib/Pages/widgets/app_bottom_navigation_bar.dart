import 'package:flutter/material.dart';


class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
            icon: Center(child: Icon(Icons.home)), label: ''),
        const BottomNavigationBarItem(
            icon: Center(child: Icon(Icons.mail_outline)), label: ''),
        const BottomNavigationBarItem(
            icon: Center(child: Icon(Icons.calendar_today)), label: ''),
        BottomNavigationBarItem(
            icon: Center(
              child: Icon(
                Icons.person,
                color: currentIndex == 3 ? Colors.teal : Colors.grey,
              ),
            ),
            label: ''),
      ],
    );
  }
}
