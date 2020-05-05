package wang.wangzh.wreader.bean

/**
 * @author  wangzh
 * @date  2020/2/26 9:32
 * 重置分支结果
 * @param result fail 失败，success成功
 * @param reason 失败原因，成功时为null
 */
class ResetResult(val result: String, val reason: String? = null)