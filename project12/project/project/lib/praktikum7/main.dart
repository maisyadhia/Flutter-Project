import 'package:encrypt/encrypt.dart';
import 'dart:convert';

void main() {
  // 1. Tentukan Key dan IV (Initialization Vector)
  // PENTING: Key dan IV ini HANYA CONTOH. Jangan gunakan di produksi.
  // Key harus 32 karakter untuk AES-256
  final key = Key.fromUtf8('0123456789ABCDEF0123456789ABCDEF');
  // IV harus 16 karakter untuk AES CBC
  final iv = IV.fromUtf8('0123456789ABCDEF');

  // 2. Buat instance Encrypter
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  // 3. Data rahasia (Plain Text)
  final plainText = 'Ini rahasia besar saya';
  print('Original text: $plainText');

  // 4. Enkripsi
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  print('Encrypted (base64): ${encrypted.base64}');

  // 5. Dekripsi
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  print('Decrypted text: $decrypted');

  print('\n--- Contoh Enkripsi JSON ---');

  // 6. Enkripsi data JSON
  final data = {'user': 'luqman', 'token': 'abc123xyz'};
  final jsonString = jsonEncode(data); // Ubah Map ke String
  print('Original JSON: $jsonString');

  // Enkripsi String JSON
  final encryptedJson = encrypter.encrypt(jsonString, iv: iv);
  print('Encrypted JSON: ${encryptedJson.base64}');

  // Dekripsi String JSON
  final decryptedJson = encrypter.decrypt(encryptedJson, iv: iv);
  print('Decrypted JSON: $decryptedJson');

  // Ubah kembali ke Map
  final decryptedMap = jsonDecode(decryptedJson);
  print('Decrypted Map (user): ${decryptedMap['user']}');
}