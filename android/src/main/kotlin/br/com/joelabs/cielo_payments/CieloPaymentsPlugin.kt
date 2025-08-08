package br.com.joelabs.cielo_payments

import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CieloPaymentsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private var channel: MethodChannel? = null
    private var activity: Activity? = null
    private var deeplinkUsecase: DeeplinkUsecase? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "cielo_payments")
        // Importante: NÃO chame setMethodCallHandler aqui se o uso depende da Activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        channel?.setMethodCallHandler(this) // só aqui!
        deeplinkUsecase = DeeplinkUsecase(activity, channel!!)
        binding.addOnNewIntentListener(::handleNewIntent)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "paymentDeeplink" -> deeplinkUsecase?.doPayment(call, result)
            "printDeeplink" -> deeplinkUsecase?.doPrint(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
        deeplinkUsecase = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    private fun handleNewIntent(intent: Intent): Boolean {
        Log.d("CieloPaymentsPlugin", "onNewIntent received: ${intent.data}")
        return intent.data?.let {
            deeplinkUsecase?.handleDeeplinkResponse(intent)
            true
        } ?: false
    }
}

