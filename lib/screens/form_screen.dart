import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/form_provider.dart';

class FormScreen extends StatefulWidget {
  final Map<String, dynamic> jsonData;

  const FormScreen({Key? key, required this.jsonData}) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final Map<dynamic, dynamic> userInputs = {};
  bool isEditable = true;

  @override
  void initState() {
    super.initState();

    // Pre-fill userInputs with saved answers if available
    final savedAnswers = widget.jsonData['data']['getUserForm']['answers'] ?? {};
    userInputs.addAll(savedAnswers);

    // Determine if fields should be editable
    isEditable = savedAnswers.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.jsonData['data']['getUserForm'];
    final questions = form['questions'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(form['name'] ?? 'Unnamed Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: questions.map<Widget>((question) {
            return _buildQuestionWidget(question);
          }).toList(),
        ),
      ),
      floatingActionButton: isEditable
          ? FloatingActionButton(
        onPressed: () {
          // Save the updated form structure
          final updatedJson = widget.jsonData;
          updatedJson['data']['getUserForm']['questions'] = questions;

          Provider.of<FormProvider>(context, listen: false).saveData(updatedJson);
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      )
          : null,
    );
  }

  Widget _buildQuestionWidget(Map question) {
    final isFieldEditable = isEditable && question['userResponse'] == null;

    switch (question['questionType']) {
      case 'TEXTFORMFIELD':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            initialValue: question['userResponse'] ?? '',
            maxLines: question['maxLines'] ?? 1,
            enabled: isFieldEditable,
            decoration: InputDecoration(
              hintText: question['hintText'] ?? 'Enter text',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              question['userResponse'] = value; // Save user response
            },
          ),
        );

      case 'RADIO':
        final options = question['options'] ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question['question'] ?? 'Unnamed Question',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...options.map<Widget>((option) {
                return IgnorePointer(
                  ignoring: isFieldEditable,
                  child: RadioListTile(
                    title: Text(option['option'] ?? 'Unnamed Option'),
                    value: option['option'],
                    groupValue: question['userResponse'],
                    toggleable: !isFieldEditable,
                    onChanged: (value) {

                      if(!isFieldEditable){
                        return;
                      }

                      setState(() {
                        question['userResponse'] = value; // Save user response
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );

      case 'MOBILENUMBER':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            initialValue: question['userResponse'] ?? '',
            keyboardType: TextInputType.phone,
            maxLines: 1,
            enabled: isFieldEditable,
            decoration: InputDecoration(
              hintText: question['hintText'] ?? 'Enter mobile number',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              question['userResponse'] = value; // Save user response
            },
          ),
        );

      case 'ELEVATEDBUTTON':
        String buttonText = question['answerType'] == 'FETCHLOCATION'
            ? (isFieldEditable
            ? 'Fetch Location'
            : (question['userResponse'] ?? 'Location not fetched'))
            : (isFieldEditable
            ? 'Take Selfie'
            : (question['userResponse'] ?? 'Selfie not taken'));
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            onPressed: isFieldEditable
                ? () {
              if (question['answerType'] == 'FETCHLOCATION') {
                fetchLocation(question['id'].toString(), question);
              } else if (question['answerType'] == 'FETCHCAMERA') {
                captureSelfie(question['id'].toString(), question);
              }
            }
                : null,
            child: Text(buttonText),
          ),
        );

      case 'FORM':
        final nestedForm = question['options']?.first ?? {};
        final nestedQuestions = nestedForm['questions'] ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question['question'] ?? nestedForm['name'] ?? 'Nested Form',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
             Wrap(
               runAlignment: WrapAlignment.start,
               crossAxisAlignment: WrapCrossAlignment.start,
               alignment: WrapAlignment.start,
               children: [
                 ...nestedQuestions.map<Widget>((nestedQuestion) {
                   return _buildQuestionWidget(nestedQuestion);
                 }).toList()
               ],
             ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  void fetchLocation(String questionId, Map question) {
    setState(() {
      final location = 'Lat: 37.7749, Lon: -122.4194'; // Example location
      userInputs[questionId] = location;
      question['userResponse'] = location; // Save user response
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location fetched successfully!')),
    );
  }

  void captureSelfie(String questionId, Map question) async {
    setState(() {
      final selfiePath = 'selfie_image_url'; // Replace with actual file path or URL
      userInputs[questionId] = selfiePath;
      question['userResponse'] = selfiePath; // Save user response
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selfie captured successfully!')),
    );
  }
}