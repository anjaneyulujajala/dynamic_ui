import 'dart:developer';

import 'package:flutter/material.dart';

class SavedDataScreen extends StatefulWidget {
  final Map<String, dynamic> jsonData;
  const SavedDataScreen({super.key, required this.jsonData});

  @override
  State<SavedDataScreen> createState() => _SavedDataScreenState();
}

class _SavedDataScreenState extends State<SavedDataScreen> {

  @override
  Widget build(BuildContext context) {
    log(widget.jsonData.toString());
    return Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }
}