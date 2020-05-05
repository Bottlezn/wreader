package wang.wangzh.wreader.feature.flutter

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry
import io.flutter.plugin.common.MethodChannel
import wang.wangzh.wreader.R
import wang.wangzh.wreader.consts.CHANNEL_TRANS_BRIDGE
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import wang.wangzh.wreader.feature.flutter.WReaderMethodCallHandler.Companion.GET_GIT_CONF_FILE
import wang.wangzh.wreader.feature.flutter.protocol.ApplyStorageCallback
import wang.wangzh.wreader.feature.flutter.protocol.IExternalMethodCallHelper
import wang.wangzh.wreader.utils.PathUtil


/**
 * WReader的Flutter Host Activity。
 * 使用[WReaderMethodCallHandler]处理Flutter的Channel通讯事件
 */
class FlutterMainAty : FlutterActivity(), IExternalMethodCallHelper {

    companion object {
        const val APPLY_WRITER_EXTRA = 123
        const val READ_MD_FILE = 124
        private const val TAG = "FlutterMainAty"
        private const val PAGE_HOME_ROUTE = "/home"
        @JvmStatic
        fun startReading(aty: Context, brightnessMode: Int?, languageCode: String?) {
            val intent = Intent(aty, FlutterMainAty::class.java)
            intent.putExtra(FlutterModuleDbConst.BRIGHTNESS_MODE, brightnessMode)
            intent.putExtra(FlutterModuleDbConst.LANGUAGE_CODE, languageCode)
            if (aty !is Activity) {
                //非Activity启动增加FLAG_ACTIVITY_NEW_TASK
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            aty.startActivity(intent)
        }
    }

    private var initChannel: MethodChannel? = null

    /**
     * 申请存储权限的回调
     */
    private var applyStorageCallback: ApplyStorageCallback? = null

    /**
     * wreader module 的methodHandler
     */
    private var methodCallHandler: WReaderMethodCallHandler? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initChannel()
    }

    fun checkWriteExternalStorage() {
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_DENIED
        ) {
            applyExternalStoragePermission(null, Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }
    }

    private fun parseGitFailOrCancel() {
        methodCallHandler?.transGitConFilePath(null)
    }

    /**
     * 解析git配置文件的绝对路径
     * 在Windows中使用`certutil -encode id_rsa_2048_git pri.txt`，可对密钥对和密码文件进行Base64编码
     */
    private fun parseGitConfPath(data: Intent?) {
        Log.i(TAG, "data?.dataString = ${data?.dataString}")

        data?.data?.let { uri ->
            Log.w(TAG, "PathUtil.getPath(this,uri) = ${PathUtil.getPath(this, uri)}")
            val filePath = PathUtil.getPath(this, uri)
            filePath?.let {
                methodCallHandler?.transGitConFilePath(it)
            } ?: run {
                parseGitFailOrCancel()
            }
        } ?: run {
            parseGitFailOrCancel()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (Activity.RESULT_OK == resultCode) {
            when (requestCode) {
                //获取成功
                GET_GIT_CONF_FILE -> {
                    parseGitConfPath(data)
                }
                else -> {
                }
            }
        } else if (GET_GIT_CONF_FILE == requestCode) {
            parseGitFailOrCancel()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == APPLY_WRITER_EXTRA) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                this.applyStorageCallback?.callback(true)
            } else {
                this.applyStorageCallback?.callback(false)
                Toast.makeText(this, R.string.grantPermission, Toast.LENGTH_LONG).show()
            }
            this.applyStorageCallback = null
        }
    }

    private fun initChannel() {
        flutterEngine?.let {
            ShimPluginRegistry(it).registrarFor(FlutterMainAty::class.java.name)
                ?.messenger()?.let { message ->
                    initChannel = MethodChannel(message, CHANNEL_TRANS_BRIDGE)
                    methodCallHandler = WReaderMethodCallHandler(this)
                    methodCallHandler?.let { handler ->
                        initChannel?.setMethodCallHandler(handler)
                    }
                }
        }
    }

    /**
     * val homeRoute = "${PAGE_HOME_ROUTE}?mode=${intent?.getIntExtra(
     * FlutterInitializedKey.BRIGHTNESS_MODE,
     *  -1
     *  )}&languageCode=${intent?.getStringExtra(FlutterInitializedKey.LANGUAGE_CODE)}"
     * Log.w(TAG, homeRoute)
     * try {
     * val matcher =
     * Pattern.compile("^${PAGE_HOME_ROUTE}\\?mode=([-\\d]{1,2})&languageCode=([\\w]*)\$")
     * .matcher(homeRoute)
     * if (matcher.find()) {
     * Log.i(TAG, matcher.group(1))
     * Log.i(TAG, matcher.group(2))
     * } else {
     * Log.i(TAG, "have no match")
     * }
     * } catch (e: Exception) {
     * e.printStackTrace()
     * }
     */
    override fun getInitialRoute(): String {
        return "${PAGE_HOME_ROUTE}?${FlutterModuleDbConst.BRIGHTNESS_MODE}=${intent?.getIntExtra(
            FlutterModuleDbConst.BRIGHTNESS_MODE,
            -1
        )}&${FlutterModuleDbConst.LANGUAGE_CODE}=${intent?.getStringExtra(FlutterModuleDbConst.LANGUAGE_CODE)}"
    }

    override fun onDestroy() {
        applyStorageCallback = null
        methodCallHandler?.onDestroy()
        methodCallHandler = null
        super.onDestroy()
    }

    override fun applyExternalStoragePermission(
        callback: ApplyStorageCallback?,
        permission: String
    ) {
        this.applyStorageCallback = callback
        ActivityCompat.requestPermissions(
            this,
            arrayOf(permission),
            APPLY_WRITER_EXTRA
        )
    }

    override fun canNext(): Activity? {
        return if (isFinishing) null else this
    }

    override fun release() {
        //暂时用不到该函数,日后扩展
    }
}

