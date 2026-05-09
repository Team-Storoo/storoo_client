package com.example.storoo

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// 외부 앱에서 공유 시 투명 배경 위에 바텀시트만 표시하는 전용 Activity
class ShareActivity : FlutterActivity() {
    private val channelName = "com.example.storoo/share"
    private var sharedText: String? = null

    override fun getDartEntrypointFunctionName(): String = "shareMain"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        extractSharedText()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSharedText" -> result.success(sharedText)
                    else -> result.notImplemented()
                }
            }
    }

    private fun extractSharedText() {
        if (intent?.action == Intent.ACTION_SEND &&
            intent?.type?.startsWith("text/") == true
        ) {
            sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        }
    }
}
