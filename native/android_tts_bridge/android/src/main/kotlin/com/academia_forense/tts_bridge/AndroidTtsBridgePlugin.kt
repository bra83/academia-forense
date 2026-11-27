package com.academia_forense.tts_bridge

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.speech.tts.Voice
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Locale

class AndroidTtsBridgePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL_NAME = "com.academia_forense/tts_bridge/methods"
        const val EVENT_CHANNEL_NAME = "com.academia_forense/tts_bridge/events"

        val SUPPORTED_ENGINES = listOf(
            "com.k2fsa.sherpa.onnx.tts.engine",
            "com.k2fsa.sherpa.onnx.tts.engine.debug"
        )

        const val MIN_SPEED = 0.65
        const val MAX_SPEED = 1.50
    }

    private var context: Context? = null
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var textToSpeech: TextToSpeech? = null
    private var activeEngine: String? = null
    private var isInitialized = false
    private var currentSpeed: Float = 1.0f
    private var initGeneration = 0

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME).also {
            it.setStreamHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        shutdownEngine()
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "detectInstalledEngines" -> {
                val engines = detectInstalledEngines()
                result.success(engines)
            }
            "isEngineInstalled" -> {
                val enginePackage = call.argument<String>("enginePackage")
                if (enginePackage != null) {
                    result.success(isPackageInstalled(enginePackage))
                } else {
                    result.success(detectInstalledEngines().isNotEmpty())
                }
            }
            "initEngine" -> {
                val requestedEngine = call.argument<String>("enginePackage")
                initEngine(requestedEngine, result)
            }
            "getAvailableVoices" -> {
                getAvailableVoices(result)
            }
            "setVoice" -> {
                val voiceName = call.argument<String>("voiceName")
                if (voiceName == null) {
                    result.error("INVALID_ARGUMENT", "voiceName must not be null", null)
                    return
                }
                setVoice(voiceName, result)
            }
            "setSpeed" -> {
                val speed = call.argument<Double>("speed")
                if (speed == null) {
                    result.error("INVALID_ARGUMENT", "speed must not be null", null)
                    return
                }
                setSpeed(speed, result)
            }
            "speakChunk" -> {
                val chunkId = call.argument<String>("chunkId")
                val text = call.argument<String>("text")
                val speed = call.argument<Double>("speed")
                val queue = call.argument<Boolean>("queue") ?: false

                if (chunkId == null || text == null) {
                    result.error("INVALID_ARGUMENT", "chunkId and text must not be null", null)
                    return
                }
                speakChunk(chunkId, text, speed, queue, result)
            }
            "stop" -> {
                stopPlayback(result)
            }
            "shutdown" -> {
                shutdownEngine()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun detectInstalledEngines(): List<String> {
        val ctx = context ?: return emptyList()
        val pm = ctx.packageManager
        val installed = mutableListOf<String>()

        for (pkg in SUPPORTED_ENGINES) {
            if (isPackageInstalled(pkg)) {
                installed.add(pkg)
            }
        }
        return installed
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        val ctx = context ?: return false
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ctx.packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                ctx.packageManager.getPackageInfo(packageName, 0)
            }
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun initEngine(enginePackage: String?, result: Result) {
        val ctx = context
        if (ctx == null) {
            result.error("CONTEXT_UNAVAILABLE", "Application context is null", null)
            return
        }

        if (Build.VERSION.SDK_INT < 26) {
            result.error("UNSUPPORTED_API_LEVEL", "Android API level ${Build.VERSION.SDK_INT} unsupported (Minimum API 26 required)", null)
            return
        }

        val systemDefault = enginePackage == "system"
        val targetEngine = if (systemDefault) "system" else
            (enginePackage ?: detectInstalledEngines().firstOrNull())
        if (targetEngine == null ||
            (!systemDefault && (!SUPPORTED_ENGINES.contains(targetEngine) ||
                !isPackageInstalled(targetEngine)))) {
            result.error("ENGINE_NOT_INSTALLED",
                "Motor Braseiro Kokoro não instalado. "
                + "Instale e ative o motor Sherpa-ONNX, "
                + "ou selecione Voz Android (sistema).", null)
            return
        }

        shutdownEngine()
        val generation = ++initGeneration
        var responded = false
        mainHandler.postDelayed({
            if (!responded) {
                responded = true
                if (generation == initGeneration) shutdownEngine()
                result.error("INIT_TIMEOUT", "O motor TTS não respondeu em 15 segundos.", null)
            }
        }, 15000L)

        val listener = TextToSpeech.OnInitListener { status ->
            mainHandler.post {
                if (responded) return@post
                responded = true
                if (generation != initGeneration) {
                    result.error("INIT_CANCELLED", "Inicialização cancelada.", null)
                    return@post
                }
                if (status == TextToSpeech.SUCCESS) {
                    isInitialized = true
                    activeEngine = targetEngine
                    if (systemDefault) {
                        // Try pt-BR first; the user can still pick an installed
                        // voice explicitly if only another language exists.
                        textToSpeech?.setLanguage(Locale.forLanguageTag("pt-BR"))
                    }
                    setupUtteranceListener()
                    result.success(mapOf(
                        "success" to true,
                        "engine" to targetEngine
                    ))
                } else {
                    isInitialized = false
                    activeEngine = null
                    result.error("INIT_FAILED", "TextToSpeech init returned error code $status", null)
                }
            }
        }
        textToSpeech = if (systemDefault) TextToSpeech(ctx, listener)
            else TextToSpeech(ctx, listener, targetEngine)
    }

    private fun setupUtteranceListener() {
        textToSpeech?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {
                utteranceId?.let { id ->
                    sendEvent(mapOf(
                        "event" to "start",
                        "utteranceId" to id
                    ))
                }
            }

            override fun onDone(utteranceId: String?) {
                utteranceId?.let { id ->
                    sendEvent(mapOf(
                        "event" to "done",
                        "utteranceId" to id
                    ))
                }
            }

            @Deprecated("Deprecated in Java")
            override fun onError(utteranceId: String?) {
                utteranceId?.let { id ->
                    sendEvent(mapOf(
                        "event" to "error",
                        "utteranceId" to id,
                        "errorCode" to -1
                    ))
                }
            }

            override fun onError(utteranceId: String?, errorCode: Int) {
                utteranceId?.let { id ->
                    sendEvent(mapOf(
                        "event" to "error",
                        "utteranceId" to id,
                        "errorCode" to errorCode
                    ))
                }
            }
        })
    }

    private fun getAvailableVoices(result: Result) {
        val tts = textToSpeech
        if (!isInitialized || tts == null) {
            result.error("NOT_INITIALIZED", "Native TTS engine must be initialized before calling getAvailableVoices()", null)
            return
        }

        val voices = try { tts.voices } catch (e: Exception) { null }
        if (voices == null || voices.isEmpty()) {
            result.success(emptyList<Map<String, Any>>())
            return
        }

        val voiceList = voices.map { v ->
            mapOf(
                "name" to v.name,
                "locale" to v.locale.toLanguageTag(),
                "quality" to v.quality,
                "latency" to v.latency,
                "requiresNetwork" to v.isNetworkConnectionRequired
            )
        }
        result.success(voiceList)
    }

    private fun setVoice(voiceName: String, result: Result) {
        val tts = textToSpeech
        if (!isInitialized || tts == null) {
            result.error("NOT_INITIALIZED", "Native TTS engine must be initialized before calling setVoice()", null)
            return
        }

        val voices = tts.voices
        if (voices.isNullOrEmpty()) {
            result.error("NO_VOICES", "No voices available from installed TTS engine", null)
            return
        }

        val matchedVoice = voices.firstOrNull { it.name == voiceName }
        if (matchedVoice == null) {
            result.error("INVALID_VOICE", "Voice '$voiceName' is not supported by installed engine.", null)
            return
        }

        val code = tts.setVoice(matchedVoice)
        if (code == TextToSpeech.SUCCESS) {
            result.success(true)
        } else {
            result.error("SET_VOICE_FAILED", "tts.setVoice returned code $code", null)
        }
    }

    private fun setSpeed(speed: Double, result: Result) {
        if (speed < MIN_SPEED || speed > MAX_SPEED) {
            result.error("INVALID_SPEED", "Speed $speed out of bounds [$MIN_SPEED, $MAX_SPEED]", null)
            return
        }

        val tts = textToSpeech
        if (!isInitialized || tts == null) {
            result.error("NOT_INITIALIZED", "Native TTS engine must be initialized before calling setSpeed()", null)
            return
        }

        currentSpeed = speed.toFloat()
        val code = tts.setSpeechRate(currentSpeed)
        if (code == TextToSpeech.SUCCESS) {
            result.success(true)
        } else {
            result.error("SET_SPEED_FAILED", "tts.setSpeechRate returned code $code", null)
        }
    }

    private fun speakChunk(
        chunkId: String,
        text: String,
        speed: Double?,
        queue: Boolean,
        result: Result
    ) {
        val tts = textToSpeech
        if (!isInitialized || tts == null) {
            result.error("NOT_INITIALIZED", "Native TTS engine must be initialized before calling speak()", null)
            return
        }

        if (speed != null) {
            if (speed < MIN_SPEED || speed > MAX_SPEED) {
                result.error("INVALID_SPEED", "Speed $speed out of bounds [$MIN_SPEED, $MAX_SPEED]", null)
                return
            }
            tts.setSpeechRate(speed.toFloat())
        }

        val queueMode = if (queue) TextToSpeech.QUEUE_ADD else TextToSpeech.QUEUE_FLUSH
        val params = Bundle().apply {
            putString(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, chunkId)
        }

        val code = try { tts.speak(text, queueMode, params, chunkId) } catch (e: Exception) {
            result.error("SPEAK_FAILED", "O motor recusou o texto: ${e.javaClass.simpleName}", null)
            return
        }
        if (code == TextToSpeech.SUCCESS) {
            result.success(true)
        } else {
            result.error("SPEAK_FAILED", "tts.speak returned error code $code", null)
        }
    }

    private fun stopPlayback(result: Result) {
        textToSpeech?.stop()
        result.success(true)
    }

    private fun shutdownEngine() {
        initGeneration++
        textToSpeech?.let {
            it.stop()
            it.shutdown()
        }
        textToSpeech = null
        isInitialized = false
        activeEngine = null
    }

    private fun sendEvent(data: Map<String, Any>) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
