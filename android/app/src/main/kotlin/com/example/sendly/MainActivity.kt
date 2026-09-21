package com.example.sendly

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * يستقبل النص أو بطاقة الاتصال المشاركة من تطبيقات أخرى (زر «مشاركة» أو قائمة تحديد النص)
 * ويمررها إلى Flutter. لا يحتاج أي صلاحيات ولا يخرج أي بيانات من الجهاز.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var initialShare: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // المشاركة التي فتحت التطبيق (تشغيل بارد)
        initialShare = consumeShare(intent)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialShare" -> {
                        result.success(initialShare)
                        initialShare = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    // التطبيق مفتوح بالفعل ووصلته مشاركة جديدة
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        consumeShare(intent)?.let { channel?.invokeMethod("onShare", it) }
    }

    /** يقرأ المحتوى المشارك من [intent] ويمسحه حتى لا يُعالَج مرتين */
    private fun consumeShare(intent: Intent?): Map<String, String>? {
        if (intent == null) return null
        // فتح التطبيق من قائمة التطبيقات الأخيرة يعيد الـ intent القديم، فنتجاهله
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null

        val type = intent.type.orEmpty()
        val payload: Map<String, String>? = when (intent.action) {
            Intent.ACTION_SEND -> when {
                type.startsWith("text/plain") ->
                    intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
                        ?.let { mapOf("type" to "text", "text" to it) }
                type.contains("vcard") ->
                    readStream(intent)?.let { mapOf("type" to "vcard", "text" to it) }
                else -> null
            }
            Intent.ACTION_PROCESS_TEXT ->
                intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
                    ?.let { mapOf("type" to "text", "text" to it) }
            else -> null
        }

        intent.removeExtra(Intent.EXTRA_TEXT)
        intent.removeExtra(Intent.EXTRA_STREAM)
        intent.removeExtra(Intent.EXTRA_PROCESS_TEXT)

        return payload?.takeIf { it["text"].isNullOrBlank().not() }
    }

    /** يقرأ بطاقة الاتصال (vCard) المشاركة، بحد أقصى 64 كيلوبايت */
    private fun readStream(intent: Intent): String? {
        val uri: Uri? = if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }
        if (uri == null) return null

        return try {
            contentResolver.openInputStream(uri)?.use { stream ->
                val buffer = ByteArray(MAX_STREAM_BYTES)
                val read = stream.read(buffer)
                if (read <= 0) null else String(buffer, 0, read, Charsets.UTF_8)
            }
        } catch (e: Exception) {
            null
        }
    }

    companion object {
        private const val CHANNEL = "sendly/incoming"
        private const val MAX_STREAM_BYTES = 64 * 1024
    }
}
