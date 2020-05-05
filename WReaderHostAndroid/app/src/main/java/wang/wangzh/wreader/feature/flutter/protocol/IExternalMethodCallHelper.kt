package wang.wangzh.wreader.feature.flutter.protocol

import android.Manifest
import android.app.Activity

/**
 * description : 声明了一个扩展 [wang.wangzh.wreader.feature.flutter.WReaderMethodCallHandler] 功能的接口
 * Created on 2020/5/4.
 * @author 悟笃笃
 */
interface IExternalMethodCallHelper {
    fun applyExternalStoragePermission(
        callback: ApplyStorageCallback?,
        permission: String = Manifest.permission.WRITE_EXTERNAL_STORAGE
    )

    /**
     * 是否可以继续,如果不可以继续返回 null
     */
    fun canNext(): Activity?

    /**
     * 销毁
     */
    fun release()
}

/**
 * 申请读或写外部存储的回调
 */
interface ApplyStorageCallback {
    fun callback(applyResult: Boolean)
}