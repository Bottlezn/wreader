package wang.wangzh.wreader.bean

/**
 * @author  wangzh
 * @date  2020/2/25 16:02
 *@param result fail失败，success成功
 * @param reason result false的理由
 */
class PullResult(
    var result: String, var reason: String?,
    isClean: Int = 0,
    additionalInfo: String? = null
) : BaseGitResult(isClean, additionalInfo) {
    override fun toString(): String {
        return "PullResult(result='$result', reason=$reason)"
    }
}