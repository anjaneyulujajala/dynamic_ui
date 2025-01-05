import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormProvider with ChangeNotifier {
  Map<String, dynamic>? formData;
  List<Map<String, dynamic>> savedData = [];

  void loadForm(Map<String, dynamic> data) {
    formData = data;
    notifyListeners();
  }

  Future<void> saveData(Map<String, dynamic> inputData) async {
    savedData.add(inputData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedData', jsonEncode(savedData));
    notifyListeners();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('savedData');
    if (data != null) {
      savedData = List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    notifyListeners();
  }
}