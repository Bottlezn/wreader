package wang.wangzh.wreader.utils

import android.os.Handler
import android.os.Looper

/**
 * @author  wangzh
 * @date  2020/2/17 9:52
 *
 */
object MainHandler {

    private val handler = Handler(Looper.getMainLooper())

    @JvmStatic
    fun runOnMain(runnable: Runnable) {
        handler.post(runnable)
    }

    /**
     * 慎用
     */
    @JvmStatic
    fun runDelay(delay: Long, runnable: Runnable) {
        handler.postDelayed(runnable, delay)
    }
}