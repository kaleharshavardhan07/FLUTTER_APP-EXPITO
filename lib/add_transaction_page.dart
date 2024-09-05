import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'transaction.dart';

class AddTransactionPage extends StatefulWidget {
  final VoidCallback onTransactionAdded;

  AddTransactionPage({required this.onTransactionAdded});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  String description = '';
  double amount = 0;
  bool isIncome = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 2, 45, 67),
        titleTextStyle: TextStyle(fontSize: 30,fontWeight: FontWeight.w700, color: Color.fromARGB(255, 179, 214, 253)),
      ),
      
      backgroundColor: Color.fromARGB(255, 16, 3, 67),
      body: SizedBox(
        child: Center(
          child: Container(
            width: 400,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(208, 21, 0, 58),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.blue),
                        ),
                        style: TextStyle(color: Colors.blue),
                        onSaved: (value) {
                          description = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          labelStyle: TextStyle(color: Colors.blue),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.blue),
                        onSaved: (value) {
                          amount = double.parse(value!);
                        },
                      ),
                      SwitchListTile(
                        title: Text(
                          'Is Income?',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: isIncome,
                        onChanged: (value) {
                          setState(() {
                            isIncome = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: _addTransaction,
                          child: Text('Add Transaction'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, 
                            elevation: 5, 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), 
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newTransaction = Transaction(
        description: description,
        amount: amount,
        date: DateTime.now(),
        isIncome: isIncome,
      );
      final box = Hive.box<Transaction>('transactions');
      box.add(newTransaction);
      widget.onTransactionAdded();
      Navigator.pop(context, true);
    }
  }
}
