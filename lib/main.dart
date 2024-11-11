import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:loading_indicator/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (e) {
    print('Error loading .env file: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();
  ResponseState responseState = ResponseState.initial;
  String apiKey = dotenv.env['API_KEY'] ?? '';

  String? apiResponse = '';
  String? apiRequest = '';

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  Future<String?> getAPIResponse(String request) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final response = await model.generateContent([Content.text(request)]);
    return response.text;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('G E M I N I  T E S T'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                onTapOutside: (e) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  hintText: 'Enter question',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  suffixIcon: IconButton(
                      onPressed: () async {
                        setState(() {
                          responseState = ResponseState.loading;
                        });
                        apiResponse = await getAPIResponse(textController.text);
                        setState(() {
                          responseState = ResponseState.loading;
                          apiRequest = textController.text;
                          responseState = ResponseState.success;
                          textController.clear();
                        });
                      },
                      icon: const Icon(Icons.send)),
                  fillColor: Colors.white10,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 1,
                        color: Colors.white24,
                      ),
                      borderRadius: BorderRadius.circular(20)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: Colors.white30,
                      ),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              responseState == ResponseState.initial
                  ? const SizedBox()
                  : responseState == ResponseState.loading
                      ? const SizedBox()
                      : responseState == ResponseState.success
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              width: size.width * 0.8,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  apiRequest!,
                                  softWrap: true,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                          : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              responseState == ResponseState.initial
                  ? const SizedBox()
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: responseState == ResponseState.loading
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      right: size.width * 0.6),
                                  child: const SizedBox(
                                    height: 10,
                                    child: LoadingIndicator(
                                      indicatorType: Indicator.ballPulse,
                                      colors: [Colors.white],
                                    ),
                                  ),
                                )
                              : responseState == ResponseState.success
                                  ? Text(
                                      apiResponse!,
                                      softWrap: true,
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  : null),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ResponseState { initial, loading, success }
