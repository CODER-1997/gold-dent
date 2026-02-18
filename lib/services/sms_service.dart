import 'package:flutter/services.dart';

class SMSService {
  static const MethodChannel _channel = MethodChannel('sms_service');

  Future<void> sendSMS(String recipient, String message) async {
    try {
      await _channel.invokeMethod('sendSMS', {
        'recipient': recipient,
        'message': message,
      });
      print('Sms ketti');
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'.");
    }
  }
}
