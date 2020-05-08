package wang.wangzh.wreader.feature.flutter

import java.util.concurrent.Executors

/**
 * 创建一只公作为[WReaderMethodCallHandler]的工作线程，因为WReader的任务不存在大量堆叠，
 * 所以不需要重写拒绝策略等措施
 * @author : wangzhanhong
 * @Date : 2020/3/27 14:25
 */
internal object Poor996Worker {

    private val worker = Executors.newSingleThreadExecutor()

    /**
     * work work work
     */
    @JvmStatic
    fun doSomething(runnable: Runnable) {
        worker.submit(runnable)
    }
}