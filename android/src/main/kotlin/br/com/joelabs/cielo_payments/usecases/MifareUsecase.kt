package br.com.joelabs.cielo_payments

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Mifare Classic 1K via serviço `cielo.lio.cashless` da Cielo Smart.
 *
 * Cada operação é uma Intent enviada com startService. O retorno chega por
 * broadcast (cbType = "B") numa action única por chamada, registrada em runtime.
 * Uma operação por vez; o resultado "R00" indica sucesso.
 */
class MifareUsecase(activityContext: Context) {

    private val context: Context = activityContext.applicationContext

    companion object {
        private const val TAG = "MifareUsecase"
        private const val CASHLESS_PACKAGE = "cielo.lio.cashless"
        private const val ACTION_PREFIX = "cielo.lio.cashless.mifare."
        private const val SUCCESS = "R00"
        private const val TIMEOUT_MS = 30_000L
        private const val DETECT_TIMEOUT_MS = 60_000L
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private var sequence = 0
    private var pending: Pending? = null

    private inner class Pending(
        val operation: String,
        val result: MethodChannel.Result,
        val receiver: BroadcastReceiver,
        val timeout: Runnable,
    )

    fun detectCard(result: MethodChannel.Result) {
        execute("DETECT", result, DETECT_TIMEOUT_MS) { it }
    }

    fun authenticateSector(call: MethodCall, result: MethodChannel.Result) {
        execute("AUTHENTICATE", result) {
            it.putExtra("sector", call.byte("sector"))
                .putExtra("key", call.argument<ByteArray>("key")!!)
                .putExtra("keyType", (call.argument<String>("keyType") ?: "A")[0])
        }
    }

    fun readBlock(call: MethodCall, result: MethodChannel.Result) {
        execute("READ", result) { it.withBlock(call) }
    }

    fun writeBlock(call: MethodCall, result: MethodChannel.Result) {
        execute("WRITE", result) {
            it.withBlock(call).putExtra("data", call.argument<ByteArray>("data")!!)
        }
    }

    fun incrementValue(call: MethodCall, result: MethodChannel.Result) {
        execute("INCREMENT", result) {
            it.withBlock(call).putExtra("value", call.byte("value"))
        }
    }

    fun decrementValue(call: MethodCall, result: MethodChannel.Result) {
        execute("DECREMENT", result) {
            it.withBlock(call).putExtra("value", call.byte("value"))
        }
    }

    fun backupBlock(call: MethodCall, result: MethodChannel.Result) {
        execute("BACKUP", result) {
            it.withBlock(call)
                .putExtra("destinationBlock", call.byte("destinationBlock"))
        }
    }

    fun restoreBlock(call: MethodCall, result: MethodChannel.Result) {
        execute("RESTORE", result) {
            it.withBlock(call)
                .putExtra("destinationBlock", call.byte("destinationBlock"))
        }
    }

    fun powerOff(result: MethodChannel.Result) {
        execute("DEACTIVATE", result) { it }
    }

    /** Interrompe a operação em andamento (ABORTED) e desativa a antena. */
    fun cancelDetection(result: MethodChannel.Result) {
        finish()?.result?.error("ABORTED", "Operação cancelada", null)
        execute("DEACTIVATE", result) { it }
    }

    fun dispose() {
        finish()?.result?.error("ABORTED", "Plugin desanexado", null)
    }

    private fun Intent.withBlock(call: MethodCall): Intent =
        putExtra("sector", call.byte("sector"))
            .putExtra("block", call.byte("block"))

    /** O serviço cashless espera sector, block, value e destinationBlock como Byte. */
    private fun MethodCall.byte(name: String): Byte = argument<Int>(name)!!.toByte()

    private fun execute(
        operation: String,
        result: MethodChannel.Result,
        timeoutMs: Long = TIMEOUT_MS,
        extras: (Intent) -> Intent,
    ) {
        if (pending != null) {
            result.error("BUSY", "Operação Mifare ${pending!!.operation} em andamento", null)
            return
        }

        val cbAction = "${context.packageName}.MIFARE_${operation}_${++sequence}"

        val receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                if (pending?.receiver !== this) return
                val p = finish() ?: return
                val code = intent?.getStringExtra("result")
                val detail = intent?.getStringExtra("detail")
                val data = intent?.getByteArrayExtra("data")
                Log.d(TAG, "$operation -> result=$code detail=$detail data=${data?.size}")

                if (code != SUCCESS) {
                    p.result.error(code ?: "NFC_ERROR", detail ?: "Falha na operação $operation", null)
                    return
                }
                when (operation) {
                    "DETECT" -> p.result.success(data?.toHex() ?: "")
                    "READ" -> p.result.success(data ?: ByteArray(16))
                    else -> p.result.success(null)
                }
            }
        }

        val timeout = Runnable {
            finish()?.result?.error("TIMEOUT", "Sem resposta do serviço cashless ($operation)", null)
        }

        try {
            val filter = IntentFilter(cbAction)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                context.registerReceiver(receiver, filter)
            }
            pending = Pending(operation, result, receiver, timeout)
            mainHandler.postDelayed(timeout, timeoutMs)

            val intent = extras(
                Intent(ACTION_PREFIX + operation)
                    .setPackage(CASHLESS_PACKAGE)
                    .putExtra("cbType", 'B')
                    .putExtra("cbPackage", context.packageName)
                    .putExtra("cbAction", cbAction)
            )
            if (startCashlessService(intent) == null) {
                finish()?.result?.error("NO_SERVICE", "Serviço $CASHLESS_PACKAGE não encontrado", null)
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "startService", e)
            (finish()?.result ?: result).error("NO_SERVICE", e.message, null)
        } catch (e: Exception) {
            Log.e(TAG, "startService", e)
            (finish()?.result ?: result).error("NFC_ERROR", e.message, null)
        }
    }

    /**
     * Inicia o serviço cashless. No Android 8+ o startService é recusado quando
     * o processo do cielo.lio.cashless não está rodando ("app is in background");
     * nesse caso tenta de novo com startForegroundService.
     */
    private fun startCashlessService(intent: Intent): ComponentName? {
        return try {
            context.startService(intent)
        } catch (e: IllegalStateException) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) throw e
            Log.w(TAG, "startService recusado, usando startForegroundService: ${e.message}")
            context.startForegroundService(intent)
        }
    }

    /** Encerra a operação pendente: remove timeout e receiver. */
    private fun finish(): Pending? {
        val p = pending ?: return null
        pending = null
        mainHandler.removeCallbacks(p.timeout)
        try {
            context.unregisterReceiver(p.receiver)
        } catch (e: IllegalArgumentException) {
        }
        return p
    }

    private fun ByteArray.toHex(): String = joinToString("") { "%02X".format(it) }
}
