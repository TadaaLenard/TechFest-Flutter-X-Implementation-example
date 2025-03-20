import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  State<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  // Define variable to store the Gemini API key and Gemini model
  String? GeminiAPI;
  GenerativeModel? model;

  TextEditingController _promptController = TextEditingController();
  String responseText = "";
  bool isLoading = false;

  // Override initialisation of the widget to load the Gemini API key and model
  @override
  void initState() {
    super.initState();
    initGeminiAPI();
  }

  Future<void> initGeminiAPI() async {
    await dotenv.load(fileName: ".env"); // Load .env file
    setState(() {
      GeminiAPI = dotenv.env['GeminiAPI']; // Load Gemini API key

      // If API key is loaded successfully, create a generative model
      if (GeminiAPI != null) {
        model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: GeminiAPI!,
        );
      }

      print("Loaded API Key: $GeminiAPI");
    });
  }

  Future<void> generateResponse() async {
    // If the Gemini Model is not created or the user does not enter any prompt,
    // The function ends and will not ask response from the Gemini
    if (model == null || _promptController.text.isEmpty) {
      return;
    }

    // Set the isLoading flag to true,
    // disable the button so the user cannot send prompt again
    // during the generation of response
    setState(() {
      isLoading = true;
    });

    // The code takes the user input as prompt and request a response from Gemini
    final prompt = [Content.text(_promptController.text)];
    final response = await model?.generateContent(prompt);

    // Set the isLoading flag to false,
    // enable the button so the user can send prompt again
    setState(() {
      responseText = response?.text ?? "No response from API.";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Back"),
            ),

            // Textfield to receive user input as the prompt
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: "Enter your prompt",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Button to send the prompt and request response from Gemini
            ElevatedButton(
              onPressed: isLoading ? null : generateResponse,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Generate Response"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Response:",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 5),

            // Display response text
            Expanded(
              child: SingleChildScrollView(
                child: Text(responseText, style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
