import 'package:flutter/material.dart';

class FeedbackContainer extends StatelessWidget {
  const FeedbackContainer({Key? key, required String errorMessage})
      : _errorMessage = errorMessage,
        super(key: key);

  final String _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Colors.red.withOpacity(0.1),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red[300]),
        ),
      ),
    );
  }
}
