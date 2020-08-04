import 'package:example/page_third_data.dart';
import 'package:example/widgets/loading_page.dart';
import 'package:pikachu_fac/pikachu_fac.dart';
import 'package:flutter/cupertino.dart';

class PageModel {
  int count = 0;
  String appBarTitle = 'TabSecond';
  String dataFromNetwork = '';
  int currentTabIndex = 0;
}

class ThirdPageModel {
  int index = 0;
  final Map<Page, List<CardData>> allPages = {};
}

class PageViewModel extends ViewModel {
  LiveState<PageModel> pageModel = LiveState<PageModel>(PageModel());
  LiveState<ThirdPageModel> thirdPageModel = LiveState<ThirdPageModel>(ThirdPageModel());
  int _stateCount = 0;

  static PageViewModel get(BuildContext context) {
    return ViewModel.of<PageViewModel>(
      context,
      builder: () => PageViewModel(),
    );
  }

  void onCountClick(BuildContext context) {
    PageViewModel.get(context).pageModel.setState((value, _) {
      _.state.count++;
    });
  }

  void loadFirstData(BuildContext context) {
    _load(context);
  }

  void loadThirdData(BuildContext context, {String instance}) {
    _load(context, instance: instance);
  }

  void _load(BuildContext context, {String instance}) {
    void _initPageState(BuildContext context) {
      PkcPageViewModel.get(context, instance: instance).pageLiveData.setState((value, _) {
        value.pageState = PkcPageState.state_loading;
      });
    }

    ///set first page loading page state
    void _setFirstPageState(BuildContext context) {
      var random = (_stateCount++) % 3;
      PkcPageViewModel.get(context, instance: instance).pageLiveData.setState((value, _) {
        switch (random) {
          case 0:
            value.pageState = PkcPageState.state_empty;
            break;
          case 1:
            value.pageState = PkcPageState.state_failure;
            break;
          case 2:
            value.pageState = PkcPageState.state_success;
            break;
        }
      });
    }

    void _fetchNetworkData() {
      Future.delayed(Duration(milliseconds: 500), () {
        pageModel.setState((value, _live) {
          _setFirstPageState(context);
          _live.state.dataFromNetwork = 'this is data from netWork';
        });
      });
    }

    _initPageState(context);
    _fetchNetworkData();
  }
}
