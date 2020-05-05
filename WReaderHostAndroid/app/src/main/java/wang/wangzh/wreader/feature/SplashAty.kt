package wang.wangzh.wreader.feature

import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.view.Window
import androidx.core.view.postDelayed
import kotlinx.android.synthetic.main.aty_splash.*
import wang.wangzh.wreader.R
import wang.wangzh.wreader.base.BaseAty
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import wang.wangzh.wreader.db.FlutterModuleDbHelper
import wang.wangzh.wreader.feature.flutter.FlutterMainAty
import wang.wangzh.wreader.utils.SystemLanguageHelper

/**
 * 闪屏页
 */
class SplashAty : BaseAty() {

    companion object {
        /**
         * 闪屏页，800ms延迟
         */
        const val DELAY = 800L
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.aty_splash)
        val start = System.currentTimeMillis()
        Thread {
            FlutterModuleDbHelper.getEnvironmentConf(this@SplashAty).let { conf ->
                this@SplashAty.runOnUiThread {
                    SystemLanguageHelper.switchLanguage(
                        this@SplashAty,
                        conf[FlutterModuleDbConst.LANGUAGE_CODE] as String?
                    )
                    tvSplash.visibility = View.VISIBLE
                    val delta = System.currentTimeMillis() - start
                    if (delta >= DELAY) {
                        startReading(conf)
                    } else {
                        tvSplash.postDelayed(DELAY - delta) {
                            if (!this@SplashAty.isFinishing) {
                                startReading(conf)
                            }
                        }
                    }
                }
            }
        }.start()
    }

    /**
     * 跳转到WReader的Flutter页面
     */
    private fun startReading(conf: HashMap<String, Any?>) {
        Log.i(
            "AndroidSplash",
            "conf[FlutterInitializedKey.BRIGHTNESS_MODE] = ${conf[FlutterModuleDbConst.BRIGHTNESS_MODE]}"
        )
        Log.w(
            "AndroidSplash",
            "conf[FlutterInitializedKey.LANGUAGE_CODE] = ${conf[FlutterModuleDbConst.LANGUAGE_CODE]}"
        )
        FlutterMainAty.startReading(
            this@SplashAty,
            conf[FlutterModuleDbConst.BRIGHTNESS_MODE] as? Int?,
            conf[FlutterModuleDbConst.LANGUAGE_CODE] as? String?
        )
        finish()
    }

    /**
     * 屏蔽闪屏页的返回按键事件
     */
    override fun onKeyDown(keyCode: Int, event: KeyEvent?) = if (keyCode == KeyEvent.KEYCODE_BACK) {
        true
    } else super.onKeyDown(keyCode, event)
}