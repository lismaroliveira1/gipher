import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:gifs_to_win/presenter/getx_saved_presenter.dart';

import '../view.dart';

class GifSavedPage extends StatelessWidget {
  final GetXSavedPresenter presenter;
  GifSavedPage({@required this.presenter});

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    ScaffoldMessengerState _snackBarContext = ScaffoldMessenger.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
      ),
      drawer: CurstomDrawer(presenter.jumpToPage),
      body: Builder(
        builder: (context) {
          presenter.jumpToStream.listen((page) {
            if (page?.isNotEmpty == true) {
              Get.offAllNamed(page);
            }
          });
          return Obx(
            () => Column(
              children: [
                Container(
                  height: 80,
                  child: Form(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onTap: () => _snackBarContext.hideCurrentSnackBar(),
                        decoration: InputDecoration(
                          labelText: 'Pesquisar',
                          labelStyle: TextStyle(
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: buildImageListView(presenter.imageSavedListStream),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
