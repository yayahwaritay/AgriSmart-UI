import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deviceIdPrefsKey = 'agrismart.device_id';

/// A stable id for this install, used to tie a biometric key pair to a
/// specific device (see README.mobile.md's biometric login section).
/// Generated once and persisted via `shared_preferences` — same pattern as
/// `theme_mode_provider.dart`. Doesn't need to be secret, just stable.
class DeviceId extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdPrefsKey);
    if (existing != null) return existing;

    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final generated = base64UrlEncode(bytes);
    await prefs.setString(_deviceIdPrefsKey, generated);
    return generated;
  }
}

final deviceIdProvider = AsyncNotifierProvider<DeviceId, String>(DeviceId.new);
