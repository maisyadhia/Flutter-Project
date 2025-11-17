import 'User.dart'; // Sesuaikan path jika perlu

void main() {
  print('=== DEBUG: Check JSON Structure ===');
  
  // 1. Object Dart ke JSON
  User user = User(
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    createdAt: DateTime.now(),
  );
  
  Map<String, dynamic> userJson = user.toJson();
  print('User.toJson() result: $userJson');
  print('Field names: ${userJson.keys.toList()}');

  print('\n=== TEST: JSON to Object === ');
  
  // 2. JSON ke Object Dart
  Map<String, dynamic> jsonData = {
    'id': 2,
    'name': 'Jane Doe',
    'email': 'jane@example.com',
    'created_at': '2024-01-01T10:00:00.000Z',
  };

  print('JSON data to parse: $jsonData');

  try {
    User userFromJson = User.fromJson(jsonData);
    print('SUCCESS: User from JSON: $userFromJson');
  } catch (e, stack) {
    print('X ERROR: $e');
    print('Stack trace: $stack');
  }

  print('\n=== TEST: Handle Missing Fields ===');
  
  // 3. Tes dengan data JSON yang tidak lengkap
  Map<String, dynamic> incompleteJson = {
    'id': 3,
    // 'name': missing
    'email': 'test@example.com',
    // 'createdAt': missing
  };

  try {
    User userFromIncomplete = User.fromJson(incompleteJson);
    // Ini tidak akan error, field 'name' akan menjadi null
    print('User from incomplete JSON: $userFromIncomplete');
  } catch (e) {
    print('Error with incomplete JSON: $e');
  }
}