import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

import 'consts.dart';
import 'app_states.dart';

class WakeOn extends StatefulWidget {
  const WakeOn({super.key});

  @override
  State<WakeOn> createState() => _WakeOnState();
}

class _WakeOnState extends State<WakeOn> {
  bool _isSending = false;

  Future<void> _handlePowerButton() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await WakeOnApi.sendPacket();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wake on command has been sent'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fail: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: ElevatedButton(
            onPressed: _isSending ? null : _handlePowerButton,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(
                side: BorderSide(
                  color: AppColors.secondary,
                  width: 3,
                ),
              ),
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
            ),
            child: _isSending
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )
                : const Icon(
                    Icons.power_settings_new,
                    size: 40,
                  ),
          ),
        ),
      ),
    );
  }
}

class WakeOnApi {
  static const String _apiUrl =
      'https://2afkfbebc2.execute-api.ap-northeast-1.amazonaws.com/power_on';

  static Future<void> sendPacket() async {
    final accessToken = await AppStates.getAccessToken();
    final device = await AppStates.getDeviceSettings();
    if (device == null) {
      throw Exception('No device');
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': 'power_on',
        'payload': {
          'name': device.name,
          'mac': device.mac,
        },
      }),
    );

    Map<String, dynamic> responseBody = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseBody = decoded;
        }
      } on FormatException {
        throw Exception(
          'Invalid response format: '
          '${response.statusCode} ${response.body}',
        );
      }
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        responseBody['message']?.toString() ??
            'Failed to call API: ${response.statusCode}',
      );
    }
  }
}
