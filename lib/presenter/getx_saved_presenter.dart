import 'package:get/get.dart';
import 'package:meta/meta.dart';
import '../model/model.dart';

class GetXSavedPresenter extends GetxController {
  final ImageResults result;
  GetXSavedPresenter({@required this.result});

  var _imageListSaved = <ImageModel>[].obs;
  List<ImageModel> get imageSavedListStream => _imageListSaved.toList();

  @override
  void onInit() async {
    _imageListSaved.value = await result.cache.readData('saved');
    super.onInit();
  }
}