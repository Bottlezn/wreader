import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/common_widgets.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';
import 'package:wreader_flutter_module/widget/repo_list_view.dart';

class RepoListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RepoListState();
}

class _RepoListState extends State<RepoListPage> {
  bool _isLoading = true;

  List<RepoPreviewItem> _items = <RepoPreviewItem>[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queryRepoItems();
    });
    super.initState();
  }

  _queryRepoItems() async {
    WReaderSqlHelper.queryRepoPreItems().then((list) {
      _items.clear();
      _items.addAll(list);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void deactivate() {
    try {
      if (ModalRoute.of(context).isCurrent) {
        _queryRepoItems();
      } else {
        println('deactivate()');
      }
    } catch (e) {
      println(e);
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EzAppBar.buildCenterTitleAppBar(StrsRepoList.title(), context,
          actions: <Widget>[
            SizedBox(
              height: 98.px2Dp,
              child: EzSelector(
                Padding(
                  padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
                  child: Image.asset(
                    'assets/images/icon_add_new.png',
                    width: 42.px2Dp,
                    height: 42.px2Dp,
                  ),
                ),
                () {
                  FluroRouter.navigateTo(context, RouteNames.REPO_CONF);
                },
                defaultColor: Colors.transparent,
                pressColor: AppColors.COLOR_TRANS_20,
              ),
            )
          ]),
      body: _isLoading ? CommonWidgets.buildLoadingPage() : _buildContent(),
    );
  }

  ///如果列表为空，显示空视图
  Widget _buildContent() {
    return _items.isEmpty
        ? Container(
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
          )
        : _buildList();
  }

  Widget _buildList() {
    return CommonRepoListViewHelper.buildCommonRepoListView(_items);
  }
}
