package com.example.flutter_app

import android.os.Build
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val SECURITY_CHANNEL = "com.edukkit.app/security"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureWindow" -> {
                    try {
                        activity?.window?.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FLAG_SECURE_ERROR", e.localizedMessage, null)
                    }
                }
                "disableSecureWindow" -> {
                    try {
                        activity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FLAG_SECURE_ERROR", e.localizedMessage, null)
                    }
                }
                "isDeviceRooted" -> {
                    result.success(checkRootSafely())
                }
                "getSecurityInfo" -> {
                    val info = mapOf(
                        "platform" to "Android",
                        "apiLevel" to Build.VERSION.SDK_INT,
                        "brand" to Build.BRAND,
                        "model" to Build.MODEL,
                        "widevineL1Supported" to isWidevineL1Supported()
                    )
                    result.success(info)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkRootSafely(): Boolean {
        val buildTags = Build.TAGS
        if (buildTags != null && buildTags.contains("test-keys")) {
            return true
        }
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun isWidevineL1Supported(): Boolean {
        return try {
            val widevineUuid = java.util.UUID(-0x121074568629b532L, -0x5c37d8232ae2de13L)
            val mediaDrm = android.media.MediaDrm(widevineUuid)
            val securityLevel = mediaDrm.getPropertyString("securityLevel")
            mediaDrm.close()
            securityLevel.equals("L1", ignoreCase = true)
        } catch (e: Exception) {
            false
        }
    }
}
