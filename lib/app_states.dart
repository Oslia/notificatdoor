import 'dart:convert';
import 'dart:async';

import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AppStates {
  Timer? _statusTimer;
  bool _connected = false;
  bool _deviceStatus = false;

  static Future<bool> isSignedIn() async {
    final session = await Amplify.Auth.fetchAuthSession().timeout(const Duration(seconds: 10));

    safePrint(
      'fetchAuthSession 완료: ${session.isSignedIn}',
    );
    
    return session.isSignedIn;
  }

  static Future<bool> updateDeviceConnectivity() async {
    final session = await Amplify.Auth.fetchAuthSession().timeout(const Duration(seconds: 10));

    safePrint(
      'fetchAuthSession 완료: ${session.isSignedIn}',
    );

    return session.isSignedIn;
  }

  static Future<String> getAccessToken() async {
    final cognitoPlugin = Amplify.Auth.getPlugin(
      AmplifyAuthCognito.pluginKey,
    );

    final session = await cognitoPlugin.fetchAuthSession();

    if (!session.isSignedIn) {
      throw Exception('로그인이 필요합니다.');
    }

    final tokens = session.userPoolTokensResult.value;

    return tokens.accessToken.raw;
  }

  static Future<DeviceSettings?> getDeviceSettings() async {
    final attributes =
        await Amplify.Auth.fetchUserAttributes();

    const deviceKey =
        CognitoUserAttributeKey.custom('pc_to_wake_on_lan');

    String? deviceJson;

    for (final attribute in attributes) {
      if (attribute.userAttributeKey == deviceKey) {
        deviceJson = attribute.value;
        break;
      }
    }

    if (deviceJson == null || deviceJson.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(deviceJson);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid property');
    }

    final name = decoded['name'];
    final mac = decoded['mac'];

    if (name is! String || name.trim().isEmpty) {
      throw Exception('No name.');
    }

    if (mac is! String || mac.trim().isEmpty) {
      throw Exception('No mac address');
    }

    return DeviceSettings(
      name: name,
      mac: mac,
    );
  }
}

class DeviceSettings {
  final String name;
  final String mac;

  const DeviceSettings({
    required this.name,
    required this.mac,
  });
}
