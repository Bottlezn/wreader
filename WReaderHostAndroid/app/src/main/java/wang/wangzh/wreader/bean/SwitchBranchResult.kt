package wang.wangzh.wreader.bean

/**
 * @author  wangzh
 * @date  2020/2/24 15:43
 *
 */
class SwitchBranchResult(
    var result: String, var currentBranchShortName: String?,
    isClean: Int = 0,
    additionalInfo: String? = null
) : BaseGitResult(isClean, additionalInfo)