import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/consts/file_type.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/file_helper.dart';
import 'package:wreader_flutter_module/utils/common/json_util.dart';
import 'package:wreader_flutter_module/utils/reading/reading.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/common_widgets.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';

class LogListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LogListState();
}

class _LogListState extends State<LogListPage> {
  bool _isLoading = true;

  List<FileInfo> _logs = List();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogData();
    });
    super.initState();
  }

  _loadLogData() async {
    String dirList = await TransBridgeChannel.getLogDir();
    List<dynamic> list = JsonUtil.decode(dirList);
    _logs.clear();
    for (var dir in list) {
      var info = await FileHelper.loadFileInfos("$dir");
      println(info);
      if (info.childList?.isNotEmpty == true) {
        _logs.addAll(info.childList);
      }
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EzAppBar.buildCenterTitleAppBar(StrsLogList.title(), context,
          actions: <Widget>[
            SizedBox(
              height: 98.px2Dp,
              child: EzSelector(
                Padding(
                  padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
                  child: Image.asset(
                    'assets/images/icon_delete.png',
                    width: 42.px2Dp,
                    height: 42.px2Dp,
                  ),
                ),
                _showDeleteHint,
                defaultColor: Colors.transparent,
                pressColor: AppColors.COLOR_TRANS_20,
              ),
            ),
          ]),
      body: _buildBody(),
    );
  }

  _showDeleteHint() {
    if (_logs.isEmpty) {
      return;
    }
    showDialog(
        context: context,
        builder: (_) {
          return Center(
            child: Container(
              width: double.infinity,
              decoration: CommonDecoration.commonRoundDecoration(),
              margin: EdgeInsets.all(30.px2Dp),
              padding: EdgeInsets.all(20.px2Dp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    StrsLogList.deleteAll(),
                    style: AppTvStyles.textStyle16ColorMain(),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 20.px2Dp,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          onPressed: () async {
                            Navigator.pop(context, true);
                          },
                          child: Text(StrsManageRepo.delete()),
                        ),
                      ),
                      SizedBox(
                        width: 30.px2Dp,
                      ),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text(StrsManageRepo.cancel()),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }).then((_) {
      if (_ != null && _) {
        _clearAllLog();
      }
    });
  }

  _clearAllLog() async {
    showDialog(
        context: context,
        builder: (_) {
          return CommonWidgets.buildLoadingDialog(
              hint: StrsLogList.deleting(), cancelable: false);
        });
    for (var info in _logs) {
      await File(info.absoultPath).delete(recursive: true);
    }
    _logs.clear();
    Navigator.pop(context);
    setState(() {});
  }

  _clickLog(FileInfo info) {
    showLoadingAndRead(
        context, info.absoultPath, null, null, null, FileTypeConst.CODE,
        record: false);
  }

  _buildEmpty() {
    return Container(
      alignment: Alignment(0, -1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 80.px2Dp,
          ),
          Image.asset(
            'assets/images/icon_welcome.png',
            width: 260.px2Dp,
            height: 260.px2Dp,
          ),
          SizedBox(
            height: 20.px2Dp,
          ),
          Text(
            StrsRepoList.empty(),
            style: AppTvStyles.textStyle18Color69(),
          ),
          SizedBox(
            height: 60.px2Dp,
          ),
        ],
      ),
    );
  }

  _buildList() => ListView.separated(
      itemBuilder: (context, index) {
        final log = _logs[index];
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.all(30.px2Dp),
            width: double.infinity,
            child: Text(
              log.fileName,
              textAlign: TextAlign.left,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: AppTvStyles.textStyle16ColorMain(),
            ),
          ),
          onTap: () {
            _clickLog(log);
          },
        );
      },
      separatorBuilder: (context, index) {
        return CommonWidgets.buildDivider();
      },
      itemCount: _logs.length);

  _buildBody() {
    return _isLoading
        ? CommonWidgets.buildLoadingPage()
        : (_logs.isEmpty ? _buildEmpty() : _buildList());
  }
}
