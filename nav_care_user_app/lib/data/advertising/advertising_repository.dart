import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/advertising/models/advertising_model.dart';
import 'package:nav_care_user_app/data/advertising/services/advertising_remote_service.dart';

abstract class AdvertisingRepository {
  Future<Result<List<Advertising>>> getAdvertisings({String? position});
}

class AdvertisingRepositoryImpl implements AdvertisingRepository {
  final AdvertisingService _advertisingService;

  AdvertisingRepositoryImpl({required AdvertisingService advertisingService})
      : _advertisingService = advertisingService;

  @override
  Future<Result<List<Advertising>>> getAdvertisings({String? position}) {
    return _advertisingService.getAdvertisings(position: position);
  }
}
