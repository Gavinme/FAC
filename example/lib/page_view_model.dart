import 'package:example/page_third_data.dart';
import 'package:example/widgets/loading_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikachu_fac/pikachu_fac.dart';

class PageModel {
  int count = 0; //
  String appBarTitle = 'TabSecond';
  String dataFromNetwork = '';
  int currentTabIndex = 0;
  bool check = false;
}

class _ThirdPageModel {
  int index = 0;
  final Map<Page, List<CardData>> allPages = {};
}

class PageViewModel extends ViewModel {
  LiveState<PageModel> _pageModel = LiveState<PageModel>(PageModel());
  LiveState<_ThirdPageModel> _thirdPageModel =
      LiveState<_ThirdPageModel>(_ThirdPageModel());
  MediatorLiveState<int> _mediatorLiveState = MediatorLiveState(0);
  LiveState<List<CardData>> pageList =
      LiveState<List<CardData>>(List<CardData>());

  MediatorLiveState<int> get mediatorLiveState => _mediatorLiveState;
  int _stateCount = 0;

  LiveState<PageModel> get pageModel => _pageModel;

  static PageViewModel get(BuildContext context) {
    return ViewModel.of<PageViewModel>(
      context,
      builder: () => PageViewModel(),
    );
  }

  void onInputValueChanged(String input) {
    this._pageModel.setState((st, o) => o.state.appBarTitle = input);
  }

  String getTabIndex() {
    return (_thirdPageModel.getState().index == 0) ? 'HOME' : 'APPAREL';
  }

  void setTabIndex(int index) {
    _thirdPageModel.setState((st, _) => st.index = index);
  }

  void onCountClick(BuildContext context) {
    PageViewModel.get(context)._pageModel.setState((value, _) {
      _.state.count++;
    });
  }

  void loadFirstData(BuildContext context) {
    _load(context);
  }

  void loadThirdData(BuildContext context, {String instance}) {
    _load(context, instance: instance);
  }

  void loadListPage(BuildContext context) {
    FacPageViewModel.get(context).showLoadingWidget();

    Future.delayed(Duration(milliseconds: 1000), () {
      FacPageViewModel.get(context).showSuccessWidget();
      pageList.setState((st, o) => o.state = _pages);
    });
  }

  void _load(BuildContext context, {String instance}) {
    void _initPageState(BuildContext context) {
      FacPageViewModel.get(context, instance: instance).showLoadingWidget();
    }

    ///set first page loading page state
    void _setFirstPageState(BuildContext context) {
      var random = (_stateCount++) % 3;
      switch (random) {
        case 0:
          FacPageViewModel.get(context, instance: instance).showEmptyWidget();
          break;
        case 1:
          FacPageViewModel.get(context, instance: instance).showFailWidget();
          break;
        case 2:
          FacPageViewModel.get(context, instance: instance).showSuccessWidget();
          break;
      }
    }

    void _fetchNetworkData() {
      Future.delayed(Duration(milliseconds: 500), () {
        _pageModel.setState((value, _live) {
          _setFirstPageState(context);
          _live.state.dataFromNetwork = 'this is data from netWork';
        });
      });
    }

    _initPageState(context);

    _fetchNetworkData();
  }

  ///测试 数据源合并
  void testMediaSource() {
    _mediatorLiveState.addSource<PageModel>(_pageModel, (v) {
      print('_mediatorLiveState addSource,on Count changed!');
      _mediatorLiveState.setState((_s, _o) {
        _o.state = v.count;
      });
    }, memo: (_st) => [_st.count]);
  }

  ///测试 数据源转换
  void testTransformations() {
    _mediatorLiveState =
        Transformations.map(_pageModel, _mediatorLiveState, (v) {
      _mediatorLiveState.setState((_s, _o) {
        _o.state = v.count * 2;
        print('map:${_o.state}');
      });
    });
  }

  void onCheckedChanged(bool value) {
    _pageModel.setState((_, o) => o.state.check = value);
  }
}

var _pages = <CardData>[
  const CardData(
    title: 'Flatwear',
    imageAsset: 'assets/images/flatwear.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Pine Table',
    imageAsset: 'assets/images/table.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Blue Cup',
    imageAsset: 'assets/images/cup.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Tea Set',
    imageAsset: 'assets/images/teaset.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Desk Set',
    imageAsset: 'assets/images/deskset.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Blue Linen Napkins',
    imageAsset: 'assets/images/napkins.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Planters',
    imageAsset: 'assets/images/planters.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Kitchen Quattro',
    imageAsset: 'assets/images/kitchen_quattro.png',
    imageAssetPackage: "fac",
  ),
  const CardData(
    title: 'Platter',
    imageAsset: 'assets/images/platter.png',
    imageAssetPackage: "fac",
  ),
];
