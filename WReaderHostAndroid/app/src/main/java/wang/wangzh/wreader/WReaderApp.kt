package wang.wangzh.wreader

import android.os.Build
import android.util.Log
import androidx.multidex.MultiDexApplication
import wang.wangzh.wreader.utils.MainHandler
import wang.wangzh.wreader.utils.RecordLogHelper
import java.util.*
import kotlin.system.exitProcess

class WReaderApp : MultiDexApplication() {

    companion object {
        private lateinit var app: WReaderApp
        fun getApp(): WReaderApp = app
        /**
         * 设备刚启动时 ，环境配置中的语言选项
         */
        var deviceInitLocale: Locale? = null
        var currentLocal: Locale? = null
        private const val TAG = "WReaderApp"
    }

    private val errorCatchHandler = WReaderErrorCatchHandler()

    override fun onCreate() {
        super.onCreate()
        app = this
        deviceInitLocale = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            app.resources.configuration.locales.get(0)
        } else {
            app.resources.configuration.locale
        }
        Log.i(TAG, "initLocalCode = ${deviceInitLocale?.language}_${deviceInitLocale?.country}")
        Thread.setDefaultUncaughtExceptionHandler(errorCatchHandler)
    }

    inner class WReaderErrorCatchHandler : Thread.UncaughtExceptionHandler {

        override fun uncaughtException(t: Thread?, e: Throwable?) {
            e?.let {
                val builder = StringBuilder()
                e.stackTrace?.forEach { stackTraceElement ->
                    builder.appendln(stackTraceElement.toString())
                }
                RecordLogHelper.recordLog(this@WReaderApp, builder.toString())
            }
            MainHandler.runOnMain(Runnable {
                exitProcess(0)
            })
        }

    }
}