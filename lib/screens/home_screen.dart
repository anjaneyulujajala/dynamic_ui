import 'dart:convert';
import 'dart:io';
import 'package:dynamic_ui/screens/saved_data_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'form_screen.dart';
import '../models/form_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<FormProvider>(context, listen: false).loadSavedData();
  }

  Future<void> loadFromUrl() async {
    try {
      final response = await http.get(Uri.parse(urlController.text));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FormScreen(jsonData: data)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load JSON from URL')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL or error loading data')));
    }
  }

  Future<void> loadFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        String jsonString = "";

        if (kIsWeb) {
          // For Web: Use bytes directly
          jsonString = utf8.decode(result.files.single.bytes!);
        } else {
          // For Mobile/Desktop: Read file from path
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        }
        Map<String, dynamic> jsonData = jsonDecode(jsonString);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FormScreen(jsonData: jsonData)),
        );
      }catch(e, stack){
        debugPrint(e.toString());
        debugPrintStack(stackTrace: stack);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Form Builder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Enter JSON URL',
              ),
            ),
            ElevatedButton(
              onPressed: loadFromUrl,
              child: const Text('Load from URL'),
            ),
            ElevatedButton(
              onPressed: loadFromFile,
              child: const Text('Load from File'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: provider.savedData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Saved Form ${index + 1}'),
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormScreen(
                            jsonData: provider.savedData[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}