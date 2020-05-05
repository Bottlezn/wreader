package wang.wangzh.wreader.widget

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.webkit.WebView

/**
 * 为了监听滚动与右下划退出手势
 * @author : wangzhanhong
 * @Date : 2020/3/26 15:54
 * @Description :
 */
class ReadingWebView(context: Context, attrs: AttributeSet) : WebView(context, attrs) {

    companion object {
        private const val TAG = "ReadingWebView"
        /**
         * [VALID_TIME]毫秒内的右下快滑手势都认为是退出手势
         */
        private const val VALID_TIME = 350

    }

    var scrollChangeCallback: ScrollChangeCallback? = null
    var rightAndBottomMotionCallback: RightAndBottomMotionCallback? = null

    /**
     * 右划有效计算值
     */
    private var rightValidDelta: Int = 300

    /**
     * 下划有效计算值
     */
    private var downValidDelta: Int = 300

    /**
     * 在down时记录时间戳
     */
    private var timestampTmp = System.currentTimeMillis()

    /**
     * move一开始时触碰的x值。在cancel时计算偏移量，
     */
    private var initializedMoveX: Float = -1f
    /**
     * move一开始时触碰的Y值，在cancel时计算偏移量，
     */
    private var initializedMoveY: Float = -1f

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        super.onLayout(changed, l, t, r, b)
        //右下划手势根据屏幕旋转一定比例计算右下划阈值
        if (measuredWidth <= measuredHeight) {
            //竖屏情况下的阈值
            rightValidDelta = (measuredWidth * 0.3f).toInt()
            downValidDelta = (measuredHeight * 0.2f).toInt()
        } else {
            //横屏情况下的阈值
            rightValidDelta = (measuredWidth * 0.15f).toInt()
            downValidDelta = (measuredHeight * 0.3f).toInt()
        }
    }

    /**
     * 滚动变化
     */
    override fun onScrollChanged(l: Int, t: Int, oldl: Int, oldt: Int) {
        super.onScrollChanged(l, t, oldl, oldt)
        scrollChangeCallback?.onScrollChanged(l, t, l - oldl, t - oldt)
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        event?.let {
            //计算move之后的cancel手势偏移量，符合右下快滑阈值就调用回调函数
            when (event.action) {
                MotionEvent.ACTION_UP -> {
                    if (System.currentTimeMillis() - timestampTmp < VALID_TIME &&
                        event.rawX - initializedMoveX > rightValidDelta &&
                        event.rawY - initializedMoveY > downValidDelta
                    ) {
                        //从触碰到cancel手势，是否[VALID_TIME]毫秒内
                        rightAndBottomMotionCallback?.doSomething()
                    }
                    timestampTmp = System.currentTimeMillis()
                    initializedMoveX = -1f
                    initializedMoveY = -1f
                }
                MotionEvent.ACTION_MOVE -> {
                    if (initializedMoveX == -1f && initializedMoveY == -1f) {
                        timestampTmp = System.currentTimeMillis()
                        initializedMoveX = event.rawX
                        initializedMoveY = event.rawY
                    }
                }
            }
        }
        return super.onTouchEvent(event)
    }

    /**
     * 滚动回调
     */
    interface ScrollChangeCallback {
        fun onScrollChanged(x: Int, y: Int, xDelta: Int, yDelta: Int)
    }

    /**
     * 右下划手势回调
     */
    interface RightAndBottomMotionCallback {
        fun doSomething()
    }
}