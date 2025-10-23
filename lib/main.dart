import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(SparkApp());

class SparkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SPARK',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController topicController = TextEditingController();
  String resultsText = "النتائج ستظهر هنا.";
  bool isLoading = false;

  Future<void> fetchResults(String topic) async {
    if (topic.trim().isEmpty) {
      setState(() {
        resultsText = "انسيت تدخل الموضوع!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      resultsText = "";
    });

    final url = Uri.parse('http://192.168.100.218:5000/search?topic=$topic');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];
        if (results.isEmpty) {
          resultsText = "ما في نتائج عن \"$topic\".";
        } else {
          resultsText = results
              .map((e) => "${e['title']}\n${e['abstract']}\n${e['link']}")
              .join("\n\n");
        }
      } else {
        resultsText = "خطأ في السيرفر: ${response.statusCode}";
      }
    } catch (e) {
      resultsText = "تعذر الاتصال بالسيرفر. تأكد أنه شغال.";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void copyResults() {
    if (resultsText.trim().isNotEmpty) {
      Clipboard.setData(ClipboardData(text: resultsText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم نسخ النتائج بنجاح!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 360,
            height: 800,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFF5F6FA)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SPARK',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF027317),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'أسامة — رفيقك البيئي الذكي في البحث.\nمشروع مقدم بفخر إلى موهبة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 300,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: topicController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "اكتب موضوعك هنا...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => fetchResults(topicController.text),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(300, 45),
                    backgroundColor: const Color(0xFF63BF5B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'ابحث الآن',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator(color: Color(0xFF027317)),
                const SizedBox(height: 20),
                Container(
                  width: 340,
                  height: 300,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF635555),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            resultsText,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: copyResults,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('نسخ النتائج'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF027317),
                          minimumSize: const Size(double.infinity, 35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
