import 'package:flutter/material.dart';


class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: const Center(
        child: Text(
          "Track your pet expenses here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}