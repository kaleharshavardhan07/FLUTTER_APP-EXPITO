import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'transaction.dart'; 
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiPage extends StatefulWidget {
  @override
  _AiPageState createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final List<String> _questions = [
    "What is the total income recorded for this month?",
    "Can you provide a detailed breakdown of my income sources?",
    "How can I optimize my budget to reduce unnecessary expenses?",
    "Can you provide a detailed breakdown of my spend?",
    "Which categories are consuming the most of my spend?",
    "Do you have any suggestions for improving my financial management?",
    "Where can I reduce expenditures to enhance my savings?",
    "What are my top spending categories for this year?",
  "How does my spending this month compare to last month?",
  "What are my major income sources and how do they compare in terms of amount?",
  // "What is my current savings rate and how can I improve it?",
  // "How much money do I have left in each budget category?",
  "Can you help me identify any patterns in my spending habits?",
  "What are my largest expense items this month?",
  "How much have I spent on entertainment this year compared to my budget?",
  // "What percentage of my income is going towards debt repayment?",
  "Can you recommend ways to adjust my budget to save for a vacation?",
  "How does my spending on groceries this month compare to previous months?",
  // "What are the upcoming financial commitments I should be aware of?",
  "Can you provide a forecast of my monthly expenses based on current spending trends?",
  // "How can I better allocate my budget to meet my long-term financial goals?",
  // "What are my fixed vs. variable expenses and how can I manage them more effectively?"
  ];

  final List<String> _messages = [];
  String _selectedQuestion = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<String> _fetchTransactions() async {
    try {
      var transactionBox = Hive.box<Transaction>('transactions');
      List<Transaction> transactions = transactionBox.values.toList();

      List<Map<String, dynamic>> transactionsJson = transactions.map((transaction) {
        return {
          'category': transaction.isIncome ? 'income' : 'spend',
          'amount': transaction.amount,
          'date': transaction.date.toIso8601String(),
          'description': transaction.description,
        };
      }).toList();

      return jsonEncode(transactionsJson);
    } catch (e) {
      print('Error fetching transactions: $e');
      return '[]';
    }
  }

  Future<void> _sendQuestionAndData(String question, String transactionsJsonString) async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = 'AIzaSyAJOUkbXwevtJZ1BhVa1jkCFcqIWsvz9Ok'; 
    if (apiKey.isEmpty) {
      print('API Key is empty');
      setState(() {
        _isLoading = false;
        _messages.add('Error: API Key is empty.');
      });
      return;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      var content = Content.text('$question\nTransactions: $transactionsJsonString');
      final response = await model.generateContent([content]);

      setState(() {
        _isLoading = false;
      });
      _messages.add('Expenso-AI: ${response.text}');
    } catch (e) {
      print('Error sending question or receiving response: $e');
      setState(() {
        _isLoading = false;
        _messages.add('Error: Failed to get response from AI.');
      });
    }
  }

  void _handleQuestionSelection(String question) async {
    setState(() {
      _selectedQuestion = question;
      _messages.add('You: $question');
    });

    String transactionsJsonString = await _fetchTransactions();
    await _sendQuestionAndData(question, transactionsJsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with Expenso-AI',
          style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w700,
              fontSize: 25),
        ),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Container(
        color: Color.fromARGB(255, 4, 31, 72),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Container(
                     margin: new EdgeInsets.all(16),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 204, 205, 206),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0, 
                      ),
                      borderRadius: BorderRadius.circular(12.0), // Border radius
                    ),
                    child: MarkdownBody(
                      data: _messages[index],
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: Color.fromARGB(255, 15, 8, 8)),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Select a question'),
                  value: _selectedQuestion.isNotEmpty ? _selectedQuestion : null,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _handleQuestionSelection(newValue);
                    }
                  },
                  items: _questions.map<DropdownMenuItem<String>>((String question) {
                    return DropdownMenuItem<String>(
                      value: question,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(question),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
