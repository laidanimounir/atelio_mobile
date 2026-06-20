import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/utils/formatters.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Detail')),
      body: const Center(child: Text('Select a client from the list')),
    );
  }
}
