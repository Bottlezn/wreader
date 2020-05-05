package wang.wangzh.wreader.feature.flutter

import android.app.Activity
import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.core.widget.NestedScrollView
import wang.wangzh.wreader.R
import wang.wangzh.wreader.WReaderApp

/**
 * @author  wangzh
 * @date  2020/2/20 10:30
 *
 */
class MsgOutputConsole(aty: Activity) {

    private val strBuilder = StringBuilder()
    private var content: View?
    private var tvCloneDetails: TextView?
    private var nsvDetails: NestedScrollView?
    private var windowManager: WindowManager? = null
    private var lp: WindowManager.LayoutParams

    init {
        val layoutInflater = LayoutInflater.from(WReaderApp.getApp())
        content = layoutInflater.inflate(R.layout.layout_clone_details, null)
        nsvDetails = content?.findViewById(R.id.nsvCloneDetails)
        tvCloneDetails = content?.findViewById(R.id.tvCloneDetails)
        val height = (WReaderApp.getApp().resources.displayMetrics.heightPixels * 0.5).toInt()
        val width =
            WReaderApp.getApp().resources.displayMetrics.widthPixels - aty.resources.getDimensionPixelSize(
                R.dimen.px30
            ) * 2
        windowManager =
            WReaderApp.getApp().getSystemService(Context.WINDOW_SERVICE) as WindowManager
        lp = WindowManager.LayoutParams()
        lp.token = aty.window.decorView.windowToken
        lp.type = WindowManager.LayoutParams.TYPE_APPLICATION_PANEL
        lp.width = WReaderApp.getApp().resources.displayMetrics.widthPixels
        lp.height = WReaderApp.getApp().resources.displayMetrics.heightPixels
        lp.format = PixelFormat.RGBA_8888
        nsvDetails?.layoutParams?.height = height
        nsvDetails?.layoutParams?.width = width
        nsvDetails?.requestLayout()
    }

    fun replaceLastLine(text: String) {
        if (strBuilder.isNotBlank() && strBuilder.contains("\n")) {
            strBuilder.replace(strBuilder.lastIndexOf("\n") + 1, strBuilder.length, text)
            tvCloneDetails?.text = strBuilder.toString()
        } else {
            appendLine(text)
        }
    }

    fun appendLine(text: String) {
        if (strBuilder.isEmpty()) {
            strBuilder.append(text).append("\n")
        } else {
            strBuilder.append(text).append("\n")
        }
        tvCloneDetails?.text = strBuilder.toString()
        nsvDetails?.scrollTo(0, tvCloneDetails?.bottom ?: 0)
    }

    fun show() {
        windowManager?.addView(content, lp)
    }

    fun dismiss() {
        windowManager?.removeView(content)
    }

    fun release() {
        dismiss()
        windowManager = null
        content = null
        tvCloneDetails = null
        nsvDetails = null
    }


}