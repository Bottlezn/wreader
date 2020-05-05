package wang.wangzh.wreader

import androidx.multidex.MultiDexApplication
import wang.wangzh.wreader.utils.MainHandler
import wang.wangzh.wreader.utils.RecordLogHelper
import kotlin.system.exitProcess

class WReaderApp : MultiDexApplication() {

    companion object {
        private lateinit var app: WReaderApp
        fun getApp(): WReaderApp = app
        var initLocalCode: String? = null
    }

    private val errorCatchHandler = WReaderErrorCatchHandler()

    override fun onCreate() {
        super.onCreate()
        app = this
        initLocalCode=app.resources.configuration.locale.country
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