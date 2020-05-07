package wang.wangzh.wreader.feature

import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.view.Window
import androidx.core.view.postDelayed
import kotlinx.android.synthetic.main.aty_splash.*
import wang.wangzh.wreader.R
import wang.wangzh.wreader.WReaderApp
import wang.wangzh.wreader.base.BaseAty
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import wang.wangzh.wreader.db.FlutterModuleDbHelper
import wang.wangzh.wreader.feature.flutter.FlutterMainAty
import wang.wangzh.wreader.feature.flutter.SingleWorker
import wang.wangzh.wreader.utils.SystemLanguageHelper
import java.util.*
import kotlin.collections.HashMap

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
        SingleWorker.doSomething(Runnable {
            FlutterModuleDbHelper.getEnvironmentConf(this@SplashAty).let { conf ->
                this@SplashAty.runOnUiThread {
                    val languageCode: String? = conf[FlutterModuleDbConst.LANGUAGE_CODE] as String?
                    SystemLanguageHelper.switchLanguage(
                        this@SplashAty,
                        languageCode
                    )
                    Log.i("WTF", "languageCode = $languageCode")
                    Log.i(
                        "WTF",
                        "WReaderApp.deviceInitLocale?.language = ${WReaderApp.deviceInitLocale?.language}"
                    )
                    if (FlutterModuleDbConst.ZH_CN == languageCode || (languageCode.isNullOrBlank() && Locale.CHINA.language == WReaderApp.deviceInitLocale?.language)
                    ) {
                        tvSplash.text = "感谢使用 WReader \nauthor：悟笃笃"
                    } else {
                        tvSplash.text = "Thanks for using WReader\nauthor：悟笃笃"
                    }
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
        })
    }

    /**
     * 跳转到WReader的Flutter页面
     */
    private fun startReading(conf: HashMap<String, Any?>) {
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