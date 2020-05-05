import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wreader_flutter_module/consts/authencation_way.dart';
import 'package:wreader_flutter_module/consts/channel_about.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/base64_util.dart';
import 'package:wreader_flutter_module/utils/common/json_util.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';
import 'package:wreader_flutter_module/widget/text_selector.dart';

class RepoConfPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RepoConfState();
}

class _RepoConfState extends State<RepoConfPage> {
  TextEditingController _gitUriController;
  TextEditingController _gitTargetDirController;
  TextEditingController _accountController;
  TextEditingController _pwdController;
  TextEditingController _priKeyController;
  TextEditingController _pubKeyController;
  TextEditingController _priPassController;
  SelectedController _gitRootDirController;
  SelectedController _authenticateController;
  int _authenticationWay = AuthenticationWay.KEY_PAIR;

  ///焦点控制，不让输入框自动弹出
  FocusNode _gitUriFocus = FocusNode();
  FocusNode _gitTargetDirFocus = FocusNode();
  FocusNode _accountFocus = FocusNode();
  FocusNode _pwdFocus = FocusNode();
  FocusNode _priKeyFocus = FocusNode();
  FocusNode _pubKeyFocus = FocusNode();
  FocusNode _priPassFocus = FocusNode();

  ///最后一个获得焦点的Focus，为了提高交互体验而生
  FocusNode _lastFocus;

  @override
  void initState() {
    _gitUriController = TextEditingController();
    _gitTargetDirController = TextEditingController();
    _accountController = TextEditingController();
    _pwdController = TextEditingController();
    _priKeyController = TextEditingController();
    _pubKeyController = TextEditingController();
    _priPassController = TextEditingController();
    _gitRootDirController = SelectedController();
    _authenticateController = SelectedController();
    _gitRootDirController.setText('');
    _authenticateController
        .setText(StrsAuthenticationWay.way(_authenticationWay));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TransBridgeChannel.CHANNEL
          .invokeMethod(ChannelOutMethod.GET_GIT_ROOT_PATH)
          .then((_) {
        if (_ is String) {
          if ('error' == _) {
            _gitRootDirController.setText(StrsRepoConf.errorLocalPath());
          } else {
            _gitRootDirController.setText(_);
            setState(() {});
          }
        }
        FocusScope.of(context).requestFocus(_gitUriFocus);
      });
    });
    super.initState();
  }

  _obtainAction() {
    if (Platform.isIOS) {
      return <Widget>[
        SizedBox(
          height: 98.px2Dp,
          child: EzSelector(
            Padding(
              padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
              child: Image.asset(
                'assets/images/icon_save.png',
                width: 38.px2Dp,
                height: 38.px2Dp,
              ),
            ),
            _saveReopConf,
            defaultColor: Colors.transparent,
            pressColor: AppColors.COLOR_TRANS_20,
          ),
        )
      ];
    } else if (Platform.isAndroid) {
      return <Widget>[
        SizedBox(
          height: 98.px2Dp,
          child: EzSelector(
            Padding(
              padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
              child: Image.asset(
                'assets/images/icon_import_git_config.png',
                width: 38.px2Dp,
                height: 38.px2Dp,
              ),
            ),
            _getGitUriConfFile,
            defaultColor: Colors.transparent,
            pressColor: AppColors.COLOR_TRANS_20,
          ),
        ),
        SizedBox(
          height: 98.px2Dp,
          child: EzSelector(
            Padding(
              padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
              child: Image.asset(
                'assets/images/icon_save.png',
                width: 38.px2Dp,
                height: 38.px2Dp,
              ),
            ),
            _saveReopConf,
            defaultColor: Colors.transparent,
            pressColor: AppColors.COLOR_TRANS_20,
          ),
        )
      ];
    } else {
      return null;
    }
  }

  _buildAppBar(BuildContext context) =>
      EzAppBar.buildCenterTitleAppBar(StrsRepoConf.title(), context,
          actions: _obtainAction());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildCommonGap(),
            _buildGitUriInput(context),
            _buildCommonGap(),
            _buildGitLocalRepoNameInput(),
            _buildCommonGap(),
            //鉴权方式选择提示文本
            Container(
              margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0.0),
              width: double.maxFinite,
              child: Text(
                StrsRepoConf.localPath(),
                style: AppTvStyles.textStyle14Color69(),
              ),
            ),
            _buildLocalPathSelectBar(context),
            _buildCommonGap(),
            Container(
              margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0.0),
              width: double.maxFinite,
              child: Text(
                StrsRepoConf.selectAuthenticate(),
                style: AppTvStyles.textStyle14Color69(),
              ),
            ),
            _buildAuthenticateSelectBar(context),
            _buildCommonGap(),
            _buildAccountAndPwd(),
            _buildKeyPair()
          ],
        ),
      ),
    );
  }

  _buildCommonGap() {
    return SizedBox(
      height: 20.px2Dp,
    );
  }

  ///从native端获取json文件的配置
  _getGitUriConfFile() async {
    var path = await TransBridgeChannel.getGitConfFile();
    println("path = $path");
    if (path == null || path is! String) {
      TransBridgeChannel.showToast(StrsToast.cancelConfFileSelected());
    } else {
      try {
        String jsonStr = await File(path).readAsString();
        println("jsonStr:\n$jsonStr");
        Map<String, dynamic> map = JsonUtil.decode(jsonStr);
        println("map:\n$map");
        _fillGitConf(map);
      } catch (e) {
        TransBridgeChannel.showToast(
            "${StrsToast.parseConfFileError()}：${e.toString()}");
      }
    }
  }

  ///解析出来
  ///gitUri
  ///targetDir
  ///authenticationWay
  ///account
  ///pwd
  ///priKey
  ///pubKey
  ///priKeyPassword
  _fillGitConf(Map<String, dynamic> map) {
    try {
      _gitUriController.text = map['gitUri'];
      _gitTargetDirController.text = map['targetDir'];
      _clearAllFocus();
      int way = map['authenticationWay'];
      if (way == AuthenticationWay.KEY_PAIR) {
        _priKeyController.text = Base64Util.decodeBase64(map['priKey']);
        _pubKeyController.text = Base64Util.decodeBase64(map['pubKey']);
        _priPassController.text =
            Base64Util.decodeBase64(map['priKeyPassword']);
        _authenticationWay = way;
        setState(() {});
        _clearAllFocus();
        TransBridgeChannel.showToast(StrsToast.fillConfFileSuccess());
      } else if (way == AuthenticationWay.ACCOUNT_AND_PWD) {
        _accountController.text = Base64Util.decodeBase64(map['account']);
        _pwdController.text = Base64Util.decodeBase64(map['pwd']);
        _authenticationWay = way;
        setState(() {});
        _clearAllFocus();
        TransBridgeChannel.showToast(StrsToast.fillConfFileSuccess());
      } else {
        TransBridgeChannel.showToast(
            "${StrsToast.parseFail()}：map['authenticationWay'] = $way");
      }
    } catch (e) {
      println(e);
      TransBridgeChannel.showToast("${StrsToast.parseFail()}：$e");
    }
  }

  _buildGitLocalRepoNameInput() {
    return Container(
      height: 90.px2Dp,
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0),
      child: TextField(
        focusNode: _gitTargetDirFocus,
        controller: _gitTargetDirController,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
            hintText: StrsRepoConf.inputGitLocalRepo(),
            contentPadding: EdgeInsets.all(12.px2Dp),
            border: _buildInputBorder()),
        maxLines: 1,
        minLines: 1,
        style: AppTvStyles.textStyle16ColorMain(),
      ),
    );
  }

  ///保存git配置
  _saveReopConf() {
    //先判断git仓库是否为空
    if (_inputCheck()) {
      _showConfLoading();
      WReaderSqlHelper.queryGitUriExists(_gitUriController.text.trim())
          .then((_) {
        println("_ = $_");
        if (!_) {
          TransBridgeChannel.checkGitExists(
                  _gitUriController.text.trim(),
                  _gitRootDirController.getText().trim(),
                  _gitTargetDirController.text.trim())
              .then((result) {
            print("result = $result");
            if ('notExists' == result) {
              if (_authenticationWay == AuthenticationWay.CLONE_DIRECT) {
                _cloneDirect();
              } else if (_authenticationWay ==
                  AuthenticationWay.ACCOUNT_AND_PWD) {
                _cloneUseAccountAndPwd();
              } else if (_authenticationWay == AuthenticationWay.KEY_PAIR) {
                _cloneUseKeyPair();
              }
            } else {
              _gitLocalRepoExists();
            }
          });
          Navigator.of(context).pop();
        } else {
          TransBridgeChannel.showToast(StrsRepoConf.alreadyExistedUri());
          Navigator.of(context).pop();
        }
      });
    }
  }

  ///使用账号密码clone项目
  _cloneUseAccountAndPwd() {
    TransBridgeChannel.cloneUseAccountAndPwd(
            _gitUriController.text.trim(),
            _gitRootDirController.getText().trim(),
            _accountController.text.trim(),
            _pwdController.text.trim(),
            repoName: _gitTargetDirController.text.trim())
        .then((result) {
      print("result = $result");
      Map<String, dynamic> map = JsonUtil.decode(result);
      if ('success' == map['result']) {
        _saveRepoConf2Db(
            AuthenticationWay.ACCOUNT_AND_PWD, map['currentBranch']);
        TransBridgeChannel.showToast(StrsToast.cloneSuccess());
      } else {
        TransBridgeChannel.showToast(StrsToast.parseFail());
      }
    });
  }

  bool _inputCheck() {
    if (_gitUriController.text.trim().isEmpty ||
        !(_gitUriController.text.trim().endsWith('.git'))) {
      TransBridgeChannel.showToast(StrsRepoConf.illegalGitUri());
      return false;
    }
    if (_authenticationWay == AuthenticationWay.ACCOUNT_AND_PWD) {
      if (_accountController.text.trim().isEmpty ||
          _pwdController.text.trim().isEmpty) {
        TransBridgeChannel.showToast(StrsRepoConf.illegalAccountAndPwd());
        return false;
      }
    }
    if (_authenticationWay == AuthenticationWay.KEY_PAIR) {
      if (_priKeyController.text.trim().isEmpty ||
          _pubKeyController.text.trim().isEmpty) {
        TransBridgeChannel.showToast(StrsRepoConf.illegalKeyPair());
        return false;
      }
    }
    return true;
  }

  ///当前 url git 仓库的本地仓库已存在，更改本地仓库名称或作其他操作
  _gitLocalRepoExists() {
    TransBridgeChannel.showToast(
        'git target dir already existed,please input a new target dir.');
    _clearAllFocus();
    FocusScope.of(context).requestFocus(_gitTargetDirFocus);
  }

  _cloneUseKeyPair() {
    TransBridgeChannel.cloneUseKeyPair(
            _gitUriController.text.trim(),
            _gitRootDirController.getText().trim(),
            _priKeyController.text.trim(),
            _pubKeyController.text.trim(),
            repoName: _gitTargetDirController.text.trim(),
            priKeyPass: _priPassController.text.trim())
        .then((result) {
      print("result = $result");
      Map<String, dynamic> map = JsonUtil.decode(result);
      if ('success' == map['result']) {
        _saveRepoConf2Db(AuthenticationWay.KEY_PAIR, map['currentBranch']);
        TransBridgeChannel.showToast(StrsToast.cloneSuccess());
      } else {
        TransBridgeChannel.showToast(StrsToast.cloneFail());
      }
    });
  }

  _saveRepoConf2Db(int authenticationWay, String currentBranch) {
    Map<String, dynamic> map = HashMap();
    if (authenticationWay == AuthenticationWay.ACCOUNT_AND_PWD) {
      //String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
      map['account'] = _accountController.text.trim();
      map['pwd'] = _pwdController.text.trim();
    } else if (authenticationWay == AuthenticationWay.KEY_PAIR) {
      //String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
      map['priKey'] = _priKeyController.text.trim();
      map['pubKey'] = _pubKeyController.text.trim();
      map['priKeyPass'] = _priPassController.text.trim();
    }
    var targetDir = _gitTargetDirController.text.trim();
    var gitUri = _gitUriController.text.trim();
    if (targetDir.isEmpty) {
      targetDir = gitUri.substring(
          gitUri.lastIndexOf('/') + 1, gitUri.lastIndexOf('.'));
    }
    WReaderSqlHelper.insertRepoConf(
            _gitUriController.text.trim(),
            _gitRootDirController.getText().trim(),
            "$targetDir",
            authenticationWay,
            JsonUtil.encode(map),
            currentBranch)
        .then((_) {
      if (_) {
        TransBridgeChannel.showToast(StrsToast.saveSuccess());
        FluroRouter.navigateTo(
            context,
            "${RouteNames.REPO_DETAILS}?"
            "gitLocalDir=${Uri.encodeComponent("${_gitRootDirController.getText().trim()}/$targetDir")}"
            "&gitUri=${Uri.encodeComponent("${_gitUriController.text.trim()}")}",
            replace: true);
      } else {
        TransBridgeChannel.showToast(StrsToast.repoDbDataInsertFail());
      }
    });
  }

  ///直接克隆
  _cloneDirect() {
    TransBridgeChannel.cloneDirect(
            _gitUriController.text.trim(),
            _gitRootDirController.getText().trim(),
            _gitTargetDirController.text.trim())
        .then((result) {
      print("result = $result");
    });
  }

  ///git本地仓库存放地址选择栏
  _buildLocalPathSelectBar(context) {
    Text(
      _gitRootDirController.getText(),
      style: AppTvStyles.textStyle14Color66(),
      maxLines: 3,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
    return Container(
      width: double.infinity,
      alignment: Alignment(-1, 0),
      height: 140.px2Dp,
      padding: EdgeInsets.all(12.px2Dp),
      color: AppColors.COLOR_EDIT_BG,
      margin: EdgeInsets.fromLTRB(30.px2Dp, 6.px2Dp, 30.px2Dp, 0),
      child: Text(
        _gitRootDirController.getText(),
        style: AppTvStyles.textStyle16ColorMain(),
        maxLines: 3,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }

  ///显示正在加载中的dialog
  _showConfLoading() {
    showDialog(
        context: context,
        builder: (_) {
          return WillPopScope(
              child: Container(
                decoration: CommonDecoration.commonRoundDecoration(),
                width: SizeUtil.designsWidthPx,
                margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
                height: 120.px2Dp,
                child: Center(
                  child: Text('配置仓库中，请稍候'),
                ),
              ),
              onWillPop: () {
                return Future.value(false);
              });
        });
  }

  ///展示git本地存放地址详情
  _showLocalPathInfo() {
    showDialog(
        context: context,
        builder: (_) {
          return Center(
            child: Container(
              width: SizeUtil.deviceWidth,
              margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
              padding: EdgeInsets.all(20.px2Dp),
              decoration: CommonDecoration.commonRoundDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _gitRootDirController.getText(),
                    style: AppTvStyles.textStyle16ColorMain(true),
                  ),
                  SizedBox(
                    height: 10.px2Dp,
                  ),
                  Center(
                    child: RaisedButton(
                      child: Text(
                        StrsRepoConf.clickAndCopy(),
                        style: AppTvStyles.textStyle16ColorMain(),
                      ),
                      onPressed: () {
                        ClipboardData data = new ClipboardData(
                            text: _gitRootDirController.getText());
                        Clipboard.setData(data);
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  ///构建鉴权方式的选择方式
  Widget _buildAuthWay(BuildContext context) {
    return Center(
      child: Container(
        width: SizeUtil.deviceWidth,
        margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
        padding: EdgeInsets.all(20.px2Dp),
        decoration: CommonDecoration.commonRoundDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //暂时不支持Github那种 git://xxx  的形式
            // FlatButton(
            //   child: Text(StrsAuthenticationWay.way(AuthencationWay.CLONE_DIRECT)),
            //   onPressed: () {
            //     Navigator.pop(context, AuthencationWay.CLONE_DIRECT);
            //   },
            // ),
            // Container(
            //   width: double.maxFinite,
            //   color: Colors.grey,
            //   height: 2.px2Dp,
            // ),

            FlatButton(
              child: Text(StrsAuthenticationWay.way(AuthenticationWay.KEY_PAIR),
                  style: AppTvStyles.textStyle14ColorMain()),
              onPressed: () {
                Navigator.pop(context, AuthenticationWay.KEY_PAIR);
              },
            ),
            Container(
              width: double.maxFinite,
              color: Colors.grey,
              height: 2.px2Dp,
            ),
            FlatButton(
              child: Text(
                StrsAuthenticationWay.way(AuthenticationWay.ACCOUNT_AND_PWD),
                style: AppTvStyles.textStyle14ColorMain(),
              ),
              onPressed: () {
                Navigator.pop(context, AuthenticationWay.ACCOUNT_AND_PWD);
              },
            ),
          ],
        ),
      ),
    );
  }

  ///鉴权方式展示栏
  _buildAuthenticateSelectBar(context) {
    return Container(
      width: SizeUtil.deviceWidth,
      height: 80.px2Dp,
      margin: EdgeInsets.fromLTRB(30.px2Dp, 6.px2Dp, 30.px2Dp, 0.px2Dp),
      alignment: Alignment(-1, 0),
      child: TextSelector(
        _authenticateController,
        onPress: _selectAuthenticate,
        alignment: Alignment(-1, 0),
        defaultStyle: AppTvStyles.textStyle16ColorMain(),
        padding: EdgeInsets.only(left: 10.px2Dp, right: 10.px2Dp),
        defaultColor: AppColors.COLOR_EDIT_BG,
        pressingColor: AppColors.COLOR_6E,
      ),
    );
  }

  ///选择鉴权方式
  _selectAuthenticate() {
    ///记录选择鉴权方式前的输入法焦点
    _lastFocus = _getLastFocusNode(_authenticationWay);
    showDialog(
      context: context,
      builder: _buildAuthWay,
    ).then((index) {
      if (index == null || !(index is int)) {
        return;
      }
      _authenticationWay = index;
      print("_authenticationWay = $_authenticationWay");
      setState(() {
        _authenticateController
            .setText(StrsAuthenticationWay.way(_authenticationWay));
        _clearAllFocus();
        _reopenKeyborad(index);
      });
    });
  }

  ///重新打开软键盘
  _reopenKeyborad(index) {
    if (_lastFocus != null) {
      if (_lastFocus == _gitUriFocus || _lastFocus == _gitTargetDirFocus) {
        FocusScope.of(context).requestFocus(_lastFocus);
      } else {
        switch (index) {
          case AuthenticationWay.ACCOUNT_AND_PWD:
            if (_lastFocus == _accountFocus || _lastFocus == _pwdFocus) {
              FocusScope.of(context).requestFocus(_lastFocus);
            } else {
              FocusScope.of(context).requestFocus(_accountFocus);
            }
            break;
          case AuthenticationWay.KEY_PAIR:
            if (_lastFocus != _accountFocus && _lastFocus != _pwdFocus) {
              FocusScope.of(context).requestFocus(_lastFocus);
            } else {
              FocusScope.of(context).requestFocus(_priKeyFocus);
            }
            break;
          default:
            break;
        }
      }
    } else {
      switch (index) {
        case AuthenticationWay.ACCOUNT_AND_PWD:
          FocusScope.of(context).requestFocus(_accountFocus);
          break;
        case AuthenticationWay.KEY_PAIR:
          FocusScope.of(context).requestFocus(_priKeyFocus);
          break;
        default:
          break;
      }
    }
  }

  _clearAllFocus() {
    //清空所有焦点，优化交互体验
    _gitUriFocus.unfocus();
    _gitTargetDirFocus.unfocus();
    _accountFocus.unfocus();
    _pwdFocus.unfocus();

    _priKeyFocus.unfocus();
    _pubKeyFocus.unfocus();
    _priPassFocus.unfocus();
  }

  FocusNode _getLastFocusNode(int index) {
    if (_gitUriFocus.hasFocus) {
      return _gitUriFocus;
    }
    if (_gitTargetDirFocus.hasFocus) {
      return _gitTargetDirFocus;
    }
    switch (index) {
      case AuthenticationWay.ACCOUNT_AND_PWD:
        if (_accountFocus.hasFocus) {
          return _accountFocus;
        }
        if (_pwdFocus.hasFocus) {
          return _pwdFocus;
        }
        return null;
      case AuthenticationWay.KEY_PAIR:
        if (_priKeyFocus.hasFocus) {
          return _priKeyFocus;
        }
        if (_pubKeyFocus.hasFocus) {
          return _pubKeyFocus;
        }
        if (_priPassFocus.hasFocus) {
          return _priPassFocus;
        }
        return null;
      default:
        return null;
    }
  }

  ///git地址的输入框
  _buildGitUriInput(context) {
    return Container(
      width: SizeUtil.deviceWidth,
      height: 140.px2Dp,
      margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0),
      child: TextField(
        controller: _gitUriController,
        focusNode: _gitUriFocus,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
            hintText: StrsRepoConf.gitUriHint(),
            contentPadding: EdgeInsets.all(12.px2Dp),
            border: _buildInputBorder()),
        maxLines: 3,
        minLines: 3,
        style: AppTvStyles.textStyle16ColorMain(),
      ),
    );
  }

  _buildInputBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.px2Dp)));
  }

  ///账号密码登录
  _buildAccountAndPwd() {
    return Offstage(
      child: Container(
        margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 90.px2Dp,
              width: double.infinity,
              child: TextField(
                focusNode: _accountFocus,
                controller: _accountController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    hintText: StrsRepoConf.inputAccount(),
                    contentPadding: EdgeInsets.all(12.px2Dp),
                    border: _buildInputBorder()),
                style: AppTvStyles.textStyle16ColorMain(),
              ),
            ),
            _buildCommonGap(),
            Container(
              height: 90.px2Dp,
              width: double.infinity,
              child: TextField(
                focusNode: _pwdFocus,
                keyboardType: TextInputType.url,
                controller: _pwdController,
                obscureText: true,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: StrsRepoConf.inputPwd(),
                    contentPadding: EdgeInsets.all(12.px2Dp),
                    border: _buildInputBorder()),
                style: AppTvStyles.textStyle16ColorMain(),
              ),
            ),
            _buildCommonGap(),
          ],
        ),
      ),
      offstage: _authenticationWay != 1,
    );
  }

  ///键值对验证
  _buildKeyPair() {
    return Offstage(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 140.px2Dp,
              width: double.infinity,
              child: TextField(
                focusNode: _priKeyFocus,
                controller: _priKeyController,
                maxLines: 10000,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    hintText: StrsRepoConf.inputPriKey(),
                    contentPadding: EdgeInsets.all(12.px2Dp),
                    border: _buildInputBorder()),
                style: AppTvStyles.textStyle16ColorMain(),
              ),
            ),
            _buildCommonGap(),
            Container(
              height: 140.px2Dp,
              width: double.infinity,
              child: TextField(
                maxLines: 10000,
                focusNode: _pubKeyFocus,
                controller: _pubKeyController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    hintText: StrsRepoConf.inputPubKey(),
                    contentPadding: EdgeInsets.all(12.px2Dp),
                    border: _buildInputBorder()),
                style: AppTvStyles.textStyle16ColorMain(),
              ),
            ),
            _buildCommonGap(),
            Container(
              height: 90.px2Dp,
              width: double.infinity,
              child: TextField(
                maxLines: 1,
                focusNode: _priPassFocus,
                obscureText: true,
                controller: _priPassController,
                decoration: InputDecoration(
                    hintText: StrsRepoConf.inputKeyPassphrase(),
                    contentPadding: EdgeInsets.all(12.px2Dp),
                    border: _buildInputBorder()),
                keyboardType: TextInputType.url,
                style: AppTvStyles.textStyle16ColorMain(),
              ),
            ),
            _buildCommonGap(),
          ],
        ),
      ),
      offstage: _authenticationWay != 2,
    );
  }

  @override
  void deactivate() {
    if (ModalRoute.of(context).isCurrent) {
      //回到当前页面了
      _reopenKeyborad(_authenticationWay);
    } else {
      _clearAllFocus();
    }
    super.deactivate();
  }
}
