import 'package:flutter/material.dart';

class HomePageController extends ChangeNotifier {
  // Example: You can add state variables and methods here
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Add more logic as needed for HomePage
}
