import 'package:flutter/material.dart';

class FeedbackContainer extends StatelessWidget {
  const FeedbackContainer({Key? key, required String errorMessage})
      : _errorMessage = errorMessage,
        super(key: key);

  final String _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.withOpacity(0.1),
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red[300], fontSize: 16),
      ),
    );
  }
}
