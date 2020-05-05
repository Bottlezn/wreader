import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wreader_flutter_module/consts/dependent_libs.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/common_widgets.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';

class AboutMePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutMeState();
}

class _AboutMeState extends State<AboutMePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          EzAppBar.buildCenterTitleAppBar(StrsSetting.aboutWReader(), context),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20.px2Dp,
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10.px2Dp)),
              child: Image.asset(
                'assets/images/icon_about_wreader.png',
                width: SizeUtil.deviceWidth / 3.0,
                height: SizeUtil.deviceWidth / 3.0,
              ),
            ),
            SizedBox(
              height: 20.px2Dp,
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList() {
    List<Widget> list = <Widget>[
      Container(
        width: double.infinity,
        color: Colors.black12,
        padding: EdgeInsets.fromLTRB(30.px2Dp, 20.px2Dp, 30.px2Dp, 20.px2Dp),
        child: Text(
          StrsSetting.projectInfo(),
          style: AppTvStyles.textStyle16ColorMain(),
        ),
      ),
      _buildTitleAndInfoBar(StrsSetting.author(), '悟笃笃/王展鸿'),
      CommonWidgets.buildDivider(
          margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp)),
      _buildTitleAndInfoBar('Email：', 'wdu_udw@163.com', onClick: () {
        Clipboard.setData(ClipboardData(text: 'wdu_udw@163.com'));
        TransBridgeChannel.showToast(StrsSetting.replicated());
      }),
      CommonWidgets.buildDivider(
          margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp)),
      _buildTitleAndInfoBar(
          '${StrsSetting.githubSite()}：', 'https://github.com/Bottlezn/wreader',
          onClick: () {
        TransBridgeChannel.openUrl('https://github.com/Bottlezn/wreader');
      }),
      CommonWidgets.buildDivider(
          margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp)),
      _buildTitleAndInfoBar('${StrsSetting.mainSite()}：',
          'https://juejin.im/user/5d779057e51d4557ca7fddc2/posts', onClick: () {
        TransBridgeChannel.openUrl(
            'https://juejin.im/user/5d779057e51d4557ca7fddc2/posts');
      }),
      Container(
        width: double.infinity,
        color: Colors.black12,
        padding: EdgeInsets.fromLTRB(30.px2Dp, 20.px2Dp, 30.px2Dp, 20.px2Dp),
        child: Text(
          StrsSetting.dependentTitle(),
          style: AppTvStyles.textStyle16ColorMain(),
        ),
      ),
    ];
    list.add(Container(
      alignment: Alignment(-1, 0),
      padding: EdgeInsets.fromLTRB(30.px2Dp, 20.px2Dp, 30.px2Dp, 20.px2Dp),
      child: Text(
        StrsSetting.thanks(),
        style: AppTvStyles.textStyle16ColorMain(true),
      ),
    ));
    list.add(CommonWidgets.buildDivider(
        margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp)));
    DEPENDENT_LIBS.forEach((name) {
      list.add(Container(
        alignment: Alignment(-1, 0),
        padding: EdgeInsets.fromLTRB(30.px2Dp, 20.px2Dp, 30.px2Dp, 20.px2Dp),
        child: Text(
          name,
          style: AppTvStyles.textStyle16ColorMain(),
        ),
      ));
      list.add(CommonWidgets.buildDivider(
          margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp)));
    });
    list.removeLast();
    return list;
  }

  _buildTitleAndInfoBar(String title, String content, {Function onClick}) {
    return InkWell(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(30.px2Dp, 20.px2Dp, 30.px2Dp, 20.px2Dp),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: AppTvStyles.textStyle16ColorMain(),
            ),
            Expanded(
              flex: 1,
              child: Text(
                content,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: AppTvStyles.textStyle16ColorMain(),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        if (onClick != null) {
          onClick();
        }
      },
    );
  }
}
