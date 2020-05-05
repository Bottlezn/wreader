import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';

class SearchReadingRecordState implements Cloneable<SearchReadingRecordState> {
  ///任务顺序,用于放弃掉一些之前触发的搜索.每次搜索都会自增 1 ,如果返回值不是当前的值清空数据
  int taskIndex = 0;

  ///最近阅读记录
  List<Map<String, dynamic>> readingRecord = <Map<String, dynamic>>[];

  SliverGridDelegateWithFixedCrossAxisCount sliverDelegate;
  TextEditingController searchController;
  FocusNode searchFocusNode;

  @override
  SearchReadingRecordState clone() {
    return SearchReadingRecordState()
      ..taskIndex = this.taskIndex
      ..readingRecord = this.readingRecord
      ..sliverDelegate = this.sliverDelegate
      ..searchController = this.searchController
      ..searchFocusNode = this.searchFocusNode;
  }
}

SearchReadingRecordState initState(Map<String, dynamic> args) {
  return SearchReadingRecordState()
    ..taskIndex = 0
    ..sliverDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 20.px2Dp,
        crossAxisSpacing: 20.px2Dp)
    ..searchController = TextEditingController()
    ..searchFocusNode = FocusNode();
}
