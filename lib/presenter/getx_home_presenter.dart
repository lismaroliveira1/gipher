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
  var _imageListRelated = <ImageModel>[];
  var _imageMapRelated = <Map>[];
  var _appInstalledsMap = {}.obs;
  var _imageListMap = <Map>[].obs;
  var _imageListSearchedMap = <Map>[].obs;
  var _imageListSearched = <ImageModel>[].obs;
  var _defaultLimit = 30.obs;
  var _wayViewMode = 1.obs;
  var _isValidName = false.obs;
  var _errorTextDialog = RxString(null);
  var _isLoading = true.obs;
  var _showEditImageDialog = false.obs;
  var _offsetPage = 1.obs;
  var _searchName = RxString('');
  var _imageDetailsMap = {}.obs;
  var isGettingRelateds = false.obs;
  var _imageQuality = RxInt(1);
  var _repositoryError = false.obs;
  var _cacheEmpityError = false.obs;

  List<ImageModel> get imageListStream => _imageList.toList();
  List<ImageModel> get imageListSearchedOut => _imageListSearched.toList();
  List<Map> get imageListMapOut => _imageListMap.toList();
  Map get appInstalledMapOut => _appInstalledsMap;
  List<ImageModel> get imageListModelOut => _imageList.toList();
  List<Map> get imageListSearchedMapOut => _imageListSearchedMap.toList();
  List<ImageModel> get imageListSearchedModelOut => _imageListSearched.toList();
  ImageModel get imageDetailsOut => _imageDetails.value;
  Map get imageDetailsMapOut => _imageDetailsMap;
  List<ImageModel> get imageListRelatedStream => [];
  Stream<String> get navigateToStream => _navigateTo.stream;
  Stream<String> get jumpToStream => _jumpTo.stream;
  Stream<bool> get showEditDialogStream => _showEditImageDialog.stream;
  String get errorTextDialogOut => _errorTextDialog.value;
  int get limitImageView => _defaultLimit.toInt();
  int get wayViewModeOut => _wayViewMode.toInt();
  bool get isValidNameOut => _isValidName.value;
  bool get isLoadingStream => _isLoading.value;
  bool get repositoryErrorOut => _repositoryError.value;
  bool get cacheEmpityErrorOut => _cacheEmpityError.value;
  String get searchNameOut => _searchName.value;

  @override
  void onInit() async {
    await result.cache.verifyCache();
    final setup = await result.cache.readData('setup');
    _imageQuality.value = setup[0]['imageQuality'];
    _defaultLimit.value = setup[0]['imagePerPage'];
    _wayViewMode.value = setup[0]['wayViewMode'];
    clearValues();
    await result.cache.writeData(jsonEncode({}), path: 'off_images');
    try {
      _imageList.value = await result.repository.getAll(
        limit: _defaultLimit.value,
        offset: _offsetPage.value,
        imageQuality: _imageQuality.value,
      );
      _imageList.forEach((element) async {
        List<Map> flag = [];
        List<ImageModel> images = await result.repository.getImagesByName(
          value: element.title.split(' ')[1],
          imageQuality: _imageQuality.value,
        );
        images.forEach((element) {
          flag.add(element.toMap());
        });
        _imageListMap.add({
          'image': element.toMap(),
          'relateds': flag,
        });
        await result.cache
            .writeData(jsonEncode(_imageListMap), path: 'off_images');
      });
    } on HttpError {
      _imageListMap = await result.cache.readData('off_images');
      _repositoryError.value = true;
      if (_imageListMap == null || _imageListMap.isEmpty)
        _cacheEmpityError.value = true;
    }
    _isLoading.value = false;
    _appInstalledsMap.value = await result.socialGifShare.checkSocialApps();
    super.onInit();
  }

  Future<void> changeWayViewMode(int value) async {
    _wayViewMode.value = value;
    await writeFileStorage(key: 'wayViewMode', value: value, path: 'setup');
  }

  Future<void> getMoreImages() async {
    _offsetPage.value++;
    var newList = await result.repository.getAll(
      limit: 50,
      offset: _offsetPage.value,
      imageQuality: _imageQuality.value,
    );
    newList.forEach((element) async {
      List<Map> flag = [];
      List<ImageModel> images = await result.repository.getImagesByName(
        value: element.title.split(' ')[1],
        imageQuality: _imageQuality.value,
      );
      images.forEach((element) {
        flag.add(element.toMap());
      });
      _imageListMap.add({
        'image': element.toMap(),
        'relateds': flag,
      });
    });
  }

  void showGifDetails(Map imageMap) async {
    _imageDetails.value = ImageModel.fromMap(imageMap);
    _imageDetailsMap.value = _imageDetails.value.toMap();
    await getRelatedImages(imageMap['slug'.split('_')[0]]);
  }

  Future<void> saveImage(Map imageMap) async {
    List<Map> _flag = [];
    _flag = await result.cache.readData('saved');
    _flag.add(imageMap);
    await result.cache.writeData(jsonEncode(_flag), path: 'saved');
  }

  void validateDialogName(String value) {
    final validationResult = commons.validateName(value);
    _isValidName.value = validationResult['isValidName'];
    _errorTextDialog.value = validationResult['errorTextDialog'];
  }

  void validateSearchName(String value) {
    _isLoading.value = true;
    final validationResult = commons.validateName(value);
    _isValidName.value = validationResult['isValidName'];
    _errorTextDialog.value = validationResult['errorTextDialog'];
    _isLoading.value = false;
  }

  void makeValidateNameFalse() {
    _isValidName.value = false;
  }

  void jumpToPage(String page) {
    _jumpTo.value = page;
  }

  void filterCallback(String name) async {
    _isLoading.value = true;
    await onSubmited(name);
    _isLoading.value = false;
  }

  void moveToBlakiList(
    Map imageGif,
  ) async {
    var _flag = await result.cache.readData('deleted');
    _flag.add(imageGif);
    await result.cache.writeData(jsonEncode(_flag), path: 'deleted');
  }

  Future<void> onSubmited(String value) async {
    _searchName.value = value;
    _errorTextDialog.value = null;
    _imageListSearched.value = await result.repository.getImagesByName(
      value: value,
      imageQuality: _imageQuality.value,
    );
    _imageListSearchedMap.clear();
    _imageListSearched.forEach((element) async {
      List<Map> flag = [];
      List<ImageModel> images = await result.repository.getImagesByName(
        value: element.title.split(' ')[1],
        imageQuality: _imageQuality.value,
      );
      images.forEach((element) {
        flag.add(element.toMap());
      });
      _imageListSearchedMap.add({
        'image': element.toMap(),
        'relateds': flag,
      });
    });
  }

  void clearValues() {
    _imageList.clear();
    _imageListSearched.clear();
    _imageListSearchedMap.clear();
    _imageListRelated.clear();
    _imageMapRelated.clear();
  }

  void closeSearch() {
    _imageListSearched.clear();
    _imageListSearchedMap.clear();
  }

  void showEditDialog() {
    _showEditImageDialog.value = !_showEditImageDialog.value;
  }

  Future<void> getRelatedImages(String name) async {
    isGettingRelateds.value = true;
    _imageListRelated = await result.repository.getImagesByName(
      value: name,
      imageQuality: _imageQuality.value,
    );
    _imageListRelated.forEach((element) {
      _imageMapRelated.add(element.toMap());
    });
  }

  void clearRelatedList() {
    _imageListRelated.clear();
    _imageMapRelated.clear();
  }

  void shareByFacebook(Map imageMap) {}

  void shareByInstagram(Map imageMap) {
    result.socialGifShare.shareByInstagram(imageMap);
  }

  void shareByWhatsApp(Map imageMap) {
    result.socialGifShare.shareByWhatsApp(imageMap);
  }

  void shareByTwitter(Map imageMap) {
    result.socialGifShare.shareTwitter(imageMap);
  }

  void shareByMessenger(Map imageMap) {
    result.socialGifShare.shareByMessenger(imageMap);
  }

  Future<void> writeFileStorage({
    @required String key,
    @required dynamic value,
    @required String path,
  }) async {
    var setup = await result.cache.readData(path);
    setup[0][key] = value;
    await result.cache.writeData(jsonEncode(setup), path: path);
  }
}
