package wang.wangzh.wreader.utils

import android.content.Context
import android.content.pm.PackageManager
import android.os.Environment
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import wang.wangzh.wreader.R
import wang.wangzh.wreader.WReaderApp
import java.io.File
import java.nio.charset.Charset
import java.text.SimpleDateFormat
import java.util.*

/**
 * Description :  记录日志的帮助类
 * @author : wangzhanhong
 * @Date : 2020/3/31 13:57
 */
object RecordLogHelper {
    private const val TAG = "RecordLogHelper"
    private const val DIR_NAME = "WReader"
    private const val LOGS = "outLogs"
    private val dateFormat = SimpleDateFormat("yyyy_MM_dd_hh_mm_ss", Locale.CHINA)
    /**
     * 记录日志
     */
    @JvmStatic
    fun recordLog(context: Context, log: String?) {
        if (log.isNullOrBlank()) {
            MainHandler.runOnMain(Runnable {
                Toast.makeText(context, R.string.logContentWasEmpty, Toast.LENGTH_SHORT).show()
            })
            return
        }
        log.let {
            val file = obtainErrFile(context)
            Log.w(TAG, "file.absolutePath  =${file.absolutePath}")
            if (file.exists() || file.createNewFile()) {
                MainHandler.runOnMain(Runnable {
                    Toast.makeText(context, R.string.loging, Toast.LENGTH_LONG).show()
                })
                file.writeText(log, Charset.defaultCharset())
                MainHandler.runOnMain(Runnable {
                    Toast.makeText(
                        context,
                        "${WReaderApp.getApp().resources.getString(R.string.logingIn)}：${file.absolutePath}",
                        Toast.LENGTH_LONG
                    ).show()
                })
            } else {
                Toast.makeText(context, R.string.logingFailure, Toast.LENGTH_LONG).show()
            }
        }
    }

    fun obtainDefaultLogRoot(context: Context): String {
        val root = File("${context.filesDir.absolutePath}${File.separator}$LOGS")
        if (!root.exists()) {
            root.mkdirs()
        }
        return root.absolutePath
    }

    fun obtainExternalLogDir(context: Context): String {
        return if (PackageManager.PERMISSION_GRANTED == ActivityCompat.checkSelfPermission(
                context, android.Manifest.permission.WRITE_EXTERNAL_STORAGE
            )
            &&
            Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED
        ) {
            val parent =
                File("${Environment.getExternalStorageDirectory().absolutePath}${File.separator}${DIR_NAME}${File.separator}$LOGS")
            if (parent.exists() && parent.isDirectory) {
                parent.absolutePath
            } else if (!parent.exists() && parent.mkdirs()) {
                parent.absolutePath
            } else {
                obtainDefaultLogRoot(context)
            }
        } else {
            obtainDefaultLogRoot(context)
        }
    }

    private fun obtainErrFile(context: Context): File {
        val root = obtainExternalLogDir(context)
        return File(root, "${dateFormat.format(Date())}.txt")
    }

}