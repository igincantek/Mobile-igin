import 'dart:convert';
import 'package:flutter/services.dart';

class JsonDataService {
  // Fungsi untuk memuat file JSON dari assets/data/
  static Future<List<dynamic>> loadList(String fileName) async {
    try {
      final String response = await rootBundle.loadString('assets/data/$fileName');
      return json.decode(response) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  static Future<dynamic> loadSingle(String fileName) async {
    try {
      final String response = await rootBundle.loadString('assets/data/$fileName');
      return json.decode(response);
    } catch (e) {
      return null;
    }
  }
}