import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

const _voterIdKey = 'featurama_voter_id';

String _generateUUID() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

Future<String> getOrCreateVoterId() async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString(_voterIdKey);
  if (id == null) {
    id = _generateUUID();
    await prefs.setString(_voterIdKey, id);
  }
  return id;
}
