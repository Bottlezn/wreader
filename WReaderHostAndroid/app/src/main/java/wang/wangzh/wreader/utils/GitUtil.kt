package wang.wangzh.wreader.utils

import android.util.Log
import com.jcraft.jsch.JSch
import com.jcraft.jsch.Session
import org.eclipse.jgit.api.*
import org.eclipse.jgit.lib.ProgressMonitor
import org.eclipse.jgit.lib.Ref
import org.eclipse.jgit.transport.*
import org.eclipse.jgit.util.FS
import wang.wangzh.wreader.WReaderApp
import wang.wangzh.wreader.bean.*
import wang.wangzh.wreader.bean.PullResult
import wang.wangzh.wreader.feature.flutter.WReaderMethodCallHandler
import java.io.File
import java.lang.Exception
import java.lang.IllegalArgumentException
import java.util.regex.Pattern


/**
 * @author  wangzh
 * @date  2020/2/14 15:06
 * * 参考文章：
 * - [JGit Authentication JGit验证机制](https://blog.csdn.net/gloomy_114/article/details/53117578)
 * - [Pro Git 简体中文第二版 (Pro Git 2(zh))](https://cntofu.com/book/39/_jgit.html)
 */
object GitUtil {

    private const val KEY_PAIR_ROOT = "keys"
    private const val TAG = "GitUtil"
    private const val NOT_CLEAN_HINT =
        "STATUS was not clean,WReader dose not support edit operation!\nPlease choose reset current branch or cancel this operation!"
    private const val TAG_PREFIX = "fromTag/"
    private const val BRANCH_PREFIX = "fromBranch/"

    @Deprecated("暂时不支持")
    fun cloneDirect(
        uri: String,
        localPath: String,
        localRepoName: String,
        callback: CloneCommand.Callback?,
        monitor: ProgressMonitor?
    ): Git? {
        val saveDir = File(localPath, localRepoName)
        if (!saveDir.exists() && !saveDir.mkdirs()) {
            return null
        }
        //设置clone文件的存放地址
        return Git.cloneRepository().setBare(false).setCloneAllBranches(true).setDirectory(saveDir)
            .setProgressMonitor(monitor).setTransportConfigCallback {
                Log.e(TAG, "it  = ${it.javaClass.name}")
                if (it is TransportGitSsh) {
                    (it as TransportGitSsh).sshSessionFactory =
                        object : JschConfigSessionFactory() {
                            override fun configure(hc: OpenSshConfig.Host, session: Session) {
                                //关闭严格模式，未知host照样使用
                                session.setConfig(
                                    SshConstants.STRICT_HOST_KEY_CHECKING,
                                    SshConstants.NO
                                )
                                session.setConfig(
                                    SshConstants.USER_KNOWN_HOSTS_FILE,
                                    SshConstants.YES
                                )
                                session.setConfig(SshConstants.PREFERRED_AUTHENTICATIONS, "null")
                                session.setPassword("")
                                Log.e(TAG, "hc  = $hc")
                                hc.preferredAuthentications
                                Log.e(TAG, "session  = $session")
                            }
                        }
                }
            }
            .setURI(uri).setCredentialsProvider(UsernamePasswordCredentialsProvider("", ""))
            .setCallback(callback).call()
    }

    fun getTagList(
        fullDir: String
    ): List<Ref>? {
        return try {
            val git = Git.open(File(fullDir))
            val tagListCommand = git.tagList()
            tagListCommand.call()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private val tagRegex = Pattern.compile("^refs/tags/(.*?)\$")
    private val remoteBranchRegex = Pattern.compile("^refs/remotes/.*?/(.*?)\$")
    private val localBranchRegex = Pattern.compile("^refs/heads/(.*?)\$")

    /**
     * checkout 指定tag到一个到本地指定分支,名称固定为 "$TAG_PREFIX/$specificTagName"
     * @param specificTagName [Ref.getName]
     */
    fun checkoutTag(
        specificTagName: String,
        bean: RepoDetailsBean,
        monitor: ProgressMonitor?
    ): String? {
        Log.i(WReaderMethodCallHandler.TAG, "specificTagName = $specificTagName")
        val git = Git.open(File(bean.fullDir))
        val matcher = tagRegex.matcher(specificTagName)
        if (matcher.find() && matcher.groupCount() > 0) {
            val localTagBranch = "$TAG_PREFIX${matcher.group(1)}"
            //本地分支检出在 Flutter 端已经被拦截了,这里不需要考虑.从服务器检出 到 localTagBranch 中
            git.checkout().setCreateBranch(true).setName(localTagBranch)
                //设置本地显示名称
                .setStartPoint(specificTagName).setProgressMonitor(monitor)
                .call()
            git.close()
            return "refs/heads/$localTagBranch"
        } else {
            throw IllegalArgumentException("unknown tag name format.")
        }
    }

    /**
     * 配置访问remote需要的鉴权信息
     */
    private fun configAuthenticationInfo(
        command: TransportCommand<*, *>,
        bean: RepoDetailsBean
    ) {
        if (2 == bean.authenticationWay) {
            //密钥对鉴权
            val keyPairInfo = GsonUtil.json2bean<KeyPairInfo>(
                bean.authenticationInfo,
                KeyPairInfo::class.java
            )
            command.setTransportConfigCallback { transport ->
                if (transport is SshTransport) {
                    transport.sshSessionFactory =
                        createKeyPairFile(
                            bean.targetDir!!,
                            keyPairInfo.priKey,
                            keyPairInfo.pubKey,
                            keyPairInfo.priKeyPass
                        )
                }
            }
        } else if (1 == bean.authenticationWay) {
            //账号密码鉴权
            val accountPwdInfo = GsonUtil.json2bean<AccountPwdInfo>(
                bean.authenticationInfo,
                AccountPwdInfo::class.java
            )
            command.setCredentialsProvider(
                UsernamePasswordCredentialsProvider(
                    accountPwdInfo.account,
                    accountPwdInfo.pwd
                )
            )
            command.setTransportConfigCallback {
                handleTransportUsePwd(
                    it,
                    accountPwdInfo.account,
                    accountPwdInfo.pwd
                )
            }
        }
    }


    /**
     * fetch
     */
    fun fetch(bean: RepoDetailsBean, progressMonitor: ProgressMonitor? = null) {
        bean.fullDir?.let { fullDir ->
            val git = Git.open(File(fullDir))
            val fetchCommand = git.fetch().setProgressMonitor(progressMonitor)
            configAuthenticationInfo(
                fetchCommand,
                bean
            )
            fetchCommand.call()
            git.close()
        }
    }

    /**
     * 回滚当前分支
     */
    fun resetBranch(bean: RepoDetailsBean, progressMonitor: ProgressMonitor? = null) {
        bean.fullDir?.let { fullDir ->
            val git = Git.open(File(fullDir))
            for (ref in git.repository.refDatabase.refs) {
                Log.w(TAG, ref.javaClass.simpleName)
                Log.w(TAG, ref.toString())
            }
            git.reset().setMode(ResetCommand.ResetType.HARD).setProgressMonitor(progressMonitor)
                .call()
            git.close()
        }
    }

    /**
     * 使用账号密码clone
     * String gitUrl, String localPath，String repoName,String account,String pwd
     */
    fun cloneUseAccountAndPwd(
        uri: String,
        localPath: String,
        localRepoName: String,
        account: String,
        pwd: String,
        callback: CloneCommand.Callback?,
        monitor: ProgressMonitor?
    ): Git? {
        val saveDir = File(localPath, localRepoName)
        if (!saveDir.exists() && !saveDir.mkdirs()) {
            return null
        }
        //设置clone文件的存放地址
        val git =
            Git.cloneRepository().setBare(false).setCloneAllBranches(true).setDirectory(saveDir)
                .setProgressMonitor(monitor).setTransportConfigCallback {
                    handleTransportUsePwd(
                        it,
                        account,
                        pwd
                    )
                }
                .setURI(uri)
                .setCredentialsProvider(UsernamePasswordCredentialsProvider(account, pwd))
                .setCallback(callback).call()
        //将 master 分支的名称修改为 "${BRANCH_PREFIX}master"
        git.branchRename().setOldName("refs/heads/master").setNewName("${BRANCH_PREFIX}master")
            .call()
        return git
    }

    /**
     * pull当前分支，会检查一下代码状态滴
     */
    fun pull(
        bean: RepoDetailsBean,
        pullMonitor: ProgressMonitor?
    ): PullResult {
        try {
            bean.fullDir?.let { fullDir ->
                val git = Git.open(File(fullDir))
                val status = git.status().call()
                if (!status.isClean) {
                    //仓库中有文件被修改，阅读器不支持修改功能，提示报错
                    git.close()
                    return PullResult(
                        "fail",
                        NOT_CLEAN_HINT,
                        1,
                        NOT_CLEAN_HINT
                    )
                }
                createPullCommand(
                    bean,
                    git,
                    pullMonitor
                ).call()
                return PullResult("success", "")
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return PullResult("fail", e.toString())
        }
        return PullResult("fail", "unknown error!")
    }

    /**
     * 提取一个公用的pullCommand
     */
    private fun createPullCommand(
        bean: RepoDetailsBean,
        git: Git,
        pullMonitor: ProgressMonitor?
    ): PullCommand {
        val pullCommand = git.pull()
            .setProgressMonitor(pullMonitor)
        configAuthenticationInfo(
            pullCommand,
            bean
        )
        return pullCommand
    }

    /**
     * 切换分支，需要传入checkout与pull的监视器
     */
    fun switchExistedBranch(
        fullBranchName: String,
        bean: RepoDetailsBean,
        checkoutMonitor: ProgressMonitor?
    ): SwitchBranchResult {
        bean.fullDir?.let { fullDir ->
            val git = Git.open(File(fullDir))
            val status = git.status().call()
            if (!status.isClean) {
                //仓库中有文件被修改，阅读器不支持修改功能，提示报错
                git.close()
                return SwitchBranchResult(
                    "fail",
                    null,
                    1,
                    NOT_CLEAN_HINT
                )
            }
            val matcher = localBranchRegex.matcher(fullBranchName)
            if (matcher.find() && matcher.groupCount() > 0) {
                val shortName = matcher.group(1)
                //本地仍未绑定该仓库，checkout下来，并且和远程仓库建立关系
                Log.i(TAG, "BRANCH_PREFIX+shortName = ${BRANCH_PREFIX}$shortName")
                git.checkout().setCreateBranch(false)
                    .setName(shortName)
                    .setProgressMonitor(checkoutMonitor)
                    .call()
                git.close()
                return SwitchBranchResult("success", fullBranchName)
            }
        }
        return SwitchBranchResult("fail", null)
    }

    /**
     * 切换分支，需要传入checkout与pull的监视器
     */
    fun switchNewBranch(
        fullBranchName: String,
        bean: RepoDetailsBean,
        checkoutMonitor: ProgressMonitor?
    ): SwitchBranchResult {
        bean.fullDir?.let { fullDir ->
            val git = Git.open(File(fullDir))
            val status = git.status().call()
            if (!status.isClean) {
                //仓库中有文件被修改，阅读器不支持修改功能，提示报错
                git.close()
                return SwitchBranchResult(
                    "fail",
                    null,
                    1,
                    NOT_CLEAN_HINT
                )
            }
            val matcher = remoteBranchRegex.matcher(fullBranchName)
            if (matcher.find() && matcher.groupCount() > 0) {
                val shortName = matcher.group(1)
                //本地仍未绑定该仓库，checkout下来，并且和远程仓库建立关系
                Log.i(TAG, "${BRANCH_PREFIX}$shortName")
                git.checkout().setCreateBranch(true)
                    .setName("${BRANCH_PREFIX}$shortName")
                    .setUpstreamMode(CreateBranchCommand.SetupUpstreamMode.SET_UPSTREAM)
                    .setStartPoint(fullBranchName).setProgressMonitor(checkoutMonitor)
                    .setProgressMonitor(checkoutMonitor)
                    .call()
                git.close()
                return SwitchBranchResult("success", "refs/heads/${BRANCH_PREFIX}$shortName")
            }

        }

        return SwitchBranchResult("fail", null)
    }

    /**
     * 配置使用账号密码clone的Transport
     */
    private fun handleTransportUsePwd(trans: Transport, account: String, pwd: String) {
        if (trans is SshTransport) {
            trans.sshSessionFactory = object : JschConfigSessionFactory() {
                override fun configure(hc: OpenSshConfig.Host, session: Session) {
                    //关闭严格模式，未知host照样使用
                    session.setConfig(
                        SshConstants.STRICT_HOST_KEY_CHECKING,
                        SshConstants.NO
                    )
                    session.setConfig(SshConstants.USER_KNOWN_HOSTS_FILE, SshConstants.YES)
                }
            }
        } else if (trans is TransportHttp) {
            trans.credentialsProvider = UsernamePasswordCredentialsProvider(account, pwd)
        }
    }

    /**
     * 创建一对本地密钥对
     */
    private fun createPriKey(
        localRepoName: String,
        privateKey: String,
        pubKey: String
    ): Array<String> {
        val rootPath =
            File("${WReaderApp.getApp().filesDir.absolutePath}${File.separator}$KEY_PAIR_ROOT${File.separator}$localRepoName")
        Log.w(TAG, "rootPath.absolutePath = ${rootPath.absolutePath}")
        if (!rootPath.exists()) {
            Log.w(TAG, "rootPath.mkdirs() = ${rootPath.mkdirs()}")
        }
        val priFile = File(rootPath, "${localRepoName}_rsa")
        val pubFile = File(rootPath, "${localRepoName}_rsa.pub")
        if (priFile.exists()) {
            priFile.delete()
        }
        if (pubFile.exists()) {
            pubFile.delete()
        }
        Log.w(TAG, "priFile.absolutePath = ${priFile.absolutePath}")
        Log.w(TAG, "pubFile.absolutePath = ${pubFile.absolutePath}")
        Log.w(TAG, "priFile.createNewFile() = ${priFile.createNewFile()}")
        Log.w(TAG, "pubFile.createNewFile() = ${pubFile.createNewFile()}")
        priFile.writeText(privateKey, Charsets.UTF_8)
        pubFile.writeText(pubKey, Charsets.UTF_8)
        return arrayOf(priFile.absolutePath, pubFile.absolutePath)
    }

    /**
     * 创建密钥对
     */
    private fun createKeyPairFile(
        localRepoName: String,
        privateKey: String,
        pubKey: String,
        password: String?
    ) = object : JschConfigSessionFactory() {
        override fun configure(host: OpenSshConfig.Host, session: Session) {
            //关闭严格模式，未知host照样使用
            session.setConfig("StrictHostKeyChecking", "no")
        }

        override fun createDefaultJSch(fs: FS?): JSch {
            val defaultJsch = super.createDefaultJSch(fs)
            val arrays = createPriKey(
                localRepoName,
                privateKey,
                pubKey
            )
            defaultJsch.addIdentity(
                arrays[0],
                arrays[1],
                if (password.isNullOrBlank()) null else password.toByteArray()
            )
            return defaultJsch
        }
    }

    /**
     * 需要传入的参数有
     * 1、 git路径
     * 2、 本地路径
     * 3、 私钥字符串，程序会将其处理成文件
     * 4、 公钥字符串，程序会将其处理成文件
     * 5、 私钥密码，如果没有密码给null就好了
     * 6、 clone的回调
     * String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
     */
    fun cloneRespUsePriKey(
        uri: String,
        localPath: String,
        localRepoName: String,
        privateKey: String,
        pubKey: String,
        password: String?,
        callback: CloneCommand.Callback?,
        monitor: ProgressMonitor?
    ): Git? {
        Log.d(TAG, "password = [$password]")
        val saveDir = File(localPath, localRepoName)
        if (!saveDir.exists() && !saveDir.mkdirs()) {
            return null
        }
        //设置clone文件的存放地址
        val clone = Git.cloneRepository()
        clone.setDirectory(saveDir).setURI(uri).setProgressMonitor(monitor)
            .setCloneAllBranches(true).setBare(false).setCallback(callback)
            .setTransportConfigCallback { transport ->
                if (transport is SshTransport) {
                    transport.sshSessionFactory =
                        createKeyPairFile(
                            localRepoName,
                            privateKey,
                            pubKey,
                            password
                        )
                }
            }
        val git = clone.call()
        //将 master 分支的名称修改为 "${BRANCH_PREFIX}master"
        git.branchRename().setOldName("refs/heads/master").setNewName("${BRANCH_PREFIX}master")
            .call()
        return git
    }

}