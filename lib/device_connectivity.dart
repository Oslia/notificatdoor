import 'dart:convert';
import 'dart:async';
import 'package:amplify_core/amplify_core.dart';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

import 'consts.dart';
import 'app_states.dart';

class DeviceConnectivityStatus {
  const DeviceConnectivityStatus({
    required this.thingName,
    required this.connected,
    this.timestamp,
    this.disconnectReason,
    this.clientId,
    this.keepAliveDuration,
  });

  final String thingName;
  final bool connected;
  final DateTime? timestamp;
  final String? disconnectReason;
  final String? clientId;
  final int? keepAliveDuration;

  factory DeviceConnectivityStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['thingName'] is! String ||
        json['connected'] is! bool) {
      throw const FormatException('Invalid connectivity response');
    }

    return DeviceConnectivityStatus(
      thingName: json['thingName'] as String,
      connected: json['connected'] as bool,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      disconnectReason: json['disconnectReason'] as String?,
      clientId: json['clientId'] as String?,
      keepAliveDuration:
          (json['keepAliveDuration'] as num?)?.toInt(),
    );
  }
}

class DeviceConnectivity {
  static const String _apiUrl = 'https://o0d2dsh35h.execute-api.ap-northeast-1.amazonaws.com/device/connect_status';
  
  static Future<DeviceConnectivityStatus> sendPacket() async {
    final accessToken = await AppStates.getAccessToken();

    final response = await http.get(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

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

    return DeviceConnectivityStatus.fromJson(responseBody);
  }
}


class DeviceConnectivityIndicator extends StatefulWidget {
  const DeviceConnectivityIndicator({super.key});

  @override
  State<DeviceConnectivityIndicator> createState() =>
      _DeviceConnectivityIndicatorState();
}


class _DeviceConnectivityIndicatorState
    extends State<DeviceConnectivityIndicator> {
  DeviceConnectivityStatus? _status;
  Timer? _timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await DeviceConnectivity.sendPacket();
      if (!mounted) return;

      setState(() {
        _status = status;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = null;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Tooltip(
        message: 'Error: $_error',
        child: const Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
      );
    }

    if (_status == null) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Tooltip(
      message:
          'Device ${_status!.thingName}\nConnected: ${_status!.connected}\n'
          'Timestamp: ${_status!.timestamp?.toIso8601String() ?? 'N/A'}\n'
          'Disconnect Reason: ${_status!.disconnectReason ?? 'N/A'}\n'
          'Client ID: ${_status!.clientId ?? 'N/A'}\n'
          'Keep Alive Duration: ${_status!.keepAliveDuration ?? 'N/A'}',
      child: Icon(
        Icons.circle,
        color: _status!.connected ? Colors.green : Colors.red,
      ),
    );
  }
}