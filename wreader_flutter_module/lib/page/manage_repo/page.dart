import 'package:fish_redux/fish_redux.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class ManageGitRepoPage extends Page<ManageGitRepoState, Map<String, dynamic>> {
  ManageGitRepoPage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<ManageGitRepoState>(
                adapter: null,
                slots: <String, Dependent<ManageGitRepoState>>{
                }),
            middleware: <Middleware<ManageGitRepoState>>[
            ],);

}
