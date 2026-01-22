package br.com.joelabs.cielo_payments

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

class DeeplinkUsecase(private val activity: Activity?, private val channel: MethodChannel) {
    private var waitingForResult = false
    private val printQueue: ArrayDeque<Pair<String, String>> = ArrayDeque()

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
            .appendQueryParameter("urlCallback", urlCallback)
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
        val requests = call.argument<List<String>>("requests")
        val urlCallback = call.argument<String>("urlCallback")

        if (requests.isNullOrEmpty() || urlCallback.isNullOrEmpty()) {
            result.error("DEEPLINK_ERROR", "Missing print parameters", null)
            return
        }

        Log.d(TAG, "doPrint called with ${requests.size} items")
        
        // Adiciona todos os requests à fila
        for (request in requests) {
            printQueue.addLast(Pair(request, urlCallback))
        }

        Log.d(TAG, "Print queue size: ${printQueue.size}")

        // Se não há impressão em andamento, inicia a primeira
        if (!waitingForResult && printQueue.isNotEmpty()) {
            val (nextRequest, nextCallback) = printQueue.removeFirst()
            Log.d(TAG, "Starting first print. Queue remaining: ${printQueue.size}")
            startPrint(nextRequest, nextCallback, null)
        } else {
            Log.d(TAG, "Print already in progress, items queued")
        }
        
        // IMPORTANTE: Retorna sucesso imediatamente após enfileirar
        result.success(null)
    }

    private fun startPrint(request: String, urlCallback: String, result: MethodChannel.Result?) {
        Log.d(TAG, "startPrint called. Queue size: ${printQueue.size}")
        
        val uriBuilder = Uri.Builder()
            .scheme("lio")
            .authority("print")
            .appendQueryParameter("urlCallback", urlCallback)
            .appendQueryParameter("request", request)

        val deeplinkUri = uriBuilder.build()
        Log.d(TAG, "Print deeplink: $deeplinkUri")
        
        val intent = Intent(Intent.ACTION_VIEW, deeplinkUri)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)

        try {
            waitingForResult = true
            activity?.startActivity(intent)
            Log.d(TAG, "Print activity started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting print activity: ${e.localizedMessage}")
            result?.error("DEEPLINK_ERROR", "Failed to open deeplink: ${e.localizedMessage}", null)
        }
    }

    fun handleDeeplinkResponse(intent: Intent?) {
        intent?.data?.let { uri ->
            val response = mutableMapOf<String, String>()
            uri.queryParameterNames.forEach { key ->
                response[key] = uri.getQueryParameter(key) ?: ""
            }

            Log.d(TAG, "Deeplink response received: $response")
            Log.d(TAG, "Print queue size before processing: ${printQueue.size}")

            // Notifica o Dart
            channel.invokeMethod("onDeeplinkResponse", response)

            // Após cada resposta, inicia a próxima impressão, se houver
            if (printQueue.isNotEmpty()) {
                val (nextRequest, nextCallback) = printQueue.removeFirst()
                Log.d(TAG, "Starting next print from queue. Remaining: ${printQueue.size}")
                startPrint(nextRequest, nextCallback, null)
            } else {
                Log.d(TAG, "No more items in queue. Setting waitingForResult = false")
                waitingForResult = false
            }
        } ?: run {
            Log.e(TAG, "No data found in deeplink response")
        }
    }

}