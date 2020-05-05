package wang.wangzh.wreader.utils

import android.content.Context
import wang.wangzh.wreader.WReaderApp
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import java.util.*

/**
 * Description : 帮助修改系统语言
 * @author : wangzhanhong
 * @Date : 2020/4/8 14:23
 */
object SystemLanguageHelper {

    fun switchLanguage(context: Context, code: String?) {
        val conf = context.resources.configuration
        val country = WReaderApp.initLocalCode ?: Locale.getDefault().country
        if (code == null || FlutterModuleDbConst.FOLLOW_SYSTEM == code) {
            //跟随系统，不需要修改
            if ("CN" == country) {
                conf.setLocale(Locale.SIMPLIFIED_CHINESE)
            } else {
                conf.setLocale(Locale.ENGLISH)
            }
        } else if (FlutterModuleDbConst.EN_US == code) {
            conf.setLocale(Locale.ENGLISH)
        } else if (FlutterModuleDbConst.ZH_CN == code) {
            conf.setLocale(Locale.SIMPLIFIED_CHINESE)
        } else {
            //跟随系统，不需要修改
            if ("CN" == country) {
                conf.setLocale(Locale.SIMPLIFIED_CHINESE)
            } else {
                conf.setLocale(Locale.ENGLISH)
            }
        }
    }

}