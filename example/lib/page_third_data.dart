/// 创建时间：2020/8/2
/// 作者：Gavin
/// 描述：

class Page {
  Page({this.label});

  final String label;

  String get id => label[0];

  @override
  String toString() => '$runtimeType("$label")';
}

class CardData {
  const CardData({this.title, this.imageAsset, this.imageAssetPackage});

  final String title;
  final String imageAsset;
  final String imageAssetPackage;
}

final Map<Page, List<CardData>> allPages = <Page, List<CardData>>{
  Page(label: 'HOME'): <CardData>[
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
  ],
  Page(label: 'APPAREL'): <CardData>[
    const CardData(
      title: 'Cloud-White Dress',
      imageAsset: 'assets/images/dress.png',
      imageAssetPackage: "fac",
    ),
    const CardData(
      title: 'Ginger Scarf',
      imageAsset: 'assets/images/scarf.png',
      imageAssetPackage: "fac",
    ),
    const CardData(
      title: 'Blush Sweats',
      imageAsset: 'assets/images/sweats.png',
      imageAssetPackage: "fac",
    ),
  ],
};
