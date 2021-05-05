import 'dart:convert';

import 'package:get/get.dart';
import 'package:meta/meta.dart';

import '../model/model.dart';
import './presenter.dart';

class GetXHomePresenter extends GetxController {
  final ImageResults result;
  final CommonController commons;
  GetXHomePresenter({
    @required this.result,
    @required this.commons,
  });

  var _imageDetails = ImageModel(
    id: '',
    url: '',
    username: '',
    title: '',
    slug: '',
    rating: '',
    importDateTime: '',
    height: '',
    width: '',
    size: '',
  ).obs;

  var _navigateTo = RxString('/');
  var _jumpTo = RxString('/');
  var _imageList = <ImageModel>[].obs;
  var _imageListMap = <Map>[].obs;
  var _imageListSearchedMap = <Map>[].obs;
  var _imageListRelated = <ImageModel>[].obs;
  var _imageListSearched = <ImageModel>[].obs;
  var _imageListSaved = <ImageModel>[].obs;
  var _imageListDeleted = <ImageModel>[].obs;
  var _defaultLimit = 30.obs;
  var _isValidName = false.obs;
  var _errorTextDialog = RxString(null);

  List<ImageModel> get imageListStream => _imageList.toList();
  List<ImageModel> get imageListSearchedOut => _imageListSearched.toList();
  List<Map> get imageListMapOut => _imageListMap.toList();
  List<Map> get imageListSearchedMapOut => _imageListSearchedMap.toList();
  ImageModel get imageDetailsStream => _imageDetails.value;
  List<ImageModel> get imageListRelatedStream => [];
  Stream<String> get navigateToStream => _navigateTo.stream;
  Stream<String> get jumpToStream => _jumpTo.stream;
  String get errorTextDialogStream => _errorTextDialog.value;
  int get limitImageView => _defaultLimit.toInt();
  bool get isValidNameStream => _isValidName.value;

  @override
  void onInit() async {
    _navigateTo.value = '';
    clearValues();
    _imageList.value =
        await result.repository.getAll(limit: _defaultLimit.value, offset: 1);
    _imageList.forEach((element) {
      _imageListMap.add(element.toMap());
    });
    super.onInit();
  }

  void changeTotalPerPage(int limit) async {
    _defaultLimit.value = limit;
    _imageList.value =
        await result.repository.getAll(limit: _defaultLimit.value, offset: 1);
  }

  void changeViewMode(int limit) async {}

  Future<void> getMoreImages() async {
    var newList = await result.repository.getRandom();
    newList.forEach((element) {
      _imageList.add(element);
      _imageListMap.add(element.toMap());
    });
  }

  void editImage({@required String id, @required String title}) {
    _imageList.forEach((image) {
      if (image.id == id) {
        image.title = title;
      }
    });
  }

  void showGifDetails(Map imageMap) async {
    _imageDetails.value = ImageModel.fromMap(imageMap);
    Future.delayed(Duration(milliseconds: 250), () {
      _navigateTo.value = '';
      _navigateTo.value = '/details';
    });
    _imageListRelated.value =
        await result.repository.getImagesByName(imageMap['username']);
  }

  Future<void> saveImage({
    @required String id,
    @required String title,
    @required String url,
  }) async {
    List<Map> _flag = [];
    _imageListSaved.clear();
    _imageListSaved.value = await result.cache.readData('saved');
    _imageListSaved.forEach((element) {
      _flag.add({
        'id': element.id,
        'title': element.title,
        'url': element.url,
      });
    });
    _flag.add({
      'id': id,
      'title': title,
      'url': url,
    });
    await result.cache.writeData(jsonEncode(_flag), path: 'saved');
  }

  Future<void> deleteImage({
    @required String id,
    @required String title,
    @required String url,
  }) async {
    _imageListDeleted.add(ImageModel.fromMap({
      'id': id,
      'title': title,
      'url': url,
    }));
    await result.cache.writeData(jsonEncode({}), path: 'deleted');
  }

  validateDialogName(String value) {
    final validationResult = commons.validateName(value);
    _isValidName.value = validationResult['isValidName'];
    _errorTextDialog.value = validationResult['errorTextDialog'];
  }

  validateSearchName(String value) {
    final validationResult = commons.validateName(value);
    _isValidName.value = validationResult['isValidName'];
    _errorTextDialog.value = validationResult['errorTextDialog'];
    if (_isValidName.value) {}
  }

  void makeValidateNameFalse() {
    _isValidName.value = false;
  }

  void jumpToPage(String page) {
    _jumpTo.value = page;
  }

  void moveToBlakiList({
    @required String id,
    @required String title,
    @required String url,
  }) async {
    List<Map> _flag = [];
    _imageListDeleted.clear();
    _imageListSaved.value = await result.cache.readData('deleted');
    _imageListSaved.forEach((element) {
      _flag.add({
        'id': element.id,
        'title': element.title,
        'url': element.url,
      });
    });
    _flag.add({
      'id': id,
      'title': title,
      'url': url,
    });
    await result.cache.writeData(jsonEncode(_flag), path: 'deleted');
    _navigateTo.value = '/';
  }

  void onSubmited(String value) async {
    clearValues();
    _errorTextDialog.value = null;
    _imageListSearched.value = await result.repository.getImagesByName(value);
    _imageListSearched.forEach((element) {
      _imageListSearchedMap.add(element.toMap());
    });
  }

  void clearValues() {
    _imageList.clear();
    _imageListSearched.clear();
    _imageListSearchedMap.clear();
  }
}
