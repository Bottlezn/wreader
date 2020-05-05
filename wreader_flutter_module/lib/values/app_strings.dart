import 'package:wreader_flutter_module/page/repo_conf/page_repo_conf.dart';
import 'package:wreader_flutter_module/utils/common/flutter_i18n_helper.dart';

/// HomePage 页面使用的字符串资源
class StrsHome {
  static String title() => i18nTranslate('home.title');

  static String loadingHint() => i18nTranslate('home.loadingHint');

  static String goToCloneGitRepo() => i18nTranslate('home.goToCloneGitRepo');

  static String emptyFile() => i18nTranslate('home.emptyFile');

  static String closeGuid() => i18nTranslate('home.closeGuid');

  static String export() => i18nTranslate('home.export');

  static String moreOperate() => i18nTranslate('home.moreOperate');

  static String delete() => i18nTranslate('home.delete');

  static String openWithNative() => i18nTranslate('home.openWithNative');

  static String notSupport() => i18nTranslate('home.notSupport');

  static String exportSuccess() => i18nTranslate('home.exportSuccess');

  static String iKnow() => i18nTranslate('home.iKnow');
}

///[RepoConfPage]页面使用的字符串资源
class StrsRepoConf {
  static String title() => i18nTranslate('repoConf.title');

  static String save() => i18nTranslate('repoConf.save');

  static String gitUriHint() => i18nTranslate('repoConf.gitUriHint');

  static String alreadyExistedUri() =>
      i18nTranslate('repoConf.alreadyExistedUri');

  static String inputGitLocalRepo() =>
      i18nTranslate('repoConf.inputGitLocalRepo');

  static String selectAuthenticate() =>
      i18nTranslate('repoConf.selectAuthenticate');

  static String localPath() => i18nTranslate('repoConf.localPath');

  static String errorLocalPath() => i18nTranslate('repoConf.errorLocalPath');

  static String clickAndCopy() => i18nTranslate('repoConf.clickAndCopy');

  static String inputAccount() => i18nTranslate('repoConf.inputAccount');

  static String inputPwd() => i18nTranslate('repoConf.inputPwd');

  static String inputPriKey() => i18nTranslate('repoConf.inputPriKey');

  static String inputPubKey() => i18nTranslate('repoConf.inputPubKey');

  static String inputKeyPassphrase() =>
      i18nTranslate('repoConf.inputKeyPassphrase');

  static String illegalGitUri() => i18nTranslate('repoConf.illegalGitUri');

  static String illegalAccountAndPwd() =>
      i18nTranslate('repoConf.illegalAccountAndPwd');

  static String illegalKeyPair() => i18nTranslate('repoConf.illegalKeyPair');
}

class StrsAuthenticationWay {
  static String way(int index) => i18nPlural('authenticationWay.way', index);
}

///设置页面使用的字符串资源
class StrsSetting {
  static String displayLanguage() => i18nTranslate('setting.displayLanguage');

  static String followSystem() => i18nTranslate('setting.followSystem');

  static String manageRepo() => i18nTranslate('setting.manageRepo');

  static String cleanInvalidRepo() => i18nTranslate('setting.cleanInvalidRepo');

  static String cleanInvalidRepoFinished() =>
      i18nTranslate('setting.cleanInvalidRepoFinished');

  static String exitApp() => i18nTranslate('setting.exitApp');

  static String exitSetting() => i18nTranslate('setting.exitSetting');

  static String replicated() => i18nTranslate('setting.replicated');

  static String aboutWReader() => i18nTranslate('setting.about');

  static String versionName() => i18nTranslate('setting.versionName');

  static String author() => i18nTranslate('setting.author');

  static String myWordHint() => i18nTranslate('setting.myWordHint');

  static String cancel() => i18nTranslate('setting.cancel');

  static String save() => i18nTranslate('setting.save');

  static String projectInfo() => i18nTranslate('setting.projectInfo');

  static String mainSite() => i18nTranslate('setting.mainSite');

  static String githubSite() => i18nTranslate('setting.githubSite');

  static String dependentTitle() => i18nTranslate('setting.dependentTitle');

  static String thanks() => i18nTranslate('setting.thanks');

  static String logList() => i18nTranslate('setting.logList');
}

class StrsRepoList {
  static String title() => i18nTranslate('repoList.title');

  static String empty() => i18nTranslate('repoList.empty');
}

class StrsRepoDetails {
  static String currentBranch() => i18nTranslate('repoDetails.currentBranch');

  static String tagBranchCannotUpdate() =>
      i18nTranslate('repoDetails.tagBranchCannotUpdate');

  static String switchHint() => i18nTranslate('repoDetails.switchHint');

  static String switchBranch() => i18nTranslate('repoDetails.switchBranch');

  static String existedRemoteBranch() =>
      i18nTranslate('repoDetails.existedRemoteBranch');

  static String fromLocalBranch() =>
      i18nTranslate('repoDetails.fromLocalBranch');

  static String fromRemoteBranch() =>
      i18nTranslate('repoDetails.fromRemoteBranch');

  static String fromRemoteTag() => i18nTranslate('repoDetails.fromRemoteTag');

  static String otherOperations() =>
      i18nTranslate('repoDetails.otherOperations');
}

class StrsManageRepo {
  static String title() => i18nTranslate('manageRepo.title');

  static String currentBranch() => i18nTranslate('manageRepo.currentBranch');

  static String delete() => i18nTranslate('manageRepo.delete');

  static String deleteConfirm() => i18nTranslate('manageRepo.deleteConfirm');

  static String deleteSuccess() => i18nTranslate('manageRepo.deleteSuccess');

  static String cancel() => i18nTranslate('manageRepo.cancel');

  static String swipeToDelete() => i18nTranslate('manageRepo.swipeToDelete');

  static String empty() => i18nTranslate('manageRepo.empty');
}

class StrsToast {
  static String emptyTextWarn() => i18nTranslate('toast.emptyTextWarn');

  static String click2HomeHint() => i18nTranslate('toast.click2HomeHint');

  static String cancelConfFileSelected() =>
      i18nTranslate('toast.cancelConfFileSelected');

  static String parseConfFileError() =>
      i18nTranslate('toast.parseConfFileError');

  static String fillConfFileSuccess() =>
      i18nTranslate('toast.fillConfFileSuccess');

  static String parseFail() => i18nTranslate('toast.parseFail');

  static String cloneSuccess() => i18nTranslate('toast.cloneSuccess');

  static String cloneFail() => i18nTranslate('toast.cloneFail');

  static String saveSuccess() => i18nTranslate('toast.saveSuccess');

  static String repoDbDataInsertFail() =>
      i18nTranslate('toast.repoDbDataInsertFail');

  static String successOperationAndReload() =>
      i18nTranslate('toast.successOperationAndReload');

  static String operationFail() => i18nTranslate('toast.operationFail');

  static String tryToResetRepo() => i18nTranslate('toast.tryToResetRepo');

  static String resetBranchSuccess() =>
      i18nTranslate('toast.resetBranchSuccess');

  static String reloadPage() => i18nTranslate('toast.reloadPage');

  static String pullSuccessAndReload() =>
      i18nTranslate('toast.pullSuccessAndReload');

  static String switchSuccessAndReload() =>
      i18nTranslate('toast.switchSuccessAndReload');

  static String pullFail() => i18nTranslate('toast.pullFail');

  static String openFileFail() => i18nTranslate('toast.openFileFail');
}

class StrsLogList {
  static String title() => i18nTranslate('logList.title');

  static String deleting() => i18nTranslate('logList.deleting');

  static String deleteAll() => i18nTranslate('logList.deleteAll');
}

///"hint": "in
//"noResult":
class StrsSearchReadingRecord {
  static String hint() => i18nTranslate('searchReadingRecord.hint');

  static String noResult() => i18nTranslate('searchReadingRecord.noResult');
}
