package com.example.storoo

import android.content.Intent
import android.net.Uri
import java.io.File
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// 외부 앱에서 공유 시 투명 배경 위에 바텀시트만 표시하는 전용 Activity
/// 지원 타입: "link" (URL 포함 텍스트), "note" (일반 텍스트), "image" (이미지)
class ShareActivity : FlutterActivity() {
    private val channelName = "com.example.storoo/share"

    private var shareType: String = "link"
    private var sharedText: String? = null
    private var imageFilePath: String? = null

    override fun getDartEntrypointFunctionName(): String = "shareMain"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        extractSharedData()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getShareType"   -> result.success(shareType)
                    "getSharedText"  -> result.success(sharedText)
                    "getImagePath"   -> result.success(imageFilePath)
                    else             -> result.notImplemented()
                }
            }
    }

    private fun extractSharedData() {
        if (intent?.action != Intent.ACTION_SEND) return

        when {
            // ── 이미지 공유 ──────────────────────────────────────────
            intent?.type?.startsWith("image/") == true -> {
                shareType = "image"
                val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                if (uri != null) {
                    imageFilePath = copyUriToCache(uri)
                }
            }
            // ── 텍스트 공유: URL 포함 여부로 link / note 구분 ───────
            intent?.type?.startsWith("text/") == true -> {
                val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: ""
                val hasUrl = Regex("https?://\\S+", RegexOption.IGNORE_CASE).containsMatchIn(text)
                shareType = if (hasUrl) "link" else "note"
                sharedText = text
            }
        }
    }

    /// content URI 이미지를 앱 캐시 디렉터리에 복사하고 파일 경로 반환
    private fun copyUriToCache(uri: Uri): String? {
        return try {
            val input = contentResolver.openInputStream(uri) ?: return null
            val ext = contentResolver.getType(uri)
                ?.substringAfter('/')?.substringBefore(';') ?: "jpg"
            val temp = File(cacheDir, "share_img_${System.currentTimeMillis()}.$ext")
            temp.outputStream().use { out -> input.copyTo(out) }
            temp.absolutePath
        } catch (_: Exception) {
            null
        }
    }
}
