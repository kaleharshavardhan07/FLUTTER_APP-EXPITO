import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hive/hive.dart';

import 'transaction.dart';

class GraphPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spending Graph'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: Hive.openBox<Transaction>('transactions'),
          builder: (context, AsyncSnapshot<Box<Transaction>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return _buildGraph(snapshot.data!);
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGraph(Box<Transaction> box) {
    var data = _prepareChartData(box);
    var series = [
      charts.Series<MapEntry<int, double>, String>(
        id: 'Spending',
        domainFn: (MapEntry<int, double> entry, _) => _monthName(entry.key),
        measureFn: (MapEntry<int, double> entry, _) => entry.value,
        data: data.entries.toList(),
      )
    ];
    return charts.BarChart(
      series,
      animate: true,
    );
  }

  Map<int, double> _prepareChartData(Box<Transaction> box) {
    var data = <int, double>{};
    for (var transaction in box.values) {
      var month = transaction.date.month;
      if (transaction.isIncome) continue;
      if (data.containsKey(month)) {
        data[month] = data[month]! + transaction.amount;
      } else {
        data[month] = transaction.amount;
      }
    }
    return data;
  }

  String _monthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
