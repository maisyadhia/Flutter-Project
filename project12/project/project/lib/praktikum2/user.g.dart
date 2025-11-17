// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  // Ensure required keys are present and not null
  if (!json.keys.toSet().containsAll(['id', 'name', 'email', 'created_at']) ||
      ['id', 'name', 'email'].any((key) => json[key] == null)) {
    throw ArgumentError('Missing or null required keys in JSON: id, name, email, created_at');
  }
  // $checkKeys(
  //   json,
  //   requiredKeys: const ['id', 'name', 'email', 'created_at'],
  //   disallowNullValues: const ['id', 'name', 'email'],
  // );
  return User(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    email: json['email'] as String,
    createdAt: User._parseDateTime(json['created_at']),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'created_at': User._dateTimeToJson(instance.createdAt),
};