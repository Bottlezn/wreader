import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/consts/global_action_name.dart';
import 'package:wreader_flutter_module/global_store/global_base_state.dart';
import 'package:wreader_flutter_module/global_store/global_store.dart';

import 'effect.dart';
import 'reducer.dart';
import 'state.dart';
import 'view.dart';

class SearchRepoFilePage extends Page<SearchRepoFileState, Map<String, dynamic>> {
  SearchRepoFilePage()
      : super(
            initState: initState,
            effect: buildEffect(),
            reducer: buildReducer(),
            view: buildView,
            dependencies: Dependencies<SearchRepoFileState>(
                adapter: null,
                slots: <String, Dependent<SearchRepoFileState>>{
                }),
            middleware: <Middleware<SearchRepoFileState>>[
            ],){
    //使用GlobalStore建立全局连接，用于处理亮暗模式变换和语言变化事件
    connectExtraStore<GlobalState>(GlobalStore.store,
            (Object pageState, GlobalState appState) {
          println("pageState = ${pageState.runtimeType.toString()}");
          println("appState.action= ${appState.action}");
          if (pageState is SearchRepoFileState && appState.action != null) {
            final Object copy = pageState.clone();
            final SearchRepoFileState newState = copy;
            switch (appState.action) {
              case GlobalActionName.LOAD_ENV:
                newState.languageCode = appState.languageCode;
                newState.brightnessMode = appState.brightnessMode;
                return newState;
              case GlobalActionName.SWITCH_LANGUAGE_CODE:
                newState.languageCode = appState.languageCode;
                return newState;
              case GlobalActionName.SWITCH_BRIGHTNESS_MODE:
                newState.brightnessMode = appState.brightnessMode;
                return newState;
              default:
                break;
            }
          }
          return pageState;
        });
  }

}
