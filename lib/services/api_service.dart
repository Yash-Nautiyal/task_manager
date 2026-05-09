import 'package:flutter/material.dart';
import 'package:task_app/core/error/failures.dart';

import '../core/utils/result.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService();

  Future<Result<String>> fetchRandomQuote() async {
    debugPrint('Fetching quote from API...');
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random'),
      );
      if (response.statusCode == 200) {
        debugPrint('Quote fetched successfully: ${response.body}');
        return Result.success(response.body);
      } else {
        return const Result.failure(
          AppFailure(" Failed to fetch quote. Please try again later."),
        );
      }
    } catch (e) {
      debugPrint('Error fetching quote: $e');
      return const Result.failure(
        AppFailure(" An unexpected error occurred. Please try again later."),
      );
    }
  }
}
