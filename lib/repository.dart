import 'package:dio/dio.dart';

import 'game/enemy.dart';

class Repository {

  late Dio dio;

  var options = BaseOptions(
    baseUrl: "https://reqres.in/api",
    connectTimeout: 5000,
    receiveTimeout: 3000
  );

  Repository() {
    dio = Dio(options);
    dio.interceptors.add(LogInterceptor());
  }

  Future<dynamic> getUsers() async {
    try {
      Response response = await dio.get("/users?page=1");
      Map<String, dynamic> data = response.data;
      List<Enemy> users = data["data"].map<Enemy>((e) => Enemy.fromJson(e)).toList();

      return users;
    } on DioError catch (e) {
      return e;
    }
  }
}