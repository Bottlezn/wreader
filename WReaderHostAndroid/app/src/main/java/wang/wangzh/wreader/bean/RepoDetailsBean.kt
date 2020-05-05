package wang.wangzh.wreader.bean

/**
 * @author  wangzh
 * @date  2020/2/24 15:31
 * 仓库详细信息
 *
 */
class RepoDetailsBean {

    var id: Int? = null
    var gitUri: String? = null
    var currentBranch: String? = null
    var fullDir: String? = null
    var targetDir: String? = null
    var rootDir: String? = null
    var allBranch: List<String>? = null
    var authenticationInfo: String? = null
    var authenticationWay: Int? = null

    override fun toString(): String {
        return "RepoDetailsBean(id=$id, gitUri=$gitUri, currentBranch=$currentBranch, fullDir=$fullDir, targetDir=$targetDir, rootDir=$rootDir, allBranch=$allBranch, authenticationInfo=$authenticationInfo, authenticationWay=$authenticationWay)"
    }

}