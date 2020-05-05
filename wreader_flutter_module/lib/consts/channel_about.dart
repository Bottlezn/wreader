const CHANNEL_TRANS_BRIDGE = 'wangzh.wang.channel.trans';

class ChannelOutMethod {
  ///获取git仓库的存储根目录
  static const GET_GIT_ROOT_PATH = 'getGitRootPath';

  ///直接克隆仓库，无需鉴权
  static const CLONE_DIRECT = 'cloneDirect';

  ///使用RSA密钥对clone
  static const CLONE_USE_KEY_PAIR = 'cloneUseKeyPair';

  ///使用账号密码clone
  static const CLONE_USE_ACCOUNT_AND_PWD = 'cloneUseAccountAndPwd';

  ///切换到新的分支
  static const SWITCH_NEW_BRANCH = 'switchNewBranch';

  ///切换到已存在的分支
  static const SWITCH_EXISTED_BRANCH = "switchExistedBranch";

  ///pull
  static const PULL = 'pull';

  ///回滚所有分支
  static const RESET = 'reset';

  ///fetch
  static const FETCH = 'reset';

  ///获取所有分支信息
  static const GET_ALL_BRANCH = 'getAllBranch';

  ///检查该git仓库是否存在
  static const CHECK_GIT_EXISTS = 'checkGitExists';

  ///showToast
  static const SHOW_TOAST = 'showToast';

  ///从Android设备上选择一个json内容的文件来解析git仓库配置
  static const GET_GIT_REPO_CONFIG_FILE = 'getGitRepoConfigFile';

  ///阅读md文件
  static const READ_MD_FILE = 'readMdFile';

  ///浏览图片
  static const BROWSE_IMAGE = 'browseImage';

  ///浏览代码文件
  static const READ_CODE_FILE = 'readCodeFile';

  ///删除无效的仓库
  static const CLEAR_INVALID_REPO = "clearInvalidRepo";

  ///删除特定的仓库
  static const CLEAR_SPECIFIED_REPO = "clearSpecifiedRepo";

  ///关闭App
  static const EXIT_APP = 'exitApp';

  ///退到桌面
  static const GOTO_HOME = 'gotoHome';

  ///使用手机的其他软件打开App
  static const OPEN_FILE_USE_OTHER_APP = 'openFileUseOtherApp';

  ///获取版本信息
  static const GET_VERSION_INFO = 'getVersionInfo';

  ///捕获flutter项目的运行异常
  static const REPORT_FLUTTER_ERROR = 'reportFlutterError';

  ///切换语言环境
  static const SWITCH_LANGUAGE = 'switchLanguage';

  ///获取存放log日志路径
  static const GET_LOG_DIR = 'getLogDir';

  ///获取存放导出文件目录
  static const GET_EXPORT_EXTERNAL_PATH = 'getExportExternalPath';

  ///获取 tag 列表
  static const GET_TAG_LIST = 'getTagList';

  ///检出 tag
  static const CHECK_OUT_TAG = 'checkoutTag';

  ///打开其他 URl
  static const OPEN_URL = "openUrl";
}
