package wang.wangzh.wreader.consts

/**
 * @author  wangzh
 * @date  2020/2/16 14:25
 *  与channel相关的常量
 */

const val CHANNEL_TRANS_BRIDGE = "wangzh.wang.channel.trans"

object ChannelIncomingMethod {
    const val GET_GIT_ROOT_PATH = "getGitRootPath"
    const val CLONE_DIRECT = "cloneDirect"
    const val CLONE_USE_KEY_PAIR = "cloneUseKeyPair"
    const val CLONE_USE_ACCOUNT_AND_PWD = "cloneUseAccountAndPwd"
    const val CHECK_GIT_EXISTS = "checkGitExists"
    const val GET_ALL_BRANCH = "getAllBranch"
    const val SWITCH_NEW_BRANCH = "switchNewBranch"
    const val SWITCH_EXISTED_BRANCH = "switchExistedBranch"
    const val SHOW_TOAST = "showToast"
    const val PULL = "pull"
    const val RESET = "reset"
    const val FETCH = "fetch"
    const val GET_GIT_REPO_CONFIG_FILE = "getGitRepoConfigFile"
    const val READ_MD_FILE = "readMdFile"
    const val BROWSE_IMAGE = "browseImage"
    const val OPEN_FILE_USE_OTHER_APP = "openFileUseOtherApp"
    const val READ_CODE_FILE = "readCodeFile"
    const val CLEAR_INVALID_REPO = "clearInvalidRepo"
    const val CLEAR_SPECIFIED_REPO = "clearSpecifiedRepo"
    const val EXIT_APP = "exitApp"
    const val GOTO_HOME = "gotoHome"
    const val GET_VERSION_INFO = "getVersionInfo"
    const val REPORT_FLUTTER_ERROR = "reportFlutterError"
    const val SWITCH_LANGUAGE = "switchLanguage"
    const val GET_LOG_DIR = "getLogDir"
    const val GET_EXPORT_EXTERNAL_PATH = "getExportExternalPath"
    const val GET_TAG_LIST = "getTagList"
    const val CHECK_OUT_TAG = "checkoutTag"
    const val OPEN_URL = "openUrl"
}