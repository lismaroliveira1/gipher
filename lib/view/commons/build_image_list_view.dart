import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../view.dart';
import './commons.dart';

Widget buildImageListView({
  @required Future<void> Function() getMoreImages,
  @required List<Map> imageList,
  @required bool isSearch,
  @required String searchName,
  @required Function closeCallback,
  @required Function editImageTitleDialog,
  @required Function(Map imageMap) moveToBlakiList,
  @required BuildContext context,
  @required Function(Map imageMap) saveImage,
  @required Function(Map imageMap) deleteImage,
  @required Function(Map imageMap) shareImage,
  @required Function shareByFacebook,
  @required Function shareByInstagram,
  @required Function shareByWhatsApp,
  @required Function shareByTwitter,
  @required Function shareByMessenger,
  @required Map appsInstalleds,
}) {
  return Container(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: LazyLoadScrollView(
      onEndOfPage: () async => getMoreImages(),
      child: ListView(
        children: <Widget>[
          isSearch
              ? builResultInformationSearch(searchName, closeCallback)
              : Container(),
          Column(
            children: imageList
                .map(
                  (imageGif) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        hideKeyboard(context: context);
                      },
                      child: OpenContainer(
                        transitionDuration: Duration(milliseconds: 300),
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedBuilder: (context, action) =>
                            builListTileClosedWidget(imageGif['image']),
                        openBuilder: (context, action) {
                          List<Map<dynamic, dynamic>> _flag =
                              imageGif['relateds'];
                          return builListTileOpenedWidget(
                            imageGif: imageGif,
                            context: context,
                            editImageTitleDialog: editImageTitleDialog,
                            moveToBlakiList: (imageGif) =>
                                moveToBlakiList(imageGif),
                            listRelatedImagesMap: _flag,
                            deleteImage: (imageMap) => deleteImage(imageMap),
                            saveImage: (imageMap) => saveImage(imageMap),
                            shareImage: (imageMap) => shareImage(imageMap),
                            appsInstalleds: appsInstalleds,
                            shareByFacebook: (imageMap) =>
                                shareByFacebook(imageMap),
                            shareByInstagram: (imageMap) =>
                                shareByInstagram(imageMap),
                            shareByWhatsApp: (imageMap) =>
                                shareByWhatsApp(imageMap),
                            shareByTwitter: (imageMap) =>
                                shareByTwitter(imageMap),
                            shareByMessenger: (imageMap) =>
                                shareByMessenger(imageMap),
                          );
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}
