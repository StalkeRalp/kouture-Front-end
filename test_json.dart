import 'dart:convert';
import 'dart:io';

void main() {
  try {
    final str = File('lib/backend/products.json').readAsStringSync();
    final data = jsonDecode(str);
    print("SUCCESS");
    print("Keys: ${data.keys.toList()}");
    print("Products: ${data['products'].length}");
  } catch (e) {
    print("ERROR parsing JSON: $e");
  }
}
