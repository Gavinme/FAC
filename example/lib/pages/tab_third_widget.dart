// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/widgets/loading_page.dart';
import 'package:flutter/material.dart';

import '../page_third_data.dart';
import '../page_view_model.dart';

class CardDataItem extends StatelessWidget {
  const CardDataItem({this.page, this.data});

  static const double height = 272.0;
  final Page page;
  final CardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: page.id == 'H' ? Alignment.centerLeft : Alignment.centerRight,
              child: CircleAvatar(child: Text('${page.id}')),
            ),
            SizedBox(
              width: 144.0,
              height: 144.0,
              child: Image.asset(
                data.imageAsset,
//                package: data.imageAssetPackage,
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Text(
                data.title,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdTabWidget extends StatefulWidget {
  const ThirdTabWidget({Key key}) : super(key: key);

  @override
  ThirdTabWidgetState createState() => new ThirdTabWidgetState();
}

class ThirdTabWidgetState extends State<ThirdTabWidget> with AutomaticKeepAliveClientMixin {
  TabController tabController;
  var homeKey = PageStorageKey('HOME');
  var apparelKey = PageStorageKey('APPAREL');

  _onTabChange() {
    PageViewModel.get(context).thirdPageModel.setState((_state, owner) => _state.index = tabController?.index);
  }

  @override
  void initState() {
    tabController = TabController(
      length: allPages.length,
      vsync: ScrollableState(),
    )..addListener(_onTabChange);

    super.initState();
  }

  @override
  void dispose() {
    tabController?.removeListener(_onTabChange);
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              child: SliverAppBar(
                title: const Text('Tabs and scrolling'),
                pinned: true,
                expandedHeight: 150.0,
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  controller: tabController,
                  onTap: (index) {
                    print('onTap index: $index');
                  },
                  tabs: allPages.keys
                      .map<Widget>(
                        (page) => Tab(text: page.label),
                      )
                      .toList(),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          key: homeKey,
          controller: tabController,
          children: allPages.keys.map<Widget>((page) {
            print('TabBarView page${page.label}');

            return LoadingPageWidget(
              onInvokeLoaded: () => PageViewModel.get(context).loadThirdData(
                context,
                instance: (PageViewModel.get(context).thirdPageModel.getState().index == 0 ? 'HOME' : 'APPAREL'),
              ),
              key: page.label == 'HOME' ? homeKey : apparelKey,
              loadingVmName: page.label,
              failureWidget: Container(
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    'custom fail hint,click retry',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              emptyWidget: Container(
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    "Custom empty hint",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              childBuilder: (_, context) => SafeArea(
                top: false,
                bottom: false,
                child: _createScrollBuilder(page),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Builder _createScrollBuilder(Page page) {
  return Builder(
    builder: (BuildContext context) {
      return CustomScrollView(
        key: PageStorageKey<Page>(page),
        slivers: <Widget>[
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            sliver: SliverFixedExtentList(
              itemExtent: CardDataItem.height,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final CardData data = allPages[page][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    child: CardDataItem(
                      page: page,
                      data: data,
                    ),
                  );
                },
                childCount: allPages[page].length,
              ),
            ),
          ),
        ],
      );
    },
  );
}
