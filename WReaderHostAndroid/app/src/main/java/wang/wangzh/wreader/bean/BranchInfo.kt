package wang.wangzh.wreader.bean

/**
 * @author  wangzh
 * @date  2020/2/24 16:30
 * 从refs/remotes/origin/master或者refs/heads/origin/master格式中分解出用户选中的分支信息
 */
data class BranchInfo(
    val isRemote: Boolean?,
    val branchName: String,
    val remoteName: String?,
    var fromTag: Boolean = false
) {
    override fun toString(): String {
        return "BranchInfo(isRemote=$isRemote, branchName='$branchName', remoteName=$remoteName)"
    }
}