import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expita_o/outgraph_page.dart';
import 'transaction.dart';
import 'add_transaction_page.dart';
import 'graph_page.dart';
import 'package:expita_o/ai_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Transaction> transactionBox;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<Transaction>('transactions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EXPITO 💰 ',
          style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 197, 166, 11)),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 53, 69, 82),
      ),
      body: Container(
        width: double.infinity,
        color: const Color.fromARGB(255, 11, 14, 31),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 22, 41, 95),
                ),
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'INCOME : ₹${calculateIncome()}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 77, 255, 142)),
                    ),
                    Text('SPEND : ₹${calculateOutcome()}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 227, 17, 24))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: transactionBox.listenable(),
                builder: (context, Box<Transaction> box, _) {
                  if (box.values.isEmpty) {
                    return const Center(
                      child: Text(
                        'No transactions yet.',
                        style: TextStyle(color: Colors.tealAccent),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      Transaction transaction = box.getAt(index)!;
                      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                          .format(transaction.date);
                      Color textColor;
                      if (transaction.isIncome) {
                        textColor = const Color.fromARGB(255, 2, 242, 118);
                      } else {
                        textColor = const Color.fromARGB(255, 255, 3, 3);
                      }
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 26, 57, 112),
                        ),
                        margin: const EdgeInsets.only(
                            bottom: 5, left: 10, right: 10),
                        child: ListTile(
                          iconColor: const Color.fromARGB(255, 232, 148, 148),
                          textColor: Colors.white,
                          title: Text("₹${transaction.amount.toString()}",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          subtitle: Text(
                            transaction.description,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 15,
                                fontWeight: FontWeight.w300),
                          ),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                Text(formattedDate,
                                    style: const TextStyle(
                                      color: Colors.lightGreenAccent,
                                    )),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteTransaction(index);
                                  },
                                ),
                              ],
                            ),
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
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          left: 30,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 16, 9, 61),
        ),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTransactionPage(
                          onTransactionAdded: _refreshHomePage)),
                );
                if (result == true) {
                  _refreshHomePage();
                }
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 20),
            FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: Colors.redAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GraphPage()),
                );
              },
              child: const Icon(Icons.bar_chart),
            ),
            const SizedBox(width: 20),
            FloatingActionButton(
              backgroundColor: Colors.green,
              heroTag: "btn3",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InGraphPage()),
                );
              },
              child: const Icon(Icons.bar_chart),
            ),
            const SizedBox(width: 20),
            FloatingActionButton(
              heroTag: "btn4",
              // backgroundColor: Colors.redAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AiPage()),
                );
              },
              child: const Icon(Icons.chat),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshHomePage() {
    setState(() {});
  }

  double calculateIncome() {
    double income = 0;
    for (var transaction in transactionBox.values) {
      if (transaction.isIncome) {
        income += transaction.amount;
      }
    }
    return income;
  }

  double calculateOutcome() {
    double outcome = 0;
    for (var transaction in transactionBox.values) {
      if (!transaction.isIncome) {
        outcome += transaction.amount;
      }
    }
    return outcome;
  }

  void _deleteTransaction(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content:
              const Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                transactionBox.deleteAt(index);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}
