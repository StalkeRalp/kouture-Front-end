import 'dart:convert';
import 'dart:io';

void main() {
  final str = File('lib/backend/products.json').readAsStringSync();
  final dbData = jsonDecode(str);
  print('dbData is Map<String, dynamic>: ${dbData is Map<String, dynamic>}');
}
