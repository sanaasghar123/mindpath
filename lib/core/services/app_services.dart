import 'package:get/get.dart';

class ApiService extends GetxService {
  Future<Response<T>> getRequest<T>(String url) async {
    return Response<T>(statusCode: 501);
  }
}

class FirebaseService extends GetxService {
  Future<FirebaseService> init() async {
    return this;
  }
}

