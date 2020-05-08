import 'package:fish_redux/fish_redux.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class RepoConfigPage extends Page<RepoConfigState, Map<String, dynamic>> {
  RepoConfigPage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<RepoConfigState>(
                adapter: null,
                slots: <String, Dependent<RepoConfigState>>{
                }),
            middleware: <Middleware<RepoConfigState>>[
            ],);

}
