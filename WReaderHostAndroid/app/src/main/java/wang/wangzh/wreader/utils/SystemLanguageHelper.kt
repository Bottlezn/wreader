package wang.wangzh.wreader.utils

import android.content.Context
import android.os.Build
import android.os.LocaleList
import android.util.Log
import wang.wangzh.wreader.WReaderApp
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import java.util.*

/**
 * Description : 帮助修改系统语言
 * @author : wangzhanhong
 * @Date : 2020/4/8 14:23
 */
object SystemLanguageHelper {

    private const val TAG = "SystemLanguageHelper"

    fun getLocaleCode(locale: Locale): String {
        return "${locale.language}${if (locale.country.isNullOrBlank()) {
            ""
        } else "_${locale.country}"
        }"
    }

    fun switchLanguage(context: Context, code: String?): Context {
        val conf = context.resources.configuration
        val defaultLocal = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.resources.configuration.locales.get(0)
        } else {
            context.resources.configuration.locale
        }
        Log.i(TAG, "code = $code")
        Log.i(TAG, "defaultLocal = ${getLocaleCode(defaultLocal)}")
        //当前环境中根据用户上次选择的语言选项
        val currentLocale = WReaderApp.deviceInitLocale ?: defaultLocal
        val selectLocale: Locale =
            if (FlutterModuleDbConst.EN_US == code) {
                Locale.US
            } else if (FlutterModuleDbConst.ZH_CN == code) {
                Locale.SIMPLIFIED_CHINESE
            } else {
                //code 为空，跟随系统，不需要修改
                if (FlutterModuleDbConst.ZH_CN == getLocaleCode(currentLocale)) {
                    Locale.SIMPLIFIED_CHINESE
                } else {
                    Locale.US
                }
            }
        Log.i(TAG, "currentLocale = ${getLocaleCode(currentLocale)}")
        Log.i(TAG, "selectLocale = ${getLocaleCode(selectLocale)}")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val localeList = LocaleList.forLanguageTags(getLocaleCode(selectLocale))
            LocaleList.setDefault(localeList)
//            conf.locales = localeList
//            conf.locales.
        } else {
            conf.locale = selectLocale
        }
        WReaderApp.currentLocal = selectLocale
        conf.locale = selectLocale
        conf.setLocale(selectLocale)
        val wrapper = context.createConfigurationContext(conf)
        wrapper.resources.updateConfiguration(conf, context.resources.displayMetrics)
        if (context !is WReaderApp) {
            switchLanguage(WReaderApp.getApp(), code)
        }
        return wrapper
    }

}