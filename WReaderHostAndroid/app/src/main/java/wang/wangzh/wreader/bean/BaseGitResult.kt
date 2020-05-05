package wang.wangzh.wreader.bean

/**
 * @author  wangzh
 * @date  2020/2/25 17:18
 * git操作的基类，会携带git仓库的status信息，因为WReader不支持编辑功能，当仓库文件发生改变，需要
 * 提示用户回滚当前分支或者不做出任何改变
 * @param isClean 1，表示不clean，0表示clean
 * @param additionalInfo 附加信息，当isClean为1时，可以带过来被更改的文件信息
 */
open class BaseGitResult(var isClean: Int = 0, var additionalInfo: String? = null)