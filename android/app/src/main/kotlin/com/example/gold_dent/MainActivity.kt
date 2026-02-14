package com.example.gold_dent


import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.telephony.SmsManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_service"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val recipient = call.argument<String>("recipient")
                    val message = call.argument<String>("message")

                    if (recipient != null && message != null) {
                        sendSMS(recipient, message)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendSMS(recipient: String, message: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), 1)
                return
            }
        }

        try {
            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(recipient, null, message, null, null)
            println("SMS sent successfully to $recipient")
        } catch (e: Exception) {
            println("Failed to send SMS: ${e.message}")
        }
    }
}

