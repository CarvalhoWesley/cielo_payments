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

/** CieloPaymentsPlugin */
class CieloPaymentsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    Activity() {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var deeplinkUsecase: DeeplinkUsecase? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cielo_payments")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        deeplinkUsecase = DeeplinkUsecase(activity, channel)

        binding.addOnNewIntentListener(::handleNewIntent)

    }

    override fun onDetachedFromActivity() {
        activity = null
        deeplinkUsecase = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Métodos relacionados ao DeeplinkUsecase
            "paymentDeeplink" -> deeplinkUsecase?.doPayment(call, result)
            "printDeeplink" -> deeplinkUsecase?.doPrint(call, result)
            else ->
                result.notImplemented()

        }
    }

    private fun handleNewIntent(intent: Intent): Boolean {
        Log.d("CieloPaymentsPlugin", "onNewIntent received: ${intent.data}")
        return intent.data?.let {
            deeplinkUsecase?.handleDeeplinkResponse(intent)
            true
        } ?: false
    }

}
