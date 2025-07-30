package br.com.joelabs.cielo_payments

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

class DeeplinkUsecase(private val activity: Activity?, private val channel: MethodChannel) {
    private var waitingForResult = false

    companion object {
        private const val TAG = "DeeplinkUsecase"
    }

    private var pendingResult: MethodChannel.Result? = null

    fun doPayment(call: MethodCall, result: MethodChannel.Result) {
        val request = call.argument<String>("request")
        val urlCallback = call.argument<String>("urlCallback")

        // Construir a URI do deeplink
        val uriBuilder = Uri.Builder()
            .scheme("lio")
            .authority("payment")
            .appendQueryParameter("urlCallback", urlCallback ?: "order://response")
            .appendQueryParameter("request", request)

        val deeplinkUri = uriBuilder.build()
        val intent = Intent(Intent.ACTION_VIEW, deeplinkUri)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)

        try {
            waitingForResult = true
            activity?.startActivity(intent)
        } catch (e: Exception) {
            result.error("DEEPLINK_ERROR", "Failed to open deeplink: ${e.localizedMessage}", null)
        }
    }

    fun doPrint(call: MethodCall, result: MethodChannel.Result) {
        val request = call.argument<String>("request")
        val urlCallback = call.argument<String>("urlCallback")

        // Construir a URI do deeplink
        val uriBuilder = Uri.Builder()
            .scheme("lio")
            .authority("print")
            .appendQueryParameter("urlCallback", urlCallback ?: "order://response")
            .appendQueryParameter("request", request)

        val deeplinkUri = uriBuilder.build()
        val intent = Intent(Intent.ACTION_VIEW, deeplinkUri)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)

        try {
            waitingForResult = true
            activity?.startActivity(intent)
        } catch (e: Exception) {
            result.error("DEEPLINK_ERROR", "Failed to open deeplink: ${e.localizedMessage}", null)
        }
    }

    fun handleDeeplinkResponse(intent: Intent?) {
        intent?.data?.let { uri ->
            val response = mutableMapOf<String, String>()
            uri.queryParameterNames.forEach { key ->
                response[key] = uri.getQueryParameter(key) ?: ""
            }

            Log.d(TAG, "Deeplink response received: $response")

            waitingForResult = false;
            channel.invokeMethod("onDeeplinkResponse", response)
        } ?: run {
            Log.e(TAG, "No data found in deeplink response")
        }
    }

}