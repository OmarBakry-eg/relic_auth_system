
import 'dart:convert';
import 'package:relic/relic.dart';

extension RequestExtension on Request{
  Future<Map<String, dynamic>> get bodyAsJson async {
    final body = await this.readAsString();
    return jsonDecode(body) as Map<String, dynamic>;
  }
}