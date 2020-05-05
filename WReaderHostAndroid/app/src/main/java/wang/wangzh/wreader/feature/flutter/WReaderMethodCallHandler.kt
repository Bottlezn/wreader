package wang.wangzh.wreader.feature.flutter

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.eclipse.jgit.api.CloneCommand
import org.eclipse.jgit.api.Git
import org.eclipse.jgit.api.ListBranchCommand
import org.eclipse.jgit.lib.AnyObjectId
import org.eclipse.jgit.lib.ProgressMonitor
import org.json.JSONObject
import wang.wangzh.wreader.R
import wang.wangzh.wreader.WReaderApp
import wang.wangzh.wreader.bean.*
import wang.wangzh.wreader.consts.ChannelIncomingMethod
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import wang.wangzh.wreader.db.FlutterModuleDbHelper
import wang.wangzh.wreader.feature.flutter.protocol.ApplyStorageCallback
import wang.wangzh.wreader.feature.flutter.protocol.IExternalMethodCallHelper
import wang.wangzh.wreader.feature.image.BrowseImageAty
import wang.wangzh.wreader.feature.reader.MdReaderActivity
import wang.wangzh.wreader.utils.*
import java.io.File
import kotlin.system.exitProcess

/**
 * @author  wangzh
 * @date  2020/2/20 9:28
 * wreader module 的methodHandler
 */
class WReaderMethodCallHandler(private var externalHelper: IExternalMethodCallHelper?) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val DIR_NAME = "WReader"
        const val TAG = "WReaderMCHandler"
        const val GET_GIT_CONF_FILE = 421
    }

    private var tmpCall: MethodCall? = null
    private var tmpResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.e(TAG, "call.method = ${call.method}")
        when (call.method) {
            ChannelIncomingMethod.GET_GIT_ROOT_PATH -> getGitLocalRootPath(result)
//            ChannelIncomingMethod.CLONE_DIRECT -> cloneDirect(call, result)
            ChannelIncomingMethod.CLONE_USE_ACCOUNT_AND_PWD -> cloneUseAccountAndPwd(call, result)
            ChannelIncomingMethod.CLONE_USE_KEY_PAIR -> cloneUseKeyPair(call, result)
            ChannelIncomingMethod.SWITCH_NEW_BRANCH -> switchNewBranch(call, result)
            ChannelIncomingMethod.SWITCH_EXISTED_BRANCH -> switchExistedBranch(call, result)
            ChannelIncomingMethod.PULL -> pull(call, result)
            ChannelIncomingMethod.RESET -> reset(call, result)
            ChannelIncomingMethod.FETCH -> fetch(call, result)
            ChannelIncomingMethod.GET_ALL_BRANCH -> getAllBranchInfo(call, result)
            ChannelIncomingMethod.CHECK_GIT_EXISTS -> checkGitRepoExists(call, result)
            ChannelIncomingMethod.GET_GIT_REPO_CONFIG_FILE -> getGitConfFile(call, result)
            ChannelIncomingMethod.SHOW_TOAST -> showToast(call, result)
            ChannelIncomingMethod.READ_CODE_FILE,
            ChannelIncomingMethod.READ_MD_FILE -> readTextFile(call, result)
            ChannelIncomingMethod.BROWSE_IMAGE -> browseImage(call, result)
            ChannelIncomingMethod.OPEN_FILE_USE_OTHER_APP -> openFileUseOtherApp(call, result)
            ChannelIncomingMethod.CLEAR_INVALID_REPO -> cleaInvalidRepo(call, result)
            ChannelIncomingMethod.CLEAR_SPECIFIED_REPO -> cleanSpecifiedRepo(call, result)
            ChannelIncomingMethod.GOTO_HOME -> gotoHome(result)
            ChannelIncomingMethod.GET_VERSION_INFO -> getVersionInfo(result)
            ChannelIncomingMethod.REPORT_FLUTTER_ERROR -> catchError(call, result)
            ChannelIncomingMethod.SWITCH_LANGUAGE -> switchLanguage(call, result)
            ChannelIncomingMethod.GET_LOG_DIR -> getLogDir(result)
            ChannelIncomingMethod.EXIT_APP -> exitApp()
            ChannelIncomingMethod.GET_EXPORT_EXTERNAL_PATH -> getExportExternalPath(result)
            ChannelIncomingMethod.GET_TAG_LIST -> getTagList(call, result)
            ChannelIncomingMethod.CHECK_OUT_TAG -> checkoutTag(call, result)
            ChannelIncomingMethod.OPEN_URL -> jumpOtherWebSite(call.arguments as String, result)
            else -> result.success("method not implemented!")
        }
    }

    /**
     * 跳转到其他 URL
     */
    private fun jumpOtherWebSite(url: String, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                val uriIntent = Intent()
                uriIntent.action = Intent.ACTION_VIEW
                val uri = Uri.parse(url)
                uriIntent.data = uri
                aty.startActivity(uriIntent)
                result.success("")
            }
        }
    }

    private fun switchExistedBranch(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                SingleWorker.doSomething(Runnable {
                    try {
                        Log.w(TAG, call.arguments as String)
                        val obj = JSONObject(call.arguments as String)
                        val realFullBranchName = obj.optString("branchFullName")
                        Log.e(TAG, "realFullBranchName = $realFullBranchName")
                        val fullBranchName =
                            if (realFullBranchName.contains("\n")) realFullBranchName.substring(
                                0,
                                realFullBranchName.indexOf("\n")
                            ) else realFullBranchName
                        Log.w(TAG, "fullBranchName = $fullBranchName")
                        val bean = GsonUtil.json2bean<RepoDetailsBean>(
                            obj.optString("repoDetails"),
                            RepoDetailsBean::class.java
                        )
                        GitUtil.switchExistedBranch(
                            fullBranchName, bean,
                            obtainProgressMonitor("Begin checkout branch.")
                        ).let { info ->

                            MainHandler.runOnMain(Runnable {
                                result.success(GsonUtil.bean2json(info))
                            })
                            return@Runnable
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        MainHandler.runOnMain(Runnable {
                            result.success(
                                GsonUtil.bean2json(
                                    SwitchBranchResult("fail", null)
                                )
                            )
                        })
                        return@Runnable
                    } finally {
                        releaseConsole()
                    }
                })
            }
        }
    }

    private fun checkoutTag(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                SingleWorker.doSomething(Runnable {
                    call.arguments?.let { arg ->
                        Log.w(TAG, "arg$arg")
                        val obj = JSONObject(arg as String)
                        val realFullBranchName = obj.optString("fullTagName")
                        Log.i(TAG, "realFullBranchName = $realFullBranchName")
                        val bean = GsonUtil.json2bean<RepoDetailsBean>(
                            obj.optString("repoDetails"),
                            RepoDetailsBean::class.java
                        )
                        try {
                            GitUtil.checkoutTag(
                                realFullBranchName,
                                bean,
                                obtainProgressMonitor("Begin checkout tag :$realFullBranchName")
                            )?.let { branch ->
                                MainHandler.runOnMain(Runnable {
                                    result.success(
                                        GsonUtil.bean2json(
                                            SwitchBranchResult("success", branch)
                                        )
                                    )
                                })
                            } ?: kotlin.run {
                                MainHandler.runOnMain(Runnable {
                                    GsonUtil.bean2json(
                                        SwitchBranchResult("fail", null)
                                    )
                                })
                            }

                        } catch (e: java.lang.Exception) {
                            e.printStackTrace()
                            MainHandler.runOnMain(Runnable {
                                GsonUtil.bean2json(
                                    SwitchBranchResult("fail", null, additionalInfo = e.message)
                                )
                            })
                        } finally {
                            releaseConsole()
                        }
                    }
                })
            }
        }
    }

    private fun getTagList(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                SingleWorker.doSomething(Runnable {
                    call.arguments?.let { arg ->
                        val obj = JSONObject((arg as String))
                        val gitRepoLocalDir = obj.optString("gitRepoLocalDir")
                        val refs = GitUtil.getTagList(gitRepoLocalDir)
                        val list = ArrayList<String>()
                        refs?.forEach {
                            list.add(it.name)
                        }
                        MainHandler.runOnMain(Runnable {
                            result.success(GsonUtil.bean2json(AllTagResult("success", list)))
                        })
                        return@Runnable
                    }
                    MainHandler.runOnMain(Runnable {
                        result.success(GsonUtil.bean2json(AllTagResult("fail", null)))
                    })
                })
            }
        }
    }

    /**
     * 获取导出文件的存放地址
     */
    private fun getExportExternalPath(result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                if (PackageManager.PERMISSION_GRANTED == ActivityCompat.checkSelfPermission(
                        aty,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                    )
                ) {
                    if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
                        val root =
                            File("${Environment.getExternalStorageDirectory().absolutePath}${File.separator}${DIR_NAME}")
                        if (!root.exists()) {
                            if (!root.mkdirs()) {
                                result.success(
                                    GsonUtil.bean2json(
                                        GetExportExternalPathResult(
                                            false,
                                            null,
                                            "create ${root.absolutePath} fail"
                                        )
                                    )
                                )
                                return
                            }
                        }
                        result.success(
                            GsonUtil.bean2json(
                                GetExportExternalPathResult(
                                    true,
                                    root.absolutePath,
                                    ""
                                )
                            )
                        )
                    } else {
                        result.success(
                            GsonUtil.bean2json(
                                GetExportExternalPathResult(
                                    false,
                                    null,
                                    "Have no write permission"
                                )
                            )
                        )
                    }
                } else {
                    result.success(
                        GsonUtil.bean2json(
                            GetExportExternalPathResult(
                                false,
                                null,
                                "Have no write permission"
                            )
                        )
                    )
                    ActivityCompat.requestPermissions(
                        aty,
                        arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                        1
                    )
                }
            }
        }
    }

    /**
     * 获取log日志的记录目录
     */
    private fun getLogDir(result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                val default = RecordLogHelper.obtainDefaultLogRoot(aty)
                val external = RecordLogHelper.obtainExternalLogDir(aty)
                val list = ArrayList<String>()
                list.add(default)
                if (default != external) {
                    list.add(external)
                }
                MainHandler.runOnMain(Runnable {
                    result.success(GsonUtil.bean2json(list))
                })
            }
        }
    }

    private fun switchLanguage(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                call.arguments?.let { arg ->
                    if (arg is String) {
                        SystemLanguageHelper.switchLanguage(
                            aty, call.arguments as String
                        )
                    }
                } ?: run {
                    SystemLanguageHelper.switchLanguage(aty, null)
                }
                result.success(null)
            }
        }
    }

    /**
     * 捕获记录Flutter module的异常信息。提示用户退出App或者重启App
     * {
     * 'error':error,
     * 'stack':stack,
     * }
     */
    private fun catchError(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                call.arguments?.let { arg ->
                    if (arg is String) {
                        try {
                            val obj = JSONObject(arg)
                            val error = obj.optString("error")
                            val stack = obj.optString("stack")
                            Log.i(TAG, "error\n${error}")
                            Log.i(TAG, "stack\n${stack}")
                            RecordLogHelper.recordLog(aty, "error:\n$error\nstack:\n$stack")
                            Toast.makeText(aty, R.string.flutterError, Toast.LENGTH_LONG).show()
                            aty.finish()
                            FlutterModuleDbHelper.getEnvironmentConf(WReaderApp.getApp())
                                .let { conf ->
                                    FlutterMainAty.startReading(
                                        WReaderApp.getApp(),
                                        conf[FlutterModuleDbConst.BRIGHTNESS_MODE] as? Int?,
                                        conf[FlutterModuleDbConst.LANGUAGE_CODE] as? String?
                                    )
                                }
                        } catch (e: java.lang.Exception) {
                            RecordLogHelper.recordLog(aty, arg)
                        } finally {
                            MainHandler.runOnMain(Runnable {
                                result.success("")
                            })
                        }
                    }
                }
            }
        }
    }

    /**
     * 获取版本信息
     */
    private fun getVersionInfo(result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                aty.packageManager.getPackageInfo(aty.packageName, 0)?.let { info ->
                    val appVersionInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        AppVersionInfo(info.versionName, info.longVersionCode)
                    } else {
                        AppVersionInfo(info.versionName, info.versionCode.toLong())
                    }
                    result.success(GsonUtil.bean2json(appVersionInfo))
                }
            }
        }
    }

    /**
     * 打开未知文件，使用AndroidIntent去寻找应用程序
     */
    private fun openFileUseOtherApp(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                Log.i(TAG, "call.arguments = ${call.arguments}")
                val jsonObject = JSONObject(call.arguments as String)
                try {
                    val uriIntent = Intent(Intent.ACTION_VIEW)
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                        uriIntent.data =
                            Uri.fromFile(File(jsonObject.optString("filePath")))
                    } else {
                        uriIntent.data = FileProvider.getUriForFile(
                            aty,
                            aty.packageName,
                            File(jsonObject.optString("filePath"))
                        )
                    }
                    uriIntent.addCategory(Intent.CATEGORY_DEFAULT)
                    uriIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    aty.startActivity(uriIntent)
                    result.success("success")
                } catch (e: java.lang.Exception) {
                    e.printStackTrace()
                    result.success("fail:[$e]")
                }

            }
        }
    }

    private fun exitApp() {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                aty.finish()
                MainHandler.runDelay(100, Runnable {
                    exitProcess(0)
                })
            }
        }

    }

    private fun gotoHome(result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                val intent = Intent(Intent.ACTION_MAIN)
                intent.addCategory(Intent.CATEGORY_HOME)
                aty.startActivity(intent)
                result.success("success")
            }
        }
    }

    /**
     * 创建一个新的日志输出框
     */
    private fun createNewConsole(aty: Activity) {
        MainHandler.runOnMain(Runnable {
            releaseConsole()
            if (progressConsole == null) {
                progressConsole = MsgOutputConsole(aty)
                progressConsole?.show()
            }
        })
    }

    /**
     * 删除特定药品，call传输一个key为"list"的字符串数组。将仓库的全路径传过来
     * {
     *  "list":["",""]
     * }
     */
    private fun cleanSpecifiedRepo(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                SingleWorker.doSomething(Runnable {
                    try {
                        if (call.arguments is String) {
                            val obj = JSONObject(call.arguments as String)
                            val listJson = obj.optJSONArray("list")
                            val length = listJson.length()
                            if (length == 0) {
                                MainHandler.runOnMain(Runnable {
                                    result.success("Specified repo was empty.")
                                })
                            } else {
                                //展示删除进度窗口
                                createNewConsole(aty)
                                for (index in 0 until length) {
                                    if (!File(listJson.optString(index)).exists()) {
                                        MainHandler.runOnMain(Runnable {
                                            result.success("The dir was Empty!")
                                            releaseConsole()
                                        })
                                        return@Runnable
                                    }
                                    deleteInvalidRepo(listJson.optString(index))
                                }
                                MainHandler.runOnMain(Runnable {
                                    result.success("success")
                                })
                            }
                        } else {
                            MainHandler.runOnMain(Runnable {
                                result.success("Illegal arguments.")
                            })
                        }
                        releaseConsole()
                    } catch (e: java.lang.Exception) {
                        e.printStackTrace()
                        MainHandler.runOnMain(Runnable {
                            result.success("Delete specified repo fail:$e")
                            releaseConsole()
                        })
                    }
                })
            }
        }
    }

    /**
     * 清理那些clone失败的无效仓库
     */
    private fun cleaInvalidRepo(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                SingleWorker.doSomething(Runnable {
                    try {
                        val list = FlutterModuleDbHelper.queryRepoList(aty)
                        val repoList = obtainRootDir(aty).listFiles()
                        Log.i(TAG, list.toString())
                        val deleteTargets = ArrayList<String>()
                        if (repoList == null) {
                            MainHandler.runOnMain(Runnable {
                                result.success("Have no invalid repo.")
                                releaseConsole()
                            })
                            return@Runnable
                        }
                        repoList.forEach {
                            if (!list.contains(
                                    it.absolutePath.substring(
                                        it.absolutePath.lastIndexOf(
                                            File.separator
                                        ) + 1, it.absolutePath.length
                                    )
                                )
                            ) {
                                deleteTargets.add(it.absolutePath)
                            }
                        }
                        if (deleteTargets.isEmpty()) {
                            MainHandler.runOnMain(Runnable {
                                result.success("Have no invalid repo.")
                            })
                        } else {
                            //展示删除进度窗口
                            createNewConsole(aty)
                            deleteTargets.forEach {
                                MainHandler.runOnMain(Runnable {
                                    progressConsole?.appendLine("start delete.")
                                })
                                deleteInvalidRepo(it)
                            }
                            releaseConsole()
                            MainHandler.runOnMain(Runnable {
                                result.success("Delete all invalid file Finished.")
                            })
                        }
                        releaseConsole()
                    } catch (e: java.lang.Exception) {
                        e.printStackTrace()
                        result.success("Delete all invalid error:${e}")
                        releaseConsole()
                    }
                })
            }
        }
    }

    /**
     * 开始删除文件
     */
    private fun deleteInvalidRepo(dirPath: String) {
        val file = File(dirPath)
        file.listFiles()?.forEach {
            if (it.isDirectory) {
                deleteInvalidRepo(it.absolutePath)
            } else {
                //删除的太快了，交互没有了
                Thread.sleep(2)
                MainHandler.runOnMain(Runnable {
                    progressConsole?.appendLine("start delete ${it.absolutePath}:${it.delete()}")
                })
            }
        }
        MainHandler.runOnMain(Runnable {
            progressConsole?.appendLine("start delete ${dirPath}:${File(dirPath).delete()}")
        })
    }

    /**
     * 浏览图片，目前只支持单张
     */
    private fun browseImage(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                Log.i(TAG, "call.arguments = ${call.arguments}")
                val jsonObject = JSONObject(call.arguments as String)
                BrowseImageAty.browseImage(
                    aty,
                    jsonObject.optString("filePath")
                )
                result.success("success")
            }
        }
    }

    /**
     * 阅读文本内容，根据传递过来的fileType进行处理
     */
    private fun readTextFile(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                Log.i(TAG, "call.arguments = ${call.arguments}")
                val jsonObject = JSONObject(call.arguments as String)
                MdReaderActivity.startReading(
                    aty,
                    jsonObject.optString("filePath"),
                    jsonObject.optString("fileType"),
                    jsonObject.optInt("brightnessMode"),
                    FlutterMainAty.READ_MD_FILE
                )
                result.success("success")
            }
        }
    }

    /**
     * 返回文件选择结果
     */
    fun transGitConFilePath(path: String?) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                if (!path.isNullOrBlank()) {
                    tmpResult?.success(path)
                } else {
                    tmpResult?.success(null)
                }
            }
        }
        tmpCall = null
        tmpResult = null
    }

    /**
     * 获取git配置的文件绝对路径，配置文件必须是json文件，
     * 详情见[RepoConfigJsonBean]
     */
    private fun getGitConfFile(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                //读权限检查
                if (ActivityCompat.checkSelfPermission(
                        aty,
                        Manifest.permission.READ_EXTERNAL_STORAGE
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    //有权限
                    gotoImportConf(aty, call, result)
                } else {
                    //申请权限
                    externalHelper?.applyExternalStoragePermission(object :
                        ApplyStorageCallback {
                        override fun callback(applyResult: Boolean) {
                            if (applyResult) {
                                gotoImportConf(aty, call, result)
                            } else {
                                result.success(null)
                            }
                        }
                    }, Manifest.permission.READ_EXTERNAL_STORAGE)
                }
            }
        }
    }

    /**
     * 选择json文件
     */
    private fun gotoImportConf(aty: Activity, call: MethodCall, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "*/*"
        intent.categories?.add(Intent.CATEGORY_OPENABLE)
        intent.categories?.add(Intent.CATEGORY_DEFAULT)
        aty.startActivityForResult(
            Intent.createChooser(intent, "Select git conf json file."),
            GET_GIT_CONF_FILE
        )
        tmpCall = call
        tmpResult = result
    }

    private fun fetch(call: MethodCall, result: MethodChannel.Result) {
        SingleWorker.doSomething(Runnable {
            try {
                val obj = JSONObject(call.arguments as String)
                val bean = GsonUtil.json2bean<RepoDetailsBean>(
                    obj.optString("repoDetails"),
                    RepoDetailsBean::class.java
                )
                GitUtil.fetch(bean, obtainProgressMonitor("begin task fetch"))
                MainHandler.runOnMain(Runnable { result.success(GsonUtil.bean2json(FetchResult("success"))) })
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
                MainHandler.runOnMain(Runnable {
                    result.success(
                        GsonUtil.bean2json(
                            FetchResult(
                                "fail",
                                e.toString()
                            )
                        )
                    )
                })
            } finally {
                releaseConsole()
            }
        })
    }

    /**
     * 重置当前分支到HEAD
     */
    private fun reset(call: MethodCall, result: MethodChannel.Result) {
        SingleWorker.doSomething(Runnable {
            try {
                val obj = JSONObject(call.arguments as String)
                val bean = GsonUtil.json2bean<RepoDetailsBean>(
                    obj.optString("repoDetails"),
                    RepoDetailsBean::class.java
                )
                GitUtil.resetBranch(bean, obtainProgressMonitor("begin task reset"))
                MainHandler.runOnMain(Runnable { result.success(GsonUtil.bean2json(ResetResult("success"))) })
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
                MainHandler.runOnMain(Runnable {
                    result.success(
                        GsonUtil.bean2json(
                            ResetResult(
                                "fail",
                                e.toString()
                            )
                        )
                    )
                })
            } finally {
                releaseConsole()
            }
        })
    }

    private var progressConsole: MsgOutputConsole? = null

    @Deprecated("因为加入 Checkout Tag 功能,该函数不再适用")
    private fun extractBranchInfo(fullBranchName: String): BranchInfo? {
        if (fullBranchName.contains("/")) {
            val strs = fullBranchName.split("/")
            if ("heads" == strs[1]) {
                return BranchInfo(
                    false,
                    fullBranchName,
                    null
                )
            } else if ("remotes" == strs[1]) {
                return BranchInfo(
                    true,
                    fullBranchName,
                    strs[2]
                )
            }
            return null
        } else {
            return null
        }
    }

    /**
     * 拉取最新代码
     */
    private fun pull(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                SingleWorker.doSomething(Runnable {
                    try {
                        val obj = JSONObject(call.arguments as String)
                        val bean = GsonUtil.json2bean<RepoDetailsBean>(
                            obj.optString("repoDetails"),
                            RepoDetailsBean::class.java
                        )
                        val pullResult = GitUtil.pull(bean, obtainProgressMonitor("begin pull"))
                        Log.d(TAG, "pullResult = $pullResult")
                        MainHandler.runOnMain(Runnable {
                            result.success(GsonUtil.bean2json(pullResult))
                        })
                        return@Runnable
                    } catch (e: Exception) {
                        e.printStackTrace()
                        MainHandler.runOnMain(Runnable {
                            result.success(
                                GsonUtil.bean2json(
                                    PullResult("fail", e.toString())
                                )
                            )
                        })
                        return@Runnable
                    } finally {
                        releaseConsole()
                    }
                })
            }
        }
    }

    /**
     * 切换分支
     */
    private fun switchNewBranch(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                SingleWorker.doSomething(Runnable {
                    try {
                        Log.w(TAG, call.arguments as String)
                        val obj = JSONObject(call.arguments as String)
                        val realFullBranchName = obj.optString("branchFullName")
                        Log.e(TAG, "realFullBranchName = $realFullBranchName")
                        val fullBranchName =
                            if (realFullBranchName.contains("\n")) realFullBranchName.substring(
                                0,
                                realFullBranchName.indexOf("\n")
                            ) else realFullBranchName
                        Log.w(TAG, "fullBranchName = $fullBranchName")
                        val bean = GsonUtil.json2bean<RepoDetailsBean>(
                            obj.optString("repoDetails"),
                            RepoDetailsBean::class.java
                        )
                        GitUtil.switchNewBranch(
                            fullBranchName, bean,
                            obtainProgressMonitor("Begin checkout branch.")
                        ).let { info ->

                            MainHandler.runOnMain(Runnable {
                                result.success(GsonUtil.bean2json(info))
                            })
                            return@Runnable
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        MainHandler.runOnMain(Runnable {
                            result.success(
                                GsonUtil.bean2json(
                                    SwitchBranchResult("fail", null)
                                )
                            )
                        })
                        return@Runnable
                    } finally {
                        releaseConsole()
                    }
                })
            }
        }
    }

    /**
     * 获取所有分支信息
     */
    private fun getAllBranchInfo(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                call.arguments?.let { arg ->
                    val obj = JSONObject((arg as String))
                    val gitRepoLocalDir = obj.optString("gitRepoLocalDir")
                    val git = Git.open(File(gitRepoLocalDir))
                    val list =
                        git.branchList().setListMode(ListBranchCommand.ListMode.ALL).call()
                    val refStrs = ArrayList<String>(list.size)
                    list.forEach { ref ->
                        refStrs.add(ref.name)
                    }
                    git.close()
                    result.success(GsonUtil.bean2json(AllBranchResult("success", refStrs)))
                    return
                }
                result.success(GsonUtil.bean2json(AllBranchResult("fail", null)))
            }
        }
    }

    /**
     * 使用一个Dialog来展示进度
     */
    private fun obtainProgressMonitor(beginTask: String): ProgressMonitor? {
        releaseConsole()
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                createNewConsole(aty)
                return object : ProgressMonitor {

                    private var lastTask: String? = null
                    private var lastProgress: Int = 0
                    private var totalNum: Int = 0
                    private var delayUpdateCount = 0
                    private val updateFlagCount = 2
                    private val format = "%s: (%s/%s)"

                    override fun update(completed: Int) {
                        lastProgress += completed
                        delayUpdateCount++
                        if (totalNum < updateFlagCount) {
                            MainHandler.runOnMain(Runnable {
                                progressConsole?.replaceLastLine(
                                    String.format(
                                        format,
                                        lastTask,
                                        lastProgress,
                                        totalNum
                                    )
                                )
                            })
                        } else if (delayUpdateCount > updateFlagCount) {
                            delayUpdateCount = 0
                            MainHandler.runOnMain(Runnable {
                                progressConsole?.replaceLastLine(
                                    String.format(
                                        format,
                                        lastTask,
                                        lastProgress,
                                        totalNum
                                    )
                                )
                            })
                        }
                    }

                    override fun start(totalTasks: Int) {
                        MainHandler.runOnMain(Runnable {
                            progressConsole?.appendLine("$beginTask,totalTasks:$totalTasks")
                        })
                    }

                    override fun beginTask(title: String?, totalWork: Int) {
                        lastTask = title
                        lastProgress = 0
                        totalNum = totalWork
                        MainHandler.runOnMain(Runnable {
                            progressConsole?.appendLine(
                                String.format(
                                    format,
                                    lastTask,
                                    lastProgress,
                                    totalNum
                                )
                            )
                        })
                    }

                    override fun endTask() {
                        MainHandler.runOnMain(Runnable {
                            progressConsole?.appendLine("remote:$lastTask ($totalNum/$totalNum) done")
                        })
                        lastTask = null
                        lastProgress = 0
                        totalNum = 0
                        delayUpdateCount = 0
                    }

                    override fun isCancelled(): Boolean {
                        return false
                    }
                }
            }

        }
        return null
    }


    /**
     * 使用账号密码clone
     * String gitUrl, String localPath，String repoName,String account,String pwd
     */
    private fun cloneUseAccountAndPwd(call: MethodCall, result: MethodChannel.Result) {
        call.arguments?.let {
            if (it is String) {
                val obj = JSONObject(it)
                val gitUri = obj.optString("gitUrl")
                val localPath = obj.optString("localPath")
                val repoName = obj.optString("repoName")
                val account = obj.optString("account")
                val pwd = obj.optString("pwd")
                Log.i(TAG, "localPath = $localPath")
                Log.i(TAG, "gitUrl = $gitUri")
                Log.i(TAG, "repoName = $repoName")
                Log.i(TAG, "account = $account")
                Log.i(TAG, "pwd = $pwd")
                cloneUseAccountAndPwd(
                    gitUri,
                    localPath,
                    repoName,
                    account,
                    pwd,
                    result
                )
            }
        }
    }

    /**
     * 使用账号密码clone
     * String gitUrl, String localPath，String repoName,String account,String pwd
     */
    private fun cloneUseAccountAndPwd(
        gitUri: String,
        localPath: String,
        repoName: String,
        account: String,
        pwd: String,
        result: MethodChannel.Result
    ) {
        SingleWorker.doSomething(Runnable {
            try {
                Log.i(TAG, "开始clone")
                val git =
                    GitUtil.cloneUseAccountAndPwd(
                        gitUri,
                        localPath,
                        repoName,
                        account,
                        pwd,
                        null,
                        obtainProgressMonitor("${WReaderApp.getApp().resources.getString(R.string.cloneHint)}\nCloning into '$repoName'")
                    )
                git?.let {
                    val currentBranch = git.repository.fullBranch
                    val listBranchCommand =
                        git.branchList().setListMode(ListBranchCommand.ListMode.ALL)
                    val ref = listBranchCommand.call()
                    Log.i(TAG, ref.toString())
                    git.close()
                    MainHandler.runOnMain(Runnable {
                        result.success(
                            GsonUtil.bean2json(
                                CloneResult(
                                    "success",
                                    currentBranch
                                )
                            )
                        )
                    })
                } ?: run {
                    Log.e(TAG, "clone失败，创建文件夹失败")
                    MainHandler.runOnMain(Runnable {
                        result.success(
                            GsonUtil.bean2json(
                                CloneResult(
                                    "fail",
                                    null
                                )
                            )
                        )
                    })
                }
            } catch (e: Exception) {
                Log.e(TAG, e.toString())
                e.printStackTrace()
                MainHandler.runOnMain(Runnable {
                    result.success(
                        GsonUtil.bean2json(
                            CloneResult(
                                "fail",
                                null
                            )
                        )
                    )
                })
            } finally {
                releaseConsole()
            }
        })
    }

    /**
     * 使用rsa 密钥对clone
     * String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
     */
    private fun cloneUseKeyPair(call: MethodCall, result: MethodChannel.Result) {
        call.arguments?.let {
            if (it is String) {
                val obj = JSONObject(it)
                val gitUri = obj.optString("gitUrl")
                val localPath = obj.optString("localPath")
                val repoName = obj.optString("repoName")
                val priKey = obj.optString("priKey")
                val pubKey = obj.optString("pubKey")
                val priKeyPass = obj.optString("priKeyPass")
                Log.i(TAG, "localPath = $localPath")
                Log.i(TAG, "gitUrl = $gitUri")
                Log.i(TAG, "repoName = $repoName")
                Log.i(TAG, "priKey = $priKey")
                Log.i(TAG, "pubKey = $pubKey")
                Log.i(TAG, "priKeyPass = $priKeyPass")
                cloneUseKeyPair(
                    gitUri,
                    localPath,
                    repoName,
                    priKey,
                    pubKey,
                    priKeyPass ?: null,
                    result
                )
            }
        }
    }

    private fun cloneUseKeyPair(
        uri: String,
        localPath: String,
        localRepoName: String,
        privateKey: String,
        pubKey: String,
        password: String?,
        result: MethodChannel.Result
    ) {
        SingleWorker.doSomething(Runnable {
            Log.i(TAG, "开始clone")
            try {
                val git =
                    GitUtil.cloneRespUsePriKey(
                        uri,
                        localPath,
                        localRepoName,
                        privateKey,
                        pubKey,
                        password,
                        null,
                        obtainProgressMonitor("${WReaderApp.getApp().resources.getString(R.string.cloneHint)}\nCloning into '$localRepoName'")
                    )
                git?.let {
                    val currentBranch = git.repository.fullBranch
                    val listBranchCommand =
                        git.branchList().setListMode(ListBranchCommand.ListMode.ALL)
                    val ref = listBranchCommand.call()
                    Log.i(TAG, ref.toString())
                    Log.i(TAG, "ref.size = ${ref.size}")
                    git.close()
                    MainHandler.runOnMain(Runnable {
                        result.success(
                            GsonUtil.bean2json(
                                CloneResult(
                                    "success",
                                    currentBranch
                                )
                            )
                        )
                    })
                } ?: run {
                    Log.e(TAG, "clone失败，创建文件夹失败")
                    MainHandler.runOnMain(Runnable {
                        result.success(
                            GsonUtil.bean2json(
                                CloneResult(
                                    "fail",
                                    null
                                )
                            )
                        )
                    })
                }
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
                MainHandler.runOnMain(Runnable {
                    result.success(
                        GsonUtil.bean2json(
                            CloneResult(
                                e.toString(),
                                null
                            )
                        )
                    )
                })
            } finally {
                releaseConsole()
            }
        })
    }

    /**
     * showToast，文本与toast时长，0或1,0是LENGTH_SHORT，1是LENGTH_LONG
     * String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
     */
    private fun showToast(call: MethodCall, result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                call.arguments?.let {
                    if (it is String) {
                        val obj = JSONObject(it)
                        val content = obj.optString("content")
                        val duration = obj.optInt("duration")
                        if (content.isNotBlank()) {
                            Toast.makeText(
                                aty,
                                content,
                                if (duration == 0) Toast.LENGTH_SHORT else Toast.LENGTH_LONG
                            ).show()
                        }
                    }
                }
                result.success("success")
            }
        }
    }


    /**
     * 检查仓库是否存在，通讯数据是json字符串，字段如下
     * String gitUrl, String localPath，String repoName
     * git@github.com:Bottlezn/amrCodec.git
     */
    private fun checkGitRepoExists(call: MethodCall, result: MethodChannel.Result) {
        call.arguments?.let {
            if (it is String) {
                val obj = JSONObject(it)
                val localPath = obj.optString("localPath")
                val repoName = obj.optString("repoName")
                val file = File(localPath, repoName)
                if (!file.exists()) {
                    result.success("notExists")
                } else {
                    result.success("exists")
                }
            }
        }
    }

    /**
     * 直接克隆仓库，不需要鉴权，通讯数据是json字符串，字段如下
     * String gitUrl, String localPath，String repoName
     */
    private fun cloneDirect(call: MethodCall, result: MethodChannel.Result) {
//        call.arguments?.let {
//            if (it is String) {
//                val obj = JSONObject(it)
//                val gitUri = obj.optString("gitUrl")
//                val localPath = obj.optString("localPath")
//                val repoName = obj.optString("repoName")
//                Log.i(TAG, "localPath = $localPath")
//                Log.i(TAG, "gitUrl = $gitUri")
//                Log.i(TAG, "repoName = $repoName")
//                cloneDirect(gitUri, localPath, repoName, result)
//            }
//        }
    }

    @Deprecated("暂时废弃")
    private fun cloneDirect(
        gitUri: String,
        localPath: String,
        repoName: String,
        result: MethodChannel.Result
    ) {
        SingleWorker.doSomething(Runnable {
            Log.i(TAG, "开始clone")
            val git =
                GitUtil.cloneDirect(
                    gitUri,
                    localPath,
                    repoName,
                    object : CloneCommand.Callback {
                        override fun checkingOut(commit: AnyObjectId?, path: String?) {
                            Log.w(TAG, "checkingOut:path =$path")
                            Log.w(TAG, "checkingOut:commit  = $commit")
                        }

                        override fun initializedSubmodules(submodules: MutableCollection<String>?) {
                            Log.w(TAG, "initializedSubmodules:submodules =$submodules")
                        }

                        override fun cloningSubmodule(path: String?) {
                            Log.w(TAG, "cloningSubmodule:path =$path")
                        }
                    },
                    obtainProgressMonitor("Cloning into '$repoName'")
                )
            git?.let {
                git.close()
                MainHandler.runOnMain(Runnable { result.success("success") })
            } ?: run {
                Log.e(TAG, "clone失败，创建文件夹失败")
                MainHandler.runOnMain(Runnable { result.success("failure") })
            }
            releaseConsole()
        })
    }

    /**
     * 获取git的本地存放地址
     */
    private fun getGitLocalRootPath(result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                //不使用SD卡的路径，避免Git仓库的数据被不小心改动到
                //因为本软件原则上只读，不提供编辑功能
                obtainContextFileDir(result)
            }
        }

    }

    private fun obtainRootDir(aty: Activity) =
        File("${aty.filesDir.absolutePath}${File.separator}${DIR_NAME}")

    ///返回应用的专属文件路径
    private fun obtainContextFileDir(result: MethodChannel.Result) {
        externalHelper?.canNext()?.let { aty ->
            if (!aty.isFinishing) {
                //没有读写权限，返回
                val root =
                    obtainRootDir(aty)
                if (!root.exists()) {
                    if (!root.mkdirs()) {
                        result.success("error")
                        return
                    }
                }
                result.success(root.absolutePath)
            }
        }
    }

    private fun releaseConsole() {
        progressConsole?.let { console ->
            MainHandler.runOnMain(Runnable {
                console.appendLine("done!")
                console.dismiss()
                console.release()
                progressConsole = null
            })
        }

    }

    fun onDestroy() {
        externalHelper?.release()
        externalHelper = null
        releaseConsole()
    }
}