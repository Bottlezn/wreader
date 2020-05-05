import 'package:fish_redux/fish_redux.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class SearchReadingRecordPage extends Page<SearchReadingRecordState, Map<String, dynamic>> {
  SearchReadingRecordPage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<SearchReadingRecordState>(
                adapter: null,
                slots: <String, Dependent<SearchReadingRecordState>>{
                }),
            middleware: <Middleware<SearchReadingRecordState>>[
            ],);

}
